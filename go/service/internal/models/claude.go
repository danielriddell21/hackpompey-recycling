package models

// Claude API types
type ClaudeMessage struct {
	Role    string          `json:"role"`
	Content []ClaudeContent `json:"content"`
}

type ClaudeContent struct {
	Type   string        `json:"type"`
	Text   string        `json:"text,omitempty"`
	Source *ClaudeSource `json:"source,omitempty"`
}

type ClaudeSource struct {
	Type      string `json:"type"`
	MediaType string `json:"media_type"`
	Data      string `json:"data"`
}

type ClaudeRequest struct {
	Model     string          `json:"model"`
	MaxTokens int             `json:"max_tokens"`
	Messages  []ClaudeMessage `json:"messages"`
}

type ClaudeResponse struct {
	Content []ClaudeContent `json:"content"`
}
