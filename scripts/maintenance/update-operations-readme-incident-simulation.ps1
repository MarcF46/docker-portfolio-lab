<#
.SYNOPSIS
  Aktualisiert docs/operations/README.md nach der Redis-Stopp Incident-Simulation.

.DESCRIPTION
  Dieses Skript ergänzt die Operations-Dokumentationsübersicht sachlich:
  - incident-simulation-redis-stopped.md wird in der Dokumententabelle ergänzt.
  - ein kurzer Abschnitt "Incident-Simulation: Redis gestoppt" wird eingefügt.
  - der Portfolio-Wert wird um kontrollierte Fehlersimulation ergänzt.

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
    throw "docs/operations/README.md wurde nicht gefunden. Bitte prüfe den Projektordner."
}

Write-Host ""
Write-Host "=== Operations-README Incident-Simulation-Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Readme = Get-Content $OperationsReadmePath -Raw

# 1) Tabellenzeile ergänzen.
$IncidentTableLine = "| `incident-simulation-redis-stopped.md` | Redis-Stopp Incident-Simulation | kontrollierter Redis-Ausfall, Erkennung, Behebung und Verifikation |"

if ($Readme.Contains($IncidentTableLine)) {
    Write-Host "[INFO] Incident-Simulation ist in der Dokumententabelle bereits vorhanden."
}
elseif ($Readme -match '(?m)^\| `daily-operations-runbook\.md` \| .*$') {
    $Readme = $Readme -replace '(?m)^(\| `daily-operations-runbook\.md` \| .*)$', "`$1`r`n$IncidentTableLine"
    Write-Host "[OK] Incident-Simulation nach daily-operations-runbook.md in der Dokumententabelle ergänzt."
}
elseif ($Readme -match '(?m)^\| `logging-basics\.md` \| .*$') {
    $Readme = $Readme -replace '(?m)^(\| `logging-basics\.md` \| .*)$', "`$1`r`n$IncidentTableLine"
    Write-Host "[OK] Incident-Simulation nach logging-basics.md in der Dokumententabelle ergänzt."
}
else {
    Write-Host "[WARN] Kein passender Tabellenanker gefunden. Dokumententabelle wurde nicht ergänzt."
}

# 2) Abschnitt ergänzen.
$IncidentSection = @'

### Incident-Simulation: Redis gestoppt

Relevantes Dokument:

```text
incident-simulation-redis-stopped.md
```

Gezeigte Fähigkeiten:

```text
kontrollierten Fehler auslösen
Redis-Ausfall erkennen
Daily-Operations-Check auswerten
Readiness-Fehler fachlich einordnen
Redis wiederherstellen
Fix verifizieren
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Einordnung:

```text
Die Simulation zeigt, dass ein teilweise laufender Stack nicht automatisch fachlich bereit ist.
Web, Prometheus, Grafana und cAdvisor können weiter laufen, während Redis als Laufzeitabhängigkeit fehlt.
```

'@

if ($Readme -match '(?m)^### Incident-Simulation: Redis gestoppt\s*$') {
    Write-Host "[INFO] Abschnitt 'Incident-Simulation: Redis gestoppt' existiert bereits. Kein doppeltes Einfügen."
}
elseif ($Readme -match '(?m)^### Daily Operations Runbook\s*$') {
    $Readme = $Readme -replace '(?m)^### Daily Operations Runbook\s*$', ($IncidentSection.TrimEnd() + "`r`n`r`n### Daily Operations Runbook")
    Write-Host "[OK] Incident-Simulation vor Daily Operations Runbook eingefügt."
}
elseif ($Readme -match '(?m)^## Portfolio-Wert\s*$') {
    $Readme = $Readme -replace '(?m)^## Portfolio-Wert\s*$', ($IncidentSection.TrimEnd() + "`r`n`r`n## Portfolio-Wert")
    Write-Host "[OK] Incident-Simulation vor Portfolio-Wert eingefügt."
}
else {
    throw "Kein passender Einfügepunkt gefunden. Bitte docs/operations/README.md manuell prüfen."
}

# 3) Portfolio-Wert leicht ergänzen.
$PortfolioAnchor = "Wie wird ein wiederholbarer Daily-Operations-Ablauf dokumentiert?"
$PortfolioAddition = "Wie wird ein wiederholbarer Daily-Operations-Ablauf dokumentiert?`r`nWie wird ein kontrollierter Fehler erkannt, behoben und verifiziert?"

if ($Readme.Contains($PortfolioAnchor) -and -not $Readme.Contains("kontrollierter Fehler erkannt")) {
    $Readme = $Readme.Replace($PortfolioAnchor, $PortfolioAddition)
    Write-Host "[OK] Portfolio-Wert um kontrollierte Fehlersimulation ergänzt."
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
Write-Host "  Select-String -Path .\docs\operations\README.md -Pattern 'incident-simulation-redis-stopped.md', 'Incident-Simulation: Redis gestoppt', 'kontrollierter Fehler'"
Write-Host "  git diff --stat docs/operations/README.md"
Write-Host ""
