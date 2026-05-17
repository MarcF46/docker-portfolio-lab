<#
.SYNOPSIS
  Prüft die fachliche Stack-Readiness des Docker-Labs.

.DESCRIPTION
  Dieses Skript prüft nicht nur, ob Container "laufen", sondern ob die wichtigsten
  Dienste aus Betriebssicht erreichbar sind:

  - Web-Service antwortet über HTTP
  - Redis antwortet mit PONG
  - Docker Compose zeigt den aktuellen Status

  Das Skript ist bewusst als externer Betriebscheck aufgebaut.
  Es verändert keine Container und keine Daten.

.SECURITY
  Redis wird über REDISCLI_AUTH angesprochen.
  Das Passwort wird nicht ausgegeben.
  Terminal-Logs und Transcripts können trotzdem sensible Informationen enthalten.
#>

param(
    # Pfad zur Compose-Datei.
    # Standard: produktionsnahe Compose-Datei des Lernprojekts.
    [string]$ComposeFile = "compose.prod.yml",

    # URL des Webdienstes vom Host aus gesehen.
    # In deinem Lab ist der Webcontainer über localhost:8082 erreichbar.
    [string]$WebUrl = "http://localhost:8082",

    # Name des Redis-Containers.
    # In deinem aktuellen Compose-Projekt heißt er dockerbung-redis-1.
    [string]$RedisContainer = "dockerbung-redis-1"
)

# Fehler sollen nicht still ignoriert werden.
# Bei unerwarteten technischen Fehlern soll das Skript abbrechen.
$ErrorActionPreference = "Stop"

# Redis-Passwort aus der Umgebung lesen.
# Falls keine Variable gesetzt ist, wird der bekannte Lab-Fallback genutzt.
# SECURITY: In echter Produktion kein Fallback-Passwort verwenden.
$RedisPassword = $env:REDIS_PASSWORD
if ([string]::IsNullOrWhiteSpace($RedisPassword)) {
    $RedisPassword = "local_redis_password_please_change"
}

# Hilfsfunktion für Zeitstempel.
# Dadurch wird die Ausgabe später besser als kleine Incident-/Betriebszeitlinie lesbar.
function Get-Timestamp {
    return Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# Gibt einen Schritt mit Zeitstempel aus.
function Write-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[$(Get-Timestamp)] $Message" -ForegroundColor Cyan
}

# Gibt eine OK-Meldung aus.
function Write-Ok {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[$(Get-Timestamp)] [OK] $Message" -ForegroundColor Green
}

# Gibt eine Warn-/Fehlermeldung aus.
function Write-Fail {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "[$(Get-Timestamp)] [FEHLER] $Message" -ForegroundColor Red
}

# Ergebnisvariablen.
# Am Ende entscheidet das Skript anhand dieser Werte, ob der Stack fachlich bereit ist.
$WebReady = $false
$RedisReady = $false

Write-Host ""
Write-Host "=== Stack-Readiness-Check ===" -ForegroundColor Green
Write-Host ""

Write-Step "1) Docker-Compose-Status anzeigen"
Write-Host "Grund: Wir wollen zuerst sehen, ob die Container laufen und welchen Health-Status sie haben."
docker compose -f $ComposeFile ps

Write-Host ""
Write-Step "2) Web-Service ueber HTTP pruefen"
Write-Host "Grund: Ein laufender Webcontainer reicht nicht. Der Webdienst muss auch antworten."
Write-Host "Ziel-URL: $WebUrl"

try {
    # Invoke-WebRequest ruft die Web-App vom Host aus auf.
    # TimeoutSec begrenzt die Wartezeit, damit der Check nicht lange hängt.
    $WebResponse = Invoke-WebRequest -Uri $WebUrl -UseBasicParsing -TimeoutSec 5

    if ($WebResponse.StatusCode -ge 200 -and $WebResponse.StatusCode -lt 400) {
        $WebReady = $true
        Write-Ok "Web-Service antwortet mit HTTP Status $($WebResponse.StatusCode)."
    }
    else {
        Write-Fail "Web-Service antwortet, aber mit unerwartetem HTTP Status $($WebResponse.StatusCode)."
    }
}
catch {
    Write-Fail "Web-Service konnte nicht erreicht werden: $($_.Exception.Message)"
}

Write-Host ""
Write-Step "3) Redis-Service per PING pruefen"
Write-Host "Grund: Redis soll nicht nur als Container laufen, sondern fachlich auf PING mit PONG antworten."
Write-Host "SECURITY: REDISCLI_AUTH wird genutzt; das Passwort wird nicht ausgegeben."

try {
    # docker exec führt redis-cli im Redis-Container aus.
    # REDISCLI_AUTH verhindert die unsichere Passwortübergabe über redis-cli -a.
    $RedisResult = docker exec --env "REDISCLI_AUTH=$RedisPassword" $RedisContainer redis-cli ping

    if ($RedisResult -eq "PONG") {
        $RedisReady = $true
        Write-Ok "Redis antwortet korrekt mit PONG."
    }
    else {
        Write-Fail "Redis antwortet unerwartet: $RedisResult"
    }
}
catch {
    Write-Fail "Redis konnte nicht geprüft werden: $($_.Exception.Message)"
}

Write-Host ""
Write-Step "4) Ergebnis zusammenfassen"

if ($WebReady -and $RedisReady) {
    Write-Ok "Stack ist aus Sicht dieses Readiness-Checks bereit."
    Write-Host ""
    Write-Host "Betriebliche Einordnung:"
    Write-Host "- Web antwortet ueber HTTP."
    Write-Host "- Redis antwortet mit PONG."
    Write-Host "- Dieser Check prueft mehr als nur den Docker-Containerstatus."
    Write-Host ""
    exit 0
}
else {
    Write-Fail "Stack ist aus Sicht dieses Readiness-Checks NICHT bereit."
    Write-Host ""
    Write-Host "Diagnosehinweise:"
    Write-Host "- docker compose -f $ComposeFile ps"
    Write-Host "- docker compose -f $ComposeFile logs --tail=80 web"
    Write-Host "- docker compose -f $ComposeFile logs --tail=80 redis"
    Write-Host "- docker inspect $RedisContainer --format '{{json .State.Health}}'"
    Write-Host ""
    exit 1
}
