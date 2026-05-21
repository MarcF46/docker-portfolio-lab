<#
.SYNOPSIS
  Aktualisiert docs/operations/README.md nach der cAdvisor-Stopp Incident-Simulation.

.DESCRIPTION
  Dieses Skript ergänzt die Operations-Dokumentationsübersicht:
  - Tabellenzeile für incident-simulation-cadvisor-stopped.md
  - Abschnitt "Incident-Simulation: cAdvisor gestoppt"

  Zweck:
  Die neue cAdvisor-Simulation soll in der zentralen Operations-Übersicht auffindbar sein.

  Das Skript ist idempotent:
  - Vorhandene Tabellenzeilen werden nicht doppelt eingefügt.
  - Vorhandene Abschnitte werden nicht doppelt eingefügt.
#>

$ErrorActionPreference = "Stop"

# Das Skript liegt in scripts\maintenance.
# Von dort gehen wir zwei Ebenen nach oben in die Projektwurzel.
$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptLocation "..\..")
Set-Location $ProjectRoot

$Path = ".\docs\operations\README.md"

if (-not (Test-Path $Path)) {
    throw "docs/operations/README.md wurde nicht gefunden."
}

Write-Host ""
Write-Host "=== Operations-README cAdvisor-Incident-Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Readme = Get-Content $Path -Raw

$GrafanaLine = "| incident-simulation-grafana-stopped.md | Grafana-Stopp Incident-Simulation | Ausfall der Monitoring-Visualisierung bei weiterhin laufender App und Metrikerfassung |"
$PrometheusLine = "| incident-simulation-prometheus-stopped.md | Prometheus-Stopp Incident-Simulation | Monitoring-Ausfall, App-Readiness vs. Operations-Readiness |"
$RedisLine = "| incident-simulation-redis-stopped.md | Redis-Stopp Incident-Simulation | kontrollierter Redis-Ausfall, Erkennung, Behebung und Verifikation |"

$CadvisorLine = "| incident-simulation-cadvisor-stopped.md | cAdvisor-Stopp Incident-Simulation | Ausfall der Container-Metrikquelle bei weiterhin laufender App |"

# 1) Tabellenzeile ergänzen.
if ($Readme.Contains($CadvisorLine)) {
    Write-Host "[INFO] cAdvisor-Tabellenzeile ist bereits vorhanden."
}
elseif ($Readme.Contains($GrafanaLine)) {
    $Readme = $Readme.Replace($GrafanaLine, "$GrafanaLine`r`n$CadvisorLine")
    Write-Host "[OK] cAdvisor-Tabellenzeile nach Grafana-Zeile eingefügt."
}
elseif ($Readme.Contains($PrometheusLine)) {
    $Readme = $Readme.Replace($PrometheusLine, "$PrometheusLine`r`n$CadvisorLine")
    Write-Host "[OK] cAdvisor-Tabellenzeile nach Prometheus-Zeile eingefügt."
}
elseif ($Readme.Contains($RedisLine)) {
    $Readme = $Readme.Replace($RedisLine, "$RedisLine`r`n$CadvisorLine")
    Write-Host "[OK] cAdvisor-Tabellenzeile nach Redis-Zeile eingefügt."
}
else {
    throw "Kein Tabellenanker gefunden. Erwartet wurde eine vorhandene Incident-Simulationszeile."
}

# 2) Abschnitt ergänzen.
$CadvisorSection = @'

### Incident-Simulation: cAdvisor gestoppt

Relevantes Dokument:

```text
incident-simulation-cadvisor-stopped.md
```

Gezeigte Fähigkeiten:

```text
cAdvisor-Ausfall kontrolliert auslösen
Container-Metrikquelle als betroffenen Bereich erkennen
Daily-Operations-Check auswerten
App-Readiness und Container-Metrikerfassung unterscheiden
cAdvisor wiederherstellen
Fix verifizieren
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Einordnung:

```text
Die Simulation zeigt, dass Web und Redis fachlich bereit bleiben können,
während cAdvisor als Container-Metrikquelle nicht verfügbar ist.
```

Wichtige Erkenntnis:

```text
Ohne cAdvisor fehlen Container-Metriken,
obwohl Web, Redis, Prometheus und Grafana weiter laufen können.
```

'@

if ($Readme -match '(?m)^### Incident-Simulation: cAdvisor gestoppt\s*$') {
    Write-Host "[INFO] Abschnitt 'Incident-Simulation: cAdvisor gestoppt' ist bereits vorhanden."
}
elseif ($Readme -match '(?m)^### Incident-Simulation: Grafana gestoppt\s*$') {
    $Readme = $Readme -replace '(?m)^### Incident-Simulation: Grafana gestoppt\s*$', ($CadvisorSection.TrimEnd() + "`r`n`r`n### Incident-Simulation: Grafana gestoppt")
    Write-Host "[OK] cAdvisor-Abschnitt vor Grafana-Abschnitt eingefügt."
}
elseif ($Readme -match '(?m)^### Incident-Simulation: Prometheus gestoppt\s*$') {
    $Readme = $Readme -replace '(?m)^### Incident-Simulation: Prometheus gestoppt\s*$', ($CadvisorSection.TrimEnd() + "`r`n`r`n### Incident-Simulation: Prometheus gestoppt")
    Write-Host "[OK] cAdvisor-Abschnitt vor Prometheus-Abschnitt eingefügt."
}
else {
    throw "Kein Abschnittsanker gefunden. Erwartet wurde Grafana- oder Prometheus-Incident-Abschnitt."
}

Set-Content -Path $Path -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] docs/operations/README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\docs\operations\README.md -Pattern 'incident-simulation-cadvisor-stopped.md', 'cAdvisor-Stopp Incident-Simulation', 'Incident-Simulation: cAdvisor gestoppt', 'Container-Metrikquelle'"
Write-Host "  git diff --stat docs/operations/README.md"
Write-Host ""
