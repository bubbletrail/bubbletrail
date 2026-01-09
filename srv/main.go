package main

import (
	"embed"
	"encoding/json"
	"io/fs"
	"log"
	"net/http"
	"strings"

	"github.com/alecthomas/kong"

	"bubbletrail.net/srv/internal/email"
	"bubbletrail.net/srv/internal/minio"
)

//go:embed static
var staticFiles embed.FS

var cli struct {
	Endpoint      string `help:"MinIO endpoint" env:"MINIO_ENDPOINT" required:""`
	AccessKey     string `help:"MinIO admin access key" env:"MINIO_ACCESS_KEY" required:""`
	SecretKey     string `help:"MinIO admin secret key" env:"MINIO_SECRET_KEY" required:""`
	UseSSL        bool   `help:"Use SSL for MinIO connection" env:"MINIO_USE_SSL" default:"true"`
	AdminToken    string `help:"Bearer token for admin API endpoints" env:"ADMIN_TOKEN" required:""`
	MailgunDomain string `help:"Mailgun domain" env:"MAILGUN_DOMAIN" required:""`
	MailgunAPIKey string `help:"Mailgun API key" env:"MAILGUN_API_KEY" required:""`
	MailgunFrom   string `help:"Email from address" env:"MAILGUN_FROM" required:""`
}

type newUserRequest struct {
	Email string `json:"email"`
}

func main() {
	kong.Parse(&cli)

	minioClient, err := minio.NewClient(cli.Endpoint, cli.AccessKey, cli.SecretKey, cli.UseSSL)
	if err != nil {
		log.Fatalf("failed to create minio client: %v", err)
	}

	emailClient := email.NewClient(cli.MailgunDomain, cli.MailgunAPIKey, cli.MailgunFrom)

	srv := server{minio: minioClient, email: emailClient}
	http.HandleFunc("POST /account/new", srv.newAccount)
	http.HandleFunc("DELETE /account/{email}", srv.deleteAccount)

	// Serve embedded static files
	staticFS, err := fs.Sub(staticFiles, "static")
	if err != nil {
		log.Fatalf("failed to create static file system: %v", err)
	}
	http.Handle("/", http.FileServer(http.FS(staticFS)))

	log.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

type server struct {
	minio *minio.Client
	email *email.Client
}

func (s *server) newAccount(w http.ResponseWriter, r *http.Request) {
	var req newUserRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	if req.Email == "" {
		http.Error(w, "email is required", http.StatusBadRequest)
		return
	}

	result, err := s.minio.CreateUser(r.Context(), req.Email)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	err = s.email.SendCredentials(r.Context(), email.Credentials{
		Email:     req.Email,
		Bucket:    result.BucketName,
		AccessKey: result.AccessKey,
		SecretKey: result.SecretKey,
	})
	if err != nil {
		log.Printf("failed to send credentials email: %v", err)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

func (s *server) deleteAccount(w http.ResponseWriter, r *http.Request) {
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

	err := s.minio.DeleteUser(r.Context(), email)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
