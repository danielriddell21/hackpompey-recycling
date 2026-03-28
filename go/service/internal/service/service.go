package service

import (
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	"recycling-service/internal/models"
	pb "recycling-service/proto"
)

//go:embed materials.json
var MaterialsJSON []byte

// Open Food Facts API types
type OFFResponse struct {
	Status  int        `json:"status"`
	Product OFFProduct `json:"product"`
}

type OFFProduct struct {
	ProductName            string   `json:"product_name"`
	Brands                 string   `json:"brands"`
	PackagingTags          []string `json:"packaging_tags"`
	PackagingMaterialsTags []string `json:"packaging_materials_tags"`
	PackagingShapesTags    []string `json:"packaging_shapes_tags"`
	PackagingText          string   `json:"packaging_text"`
}

// Map bin string to BinColour enum
func mapBinColour(bin string) pb.RecyclingItem_BinColour {
	switch bin {
	case "blue":
		return pb.RecyclingItem_BLUE
	case "green":
		return pb.RecyclingItem_GREEN
	case "brown":
		return pb.RecyclingItem_BROWN
	case "black":
		return pb.RecyclingItem_BLACK
	default:
		return pb.RecyclingItem_BIN_COLOUR_UNKNOWN
	}
}

// Map bin string to BinType enum
func mapBinType(bin string) pb.RecyclingItem_BinType {
	switch bin {
	case "blue":
		return pb.RecyclingItem_PLASTIC
	case "green":
		return pb.RecyclingItem_GLASS
	case "brown":
		return pb.RecyclingItem_PAPER
	case "black":
		return pb.RecyclingItem_WASTE
	default:
		return pb.RecyclingItem_BIN_TYPE_UNKNOWN
	}
}

// RecyclingServiceServer implements the RecyclingService gRPC service
type RecyclingServiceServer struct {
	pb.UnimplementedRecyclingServiceServer
	Db models.MaterialsDB
}

// CanItBeRecycled implements the CanItBeRecycled RPC method
func (s *RecyclingServiceServer) CanItBeRecycled(ctx context.Context, req *pb.CanItBeRecycledRequest) (*pb.CanItBeRecycledResponse, error) {
	log.Printf("Received barcode: %s", req.Barcode)
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

	var off OFFResponse
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
		BinColour:  mapBinColour(m.Bin),
		BinType:    mapBinType(m.Bin),
	}

	return &pb.CanItBeRecycledResponse{
		Data: item,
	}, nil
}
