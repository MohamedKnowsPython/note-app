#!/bin/bash
set -e

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_DIR="ci-reports/$TIMESTAMP"
mkdir -p "$REPORT_DIR"
LATEST_LINK="ci-reports/latest"

echo "=============================================="
echo "     NOTE APP - LOCAL CI/CD PIPELINE"
echo "     Started : $(date)"
echo "=============================================="

START_TOTAL=$(date +%s)
rm -rf playwright-report test-results

# ---------- 1. UNIT TESTS ----------
echo ""
echo ">>> [1/3] Unit Tests"
START=$(date +%s)

cd ~/frappe-bench
bench --site dev.localhost run-tests --app note_app > "apps/note_app/$REPORT_DIR/unit-tests.log" 2>&1 || true
UNIT_STATUS=$?

# Also generate a simple readable summary
echo "Unit tests finished with status: $UNIT_STATUS" >> "apps/note_app/$REPORT_DIR/unit-tests.log"

cd apps/note_app
END=$(date +%s)
UNIT_TIME=$((END - START))

if [ $UNIT_STATUS -eq 0 ]; then
  echo "    PASSED (${UNIT_TIME}s)"
  UNIT_RESULT="PASSED"
else
  echo "    FAILED (${UNIT_TIME}s)"
  UNIT_RESULT="FAILED"
fi

# ---------- 2. API TESTS ----------
echo ""
echo ">>> [2/3] API Tests (Playwright)"
START=$(date +%s)
npx playwright test --project=api --reporter=line,html > "$REPORT_DIR/api-tests.log" 2>&1
API_STATUS=$?
END=$(date +%s)
API_TIME=$((END - START))

if [ $API_STATUS -eq 0 ]; then
  echo "    PASSED (${API_TIME}s)"
  API_RESULT="PASSED"
else
  echo "    FAILED (${API_TIME}s)"
  API_RESULT="FAILED"
fi

# ---------- 3. E2E UI TESTS ----------
echo ""
echo ">>> [3/3] E2E UI Tests (Playwright)"
START=$(date +%s)
npx playwright test --project=e2e --reporter=line,html > "$REPORT_DIR/e2e-tests.log" 2>&1
E2E_STATUS=$?
END=$(date +%s)
E2E_TIME=$((END - START))

if [ $E2E_STATUS -eq 0 ]; then
  echo "    PASSED (${E2E_TIME}s)"
  E2E_RESULT="PASSED"
else
  echo "    FAILED (${E2E_TIME}s)"
  E2E_RESULT="FAILED"
fi

END_TOTAL=$(date +%s)
TOTAL_TIME=$((END_TOTAL - START_TOTAL))

# ---------- SAVE RESULTS ----------
cp -r playwright-report "$REPORT_DIR/" 2>/dev/null || true

cat > "$REPORT_DIR/summary.json" << JSON
{
  "timestamp": "$TIMESTAMP",
  "unit": "$UNIT_RESULT",
  "unit_time": $UNIT_TIME,
  "api": "$API_RESULT",
  "api_time": $API_TIME,
  "e2e": "$E2E_RESULT",
  "e2e_time": $E2E_TIME,
  "total_time": $TOTAL_TIME,
  "overall": "$([ "$UNIT_RESULT" = "PASSED" ] && [ "$API_RESULT" = "PASSED" ] && [ "$E2E_RESULT" = "PASSED" ] && echo "PASSED" || echo "FAILED")"
}
JSON

rm -rf "$LATEST_LINK"
ln -sfn "$TIMESTAMP" "$LATEST_LINK"

echo ""
echo "=============================================="
echo "Unit Tests  : $UNIT_RESULT  (${UNIT_TIME}s)"
echo "API Tests   : $API_RESULT  (${API_TIME}s)"
echo "E2E Tests   : $E2E_RESULT  (${E2E_TIME}s)"
echo "Total Time  : ${TOTAL_TIME}s"
echo "Overall     : $( [[ "$UNIT_RESULT" == "PASSED" && "$API_RESULT" == "PASSED" && "$E2E_RESULT" == "PASSED" ]] && echo PASSED || echo FAILED)"
echo "=============================================="

./update-dashboard.sh
