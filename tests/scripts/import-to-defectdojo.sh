#!/bin/bash
# import-to-defectdojo.sh
# Imports all security scan reports into DefectDojo via REST API
# Usage: DEFECTDOJO_URL=http://localhost:8080 DEFECTDOJO_TOKEN=<token> ./import-to-defectdojo.sh

set -e

DEFECTDOJO_URL="${DEFECTDOJO_URL:-http://localhost:8080}"
DEFECTDOJO_TOKEN="${DEFECTDOJO_TOKEN:-}"
ENGAGEMENT_ID="${ENGAGEMENT_ID:-1}"
REPORTS_DIR="${REPORTS_DIR:-tests/logs}"

if [ -z "$DEFECTDOJO_TOKEN" ]; then
  echo "ERROR: DEFECTDOJO_TOKEN not set"
  exit 1
fi

AUTH_HEADER="Authorization: Token $DEFECTDOJO_TOKEN"

import_scan() {
  local file="$1"
  local scan_type="$2"
  echo "Importing: $file ($scan_type)"
  curl -s -X POST "$DEFECTDOJO_URL/api/v2/import-scan/" \
    -H "$AUTH_HEADER" \
    -F "scan_type=$scan_type" \
    -F "engagement=$ENGAGEMENT_ID" \
    -F "minimum_severity=Low" \
    -F "active=true" \
    -F "verified=false" \
    -F "file=@$file" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'  -> test_id={d.get(\"test\")} findings={d.get(\"finding_count\",\"?\")}' )"
}

echo "=== DefectDojo Import Script - PAI4 ==="
echo "Target: $DEFECTDOJO_URL | Engagement: $ENGAGEMENT_ID"
echo ""

[ -f "$REPORTS_DIR/pip-audit-report.json" ]  && import_scan "$REPORTS_DIR/pip-audit-report.json"  "pip-audit Scan"
[ -f "$REPORTS_DIR/semgrep-report.json" ]    && import_scan "$REPORTS_DIR/semgrep-report.json"    "Semgrep JSON Report"
[ -f "$REPORTS_DIR/trivy-iac-report.json" ]  && import_scan "$REPORTS_DIR/trivy-iac-report.json"  "Trivy Scan"
[ -f "$REPORTS_DIR/trivy-image-report.json" ] && import_scan "$REPORTS_DIR/trivy-image-report.json" "Trivy Scan"
[ -f "$REPORTS_DIR/zap-report.xml" ]         && import_scan "$REPORTS_DIR/zap-report.xml"         "ZAP Scan"

echo ""
echo "=== Import complete ==="
