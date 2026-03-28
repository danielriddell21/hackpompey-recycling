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

func init() {
	// Set the default log level to info
	slog.SetLogLoggerLevel(slog.LevelInfo)

	logger := slog.New(slog.NewTextHandler(os.Stderr, nil))
	slog.SetDefault(logger)
}

func main() {
	// Load environment variables
	if err := godotenv.Load("../../.env.local"); err != nil {
		slog.Warn("Warning: could not load .env.local", "error", err)
	}

	logLevel := os.Getenv("LOG_LEVEL")
	if logLevel == "" {
		logLevel = "info"
	}
	slog.SetLogLoggerLevel(slog.Level(func() slog.Level {
		switch logLevel {
		case "debug":
			return slog.LevelDebug
		case "info":
			return slog.LevelInfo
		case "warn":
			return slog.LevelWarn
		case "error":
			return slog.LevelError
		default:
			return slog.LevelInfo
		}
	}()))

	// Create a listener on TCP port 50051
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		slog.Error("failed to listen", "error", err)
	}

	// Create a gRPC server object
	s := grpc.NewServer()

	// Register the RecyclingService with the server
	recyclingService := service.MakeRecylingService()
	pb.RegisterRecyclingServiceServer(s, recyclingService)

	// Start serving requests
	slog.Info("server listening at", "address", lis.Addr())
	if err := s.Serve(lis); err != nil {
		slog.Error("failed to serve", "error", err)
	}
}
