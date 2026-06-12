package repository

import (
	"fmt"
	"sync"
	"time"
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
	List(userID string) ([]HistoryEntry, error)
	Add(entry HistoryEntry) error
	Delete(id string) error
	Clear(userID string) error
	ToggleFavorite(id string) (*HistoryEntry, error)
}

type InMemoryHistoryRepo struct {
	mu    sync.RWMutex
	data  map[string][]HistoryEntry
	index int
}

func NewInMemoryHistoryRepo() *InMemoryHistoryRepo {
	return &InMemoryHistoryRepo{
		data: make(map[string][]HistoryEntry),
	}
}

func (r *InMemoryHistoryRepo) List(userID string) ([]HistoryEntry, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	entries := r.data[userID]
	if entries == nil {
		return []HistoryEntry{}, nil
	}
	result := make([]HistoryEntry, len(entries))
	copy(result, entries)
	return result, nil
}

func (r *InMemoryHistoryRepo) Add(entry HistoryEntry) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.data[entry.UserID] = append(r.data[entry.UserID], entry)
	return nil
}

func (r *InMemoryHistoryRepo) Delete(id string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	for userID, entries := range r.data {
		for i, e := range entries {
			if e.ID == id {
				r.data[userID] = append(entries[:i], entries[i+1:]...)
				return nil
			}
		}
	}
	return fmt.Errorf("history entry not found: %s", id)
}

func (r *InMemoryHistoryRepo) Clear(userID string) error {
	r.mu.Lock()
	defer r.mu.Unlock()
	delete(r.data, userID)
	return nil
}

func (r *InMemoryHistoryRepo) ToggleFavorite(id string) (*HistoryEntry, error) {
	r.mu.Lock()
	defer r.mu.Unlock()
	for userID, entries := range r.data {
		for i, e := range entries {
			if e.ID == id {
				r.data[userID][i].Favorite = !e.Favorite
				return &r.data[userID][i], nil
			}
		}
	}
	return nil, fmt.Errorf("history entry not found: %s", id)
}
