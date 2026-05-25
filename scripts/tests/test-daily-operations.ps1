# Daily Operations Check fuer das Docker-Portfolio-Lab
# Zweck:
# - prueft den lokalen Docker-Stack ohne Aenderungen vorzunehmen
# - bewertet Git, Compose, Containerstatus, Readiness, Endpunkte, Secrets und Logs
# - fuehrt KEINE Loesch-, Prune- oder Down-Befehle aus

$ErrorActionPreference = "Continue"

$OkCount = 0
$WarnCount = 0
$ErrorCount = 0

function Write-Section {
    param([string]$Text)

    Write-Host ""
    Write-Host "=== $Text ===" -ForegroundColor Cyan
}

function Add-Ok {
    param([string]$Text)

    $script:OkCount++
    Write-Host ("[OK]    " + $Text) -ForegroundColor Green
}

function Add-Warn {
    param([string]$Text)

    $script:WarnCount++
    Write-Host ("[WARN]  " + $Text) -ForegroundColor Yellow
}

function Add-ErrorCheck {
    param([string]$Text)

    $script:ErrorCount++
    Write-Host ("[ERROR] " + $Text) -ForegroundColor Red
}

function Test-HttpEndpoint {
    param(
        [string]$Name,
        [string]$Uri
    )

    try {
        $response = Invoke-WebRequest -Uri $Uri -UseBasicParsing -TimeoutSec 10

        if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
            Add-Ok "$Name antwortet auf $Uri"
        }
        else {
            Add-Warn "$Name antwortet, aber mit HTTP Status $($response.StatusCode)"
        }
    }
    catch {
        Add-ErrorCheck "$Name ist nicht erreichbar: $($_.Exception.Message)"
    }
}

# Projektwurzel aus Skriptpfad ableiten:
# Skript liegt erwartungsgemaess unter scripts/tests/
$ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Set-Location $ProjectRoot

Write-Host ""
Write-Host "Daily Operations Check" -ForegroundColor White
Write-Host "Projektordner: $ProjectRoot"
Write-Host "Zeitpunkt: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

$ComposeBaseArgs = @("compose", "-f", ".\compose.prod.yml", "-f", ".\compose.monitoring.yml")

Write-Section "1) Git-Zustand pruefen"

$gitStatus = git status --short 2>&1

if ($LASTEXITCODE -ne 0) {
    Add-ErrorCheck "Git-Status konnte nicht gelesen werden: $gitStatus"
}
elseif ([string]::IsNullOrWhiteSpace(($gitStatus | Out-String))) {
    Add-Ok "Git-Arbeitsverzeichnis ist sauber."
}
else {
    Add-Warn "Git hat offene Aenderungen:"
    $gitStatus | ForEach-Object { Write-Host $_ }
}

Write-Section "2) Docker Compose Konfiguration pruefen"

$composeConfig = docker @ComposeBaseArgs config 2>&1

if ($LASTEXITCODE -eq 0) {
    Add-Ok "Docker Compose kann compose.prod.yml + compose.monitoring.yml lesen."
}
else {
    Add-ErrorCheck "Docker Compose Konfiguration konnte nicht gelesen werden."
    $composeConfig | ForEach-Object { Write-Host $_ }
}

Write-Section "3) Stackstatus anzeigen"

$composePs = docker @ComposeBaseArgs ps 2>&1

if ($LASTEXITCODE -ne 0) {
    Add-ErrorCheck "Docker Compose Status konnte nicht gelesen werden."
    $composePs | ForEach-Object { Write-Host $_ }
}
else {
    $composePs | ForEach-Object { Write-Host $_ }

    $requiredServices = @("web", "redis", "prometheus", "grafana", "cadvisor")

    foreach ($service in $requiredServices) {
        $serviceLines = $composePs | Where-Object {
            ($_ -match "\s$service\s") -or ($_ -match "dockerbung-$service-1")
        }

        if (-not $serviceLines -or $serviceLines.Count -eq 0) {
            Add-ErrorCheck "Service '$service' wurde im Compose-Status nicht gefunden."
            continue
        }

        $serviceText = ($serviceLines -join " ")

        if ($serviceText -match "healthy") {
            Add-Ok "Service '$service' ist healthy."
        }
        elseif ($serviceText -match "\bUp\b") {
            Add-Warn "Service '$service' ist Up, aber nicht eindeutig healthy."
        }
        else {
            Add-ErrorCheck "Service '$service' ist nicht Up/healthy."
        }
    }
}

Write-Section "4) Fachliche Readiness pruefen"

# Web pruefen
Test-HttpEndpoint -Name "Web-App" -Uri "http://localhost:8082"

# Redis pruefen, ohne Passwort auf der Kommandozeile auszugeben.
try {
    $redisCommand = 'export REDISCLI_AUTH=$(cat /run/secrets/redis_password); redis-cli ping'
    $redisPing = docker exec dockerbung-redis-1 sh -c $redisCommand 2>&1

    if ($LASTEXITCODE -eq 0 -and (($redisPing | Out-String) -match "PONG")) {
        Add-Ok "Redis antwortet korrekt mit PONG."
    }
    else {
        Add-ErrorCheck "Redis PING war nicht erfolgreich."
        $redisPing | ForEach-Object { Write-Host $_ }
    }
}
catch {
    Add-ErrorCheck "Redis-Pruefung konnte nicht ausgefuehrt werden: $($_.Exception.Message)"
}

Write-Section "5) HTTP-Endpunkte pruefen"

Test-HttpEndpoint -Name "Prometheus Readiness" -Uri "http://localhost:9090/-/ready"
Test-HttpEndpoint -Name "Grafana Health API" -Uri "http://localhost:3000/api/health"
Test-HttpEndpoint -Name "cAdvisor Metrics" -Uri "http://localhost:8085/metrics"

Write-Section "6) Secrets pruefen"

$trackedSecrets = git ls-files .\secrets 2>&1

if ($LASTEXITCODE -ne 0) {
    Add-Warn "Git konnte secrets/ nicht pruefen."
}
else {
    $trackedSecretText = $trackedSecrets | Out-String

    if ($trackedSecretText -match "redis_password.txt" -or $trackedSecretText -match "grafana_admin_password.txt") {
        Add-ErrorCheck "Eine echte Secret-Datei wird von Git verfolgt."
        $trackedSecrets | ForEach-Object { Write-Host $_ }
    }
    else {
        Add-Ok "Keine echte Passwortdatei wird von Git verfolgt."
    }
}

$secretFiles = @(
    ".\secrets\redis_password.txt",
    ".\secrets\grafana_admin_password.txt"
)

foreach ($secretFile in $secretFiles) {
    git check-ignore -q $secretFile

    if ($LASTEXITCODE -eq 0) {
        Add-Ok "Secret-Datei wird von Git ignoriert: $secretFile"
    }
    else {
        Add-ErrorCheck "Secret-Datei wird NICHT von Git ignoriert: $secretFile"
    }
}

Write-Section "7) Kurze Log-Einordnung"

$logs = docker @ComposeBaseArgs logs --tail=120 2>&1

if ($LASTEXITCODE -ne 0) {
    Add-Warn "Logs konnten nicht gelesen werden."
}
else {
    $criticalPatterns = "panic|fatal|segmentation fault|permission denied"
    $criticalLines = $logs | Where-Object { $_ -match $criticalPatterns }

    if ($criticalLines -and $criticalLines.Count -gt 0) {
        Add-ErrorCheck "Kritische Logmuster gefunden."
        $criticalLines | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    }
    else {
        Add-Ok "Keine offensichtlichen kritischen Logmuster in den letzten Logs gefunden."
    }

    $knownCadvisorPatterns = "machine id|resctrl|perf_event|hugetlb|oom|WSL2|failed to get system UUID"
    $knownCadvisorLines = $logs | Where-Object { $_ -match $knownCadvisorPatterns }

    if ($knownCadvisorLines -and $knownCadvisorLines.Count -gt 0) {
        Add-Warn "Bekannte cAdvisor-/Docker-Desktop-/WSL2-Hinweise gefunden. Im Lab meist nicht fatal, wenn cAdvisor healthy ist."
    }
}

Write-Section "8) Abschlussbewertung"

Write-Host ("OK:    " + $OkCount) -ForegroundColor Green
Write-Host ("WARN:  " + $WarnCount) -ForegroundColor Yellow
Write-Host ("ERROR: " + $ErrorCount) -ForegroundColor Red

Write-Host ""

if ($ErrorCount -eq 0 -and $WarnCount -eq 0) {
    Write-Host "GESAMTSTATUS: BEREIT" -ForegroundColor Green
    exit 0
}
elseif ($ErrorCount -eq 0) {
    Write-Host "GESAMTSTATUS: BEREIT MIT HINWEISEN - Warnungen fachlich pruefen." -ForegroundColor Yellow
    exit 0
}
else {
    Write-Host "GESAMTSTATUS: NICHT BEREIT - Fehler beheben und Check erneut ausfuehren." -ForegroundColor Red
    exit 1
}
