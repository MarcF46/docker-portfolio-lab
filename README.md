# Docker Portfolio Lab

Praxisnahes Docker-/DevOps-Portfolio mit Fokus auf Containerbetrieb, Troubleshooting, Backup/Restore, Healthchecks, Readiness-Checks, Reverse Proxy, HTTPS, Secret-Handling, Logging, Monitoring, Container Security, Image Scanning, Registry-Grundlagen, CI/CD und sauberer Repository-Struktur.

Dieses Repository ist bewusst kein reines Startbeispiel. Es zeigt anhand eines kleinen containerisierten Stacks, dass Docker-Container nicht nur gestartet, sondern auch geprÃ¼ft, dokumentiert, abgesichert, Ã¼ber Reverse Proxy/HTTPS bereitgestellt, gescannt und in realistischeren BetriebsfÃ¤llen getestet werden kÃ¶nnen.

## KurzÃ¼berblick

Dieses Projekt ist ein praxisnahes Docker-/DevOps-Lab fÃ¼r den Einstieg in Cloud-, DevOps-, Plattform- und Systemadministrationsrollen.

Es zeigt unter anderem:

- Aufbau eines containerisierten Web-/Redis-Stacks mit Docker Compose
- Trennung zwischen Development- und produktionsnaher Compose-Konfiguration
- persistente Redis-Datenhaltung Ã¼ber Docker Volumes
- Healthchecks und Stack-Readiness-Checks
- Backup und getesteter Restore
- NGINX Reverse Proxy mit lokalem HTTPS/TLS
- Secret-Handling ohne Commit echter Secrets
- Docker Log Rotation und Logging-Grundlagen
- Monitoring-Lab mit Prometheus, Grafana, cAdvisor und Target-API-PrÃ¼fung
- Container Security Stage 1 mit `no-new-privileges`
- Image Scanning mit Docker Scout und Wechsel auf `nginx:alpine-slim`
- lokale Registry mit Tag-/Digest-Grundlagen
- GitHub Actions CI und separate Docker Image Pipeline
- Simulation typischer Betriebs- und FehlerfÃ¤lle

## Was dieses Projekt nachweist

Dieses Projekt zeigt praktische Grundlagen fÃ¼r Junior-Rollen im Bereich Cloud, DevOps, Plattformbetrieb und Systemadministration:

- Ich kann Docker-Stacks strukturiert aufbauen, starten und prÃ¼fen.
- Ich kann Container-ZustÃ¤nde, Healthchecks und Readiness nachvollziehbar bewerten.
- Ich kann Persistenz, Backup und Restore dokumentieren und testen.
- Ich kann Reverse Proxy, lokales HTTPS/TLS und interne Service-Kommunikation einordnen.
- Ich kann einfache AusfÃ¤lle simulieren und das Verhalten des Stacks analysieren.
- Ich achte auf Secret-Handling, `.gitignore`, `.dockerignore` und saubere Repository-Hygiene.
- Ich kann Container-Security-Grundlagen wie `no-new-privileges`, Capabilities und Log Rotation erklÃ¤ren.
- Ich kann Image-Scanning-Ergebnisse bewerten und ein schlankeres Basis-Image kontrolliert testen.
- Ich kann Registry-Grundlagen wie Tag, Push, Pull und Digest praktisch nachweisen.
- Ich kann technische Arbeit so dokumentieren, dass andere sie nachvollziehen kÃ¶nnen.

> Hinweis: Dieses Projekt ist ein Lern- und Portfolio-Lab. Es ist bewusst produktionsnah aufgebaut, ersetzt aber keine vollstÃ¤ndige Enterprise-Produktionsumgebung.

---

## Ziel des Projekts

Ziel dieses Projekts ist es, Docker nicht nur als Startbefehl zu lernen, sondern aus Betriebssicht zu verstehen.

Das Projekt trainiert Grundlagen fÃ¼r einen Einstieg als:

- Junior Cloud Engineer
- Junior DevOps Engineer
- Junior Platform Engineer
- Junior System Engineer mit Cloud-/Container-Fokus

Im Mittelpunkt stehen typische Betriebsfragen:

- Startet der Stack sauber?
- Sind die Container wirklich healthy?
- Funktioniert HTTPS Ã¼ber den Reverse Proxy?
- Was passiert, wenn Redis oder Monitoring-Komponenten ausfallen?
- Bleiben Daten nach Container-Neustarts erhalten?
- Gibt es Backup und Restore?
- Wurde ein Restore erfolgreich getestet?
- Sind Logs, Backups, Zertifikate und Secrets geschÃ¼tzt?
- Welche bekannten Schwachstellen enthÃ¤lt das Image?
- Kann das Image aus einer Registry genutzt werden?
- Ist der Stack aus Betriebssicht bereit?

---

## Aktueller Projektumfang

| Bereich | Status |
|---|---|
| Dockerfile fÃ¼r Webcontainer | vorhanden |
| Development-Compose-Datei | vorhanden |
| produktionsnahe Compose-Datei | vorhanden |
| Redis mit persistentem Docker Volume | vorhanden |
| Redis-Persistenz mit AOF | vorhanden |
| Backup-Skripte | vorhanden |
| Restore-Test | vorhanden |
| Retention-/GFS-Dokumentation | vorhanden |
| Healthchecks fÃ¼r Web und Redis | vorhanden |
| Start-AbhÃ¤ngigkeit `web -> redis healthy` | vorhanden |
| Restart Policy | vorhanden |
| Redis-Ausfallsimulation | vorhanden |
| Stack-Readiness-Check | vorhanden |
| Terminal-Session-Logging-Dokumentation | vorhanden |
| Monitoring-Lab mit Prometheus, Grafana und cAdvisor | vorhanden |
| Logging-Grundlagen mit Docker Compose | vorhanden |
| Secret-Handling Ã¼ber lokale Secret-Datei | vorhanden |
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
â”œâ”€â”€ .github/
â”‚   â””â”€â”€ workflows/
â”œâ”€â”€ app/
â”‚   â””â”€â”€ index.html
â”œâ”€â”€ archive/
â”œâ”€â”€ backups/
â”œâ”€â”€ docs/
â”‚   â”œâ”€â”€ architecture/
â”‚   â”œâ”€â”€ labs/
â”‚   â”œâ”€â”€ operations/
â”‚   â””â”€â”€ troubleshooting/
â”œâ”€â”€ logs/
â”‚   â””â”€â”€ .gitkeep
â”œâ”€â”€ monitoring/
â”‚   â”œâ”€â”€ grafana/
â”‚   â””â”€â”€ prometheus/
â”œâ”€â”€ scripts/
â”‚   â”œâ”€â”€ backup/
â”‚   â”œâ”€â”€ incidents/
â”‚   â”œâ”€â”€ maintenance/
â”‚   â”œâ”€â”€ restore/
â”‚   â”œâ”€â”€ retention/
â”‚   â””â”€â”€ tests/
â”œâ”€â”€ secrets/
â”‚   â””â”€â”€ .gitkeep
â”œâ”€â”€ .dockerignore
â”œâ”€â”€ .env.example
â”œâ”€â”€ .gitattributes
â”œâ”€â”€ .gitignore
â”œâ”€â”€ compose.dev.yml
â”œâ”€â”€ compose.monitoring.yml
â”œâ”€â”€ compose.prod.yml
â”œâ”€â”€ compose.registry-test.yml
â”œâ”€â”€ Dockerfile
â”œâ”€â”€ index.html
â”œâ”€â”€ styles.css
â””â”€â”€ README.md
```

---

## Wichtige Ordner

| Ordner | Zweck |
|---|---|
| `.github/workflows/` | GitHub-Actions-CI-Pipeline |
| `app/` | einfache Web-App / HTML-Datei |
| `docs/architecture/` | Architektur- und Strukturentscheidungen |
| `docs/labs/` | praktische Ãœbungen und Simulationen |
| `docs/operations/` | Betriebsdokumentation, Backup, Logging, Readiness, Secrets |
| `docs/troubleshooting/` | Fehleranalyse und Wiederherstellung |
| `logs/` | lokale Logdateien; echte Logs werden nicht committed |
| `monitoring/` | Prometheus- und Grafana-Konfigurationen sowie Provisioning-Dateien |
| `scripts/backup/` | Backup-Skripte |
| `scripts/restore/` | Restore-/Testskripte |
| `scripts/retention/` | Aufbewahrungs-/GFS-Skripte |
| `scripts/incidents/` | Fehler- und Ausfallsimulationen |
| `scripts/tests/` | Betriebs- und Readiness-PrÃ¼fungen |
| `secrets/` | lokale Secret-Dateien; echte Secrets werden nicht committed |

---

## Voraussetzungen

Auf dem lokalen System werden benÃ¶tigt:

```text
Docker Desktop
Docker Compose
PowerShell
Git
```

Das Projekt wurde unter Windows mit PowerShell entwickelt. Viele Konzepte sind aber auf Linux/macOS Ã¼bertragbar.

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
# SECURITY: Dies ist ein Lab-Wert. In Produktion wÃ¼rde ein Secret Manager genutzt.
if (-not (Test-Path .\secrets\redis_password.txt)) {
    Set-Content -Path .\secrets\redis_password.txt -Value "local_redis_password_please_change" -NoNewline
}

# Erstellt eine lokale Grafana-Admin-Passwortdatei, falls sie noch nicht existiert.
# SECURITY: Dies ist ein Lab-Wert. In Produktion wÃ¼rde ein Secret Manager genutzt.
if (-not (Test-Path .\secrets\grafana_admin_password.txt)) {
    Set-Content -Path .\secrets\grafana_admin_password.txt -Value "local_grafana_admin_password_please_change" -NoNewline
}
```

PrÃ¼fen, ob die Secret-Dateien ignoriert werden:

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

Status prÃ¼fen:

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

Status prÃ¼fen:

```powershell
docker compose -f compose.prod.yml ps
```

Die Web-App ist im produktionsnahen Modus Ã¼ber folgenden lokalen Port erreichbar:

```text
http://localhost:8082
```

Stoppen:

```powershell
docker compose -f compose.prod.yml down
```

---

## Compose-Konfiguration prÃ¼fen

Vor wichtigen Ã„nderungen wird die finale Compose-Konfiguration geprÃ¼ft:

```powershell
docker compose -f compose.prod.yml config
```

Dieser Befehl zeigt die von Docker Compose ausgewertete Konfiguration. Dadurch werden Syntaxfehler, Pfadfehler und aufgelÃ¶ste Variablen sichtbar.

Security-Hinweis:

```text
docker compose config kann aufgelÃ¶ste Secrets oder lokale Pfade sichtbar machen.
Ausgaben nicht ungeprÃ¼ft teilen oder committen.
```

---

## Healthchecks

Der produktionsnahe Stack enthÃ¤lt Healthchecks fÃ¼r:

```text
web
redis
```

Web prÃ¼ft, ob Nginx lokal im Container antwortet.

Redis prÃ¼ft, ob Redis mit `PONG` antwortet. Der Redis-Healthcheck nutzt `REDISCLI_AUTH` und liest das Passwort aus der Secret-Datei im Container:

```text
/run/secrets/redis_password
```

Dadurch wird die unsaubere PasswortÃ¼bergabe Ã¼ber `redis-cli -a` vermieden.

---

## Stack-Readiness-Check

ZusÃ¤tzlich zu Docker-Healthchecks gibt es einen externen Readiness-Check:

```powershell
.\scripts\tests\test-stack-readiness.ps1
```

Dieser Check prÃ¼ft:

```text
Docker-Compose-Status
Web-Erreichbarkeit Ã¼ber HTTP
Redis-Erreichbarkeit per PING/PONG
Gesamtergebnis mit Exit-Code
```

Erwartung bei gesundem Stack:

```text
[OK] Web-Service antwortet mit HTTP Status 200.
[OK] Redis antwortet korrekt mit PONG.
[OK] Stack ist aus Sicht dieses Readiness-Checks bereit.
```

---

## Redis-Ausfallsimulation

Ein realistischer Fehlerfall wird Ã¼ber dieses Skript simuliert:

```powershell
.\scripts\incidents\simulate-runtime-redis-outage.ps1
```

Das Skript:

```text
prÃ¼ft den Ausgangszustand
beendet den Redis-Prozess kontrolliert
wartet auf Docker-Recovery
prÃ¼ft den RestartCount
prÃ¼ft Redis-Logs
bewertet das Ergebnis
gibt Zeitstempel aus
enthÃ¤lt Security-Hinweise
```

Der wichtigste Nachweis:

```text
RestartCount VORHER: 0
RestartCount NACHHER: 1
[OK] Die Restart Policy hat bei diesem simulierten Ausfall gegriffen.
```

---

## Backup und Restore

Das Projekt enthÃ¤lt Skripte und Dokumentation fÃ¼r Redis-Volume-Backups.

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

FÃ¼r Betriebs- und Incident-Ãœbungen kann eine lokale PowerShell-Session mitgeschnitten werden:

```powershell
New-Item -ItemType Directory -Force -Path .\logs\terminal-sessions
Start-Transcript -Path ".\logs\terminal-sessions\session_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
```

Beenden:

```powershell
Stop-Transcript
```

Die Terminal-Mitschnitte werden durch `.gitignore` geschÃ¼tzt.

Security-Hinweis:

```text
Terminal-Logs kÃ¶nnen Secrets, PasswÃ¶rter, Tokens, lokale Pfade oder interne Informationen enthalten.
Nicht committen.
Nicht ungeprÃ¼ft teilen.
Vor Weitergabe auf sensible Inhalte prÃ¼fen.
```

Dokumentation:

```text
docs/operations/terminal-session-logging.md
```

---

## Security-Regeln im Projekt

Dieses Projekt behandelt Security bewusst als wiederkehrendes Thema.

Wichtige Regeln:

```text
Keine echten Secrets committen.
Keine PasswÃ¶rter in Screenshots zeigen.
Keine Terminal-Logs ungeprÃ¼ft teilen.
Backups nicht nach GitHub hochladen.
Logs nicht committen.
Lokale Secret-Dateien durch .gitignore schÃ¼tzen.
Build-Kontext durch .dockerignore klein und sauber halten.
Bei einem Secret-Leak: Secret rotieren, nicht nur lÃ¶schen.
```

GeschÃ¼tzte lokale Dateien und Ordner:

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

Dieses Repository nutzt:

| Datei | Zweck |
|---|---|
| `.gitignore` | schÃ¼tzt Git vor lokalen, sensiblen oder generierten Dateien |
| `.dockerignore` | schÃ¼tzt den Docker-Build-Kontext vor unnÃ¶tigen/sensiblen Dateien |
| `.gitattributes` | standardisiert Zeilenenden im Repository |

Build-Kontext prÃ¼fen:

```powershell
docker compose -f compose.prod.yml build web
```

---

## Operations-Dokumentation

Die betriebsnahen Dokumente sind in einer eigenen Ãœbersicht zusammengefasst:

```text
docs/operations/README.md
```

Dort sind die wichtigsten Betriebsbereiche des Labs gebÃ¼ndelt:

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

Diese Ãœbersicht erleichtert das Lesen des Projekts und zeigt, welche praktischen Cloud-/DevOps-Grundlagen im Lab nachgewiesen werden.


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
Browseraktion â†’ Webcontainer â†’ Logzeile erscheint live im Terminal
```

Fachliche Einordnung:

| Logtyp | Beispiel | Bedeutung |
|---|---|---|
| Healthcheck-Zugriff | `Wget` mit HTTP 200 | normaler automatischer Healthcheck |
| Browserzugriff | `Mozilla/5.0` und `?test=logcheck` | bewusst ausgelÃ¶ster Zugriff |
| cAdvisor-Warnung | fehlende `machine-id` / `system UUID` | Docker-Desktop-/WSL2-Hinweis, im Lab nicht fatal |

Security-Hinweis:

```text
Logs kÃ¶nnen sensible Informationen enthalten.
Terminal-Ausgaben und Screenshots mÃ¼ssen vor Ã¶ffentlicher Nutzung geprÃ¼ft werden.
Secrets, Tokens und personenbezogene Daten dÃ¼rfen nicht in Ã¶ffentliche Logs oder Screenshots gelangen.
```


## Monitoring mit Prometheus und Grafana
Das Projekt enthÃ¤lt ein kleines, bewusst begrenztes Monitoring-Lab:

```text
compose.monitoring.yml
```

Es ergÃ¤nzt den produktionsnahen Stack um:

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

Lokale WeboberflÃ¤chen:

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
Es ist keine vollstÃ¤ndige produktionsreife Observability-Plattform.
```

In Produktion wÃ¤ren zusÃ¤tzlich nÃ¶tig:

```text
Authentifizierung
TLS/HTTPS
Rollen- und Rechtekonzept
Alerting
Retention-Konzept
zentrale oder hochverfÃ¼gbare Speicherung
sichere Netzwerkfreigaben
```

Dokumentation:

```text
docs/operations/monitoring-prometheus-grafana.md
```


## GitHub Actions CI
Das Repository enthÃ¤lt eine erste GitHub-Actions-CI-Pipeline:

```text
.github/workflows/docker-lab-ci.yml
```

Die Pipeline lÃ¤uft automatisch bei Push auf `main` und bei Pull Requests.

Sie prÃ¼ft:

```text
Docker-Versionen anzeigen
lokale CI-Secret-Datei im Runner erzeugen
docker compose config ausfÃ¼hren
Web-Image bauen
Stack starten
Web per HTTP prÃ¼fen
Redis per PING/PONG prÃ¼fen
bei Fehlern Logs anzeigen
Stack aufrÃ¤umen
```

Damit wird nicht nur die Compose-Datei geprÃ¼ft, sondern der Stack im GitHub-Actions-Runner tatsÃ¤chlich gestartet und getestet.

Security-Hinweis:

```text
Das CI-Secret wird nur im kurzlebigen GitHub-Actions-Runner erzeugt.
Es wird nicht committed und nicht im Workflow ausgegeben.
FÃ¼r echte produktive Secrets wÃ¤ren GitHub Actions Secrets, Vault oder ein Cloud Secret Manager nÃ¶tig.
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

Dieses Projekt ist bewusst ein Lern- und Portfolio-Lab.

| Thema | Lernprojekt | Produktion |
|---|---|---|
| Orchestrierung | Docker Compose lokal | Kubernetes, Cloud-Service, Swarm, Nomad |
| Secrets | lokale Secret-Datei | Vault, Cloud Secret Manager, Kubernetes Secrets |
| Monitoring | Skripte, Logs, `docker compose ps` | Prometheus, Grafana, Cloud Monitoring, SIEM |
| Backup | lokale TAR/GZ-Dateien | externe Speicherung, VerschlÃ¼sselung, Retention, Restore-Tests |
| Readiness | PowerShell-Skript | Load Balancer, Readiness Probe, Monitoring |
| Logging | lokale Logs und Transcripts | zentrale Logplattform, Zugriffsschutz, Retention |
| CI | GitHub Actions CI vorhanden: Compose prÃ¼fen, Web-Image bauen, Stack starten, Web + Redis testen | Pipeline mit Tests, Build, Security Checks, Quality Gates |
| CD/Deployment | noch nicht umgesetzt | Staging-/Production-Deployment mit Freigaben, Rollback und Monitoring |

Das Ziel ist nicht, Produktion vorzutÃ¤uschen, sondern wichtige Betriebsprinzipien praktisch zu trainieren.

---

## Typische Betriebsbefehle

```powershell
# Produktionsnahen Stack mit Monitoring starten
docker compose -f compose.prod.yml -f compose.monitoring.yml up -d --build

# Stack anzeigen
docker compose -f compose.prod.yml -f compose.monitoring.yml ps

# Compose-Konfiguration prÃ¼fen
docker compose -f compose.prod.yml -f compose.monitoring.yml config

# Logs anzeigen
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=80

# Daily Operations Check ausfÃ¼hren
powershell -ExecutionPolicy Bypass -File .\scripts\tests\test-daily-operations.ps1

# Redis-Ausfall simulieren
.\scripts\incidents\simulate-runtime-redis-outage.ps1

# Stack stoppen, ohne Volumes zu lÃ¶schen
docker compose -f compose.prod.yml -f compose.monitoring.yml down

# Git-Status prÃ¼fen
git status --short
```

---

## Aktueller Lernstand

Dieses Projekt zeigt aktuell:

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

## MÃ¶gliche spÃ¤tere Ausbaustufen

MÃ¶gliche nÃ¤chste Schritte:

```text
CI-FehlerÃ¼bungen und GitHub-Actions-Log-Diagnose
erweiterte CI-PrÃ¼fungen, z. B. Script-Checks, Security-Checks und Build-Fehler-Simulationen
Monitoring-FehlerÃ¼bungen und erste Alerting-Grundlagen
strukturierte Application Logs
Reverse Proxy
HTTPS im Lab
Kubernetes-Grundlagen
Deployment-/Rollback-Szenarien
Secret-Rotation als Ãœbung
```

---

## Portfolio-Einordnung

Dieses Projekt ist ein praxisnahes Lern- und Portfolio-Projekt fÃ¼r den Einstieg in Cloud-/DevOps-nahe Rollen.

Es zeigt nicht nur:

```text
Ich kann Docker starten.
```

Sondern auch:

```text
Ich kann BetriebszustÃ¤nde prÃ¼fen.
Ich kann FehlerfÃ¤lle simulieren.
Ich kann Backups und Restore-Tests dokumentieren.
Ich beachte Security- und Secret-Handling.
Ich kann eine Repository-Struktur nachvollziehbar aufbauen.
Ich kann technische Ã„nderungen mit Git sauber versionieren.
```

