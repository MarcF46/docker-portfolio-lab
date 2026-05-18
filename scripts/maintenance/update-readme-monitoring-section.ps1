<#
.SYNOPSIS
  Aktualisiert die README nach erfolgreicher Monitoring-Lab-Einrichtung.

.DESCRIPTION
  Dieses Skript ergänzt die README.md sachlich und portfolio-tauglich:
  - Monitoring wird als vorhandener Projektbestandteil erwähnt.
  - Prometheus, Grafana und cAdvisor werden kurz erklärt.
  - Die Lab-vs-Produktion-Tabelle bleibt ehrlich abgegrenzt.
  - Der geplante Ausbau wird angepasst, damit Monitoring nicht mehr als "geplant" wirkt.

  Das Skript ist idempotent:
  - Wenn der Abschnitt bereits existiert, wird er nicht doppelt eingefügt.
  - Es schreibt nur README.md.
#>

$ErrorActionPreference = "Stop"

# Ermittelt den Projektordner.
# Das Skript liegt in scripts\maintenance.
# Von dort gehen wir zwei Ebenen nach oben in die Projektwurzel.
$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptLocation "..\..")

# Wechselt in die Projektwurzel.
Set-Location $ProjectRoot

$ReadmePath = ".\README.md"

if (-not (Test-Path $ReadmePath)) {
    throw "README.md wurde nicht gefunden. Bitte prüfe den Projektordner."
}

Write-Host ""
Write-Host "=== README Monitoring-Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

# README vollständig einlesen.
$Readme = Get-Content $ReadmePath -Raw

# Aktualisiert die Projektumfang-Tabelle, falls dort noch kein Monitoring-Eintrag existiert.
$AnchorProjectScope = "| Terminal-Session-Logging-Dokumentation | vorhanden |"
$MonitoringScopeLine = "| Monitoring-Lab mit Prometheus, Grafana und cAdvisor | vorhanden |"

if ($Readme.Contains($MonitoringScopeLine)) {
    Write-Host "[INFO] Monitoring ist in der Projektumfang-Tabelle bereits vorhanden."
}
elseif ($Readme.Contains($AnchorProjectScope)) {
    $Readme = $Readme.Replace($AnchorProjectScope, "$AnchorProjectScope`r`n$MonitoringScopeLine")
    Write-Host "[OK] Monitoring in der Projektumfang-Tabelle ergänzt."
}
else {
    Write-Host "[WARN] Tabellenanker für Projektumfang nicht gefunden. Tabelle wurde nicht ergänzt."
}

# Fügt einen eigenen Monitoring-Abschnitt ein.
# Der Abschnitt wird vor dem GitHub-Actions-CI-Abschnitt eingefügt, falls dieser existiert.
$MonitoringSection = @'

## Monitoring mit Prometheus und Grafana

Das Projekt enthält ein kleines, bewusst begrenztes Monitoring-Lab:

```text
compose.monitoring.yml
```

Es ergänzt den produktionsnahen Stack um:

```text
Prometheus
Grafana
cAdvisor
```

Die Aufgabe der Komponenten:

| Komponente | Aufgabe im Lab |
|---|---|
| Prometheus | sammelt Metriken |
| Grafana | visualisiert Metriken in Dashboards |
| cAdvisor | stellt Container-Metriken bereit |

Lokale Weboberflächen:

| Tool | URL |
|---|---|
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| cAdvisor | http://localhost:8085 |

Der Monitoring-Stack wird zusammen mit dem produktionsnahen Stack gestartet:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml up -d --build
```

Verifikation:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml ps
Invoke-WebRequest -Uri http://localhost:9090/-/ready -UseBasicParsing
Invoke-WebRequest -Uri http://localhost:3000/api/health -UseBasicParsing
Invoke-WebRequest -Uri http://localhost:8085/metrics -UseBasicParsing
```

Im lokalen Lab wurden Prometheus und cAdvisor als `UP` erkannt. Grafana konnte das automatisch provisionierte Dashboard `Docker Portfolio Lab Overview` anzeigen.

Wichtige Einordnung:

```text
Das Monitoring-Lab zeigt die Grundidee von Metriken, Targets und Dashboards.
Es ist keine vollständige produktionsreife Observability-Plattform.
```

In Produktion wären zusätzlich nötig:

```text
Authentifizierung
TLS/HTTPS
Rollen- und Rechtekonzept
Alerting
Retention-Konzept
zentrale oder hochverfügbare Speicherung
sichere Netzwerkfreigaben
```

Dokumentation:

```text
docs/operations/monitoring-prometheus-grafana.md
```

'@

if ($Readme -match '(?m)^## Monitoring mit Prometheus und Grafana\s*$') {
    Write-Host "[INFO] Abschnitt 'Monitoring mit Prometheus und Grafana' existiert bereits. Kein doppeltes Einfügen."
}
elseif ($Readme -match '(?m)^## GitHub Actions CI\s*$') {
    $Readme = $Readme -replace '(?m)^## GitHub Actions CI\s*$', ($MonitoringSection.TrimEnd() + "`r`n`r`n## GitHub Actions CI")
    Write-Host "[OK] Monitoring-Abschnitt vor GitHub Actions CI eingefügt."
}
elseif ($Readme -match '(?m)^## Dokumentation\s*$') {
    $Readme = $Readme -replace '(?m)^## Dokumentation\s*$', ($MonitoringSection.TrimEnd() + "`r`n`r`n## Dokumentation")
    Write-Host "[OK] Monitoring-Abschnitt vor Dokumentation eingefügt."
}
else {
    throw "Weder '## GitHub Actions CI' noch '## Dokumentation' wurde gefunden. Bitte README manuell prüfen."
}

# Geplanten Ausbau anpassen, falls Monitoring dort noch als geplanter Punkt steht.
$OldPlannedMonitoring = "einfaches Monitoring mit Prometheus/Grafana"
$NewPlannedMonitoring = "Monitoring-Fehlerübungen und erste Alerting-Grundlagen"

if ($Readme.Contains($OldPlannedMonitoring)) {
    $Readme = $Readme.Replace($OldPlannedMonitoring, $NewPlannedMonitoring)
    Write-Host "[OK] Geplanten Ausbau angepasst: Monitoring ist nicht mehr nur geplant."
}
else {
    Write-Host "[INFO] Alter geplanter Monitoring-Punkt nicht gefunden oder bereits angepasst."
}

# README zurückschreiben.
Set-Content -Path $ReadmePath -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\README.md -Pattern 'Monitoring mit Prometheus', 'compose.monitoring.yml', 'cAdvisor', 'Grafana', 'Prometheus'"
Write-Host "  git diff --stat README.md"
Write-Host ""
