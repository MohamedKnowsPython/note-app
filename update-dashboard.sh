#!/bin/bash

LATEST="ci-reports/latest"
DASHBOARD="ci-dashboard.html"

if [ ! -f "$LATEST/summary.json" ]; then
  echo "No results found. Run ./run-ci.sh first."
  exit 1
fi

UNIT=$(jq -r .unit "$LATEST/summary.json")
API=$(jq -r .api "$LATEST/summary.json")
E2E=$(jq -r .e2e "$LATEST/summary.json")
OVERALL=$(jq -r .overall "$LATEST/summary.json")
TIMESTAMP=$(jq -r .timestamp "$LATEST/summary.json")
UNIT_TIME=$(jq -r .unit_time "$LATEST/summary.json")
API_TIME=$(jq -r .api_time "$LATEST/summary.json")
E2E_TIME=$(jq -r .e2e_time "$LATEST/summary.json")
TOTAL_TIME=$(jq -r .total_time "$LATEST/summary.json")

status_class() {
  [ "$1" = "PASSED" ] && echo "passed" || echo "failed"
}

# Build history (last 8 runs)
HISTORY_ROWS=""
for dir in $(ls -1d ci-reports/20* 2>/dev/null | sort -r | head -8); do
  if [ -f "$dir/summary.json" ]; then
    TS=$(jq -r .timestamp "$dir/summary.json")
    OV=$(jq -r .overall "$dir/summary.json")
    TT=$(jq -r .total_time "$dir/summary.json")
    UT=$(jq -r .unit_time "$dir/summary.json")
    AT=$(jq -r .api_time "$dir/summary.json")
    ET=$(jq -r .e2e_time "$dir/summary.json")
    CLS=$([ "$OV" = "PASSED" ] && echo "passed" || echo "failed")
    HISTORY_ROWS="$HISTORY_ROWS
      <tr>
        <td>$TS</td>
        <td class=\"$CLS\">$OV</td>
        <td>${TT}s</td>
        <td>${UT}s</td>
        <td>${AT}s</td>
        <td>${ET}s</td>
      </tr>"
  fi
done

cat > $DASHBOARD << HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Note App - CI/CD Dashboard</title>
  <style>
    body { font-family: system-ui, -apple-system, sans-serif; background: #0f172a; color: #e2e8f0; margin: 0; padding: 2rem; }
    h1 { color: #38bdf8; margin-bottom: 0.3rem; }
    .subtitle { color: #94a3b8; margin-bottom: 2rem; }
    .card { background: #1e293b; border-radius: 12px; padding: 1.5rem; margin-bottom: 1.5rem; }
    .passed { color: #4ade80; font-weight: 600; }
    .failed { color: #f87171; font-weight: 600; }
    table { width: 100%; border-collapse: collapse; }
    th, td { padding: 0.75rem 1rem; text-align: left; border-bottom: 1px solid #334155; }
    th { color: #94a3b8; font-weight: 500; }
    a { color: #38bdf8; text-decoration: none; }
    a:hover { text-decoration: underline; }
    .overall { font-size: 1.3rem; margin-top: 1.2rem; }
    pre { background: #0f172a; padding: 1rem; border-radius: 8px; }
  </style>
</head>
<body>
  <h1>Note App - CI/CD Dashboard</h1>
  <p class="subtitle">Last run: $TIMESTAMP &nbsp;|&nbsp; Total time: <strong>${TOTAL_TIME}s</strong></p>

  <!-- Latest Results -->
  <div class="card">
    <h2>Latest Pipeline Results</h2>
    <table>
      <thead>
        <tr>
          <th>Stage</th>
          <th>Status</th>
          <th>Duration</th>
          <th>Action</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Unit Tests</td>
          <td class="$(status_class $UNIT)">$UNIT</td>
          <td>${UNIT_TIME}s</td>
          <td><a href="ci-reports/latest/unit-tests.log" target="_blank">View Log</a></td>
        </tr>
        <tr>
          <td>API Tests (Playwright)</td>
          <td class="$(status_class $API)">$API</td>
          <td>${API_TIME}s</td>
          <td><a href="ci-reports/latest/playwright-report/index.html" target="_blank">Open Report</a></td>
        </tr>
        <tr>
          <td>E2E UI Tests (Playwright)</td>
          <td class="$(status_class $E2E)">$E2E</td>
          <td>${E2E_TIME}s</td>
          <td><a href="ci-reports/latest/playwright-report/index.html" target="_blank">Open Report</a></td>
        </tr>
      </tbody>
    </table>
    <div class="overall">
      Overall Status: <span class="$(status_class $OVERALL)">$OVERALL</span>
    </div>
  </div>

  <!-- SLAs -->
  <div class="card">
    <h2>SLAs (Service Level Agreements)</h2>
    <table>
      <thead>
        <tr>
          <th>Metric</th>
          <th>Target</th>
          <th>Current</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Unit Tests Duration</td>
          <td>&lt; 10 seconds</td>
          <td>${UNIT_TIME}s</td>
          <td class="$([ $UNIT_TIME -lt 10 ] && echo passed || echo failed)">$([ $UNIT_TIME -lt 10 ] && echo "MET" || echo "BREACHED")</td>
        </tr>
        <tr>
          <td>API Tests Duration</td>
          <td>&lt; 15 seconds</td>
          <td>${API_TIME}s</td>
          <td class="$([ $API_TIME -lt 15 ] && echo passed || echo failed)">$([ $API_TIME -lt 15 ] && echo "MET" || echo "BREACHED")</td>
        </tr>
        <tr>
          <td>E2E UI Tests Duration</td>
          <td>&lt; 60 seconds</td>
          <td>${E2E_TIME}s</td>
          <td class="$([ $E2E_TIME -lt 60 ] && echo passed || echo failed)">$([ $E2E_TIME -lt 60 ] && echo "MET" || echo "BREACHED")</td>
        </tr>
        <tr>
          <td>Full Pipeline Duration</td>
          <td>&lt; 90 seconds</td>
          <td>${TOTAL_TIME}s</td>
          <td class="$([ $TOTAL_TIME -lt 90 ] && echo passed || echo failed)">$([ $TOTAL_TIME -lt 90 ] && echo "MET" || echo "BREACHED")</td>
        </tr>
        <tr>
          <td>Pass Rate</td>
          <td>100%</td>
          <td>$([ "$OVERALL" = "PASSED" ] && echo "100%" || echo "Failed")</td>
          <td class="$(status_class $OVERALL)">$([ "$OVERALL" = "PASSED" ] && echo "MET" || echo "BREACHED")</td>
        </tr>
      </tbody>
    </table>
  </div>

  <!-- History -->
  <div class="card">
    <h2>Run History (Last 8 runs)</h2>
    <table>
      <thead>
        <tr>
          <th>Timestamp</th>
          <th>Overall</th>
          <th>Total</th>
          <th>Unit</th>
          <th>API</th>
          <th>E2E</th>
        </tr>
      </thead>
      <tbody>
        $HISTORY_ROWS
      </tbody>
    </table>
  </div>

  <div class="card">
    <h2>How to run the pipeline</h2>
    <pre>cd ~/frappe-bench/apps/note_app
./run-ci.sh</pre>
  </div>
</body>
</html>
HTML

echo "✅ Dashboard updated → $DASHBOARD"
