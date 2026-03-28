package service

import (
	"context"
	"log/slog"
	"recycling-service/internal/mappers"
	pb "recycling-service/proto"

	"strings"
)

// CanItBeRecycledSearch implements the CanItBeRecycledSearch RPC method
func (s *RecyclingServiceServer) CanItBeRecycledSearch(ctx context.Context, req *pb.CanItBeRecycledSearchRequest) (*pb.CanItBeRecycledSearchResponse, error) {
	s.logger.Info("Received search query", slog.String("query", req.Query))

	// Use the identified item to lookup materials
	matched := s.Db.SearchMaterials(req.Query)

	if len(matched) == 0 {
		return &pb.CanItBeRecycledSearchResponse{
			Data: []*pb.RecyclingItem{
				{
					Recyclable: false,
					Advice:     "No recycling information found for the identified item.",
					BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
					BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
				},
			},
		}, nil
	}

	s.logger.Debug("Identified items: %s, Count: %s", req.Query, len(matched))

	// Process each matched item
	var items []*pb.RecyclingItem
	for _, m := range matched {
		s.logger.Debug("Processing item: %s, Recyclable: %s", req.Query, m.Recyclable)
		item := &pb.RecyclingItem{
			Recyclable: strings.ToLower(m.Recyclable) == "yes",
			Advice:     m.Tips,
			BinColour:  mappers.ToBinColour(m.Bin),
			BinType:    mappers.ToBinType(m.Bin),
		}
		items = append(items, item)
	}

	return &pb.CanItBeRecycledSearchResponse{
		Data: items,
	}, nil
}
