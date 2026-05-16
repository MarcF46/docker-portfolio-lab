# scripts/simulate-runtime-redis-outage.ps1
# Zweck:
# - simuliert einen Redis-Ausfall nach erfolgreichem Stack-Start
# - zeigt den Unterschied zwischen geplantem Stop und hartem Crash
# - prüft, ob restart: unless-stopped Redis nach einem Crash wieder startet
# - verändert keine Dateien und löscht keine Volumes

param(
    # Wenn dieser Schalter gesetzt ist, wird Redis nach dem geplanten Stop nicht automatisch wieder gestartet.
    # Normalerweise brauchst du diesen Schalter nicht.
    [switch]$NoRestoreAfterPlannedStop
)

$ErrorActionPreference = "Stop"

$ComposeFile = "compose.prod.yml"
$RedisContainer = "dockerbung-redis-1"

function Write-Step {
    param(
        [string]$Title
    )

    Write-Host ""
    Write-Host "============================================================"
    Write-Host $Title
    Write-Host "============================================================"
}

function Run-Command {
    param(
        [string]$Command
    )

    Write-Host ""
    Write-Host "Befehl: $Command"
    Invoke-Expression $Command
}

if (-not (Test-Path $ComposeFile)) {
    throw "Die Datei $ComposeFile wurde nicht gefunden. Bitte das Skript aus dem Projektordner ausführen: C:\Docker Übung"
}

Write-Step "Baseline: aktueller Stack-Status"
Run-Command "docker compose -f $ComposeFile ps"

Write-Step "Restart Count vor der Crash-Simulation merken"
Run-Command "docker inspect $RedisContainer --format '{{.RestartCount}}'"

Write-Step "Simulation A: Redis geplant stoppen"
Run-Command "docker compose -f $ComposeFile stop redis"
Start-Sleep -Seconds 5

Write-Step "Prüfen: Redis sollte gestoppt sein, web sollte weiterlaufen"
Run-Command "docker compose -f $ComposeFile ps -a"
Run-Command "docker compose -f $ComposeFile ps web"
Run-Command "docker compose -f $ComposeFile logs --tail=30 redis"

if (-not $NoRestoreAfterPlannedStop) {
    Write-Step "Fix: Redis nach geplantem Stop wieder starten"
    Run-Command "docker compose -f $ComposeFile start redis"
    Start-Sleep -Seconds 15
    Run-Command "docker compose -f $ComposeFile ps"
}

Write-Step "Simulation B: Redis hart beenden"
Write-Host "Hinweis: docker kill simuliert einen abrupten Container-Ausfall im Lab."
Run-Command "docker kill $RedisContainer"
Start-Sleep -Seconds 15

Write-Step "Prüfen: Redis sollte durch restart: unless-stopped wieder laufen"
Run-Command "docker compose -f $ComposeFile ps"
Run-Command "docker inspect $RedisContainer --format '{{.RestartCount}}'"
Run-Command "docker compose -f $ComposeFile logs --tail=40 redis"

Write-Step "Abschluss"
Write-Host "Wenn Redis wieder healthy ist und der Restart Count gestiegen ist, wurde die Recovery durch die Restart Policy nachgewiesen."
Write-Host "Wenn web weiterhin healthy bleibt, zeigt das: Der aktuelle Web-Healthcheck prüft nur Nginx, nicht die Redis-Abhängigkeit."
