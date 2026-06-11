$ErrorActionPreference = 'Stop'

# Adds a Prometheus scrape job for the antenna-simulator service.
# Safe behavior:
# - creates a timestamped backup first
# - does nothing if the job already exists
# - appends a small scrape job to monitoring/prometheus/prometheus.yml

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
if ((Split-Path -Leaf $ProjectRoot) -eq 'scripts') {
    $ProjectRoot = Split-Path -Parent $ProjectRoot
}

$PrometheusPath = Join-Path $ProjectRoot 'monitoring/prometheus/prometheus.yml'

if (-not (Test-Path $PrometheusPath)) {
    throw "Could not find Prometheus config: $PrometheusPath"
}

$Content = Get-Content -Raw -Path $PrometheusPath

if ($Content -match 'job_name:\s*["'']antenna-simulator["'']') {
    Write-Host 'OK: antenna-simulator scrape job already exists. No change needed.'
    exit 0
}

if ($Content -notmatch '(?m)^scrape_configs:\s*$') {
    throw 'Could not find top-level scrape_configs: in Prometheus config. Please inspect the file manually.'
}

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupPath = "$PrometheusPath.backup-$Timestamp"
Copy-Item -Path $PrometheusPath -Destination $BackupPath -Force

$Block = @'

  # Scrapes the local antenna/sensor simulator used for operations training.
  - job_name: "antenna-simulator"
    static_configs:
      - targets: ["antenna-simulator:8000"]
'@

Add-Content -Path $PrometheusPath -Value $Block

Write-Host 'OK: Added antenna-simulator scrape job to monitoring/prometheus/prometheus.yml.'
Write-Host "Backup created: $BackupPath"
Write-Host 'Next check: docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml -f compose.antenna-simulator.yml config --quiet'
