package main

import (
	"encoding/json"
	"log"
	"net"

	"recycling-service/internal/models"
	"recycling-service/internal/service"
	pb "recycling-service/proto"

	"google.golang.org/grpc"
)

func main() {
	// Load materials DB
	var db models.MaterialsDB
	if err := json.Unmarshal(service.MaterialsJSON, &db); err != nil {
		log.Fatalf("failed to parse materials: %v", err)
	}

	// Create a listener on TCP port 50051
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	// Create a gRPC server object
	s := grpc.NewServer()

	// Register the RecyclingService with the server
	recyclingService := &service.RecyclingServiceServer{
		Db: db,
	}
	pb.RegisterRecyclingServiceServer(s, recyclingService)

	// Start serving requests
	log.Printf("server listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
