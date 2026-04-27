#!/bin/bash
# run-zap-scan.sh
# Runs OWASP ZAP Baseline Scan against the staging application
# Usage: TARGET_URL=http://localhost:8080 ./run-zap-scan.sh

TARGET_URL="${TARGET_URL:-http://localhost:8080}"
OUTPUT_DIR="${OUTPUT_DIR:-tests/logs}"

echo "=== OWASP ZAP Baseline Scan - PAI4 ==="
echo "Target: $TARGET_URL"

docker run --rm \
  -v "$(pwd)/$OUTPUT_DIR:/zap/wrk:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py \
    -t "$TARGET_URL" \
    -r zap-report.html \
    -x zap-report.xml \
    -J zap-report.json \
    -I

echo "ZAP reports saved to $OUTPUT_DIR/"
