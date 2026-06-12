package usecase

import (
	"fmt"
	"time"

	"github.com/abdelrzz9/math_app/backend/internal/module/history/repository"
)

type HistoryUsecase struct {
	repo repository.HistoryRepository
}

func NewHistoryUsecase(repo repository.HistoryRepository) *HistoryUsecase {
	return &HistoryUsecase{repo: repo}
}

type AddEntryRequest struct {
	Type   string `json:"type"`
	Input  string `json:"input"`
	Result string `json:"result"`
}

func (uc *HistoryUsecase) List(userID string) ([]repository.HistoryEntry, error) {
	return uc.repo.List(userID)
}

func (uc *HistoryUsecase) Add(userID string, req AddEntryRequest) (*repository.HistoryEntry, error) {
	entry := repository.HistoryEntry{
		ID:        fmt.Sprintf("hist_%d", time.Now().UnixNano()),
		UserID:    userID,
		Type:      req.Type,
		Input:     req.Input,
		Result:    req.Result,
		Favorite:  false,
		CreatedAt: time.Now(),
	}
	if err := uc.repo.Add(entry); err != nil {
		return nil, err
	}
	return &entry, nil
}

func (uc *HistoryUsecase) Delete(id string) error {
	return uc.repo.Delete(id)
}

func (uc *HistoryUsecase) Clear(userID string) error {
	return uc.repo.Clear(userID)
}

func (uc *HistoryUsecase) ToggleFavorite(id string) (*repository.HistoryEntry, error) {
	return uc.repo.ToggleFavorite(id)
}
