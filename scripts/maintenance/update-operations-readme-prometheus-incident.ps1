<#
.SYNOPSIS
  Aktualisiert docs/operations/README.md nach der Prometheus-Stopp Incident-Simulation.

.DESCRIPTION
  Dieses Skript ergänzt die Operations-Dokumentationsübersicht sachlich:
  - incident-simulation-prometheus-stopped.md wird in der Dokumententabelle ergänzt.
  - ein kurzer Abschnitt "Incident-Simulation: Prometheus gestoppt" wird eingefügt.
  - der Portfolio-Wert wird um App-Readiness vs. Operations-Readiness ergänzt.

  Das Skript ist idempotent:
  - Wenn Eintrag oder Abschnitt bereits existieren, wird nichts doppelt eingefügt.
  - Es schreibt nur docs/operations/README.md.
#>

$ErrorActionPreference = "Stop"

# Das Skript liegt in scripts\maintenance.
# Von dort gehen wir zwei Ebenen nach oben in die Projektwurzel.
$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptLocation "..\..")

# Wechselt in die Projektwurzel.
Set-Location $ProjectRoot

$OperationsReadmePath = ".\docs\operations\README.md"

if (-not (Test-Path $OperationsReadmePath)) {
    throw "docs/operations/README.md wurde nicht gefunden. Bitte pruefe den Projektordner."
}

Write-Host ""
Write-Host "=== Operations-README Prometheus-Incident-Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Readme = Get-Content $OperationsReadmePath -Raw

# 1) Tabellenzeile ergänzen.
$IncidentTableLine = "| `incident-simulation-prometheus-stopped.md` | Prometheus-Stopp Incident-Simulation | Monitoring-Ausfall, App-Readiness vs. Operations-Readiness |"

if ($Readme.Contains($IncidentTableLine)) {
    Write-Host "[INFO] Prometheus-Incident-Simulation ist in der Dokumententabelle bereits vorhanden."
}
elseif ($Readme -match '(?m)^\| `incident-simulation-redis-stopped\.md` \| .*$') {
    $Readme = $Readme -replace '(?m)^(\| `incident-simulation-redis-stopped\.md` \| .*)$', "`$1`r`n$IncidentTableLine"
    Write-Host "[OK] Prometheus-Incident-Simulation nach Redis-Incident in der Dokumententabelle ergänzt."
}
elseif ($Readme -match '(?m)^\| `daily-operations-runbook\.md` \| .*$') {
    $Readme = $Readme -replace '(?m)^(\| `daily-operations-runbook\.md` \| .*)$', "`$1`r`n$IncidentTableLine"
    Write-Host "[OK] Prometheus-Incident-Simulation nach Daily Operations Runbook in der Dokumententabelle ergänzt."
}
else {
    Write-Host "[WARN] Kein passender Tabellenanker gefunden. Dokumententabelle wurde nicht ergänzt."
}

# 2) Abschnitt ergänzen.
$IncidentSection = @'

### Incident-Simulation: Prometheus gestoppt

Relevantes Dokument:

```text
incident-simulation-prometheus-stopped.md
```

Gezeigte Fähigkeiten:

```text
Monitoring-Ausfall kontrolliert auslösen
Prometheus-Ausfall erkennen
Daily-Operations-Check auswerten
App-Readiness und Operations-Readiness unterscheiden
Prometheus wiederherstellen
Fix verifizieren
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Einordnung:

```text
Die Simulation zeigt, dass Web und Redis fachlich bereit bleiben können,
während die Beobachtbarkeit durch einen Prometheus-Ausfall beschädigt ist.
```

Wichtige Erkenntnis:

```text
App-Stack bereit ist nicht automatisch gleich Operations-Stack vollständig bereit.
```

'@

if ($Readme -match '(?m)^### Incident-Simulation: Prometheus gestoppt\s*$') {
    Write-Host "[INFO] Abschnitt 'Incident-Simulation: Prometheus gestoppt' existiert bereits. Kein doppeltes Einfügen."
}
elseif ($Readme -match '(?m)^### Incident-Simulation: Redis gestoppt\s*$') {
    $Readme = $Readme -replace '(?m)^### Incident-Simulation: Redis gestoppt\s*$', ($IncidentSection.TrimEnd() + "`r`n`r`n### Incident-Simulation: Redis gestoppt")
    Write-Host "[OK] Prometheus-Incident-Simulation vor Redis-Incident eingefügt."
}
elseif ($Readme -match '(?m)^### Daily Operations Runbook\s*$') {
    $Readme = $Readme -replace '(?m)^### Daily Operations Runbook\s*$', ($IncidentSection.TrimEnd() + "`r`n`r`n### Daily Operations Runbook")
    Write-Host "[OK] Prometheus-Incident-Simulation vor Daily Operations Runbook eingefügt."
}
else {
    throw "Kein passender Einfügepunkt gefunden. Bitte docs/operations/README.md manuell prüfen."
}

# 3) Portfolio-Wert ergänzen.
$PortfolioAnchor = "Wie wird ein kontrollierter Fehler erkannt, behoben und verifiziert?"
$PortfolioAddition = "Wie wird ein kontrollierter Fehler erkannt, behoben und verifiziert?`r`nWie werden App-Readiness und Operations-Readiness unterschieden?"

if ($Readme.Contains($PortfolioAnchor) -and -not $Readme.Contains("App-Readiness und Operations-Readiness")) {
    $Readme = $Readme.Replace($PortfolioAnchor, $PortfolioAddition)
    Write-Host "[OK] Portfolio-Wert um App-Readiness vs. Operations-Readiness ergänzt."
}
else {
    Write-Host "[INFO] Portfolio-Wert war bereits angepasst oder Anker nicht eindeutig."
}

Set-Content -Path $OperationsReadmePath -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] docs/operations/README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\docs\operations\README.md -Pattern 'incident-simulation-prometheus-stopped.md', 'Incident-Simulation: Prometheus gestoppt', 'App-Readiness', 'Operations-Readiness'"
Write-Host "  git diff --stat docs/operations/README.md"
Write-Host ""
