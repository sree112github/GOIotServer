package model

type TelemetryRecord struct {
	ClientID  string
	Username  string
	Topic     string
	Payload   []byte
	Timestamp int64
}
