// Package rgw manages storage accounts on a Ceph object gateway (RadosGW).
// Users and quotas are handled through the RGW admin ops API, buckets and
// objects through plain S3 calls.
package rgw

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base32"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"regexp"
	"slices"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/s3/types"
	"github.com/ceph/go-ceph/rgw/admin"
)

const (
	// Purging a bucket can take a while, so we need considerably more than
	// go-ceph's three second default.
	adminTimeout = 2 * time.Minute

	// Freshly created credentials are not necessarily usable on the gateway
	// straight away, so the first S3 call using them is retried.
	credentialAttempts   = 6
	credentialRetryDelay = 500 * time.Millisecond
)

type Client struct {
	admin    *admin.API
	endpoint string
	region   string
}

type UserResult struct {
	BucketName string `json:"bucketName"`
	AccessKey  string `json:"accessKey"`
	SecretKey  string `json:"-"`
}

// NewClient creates a new client for managing users and buckets on a Ceph
// object gateway. The endpoint is the gateway base URL, and the credentials
// must belong to a user holding the "users" and "buckets" admin capabilities.
func NewClient(endpoint, accessKey, secretKey, region string) (*Client, error) {
	endpoint = strings.TrimSuffix(endpoint, "/")

	adminClient, err := admin.New(endpoint, accessKey, secretKey, &http.Client{Timeout: adminTimeout})
	if err != nil {
		return nil, fmt.Errorf("failed to create rgw admin client: %w", err)
	}

	return &Client{
		admin:    adminClient,
		endpoint: endpoint,
		region:   region,
	}, nil
}

var errInternal = errors.New("internal error")

func (c *Client) CreateUser(ctx context.Context, email string, quota int) (UserResult, error) {
	// Calculate new bucket name, accesskey, secret key.
	bucketName := hashEmail(email)

	log := slog.With("email", email, "bucket", bucketName)

	accessKey := email
	secretKey := generateSecretKey()

	// Create the gateway user. Unlike with MinIO there is no separate policy
	// to attach: the user owns their own bucket, and limiting them to a single
	// bucket is what keeps them out of everything else.
	if _, err := c.admin.CreateUser(ctx, admin.User{
		ID:          bucketName,
		DisplayName: "Bubbletrail user",
		Email:       email,
		MaxBuckets:  new(1),
		Keys: []admin.UserKeySpec{{
			AccessKey: accessKey,
			SecretKey: secretKey,
		}},
	}); err != nil {
		log.ErrorContext(ctx, "failed to create user", "error", err)
		return UserResult{}, errInternal
	}

	// Create the bucket as the new user, so that they end up owning it.
	s3Client := c.s3Client(accessKey, secretKey)
	if err := createBucket(ctx, s3Client, bucketName); err != nil {
		log.ErrorContext(ctx, "failed to create bucket", "error", err)
		return UserResult{}, errInternal
	}

	// Set quota if configured. The user owns a single bucket, so a user quota
	// bounds that bucket.
	if quota > 0 {
		if err := c.admin.SetUserQuota(ctx, admin.QuotaSpec{
			UID:     bucketName,
			Enabled: new(true),
			MaxSize: new(int64(quota)),
		}); err != nil {
			log.ErrorContext(ctx, "failed to set user quota", "error", err)
			// continue anyway
		}
	}

	log.InfoContext(ctx, "created new account")
	return UserResult{
		BucketName: bucketName,
		AccessKey:  accessKey,
		SecretKey:  secretKey,
	}, nil
}

func (c *Client) DeleteUser(ctx context.Context, email string) error {
	bucketName := hashEmail(email)
	log := slog.With("email", email, "bucket", bucketName)
	log.InfoContext(ctx, "deleting account")
	success := true

	// Delete the bucket along with everything in it.
	purgeObjects := true
	if err := c.admin.RemoveBucket(ctx, admin.Bucket{
		Bucket:      bucketName,
		PurgeObject: &purgeObjects,
	}); err != nil && !errors.Is(err, admin.ErrNoSuchBucket) {
		log.ErrorContext(ctx, "failed to delete bucket", "error", err)
		success = false
	}

	// Delete the user, purging any remaining data they own.
	purgeData := 1
	if err := c.admin.RemoveUser(ctx, admin.User{
		ID:        email,
		PurgeData: &purgeData,
	}); err != nil && !errors.Is(err, admin.ErrNoSuchUser) {
		log.ErrorContext(ctx, "failed to delete user", "error", err)
		success = false
	}

	if !success {
		return errInternal
	}

	return nil
}

// s3Client returns an S3 client for the gateway using the given credentials.
// Path style addressing avoids requiring wildcard DNS for the gateway, and
// checksums are only sent when the API requires them as older gateways choke
// on the trailing checksums the SDK otherwise adds.
func (c *Client) s3Client(accessKey, secretKey string) *s3.Client {
	return s3.New(s3.Options{
		BaseEndpoint:               aws.String(c.endpoint),
		Region:                     c.region,
		Credentials:                credentials.NewStaticCredentialsProvider(accessKey, secretKey, ""),
		UsePathStyle:               true,
		RequestChecksumCalculation: aws.RequestChecksumCalculationWhenRequired,
	})
}

// createBucket creates the bucket, retrying while the gateway still rejects
// the newly created credentials.
func createBucket(ctx context.Context, client *s3.Client, bucketName string) error {
	var err error
	for attempt := range credentialAttempts {
		if attempt > 0 {
			select {
			case <-ctx.Done():
				return ctx.Err()
			case <-time.After(credentialRetryDelay):
			}
		}

		_, err = client.CreateBucket(ctx, &s3.CreateBucketInput{Bucket: aws.String(bucketName)})
		if err == nil {
			return nil
		}

		var owned *types.BucketAlreadyOwnedByYou
		if errors.As(err, &owned) {
			return nil
		}

		var taken *types.BucketAlreadyExists
		if errors.As(err, &taken) {
			return err
		}
	}
	return err
}

// hashEmail creates a bucket name from the SHA256 hash of the email.
func hashEmail(email string) string {
	email = strings.ToLower(strings.TrimSpace(email))
	h := sha256.Sum256([]byte(email))
	user, _, _ := strings.Cut(email, "@")
	user = regexp.MustCompile(`[^0-9a-z]`).ReplaceAllLiteralString(user, "")
	return user + "-" + strings.ToLower(dashedString(base32.HexEncoding.WithPadding(base32.NoPadding).EncodeToString(h[:])[:8], 4))
}

// generateSecretKey generates a random 18-character (~90 bits) secret key.
func generateSecretKey() string {
	bytes := make([]byte, 12)
	rand.Read(bytes) //nolint:errcheck
	rnd := base32.HexEncoding.WithPadding(base32.NoPadding).EncodeToString(bytes)
	return dashedString(rnd[:18], 6)
}

func dashedString(s string, intv int) string {
	runes := []rune(s)
	var parts []string
	for chunk := range slices.Chunk(runes, intv) {
		parts = append(parts, string(chunk))
	}
	return strings.Join(parts, "-")
}
