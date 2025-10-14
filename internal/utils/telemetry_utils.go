package utils

import (
	"IotProto/internal/config"
	"IotProto/internal/proto/aq"
	"context"
	"encoding/base64"
	"errors"
	"sync"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protodesc"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/types/descriptorpb"
	"google.golang.org/protobuf/types/dynamicpb"
)

var (
	cacheMutex      sync.RWMutex
	descriptorCache = make(map[string]protoreflect.MessageDescriptor)
)

func DecodeDynamicPayload(b64 string) (map[string]any, int64, error) {
	dataBytes, err := base64.StdEncoding.DecodeString(b64)
	if err != nil {
		return nil, 0, errors.New("invalid base64")
	}

	var wrapper aq.CommonWrapper
	if err := proto.Unmarshal(dataBytes, &wrapper); err != nil {
		return nil, 0, errors.New("failed to decode CommonWrapper")
	}

	msgDesc, err := LoadDescriptorCached(wrapper.SchemaName)
	if err != nil {
		return nil, 0, err
	}

	dynMsg := dynamicpb.NewMessage(msgDesc)
	if err := proto.Unmarshal(wrapper.Payload, dynMsg); err != nil {
		return nil, 0, errors.New("invalid inner protobuf payload")
	}

	out := make(map[string]any)
	var timestamp int64
	fields := msgDesc.Fields()
	for i := 0; i < fields.Len(); i++ {
		fd := fields.Get(i)
		val := dynMsg.Get(fd)
		name := string(fd.Name())
		out[name] = val.Interface()
		if name == "timestamp" {
			if ts, ok := val.Interface().(int64); ok {
				timestamp = ts
			}
		}
	}

	return out, timestamp, nil
}

// -------- Descriptor Cache --------
func LoadDescriptorCached(protoName string) (protoreflect.MessageDescriptor, error) {
	cacheMutex.RLock()
	if desc, ok := descriptorCache[protoName]; ok {
		cacheMutex.RUnlock()
		return desc, nil
	}
	cacheMutex.RUnlock()

	desc, err := LoadDescriptor(protoName)
	if err != nil {
		return nil, err
	}

	cacheMutex.Lock()
	descriptorCache[protoName] = desc
	cacheMutex.Unlock()
	return desc, nil
}

func LoadDescriptor(protoName string) (protoreflect.MessageDescriptor, error) {
	ctx := context.Background()
	var descBytes []byte
	err := config.DB.QueryRow(ctx, `SELECT descriptor FROM proto_descriptors WHERE proto_name = $1`, protoName).Scan(&descBytes)
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
		return nil, errors.New("message not found: " + protoName)
	}
	return msgDesc, nil
}
