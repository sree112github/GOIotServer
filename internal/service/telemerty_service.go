package service

import (
	model "IotProto/internal/models"
	"IotProto/internal/repository"
	"context"
	"encoding/json"
	"log"
	"time"
)

var telemetryChan = make(chan model.TelemetryRecord, 1000)

// StartBatchInserter starts a goroutine that flushes in batches
func StartBatchInserter(ctx context.Context) {
	const batchSize = 20
	const flushInterval = 10 * time.Second

	ticker := time.NewTicker(flushInterval)
	defer ticker.Stop()

	var buffer []model.TelemetryRecord

	for {
		select {
		case rec := <-telemetryChan:
			buffer = append(buffer, rec)
			if len(buffer) >= batchSize {
				repository.CopyBatch(ctx, buffer)
				buffer = buffer[:0]
			}

		case <-ticker.C:
			if len(buffer) > 0 {
				repository.CopyBatch(ctx, buffer)
				buffer = buffer[:0]
			}
		}
	}
}

// EnqueueTelemetry safely sends a telemetry record into the channel
func EnqueueTelemetry(rec model.TelemetryRecord) {
	select {
	case telemetryChan <- rec:
	default:
		log.Println("⚠️ Telemetry channel full — dropping data!")
	}
}

// MarshalPayload converts map payload to JSON
func MarshalPayload(payload map[string]any) ([]byte, error) {
	return json.Marshal(payload)
}
