package service

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"recycling-service/internal/mappers"
	"recycling-service/internal/models"
	pb "recycling-service/proto"

	"strings"
)

// CanItBeRecycled implements the CanItBeRecycled RPC method
func (s *RecyclingServiceServer) CanItBeRecycled(ctx context.Context, req *pb.CanItBeRecycledRequest) (*pb.CanItBeRecycledResponse, error) {
	s.logger.Info("Received barcode: %s", req.Barcode)
	barcode := strings.TrimSpace(req.Barcode)

	// Fetch from Open Food Facts
	url := fmt.Sprintf(
		"https://world.openfoodfacts.org/api/v2/product/%s?fields=product_name,brands,packaging_tags,packaging_materials_tags,packaging_shapes_tags,packaging_text",
		barcode,
	)

	resp, err := http.Get(url)
	if err != nil {
		// Return default not recyclable if API fails
		return &pb.CanItBeRecycledResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "Unable to check recycling information. Please check local guidelines.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}
	defer resp.Body.Close()

	var off models.OFFResponse
	if err := json.NewDecoder(resp.Body).Decode(&off); err != nil {
		return &pb.CanItBeRecycledResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "Unable to check recycling information. Please check local guidelines.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}

	if off.Status == 0 {
		// Product not found
		return &pb.CanItBeRecycledResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "Product not found. Unable to determine recycling information.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}

	// Extract tags
	allTags := append(off.Product.PackagingTags, off.Product.PackagingMaterialsTags...)
	allTags = append(allTags, off.Product.PackagingShapesTags...)

	// Map to materials
	matched := s.Db.LookupMaterials(allTags)

	if len(matched) == 0 {
		return &pb.CanItBeRecycledResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "No packaging materials could be identified. Please check local recycling guidelines.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}

	// Use the first matched material
	m := matched[0]

	// Map to RecyclingItem
	item := &pb.RecyclingItem{
		Recyclable: strings.ToLower(m.Recyclable) == "yes",
		Advice:     m.Tips,
		BinColour:  mappers.ToBinColour(m.Bin),
		BinType:    mappers.ToBinType(m.Bin),
	}

	return &pb.CanItBeRecycledResponse{
		Data: item,
	}, nil
}
