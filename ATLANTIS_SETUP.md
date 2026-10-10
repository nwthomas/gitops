# Atlantis Setup Guide

This guide will help you set up Atlantis for your GitOps repository to enable Terraform and Helm automation via GitHub comments.

## Prerequisites

1. **GitHub Personal Access Token** or **GitHub App**
2. **Domain name** for Atlantis (or use port-forwarding for testing)
3. **Kubernetes cluster** with ArgoCD running

## Setup Steps

### 1. Create GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name like "Atlantis GitOps"
4. Select scopes:
   - `repo` (Full control of private repositories)
   - `write:discussion` (Write team discussions)
   - `admin:org` (if using organization webhooks)
5. Copy the token (you won't see it again!)

### 2. Create GitHub App (Alternative to Personal Access Token)

If you prefer using a GitHub App:

1. Go to GitHub Settings → Developer settings → GitHub Apps
2. Click "New GitHub App"
3. Fill in:
   - **GitHub App name**: `atlantis-gitops`
   - **Homepage URL**: `https://atlantis.yourdomain.com`
   - **Webhook URL**: `https://atlantis.yourdomain.com/events`
   - **Webhook secret**: Generate a random string
4. Select permissions:
   - **Repository permissions**:
     - Contents: Read
     - Issues: Write
     - Pull requests: Write
     - Metadata: Read
   - **Subscribe to events**:
     - Pull request
     - Issue comment
     - Pull request review
5. Download the private key

### 3. Update Atlantis Configuration

Edit `helm/atlantis/values.yaml`:

```yaml
atlantis:
  env:
    # Update these values
    ATLANTIS_REPO_ALLOWLIST: "github.com/nwthomas/gitops"  # Your repo
    ATLANTIS_ATLANTIS_URL: "https://atlantis.yourdomain.com"  # Your domain
    GITHUB_USER: "nwthomas"  # Your GitHub username
    
    # If using GitHub App, uncomment and set:
    # GITHUB_APP_ID: "123456"  # Your GitHub App ID
```

### 4. Create Kubernetes Secret

Create the secret with your GitHub token:

```bash
# For Personal Access Token
kubectl create secret generic atlantis-secrets \
  --from-literal=github-token="YOUR_GITHUB_TOKEN" \
  -n atlantis

# For GitHub App (also include the private key)
kubectl create secret generic atlantis-secrets \
  --from-literal=github-token="YOUR_GITHUB_TOKEN" \
  --from-file=github-app-key=path/to/your/private-key.pem \
  -n atlantis
```

### 5. Set Up GitHub Webhook

1. Go to your repository settings → Webhooks
2. Click "Add webhook"
3. Fill in:
   - **Payload URL**: `https://atlantis.yourdomain.com/events`
   - **Content type**: `application/json`
   - **Secret**: (if using GitHub App, use the webhook secret)
   - **Events**: Select "Let me select individual events"
     - Pull requests
     - Issue comments
     - Pull request reviews
4. Click "Add webhook"

### 6. Deploy Atlantis

1. Commit and push your changes to the repository
2. ArgoCD will automatically deploy Atlantis
3. Check the deployment:

```bash
kubectl get pods -n atlantis
kubectl get svc -n atlantis
kubectl get ingress -n atlantis
```

### 7. Test the Setup

1. Create a test pull request that modifies files in the `/helm` directory
2. Comment on the PR: `atlantis plan`
3. Atlantis should respond with a plan
4. If the plan looks good, comment: `atlantis apply`
5. Atlantis will apply the changes

## Usage

### Available Commands

- `atlantis plan` - Run terraform plan
- `atlantis apply` - Apply terraform changes
- `atlantis plan -p <project>` - Plan specific project
- `atlantis apply -p <project>` - Apply specific project
- `atlantis unlock` - Unlock a locked workspace
- `atlantis help` - Show help

### Project Structure

Atlantis monitors these directories:
- `/helm/*` - Helm charts
- `/terraform` - Terraform configurations
- `/argocd/apps/*` - ArgoCD applications

### Security Features

- **User Restriction**: Only `nwthomas` can run Atlantis commands
- **Approval Required**: All changes require PR approval
- **Mergeable Required**: PR must be mergeable before applying
- **Repository Allowlist**: Only your specific repository is allowed

## Troubleshooting

### Check Atlantis Logs

```bash
kubectl logs -f deployment/atlantis -n atlantis
```

### Verify Webhook Delivery

1. Go to your repository → Settings → Webhooks
2. Click on your webhook
3. Check "Recent Deliveries" for any failed deliveries

### Common Issues

1. **Webhook not working**: Check the webhook URL and secret
2. **Permission denied**: Verify GitHub token has correct permissions
3. **Atlantis not responding**: Check logs and ensure the service is running
4. **Terraform errors**: Check the terraform configuration and state

### Port Forwarding for Testing

If you don't have a domain set up yet:

```bash
kubectl port-forward svc/atlantis 4141:4141 -n atlantis
```

Then use `http://localhost:4141` as your webhook URL temporarily.

## Security Considerations

1. **GitHub Token**: Store securely and rotate regularly
2. **Webhook Secret**: Use a strong, random secret
3. **RBAC**: Atlantis has minimal required permissions
4. **Network**: Use HTTPS for webhook URLs
5. **Monitoring**: Monitor Atlantis logs for suspicious activity

## Next Steps

1. Set up monitoring for Atlantis
2. Configure backup for Atlantis data
3. Set up alerting for failed plans/applies
4. Consider setting up Atlantis for multiple repositories
