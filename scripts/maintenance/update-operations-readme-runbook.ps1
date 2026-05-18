<#
.SYNOPSIS
  Aktualisiert docs/operations/README.md nach Ergänzung des Daily Operations Runbooks.

.DESCRIPTION
  Dieses Skript ergänzt die Operations-Dokumentationsübersicht sachlich:
  - daily-operations-runbook.md wird in der Dokumententabelle ergänzt.
  - ein eigener Abschnitt "Daily Operations Runbook" wird eingefügt.
  - die nächsten Ausbaustufen werden leicht angepasst.

  Das Skript ist idempotent:
  - Wenn der Eintrag oder Abschnitt bereits existiert, wird er nicht doppelt eingefügt.
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
Write-Host "=== Operations-README Runbook-Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Readme = Get-Content $OperationsReadmePath -Raw

# 1) Daily Operations Runbook in der Dokumententabelle ergänzen.
$RunbookTableLine = "| `daily-operations-runbook.md` | Daily Operations Runbook | wiederholbarer Betriebsablauf für Start, Checks, Logs, Monitoring, Secrets und Stoppen |"

if ($Readme.Contains($RunbookTableLine)) {
    Write-Host "[INFO] Daily Operations Runbook ist in der Dokumententabelle bereits vorhanden."
}
elseif ($Readme.Contains("| `logging-basics.md` | Docker Compose Logs | Logs mit `--tail`, `--since`, `--follow` lesen und einordnen |")) {
    $Readme = $Readme.Replace(
        "| `logging-basics.md` | Docker Compose Logs | Logs mit `--tail`, `--since`, `--follow` lesen und einordnen |",
        "| `logging-basics.md` | Docker Compose Logs | Logs mit `--tail`, `--since`, `--follow` lesen und einordnen |`r`n$RunbookTableLine"
    )
    Write-Host "[OK] Daily Operations Runbook in der Dokumententabelle ergänzt."
}
else {
    Write-Host "[WARN] Tabellenanker 'logging-basics.md' wurde nicht gefunden. Dokumententabelle wurde nicht ergänzt."
}

# 2) Eigenen Abschnitt für das Runbook einfügen.
$RunbookSection = @'

### Daily Operations Runbook

Relevantes Dokument:

```text
daily-operations-runbook.md
```

Gezeigte Fähigkeiten:

```text
Stack reproduzierbar starten
Stackstatus prüfen
Readiness Check ausführen
Logs und Monitoring prüfen
Secrets kontrollieren
Git-Zustand prüfen
Monitoring ohne Datenverlust stoppen
Screenshots bewusst und sicher verwenden
```

Einordnung:

```text
Das Runbook bündelt wiederkehrende Betriebsabläufe.
Es hilft dabei, den Stack nicht nur aufzubauen, sondern auch nachvollziehbar zu betreiben.
```

'@

if ($Readme -match '(?m)^### Daily Operations Runbook\s*$') {
    Write-Host "[INFO] Abschnitt 'Daily Operations Runbook' existiert bereits. Kein doppeltes Einfügen."
}
elseif ($Readme -match '(?m)^### Terminal-Session-Logging\s*$') {
    $Readme = $Readme -replace '(?m)^### Terminal-Session-Logging\s*$', ($RunbookSection.TrimEnd() + "`r`n`r`n### Terminal-Session-Logging")
    Write-Host "[OK] Abschnitt 'Daily Operations Runbook' vor Terminal-Session-Logging eingefügt."
}
elseif ($Readme -match '(?m)^## Portfolio-Wert\s*$') {
    $Readme = $Readme -replace '(?m)^## Portfolio-Wert\s*$', ($RunbookSection.TrimEnd() + "`r`n`r`n## Portfolio-Wert")
    Write-Host "[OK] Abschnitt 'Daily Operations Runbook' vor Portfolio-Wert eingefügt."
}
else {
    throw "Kein passender Einfügepunkt gefunden. Bitte docs/operations/README.md manuell prüfen."
}

# 3) Portfolio-Wert um Runbook-Betrieb ergänzen.
$OldPortfolioQuestion = "Wie ordnet man Warnungen ein?"
$NewPortfolioQuestion = "Wie ordnet man Warnungen ein?`r`nWie wird ein wiederholbarer Daily-Operations-Ablauf dokumentiert?"

if ($Readme.Contains($OldPortfolioQuestion) -and -not $Readme.Contains("Daily-Operations-Ablauf")) {
    $Readme = $Readme.Replace($OldPortfolioQuestion, $NewPortfolioQuestion)
    Write-Host "[OK] Portfolio-Wert um Daily-Operations-Ablauf ergänzt."
}
else {
    Write-Host "[INFO] Portfolio-Wert war bereits angepasst oder Anker nicht eindeutig."
}

# 4) Kurzfristige Ausbaustufen anpassen.
$OldNextStep = "praktisches Befehlstraining vorbereiten"
$NewNextStep = "praktisches Befehlstraining und Simulationen vorbereiten"

if ($Readme.Contains($OldNextStep)) {
    $Readme = $Readme.Replace($OldNextStep, $NewNextStep)
    Write-Host "[OK] Nächste Ausbaustufen angepasst."
}
else {
    Write-Host "[INFO] Ausbaustufen-Anker nicht gefunden oder bereits angepasst."
}

Set-Content -Path $OperationsReadmePath -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] docs/operations/README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\docs\operations\README.md -Pattern 'daily-operations-runbook.md', 'Daily Operations Runbook', 'Daily-Operations-Ablauf'"
Write-Host "  git diff --stat docs/operations/README.md"
Write-Host ""
