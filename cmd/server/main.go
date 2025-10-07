package main

import (
	"IotProto/internal/utils"
	"database/sql"
	"encoding/base64"
	"encoding/json"
	"errors"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protodesc"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/types/descriptorpb"
	"google.golang.org/protobuf/types/dynamicpb"
)

var (
	db                   *sql.DB
	sensorPayloadMsgDesc protoreflect.MessageDescriptor
)

func main() {
	// Initialize database (use your connection string)
	var err error
	db, err = sql.Open("postgres", "postgres://postgres:148115@localhost:5432/samyojak?sslmode=disable")
	if err != nil {
		log.Fatalf("DB open fail: %v", err)
	}
	if err = db.Ping(); err != nil {
		log.Fatalf("DB ping fail: %v", err)
	}

	utils.InsertSensorPayloadDescriptor(db)
	defer db.Close()

	
	// Load proto descriptor from DB to global variable
	if err = loadSensorPayloadDescriptor(); err != nil {
		log.Fatalf("Failed to load descriptor: %v", err)
	}

	// Setup Gin HTTP server
	r := gin.Default()
	r.POST("/webhook", handleWebhook)
	log.Println("Server started at :8080")
	r.Run(":8080")
}

// -- Descriptor Loader --

func loadSensorPayloadDescriptor() error {
	var descBytes []byte
	err := db.QueryRow(`SELECT descriptor FROM proto_descriptors WHERE proto_name = 'SensorPayload'`).Scan(&descBytes)
	if err != nil {
		return err
	}
	var fileDescriptor descriptorpb.FileDescriptorProto
	if err := proto.Unmarshal(descBytes, &fileDescriptor); err != nil {
		panic(err)
	}
	// You now have *descriptorpb.FileDescriptorProto, can pass to protodesc.NewFile:
	fileDesc, err := protodesc.NewFile(&fileDescriptor, nil)
	if err != nil {
		panic(err)
	}
	msgDesc := fileDesc.Messages().ByName("SensorPayload")
	if msgDesc == nil {
		return errors.New("SensorPayload not found in descriptor")
	}
	sensorPayloadMsgDesc = msgDesc
	return nil
}

// -- Webhook Handler --

func handleWebhook(c *gin.Context) {
	var msg struct {
		ClientID string `json:"clientid"`
		Username string `json:"username"`
		Topic    string `json:"topic"`
		Payload  string `json:"payload"` // base64 encoded protobuf
	}
	if err := c.ShouldBindJSON(&msg); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid JSON"})
		return
	}
	jsonMap, timestamp, err := decodeDynamicPayload(msg.Payload)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if err := saveSensorData(msg.ClientID, msg.Username, msg.Topic, jsonMap, timestamp); err != nil {
		log.Println("DB insert failed:", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "DB insert failed"})
		return
	}
	c.JSON(http.StatusOK, gin.H{"status": "success"})
}

// -- Dynamic Decoding of Protobuf Payload --

func decodeDynamicPayload(b64 string) (map[string]any, int64, error) {
	dataBytes, err := base64.StdEncoding.DecodeString(b64)
	if err != nil {
		return nil, 0, errors.New("invalid base64")
	}
	dynMsg := dynamicpb.NewMessage(sensorPayloadMsgDesc)
	if err := proto.Unmarshal(dataBytes, dynMsg); err != nil {
		return nil, 0, errors.New("invalid protobuf")
	}
	out := make(map[string]any)
	var timestamp int64 = 0
	fields := sensorPayloadMsgDesc.Fields()
	for i := 0; i < fields.Len(); i++ {
		fd := fields.Get(i)
		val := dynMsg.Get(fd)
		goName := string(fd.Name())
		out[goName] = val.Interface()
		if goName == "timestamp" {
			if ts, ok := val.Interface().(int64); ok {
				timestamp = ts
			}
		}
	}
	return out, timestamp, nil
}

// -- Save to DB --

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
