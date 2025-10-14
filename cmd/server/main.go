package main

import (
	"context"
	"log"

	"IotProto/internal/config"
	"IotProto/internal/controller"
	"IotProto/internal/service"

	"github.com/gin-gonic/gin"
)

func main() {
	config.InitDB()
	defer config.DB.Close()

	ctx := context.Background()
	go service.StartBatchInserter(ctx)

	r := gin.Default()
	r.POST("/webhook", controller.HandleWebhook)

	log.Println("🚀 Server running at :8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("❌ Server failed: %v", err)
	}
}
