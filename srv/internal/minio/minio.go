package minio

import (
	"bytes"
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"regexp"
	"strings"
	"time"

	"github.com/minio/madmin-go/v3"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

type Client struct {
	minioClient *minio.Client
	adminClient *madmin.AdminClient
}

type MinioUserResult struct {
	BucketName string `json:"bucketName"`
	AccessKey  string `json:"accessKey"`
	SecretKey  string `json:"-"`
}

// NewClient creates a new MinIO client for managing users and buckets.
func NewClient(endpoint, accessKey, secretKey string, useSSL bool) (*Client, error) {
	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
		Secure: useSSL,
	})
	if err != nil {
		return nil, fmt.Errorf("failed to create minio client: %w", err)
	}

	adminClient, err := madmin.New(endpoint, accessKey, secretKey, useSSL)
	if err != nil {
		return nil, fmt.Errorf("failed to create admin client: %w", err)
	}

	return &Client{
		minioClient: minioClient,
		adminClient: adminClient,
	}, nil
}

var errInternal = errors.New("internal error")

func (c *Client) CreateUser(ctx context.Context, email string, quota int) (MinioUserResult, error) {
	// Calculate new bucket name, accesskey, secret key.
	bucketName := hashEmail(email)

	log := slog.With("email", email, "bucket", bucketName)

	accessKey := email
	secretKey, err := generateSecretKey()
	if err != nil {
		log.Error("failed to generate secret key", "error", err)
		return MinioUserResult{}, errInternal
	}

	// Create the new, private, bucket in the minio instance.
	err = c.minioClient.MakeBucket(ctx, bucketName, minio.MakeBucketOptions{})
	if err != nil {
		log.Error("failed to create bucket", "error", err)
		return MinioUserResult{}, errInternal
	}

	// Set bucket quota if configured.
	if quota > 0 {
		err = c.adminClient.SetBucketQuota(ctx, bucketName, &madmin.BucketQuota{
			Quota: uint64(quota),
			Type:  madmin.HardQuota,
		})
		if err != nil {
			log.Error("failed to set bucket quota", "error", err)
			// continue anyway
		}
	}

	// Create an owner object with email and creation date.
	ownerData := map[string]string{
		"email":     email,
		"createdAt": time.Now().UTC().Format(time.RFC3339),
	}
	ownerJSON, err := json.Marshal(ownerData)
	if err != nil {
		log.Error("failed to marshal owner data", "error", err)
		return MinioUserResult{}, errInternal
	}
	_, err = c.minioClient.PutObject(ctx, bucketName, "owner.json", bytes.NewReader(ownerJSON), int64(len(ownerJSON)), minio.PutObjectOptions{
		ContentType: "application/json",
	})
	if err != nil {
		log.Error("failed to create owner object", "error", err)
		return MinioUserResult{}, errInternal
	}

	// Create the accesskey/secretkey (user) in the minio instance.
	err = c.adminClient.AddUser(ctx, accessKey, secretKey)
	if err != nil {
		log.Error("failed to create user", "error", err)
		return MinioUserResult{}, errInternal
	}

	// Create and apply an access policy so the new user has readwrite on the specified bucket, and nothing else.
	policyName := fmt.Sprintf("user-%s-policy", bucketName)
	policy := createBucketPolicy(bucketName)

	policyBytes, err := json.Marshal(policy)
	if err != nil {
		log.Error("failed to marshal policy", "error", err)
		return MinioUserResult{}, errInternal
	}

	err = c.adminClient.AddCannedPolicy(ctx, policyName, policyBytes)
	if err != nil {
		log.Error("failed to create policy", "error", err)
		return MinioUserResult{}, errInternal
	}

	_, err = c.adminClient.AttachPolicy(ctx, madmin.PolicyAssociationReq{
		Policies: []string{policyName},
		User:     accessKey,
	})
	if err != nil {
		log.Error("failed to attach policy", "error", err)
		return MinioUserResult{}, errInternal
	}

	log.Info("created new account")
	return MinioUserResult{
		BucketName: bucketName,
		AccessKey:  accessKey,
		SecretKey:  secretKey,
	}, nil
}

func (c *Client) DeleteUser(ctx context.Context, email string) error {
	bucketName := hashEmail(email)
	accessKey := email
	policyName := fmt.Sprintf("user-%s-policy", bucketName)
	log := slog.With("email", email, "bucket", bucketName, "policy", policyName)
	log.Info("deleting account")
	success := true

	// Delete all objects in the bucket.
	objectsCh := c.minioClient.ListObjects(ctx, bucketName, minio.ListObjectsOptions{Recursive: true})
	for obj := range objectsCh {
		if obj.Err != nil {
			log.Error("failed to list objects", "error", obj.Err)
			return errInternal
		}
		err := c.minioClient.RemoveObject(ctx, bucketName, obj.Key, minio.RemoveObjectOptions{})
		if err != nil {
			log.Error("failed to delete object", "object", obj.Key, "error", err)
			success = false
		}
	}

	// Delete the bucket.
	err := c.minioClient.RemoveBucket(ctx, bucketName)
	if err != nil {
		log.Error("failed to delete bucket", "error", err)
		success = false
	}

	// Detach the policy from the user.
	_, err = c.adminClient.DetachPolicy(ctx, madmin.PolicyAssociationReq{
		Policies: []string{policyName},
		User:     accessKey,
	})
	if err != nil {
		log.Error("failed to detach policy", "error", err)
		success = false
	}

	// Delete the policy.
	err = c.adminClient.RemoveCannedPolicy(ctx, policyName)
	if err != nil {
		log.Error("failed to delete policy", "error", err)
		success = false
	}

	// Delete the user.
	err = c.adminClient.RemoveUser(ctx, accessKey)
	if err != nil {
		log.Error("failed to delete user", "error", err)
		success = false
	}

	if !success {
		return errInternal
	}

	return nil
}

// hashEmail creates a bucket name from the SHA256 hash of the email.
func hashEmail(email string) string {
	email = strings.ToLower(strings.TrimSpace(email))
	h := sha256.Sum256([]byte(email))
	user, _, _ := strings.Cut(email, "@")
	user = regexp.MustCompile(`[^0-9a-z]`).ReplaceAllLiteralString(user, "")
	return user + "-" + hex.EncodeToString(h[:4])
}

// generateSecretKey generates a random 32-character secret key.
func generateSecretKey() (string, error) {
	bytes := make([]byte, 12)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return hex.EncodeToString(bytes), nil
}

// createBucketPolicy creates an IAM policy that grants read-write access to a specific bucket.
func createBucketPolicy(bucketName string) map[string]any {
	return map[string]any{
		"Version": "2012-10-17",
		"Statement": []map[string]any{
			{
				"Effect": "Allow",
				"Action": []string{
					"s3:GetObject",
					"s3:PutObject",
					"s3:DeleteObject",
					"s3:ListBucket",
					"s3:GetBucketLocation",
				},
				"Resource": []string{
					fmt.Sprintf("arn:aws:s3:::%s", bucketName),
					fmt.Sprintf("arn:aws:s3:::%s/*", bucketName),
				},
			},
		},
	}
}
