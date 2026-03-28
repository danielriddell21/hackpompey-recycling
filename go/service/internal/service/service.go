package service

import (
	_ "embed"

	"recycling-service/internal/models"
	pb "recycling-service/proto"
)

//go:embed materials.json
var MaterialsJSON []byte

// RecyclingServiceServer implements the RecyclingService gRPC service
type RecyclingServiceServer struct {
	pb.UnimplementedRecyclingServiceServer
	Db models.MaterialsDB
}
