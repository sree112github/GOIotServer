package handler

import (
    "encoding/base64"
    "log"
    "net/http"

    "github.com/gin-gonic/gin"
    "google.golang.org/protobuf/proto"

    "IotProto/internal/proto/aq"
    "IotProto/internal/repository"
)

type WebhookHandler struct {
    repo repository.TelemetryRepo
}

func NewWebhookHandler(repo repository.TelemetryRepo) *WebhookHandler {
    return &WebhookHandler{repo: repo}
}

func (h *WebhookHandler) HandleWebhook(c *gin.Context) {
    var msg struct {
        ClientID string `json:"client_id"`
        Username string `json:"username"`
        Topic    string `json:"topic"`
        Payload  string `json:"payload"` // base64
    }

    if err := c.ShouldBindJSON(&msg); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid JSON"})
        return
    }

    dataBytes, err := base64.StdEncoding.DecodeString(msg.Payload)
    if err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid base64"})
        return
    }

    var sensor aq.SensorPayload
    if err := proto.Unmarshal(dataBytes, &sensor); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "invalid protobuf"})
        return
    }

    // Convert Protobuf to map for JSONB storage
    jsonMap := map[string]interface{}{
        "param_1": sensor.Param_1,
        "param_2": sensor.Param_2,
        "param_3": sensor.Param_3,
        "param_4": sensor.Param_4,
        "param_5": sensor.Param_5,
        "param_6": sensor.Param_6,
        "param_7": sensor.Param_7,
        "param_8": sensor.Param_8,
        "param_9": sensor.Param_9,
        "param_10": sensor.Param_10,
    }

    if err := h.repo.SaveSensorData(msg.ClientID, msg.Username, msg.Topic, jsonMap, sensor.Timestamp); err != nil {
        log.Println("DB insert failed:", err)
        c.JSON(http.StatusInternalServerError, gin.H{"error": "DB insert failed"})
        return
    }

    c.JSON(http.StatusOK, gin.H{"status": "success"})
}
