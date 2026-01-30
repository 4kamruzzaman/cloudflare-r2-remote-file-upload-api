# 🚀 Cloudflare R2 Remote File Upload API

A powerful PHP-based API that downloads files from any remote URL and automatically uploads them to Cloudflare R2 storage. Perfect for batch migrations, content aggregation, backup systems, and proxy upload services.

[![PHP Version](https://img.shields.io/badge/PHP-7.4%2B-blue)](https://php.net)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Cloudflare R2](https://img.shields.io/badge/Cloudflare-R2-orange)](https://www.cloudflare.com/products/r2/)

## ✨ Features

- 📥 **Download from Any URL** - Fetch files from remote servers
- ☁️ **Cloudflare R2 Integration** - Store files in R2 with S3-compatible API
- 🔄 **Asynchronous Processing** - Non-blocking background workers
- 🔁 **Auto-Retry Logic** - 3 attempts for failed downloads/uploads
- 📊 **Real-time Status Tracking** - Monitor upload progress via API
- 🎯 **Multipart Uploads** - Efficient handling of large files (32MB chunks)
- 🛡️ **Integrity Verification** - Automatic file size validation
- 📈 **Performance Metrics** - Track download and upload durations
- 🎨 **Admin Dashboard** - Web interface for managing uploads
- 🔒 **Secure Admin Panel** - Password-protected with session management
- 📁 **20+ File Format Support** - AI, PDF, images, videos, documents, and more
- ♻️ **Bulk Operations** - Mass delete and retry failed uploads

## 📋 Table of Contents

- [Requirements](#-requirements)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [API Endpoints](#-api-endpoints)
- [Admin Panel](#-admin-panel)
- [Database Schema](#-database-schema)
- [Troubleshooting](#-troubleshooting)
- [FAQ](#-faq)
- [License](#-license)

## 🔧 Requirements

Before you start, make sure you have:

### Server Requirements
- **PHP 7.4 or higher** (PHP 8.0+ recommended)
- **MySQL 5.7+** or **MariaDB 10.2+**
- **Apache** or **Nginx** web server
- **Composer** (PHP package manager)
- **PHP Extensions:**
  - `pdo_mysql` - Database connectivity
  - `curl` - HTTP requests
  - `mbstring` - String handling
  - `json` - JSON processing
  - `fileinfo` - MIME type detection

### Cloudflare Account Requirements
- Active Cloudflare account (free tier works!)
- R2 storage enabled
- R2 API tokens created
- (Optional) Custom domain for R2 bucket

### Recommended Server Specs
- **RAM**: 2GB minimum (for large file handling)
- **Disk Space**: Temporary storage for downloads
- **Bandwidth**: Good internet connection

## 📦 Installation

### Step 1: Clone or Download the Project

**Option A: Using Git**
```bash
git clone https://github.com/4kamruzzaman/cloudflare-r2-remote-file-upload-api.git
cd cloudflare-r2-remote-file-upload-api
```

**Option B: Manual Download**
1. Download the ZIP file from GitHub
2. Extract to your web server directory (e.g., `/var/www/html` or `C:\xampp\htdocs`)
3. Open terminal/command prompt in the project folder

### Step 2: Install PHP Dependencies

Run this command in your project folder:

```bash
composer install
```

**Don't have Composer?** [Download it here](https://getcomposer.org/download/)

**For Windows Users:**
- Download and run [Composer-Setup.exe](https://getcomposer.org/Composer-Setup.exe)
- Restart your terminal and run the command above

### Step 3: Create Database

1. Open **phpMyAdmin** or your database management tool
2. Create a new database:

```sql
CREATE DATABASE r2_uploads CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

3. Create the uploads table:

```sql
CREATE TABLE uploads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    object_key VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(50) DEFAULT 'pending',
    file_url TEXT,
    message TEXT,
    retries INT DEFAULT 0,
    size_bytes BIGINT,
    original_url TEXT,
    download_time_sec DECIMAL(10,2),
    upload_time_sec DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Step 4: Configure Cloudflare R2

#### A. Create R2 Bucket
1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Go to **R2** section
3. Click **"Create bucket"**
4. Name your bucket (e.g., `my-uploads`)
5. Click **"Create bucket"**

#### B. Generate API Tokens
1. In R2 section, click **"Manage R2 API Tokens"**
2. Click **"Create API token"**
3. Set permissions: **"Admin Read & Write"**
4. Click **"Create API token"**
5. **IMPORTANT:** Copy and save:
   - **Access Key ID** (e.g., `abc123def456...`)
   - **Secret Access Key** (e.g., `xyz789...`)
   - **Account ID** (found in R2 dashboard URL)

⚠️ **Save these credentials immediately - you won't see them again!**

#### C. (Optional) Setup Custom Domain
1. In your R2 bucket settings, click **"Settings"**
2. Under "Public access", click **"Connect Domain"**
3. Add your domain (e.g., `files.yourdomain.com`)
4. Follow DNS setup instructions
5. Wait for DNS propagation (5-30 minutes)

### Step 5: Configure Environment Variables

1. Create a file named **`.env`** in the project root folder
2. Copy and paste this template:

```env
# Database Configuration
DB_HOST=localhost
DB_USER=your_database_username
DB_PASS=your_database_password
DB_NAME=r2_uploads

# Cloudflare R2 Configuration
R2_KEY_ID=your_r2_access_key_id
R2_SECRET_KEY=your_r2_secret_access_key
R2_BUCKET=your-bucket-name
R2_ACCOUNT_ID=your_cloudflare_account_id

# Public URL Configuration
# Option 1: Use R2 public domain
R2_CUSTOM_DOMAIN=pub-xxxxx.r2.dev

# Option 2: Use your custom domain (recommended)
# R2_CUSTOM_DOMAIN=files.yourdomain.com

# Admin Panel Credentials
ADMIN_USER=admin
# Generate password hash at: https://bcrypt-generator.com/ (use 12 rounds)
ADMIN_PASS_HASH=$2y$12$your_bcrypt_hashed_password_here
```

3. **Replace all placeholder values** with your actual credentials

#### How to Generate Admin Password Hash:
1. Go to https://bcrypt-generator.com/
2. Enter your desired password
3. Select **12 rounds**
4. Click **"Generate"**
5. Copy the hash (starts with `$2y$12$`)
6. Paste into `ADMIN_PASS_HASH`

### Step 6: Set File Permissions

**For Linux/Mac:**
```bash
chmod 755 admin
chmod 644 .env
chmod 644 *.php
```

**For Windows:**
- Right-click folder → Properties → Security
- Ensure web server user has read/write permissions

### Step 7: Configure Web Server

#### Apache (.htaccess already included)
Make sure `mod_rewrite` is enabled:
```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

#### Nginx
Add this to your server block:

```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}

location ~ \.php$ {
    fastcgi_pass unix:/var/run/php/php8.0-fpm.sock;
    fastcgi_index index.php;
    include fastcgi_params;
}
```

### Step 8: Test Installation

1. Open your browser
2. Navigate to: `http://your-domain.com/test.php`
3. You should see: **"Setup complete!"** (if test file is configured)
4. Or navigate to: `http://your-domain.com/admin/login.php`
5. Try logging in with your admin credentials

## ⚙️ Configuration

### Environment Variables Explained

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_HOST` | Database server address | `localhost` or `127.0.0.1` |
| `DB_USER` | Database username | `root` or `your_db_user` |
| `DB_PASS` | Database password | Your database password |
| `DB_NAME` | Database name | `r2_uploads` |
| `R2_KEY_ID` | R2 Access Key ID | From Cloudflare R2 API token |
| `R2_SECRET_KEY` | R2 Secret Access Key | From Cloudflare R2 API token |
| `R2_BUCKET` | R2 Bucket name | `my-uploads` |
| `R2_ACCOUNT_ID` | Cloudflare Account ID | Found in R2 dashboard URL |
| `R2_CUSTOM_DOMAIN` | Public domain for files | `files.yourdomain.com` |
| `ADMIN_USER` | Admin panel username | `admin` |
| `ADMIN_PASS_HASH` | Bcrypt hashed password | Generated hash from bcrypt |

### Advanced Configuration

#### Adjust Memory Limits
Edit `upload_worker.php` line 2:
```php
ini_set('memory_limit', '1G'); // Increase for larger files
```

#### Change Chunk Size
Edit `upload_worker.php` around line 140:
```php
'part_size' => 32 * 1024 * 1024, // 32MB chunks (adjust as needed)
```

#### Modify Retry Attempts
Edit `upload_worker.php` around line 60:
```php
$maxRetries = 3; // Change number of retry attempts
```

## 🚀 Usage

### Basic Upload Flow

1. **Send API Request** → File starts downloading
2. **Worker Process** → Downloads and uploads in background
3. **Check Status** → Poll status endpoint
4. **Get File URL** → Receive public R2 URL

### Upload a File via API

#### Using cURL (Command Line)

```bash
curl -X POST http://your-domain.com/index.php \
  -H "Content-Type: application/json" \
  -d '{
    "file_url": "https://example.com/video.mp4",
    "filename": "my-video.mp4"
  }'
```

#### Using PHP

```php
<?php
$url = 'http://your-domain.com/index.php';
$data = [
    'file_url' => 'https://example.com/image.jpg',
    'filename' => 'my-image.jpg'
];

$options = [
    'http' => [
        'header'  => "Content-type: application/json\r\n",
        'method'  => 'POST',
        'content' => json_encode($data)
    ]
];

$context = stream_context_create($options);
$result = file_get_contents($url, false, $context);
$response = json_decode($result, true);

print_r($response);
?>
```

#### Using JavaScript/jQuery

```javascript
$.ajax({
    url: 'http://your-domain.com/index.php',
    type: 'POST',
    contentType: 'application/json',
    data: JSON.stringify({
        file_url: 'https://example.com/document.pdf',
        filename: 'my-document.pdf'
    }),
    success: function(response) {
        console.log('Upload started:', response);
    }
});
```

#### Using Python

```python
import requests
import json

url = 'http://your-domain.com/index.php'
data = {
    'file_url': 'https://example.com/file.zip',
    'filename': 'my-file.zip'
}

response = requests.post(url, json=data)
print(response.json())
```

### Check Upload Status

#### Using cURL

```bash
curl "http://your-domain.com/status.php?key=my-video.mp4"
```

#### Using JavaScript

```javascript
fetch('http://your-domain.com/status.php?key=my-video.mp4')
    .then(response => response.json())
    .then(data => {
        console.log('Status:', data.status);
        if (data.status === 'completed') {
            console.log('File URL:', data.file_url);
        }
    });
```

### Response Examples

#### Upload Started Successfully
```json
{
    "status": "started",
    "message": "File download started",
    "object_key": "my-video.mp4"
}
```

#### Status Check - In Progress
```json
{
    "status": "downloading",
    "message": "Downloading file from remote URL",
    "object_key": "my-video.mp4",
    "retries": 0
}
```

#### Status Check - Completed
```json
{
    "status": "completed",
    "message": "Upload completed successfully",
    "object_key": "my-video.mp4",
    "file_url": "https://files.yourdomain.com/my-video.mp4",
    "size_bytes": 15728640,
    "download_time_sec": 8.45,
    "upload_time_sec": 3.21
}
```

#### Status Check - Failed
```json
{
    "status": "failed",
    "message": "Download failed: Connection timeout",
    "object_key": "my-video.mp4",
    "retries": 3
}
```

## 📡 API Endpoints

### POST /index.php
Start a new file upload

**Request:**
```json
{
    "file_url": "https://example.com/file.ext",
    "filename": "custom-name.ext"
}
```

**Parameters:**
- `file_url` (required): Remote URL of the file to download
- `filename` (required): Desired filename in R2 storage

**Response:** `201 Created`
```json
{
    "status": "started",
    "message": "File download started",
    "object_key": "custom-name.ext"
}
```

---

### GET /status.php?key={filename}
Check upload status

**Parameters:**
- `key` (required): The filename/object key

**Response:** `200 OK`
```json
{
    "status": "completed|downloading|uploading|failed|pending",
    "message": "Status message",
    "object_key": "filename.ext",
    "file_url": "https://...",
    "size_bytes": 12345,
    "download_time_sec": 2.5,
    "upload_time_sec": 1.8,
    "retries": 0
}
```

**Status Values:**
- `pending` - Queued, waiting to start
- `preparing` - Worker initializing
- `downloading` - Downloading from remote URL
- `uploading` - Uploading to R2
- `completed` - Successfully uploaded
- `failed` - Upload failed after retries

## 🎛️ Admin Panel

Access the admin dashboard at: `http://your-domain.com/admin/`

### Features

#### 📊 Dashboard
- View all uploads with status
- Filter by status (pending, completed, failed)
- Sort by date, size, or duration
- Search by filename

#### 🗑️ Bulk Delete
1. Select multiple files
2. Click "Delete Selected"
3. Files are removed from both database and R2

#### 🔄 Bulk Retry
1. Select failed uploads
2. Click "Retry Selected"
3. Workers restart the upload process

#### 📈 Statistics
- Total uploads
- Success rate
- Average upload time
- Total storage used

### Admin Login

**URL:** `http://your-domain.com/admin/login.php`

**Credentials:**
- Username: From `.env` (`ADMIN_USER`)
- Password: The password you used to generate the hash

### Security Features
- Session-based authentication
- Bcrypt password hashing
- `.htaccess` protection
- CSRF protection (recommended to add)

## 🗄️ Database Schema

```sql
CREATE TABLE uploads (
    id INT AUTO_INCREMENT PRIMARY KEY,
    object_key VARCHAR(255) NOT NULL UNIQUE,
    status VARCHAR(50) DEFAULT 'pending',
    file_url TEXT,
    message TEXT,
    retries INT DEFAULT 0,
    size_bytes BIGINT,
    original_url TEXT,
    download_time_sec DECIMAL(10,2),
    upload_time_sec DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `id` | INT | Auto-incrementing primary key |
| `object_key` | VARCHAR(255) | Filename in R2 (unique) |
| `status` | VARCHAR(50) | Current status of upload |
| `file_url` | TEXT | Public R2 URL after completion |
| `message` | TEXT | Status message or error details |
| `retries` | INT | Number of retry attempts |
| `size_bytes` | BIGINT | File size in bytes |
| `original_url` | TEXT | Source URL of the file |
| `download_time_sec` | DECIMAL | Time taken to download |
| `upload_time_sec` | DECIMAL | Time taken to upload to R2 |
| `created_at` | TIMESTAMP | Record creation time |
| `updated_at` | TIMESTAMP | Last update time |

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. "Database connection failed"
**Cause:** Incorrect database credentials or server not running

**Solution:**
- Verify `.env` database settings
- Check if MySQL/MariaDB is running: `sudo systemctl status mysql`
- Test connection: `mysql -u your_user -p`

---

#### 2. "R2 upload failed: Invalid credentials"
**Cause:** Wrong R2 API keys or account ID

**Solution:**
- Regenerate R2 API tokens in Cloudflare dashboard
- Double-check `R2_KEY_ID`, `R2_SECRET_KEY`, and `R2_ACCOUNT_ID`
- Ensure no extra spaces in `.env` file

---

#### 3. "Worker process not starting"
**Cause:** PHP not found in system PATH or insufficient permissions

**Solution:**
- **Windows:** Add PHP to PATH environment variable
- **Linux:** Check PHP path: `which php`
- Update `index.php` line 28: `$cmd = "/full/path/to/php upload_worker.php ...";`

---

#### 4. "Download failed: SSL certificate problem"
**Cause:** SSL verification issues

**Solution:**
- Update CA certificates: `sudo apt-get install ca-certificates`
- Or disable verification in `upload_worker.php` (not recommended for production)

---

#### 5. "Memory limit exceeded"
**Cause:** Large files exceeding PHP memory limit

**Solution:**
- Increase memory in `upload_worker.php`: `ini_set('memory_limit', '2G');`
- Or adjust php.ini: `memory_limit = 2048M`
- Reduce chunk size to use less memory

---

#### 6. "File not found after upload"
**Cause:** R2 bucket not public or wrong domain

**Solution:**
- Make bucket public in R2 settings
- Verify `R2_CUSTOM_DOMAIN` in `.env`
- Check bucket name matches `.env` configuration

---

#### 7. "Admin panel login fails"
**Cause:** Incorrect password hash or session issues

**Solution:**
- Regenerate bcrypt hash with correct password
- Clear browser cookies/cache
- Check `session_start()` errors in PHP error log

---

#### 8. "Upload stuck in 'pending' status"
**Cause:** Worker crashed or didn't start

**Solution:**
- Check PHP error log: `/var/log/php_errors.log`
- Manually run: `php upload_worker.php pending "https://..." "file.ext"`
- Verify database connection in worker

---

### Enable Debug Mode

Add to top of `upload_worker.php`:
```php
error_reporting(E_ALL);
ini_set('display_errors', 1);
```

Check error logs:
- **Linux:** `/var/log/apache2/error.log` or `/var/log/php_errors.log`
- **Windows XAMPP:** `C:\xampp\apache\logs\error.log`

## ❓ FAQ

### General Questions

**Q: Is this free to use?**  
A: Yes! The code is open-source. You only pay for Cloudflare R2 storage (first 10GB free).

**Q: Can I use this for commercial projects?**  
A: Absolutely! No restrictions on commercial use.

**Q: What's the maximum file size?**  
A: Limited only by your server's disk space and R2's 5TB object limit. Tested with 10GB+ files.

**Q: Does it work with other S3-compatible services?**  
A: Yes! Modify `db.php` `r2()` function to point to AWS S3, DigitalOcean Spaces, MinIO, etc.

### Technical Questions

**Q: Can multiple uploads run simultaneously?**  
A: Yes! Each upload spawns an independent background worker.

**Q: How do I limit concurrent uploads?**  
A: Implement a queue system (Redis/RabbitMQ) or check running processes before spawning.

**Q: Can I customize chunk size?**  
A: Yes, edit `part_size` in `upload_worker.php` (line ~140).

**Q: How are duplicate files handled?**  
A: Files with same `object_key` update existing records. To prevent overwrites, use unique filenames.

**Q: Can I upload from local files?**  
A: Not directly. Host files temporarily on a web server, then use the URL.

**Q: Is there a webhook for completion notifications?**  
A: Not included. Add webhook calls in `upload_worker.php` after upload completion.

### Cloudflare R2 Questions

**Q: What's included in R2 free tier?**  
A: 10GB storage, 10 million Class A operations, 100 million Class B operations per month.

**Q: How much does R2 cost beyond free tier?**  
A: $0.015/GB/month storage. No egress fees!

**Q: Can I use R2 without custom domain?**  
A: Yes, use the provided `pub-xxxxx.r2.dev` domain.

## 📊 Performance Tips

### Optimize Upload Speed

1. **Increase chunk size** for fast connections:
   ```php
   'part_size' => 64 * 1024 * 1024, // 64MB chunks
   ```

2. **Adjust concurrency** in multipart uploader:
   ```php
   'concurrency' => 5, // Upload 5 parts simultaneously
   ```

3. **Use SSD storage** for temporary downloads

4. **Optimize PHP settings** in `php.ini`:
   ```ini
   max_execution_time = 300
   memory_limit = 2048M
   post_max_size = 1024M
   upload_max_filesize = 1024M
   ```

### Reduce Database Load

1. Add indexes for frequently queried columns:
   ```sql
   CREATE INDEX idx_status ON uploads(status);
   CREATE INDEX idx_created ON uploads(created_at);
   ```

2. Archive old completed uploads periodically

### Monitor System Resources

```bash
# Check running PHP processes
ps aux | grep php

# Monitor disk usage
df -h

# Check MySQL connections
mysqladmin -u root -p processlist
```

## 🔒 Security Best Practices

1. **Use HTTPS** - Always secure your API endpoints with SSL/TLS
2. **API Authentication** - Add token-based auth to `index.php` (not included)
3. **Rate Limiting** - Prevent abuse with request limits
4. **Input Validation** - Sanitize and validate all URLs
5. **File Type Restrictions** - Limit allowed file extensions
6. **Regular Updates** - Keep PHP and dependencies updated
7. **Secure .env** - Never commit `.env` to version control
8. **Strong Admin Password** - Use 16+ character passwords
9. **Monitor Logs** - Regularly check error logs for suspicious activity
10. **Firewall Rules** - Restrict admin panel to specific IPs if possible

## 🚀 Deployment

### Production Checklist

- [ ] Enable HTTPS with SSL certificate (Let's Encrypt)
- [ ] Set secure file permissions (644 for files, 755 for directories)
- [ ] Disable PHP error display (`display_errors = Off`)
- [ ] Enable PHP error logging
- [ ] Configure firewall (UFW/iptables)
- [ ] Set up database backups (daily recommended)
- [ ] Monitor disk space for temp files
- [ ] Configure logrotate for log files
- [ ] Add monitoring/alerting (optional)
- [ ] Test disaster recovery procedures

### Recommended Server Stack

**For Small to Medium Traffic:**
- **OS:** Ubuntu 22.04 LTS
- **Web Server:** Nginx 1.22+
- **PHP:** 8.1 FPM
- **Database:** MariaDB 10.6+
- **RAM:** 4GB minimum
- **Storage:** 50GB+ SSD

**For High Traffic:**
- Load balancer (HAProxy/Nginx)
- Multiple PHP-FPM workers
- Redis for queue management
- Database replication
- CDN for static files

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

Need help? Here's how to get support:

- 📖 **Documentation:** Read this README thoroughly
- 🐛 **Bug Reports:** [Open an issue](https://github.com/4kamruzzaman/cloudflare-r2-remote-file-upload-api/issues)
- 💡 **Feature Requests:** [Start a discussion](https://github.com/4kamruzzaman/cloudflare-r2-remote-file-upload-api/discussions)
- 📧 **Email:** 4kamruzzaman@gmail.com

## 🙏 Acknowledgments

- Cloudflare for the amazing R2 storage service
- AWS SDK for PHP maintainers
- Guzzle HTTP client contributors
- The open-source community

## 📈 Roadmap

Future enhancements planned:

- [ ] Web UI for file uploads
- [ ] Webhook notifications
- [ ] Queue management system (Redis)
- [ ] File preview generation
- [ ] Scheduled uploads
- [ ] Batch import from CSV
- [ ] API rate limiting
- [ ] Multi-bucket support
- [ ] Docker containerization
- [ ] REST API documentation (OpenAPI/Swagger)

---

<div align="center">

**Made with ❤️ for the community**

If this project helped you, please ⭐ star the repository!

[Report Bug](https://github.com/4kamruzzaman/cloudflare-r2-remote-file-upload-api/issues) · [Request Feature](https://github.com/4kamruzzaman/cloudflare-r2-remote-file-upload-api/issues) · [Documentation](https://github.com/4kamruzzaman/cloudflare-r2-remote-file-upload-api/wiki)

</div>
