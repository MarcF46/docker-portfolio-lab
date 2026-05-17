<#
.SYNOPSIS
  Aktualisiert die README nach erfolgreicher GitHub-Actions-CI-Einrichtung.

.DESCRIPTION
  Dieses Skript passt gezielt die README.md an:
  - CI wird nicht mehr als "geplant" beschrieben.
  - CI und CD/Deployment werden sauber getrennt.
  - Ein Abschnitt "GitHub Actions CI" wird eingefügt, falls er noch nicht existiert.

  Das Skript ist idempotent:
  - Wenn der CI-Abschnitt bereits existiert, wird er nicht doppelt eingefügt.
  - Es schreibt nur README.md.
#>

$ErrorActionPreference = "Stop"

# Projektwurzel bestimmen:
# Das Skript liegt später in scripts\maintenance.
# Von dort gehen wir zwei Ebenen nach oben zum Projektordner.
$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptLocation "..\..")

# In den Projektordner wechseln.
Set-Location $ProjectRoot

$ReadmePath = ".\README.md"

if (-not (Test-Path $ReadmePath)) {
    throw "README.md wurde nicht gefunden. Bitte prüfe den Projektordner."
}

Write-Host ""
Write-Host "=== README CI-Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

# README vollständig einlesen.
$Readme = Get-Content $ReadmePath -Raw

# 1) Lab-vs-Produktion-Tabelle aktualisieren.
# Alt: CI/CD war noch nicht vollständig umgesetzt.
# Neu: CI ist vorhanden, CD/Deployment ist noch nicht umgesetzt.
$OldCiCdLine = '| CI/CD | noch nicht vollständig umgesetzt | Pipeline mit Tests, Build, Security Checks |'
$NewCiCdLines = @'
| CI | GitHub Actions CI vorhanden: Compose prüfen, Web-Image bauen, Stack starten, Web + Redis testen | Pipeline mit Tests, Build, Security Checks, Quality Gates |
| CD/Deployment | noch nicht umgesetzt | Staging-/Production-Deployment mit Freigaben, Rollback und Monitoring |
'@

if ($Readme.Contains($OldCiCdLine)) {
    $Readme = $Readme.Replace($OldCiCdLine, $NewCiCdLines.TrimEnd())
    Write-Host "[OK] Lab-vs-Produktion-Tabelle aktualisiert."
}
else {
    Write-Host "[INFO] Alte CI/CD-Zeile nicht gefunden oder bereits aktualisiert."
}

# 2) Geplanten Ausbau aktualisieren.
# GitHub Actions CI ist jetzt umgesetzt, daher wird der Ausbaupunkt angepasst.
$OldPlanned = "GitHub Actions / CI-Prüfungen`nautomatischer Compose-Config-Check bei Push"
$NewPlanned = "CI-Fehlerübungen und GitHub-Actions-Log-Diagnose`nerweiterte CI-Prüfungen, z. B. Script-Checks, Security-Checks und Build-Fehler-Simulationen"

if ($Readme.Contains($OldPlanned)) {
    $Readme = $Readme.Replace($OldPlanned, $NewPlanned)
    Write-Host "[OK] Geplanter Ausbau aktualisiert."
}
else {
    Write-Host "[INFO] Alter Ausbaupunkt nicht gefunden oder bereits aktualisiert."
}

# 3) GitHub-Actions-CI-Abschnitt einfügen.
# Der Abschnitt wird vor "## Dokumentation" eingefügt.
$CiSection = @'

## GitHub Actions CI

Das Repository enthält eine erste GitHub-Actions-CI-Pipeline:

```text
.github/workflows/docker-lab-ci.yml
```

Die Pipeline läuft automatisch bei Push auf `main` und bei Pull Requests.

Sie prüft:

```text
Docker-Versionen anzeigen
lokale CI-Secret-Datei im Runner erzeugen
docker compose config ausführen
Web-Image bauen
Stack starten
Web per HTTP prüfen
Redis per PING/PONG prüfen
bei Fehlern Logs anzeigen
Stack aufräumen
```

Damit wird nicht nur die Compose-Datei geprüft, sondern der Stack im GitHub-Actions-Runner tatsächlich gestartet und getestet.

Security-Hinweis:

```text
Das CI-Secret wird nur im kurzlebigen GitHub-Actions-Runner erzeugt.
Es wird nicht committed und nicht im Workflow ausgegeben.
Für echte produktive Secrets wären GitHub Actions Secrets, Vault oder ein Cloud Secret Manager nötig.
```

Dokumentation:

```text
docs/operations/github-actions-ci.md
```

'@

if ($Readme -match '(?m)^## GitHub Actions CI\s*$') {
    Write-Host "[INFO] Abschnitt 'GitHub Actions CI' existiert bereits. Kein doppeltes Einfügen."
}
elseif ($Readme -match '(?m)^## Dokumentation\s*$') {
    $Readme = $Readme -replace '(?m)^## Dokumentation\s*$', ($CiSection.TrimEnd() + "`r`n`r`n## Dokumentation")
    Write-Host "[OK] Abschnitt 'GitHub Actions CI' eingefügt."
}
else {
    throw "Abschnitt '## Dokumentation' wurde nicht gefunden. Bitte README manuell prüfen."
}

# README zurückschreiben.
Set-Content -Path $ReadmePath -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\README.md -Pattern 'GitHub Actions CI', 'CD/Deployment', 'CI-Fehlerübungen', '.github/workflows/docker-lab-ci.yml'"
Write-Host "  git diff --stat README.md"
Write-Host ""
