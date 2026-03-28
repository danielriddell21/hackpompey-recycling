package models

import "strings"

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

func (db MaterialsDB) LookupMaterials(offTags []string) []Material {
	seen := map[string]bool{}
	var results []Material
	for _, raw := range offTags {
		key, ok := offTagToMaterial[db.NormaliseTag(raw)]
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

func (db MaterialsDB) NormaliseTag(raw string) string {
	tag := raw
	for _, prefix := range []string{"en:", "fr:", "de:", "es:"} {
		tag = strings.TrimPrefix(tag, prefix)
	}
	return strings.ToLower(strings.TrimSpace(tag))
}
