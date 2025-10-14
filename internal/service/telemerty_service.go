package service

import (
	model "IotProto/internal/models"
	"IotProto/internal/repository"
	"context"
	"encoding/json"
	"log"
	"time"
)

var (
	recordsChan = make(chan model.TelemetryRecord, 1000) // buffered channel
)

// StartBatchInserter runs in background and inserts data in batches
func StartBatchInserter(ctx context.Context) {
	batchSize := 100
	batchTimeout := 20 * time.Second // flush interval
	insertTimeout := 5 * time.Second // DB insert timeout

	ticker := time.NewTicker(batchTimeout)
	defer ticker.Stop()

	var batch []model.TelemetryRecord

	for {
		select {
		case <-ctx.Done():
			log.Println("🛑 Batch inserter stopping...")
			if len(batch) > 0 {
				flushBatch(batch, insertTimeout)
			}
			return

		case rec := <-recordsChan:
			batch = append(batch, rec)
			if len(batch) >= batchSize {
				flushBatch(batch, insertTimeout)
				batch = nil
			}

		case <-ticker.C:
			if len(batch) > 0 {
				flushBatch(batch, insertTimeout)
				batch = nil
			}
		}
	}
}
func flushBatch(batch []model.TelemetryRecord, insertTimeout time.Duration) {
	ctx, cancel := context.WithTimeout(context.Background(), insertTimeout)
	defer cancel()

	if err := repository.CopyBatch(ctx, batch); err != nil {
		log.Printf("❌ Batch insert failed: %v", err)
		return
	}

	log.Printf("✅ Batch insert success (%d records)", len(batch))
}

// EnqueueTelemetry adds telemetry data to the channel
func EnqueueTelemetry(record model.TelemetryRecord) {
	select {
	case recordsChan <- record:
	default:
		log.Println("⚠️ Queue full, dropping record")
	}
}

// MarshalPayload converts map payload to JSON
func MarshalPayload(payload map[string]any) ([]byte, error) {
	return json.Marshal(payload)
}
