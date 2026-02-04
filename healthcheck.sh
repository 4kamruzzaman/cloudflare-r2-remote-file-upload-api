#!/bin/bash

# ----------------------------------------------------------------
# BizSafer SRE Tooling: Health Check Probe
# ----------------------------------------------------------------

TARGET_URL="http://localhost:8080/index.php"

echo "🩺 Initiating Health Probe..."
echo "Target: $TARGET_URL"

# 1. Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "❌ Error: curl is not installed."
    exit 1
fi

# 2. Perform Request
# -s: Silent
# -o /dev/null: Ignore body
# -w "%{http_code}": Print status code
# -X POST: Send POST (since GET is not allowed on index.php, we expect 401 or 400, which means code is running)
# Actually, checking status.php is better for a health probe.
CHECK_URL="http://localhost:8080/status.php?key=healthcheck_test"

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$CHECK_URL")

# 3. Analyze Result
# We accept 200 (OK) or 400/404 (App is running but key missing). 
# If we get 500 or 000, the server is dead.
if [[ "$HTTP_STATUS" =~ ^(200|400|404|401)$ ]]; then
    echo "✅ SYSTEM HEALTHY (Response Code: $HTTP_STATUS)"
    exit 0
else
    echo "❌ SYSTEM CRITICAL (Response Code: $HTTP_STATUS)"
    echo "Action Required: Check logs with 'docker compose logs -f'"
    exit 1
fi