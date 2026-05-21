<#
.SYNOPSIS
  Aktualisiert docs/operations/README.md nach der Grafana-Stopp Incident-Simulation.

.DESCRIPTION
  Dieses Skript ergänzt die Operations-Dokumentationsübersicht:
  - Tabellenzeile für incident-simulation-grafana-stopped.md
  - Abschnitt "Incident-Simulation: Grafana gestoppt"
  - keine privaten Informationen
  - idempotent: vorhandene Einträge werden nicht doppelt eingefügt
#>

$ErrorActionPreference = "Stop"

$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptLocation "..\..")
Set-Location $ProjectRoot

$Path = ".\docs\operations\README.md"

if (-not (Test-Path $Path)) {
    throw "docs/operations/README.md wurde nicht gefunden."
}

Write-Host ""
Write-Host "=== Operations-README Grafana-Incident-Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Readme = Get-Content $Path -Raw

$PrometheusLine = "| incident-simulation-prometheus-stopped.md | Prometheus-Stopp Incident-Simulation | Monitoring-Ausfall, App-Readiness vs. Operations-Readiness |"
$RedisLine = "| incident-simulation-redis-stopped.md | Redis-Stopp Incident-Simulation | kontrollierter Redis-Ausfall, Erkennung, Behebung und Verifikation |"
$GrafanaLine = "| incident-simulation-grafana-stopped.md | Grafana-Stopp Incident-Simulation | Ausfall der Monitoring-Visualisierung bei weiterhin laufender App und Metrikerfassung |"

# 1) Tabellenzeile ergänzen.
if ($Readme.Contains($GrafanaLine)) {
    Write-Host "[INFO] Grafana-Tabellenzeile ist bereits vorhanden."
}
elseif ($Readme.Contains($PrometheusLine)) {
    $Readme = $Readme.Replace($PrometheusLine, "$PrometheusLine`r`n$GrafanaLine")
    Write-Host "[OK] Grafana-Tabellenzeile nach Prometheus-Zeile eingefügt."
}
elseif ($Readme.Contains($RedisLine)) {
    $Readme = $Readme.Replace($RedisLine, "$RedisLine`r`n$GrafanaLine")
    Write-Host "[OK] Grafana-Tabellenzeile nach Redis-Zeile eingefügt."
}
else {
    throw "Kein Tabellenanker gefunden. Erwartet wurde die Prometheus- oder Redis-Zeile."
}

# 2) Abschnitt ergänzen.
$GrafanaSection = @'

### Incident-Simulation: Grafana gestoppt

Relevantes Dokument:

```text
incident-simulation-grafana-stopped.md
```

Gezeigte Fähigkeiten:

```text
Grafana-Ausfall kontrolliert auslösen
Visualisierungsausfall erkennen
Daily-Operations-Check auswerten
App-Readiness und Monitoring-Visualisierung unterscheiden
Grafana wiederherstellen
Fix verifizieren
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Einordnung:

```text
Die Simulation zeigt, dass Web und Redis fachlich bereit bleiben können,
während Grafana als Dashboard- und Visualisierungsschicht nicht verfügbar ist.
```

Wichtige Erkenntnis:

```text
Monitoring-Daten können weiterhin gesammelt werden,
auch wenn die grafische Visualisierung über Grafana gestört ist.
```

'@

if ($Readme -match '(?m)^### Incident-Simulation: Grafana gestoppt\s*$') {
    Write-Host "[INFO] Abschnitt 'Incident-Simulation: Grafana gestoppt' ist bereits vorhanden."
}
elseif ($Readme -match '(?m)^### Incident-Simulation: Prometheus gestoppt\s*$') {
    $Readme = $Readme -replace '(?m)^### Incident-Simulation: Prometheus gestoppt\s*$', ($GrafanaSection.TrimEnd() + "`r`n`r`n### Incident-Simulation: Prometheus gestoppt")
    Write-Host "[OK] Grafana-Abschnitt vor Prometheus-Abschnitt eingefügt."
}
elseif ($Readme -match '(?m)^### Incident-Simulation: Redis gestoppt\s*$') {
    $Readme = $Readme -replace '(?m)^### Incident-Simulation: Redis gestoppt\s*$', ($GrafanaSection.TrimEnd() + "`r`n`r`n### Incident-Simulation: Redis gestoppt")
    Write-Host "[OK] Grafana-Abschnitt vor Redis-Abschnitt eingefügt."
}
else {
    throw "Kein Abschnittsanker gefunden. Erwartet wurde Prometheus- oder Redis-Incident-Abschnitt."
}

Set-Content -Path $Path -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] docs/operations/README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\docs\operations\README.md -Pattern 'incident-simulation-grafana-stopped.md', 'Grafana-Stopp Incident-Simulation', 'Incident-Simulation: Grafana gestoppt', 'Monitoring-Visualisierung'"
Write-Host "  git diff --stat docs/operations/README.md"
Write-Host ""
