package config

import (
	"context"
	"log"
	"sync"

	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	DB   *pgxpool.Pool
	once sync.Once
)

// InitDB initializes the pgx pool
func InitDB() {
	once.Do(func() {
		ctx := context.Background()
		dsn := "postgres://postgres:6043940@localhost:5433/samyojak1?sslmode=disable"

		var err error
		DB, err = pgxpool.New(ctx, dsn)
		if err != nil {
			log.Fatalf("❌ Failed to create pgx pool: %v", err)
		}

		if err := DB.Ping(ctx); err != nil {
			log.Fatalf("❌ DB ping failed: %v", err)
		}

		log.Println("✅ Database connected successfully (pgxpool)")
	})
}
