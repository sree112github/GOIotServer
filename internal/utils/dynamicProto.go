package utils

import (
	"IotProto/internal/proto/aq"
	"context"
	"database/sql"
	"log"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/descriptorpb"
)

func InsertSensorPayloadDescriptor(db *sql.DB) {
	// Convert raw descriptor string to bytes
	descBytes := []byte(aq.File_internal_proto_aq_sensor_proto_rawDesc)

	// Optional: unmarshal to FileDescriptorProto to validate
	var fileDescProto descriptorpb.FileDescriptorProto
	if err := proto.Unmarshal(descBytes, &fileDescProto); err != nil {
		log.Fatalf("Failed to unmarshal descriptor: %v", err)
	}

	// Insert into Postgres
	_, err := db.ExecContext(context.Background(), `
		INSERT INTO proto_descriptors (proto_name, descriptor)
		VALUES ($1, $2)
		ON CONFLICT (proto_name) DO UPDATE SET descriptor = EXCLUDED.descriptor
	`, "SensorPayload", descBytes)
	if err != nil {
		log.Fatalf("Failed to insert descriptor into DB: %v", err)
	}

	log.Println("✅ SensorPayload descriptor inserted successfully")
}
