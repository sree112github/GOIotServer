package repository

import (
	"IotProto/internal/config"
	model "IotProto/internal/models"
	"context"
	"log"

	"github.com/jackc/pgx/v5"
)

// CopyBatch inserts multiple records efficiently using pgx CopyFrom
func CopyBatch(ctx context.Context, records []model.TelemetryRecord) error {
	if len(records) == 0 {
		return nil
	}

	rows := make([][]any, len(records))
	for i, rec := range records {
		rows[i] = []any{
			rec.ClientID, rec.Username, rec.Topic, rec.Payload, rec.Timestamp,
		}
	}

	count, err := config.DB.CopyFrom(
		ctx,
		pgx.Identifier{"mqtt_telemetry"},
		[]string{"client_id", "username", "topic", "payload", "timestamp"},
		pgx.CopyFromRows(rows),
	)
	if err != nil {
		return err
	}

	log.Printf("✅ COPY inserted %d rows", count)
	return nil
}
