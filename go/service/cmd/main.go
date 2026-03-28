package main

import (
	"log/slog"
	"net"
	"os"

	"recycling-service/internal/service"
	pb "recycling-service/proto"

	"github.com/joho/godotenv"
	"google.golang.org/grpc"
)

func main() {
	logger := slog.New(slog.NewTextHandler(os.Stderr, nil))

	// Load environment variables
	if err := godotenv.Load("../../.env.local"); err != nil {
		logger.Warn("Warning: could not load .env.local", "error", err)
	}

	// Create a listener on TCP port 50051
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		logger.Error("failed to listen", "error", err)
	}

	// Create a gRPC server object
	s := grpc.NewServer()

	// Register the RecyclingService with the server
	recyclingService := service.MakeRecylingService()
	pb.RegisterRecyclingServiceServer(s, recyclingService)

	// Start serving requests
	logger.Info("server listening at", "address", lis.Addr())
	if err := s.Serve(lis); err != nil {
		logger.Error("failed to serve", "error", err)
	}
}
