<?php
// index.php — Secured Public Entry Point
// Owner: Senior SRE & Lead Architect

header('Content-Type: application/json');
date_default_timezone_set('Asia/Dhaka');

require_once __DIR__ . '/db.php';

// ----------------------------------------------------------------
// 1. SECURITY AUDIT (The Gatekeeper)
// ----------------------------------------------------------------
$serverKey = env('API_ACCESS_KEY');
$clientKey = $_SERVER['HTTP_X_API_KEY'] ?? $_SERVER['HTTP_X_API_KEY'] ?? '';

// Fail if server is not configured
if (empty($serverKey)) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Server Configuration Error: API_ACCESS_KEY missing in .env']);
    exit;
}

// Fail if client is unauthorized
if ($clientKey !== $serverKey) {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Unauthorized: Invalid or missing X-API-KEY']);
    exit;
}

// ----------------------------------------------------------------
// 2. REQUEST VALIDATION
// ----------------------------------------------------------------
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Only POST allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if (empty($input['url'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'error' => "Missing 'url' parameter"]);
    exit;
}

// ----------------------------------------------------------------
// 3. EXECUTION LOGIC
// ----------------------------------------------------------------
$url = trim($input['url']);
$filename = !empty($input['filename'])
    ? trim($input['filename'])
    : basename(parse_url($url, PHP_URL_PATH));

// Enforce flat key (security best practice)
$objectKey = basename($filename);

// Create pending status
setStatus(
    $objectKey,
    'pending',
    null,             // file_url
    'Upload started', // message
    0,                // retries
    0,                // size_bytes
    $url,             // original_url
    0,                // download_time_sec
    0                 // upload_time_sec
);

// Spawn Worker (Background Process)
// Note: Worker runs in CLI mode, so it bypasses the HTTP API Key check (Correct behavior)
$cmd = 'php ' . escapeshellarg(__DIR__ . '/upload_worker.php') . ' '
    . escapeshellarg($url) . ' '
    . escapeshellarg($objectKey) . ' > /dev/null 2>&1 &';

exec($cmd);

// Return pending status immediately
echo json_encode([
    'success' => true,
    'status'  => 'pending',
    'key'     => $objectKey,
    'message' => 'Upload started in background'
]);