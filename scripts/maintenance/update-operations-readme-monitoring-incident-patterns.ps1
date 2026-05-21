<#
.SYNOPSIS
  Aktualisiert docs/operations/README.md nach der Monitoring Incident Patterns Doku.

.DESCRIPTION
  Dieses Skript ergänzt die Operations-Dokumentationsübersicht:
  - Tabellenzeile für monitoring-incident-patterns.md
  - Abschnitt "Monitoring Incident Patterns"

  Zweck:
  Die Vergleichsdoku zu Redis-, Prometheus-, Grafana- und cAdvisor-Ausfällen
  soll in der zentralen Operations-Übersicht auffindbar sein.

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
Write-Host "=== Operations-README Monitoring Incident Patterns Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Readme = Get-Content $Path -Raw

$TargetHealthLine = "| prometheus-target-health-cadvisor.md | Prometheus Target Health: cAdvisor | Prometheus Targets, Query up, cAdvisor UP/DOWN einordnen |"
$CadvisorIncidentLine = "| incident-simulation-cadvisor-stopped.md | cAdvisor-Stopp Incident-Simulation | Ausfall der Container-Metrikquelle bei weiterhin laufender App |"
$PatternsLine = "| monitoring-incident-patterns.md | Monitoring Incident Patterns | Vergleich Redis-, Prometheus-, Grafana- und cAdvisor-Ausfall |"

# 1) Tabellenzeile ergänzen.
if ($Readme.Contains($PatternsLine)) {
    Write-Host "[INFO] Monitoring-Incident-Patterns-Tabellenzeile ist bereits vorhanden."
}
elseif ($Readme.Contains($TargetHealthLine)) {
    $Readme = $Readme.Replace($TargetHealthLine, "$TargetHealthLine`r`n$PatternsLine")
    Write-Host "[OK] Patterns-Tabellenzeile nach Prometheus-Target-Health-Zeile eingefügt."
}
elseif ($Readme.Contains($CadvisorIncidentLine)) {
    $Readme = $Readme.Replace($CadvisorIncidentLine, "$CadvisorIncidentLine`r`n$PatternsLine")
    Write-Host "[OK] Patterns-Tabellenzeile nach cAdvisor-Incident-Zeile eingefügt."
}
else {
    throw "Kein Tabellenanker gefunden. Erwartet wurde Target-Health- oder cAdvisor-Incident-Zeile."
}

# 2) Abschnitt ergänzen.
$PatternsSection = @'

### Monitoring Incident Patterns

Relevantes Dokument:

```text
monitoring-incident-patterns.md
```

Gezeigte Fähigkeiten:

```text
Fehlerbilder vergleichen
Redis-, Prometheus-, Grafana- und cAdvisor-Ausfall unterscheiden
betroffenen Bereich erkennen
Diagnosekette anwenden
Fix und Verifikation ableiten
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Einordnung:

```text
Diese Doku fasst die bisher trainierten Betriebsfehler zusammen.
Sie hilft bei der Mustererkennung:
Symptom → betroffener Service → betroffener Bereich → Diagnose → Maßnahme → Verifikation.
```

Wichtige Erkenntnis:

```text
Nicht jedes sichtbare Symptom zeigt direkt die Ursache.
Grafana kann fehlende Daten anzeigen,
obwohl die Ursache bei Prometheus oder cAdvisor liegt.
```

'@

if ($Readme -match '(?m)^### Monitoring Incident Patterns\s*$') {
    Write-Host "[INFO] Abschnitt 'Monitoring Incident Patterns' ist bereits vorhanden."
}
elseif ($Readme -match '(?m)^### Prometheus Target Health: cAdvisor\s*$') {
    $Readme = $Readme -replace '(?m)^### Prometheus Target Health: cAdvisor\s*$', ($PatternsSection.TrimEnd() + "`r`n`r`n### Prometheus Target Health: cAdvisor")
    Write-Host "[OK] Patterns-Abschnitt vor Prometheus-Target-Health-Abschnitt eingefügt."
}
elseif ($Readme -match '(?m)^### Incident-Simulation: cAdvisor gestoppt\s*$') {
    $Readme = $Readme -replace '(?m)^### Incident-Simulation: cAdvisor gestoppt\s*$', ($PatternsSection.TrimEnd() + "`r`n`r`n### Incident-Simulation: cAdvisor gestoppt")
    Write-Host "[OK] Patterns-Abschnitt vor cAdvisor-Incident-Abschnitt eingefügt."
}
else {
    throw "Kein Abschnittsanker gefunden. Erwartet wurde Target-Health- oder cAdvisor-Incident-Abschnitt."
}

Set-Content -Path $Path -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] docs/operations/README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\docs\operations\README.md -Pattern 'monitoring-incident-patterns.md', 'Monitoring Incident Patterns', 'Fehlerbilder vergleichen', 'Mustererkennung'"
Write-Host "  git diff --stat docs/operations/README.md"
Write-Host ""
