package email

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/mailgun/mailgun-go/v4"
)

type Client struct {
	mg          *mailgun.MailgunImpl
	fromAddress string
}

func NewClient(domain, apiKey, fromAddress string) *Client {
	mg := mailgun.NewMailgun(domain, apiKey)
	return &Client{
		mg:          mg,
		fromAddress: fromAddress,
	}
}

type Credentials struct {
	Email     string
	Bucket    string
	AccessKey string
	SecretKey string
}

func (c *Client) SendCredentials(ctx context.Context, creds Credentials) error {
	subject := "Your Bubbletrail sync credentials"
	body := fmt.Sprintf(`Hi!

Your storage account has been created. Here are your credentials, which
you can enter directly into Bubbletrail:

  Bucket: %s
  Access key: %s
  Secret key: %s

You also need to set a "Vault key" which is your personal password for
encrypting the synced data. Pick one and set it on each of your Bubbletrail
devices.

Best regards,
Bubbletrail automation
`, creds.Bucket, creds.AccessKey, creds.SecretKey)

	message := mailgun.NewMessage(c.fromAddress, subject, body, creds.Email)

	log := slog.With("email", creds.Email)
	_, _, err := c.mg.Send(ctx, message)
	if err != nil {
		log.Error("failed to send email", "error", err)
		return err
	}

	log.Info("sent email")

	return nil
}
