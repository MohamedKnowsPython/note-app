#!/bin/bash

DASHBOARD="ci-dashboard.html"

cat > $DASHBOARD << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Note App - CI/CD Dashboard</title>
  <style>
    body { font-family: system-ui, sans-serif; background: #0f172a; color: #e2e8f0; margin: 0; padding: 2rem; }
    h1 { color: #38bdf8; }
    .card { background: #1e293b; border-radius: 12px; padding: 1.5rem; margin-bottom: 1.5rem; }
    .passed { color: #4ade80; font-weight: bold; }
    .failed { color: #f87171; font-weight: bold; }
    table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
    th, td { padding: 0.75rem; text-align: left; border-bottom: 1px solid #334155; }
    th { color: #94a3b8; }
    a { color: #38bdf8; text-decoration: none; }
    a:hover { text-decoration: underline; }
  </style>
</head>
<body>
  <h1>Note App - Local CI/CD Dashboard</h1>
  <p>Last updated: <span id="time"></span></p>

  <div class="card">
    <h2>Pipeline Status</h2>
    <table>
      <thead>
        <tr>
          <th>Stage</th>
          <th>Status</th>
          <th>Details</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Unit Tests</td>
          <td id="unit-status">-</td>
          <td><a href="#" onclick="alert('See latest report folder')">View Log</a></td>
        </tr>
        <tr>
          <td>API Tests (Playwright)</td>
          <td id="api-status">-</td>
          <td><a href="playwright-report/index.html" target="_blank">Open Report</a></td>
        </tr>
        <tr>
          <td>E2E UI Tests (Playwright)</td>
          <td id="e2e-status">-</td>
          <td><a href="playwright-report/index.html" target="_blank">Open Report</a></td>
        </tr>
      </tbody>
    </table>
  </div>

  <div class="card">
    <h2>How to run the pipeline</h2>
    <pre style="background:#0f172a; padding:1rem; border-radius:8px;">
cd ~/frappe-bench/apps/note_app
./run-ci.sh
    </pre>
  </div>

  <script>
    document.getElementById('time').textContent = new Date().toLocaleString();
  </script>
</body>
</html>
HTML

echo "Dashboard created: $DASHBOARD"
echo "Open it with: xdg-open $DASHBOARD"
