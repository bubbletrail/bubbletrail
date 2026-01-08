package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strings"

	"github.com/alecthomas/kong"

	"bubbletrail.net/srv/internal/minio"
)

var cli struct {
	Endpoint   string `help:"MinIO endpoint" env:"MINIO_ENDPOINT" required:""`
	AccessKey  string `help:"MinIO admin access key" env:"MINIO_ACCESS_KEY" required:""`
	SecretKey  string `help:"MinIO admin secret key" env:"MINIO_SECRET_KEY" required:""`
	UseSSL     bool   `help:"Use SSL for MinIO connection" env:"MINIO_USE_SSL" default:"true"`
	AdminToken string `help:"Bearer token for admin API endpoints" env:"ADMIN_TOKEN" required:""`
}

type newUserRequest struct {
	Email string `json:"email"`
}

func main() {
	kong.Parse(&cli)

	client, err := minio.NewClient(cli.Endpoint, cli.AccessKey, cli.SecretKey, cli.UseSSL)
	if err != nil {
		log.Fatalf("failed to create minio client: %v", err)
	}

	http.HandleFunc("POST /new", func(w http.ResponseWriter, r *http.Request) {
		var req newUserRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, "invalid request body", http.StatusBadRequest)
			return
		}

		if req.Email == "" {
			http.Error(w, "email is required", http.StatusBadRequest)
			return
		}

		result, err := client.CreateUser(r.Context(), req.Email)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(result)
	})

	http.HandleFunc("DELETE /{email}", func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if !strings.HasPrefix(authHeader, "Bearer ") || authHeader[7:] != cli.AdminToken {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}

		email := r.PathValue("email")
		if email == "" {
			http.Error(w, "email is required", http.StatusBadRequest)
			return
		}

		err := client.DeleteUser(r.Context(), email)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.WriteHeader(http.StatusNoContent)
	})

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
