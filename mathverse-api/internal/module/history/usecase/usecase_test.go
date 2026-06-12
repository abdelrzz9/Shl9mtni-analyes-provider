package usecase

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/abdelrzz9/math_app/mathverse-api/internal/module/history/repository"
)

type mockHistoryRepo struct {
	entries map[string]repository.HistoryEntry
	addErr  error
}

func newMockHistoryRepo() *mockHistoryRepo {
	return &mockHistoryRepo{
		entries: make(map[string]repository.HistoryEntry),
	}
}

func (m *mockHistoryRepo) List(ctx context.Context, userID string, page, pageSize int) ([]repository.HistoryEntry, int, error) {
	var userEntries []repository.HistoryEntry
	for _, e := range m.entries {
		if e.UserID == userID {
			userEntries = append(userEntries, e)
		}
	}
	total := len(userEntries)
	start := (page - 1) * pageSize
	if start >= total {
		return []repository.HistoryEntry{}, total, nil
	}
	end := start + pageSize
	if end > total {
		end = total
	}
	return userEntries[start:end], total, nil
}

func (m *mockHistoryRepo) Add(ctx context.Context, entry repository.HistoryEntry) error {
	if m.addErr != nil {
		return m.addErr
	}
	m.entries[entry.ID] = entry
	return nil
}

func (m *mockHistoryRepo) Delete(ctx context.Context, id string) error {
	if _, ok := m.entries[id]; !ok {
		return errors.New("history entry not found")
	}
	delete(m.entries, id)
	return nil
}

func (m *mockHistoryRepo) Clear(ctx context.Context, userID string) error {
	for id, e := range m.entries {
		if e.UserID == userID {
			delete(m.entries, id)
		}
	}
	return nil
}

func (m *mockHistoryRepo) ToggleFavorite(ctx context.Context, id string) (*repository.HistoryEntry, error) {
	e, ok := m.entries[id]
	if !ok {
		return nil, errors.New("history entry not found")
	}
	e.Favorite = !e.Favorite
	m.entries[id] = e
	return &e, nil
}

func TestHistoryList_DefaultPagination(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	for i := 0; i < 5; i++ {
		uc.Add(context.Background(), "user-1", AddEntryRequest{
			Type:   "calculator",
			Input:  "2+2",
			Result: "4",
		})
	}

	result, err := uc.List(context.Background(), "user-1", 0, 0)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if result.Page != 1 {
		t.Errorf("expected page 1, got %d", result.Page)
	}
	if result.PageSize != 20 {
		t.Errorf("expected pageSize 20, got %d", result.PageSize)
	}
	if len(result.Entries) != 5 {
		t.Errorf("expected 5 entries, got %d", len(result.Entries))
	}
	if result.TotalCount != 5 {
		t.Errorf("expected totalCount 5, got %d", result.TotalCount)
	}
}

func TestHistoryList_Pagination(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	for i := 0; i < 10; i++ {
		uc.Add(context.Background(), "user-1", AddEntryRequest{
			Type:   "calculator",
			Input:  "2+2",
			Result: "4",
		})
	}

	result, err := uc.List(context.Background(), "user-1", 1, 3)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(result.Entries) != 3 {
		t.Errorf("expected 3 entries, got %d", len(result.Entries))
	}
	if result.TotalCount != 10 {
		t.Errorf("expected totalCount 10, got %d", result.TotalCount)
	}
	if result.TotalPages != 4 {
		t.Errorf("expected 4 totalPages, got %d", result.TotalPages)
	}
}

func TestHistoryList_Empty(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	result, err := uc.List(context.Background(), "user-1", 1, 20)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(result.Entries) != 0 {
		t.Errorf("expected 0 entries, got %d", len(result.Entries))
	}
	if result.TotalCount != 0 {
		t.Errorf("expected totalCount 0, got %d", result.TotalCount)
	}
	if result.TotalPages != 1 {
		t.Errorf("expected 1 totalPages, got %d", result.TotalPages)
	}
}

func TestHistoryAdd_Success(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	entry, err := uc.Add(context.Background(), "user-1", AddEntryRequest{
		Type:   "derivative",
		Input:  "x^2",
		Result: "2x",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if entry.ID == "" {
		t.Error("expected non-empty ID")
	}
	if entry.UserID != "user-1" {
		t.Errorf("expected userID 'user-1', got '%s'", entry.UserID)
	}
	if entry.Type != "derivative" {
		t.Errorf("expected type 'derivative', got '%s'", entry.Type)
	}
	if entry.Favorite {
		t.Error("expected favorite to be false")
	}
	if entry.CreatedAt.IsZero() {
		t.Error("expected non-zero CreatedAt")
	}
}

func TestHistoryDelete_Success(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	entry, err := uc.Add(context.Background(), "user-1", AddEntryRequest{
		Type:   "calculator",
		Input:  "2+2",
		Result: "4",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	err = uc.Delete(context.Background(), entry.ID)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	result, _ := uc.List(context.Background(), "user-1", 1, 20)
	if len(result.Entries) != 0 {
		t.Errorf("expected 0 entries after delete, got %d", len(result.Entries))
	}
}

func TestHistoryDelete_NotFound(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	err := uc.Delete(context.Background(), "non-existent-id")
	if err == nil {
		t.Fatal("expected error, got nil")
	}
}

func TestHistoryClear(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	for i := 0; i < 3; i++ {
		uc.Add(context.Background(), "user-1", AddEntryRequest{
			Type:   "calculator",
			Input:  "2+2",
			Result: "4",
		})
	}

	err := uc.Clear(context.Background(), "user-1")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	result, _ := uc.List(context.Background(), "user-1", 1, 20)
	if len(result.Entries) != 0 {
		t.Errorf("expected 0 entries after clear, got %d", len(result.Entries))
	}
}

func TestHistoryToggleFavorite(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	entry, err := uc.Add(context.Background(), "user-1", AddEntryRequest{
		Type:   "calculator",
		Input:  "2+2",
		Result: "4",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	updated, err := uc.ToggleFavorite(context.Background(), entry.ID)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if !updated.Favorite {
		t.Error("expected favorite to be true after toggle")
	}

	updated, err = uc.ToggleFavorite(context.Background(), entry.ID)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if updated.Favorite {
		t.Error("expected favorite to be false after second toggle")
	}
}

func TestHistoryToggleFavorite_NotFound(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	_, err := uc.ToggleFavorite(context.Background(), "non-existent-id")
	if err == nil {
		t.Fatal("expected error, got nil")
	}
}

func TestHistoryAdd_Timestamp(t *testing.T) {
	repo := newMockHistoryRepo()
	uc := NewHistoryUsecase(repo)

	before := time.Now().UTC()
	entry, err := uc.Add(context.Background(), "user-1", AddEntryRequest{
		Type:   "calculator",
		Input:  "2+2",
		Result: "4",
	})
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	after := time.Now().UTC()

	if entry.CreatedAt.Before(before.Add(-time.Second)) || entry.CreatedAt.After(after.Add(time.Second)) {
		t.Errorf("CreatedAt %v not in expected range [%v, %v]", entry.CreatedAt, before, after)
	}
}
