package usecase

import (
	"context"
	"time"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/module/history/repository"
	"github.com/google/uuid"
)

type HistoryUsecase struct {
	repo repository.HistoryRepository
}

func NewHistoryUsecase(repo repository.HistoryRepository) *HistoryUsecase {
	return &HistoryUsecase{repo: repo}
}

type AddEntryRequest struct {
	Type   string `json:"type" binding:"required"`
	Input  string `json:"input" binding:"required"`
	Result string `json:"result" binding:"required"`
}

type ListResult struct {
	Entries    []repository.HistoryEntry `json:"entries"`
	TotalCount int                       `json:"totalCount"`
	Page       int                       `json:"page"`
	PageSize   int                       `json:"pageSize"`
	TotalPages int                       `json:"totalPages"`
}

func (uc *HistoryUsecase) List(ctx context.Context, userID string, page, pageSize int) (*ListResult, error) {
	if page < 1 {
		page = 1
	}
	if pageSize < 1 || pageSize > 100 {
		pageSize = 20
	}

	entries, totalCount, err := uc.repo.List(ctx, userID, page, pageSize)
	if err != nil {
		return nil, err
	}

	totalPages := (totalCount + pageSize - 1) / pageSize
	if totalPages < 1 {
		totalPages = 1
	}

	return &ListResult{
		Entries:    entries,
		TotalCount: totalCount,
		Page:       page,
		PageSize:   pageSize,
		TotalPages: totalPages,
	}, nil
}

func (uc *HistoryUsecase) Add(ctx context.Context, userID string, req AddEntryRequest) (*repository.HistoryEntry, error) {
	entry := repository.HistoryEntry{
		ID:        uuid.New().String(),
		UserID:    userID,
		Type:      req.Type,
		Input:     req.Input,
		Result:    req.Result,
		Favorite:  false,
		CreatedAt: time.Now().UTC(),
	}
	if err := uc.repo.Add(ctx, entry); err != nil {
		return nil, err
	}
	return &entry, nil
}

func (uc *HistoryUsecase) Delete(ctx context.Context, id string) error {
	return uc.repo.Delete(ctx, id)
}

func (uc *HistoryUsecase) Clear(ctx context.Context, userID string) error {
	return uc.repo.Clear(ctx, userID)
}

func (uc *HistoryUsecase) ToggleFavorite(ctx context.Context, id string) (*repository.HistoryEntry, error) {
	return uc.repo.ToggleFavorite(ctx, id)
}
