package main

import (
	"IotProto/internal/proto/aq"
	"bytes"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protodesc"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/types/descriptorpb"
	"google.golang.org/protobuf/types/dynamicpb"
)

var (
	db              *sql.DB
	descriptorCache = make(map[string]protoreflect.MessageDescriptor)
	cacheMutex      = sync.RWMutex{}
)

func main() {
	var err error
	db, err = sql.Open("postgres", "postgres://postgres:148115@localhost:5432/samyojak?sslmode=disable")
	if err != nil {
		log.Fatalf("DB open fail: %v", err)
	}
	if err = db.Ping(); err != nil {
		log.Fatalf("DB ping fail: %v", err)
	}

	// Insert all proto descriptors to DB
	// utils.InsertSensorPayloadDescriptor(db)
	// utils.InsertAlertPayloadDescriptor(db) // You need to implement this in utils

	defer db.Close()

	// Start HTTP server
	r := gin.Default()
	r.POST("/webhook", handleWebhook)
	log.Println("Server started at :8080")
	r.Run(":8080")
}

// ----------------- Webhook Handler -----------------
func handleWebhook(c *gin.Context) {
	bodyBytes, err := io.ReadAll(c.Request.Body)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "failed to read body"})
		return
	}

	// Restore the body so Gin can bind JSON if needed
	c.Request.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

	var msg struct {
		ClientID string `json:"clientid"`
		Username string `json:"username"`
		Topic    string `json:"topic"`
		Payload  string `json:"payload"` // base64 encoded CommonWrapper
	}
	if err := c.ShouldBindJSON(&msg); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid JSON"})
		return
	}

	decodedPayload, timestamp, err := decodeDynamicPayload(msg.Payload)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := saveSensorData(msg.ClientID, msg.Username, msg.Topic, decodedPayload, timestamp); err != nil {
		log.Println("DB insert failed:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "DB insert failed"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"status": "success"})
}

// ----------------- Dynamic Decoding -----------------
func decodeDynamicPayload(b64 string) (map[string]any, int64, error) {
	dataBytes, err := base64.StdEncoding.DecodeString(b64)
	if err != nil {
		return nil, 0, errors.New("invalid base64")
	}

	// Decode CommonWrapper
	var wrapper aq.CommonWrapper
	if err := proto.Unmarshal(dataBytes, &wrapper); err != nil {
		return nil, 0, errors.New("failed to decode CommonWrapper")
	}

	log.Printf("Wrapper: device_id=%s schema_name=%s payload_len=%d",
		wrapper.DeviceId, wrapper.SchemaName, len(wrapper.Payload))

	// Load the correct descriptor dynamically
	msgDesc, err := loadDescriptorCached(wrapper.SchemaName)
	if err != nil {
		return nil, 0, err
	}

	// Decode inner payload dynamically
	dynMsg := dynamicpb.NewMessage(msgDesc)
	if err := proto.Unmarshal(wrapper.Payload, dynMsg); err != nil {
		return nil, 0, errors.New("invalid inner protobuf payload")
	}

	// Convert fields to map
	out := make(map[string]any)
	var timestamp int64
	fields := msgDesc.Fields()
	for i := 0; i < fields.Len(); i++ {
		fd := fields.Get(i)
		val := dynMsg.Get(fd)
		fieldName := string(fd.Name())
		out[fieldName] = val.Interface()
		if fieldName == "timestamp" {
			if ts, ok := val.Interface().(int64); ok {
				timestamp = ts
			}
		}
	}

	return out, timestamp, nil
}

// ----------------- Descriptor Loading & Caching -----------------
func loadDescriptorCached(protoName string) (protoreflect.MessageDescriptor, error) {
	cacheMutex.RLock()
	if desc, ok := descriptorCache[protoName]; ok {
		cacheMutex.RUnlock()
		return desc, nil
	}
	cacheMutex.RUnlock()

	// Load from DB if not cached
	desc, err := loadDescriptor(protoName)
	if err != nil {
		return nil, err
	}

	cacheMutex.Lock()
	descriptorCache[protoName] = desc
	cacheMutex.Unlock()
	return desc, nil
}

func loadDescriptor(protoName string) (protoreflect.MessageDescriptor, error) {
	var descBytes []byte
	err := db.QueryRow(`SELECT descriptor FROM proto_descriptors WHERE proto_name = $1`, protoName).Scan(&descBytes)
	if err != nil {
		return nil, err
	}

	var fileDescProto descriptorpb.FileDescriptorProto
	if err := proto.Unmarshal(descBytes, &fileDescProto); err != nil {
		return nil, err
	}

	fileDesc, err := protodesc.NewFile(&fileDescProto, nil)
	if err != nil {
		return nil, err
	}

	msgDesc := fileDesc.Messages().ByName(protoreflect.Name(protoName))
	if msgDesc == nil {
		return nil, errors.New("message not found in descriptor: " + protoName)
	}
	return msgDesc, nil
}

// ----------------- Save to DB -----------------
func saveSensorData(clientID, username, topic string, payload map[string]any, timestamp int64) error {
	jsonPayload, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	_, err = db.Exec(
		`INSERT INTO mqtt_telemetry(client_id, username, topic, payload, timestamp)
         VALUES ($1,$2,$3,$4,$5)`,
		clientID, username, topic, jsonPayload, timestamp,
	)
	return err
}
