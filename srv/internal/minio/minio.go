package minio

import (
	"bytes"
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
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
	SecretKey  string `json:"secretKey"`
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

func (c *Client) CreateUser(ctx context.Context, email string) (MinioUserResult, error) {
	// Calculate new bucket name, accesskey, secret key.
	bucketName := hashEmail(email)
	accessKey := email
	secretKey, err := generateSecretKey()
	if err != nil {
		return MinioUserResult{}, fmt.Errorf("failed to generate secret key: %w", err)
	}

	// Create the new, private, bucket in the minio instance.
	err = c.minioClient.MakeBucket(ctx, bucketName, minio.MakeBucketOptions{})
	if err != nil {
		return MinioUserResult{}, fmt.Errorf("failed to create bucket: %w", err)
	}

	// Create an owner object with email and creation date.
	ownerData := map[string]string{
		"email":     email,
		"createdAt": time.Now().UTC().Format(time.RFC3339),
	}
	ownerJSON, err := json.Marshal(ownerData)
	if err != nil {
		return MinioUserResult{}, fmt.Errorf("failed to marshal owner data: %w", err)
	}
	_, err = c.minioClient.PutObject(ctx, bucketName, "owner.json", bytes.NewReader(ownerJSON), int64(len(ownerJSON)), minio.PutObjectOptions{
		ContentType: "application/json",
	})
	if err != nil {
		return MinioUserResult{}, fmt.Errorf("failed to create owner object: %w", err)
	}

	// Create the accesskey/secretkey (user) in the minio instance.
	err = c.adminClient.AddUser(ctx, accessKey, secretKey)
	if err != nil {
		return MinioUserResult{}, fmt.Errorf("failed to create user: %w", err)
	}

	// Create and apply an access policy so the new user has readwrite on the specified bucket, and nothing else.
	policyName := fmt.Sprintf("user-%s-policy", bucketName)
	policy := createBucketPolicy(bucketName)

	policyBytes, err := json.Marshal(policy)
	if err != nil {
		return MinioUserResult{}, fmt.Errorf("failed to marshal policy: %w", err)
	}

	err = c.adminClient.AddCannedPolicy(ctx, policyName, policyBytes)
	if err != nil {
		return MinioUserResult{}, fmt.Errorf("failed to create policy: %w", err)
	}

	_, err = c.adminClient.AttachPolicy(ctx, madmin.PolicyAssociationReq{
		Policies: []string{policyName},
		User:     accessKey,
	})
	if err != nil {
		return MinioUserResult{}, fmt.Errorf("failed to attach policy to user: %w", err)
	}

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

	// Delete all objects in the bucket.
	objectsCh := c.minioClient.ListObjects(ctx, bucketName, minio.ListObjectsOptions{Recursive: true})
	for obj := range objectsCh {
		if obj.Err != nil {
			return fmt.Errorf("failed to list objects: %w", obj.Err)
		}
		err := c.minioClient.RemoveObject(ctx, bucketName, obj.Key, minio.RemoveObjectOptions{})
		if err != nil {
			return fmt.Errorf("failed to delete object %s: %w", obj.Key, err)
		}
	}

	// Delete the bucket.
	err := c.minioClient.RemoveBucket(ctx, bucketName)
	if err != nil {
		return fmt.Errorf("failed to delete bucket: %w", err)
	}

	// Detach the policy from the user.
	_, err = c.adminClient.DetachPolicy(ctx, madmin.PolicyAssociationReq{
		Policies: []string{policyName},
		User:     accessKey,
	})
	if err != nil {
		return fmt.Errorf("failed to detach policy: %w", err)
	}

	// Delete the policy.
	err = c.adminClient.RemoveCannedPolicy(ctx, policyName)
	if err != nil {
		return fmt.Errorf("failed to delete policy: %w", err)
	}

	// Delete the user.
	err = c.adminClient.RemoveUser(ctx, accessKey)
	if err != nil {
		return fmt.Errorf("failed to delete user: %w", err)
	}

	return nil
}

// hashEmail creates a bucket name from the SHA256 hash of the email.
func hashEmail(email string) string {
	email = strings.ToLower(strings.TrimSpace(email))
	h := sha256.Sum256([]byte(email))
	prefix := regexp.MustCompile(`[^0-9a-z]`).ReplaceAllLiteralString(email, "")
	return prefix + "-" + hex.EncodeToString(h[:8])
}

// generateSecretKey generates a random 32-character secret key.
func generateSecretKey() (string, error) {
	bytes := make([]byte, 16)
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
