<#
.SYNOPSIS
  Farbiger Daily-Operations-Check für das Docker Portfolio Lab.

.DESCRIPTION
  Dieses Skript ist ein lernfreundlicher Betriebscheck.
  Es prüft Git, Docker Compose, Containerstatus, Readiness, HTTP-Endpunkte,
  Secret-Ignore-Regeln und eine kleine Logauswertung.

  Ziel:
  Schnell sehen, ob das Lab betriebsbereit ist, ohne rohe Docker-Ausgaben komplett selbst auswerten zu müssen.
#>

# Stoppt das Skript bei echten PowerShell-Fehlern.
$ErrorActionPreference = "Stop"

# Ergebniszähler für die Abschlussbewertung.
$script:OkCount = 0
$script:WarnCount = 0
$script:ErrorCount = 0

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "=== $Title ===" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    $script:OkCount++
    Write-Host "[OK]    $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    $script:WarnCount++
    Write-Host "[WARN]  $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    $script:ErrorCount++
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Invoke-SafeCommand {
    param(
        [string]$Description,
        [scriptblock]$Command
    )

    try {
        & $Command
        Write-Ok $Description
        return $true
    }
    catch {
        Write-Fail "$Description fehlgeschlagen: $($_.Exception.Message)"
        return $false
    }
}

# Ermittelt den Projektordner.
# Das Skript liegt in scripts\tests.
# Von dort gehen wir zwei Ebenen nach oben in die Projektwurzel.
$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptLocation "..\..")

# Wechselt in die Projektwurzel.
Set-Location $ProjectRoot

# Definiert die Compose-Dateien an einer zentralen Stelle.
# Dadurch muss der lange Compose-Befehl nicht überall neu geschrieben werden.
$ComposeFiles = @(
    "-f", ".\compose.prod.yml",
    "-f", ".\compose.monitoring.yml"
)

# Erwartete Services im Lab.
$ExpectedServices = @(
    "web",
    "redis",
    "prometheus",
    "grafana",
    "cadvisor"
)

Write-Host ""
Write-Host "Daily Operations Check" -ForegroundColor White
Write-Host "Projektordner: $ProjectRoot" -ForegroundColor DarkGray
Write-Host "Zeitpunkt: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor DarkGray

Write-Section "1) Git-Zustand pruefen"

try {
    # Prüft, ob wir uns in einem Git-Repository befinden.
    git rev-parse --is-inside-work-tree *> $null

    # git status --porcelain ist für Skripte besser auswertbar als normaler Git-Status.
    $GitChanges = git status --porcelain

    if ([string]::IsNullOrWhiteSpace($GitChanges)) {
        Write-Ok "Git-Arbeitsverzeichnis ist sauber."
    }
    else {
        Write-Warn "Git-Arbeitsverzeichnis hat offene Änderungen:"
        $GitChanges | ForEach-Object {
            Write-Host "        $_" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Fail "Git konnte nicht geprüft werden: $($_.Exception.Message)"
}

Write-Section "2) Docker Compose Konfiguration pruefen"

# docker compose config prüft, ob beide Compose-Dateien zusammen lesbar sind.
# Die Ausgabe wird unterdrückt, weil hier nur der Erfolg interessiert.
Invoke-SafeCommand `
    -Description "Docker Compose kann compose.prod.yml + compose.monitoring.yml lesen" `
    -Command {
        docker compose @ComposeFiles config *> $null
    } | Out-Null

Write-Section "3) Stackstatus anzeigen"

try {
    # Zeigt den Compose-Status sichtbar an.
    docker compose @ComposeFiles ps

    # JSON-Ausgabe wird zusätzlich für maschinelle Prüfung genutzt.
    $PsJsonRaw = docker compose @ComposeFiles ps --format json

    if ([string]::IsNullOrWhiteSpace($PsJsonRaw)) {
        Write-Warn "Docker Compose ps liefert keine Container. Ist der Stack gestoppt?"
        $PsItems = @()
    }
    else {
        $PsItems = $PsJsonRaw | ConvertFrom-Json
        if ($null -eq $PsItems) {
            $PsItems = @()
        }
        elseif ($PsItems -isnot [System.Array]) {
            $PsItems = @($PsItems)
        }
    }

    foreach ($Service in $ExpectedServices) {
        $Match = $PsItems | Where-Object { $_.Service -eq $Service } | Select-Object -First 1

        if ($null -eq $Match) {
            Write-Fail "Service '$Service' wurde im Compose-Status nicht gefunden."
            continue
        }

        $StateText = "$($Match.State) $($Match.Health)"

        if ($StateText -match "healthy") {
            Write-Ok "Service '$Service' ist healthy."
        }
        elseif ($StateText -match "running|Up") {
            Write-Warn "Service '$Service' laeuft, aber Health-Status ist nicht eindeutig: $StateText"
        }
        else {
            Write-Fail "Service '$Service' ist nicht gesund: $StateText"
        }
    }
}
catch {
    Write-Fail "Stackstatus konnte nicht ausgewertet werden: $($_.Exception.Message)"
}

Write-Section "4) Fachliche Readiness pruefen"

$ReadinessScript = ".\scripts\tests\test-stack-readiness.ps1"

if (Test-Path $ReadinessScript) {
    try {
        # Führt den vorhandenen Readiness-Check aus.
        # Dieser prüft Web über HTTP und Redis per PING.
        & $ReadinessScript

        if ($LASTEXITCODE -eq 0 -or $null -eq $LASTEXITCODE) {
            Write-Ok "Readiness-Check wurde ausgefuehrt."
        }
        else {
            Write-Fail "Readiness-Check meldete Exit-Code $LASTEXITCODE."
        }
    }
    catch {
        Write-Fail "Readiness-Check konnte nicht ausgefuehrt werden: $($_.Exception.Message)"
        Write-Warn "Falls PowerShell Skripte blockiert: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass"
    }
}
else {
    Write-Fail "Readiness-Skript wurde nicht gefunden: $ReadinessScript"
}

Write-Section "5) HTTP-Endpunkte pruefen"

# Prüft die lokale Web-App.
Invoke-SafeCommand `
    -Description "Web-App antwortet auf http://localhost:8082" `
    -Command {
        $Response = Invoke-WebRequest -Uri "http://localhost:8082" -UseBasicParsing -TimeoutSec 5
        if ($Response.StatusCode -ne 200) {
            throw "HTTP Status $($Response.StatusCode)"
        }
    } | Out-Null

# Prüft Prometheus Readiness.
Invoke-SafeCommand `
    -Description "Prometheus ist ready" `
    -Command {
        $Response = Invoke-WebRequest -Uri "http://localhost:9090/-/ready" -UseBasicParsing -TimeoutSec 5
        if ($Response.StatusCode -ne 200) {
            throw "HTTP Status $($Response.StatusCode)"
        }
    } | Out-Null

# Prüft Grafana Health.
Invoke-SafeCommand `
    -Description "Grafana Health API antwortet" `
    -Command {
        $Response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -UseBasicParsing -TimeoutSec 5
        if ($Response.StatusCode -ne 200) {
            throw "HTTP Status $($Response.StatusCode)"
        }
    } | Out-Null

# Prüft cAdvisor Metrics.
Invoke-SafeCommand `
    -Description "cAdvisor liefert Metriken" `
    -Command {
        $Response = Invoke-WebRequest -Uri "http://localhost:8085/metrics" -UseBasicParsing -TimeoutSec 5
        if ($Response.StatusCode -ne 200) {
            throw "HTTP Status $($Response.StatusCode)"
        }
    } | Out-Null

Write-Section "6) Secrets pruefen"

$SecretFiles = @(
    "secrets/redis_password.txt",
    "secrets/grafana_admin_password.txt"
)

foreach ($Secret in $SecretFiles) {
    try {
        # git check-ignore -q gibt Exit-Code 0 zurück, wenn die Datei ignoriert wird.
        git check-ignore -q $Secret

        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Secret-Datei wird von Git ignoriert: $Secret"
        }
        else {
            Write-Fail "Secret-Datei wird NICHT von Git ignoriert: $Secret"
        }
    }
    catch {
        Write-Fail "Secret-Pruefung fehlgeschlagen fuer $Secret : $($_.Exception.Message)"
    }
}

Write-Section "7) Kurze Log-Einordnung"

try {
    # Holt eine begrenzte Logmenge.
    # Das verhindert, dass VS Code durch sehr große Terminalausgaben langsam wird.
    $LogLines = docker compose @ComposeFiles logs --tail=30

    # Bekannte cAdvisor-Hinweise unter Docker Desktop / WSL2.
    $KnownCadvisorHints = $LogLines | Where-Object {
        $_ -match "cadvisor" -and (
            $_ -match "machine-id" -or
            $_ -match "system UUID" -or
            $_ -match "product_name"
        )
    }

    if ($KnownCadvisorHints.Count -gt 0) {
        Write-Warn "Bekannte cAdvisor-/WSL2-Hinweise gefunden. Im Lab meist nicht fatal, wenn cAdvisor healthy ist."
    }
    else {
        Write-Ok "Keine bekannten cAdvisor-/WSL2-Hinweise in den letzten Logs gefunden."
    }

    # Kritische Muster grob suchen.
    # Diese Suche ist bewusst einfach und ersetzt keine echte Loganalyse.
    $CriticalPatterns = @(
        "permission denied",
        "connection refused",
        "unhealthy",
        "panic",
        "fatal"
    )

    $CriticalHits = @()

    foreach ($Pattern in $CriticalPatterns) {
        $CriticalHits += $LogLines | Where-Object { $_ -match $Pattern }
    }

    if ($CriticalHits.Count -gt 0) {
        Write-Warn "Moegliche kritische Logmuster gefunden. Bitte manuell pruefen:"
        $CriticalHits | Select-Object -First 8 | ForEach-Object {
            Write-Host "        $_" -ForegroundColor Yellow
        }
    }
    else {
        Write-Ok "Keine offensichtlichen kritischen Logmuster in den letzten Logs gefunden."
    }
}
catch {
    Write-Warn "Logs konnten nicht vollstaendig ausgewertet werden: $($_.Exception.Message)"
}

Write-Section "8) Abschlussbewertung"

Write-Host "OK:    $script:OkCount" -ForegroundColor Green
Write-Host "WARN:  $script:WarnCount" -ForegroundColor Yellow
Write-Host "ERROR: $script:ErrorCount" -ForegroundColor Red

if ($script:ErrorCount -gt 0) {
    Write-Host ""
    Write-Host "GESAMTSTATUS: NICHT BEREIT - es gibt ERROR-Meldungen." -ForegroundColor Red
    exit 1
}
elseif ($script:WarnCount -gt 0) {
    Write-Host ""
    Write-Host "GESAMTSTATUS: BEREIT MIT HINWEISEN - Warnungen fachlich pruefen." -ForegroundColor Yellow
    exit 0
}
else {
    Write-Host ""
    Write-Host "GESAMTSTATUS: BEREIT - keine Warnungen oder Fehler erkannt." -ForegroundColor Green
    exit 0
}
