# Aktualisiert die README mit den abgeschlossenen Advanced-Themen.
# Bestehende Datei wird gezielt angepasst, nicht komplett ersetzt.

$path = ".\README.md"
$content = Get-Content -Path $path -Raw

$content = $content -replace `
"Praxisnahes Docker-/DevOps-Portfolio mit Fokus auf Containerbetrieb, Troubleshooting, Backup/Restore, Healthchecks, Readiness-Checks, Secret-Handling, Logging, Monitoring und sauberer Repository-Struktur\.", `
"Praxisnahes Docker-/DevOps-Portfolio mit Fokus auf Containerbetrieb, Troubleshooting, Backup/Restore, Healthchecks, Readiness-Checks, Reverse Proxy, HTTPS, Secret-Handling, Logging, Monitoring, Container Security, Image Scanning, Registry-Grundlagen, CI/CD und sauberer Repository-Struktur."

$content = $content -replace `
"Dieses Repository ist bewusst kein reines Hello-World-Projekt\. Es zeigt anhand eines kleinen containerisierten Stacks, dass Docker-Container nicht nur gestartet, sondern auch geprüft, dokumentiert, abgesichert und in realistischeren Betriebsfällen getestet werden können\.", `
"Dieses Repository ist bewusst kein reines Startbeispiel. Es zeigt anhand eines kleinen containerisierten Stacks, dass Docker-Container nicht nur gestartet, sondern auch geprüft, dokumentiert, abgesichert, über Reverse Proxy/HTTPS bereitgestellt, gescannt und in realistischeren Betriebsfällen getestet werden können."

$oldList = @'
- Aufbau eines containerisierten Web-/Redis-Stacks mit Docker Compose
- Trennung zwischen Development- und produktionsnaher Compose-Konfiguration
- persistente Redis-Datenhaltung über Docker Volumes
- Healthchecks und Stack-Readiness-Checks
- Backup und getesteter Restore
- Secret-Handling ohne Commit echter Secrets
- Logging-Grundlagen und Terminal-Session-Logging
- Monitoring-Lab mit Prometheus, Grafana und cAdvisor
- GitHub Actions CI zur automatisierten Prüfung
- Simulation typischer Betriebs- und Fehlerfälle
'@

$newList = @'
- Aufbau eines containerisierten Web-/Redis-Stacks mit Docker Compose
- Trennung zwischen Development- und produktionsnaher Compose-Konfiguration
- persistente Redis-Datenhaltung über Docker Volumes
- Healthchecks und Stack-Readiness-Checks
- Backup und getesteter Restore
- NGINX Reverse Proxy mit lokalem HTTPS/TLS
- Secret-Handling ohne Commit echter Secrets
- Docker Log Rotation und Logging-Grundlagen
- Monitoring-Lab mit Prometheus, Grafana, cAdvisor und Target-API-Prüfung
- Container Security Stage 1 mit `no-new-privileges`
- Image Scanning mit Docker Scout und Wechsel auf `nginx:alpine-slim`
- lokale Registry mit Tag-/Digest-Grundlagen
- GitHub Actions CI und separate Docker Image Pipeline
- Simulation typischer Betriebs- und Fehlerfälle
'@

if ($content.Contains($oldList)) {
    $content = $content.Replace($oldList, $newList)
}
else {
    Write-Host "Hinweis: Der Kurzüberblick-Listenblock wurde nicht exakt gefunden. Bitte README manuell prüfen."
}

$oldProof = @'
- Ich kann Docker-Stacks strukturiert aufbauen, starten und prüfen.
- Ich kann Container-Zustände, Healthchecks und Readiness nachvollziehbar bewerten.
- Ich kann Persistenz, Backup und Restore dokumentieren und testen.
- Ich kann einfache Ausfälle simulieren und das Verhalten des Stacks analysieren.
- Ich achte auf Secret-Handling, `.gitignore`, `.dockerignore` und saubere Repository-Hygiene.
- Ich kann technische Arbeit so dokumentieren, dass andere sie nachvollziehen können.
'@

$newProof = @'
- Ich kann Docker-Stacks strukturiert aufbauen, starten und prüfen.
- Ich kann Container-Zustände, Healthchecks und Readiness nachvollziehbar bewerten.
- Ich kann Persistenz, Backup und Restore dokumentieren und testen.
- Ich kann Reverse Proxy, lokales HTTPS/TLS und interne Service-Kommunikation einordnen.
- Ich kann einfache Ausfälle simulieren und das Verhalten des Stacks analysieren.
- Ich achte auf Secret-Handling, `.gitignore`, `.dockerignore` und saubere Repository-Hygiene.
- Ich kann Container-Security-Grundlagen wie `no-new-privileges`, Capabilities und Log Rotation erklären.
- Ich kann Image-Scanning-Ergebnisse bewerten und ein schlankeres Basis-Image kontrolliert testen.
- Ich kann Registry-Grundlagen wie Tag, Push, Pull und Digest praktisch nachweisen.
- Ich kann technische Arbeit so dokumentieren, dass andere sie nachvollziehen können.
'@

if ($content.Contains($oldProof)) {
    $content = $content.Replace($oldProof, $newProof)
}
else {
    Write-Host "Hinweis: Der Nachweis-Listenblock wurde nicht exakt gefunden. Bitte README manuell prüfen."
}

$oldQuestions = @'
- Startet der Stack sauber?
- Sind die Container wirklich healthy?
- Was passiert, wenn Redis ausfällt?
- Bleiben Daten nach Container-Neustarts erhalten?
- Gibt es Backup und Restore?
- Wurde ein Restore erfolgreich getestet?
- Sind Logs, Backups und Secrets geschützt?
- Ist der Stack aus Betriebssicht bereit?
'@

$newQuestions = @'
- Startet der Stack sauber?
- Sind die Container wirklich healthy?
- Funktioniert HTTPS über den Reverse Proxy?
- Was passiert, wenn Redis oder Monitoring-Komponenten ausfallen?
- Bleiben Daten nach Container-Neustarts erhalten?
- Gibt es Backup und Restore?
- Wurde ein Restore erfolgreich getestet?
- Sind Logs, Backups, Zertifikate und Secrets geschützt?
- Welche bekannten Schwachstellen enthält das Image?
- Kann das Image aus einer Registry genutzt werden?
- Ist der Stack aus Betriebssicht bereit?
'@

if ($content.Contains($oldQuestions)) {
    $content = $content.Replace($oldQuestions, $newQuestions)
}
else {
    Write-Host "Hinweis: Der Betriebsfragen-Block wurde nicht exakt gefunden. Bitte README manuell prüfen."
}

$advancedRows = @'
| NGINX Reverse Proxy | vorhanden |
| lokales HTTPS/TLS | vorhanden |
| Docker Log Rotation | vorhanden |
| Prometheus Target API Check | vorhanden |
| Container Security Stage 1 | vorhanden |
| Image Scanning mit Docker Scout | vorhanden |
| schlankeres NGINX-Basis-Image | vorhanden |
| lokale Registry mit Image v1.4 | vorhanden |
| Docker Image Pipeline mit GitHub Actions | vorhanden |
'@

if (-not ($content -match "Docker Image Pipeline mit GitHub Actions")) {
    $content = $content -replace "(\| finaler Daily-Operations-/Readiness-Check \| vorhanden \|\r?\n)", "`$1$advancedRows"
}

Set-Content -Path $path -Value $content -Encoding UTF8
Write-Host "README wurde gezielt aktualisiert. Bitte Diff prüfen."
