package db

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/Bank-Raya/bridgtl-rdv-be-cash-mgmt-sys-migration/config"
	"github.com/jackc/pgx/v5/pgxpool"
)

func New(config *config.Config) *pgxpool.Pool {
	ctx := context.Background()

	envHost := config.DbHost
	envPort := config.DbPort
	envDatabase := config.DbDatabase
	envUsername := config.DbUsername
	envPassword := config.DbPassword

	connStr := fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=disable", envUsername, envPassword, envHost, envPort, envDatabase)

	pgxConfig, err := pgxpool.ParseConfig(connStr)
	if err != nil {
		log.Fatal("[Database] Unable to parse connection url")
	}
	pgxConfig.MaxConns = 50
	pgxConfig.MinConns = 0
	pgxConfig.MaxConnLifetime = time.Hour

	pgxConfig.MaxConnIdleTime = time.Minute * 30
	pgxConfig.HealthCheckPeriod = time.Minute
	pgxConfig.ConnConfig.ConnectTimeout = time.Second * 10
	pgxConfig.ConnConfig.RuntimeParams["timezone"] = config.DbTz

	conn, err := pgxpool.NewWithConfig(ctx, pgxConfig)
	if err != nil {
		log.Fatal("[Database] Unable to connect to database")
	}

	err = conn.Ping(ctx)
	if err != nil {
		log.Fatal("[Database] Unable to ping database")
	}

	return conn
}
