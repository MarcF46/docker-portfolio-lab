# Docker / Grafana Monitoring Portfolio Lab

> **Original portfolio project by Marc Fahlbusch**  
> GitHub: https://github.com/MarcF46  
> Repository: https://github.com/MarcF46/docker-portfolio-lab  
> Portfolio: https://marcf46.github.io/docker-portfolio-lab/#docs  
> LinkedIn: https://www.linkedin.com/in/marc-fahlbusch-1762b3335

This repository is a personal learning and portfolio project focused on Docker, Docker Compose, Grafana, Prometheus, monitoring, alerting, backup/restore thinking, troubleshooting and operations-oriented DevOps practice.

The project structure, documentation, screenshots, dashboard descriptions, operational scenarios and learning notes are part of my personal portfolio work.

## Usage and attribution

You are welcome to view this repository for learning, review and recruitment purposes.

If this project inspires your own work or you reference parts of it publicly, please include fair attribution and link back to the original repository.

Please do not copy, rebrand, republish or present this project, its documentation, screenshots, dashboard descriptions or portfolio structure as your own work.

**Original project by Marc Fahlbusch**  
GitHub: https://github.com/MarcF46/docker-portfolio-lab

For details, see `ATTRIBUTION.md`.

---

## Deutsch

Das Repository ist ein persönliches Lern- und Portfolio-Projekt von **Marc Fahlbusch**.

Es dokumentiert praktische Arbeit mit Docker, Docker Compose, Grafana, Prometheus, Monitoring, Alerting, Backup-/Restore-Denken, Troubleshooting und betriebsnaher DevOps-Praxis.

Die Projektstruktur, Dokumentation, Screenshots, Dashboard-Beschreibungen, Betriebsszenarien und Lernnotizen sind Teil meiner persönlichen Portfolio-Arbeit.

## Nutzung und Namensnennung

Das Repository darf gern zu Lern-, Prüfungs-, Bewerbungs- und Review-Zwecken angesehen werden.

Wenn einzelne Ideen, Dokumentationsansätze oder Projektteile als Inspiration dienen, freue ich mich über eine faire Namensnennung und einen Link zum Original-Repository.

Bitte kopiere, benenne oder veröffentliche Projektinhalte, Screenshots, Dashboard-Beschreibungen oder die Portfolio-Struktur nicht als eigene Arbeit.

**Originalprojekt von Marc Fahlbusch**  
GitHub: https://github.com/MarcF46/docker-portfolio-lab

Weitere Details stehen in `ATTRIBUTION.md`.

---

Praxisnahes Docker-/DevOps-Portfolio mit Fokus auf Containerbetrieb, Troubleshooting, Backup/Restore, Healthchecks, Readiness-Checks, Reverse Proxy, HTTPS, Secret-Handling, Logging, Monitoring, Container Security, Image Scanning, Registry-Grundlagen, CI/CD und sauberer Repository-Struktur.

Das Repository ist bewusst kein reines Startbeispiel. Anhand eines kleinen containerisierten Stacks wird gezeigt, dass Docker-Container nicht nur gestartet, sondern auch geprüft, dokumentiert, abgesichert, über Reverse Proxy/HTTPS bereitgestellt, gescannt und in realistischeren Betriebsfällen getestet werden können.

## Kurzüberblick

Das Projekt ist als praxisnahes Docker-/DevOps-Lab für den Einstieg in Cloud-, DevOps-, Plattform- und Systemadministrationsrollen aufgebaut.

Es zeigt unter anderem:

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

## Was das Projekt nachweist

Das Repository dokumentiert ein praxisnahes Docker-/DevOps-Lab mit Fokus auf Betrieb, Monitoring, Recovery, Security und nachvollziehbare technische Dokumentation.

Im Projekt wurde ein Docker-Stack strukturiert aufgebaut, gestartet und über konkrete Prüfungen bewertet. Dabei ging es nicht nur darum, Container laufen zu lassen, sondern Betriebszustände sichtbar zu machen und typische Fragen aus dem Alltag eines Junior Cloud-/DevOps-/Plattform-Teams praktisch nachzustellen.

Wichtige Schwerpunkte waren:

- Docker-Stacks wurden aufgebaut, gestartet und über Status-, Log- und Healthcheck-Ausgaben geprüft.
- Container-Zustände, Healthchecks und Readiness wurden aus Betriebssicht eingeordnet.
- Persistenz, Backup und Restore wurden nicht nur beschrieben, sondern praktisch getestet und dokumentiert.
- Reverse Proxy, lokales HTTPS/TLS und interne Service-Kommunikation wurden im Lab umgesetzt und nachvollziehbar geprüft.
- Einfache Ausfälle wurden simuliert, um das Verhalten des Stacks sichtbar zu machen und Diagnosewege zu üben.
- Secret-Handling, `.gitignore`, `.dockerignore` und saubere Repository-Hygiene wurden bewusst berücksichtigt.
- Container-Security-Grundlagen wie `no-new-privileges`, Capabilities und Log Rotation wurden praktisch eingeordnet.
- Image-Scanning-Ergebnisse wurden bewertet und ein schlankeres Basis-Image kontrolliert getestet.
- Registry-Grundlagen wie Tag, Push, Pull und Digest wurden praktisch nachvollzogen.
- Die technische Arbeit wurde so dokumentiert, dass Aufbau, Prüfungen, Fehlerbilder und Ergebnisse auch später nachvollziehbar bleiben.

> Hinweis: Das Projekt ist ein Lern- und Portfolio-Lab. Es ist bewusst produktionsnah aufgebaut, ersetzt aber keine vollständige Enterprise-Produktionsumgebung.

---

## Ziel des Projekts

Ziel des Projekts ist es, Docker nicht nur als Startbefehl zu lernen, sondern aus Betriebssicht zu verstehen.

Das Projekt trainiert Grundlagen für einen Einstieg als:

- Junior Cloud Engineer
- Junior DevOps Engineer
- Junior Platform Engineer
- Junior System Engineer mit Cloud-/Container-Fokus

Im Mittelpunkt stehen typische Betriebsfragen:

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

---

## Aktueller Projektumfang

| Bereich | Status |
|---|---|
| Dockerfile für Webcontainer | vorhanden |
| Development-Compose-Datei | vorhanden |
| produktionsnahe Compose-Datei | vorhanden |
| Redis mit persistentem Docker Volume | vorhanden |
| Redis-Persistenz mit AOF | vorhanden |
| Backup-Skripte | vorhanden |
| Restore-Test | vorhanden |
| Retention-/GFS-Dokumentation | vorhanden |
| Healthchecks für Web und Redis | vorhanden |
| Start-Abhängigkeit `web -> redis healthy` | vorhanden |
| Restart Policy | vorhanden |
| Redis-Ausfallsimulation | vorhanden |
| Stack-Readiness-Check | vorhanden |
| Terminal-Session-Logging-Dokumentation | vorhanden |
| Monitoring-Lab mit Prometheus, Grafana und cAdvisor | vorhanden |
| Logging-Grundlagen mit Docker Compose | vorhanden |
| Secret-Handling über lokale Secret-Datei | vorhanden |
| `.gitignore`, `.dockerignore`, `.gitattributes` | vorhanden |
| strukturierte Dokumentation | vorhanden |
| Docker-Compose-Umgebungsdokumentation | vorhanden |
| Docker Cleanup Safety | vorhanden |
| Security-/Readiness-Dokumentation | vorhanden |
| finaler Daily-Operations-/Readiness-Check | vorhanden |
| NGINX Reverse Proxy | vorhanden |
| lokales HTTPS/TLS | vorhanden |
| Docker Log Rotation | vorhanden |
| Prometheus Target API Check | vorhanden |
| Container Security Stage 1 | vorhanden |
| Image Scanning mit Docker Scout | vorhanden |
| schlankeres NGINX-Basis-Image | vorhanden |
| lokale Registry mit Image v1.4 | vorhanden |
| Docker Image Pipeline mit GitHub Actions | vorhanden |
---

## Projektstruktur

```text
.
├── .github/
│   └── workflows/
├── app/
│   └── index.html
├── archive/
├── backups/
├── docs/
│   ├── architecture/
│   ├── labs/
│   ├── operations/
│   └── troubleshooting/
├── logs/
│   └── .gitkeep
├── monitoring/
│   ├── grafana/
│   └── prometheus/
├── scripts/
│   ├── backup/
│   ├── incidents/
│   ├── maintenance/
│   ├── restore/
│   ├── retention/
│   └── tests/
├── secrets/
│   └── .gitkeep
├── .dockerignore
├── .env.example
├── .gitattributes
├── .gitignore
├── compose.dev.yml
├── compose.monitoring.yml
├── compose.prod.yml
├── compose.registry-test.yml
├── Dockerfile
├── index.html
├── styles.css
└── README.md
```

---

## Wichtige Ordner

| Ordner | Zweck |
|---|---|
| `.github/workflows/` | GitHub-Actions-CI-Pipeline |
| `app/` | einfache Web-App / HTML-Datei |
| `docs/architecture/` | Architektur- und Strukturentscheidungen |
| `docs/labs/` | praktische Übungen und Simulationen |
| `docs/operations/` | Betriebsdokumentation, Backup, Logging, Readiness, Secrets |
| `docs/troubleshooting/` | Fehleranalyse und Wiederherstellung |
| `logs/` | lokale Logdateien; echte Logs werden nicht committed |
| `monitoring/` | Prometheus- und Grafana-Konfigurationen sowie Provisioning-Dateien |
| `scripts/backup/` | Backup-Skripte |
| `scripts/restore/` | Restore-/Testskripte |
| `scripts/retention/` | Aufbewahrungs-/GFS-Skripte |
| `scripts/incidents/` | Fehler- und Ausfallsimulationen |
| `scripts/tests/` | Betriebs- und Readiness-Prüfungen |
| `secrets/` | lokale Secret-Dateien; echte Secrets werden nicht committed |

---

## Voraussetzungen

Auf dem lokalen System werden benötigt:

```text
Docker Desktop
Docker Compose
PowerShell
Git
```

Das Projekt wurde unter Windows mit PowerShell entwickelt. Viele Konzepte sind aber auf Linux/macOS übertragbar.

---

## Lokale Vorbereitung

### 1. Repository klonen

```powershell
git clone https://github.com/MarcF46/docker-portfolio-lab.git
cd docker-portfolio-lab
```

### 2. Lokale Secret-Dateien erstellen

Redis und Grafana nutzen im Lab lokale Secret-Dateien.

```powershell
# Erstellt den lokalen Secret-Ordner.
New-Item -ItemType Directory -Force -Path .\secrets

# Erstellt eine lokale Redis-Passwortdatei, falls sie noch nicht existiert.
# SECURITY: Dies ist ein Lab-Wert. In Produktion würde ein Secret Manager genutzt.
if (-not (Test-Path .\secrets\redis_password.txt)) {
    Set-Content -Path .\secrets\redis_password.txt -Value "local_redis_password_please_change" -NoNewline
}

# Erstellt eine lokale Grafana-Admin-Passwortdatei, falls sie noch nicht existiert.
# SECURITY: Dies ist ein Lab-Wert. In Produktion würde ein Secret Manager genutzt.
if (-not (Test-Path .\secrets\grafana_admin_password.txt)) {
    Set-Content -Path .\secrets\grafana_admin_password.txt -Value "local_grafana_admin_password_please_change" -NoNewline
}
```

Prüfen, ob die Secret-Dateien ignoriert werden:

```powershell
git check-ignore -v secrets/redis_password.txt
git check-ignore -v secrets/grafana_admin_password.txt
```

Erwartung:

```text
Die lokalen Secret-Dateien werden durch .gitignore ignoriert.
```

---

## Development-Modus starten

```powershell
docker compose -f compose.dev.yml up -d --build
```

Status prüfen:

```powershell
docker compose -f compose.dev.yml ps
```

Stoppen:

```powershell
docker compose -f compose.dev.yml down
```

---

## Produktionsnahen Modus starten

```powershell
docker compose -f compose.prod.yml up -d --build
```

Status prüfen:

```powershell
docker compose -f compose.prod.yml ps
```

Die Web-App ist im produktionsnahen Modus über folgenden lokalen Port erreichbar:

```text
http://localhost:8082
```

Stoppen:

```powershell
docker compose -f compose.prod.yml down
```

---

## Compose-Konfiguration prüfen

Vor wichtigen Änderungen wird die finale Compose-Konfiguration geprüft:

```powershell
docker compose -f compose.prod.yml config
```

Dieser Befehl zeigt die von Docker Compose ausgewertete Konfiguration. Dadurch werden Syntaxfehler, Pfadfehler und aufgelöste Variablen sichtbar.

Security-Hinweis:

```text
docker compose config kann aufgelöste Secrets oder lokale Pfade sichtbar machen.
Ausgaben nicht ungeprüft teilen oder committen.
```

---

## Healthchecks

Der produktionsnahe Stack enthält Healthchecks für:

```text
web
redis
```

Web prüft, ob Nginx lokal im Container antwortet.

Redis prüft, ob Redis mit `PONG` antwortet. Der Redis-Healthcheck nutzt `REDISCLI_AUTH` und liest das Passwort aus der Secret-Datei im Container:

```text
/run/secrets/redis_password
```

Dadurch wird die unsaubere Passwortübergabe über `redis-cli -a` vermieden.

---

## Stack-Readiness-Check

Zusätzlich zu Docker-Healthchecks gibt es einen externen Readiness-Check:

```powershell
.\scripts\tests\test-stack-readiness.ps1
```

Dieser Check prüft:

```text
Docker-Compose-Status
Web-Erreichbarkeit über HTTP
Redis-Erreichbarkeit per PING/PONG
Gesamtergebnis mit Exit-Code
```

Erwartung bei gesundem Stack:

```text
[OK] Web-Service antwortet mit HTTP Status 200.
[OK] Redis antwortet korrekt mit PONG.
[OK] Stack ist aus Sicht des Readiness-Checks bereit.
```

---

## Redis-Ausfallsimulation

Ein realistischer Fehlerfall wird über das Skript simuliert:

```powershell
.\scripts\incidents\simulate-runtime-redis-outage.ps1
```

Das Skript:

```text
prüft den Ausgangszustand
beendet den Redis-Prozess kontrolliert
wartet auf Docker-Recovery
prüft den RestartCount
prüft Redis-Logs
bewertet das Ergebnis
gibt Zeitstempel aus
enthält Security-Hinweise
```

Der wichtigste Nachweis:

```text
RestartCount VORHER: 0
RestartCount NACHHER: 1
[OK] Die Restart Policy hat bei diesem simulierten Ausfall gegriffen.
```

---

## Backup und Restore

Das Projekt enthält Skripte und Dokumentation für Redis-Volume-Backups.

Wichtige Skripte:

```text
scripts/backup/backup-redis-volume.ps1
scripts/backup/backup-and-test-redis.ps1
scripts/restore/test-redis-restore.ps1
scripts/retention/cleanup-old-backups.ps1
scripts/retention/simulate-gfs-retention.ps1
```

Wichtige Dokumentation:

```text
docs/operations/backup-strategie-gfs.md
docs/troubleshooting/troubleshooting-backup-restore.md
```

Merksatz:

```text
Ein Backup ist erst dann belastbar, wenn ein Restore erfolgreich getestet wurde.
```

---

## Terminal-Session-Logging

Für Betriebs- und Incident-Übungen kann eine lokale PowerShell-Session mitgeschnitten werden:

```powershell
New-Item -ItemType Directory -Force -Path .\logs\terminal-sessions
Start-Transcript -Path ".\logs\terminal-sessions\session_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
```

Beenden:

```powershell
Stop-Transcript
```

Die Terminal-Mitschnitte werden durch `.gitignore` geschützt.

Security-Hinweis:

```text
Terminal-Logs können Secrets, Passwörter, Tokens, lokale Pfade oder interne Informationen enthalten.
Nicht committen.
Nicht ungeprüft teilen.
Vor Weitergabe auf sensible Inhalte prüfen.
```

Dokumentation:

```text
docs/operations/terminal-session-logging.md
```

---

## Security-Regeln im Projekt

Security wird im Projekt bewusst als wiederkehrendes Thema behandelt.

Wichtige Regeln:

```text
Keine echten Secrets committen.
Keine Passwörter in Screenshots zeigen.
Keine Terminal-Logs ungeprüft teilen.
Backups nicht nach GitHub hochladen.
Logs nicht committen.
Lokale Secret-Dateien durch .gitignore schützen.
Build-Kontext durch .dockerignore klein und sauber halten.
Bei einem Secret-Leak: Secret rotieren, nicht nur löschen.
```

Geschützte lokale Dateien und Ordner:

```text
.env
.env.*
secrets/redis_password.txt
secrets/grafana_admin_password.txt
backups/
logs/
logs/terminal-sessions/
Notizen/
```

---

## Git- und Build-Hygiene

Das Repository nutzt:

| Datei | Zweck |
|---|---|
| `.gitignore` | schützt Git vor lokalen, sensiblen oder generierten Dateien |
| `.dockerignore` | schützt den Docker-Build-Kontext vor unnötigen/sensiblen Dateien |
| `.gitattributes` | standardisiert Zeilenenden im Repository |

Build-Kontext prüfen:

```powershell
docker compose -f compose.prod.yml build web
```

---

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


## Monitoring mit Prometheus und Grafana
Das Projekt enthält ein kleines, bewusst begrenztes Monitoring-Lab:

```text
compose.monitoring.yml
```

Es ergänzt den produktionsnahen Stack um:

```text
Prometheus
Grafana
cAdvisor
```

Die Aufgabe der Komponenten:

| Komponente | Aufgabe im Lab |
|---|---|
| Prometheus | sammelt Metriken |
| Grafana | visualisiert Metriken in Dashboards |
| cAdvisor | stellt Container-Metriken bereit |

Lokale Weboberflächen:

| Tool | URL |
|---|---|
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| cAdvisor | http://localhost:8085 |

Der Monitoring-Stack wird zusammen mit dem produktionsnahen Stack gestartet:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml up -d --build
```

Verifikation:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml ps
Invoke-WebRequest -Uri http://localhost:9090/-/ready -UseBasicParsing
Invoke-WebRequest -Uri http://localhost:3000/api/health -UseBasicParsing
Invoke-WebRequest -Uri http://localhost:8085/metrics -UseBasicParsing
```

Im lokalen Lab wurden Prometheus und cAdvisor als `UP` erkannt. Grafana konnte das automatisch provisionierte Dashboard `Docker Portfolio Lab Overview` anzeigen.

Wichtige Einordnung:

```text
Das Monitoring-Lab zeigt die Grundidee von Metriken, Targets und Dashboards.
Es ist keine vollständige produktionsreife Observability-Plattform.
```

In Produktion wären zusätzlich nötig:

```text
Authentifizierung
TLS/HTTPS
Rollen- und Rechtekonzept
Alerting
Retention-Konzept
zentrale oder hochverfügbare Speicherung
sichere Netzwerkfreigaben
```

Dokumentation:

```text
docs/operations/monitoring-prometheus-grafana.md
docs/operations/grafana-monitoring-lab.md
```


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


## Dokumentation
Wichtige Dokumentationsdateien:

```text
docs/operations/README.md
docs/operations/docker-compose-environments.md
docs/operations/docker-final-readiness-check.md
docs/operations/docker-security-readiness.md
docs/operations/docker-cleanup-safety.md
docs/operations/docker-volume-backup-restore.md
docs/operations/backup-strategie-gfs.md
docs/operations/monitoring-prometheus-grafana.md
docs/operations/logging-basics.md
docs/operations/github-actions-ci.md
docs/operations/redis-secret-handling-healthcheck.md
docs/troubleshooting/troubleshooting-backup-restore.md
docs/labs/runtime-dependency-redis-outage.md
docs/architecture/projektstruktur-und-aufraeumplan.md
```

---

## Lab vs. Produktion

Das Projekt ist bewusst als Lern- und Portfolio-Lab aufgebaut.

| Thema | Lernprojekt | Produktion |
|---|---|---|
| Orchestrierung | Docker Compose lokal | Kubernetes, Cloud-Service, Swarm, Nomad |
| Secrets | lokale Secret-Datei | Vault, Cloud Secret Manager, Kubernetes Secrets |
| Monitoring | Skripte, Logs, `docker compose ps` | Prometheus, Grafana, Cloud Monitoring, SIEM |
| Backup | lokale TAR/GZ-Dateien | externe Speicherung, Verschlüsselung, Retention, Restore-Tests |
| Readiness | PowerShell-Skript | Load Balancer, Readiness Probe, Monitoring |
| Logging | lokale Logs und Transcripts | zentrale Logplattform, Zugriffsschutz, Retention |
| CI | GitHub Actions CI vorhanden: Compose prüfen, Web-Image bauen, Stack starten, Web + Redis testen | Pipeline mit Tests, Build, Security Checks, Quality Gates |
| CD/Deployment | noch nicht umgesetzt | Staging-/Production-Deployment mit Freigaben, Rollback und Monitoring |

Das Ziel ist nicht, Produktion vorzutäuschen, sondern wichtige Betriebsprinzipien praktisch zu trainieren.

---

## Typische Betriebsbefehle

```powershell
# Produktionsnahen Stack mit Monitoring starten
docker compose -f compose.prod.yml -f compose.monitoring.yml up -d --build

# Stack anzeigen
docker compose -f compose.prod.yml -f compose.monitoring.yml ps

# Compose-Konfiguration prüfen
docker compose -f compose.prod.yml -f compose.monitoring.yml config

# Logs anzeigen
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=80

# Daily Operations Check ausführen
powershell -ExecutionPolicy Bypass -File .\scripts\tests\test-daily-operations.ps1

# Redis-Ausfall simulieren
.\scripts\incidents\simulate-runtime-redis-outage.ps1

# Stack stoppen, ohne Volumes zu löschen
docker compose -f compose.prod.yml -f compose.monitoring.yml down

# Git-Status prüfen
git status --short
```

---

## Aktueller Lernstand

Der aktuelle Lernstand umfasst:

```text
Docker-Grundlagen
Compose Development/Production/Monitoring
Redis mit persistentem Volume
Backup und Restore
Retention/GFS-Dokumentation
Healthchecks
Restart Policies
Laufzeitausfall-Simulation
Readiness-Checks und Daily-Operations-Check
Terminal-Session-Logging
Secret-Handling
Logging-Grundlagen
Monitoring mit Prometheus/Grafana/cAdvisor
GitHub Actions CI
Repository-Hygiene
Dokumentation und Troubleshooting
```

---

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

Das Projekt ist als praxisnahes Lern- und Portfolio-Projekt für den Einstieg in Cloud-/DevOps-nahe Rollen angelegt.

Im Lab wurde nicht nur ein Docker-Stack gestartet. Der Fokus lag darauf, den Stack wie ein kleines Betriebssystem aus Services zu betrachten: mit Zuständen, Abhängigkeiten, Logs, Healthchecks, Backups, Security-Grenzen, Monitoring und wiederholbaren Prüfungen.

Besonders wichtig war dabei die Frage:

```text
Wie verhält sich der Stack, wenn im Betrieb etwas passiert?
```

Daraus entstanden mehrere praktische Nachweise:

- Container-Stacks wurden strukturiert aufgebaut, geprüft und nachvollziehbar dokumentiert.
- Betriebszustände wurden über Healthchecks, Readiness-Checks und Monitoring sichtbar gemacht.
- Fehlerfälle wurden simuliert, beobachtet und mit Logs sowie Statusausgaben eingeordnet.
- Persistente Daten, Backups und Restore-Tests wurden praktisch umgesetzt.
- Reverse Proxy, lokales HTTPS/TLS und interne Service-Kommunikation wurden im Lab nachvollzogen.
- Secret Handling, `.gitignore`, `.dockerignore` und sichere Dokumentation wurden konsequent berücksichtigt.
- Container-Logs wurden begrenzt und für grundlegende Log-Diagnose genutzt.
- Container-Security-Maßnahmen wie `no-new-privileges` wurden praktisch eingeordnet.
- Image-Scanning-Ergebnisse wurden ausgewertet und als Grundlage für eine kontrollierte technische Verbesserung genutzt.
- Ein schlankeres Basis-Image wurde getestet und übernommen.
- Registry-Grundlagen wie Tag, Push, Pull und Digest wurden praktisch nachvollzogen.
- GitHub Actions wurden genutzt, um Docker-Images und Compose-Stacks automatisiert zu prüfen.
- Technische Änderungen wurden mit Git versioniert und so dokumentiert, dass sie später nachvollziehbar bleiben.

Das Projekt erhebt keinen Anspruch auf vollständige Enterprise-Produktionsreife. Es zeigt aber wichtige Betriebsprinzipien, die für Junior-Rollen im Bereich Systemintegration, Cloud Engineering, DevOps und Plattformbetrieb relevant sind.
