package controller

import (
	"net/http"

	model "IotProto/internal/models"
	"IotProto/internal/service"
	"IotProto/internal/utils"

	"github.com/gin-gonic/gin"
)

// HandleWebhook handles the incoming POST requests
func HandleWebhook(c *gin.Context) {
	var msg struct {
		ClientID string `json:"clientid"`
		Username string `json:"username"`
		Topic    string `json:"topic"`
		Payload  string `json:"payload"`
	}
	if err := c.ShouldBindJSON(&msg); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid JSON"})
		return
	}

	decodedPayload, timestamp, err := utils.DecodeDynamicPayload(msg.Payload)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	jsonPayload, err := service.MarshalPayload(decodedPayload)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "JSON marshal failed"})
		return
	}

	service.EnqueueTelemetry(model.TelemetryRecord{
		ClientID:  msg.ClientID,
		Username:  msg.Username,
		Topic:     msg.Topic,
		Payload:   jsonPayload,
		Timestamp: timestamp,
	})

	c.JSON(http.StatusOK, gin.H{"status": "queued"})
}
