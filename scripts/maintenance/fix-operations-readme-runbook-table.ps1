<#
.SYNOPSIS
  Ergänzt den fehlenden Tabellen-Eintrag für das Daily Operations Runbook.

.DESCRIPTION
  Beim vorherigen Update wurde der Abschnitt "Daily Operations Runbook" korrekt eingefügt.
  Der Tabellenanker wurde aber nicht gefunden, daher wurde der Eintrag in der Übersichtstabelle nicht ergänzt.

  Dieses Skript korrigiert nur diesen fehlenden Tabellen-Eintrag in:
  docs/operations/README.md

  Das Skript ist idempotent:
  - Wenn der Tabellen-Eintrag bereits existiert, wird nichts doppelt eingefügt.
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
    throw "docs/operations/README.md wurde nicht gefunden."
}

Write-Host ""
Write-Host "=== Fix: Runbook-Tabellenzeile in Operations-README ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Readme = Get-Content $OperationsReadmePath -Raw

$RunbookLine = "| `daily-operations-runbook.md` | Daily Operations Runbook | wiederholbarer Betriebsablauf für Start, Checks, Logs, Monitoring, Secrets und Stoppen |"

if ($Readme.Contains($RunbookLine)) {
    Write-Host "[INFO] Tabellenzeile existiert bereits. Keine Änderung nötig."
}
else {
    # Einfügepunkt: direkt nach der Logging-Basics-Zeile, aber toleranter als das vorherige Skript.
    $Pattern = '(?m)^(\| `logging-basics\.md` \| .*)$'

    if ($Readme -match $Pattern) {
        $Readme = $Readme -replace $Pattern, "`$1`r`n$RunbookLine"
        Write-Host "[OK] Tabellenzeile nach logging-basics.md eingefügt."
    }
    else {
        throw "Tabellenzeile für logging-basics.md wurde nicht gefunden. Bitte Operations-README manuell prüfen."
    }

    Set-Content -Path $OperationsReadmePath -Value $Readme -Encoding UTF8
    Write-Host "[OK] docs/operations/README.md wurde aktualisiert." -ForegroundColor Green
}

Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\docs\operations\README.md -Pattern 'daily-operations-runbook.md', 'wiederholbarer Betriebsablauf'"
Write-Host "  git diff --stat docs/operations/README.md"
Write-Host ""
