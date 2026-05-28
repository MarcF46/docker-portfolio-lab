# Aktualisiert den finalen Portfolio-Abschnitt in der README.md im Projekt-Hauptordner.
# Ziel-Datei: .\README.md
# Nicht gemeint: .\docs\operations\README.md
#
# Das Skript ersetzt den Abschnitt ab:
# ## Mögliche spätere Ausbaustufen
# bis zum Dateiende.
#
# Vorher wird ein Backup im TEMP-Ordner erstellt.

$path = ".\README.md"

if (-not (Test-Path $path)) {
    Write-Host "STOPP: README.md wurde im aktuellen Ordner nicht gefunden."
    Write-Host "Bitte zuerst in den Projektordner wechseln, z. B.:"
    Write-Host "cd 'C:\Docker Übung'"
    exit 1
}

$resolvedPath = (Resolve-Path $path).Path
$backupPath = Join-Path $env:TEMP ("README-before-final-portfolio-update-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".md")

Copy-Item -Path $resolvedPath -Destination $backupPath -Force

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText($resolvedPath, $utf8NoBom)

$heading = "## Mögliche spätere Ausbaustufen"

if (-not $content.Contains($heading)) {
    Write-Host "STOPP: Abschnitt '## Mögliche spätere Ausbaustufen' wurde nicht gefunden."
    Write-Host "README.md wurde nicht geändert."
    Write-Host "Backup liegt unter: $backupPath"
    exit 1
}

$newSection = @'
## Mögliche spätere Ausbaustufen

Mögliche nächste Schritte:

```text
Kubernetes-Grundlagen
Linux-/SSH-Training für Serverbetrieb
CI-Fehlerübungen und GitHub-Actions-Log-Diagnose
erweiterte CI-Prüfungen, z. B. Script-Checks, Security-Checks und Build-Fehler-Simulationen
Monitoring-Fehlerübungen und erste Alerting-Grundlagen
strukturierte Application Logs
Deployment-/Rollback-Szenarien
Secret-Rotation als Übung
GitHub Container Registry oder andere externe Registry
Cloud-Grundlagen mit Fokus auf realistische Junior-Cloud-/DevOps-Rollen
```

Bereits umgesetzt und dokumentiert sind unter anderem:

```text
Dockerfile und Docker Compose
persistente Redis-Datenhaltung
Backup und getesteter Restore
Healthchecks und Readiness-Checks
NGINX Reverse Proxy
lokales HTTPS/TLS
Secret Handling
Docker Log Rotation
Monitoring mit Prometheus, Grafana und cAdvisor
Prometheus Target API Check
Container Security Stage 1
Image Scanning mit Docker Scout
Wechsel auf nginx:alpine-slim
lokale Registry mit Tag-/Digest-Grundlagen
GitHub Actions CI
Docker Image Pipeline
```

---

## Portfolio-Einordnung

Dieses Projekt ist ein praxisnahes Lern- und Portfolio-Projekt für den Einstieg in Cloud-/DevOps-nahe Rollen.

Es zeigt nicht nur:

```text
Ich kann Docker starten.
```

Sondern auch:

```text
Ich kann Container-Stacks strukturiert aufbauen, prüfen und dokumentieren.
Ich kann Betriebszustände mit Healthchecks, Readiness-Checks und Monitoring bewerten.
Ich kann Fehlerfälle simulieren und deren Auswirkungen nachvollziehen.
Ich kann persistente Daten, Backups und Restore-Tests praktisch umsetzen.
Ich kann Reverse Proxy, lokales HTTPS/TLS und interne Service-Kommunikation einordnen.
Ich beachte Secret Handling, .gitignore, .dockerignore und sichere Dokumentation.
Ich kann Container-Logs begrenzen und grundlegende Log-Diagnose durchführen.
Ich kann einfache Container-Security-Maßnahmen wie no-new-privileges erklären und testen.
Ich kann Image-Scanning-Ergebnisse bewerten und daraus eine technische Verbesserung ableiten.
Ich kann ein schlankeres Basis-Image kontrolliert testen und übernehmen.
Ich kann Registry-Grundlagen wie Tag, Push, Pull und Digest praktisch nachweisen.
Ich kann GitHub Actions nutzen, um Docker-Images und Compose-Stacks automatisiert zu prüfen.
Ich kann technische Änderungen mit Git sauber versionieren und nachvollziehbar dokumentieren.
```

Das Projekt erhebt keinen Anspruch auf vollständige Enterprise-Produktionsreife. Es zeigt aber wichtige Betriebsprinzipien, die für Junior-Rollen im Bereich Systemintegration, Cloud Engineering, DevOps und Plattformbetrieb relevant sind.
'@

$pattern = "(?s)## Mögliche spätere Ausbaustufen.*\z"
$updated = [regex]::Replace($content, $pattern, $newSection.TrimEnd() + "`r`n")

[System.IO.File]::WriteAllText($resolvedPath, $updated, $utf8NoBom)

Write-Host "README.md wurde im finalen Portfolio-Abschnitt aktualisiert."
Write-Host "Backup liegt unter: $backupPath"
