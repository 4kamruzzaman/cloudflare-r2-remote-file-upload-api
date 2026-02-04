#!/bin/bash

# ----------------------------------------------------------------
# BizSafer SRE Tooling: Database Backup (Root / Admin Mode)
# ----------------------------------------------------------------

# 1. Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
FILENAME="db_backup_$TIMESTAMP.sql.gz"
CONTAINER_NAME="bizsafer-r2-db"

# 2. Extract Credentials (Robust method)
# We specifically hunt for the ROOT password to bypass permission errors.
DB_USER="root"
DB_PASS=$(grep '^DB_ROOT_PASS=' .env | cut -d '=' -f2 | tr -d '\r' | tr -d '"')
DB_NAME=$(grep '^DB_NAME=' .env | cut -d '=' -f2 | tr -d '\r' | tr -d '"')

echo "🚀 Starting ADMINISTRATIVE backup for database: $DB_NAME..."

# 3. Create Directory
mkdir -p $BACKUP_DIR

# 4. Execute Dump
# We pass the password environment variable INTO the exec command to avoid CLI quoting issues.
# We explicitly use the root user.
docker exec -e MYSQL_PWD="$DB_PASS" $CONTAINER_NAME \
    mysqldump -u "$DB_USER" \
    --single-transaction \
    --quick \
    "$DB_NAME" \
    | gzip > "$BACKUP_DIR/$FILENAME"

# 5. Validation
if [ -s "$BACKUP_DIR/$FILENAME" ]; then
    SIZE=$(du -h "$BACKUP_DIR/$FILENAME" | cut -f1)
    echo "✅ Success! Backup saved: $BACKUP_DIR/$FILENAME ($SIZE)"
else
    echo "❌ Backup Failed. File is empty."
    echo "   Diagnostic: Verifying root access..."
    # Debug: Try to show error without gzip
    docker exec -e MYSQL_PWD="$DB_PASS" $CONTAINER_NAME mysqldump -u "$DB_USER" "$DB_NAME" > /dev/null
    rm "$BACKUP_DIR/$FILENAME"
    exit 1
fi