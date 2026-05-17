<#
.SYNOPSIS
  Simuliert einen Redis-Laufzeitausfall und protokolliert jeden Schritt mit Zeitstempel.

.DESCRIPTION
  Dieses Skript gehört zum Docker-/DevOps-Lernprojekt.
  Es zeigt kontrolliert, was passiert, wenn der Redis-Prozess im laufenden Betrieb beendet wird.

  Lernziele:
  - Unterschied zwischen Start-Abhängigkeit und Laufzeit-Ausfall verstehen
  - Restart Policy praktisch prüfen
  - Healthcheck-Zustände beobachten
  - RestartCount als technischen Nachweis nutzen
  - Ausgaben mit Timestamps für bessere Incident-Nachvollziehbarkeit versehen

.SECURITY
  Dieses Skript verwendet REDISCLI_AUTH statt "redis-cli -a".
  Dadurch wird die Redis-Warnung zur Passwortübergabe über die CLI vermieden.
  Trotzdem gilt: Terminal-Ausgaben und Logs können sensible Informationen enthalten.
#>

# Fehler sollen nicht still ignoriert werden.
# Wenn ein wichtiger Befehl fehlschlägt, soll das Skript abbrechen.
$ErrorActionPreference = "Stop"

# Pfad zur produktionsnahen Compose-Datei.
# Diese Datei definiert den Redis- und Web-Service.
$ComposeFile = "compose.prod.yml"

# Erwarteter Redis-Containername im aktuellen Compose-Projekt.
# In deinem Lab heißt der Container aktuell dockerbung-redis-1.
$RedisContainer = "dockerbung-redis-1"

# Redis-Passwort aus der Umgebung lesen.
# Falls keine Umgebungsvariable gesetzt ist, wird der bekannte Lab-Fallback verwendet.
# SECURITY: In echter Production kein Fallback-Passwort verwenden.
$RedisPassword = $env:REDIS_PASSWORD
if ([string]::IsNullOrWhiteSpace($RedisPassword)) {
    $RedisPassword = "local_redis_password_please_change"
}

# Gibt eine Meldung mit Zeitstempel aus.
# Dadurch ist später besser nachvollziehbar, wann welcher Schritt gelaufen ist.
function Write-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] $Message" -ForegroundColor Cyan
}

# Gibt eine normale Info-Meldung mit Zeitstempel aus.
function Write-Info {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] $Message"
}

Write-Host ""
Write-Host "=== Redis-Laufzeitausfall-Simulation mit Timestamps ===" -ForegroundColor Green
Write-Host ""

Write-Step "1) Ausgangszustand prüfen"
Write-Info "Grund: Vor jeder Incident-Simulation brauchen wir einen bekannten Startzustand."
docker compose -f $ComposeFile ps

Write-Host ""
Write-Step "2) Redis vorsichtshalber starten"
Write-Info "Grund: Die Crash-Simulation ist nur sinnvoll, wenn Redis vorher läuft."
docker compose -f $ComposeFile start redis | Out-Host

Write-Host ""
Write-Step "3) 15 Sekunden warten, bis Redis healthy werden kann"
Write-Info "Grund: Redis und der Healthcheck brauchen nach einem Start kurz Zeit."
Start-Sleep -Seconds 15

Write-Host ""
Write-Step "4) Status nach Redis-Start prüfen"
Write-Info "Erwartung: Redis und Web sollten Up/healthy sein."
docker compose -f $ComposeFile ps

Write-Host ""
Write-Step "5) RestartCount VOR dem simulierten Redis-Ausfall prüfen"
Write-Info "Grund: Dieser Wert ist unser technischer Vorher-Nachher-Beweis."
$RestartCountBefore = docker inspect $RedisContainer --format '{{.RestartCount}}'
Write-Host "RestartCount VORHER: $RestartCountBefore"

Write-Host ""
Write-Step "6) Redis-Prozess im Container per SHUTDOWN NOSAVE beenden"
Write-Info "Grund: Wir simulieren einen Prozessausfall innerhalb des Containers."
Write-Info "SECURITY: REDISCLI_AUTH wird genutzt, damit redis-cli das Passwort nicht per -a bekommt."
docker exec --env "REDISCLI_AUTH=$RedisPassword" $RedisContainer redis-cli SHUTDOWN NOSAVE

Write-Host ""
Write-Step "7) 20 Sekunden warten, damit Docker Recovery + Healthcheck durchführen kann"
Write-Info "Grund: restart: unless-stopped braucht etwas Zeit, um Redis wieder zu starten."
Start-Sleep -Seconds 20

Write-Host ""
Write-Step "8) Status NACH dem simulierten Redis-Ausfall prüfen"
Write-Info "Erwartung: Redis ist wieder Up/healthy, Web läuft weiter."
docker compose -f $ComposeFile ps

Write-Host ""
Write-Step "9) RestartCount NACH dem simulierten Redis-Ausfall prüfen"
Write-Info "Grund: Wenn der Wert gestiegen ist, hat Docker den Container neu gestartet."
$RestartCountAfter = docker inspect $RedisContainer --format '{{.RestartCount}}'
Write-Host "RestartCount NACHHER: $RestartCountAfter"

Write-Host ""
Write-Step "10) Redis-Logs prüfen"
Write-Info "Grund: Logs zeigen, ob Redis nach dem Ausfall wieder gestartet und bereit wurde."
docker compose -f $ComposeFile logs --tail=40 redis

Write-Host ""
Write-Step "11) Ergebnis bewerten"

if ([int]$RestartCountAfter -gt [int]$RestartCountBefore) {
    Write-Host "[OK] RestartCount ist gestiegen: $RestartCountBefore -> $RestartCountAfter" -ForegroundColor Green
    Write-Host "[OK] Die Restart Policy hat bei diesem simulierten Ausfall gegriffen." -ForegroundColor Green
}
else {
    Write-Host "[WARNUNG] RestartCount ist nicht gestiegen: $RestartCountBefore -> $RestartCountAfter" -ForegroundColor Yellow
    Write-Host "[WARNUNG] Prüfe, ob Redis wirklich beendet wurde oder ob der Containername stimmt." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Simulation beendet ===" -ForegroundColor Green
Write-Host ""
Write-Host "Betriebliche Einordnung:"
Write-Host "- Wenn Redis wieder Up/healthy ist und RestartCount gestiegen ist, wurde Recovery nachgewiesen."
Write-Host "- Wenn Web weiterhin healthy ist, prüft der Web-Healthcheck aktuell nur Nginx, nicht Redis."
Write-Host "- Das führt zur nächsten Lerneinheit: fachliche Readiness Checks."
Write-Host ""
Write-Host "Security-Hinweis:"
Write-Host "- Terminal-Logs und Transcripts können sensible Informationen enthalten."
Write-Host "- Nicht unkontrolliert teilen, nicht committen, vor Weitergabe auf Secrets prüfen."
