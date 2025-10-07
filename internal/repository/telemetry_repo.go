package repository

// import (
// 	db "IotProto/internal/config"
// 	"encoding/json"
// )

// func SaveSensorData(clientID, username, topic string, payload map[string]any, timestamp int64) error {
// 	jsonPayload, err := json.Marshal(payload)
// 	if err != nil {
// 		return err
// 	}
// 	_, err = db.DB.Exec(
// 		`INSERT INTO mqtt_telemetry(client_id, username, topic, payload, timestamp)
//          VALUES ($1,$2,$3,$4,$5)`,
// 		clientID, username, topic, jsonPayload, timestamp,
// 	)
// 	return err
// }
