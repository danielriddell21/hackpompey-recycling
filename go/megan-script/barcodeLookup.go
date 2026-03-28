package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"
	_ "embed"
)

type Material struct {
	Label      string   `json:"label"`
	Examples   []string `json:"examples"`
	Recyclable string   `json:"recyclable"`
	Bin        string   `json:"bin"`
	Tips       string   `json:"tips"`
}

type Bin struct {
	Label       string `json:"label"`
	Description string `json:"description"`
	Collection  string `json:"collection,omitempty"`
	URL         string `json:"url,omitempty"`
}

type MaterialsDB struct {
	Materials map[string]Material `json:"materials"`
	Bins      map[string]Bin      `json:"bins"`
}

//go:embed rules/materials.json
var materialsJSON []byte

// ── Open Food Facts API types ──────────────────────────────────────────────

type OFFResponse struct {
	Status  int        `json:"status"`
	Product OFFProduct `json:"product"`
}

type OFFProduct struct {
	ProductName          string   `json:"product_name"`
	Brands               string   `json:"brands"`
	PackagingTags        []string `json:"packaging_tags"`
	PackagingMaterialsTags []string `json:"packaging_materials_tags"`
	PackagingShapesTags  []string `json:"packaging_shapes_tags"`
	PackagingText        string   `json:"packaging_text"`
}

// ── Tag → material key mapping ─────────────────────────────────────────────

var offTagToMaterial = map[string]string{
	// Plastic bottles
	"plastic-bottle":       "plastic_bottle",
	"pet-bottle":           "plastic_bottle",
	"hdpe-bottle":          "plastic_bottle",
	"bottle":               "plastic_bottle", // generic fallback
	// Plastic tubs/trays
	"plastic-tray":         "plastic_tub",
	"plastic-pot":          "plastic_tub",
	"plastic-tub":          "plastic_tub",
	"tray":                 "plastic_tub",
	"pot":                  "plastic_tub",
	// Black plastic
	"black-plastic":        "plastic_black",
	// Bags & film
	"plastic-bag":          "plastic_bag",
	"film":                 "plastic_bag",
	"flexible-plastic":     "plastic_bag",
	"bag":                  "plastic_bag",
	// Polystyrene
	"polystyrene":          "polystyrene",
	"expanded-polystyrene": "polystyrene",
	"foam":                 "polystyrene",
	// Glass
	"glass-bottle":         "glass_bottle",
	"glass-jar":            "glass_bottle",
	"jar":                  "glass_bottle",
	// Cans
	"tin":                  "tin_can",
	"steel-can":            "tin_can",
	"aluminium-can":        "tin_can",
	"can":                  "tin_can",
	"metal-can":            "tin_can",
	// Foil
	"aluminium-foil":       "foil",
	"foil-tray":            "foil",
	"foil":                 "foil",
	// Paper & cardboard
	"cardboard":            "cardboard",
	"cardboard-box":        "cardboard",
	"paper-box":            "cardboard",
	"paper":                "paper",
	"paper-bag":            "paper",
	// Cartons
	"tetra-pak":            "tetra_pak",
	"carton":               "tetra_pak",
	"beverage-carton":      "tetra_pak",
	// Aerosol
	"aerosol":              "aerosol",
	// Crisp packets / wrappers
	"crisp-packet":         "crisp_packet",
	"snack-wrapper":        "crisp_packet",
	"wrapper":              "crisp_packet",
}

func normaliseTag(raw string) string {
	tag := raw
	for _, prefix := range []string{"en:", "fr:", "de:", "es:"} {
		tag = strings.TrimPrefix(tag, prefix)
	}
	return strings.ToLower(strings.TrimSpace(tag))
}

func lookupMaterials(db MaterialsDB, offTags []string) []Material {
	seen := map[string]bool{}
	var results []Material
	for _, raw := range offTags {
		key, ok := offTagToMaterial[normaliseTag(raw)]
		if !ok || seen[key] {
			continue
		}
		if m, found := db.Materials[key]; found {
			results = append(results, m)
			seen[key] = true
		}
	}
	return results
}

// ── Bin display helper ─────────────────────────────────────────────────────

func binIcon(bin string) string {
	switch bin {
	case "blue":
		return "🔵"
	case "black":
		return "⚫"
	case "recycling_centre":
		return "♻️ "
	default:
		return "❓"
	}
}

// ── Main ───────────────────────────────────────────────────────────────────

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "Usage: go run barcode_lookup.go <barcode>")
		fmt.Fprintln(os.Stderr, "Example: go run barcode_lookup.go 3017620422003")
		os.Exit(1)
	}
	barcode := strings.TrimSpace(os.Args[1])

	// Load materials DB
	var db MaterialsDB
	if err := json.Unmarshal(materialsJSON, &db); err != nil {
		fmt.Fprintf(os.Stderr, "failed to parse materials: %v\n", err)
		os.Exit(1)
	}

	// Fetch from Open Food Facts
	url := fmt.Sprintf(
		"https://world.openfoodfacts.org/api/v2/product/%s?fields=product_name,brands,packaging_tags,packaging_materials_tags,packaging_shapes_tags,packaging_text",
		barcode,
	)
	fmt.Printf("Fetching: %s\n\n", url)

	resp, err := http.Get(url)
	if err != nil {
		fmt.Fprintf(os.Stderr, "HTTP error: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	var off OFFResponse
	if err := json.NewDecoder(resp.Body).Decode(&off); err != nil {
		fmt.Fprintf(os.Stderr, "JSON decode error: %v\n", err)
		os.Exit(1)
	}

	if off.Status == 0 {
		fmt.Printf("❌ Product not found for barcode: %s\n", barcode)
		os.Exit(1)
	}

	p := off.Product

	// Print product info
	fmt.Printf("════════════════════════════════════════\n")
	fmt.Printf("Product : %s\n", p.ProductName)
	if p.Brands != "" {
		fmt.Printf("Brand   : %s\n", p.Brands)
	}
	fmt.Printf("════════════════════════════════════════\n\n")

	// Print raw tags
	allTags := append(p.PackagingTags, p.PackagingMaterialsTags...)
	allTags = append(allTags, p.PackagingShapesTags...)
	if len(allTags) > 0 {
		fmt.Println("Raw packaging tags:")
		for _, t := range allTags {
			fmt.Printf("  • %s\n", t)
		}
		fmt.Println()
	}

	if p.PackagingText != "" {
		fmt.Printf("Packaging label: %s\n\n", p.PackagingText)
	}

	// Map to materials
	matched := lookupMaterials(db, allTags)

	fmt.Println("────────────────────────────────────────")
	fmt.Println("Portsmouth recycling guidance:")
	fmt.Println("────────────────────────────────────────")

	if len(matched) == 0 {
		fmt.Println("⚠️  No packaging materials could be matched.")
		fmt.Println("   The product may have incomplete data on Open Food Facts.")
		fmt.Printf("\nRaw tags for manual lookup: %s\n", strings.Join(allTags, ", "))
	} else {
		for _, m := range matched {
			bin := db.Bins[m.Bin]
			fmt.Printf("\n%s %s  →  %s\n", binIcon(m.Bin), m.Label, bin.Label)
			fmt.Printf("   Recyclable : %s\n", m.Recyclable)
			fmt.Printf("   Tip        : %s\n", m.Tips)
			if bin.Collection != "" {
				fmt.Printf("   Collection : %s\n", bin.Collection)
			}
		}
	}

	fmt.Println()
}