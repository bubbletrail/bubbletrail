package main

import (
	"embed"
	"encoding/json"
	"io/fs"
	"log/slog"
	"net/http"
	"os"
	"strings"

	"github.com/alecthomas/kong"

	"bubbletrail.net/srv/internal/email"
	"bubbletrail.net/srv/internal/rgw"
)

//go:embed static
var staticFiles embed.FS

var cli struct {
	Endpoint       string `help:"Ceph object gateway base URL" env:"RGW_ENDPOINT" required:""`
	AccessKey      string `help:"Gateway admin access key" env:"RGW_ACCESS_KEY" required:""`
	SecretKey      string `help:"Gateway admin secret key" env:"RGW_SECRET_KEY" required:""`
	Region         string `help:"Region used for request signing" env:"RGW_REGION" default:"us-east-1"`
	BucketQuotaMiB int    `help:"Bucket quota in MiB (0 to disable)" env:"RGW_BUCKET_QUOTA_MiB" default:"256"`
	AdminToken     string `help:"Bearer token for admin API endpoints" env:"ADMIN_TOKEN" required:""`
	MailgunDomain  string `help:"Mailgun domain" env:"MAILGUN_DOMAIN" required:""`
	MailgunAPIKey  string `help:"Mailgun API key" env:"MAILGUN_API_KEY" required:""`
	MailgunFrom    string `help:"Email from address" env:"MAILGUN_FROM" required:""`
}

type newUserRequest struct {
	Email string `json:"email"`
}

func main() {
	kong.Parse(&cli)

	storageClient, err := rgw.NewClient(cli.Endpoint, cli.AccessKey, cli.SecretKey, cli.Region)
	if err != nil {
		slog.Error("failed to create storage client", "error", err)
		os.Exit(1)
	}

	emailClient := email.NewClient(cli.MailgunDomain, cli.MailgunAPIKey, cli.MailgunFrom)

	srv := server{storage: storageClient, email: emailClient, quotaMiB: cli.BucketQuotaMiB}
	http.HandleFunc("POST /account/new", srv.newAccount)
	http.HandleFunc("DELETE /account/{email}", srv.deleteAccount)

	// Serve embedded static files
	staticFS, err := fs.Sub(staticFiles, "static")
	if err != nil {
		slog.Error("failed to create static file system", "error", err)
		os.Exit(1)
	}
	http.Handle("/", http.FileServer(http.FS(staticFS)))

	slog.Info("starting server", "address", ":8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		slog.Error("failed to listen", "error", err)
		os.Exit(1)
	}
}

type server struct {
	storage  *rgw.Client
	email    *email.Client
	quotaMiB int
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

	result, err := s.storage.CreateUser(r.Context(), req.Email, s.quotaMiB<<20)
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
		slog.Error("failed to send credentials email", "error", err)
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

	err := s.storage.DeleteUser(r.Context(), email)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusNoContent)
}
