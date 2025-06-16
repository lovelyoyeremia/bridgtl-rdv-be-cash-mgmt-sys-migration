package repository

import "github.com/jackc/pgx/v5/pgxpool"

type Store struct {
	*Queries
	Pool *pgxpool.Pool
}

func NewStore(conn *pgxpool.Pool) *Store {
	return &Store{
		Queries: New(conn),
		Pool:    conn,
	}
}
