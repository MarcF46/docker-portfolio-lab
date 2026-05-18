<#
.SYNOPSIS
  Aktualisiert die README nach der Logging-Grundlagen-Einheit.

.DESCRIPTION
  Dieses Skript ergänzt die README.md sachlich und portfolio-tauglich:
  - Logging-Grundlagen werden als vorhandener Projektbestandteil erwähnt.
  - Die wichtigsten Docker-Compose-Logbefehle werden sichtbar dokumentiert.
  - Der Unterschied zwischen Healthcheck-Logs, Browserzugriffen und Warnungen wird kurz eingeordnet.
  - Die Dokumentation docs/operations/logging-basics.md wird verlinkt.

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
Write-Host "=== README Logging-Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

# README vollständig einlesen.
$Readme = Get-Content $ReadmePath -Raw

# Ergänzt Logging im Projektumfang, falls noch nicht vorhanden.
$LoggingScopeLine = "| Logging-Grundlagen mit Docker Compose | vorhanden |"

if ($Readme.Contains($LoggingScopeLine)) {
    Write-Host "[INFO] Logging ist in der Projektumfang-Tabelle bereits vorhanden."
}
elseif ($Readme.Contains("| Monitoring-Lab mit Prometheus, Grafana und cAdvisor | vorhanden |")) {
    $Readme = $Readme.Replace(
        "| Monitoring-Lab mit Prometheus, Grafana und cAdvisor | vorhanden |",
        "| Monitoring-Lab mit Prometheus, Grafana und cAdvisor | vorhanden |`r`n$LoggingScopeLine"
    )
    Write-Host "[OK] Logging in der Projektumfang-Tabelle nach Monitoring ergänzt."
}
elseif ($Readme.Contains("| Terminal-Session-Logging-Dokumentation | vorhanden |")) {
    $Readme = $Readme.Replace(
        "| Terminal-Session-Logging-Dokumentation | vorhanden |",
        "| Terminal-Session-Logging-Dokumentation | vorhanden |`r`n$LoggingScopeLine"
    )
    Write-Host "[OK] Logging in der Projektumfang-Tabelle nach Terminal-Session-Logging ergänzt."
}
else {
    Write-Host "[WARN] Kein passender Tabellenanker gefunden. Projektumfang-Tabelle wurde nicht ergänzt."
}

# Neuer README-Abschnitt für Logging.
$LoggingSection = @'

## Logging-Grundlagen

Das Projekt dokumentiert grundlegende Log-Diagnose mit Docker Compose:

```text
docs/operations/logging-basics.md
```

Ziel der Logging-Einheit:

```text
Logs gezielt abrufen
Logs pro Service lesen
Logs zeitlich eingrenzen
Live-Logs beobachten
Warnungen von echten Fehlern unterscheiden
```

Wichtige Befehle:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 web
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --since=10m grafana
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --follow --tail=5 web
```

Im Lab wurde ein Browserzugriff gezielt sichtbar gemacht:

```text
http://localhost:8082/?test=logcheck
```

Dadurch konnte im Webcontainer nachvollzogen werden:

```text
Browseraktion → Webcontainer → Logzeile erscheint live im Terminal
```

Fachliche Einordnung:

| Logtyp | Beispiel | Bedeutung |
|---|---|---|
| Healthcheck-Zugriff | `Wget` mit HTTP 200 | normaler automatischer Healthcheck |
| Browserzugriff | `Mozilla/5.0` und `?test=logcheck` | bewusst ausgelöster Zugriff |
| cAdvisor-Warnung | fehlende `machine-id` / `system UUID` | Docker-Desktop-/WSL2-Hinweis, im Lab nicht fatal |

Security-Hinweis:

```text
Logs können sensible Informationen enthalten.
Terminal-Ausgaben und Screenshots müssen vor öffentlicher Nutzung geprüft werden.
Secrets, Tokens und personenbezogene Daten dürfen nicht in öffentliche Logs oder Screenshots gelangen.
```

'@

if ($Readme -match '(?m)^## Logging-Grundlagen\s*$') {
    Write-Host "[INFO] Abschnitt 'Logging-Grundlagen' existiert bereits. Kein doppeltes Einfügen."
}
elseif ($Readme -match '(?m)^## Monitoring mit Prometheus und Grafana\s*$') {
    $Readme = $Readme -replace '(?m)^## Monitoring mit Prometheus und Grafana\s*$', ($LoggingSection.TrimEnd() + "`r`n`r`n## Monitoring mit Prometheus und Grafana")
    Write-Host "[OK] Logging-Abschnitt vor Monitoring eingefügt."
}
elseif ($Readme -match '(?m)^## GitHub Actions CI\s*$') {
    $Readme = $Readme -replace '(?m)^## GitHub Actions CI\s*$', ($LoggingSection.TrimEnd() + "`r`n`r`n## GitHub Actions CI")
    Write-Host "[OK] Logging-Abschnitt vor GitHub Actions CI eingefügt."
}
elseif ($Readme -match '(?m)^## Dokumentation\s*$') {
    $Readme = $Readme -replace '(?m)^## Dokumentation\s*$', ($LoggingSection.TrimEnd() + "`r`n`r`n## Dokumentation")
    Write-Host "[OK] Logging-Abschnitt vor Dokumentation eingefügt."
}
else {
    throw "Weder '## Monitoring mit Prometheus und Grafana', '## GitHub Actions CI' noch '## Dokumentation' wurde gefunden. Bitte README manuell prüfen."
}

# README zurückschreiben.
Set-Content -Path $ReadmePath -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\README.md -Pattern 'Logging-Grundlagen', 'logging-basics.md', '--tail', '--since', '--follow', 'test=logcheck'"
Write-Host "  git diff --stat README.md"
Write-Host ""
