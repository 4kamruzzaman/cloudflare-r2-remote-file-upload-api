# 🚀 Cloudflare R2 Remote File Upload API
## Enterprise-Grade SRE Edition

A container-native microservice that fetches files from any remote URL and streams them directly to Cloudflare R2 (S3-compatible) storage. Designed for high-availability batch migrations, content aggregation, and background processing.

[![Docker](https://img.shields.io/badge/Docker-Container_Native-blue?logo=docker)](https://www.docker.com/)
[![PHP](https://img.shields.io/badge/PHP-8.2_LTS-777BB4?logo=php)](https://php.net)
[![Cloudflare R2](https://img.shields.io/badge/Cloudflare-R2-F38020?logo=cloudflare)](https://www.cloudflare.com/products/r2/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## ✨ Architecture Highlights

- **Zero-Trust Security:** API key enforcement on all write endpoints
- **Asynchronous Processing:** Non-blocking background workers for immediate API response
- **Container-Native:** Fully Dockerized with persistent MySQL volumes
- **Resilient Infrastructure:** Includes automated backup (`backup.sh`) and health probe (`healthcheck.sh`)
- **Smart Multipart Uploads:** Handles large files (1GB+) via 32MB streaming chunks
- **Self-Healing:** Auto-retry logic (3 attempts) for network instability

---

## 🔧 Requirements

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Cloudflare account with R2 enabled

---

## 📦 Quick Start (Docker)

**Recommended method.** No manual PHP/MySQL installation required.

### 1. Clone the Repository

```bash
git clone https://github.com/4kamruzzaman/cloudflare-r2-remote-file-upload-api.git
cd cloudflare-r2-remote-file-upload-api
```

### 2. Configure Environment

```bash
cp .env.example .env
```

### 3. Setup Credentials

Open `.env` and configure your keys.  
**Critical:** You must set a strong `API_ACCESS_KEY`.

```ini
# Database (Internal Docker Networking)
DB_HOST=db
DB_USER=bizsafer_user
DB_PASS=secure_password
DB_NAME=r2_uploads

# Cloudflare R2 Credentials
R2_ACCOUNT_ID=your_cf_account_id
R2_ACCESS_KEY_ID=your_access_key
R2_SECRET_ACCESS_KEY=your_secret_key
R2_BUCKET_NAME=your-bucket-name
R2_CUSTOM_DOMAIN=https://files.yourdomain.com

# Security Gatekeeper
API_ACCESS_KEY=sk_prod_YOUR_SECRET_KEY_HERE
```

### 4. Launch Infrastructure

```bash
docker compose up -d
```

The system is now live at: http://localhost:8080

---

## 📡 API Reference

### Upload File

- **Endpoint:** `POST /index.php`
- **Auth:** Required (`X-API-KEY` header)

```bash
curl -X POST http://localhost:8080/index.php \
  -H "Content-Type: application/json" \
  -H "X-API-KEY: sk_prod_YOUR_SECRET_KEY_HERE" \
  -d '{
    "url": "https://example.com/large-video.mp4",
    "filename": "my-video.mp4"
  }'
```

```json
{
  "success": true,
  "status": "pending",
  "key": "my-video.mp4",
  "message": "Upload started in background"
}
```

### Check Status

- **Endpoint:** `GET /status.php?key={filename}`

```bash
curl "http://localhost:8080/status.php?key=my-video.mp4"
```

```json
{
  "success": true,
  "status": "completed",
  "file_url": "https://files.yourdomain.com/my-video.mp4",
  "message": "Uploaded successfully",
  "size_bytes": 15728640,
  "original_url": "https://example.com/large-video.mp4",
  "download_time_sec": "1.45",
  "upload_time_sec": "3.21"
}
```

---

## 🛠️ Operational Standards (SOPs)

### Backup

```bash
chmod +x backup.sh
./backup.sh
```

### Health Check

```bash
chmod +x healthcheck.sh
./healthcheck.sh
```

### Live Logs

```bash
docker compose logs -f app
```

---

## ❓ FAQ

**Q: Where do I get `API_ACCESS_KEY`?**  
A: You generate it yourself and define it in `.env`.

**Q: Can I use this without Docker?**  
A: Yes, but you must manually install PHP, MySQL, and Composer.

**Q: How do I access the database manually?**  
A: Connect to `127.0.0.1:3306` using credentials from `.env`.

---

## 📄 License

MIT License

---

**BizSafer Engineering Lab**