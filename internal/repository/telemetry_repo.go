package repository

import (
    "database/sql"
    "encoding/json"
)

type TelemetryRepo struct {
    db *sql.DB
}

func NewTelemetryRepo(db *sql.DB) TelemetryRepo {
    return TelemetryRepo{db: db}
}

func (r *TelemetryRepo) SaveSensorData(clientID, username, topic string, payload map[string]any, timestamp int64) error {
    // Marshal the map to JSON
    jsonPayload, err := json.Marshal(payload)
    if err != nil {
        return err
    }

    _, err = r.db.Exec(
        `INSERT INTO mqtt_telemetry(client_id, username, topic, payload, timestamp)
         VALUES ($1,$2,$3,$4,$5)`,
        clientID, username, topic, jsonPayload, timestamp,
    )
    return err
}
