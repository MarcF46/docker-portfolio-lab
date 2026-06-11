$ErrorActionPreference = 'Stop'

# Adds a Docker Compose healthcheck to the reverse-proxy service in compose.proxy.yml.
# Safe behavior:
# - creates a timestamped backup first
# - does nothing if a healthcheck already exists in the reverse-proxy service
# - inserts the healthcheck directly before "restart: unless-stopped"

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir = Split-Path -Parent $ScriptPath
$ProjectRoot = Split-Path -Parent $ScriptDir
$ComposePath = Join-Path $ProjectRoot 'compose.proxy.yml'

if (-not (Test-Path $ComposePath)) {
    $ComposePath = Join-Path (Get-Location) 'compose.proxy.yml'
}

if (-not (Test-Path $ComposePath)) {
    throw 'compose.proxy.yml was not found. Put this script into C:\Docker Uebung\scripts or run it from C:\Docker Uebung.'
}

$Lines = [System.IO.File]::ReadAllLines($ComposePath)

$ServiceStart = -1
for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match '^  reverse-proxy:\s*$') {
        $ServiceStart = $i
        break
    }
}

if ($ServiceStart -lt 0) {
    throw 'Service reverse-proxy was not found in compose.proxy.yml.'
}

$ServiceEnd = $Lines.Count
for ($i = $ServiceStart + 1; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match '^  [A-Za-z0-9._-]+:\s*$') {
        $ServiceEnd = $i
        break
    }
}

for ($i = $ServiceStart; $i -lt $ServiceEnd; $i++) {
    if ($Lines[$i] -match '^    healthcheck:\s*$') {
        Write-Host 'OK: reverse-proxy already has a healthcheck. No change made.'
        exit 0
    }
}

$InsertIndex = -1
for ($i = $ServiceStart; $i -lt $ServiceEnd; $i++) {
    if ($Lines[$i] -match '^    restart:\s*') {
        $InsertIndex = $i
        break
    }
}

if ($InsertIndex -lt 0) {
    throw 'Could not find "restart:" inside reverse-proxy service. No change made.'
}

$HealthcheckText = @'

    # Checks whether the HTTPS reverse proxy responds inside the container.
    # For this local lab, the self-signed certificate is accepted intentionally.
    healthcheck:
      test: ["CMD-SHELL", "wget --no-check-certificate --quiet --tries=1 --spider https://127.0.0.1/ || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 15s
'@

$HealthcheckLines = [System.Text.RegularExpressions.Regex]::Split($HealthcheckText.TrimEnd(), '\r?\n')

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupPath = "$ComposePath.backup-$Timestamp"
Copy-Item -Path $ComposePath -Destination $BackupPath -Force

$NewLines = New-Object System.Collections.Generic.List[string]

for ($i = 0; $i -lt $InsertIndex; $i++) {
    $NewLines.Add($Lines[$i])
}

foreach ($line in $HealthcheckLines) {
    $NewLines.Add($line)
}

for ($i = $InsertIndex; $i -lt $Lines.Count; $i++) {
    $NewLines.Add($Lines[$i])
}

$Utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllLines($ComposePath, $NewLines, $Utf8NoBom)

Write-Host 'OK: Healthcheck was added to compose.proxy.yml.'
Write-Host "Backup created: $BackupPath"
Write-Host 'Next check: git diff -- compose.proxy.yml'
