# OIDC VPN Manager Production Deployment

This directory contains the production deployment configuration for OIDC VPN Manager using Docker Compose with PostgreSQL databases and proper security configurations.

## 📦 Service Configuration

This deployment uses the **Combined/Unsplit Frontend Service** which provides:
- User interface for certificate generation and management
- Administrative interface for PSK and certificate management
- API endpoints for both user and server operations
- All functionality in a single service instance

## 🏗️ Architecture

The production deployment includes:

- **Frontend Service**: User-facing web application with OpenVPN profile generation
- **Signing Service**: Certificate signing service (isolated from frontend)
- **Certificate Transparency Service**: Audit log for all issued certificates
- **PostgreSQL Databases**: Separate databases for each service
- **Nginx Reverse Proxy**: SSL termination and load balancing

## 🔧 Prerequisites

- Docker and Docker Compose
- OpenSSL (for secret generation)
- Valid SSL certificates for your domain
- OIDC provider configuration
- PKI materials (CA certificates and keys)

## 🚀 Quick Start

1. **Generate secrets**:
   ```bash
   ./generate-secrets.sh
   ```

2. **Configure environment**:
   - Update `.env.*` files with your actual values
   - Replace `your-oidc-provider.com` and `vpn.yourdomain.com`
   - Update OIDC client ID and other provider-specific settings

3. **Prepare PKI materials**:
   ```bash
   mkdir -p pki ssl
   # Copy your CA certificates to pki/
   # Copy SSL certificates to ssl/
   ```

4. **Configuration files included**:
   The following configuration files are already included:
   - `openvpn_templates/` - OpenVPN client configuration templates
   - `server_templates/` - OpenVPN server configuration templates  
   - `openvpn_options.yaml` - Client configuration options
   - `pki/` - Sample PKI certificates (replace with your own)

5. **Deploy**:
   ```bash
   docker-compose up -d
   ```

## 📁 Directory Structure

```
deploy/docker/
├── docker-compose.yml          # Main deployment configuration
├── .env.frontend              # Frontend service environment
├── .env.certtransparency      # CT service environment  
├── .env.signing               # Signing service environment
├── nginx.conf                 # Nginx reverse proxy configuration
├── generate-secrets.sh        # Secret generation script
├── secrets/                   # Generated secrets (create with script)
├── pki/                      # PKI materials (copy from tests/)
├── ssl/                      # SSL certificates for nginx
├── openvpn_templates/        # OpenVPN configuration templates
└── openvpn_options.yaml      # OpenVPN options configuration
```

## 🔐 Security Features

### Network Isolation
- Separate networks for frontend, backend, and database tiers
- Services only communicate through defined network interfaces

### Secret Management
- All sensitive values stored in Docker secrets
- No plaintext secrets in environment variables
- Secure file permissions (600) on secret files

### SSL/TLS Configuration
- Modern TLS configuration (TLS 1.2/1.3 only)
- Strong cipher suites and security headers
- HSTS and other security headers enabled

### Database Security
- Separate PostgreSQL instances for each service
- Password authentication via Docker secrets
- Isolated database networks

### Application Security
- Production environment configuration
- CSRF protection enabled
- Secure session cookie settings
- Rate limiting on authentication and API endpoints

## 🏥 Health Checks

All services include health checks:
- Database connectivity verification
- Application endpoint monitoring
- Dependency validation
- Automatic restart on failure

## 📊 Monitoring

Health check endpoints are available:
- Frontend: `https://yourdomain.com/health`
- Services expose internal health endpoints for monitoring

## 🔄 Maintenance

### Secret Rotation
1. Generate new secrets with `./generate-secrets.sh`
2. Update the affected services: `docker-compose up -d <service>`
3. Services will restart with new secrets automatically

### Database Migrations
Migrations run automatically during deployment via dedicated migration containers.

### Backup
- Database volumes are persistent and should be backed up regularly
- PKI materials should be backed up securely
- Secret files should be backed up to encrypted storage

## ⚙️ Configuration

### Required Environment Variables

Update these in the respective `.env.*` files:

- `OIDC_DISCOVERY_URL`: Your OIDC provider's discovery endpoint
- `OIDC_CLIENT_ID`: Client ID from your OIDC provider  
- `FRONTEND_SERVICE_URL`: Your public-facing URL

### SSL Certificates

Place your SSL certificates in the `ssl/` directory:
- `ssl/server.crt`: SSL certificate
- `ssl/server.key`: SSL private key

### PKI Materials

Copy PKI materials to the `pki/` directory:
- `pki/root-ca.crt`: Root CA certificate
- `pki/intermediate-ca.crt`: Intermediate CA certificate
- `pki/intermediate-ca.key`: Intermediate CA private key (encrypted)

## 🐛 Troubleshooting

### Check service status
```bash
docker-compose ps
```

### View service logs
```bash
docker-compose logs <service-name>
```

### Test database connectivity
```bash
docker-compose exec postgres-frontend psql -U frontend_user -d frontend_db -c "SELECT 1;"
```

### Verify secret files
```bash
ls -la secrets/
```

## 🚨 Security Considerations

1. **Never commit secrets to version control**
2. **Regularly rotate secrets and certificates**
3. **Monitor for security updates to base images**
4. **Implement proper backup and disaster recovery**
5. **Use a proper secrets management system for production**
6. **Regularly audit access logs and security configurations**
7. **Consider implementing additional monitoring and alerting**

## 📞 Support

For issues and questions:
- Check service logs for error details
- Verify all configuration values are correct
- Ensure all required files are present and have correct permissions
- Validate OIDC provider configuration