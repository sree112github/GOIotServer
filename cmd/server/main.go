package main

import (
	"database/sql"
	"log"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"

	handler "IotProto/internal/controller"
	"IotProto/internal/repository"
)

func main() {
	db, err := sql.Open("postgres", "postgres://postgres:148115@localhost:5432/samyojak?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	repo := repository.NewTelemetryRepo(db)
	webhookHandler := handler.NewWebhookHandler(repo)

	r := gin.Default()
	r.POST("/webhook", webhookHandler.HandleWebhook)

	log.Println("Server started on :8080")
	r.Run(":8080")
}
