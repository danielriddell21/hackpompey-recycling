package service

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"recycling-service/internal/mappers"
	"recycling-service/internal/models"
	pb "recycling-service/proto"

	"os"
	"strings"
)

// CanItBeRecycledImage implements the CanItBeRecycledImage RPC method
func (s *RecyclingServiceServer) CanItBeRecycledImage(ctx context.Context, req *pb.CanItBeRecycledImageRequest) (*pb.CanItBeRecycledImageResponse, error) {
	log.Printf("Received image for analysis, size: %d bytes", len(req.Image))

	// Encode image to base64
	imageBase64 := base64.StdEncoding.EncodeToString(req.Image)

	// Prepare Claude request
	claudeReq := models.ClaudeRequest{
		Model:     "claude-sonnet-4-6",
		MaxTokens: 1000,
		Messages: []models.ClaudeMessage{
			{
				Role: "user",
				Content: []models.ClaudeContent{
					{
						Type: "text",
						Text: "Identify the object in this image and return only a JSON object with a single field: 'item' (string describing the material or item type, e.g., 'aluminum can', 'plastic bottle'). Do not include any other text.",
					},
					{
						Type: "image",
						Source: &models.ClaudeSource{
							Type:      "base64",
							MediaType: "image/jpeg", // Assume JPEG, adjust if needed
							Data:      imageBase64,
						},
					},
				},
			},
		},
	}

	// Serialize to JSON
	reqBody, err := json.Marshal(claudeReq)
	if err != nil {
		return &pb.CanItBeRecycledImageResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "Failed to process image.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}

	// Get API key
	apiKey := os.Getenv("ANTHROPIC_API_KEY")
	if apiKey == "" {
		return &pb.CanItBeRecycledImageResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "API key not configured.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}

	// Make HTTP request to Claude
	httpReq, err := http.NewRequest("POST", "https://api.anthropic.com/v1/messages", strings.NewReader(string(reqBody)))
	if err != nil {
		return &pb.CanItBeRecycledImageResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "Failed to create request.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("x-api-key", apiKey)
	httpReq.Header.Set("anthropic-version", "2023-06-01")

	client := &http.Client{}
	resp, err := client.Do(httpReq)
	if err != nil {
		return &pb.CanItBeRecycledImageResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "Failed to call Claude API.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return &pb.CanItBeRecycledImageResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     fmt.Sprintf("Claude API error: %d", resp.StatusCode),
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}

	// Parse response
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return &pb.CanItBeRecycledImageResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "Failed to read response.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}

	var claudeResp models.ClaudeResponse
	if err := json.Unmarshal(body, &claudeResp); err != nil {
		return &pb.CanItBeRecycledImageResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "Failed to parse response.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}

	// Extract text from response
	var description string
	for _, content := range claudeResp.Content {
		if content.Type == "text" {
			description = content.Text
			break
		}
	}

	log.Printf("Claude response: %s", description)

	// Parse JSON response
	type ClaudeAnalysis struct {
		Item string `json:"item"`
	}

	var analysis ClaudeAnalysis
	if err := json.Unmarshal([]byte(strings.TrimSpace(description)), &analysis); err != nil {
		// Fallback
		return &pb.CanItBeRecycledImageResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "Failed to identify item from image.",
				BinColour:  pb.RecyclingItem_BIN_COLOUR_UNKNOWN,
				BinType:    pb.RecyclingItem_BIN_TYPE_UNKNOWN,
			},
		}, nil
	}

	// Use the identified item to lookup materials
	matched := s.Db.LookupMaterials([]string{analysis.Item})

	if len(matched) == 0 {
		return &pb.CanItBeRecycledImageResponse{
			Data: &pb.RecyclingItem{
				Recyclable: false,
				Advice:     "No recycling information found for the identified item.",
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

	return &pb.CanItBeRecycledImageResponse{
		Data: item,
	}, nil
}
