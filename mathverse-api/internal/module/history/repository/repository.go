package repository

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type HistoryEntry struct {
	ID        string    `json:"id"`
	UserID    string    `json:"userId"`
	Type      string    `json:"type"`
	Input     string    `json:"input"`
	Result    string    `json:"result"`
	Favorite  bool      `json:"favorite"`
	CreatedAt time.Time `json:"createdAt"`
}

type HistoryRepository interface {
	List(ctx context.Context, userID string, page, pageSize int) ([]HistoryEntry, int, error)
	Add(ctx context.Context, entry HistoryEntry) error
	Delete(ctx context.Context, id string) error
	Clear(ctx context.Context, userID string) error
	ToggleFavorite(ctx context.Context, id string) (*HistoryEntry, error)
}

type PostgresHistoryRepository struct {
	pool *pgxpool.Pool
}

func NewPostgresHistoryRepository(pool *pgxpool.Pool) *PostgresHistoryRepository {
	return &PostgresHistoryRepository{pool: pool}
}

func (r *PostgresHistoryRepository) List(ctx context.Context, userID string, page, pageSize int) ([]HistoryEntry, int, error) {
	var totalCount int
	err := r.pool.QueryRow(ctx, `SELECT COUNT(*) FROM history WHERE user_id = $1`, userID).Scan(&totalCount)
	if err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	if offset < 0 {
		offset = 0
	}

	rows, err := r.pool.Query(ctx,
		`SELECT id, user_id, type, input, result, favorite, created_at
		 FROM history WHERE user_id = $1
		 ORDER BY created_at DESC
		 LIMIT $2 OFFSET $3`,
		userID, pageSize, offset,
	)
	if err != nil {
		return nil, 0, err
	}
	defer rows.Close()

	var entries []HistoryEntry
	for rows.Next() {
		var e HistoryEntry
		if err := rows.Scan(&e.ID, &e.UserID, &e.Type, &e.Input, &e.Result, &e.Favorite, &e.CreatedAt); err != nil {
			return nil, 0, err
		}
		entries = append(entries, e)
	}

	return entries, totalCount, nil
}

func (r *PostgresHistoryRepository) Add(ctx context.Context, entry HistoryEntry) error {
	_, err := r.pool.Exec(ctx,
		`INSERT INTO history (id, user_id, type, input, result, favorite, created_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7)`,
		entry.ID, entry.UserID, entry.Type, entry.Input, entry.Result, entry.Favorite, entry.CreatedAt,
	)
	return err
}

func (r *PostgresHistoryRepository) Delete(ctx context.Context, id string) error {
	tag, err := r.pool.Exec(ctx, `DELETE FROM history WHERE id = $1`, id)
	if err != nil {
		return err
	}
	if tag.RowsAffected() == 0 {
		return errors.New("history entry not found")
	}
	return nil
}

func (r *PostgresHistoryRepository) Clear(ctx context.Context, userID string) error {
	_, err := r.pool.Exec(ctx, `DELETE FROM history WHERE user_id = $1`, userID)
	return err
}

func (r *PostgresHistoryRepository) ToggleFavorite(ctx context.Context, id string) (*HistoryEntry, error) {
	var e HistoryEntry
	err := r.pool.QueryRow(ctx,
		`UPDATE history SET favorite = NOT favorite
		 WHERE id = $1
		 RETURNING id, user_id, type, input, result, favorite, created_at`,
		id,
	).Scan(&e.ID, &e.UserID, &e.Type, &e.Input, &e.Result, &e.Favorite, &e.CreatedAt)
	if err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return nil, errors.New("history entry not found")
		}
		return nil, err
	}
	return &e, nil
}
