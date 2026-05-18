<#
.SYNOPSIS
  Ergänzt die Haupt-README um einen Link zur Operations-Dokumentationsübersicht.

.DESCRIPTION
  Dieses Skript aktualisiert README.md sachlich und portfolio-tauglich:
  - Es verweist auf docs/operations/README.md.
  - Es erklärt kurz, dass dort die betriebsnahen Dokumente gebündelt sind.
  - Es vermeidet private Roadmap-/Motivationsinformationen.

  Das Skript ist idempotent:
  - Wenn der Abschnitt bereits existiert, wird er nicht doppelt eingefügt.
  - Es schreibt nur README.md.
#>

$ErrorActionPreference = "Stop"

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
Write-Host "=== README Operations-Link-Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Readme = Get-Content $ReadmePath -Raw

$OperationsSection = @'

## Operations-Dokumentation

Die betriebsnahen Dokumente sind in einer eigenen Übersicht zusammengefasst:

```text
docs/operations/README.md
```

Dort sind die wichtigsten Betriebsbereiche des Labs gebündelt:

```text
Backup und Restore
Troubleshooting
Runtime Dependencies
Secret Handling
GitHub Actions CI
Monitoring
Logging
Lab vs. Produktion
```

Diese Übersicht erleichtert das Lesen des Projekts und zeigt, welche praktischen Cloud-/DevOps-Grundlagen im Lab nachgewiesen werden.

'@

if ($Readme -match '(?m)^## Operations-Dokumentation\s*$') {
    Write-Host "[INFO] Abschnitt 'Operations-Dokumentation' existiert bereits. Kein doppeltes Einfügen."
}
elseif ($Readme -match '(?m)^## Logging-Grundlagen\s*$') {
    $Readme = $Readme -replace '(?m)^## Logging-Grundlagen\s*$', ($OperationsSection.TrimEnd() + "`r`n`r`n## Logging-Grundlagen")
    Write-Host "[OK] Operations-Dokumentation vor Logging-Grundlagen eingefügt."
}
elseif ($Readme -match '(?m)^## Monitoring mit Prometheus und Grafana\s*$') {
    $Readme = $Readme -replace '(?m)^## Monitoring mit Prometheus und Grafana\s*$', ($OperationsSection.TrimEnd() + "`r`n`r`n## Monitoring mit Prometheus und Grafana")
    Write-Host "[OK] Operations-Dokumentation vor Monitoring eingefügt."
}
elseif ($Readme -match '(?m)^## Dokumentation\s*$') {
    $Readme = $Readme -replace '(?m)^## Dokumentation\s*$', ($OperationsSection.TrimEnd() + "`r`n`r`n## Dokumentation")
    Write-Host "[OK] Operations-Dokumentation vor Dokumentation eingefügt."
}
else {
    throw "Kein passender Einfügepunkt gefunden. Bitte README manuell prüfen."
}

Set-Content -Path $ReadmePath -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\README.md -Pattern 'Operations-Dokumentation', 'docs/operations/README.md', 'Lab vs. Produktion'"
Write-Host "  git diff --stat README.md"
Write-Host ""
