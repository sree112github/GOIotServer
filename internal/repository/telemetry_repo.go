package repository

import (
	"IotProto/internal/config"
	model "IotProto/internal/models"
	"context"
	"log"
	"time"

	"github.com/jackc/pgx/v5"
)

// CopyBatch inserts records efficiently using pgx COPY FROM
func CopyBatch(ctx context.Context, records []model.TelemetryRecord) error {
	if len(records) == 0 {
		return nil
	}

	rows := make([][]interface{}, len(records))
	for i, rec := range records {
		rows[i] = []interface{}{
			rec.ClientID, rec.Username, rec.Topic, rec.Payload, rec.Timestamp,
		}
	}

	start := time.Now()

	count, err := config.DB.CopyFrom(
		ctx,
		pgx.Identifier{"mqtt_telemetry"},
		[]string{"client_id", "username", "topic", "payload", "timestamp"},
		pgx.CopyFromRows(rows),
	)
	if err != nil {
		return err
	}

	log.Printf("✅ COPY inserted %d rows in %v", count, time.Since(start))
	return nil
}
