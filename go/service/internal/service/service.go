package service

import (
	_ "embed"
	"encoding/json"
	"log/slog"
	"os"

	"recycling-service/internal/models"
	pb "recycling-service/proto"
)

//go:embed materials.json
var materialsJSON []byte

// RecyclingServiceServer implements the RecyclingService gRPC service
type RecyclingServiceServer struct {
	pb.UnimplementedRecyclingServiceServer
	Db     models.MaterialsDB
	logger *slog.Logger
}

func MakeRecylingService() *RecyclingServiceServer {
	logger := slog.New(slog.NewTextHandler(os.Stderr, nil))

	// Load materials DB
	var db models.MaterialsDB
	if err := json.Unmarshal(materialsJSON, &db); err != nil {
		logger.Error("failed to parse materials", "error", err)
	}

	return &RecyclingServiceServer{
		logger: logger,
		Db:     db,
	}
}
