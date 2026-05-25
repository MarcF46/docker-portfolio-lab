# Docker Portfolio Lab

Praxisnahes Docker-/DevOps-Portfolio mit Fokus auf Containerbetrieb, Troubleshooting, Backup/Restore, Healthchecks, Readiness-Checks, Secret-Handling, Logging, Monitoring und sauberer Repository-Struktur.

Dieses Repository ist bewusst kein reines Hello-World-Projekt. Es zeigt anhand eines kleinen containerisierten Stacks, dass Docker-Container nicht nur gestartet, sondern auch geprüft, dokumentiert, abgesichert und in realistischeren Betriebsfällen getestet werden können.

## Kurzüberblick

Dieses Projekt ist ein praxisnahes Docker-/DevOps-Lab für den Einstieg in Cloud-, DevOps-, Plattform- und Systemadministrationsrollen.

Es zeigt unter anderem:

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

## Was dieses Projekt nachweist

Dieses Projekt zeigt praktische Grundlagen für Junior-Rollen im Bereich Cloud, DevOps, Plattformbetrieb und Systemadministration:

- Ich kann Docker-Stacks strukturiert aufbauen, starten und prüfen.
- Ich kann Container-Zustände, Healthchecks und Readiness nachvollziehbar bewerten.
- Ich kann Persistenz, Backup und Restore dokumentieren und testen.
- Ich kann einfache Ausfälle simulieren und das Verhalten des Stacks analysieren.
- Ich achte auf Secret-Handling, `.gitignore`, `.dockerignore` und saubere Repository-Hygiene.
- Ich kann technische Arbeit so dokumentieren, dass andere sie nachvollziehen können.

> Hinweis: Dieses Projekt ist ein Lern- und Portfolio-Lab. Es ist bewusst produktionsnah aufgebaut, ersetzt aber keine vollständige Enterprise-Produktionsumgebung.
Praxisnahes Docker-/DevOps-Lernprojekt mit Fokus auf Betrieb, Troubleshooting, Backup/Restore, Healthchecks, Readiness-Checks, Secret-Handling und sauberer Repository-Struktur.

Dieses Repository ist bewusst **kein reines Hello-World-Projekt**. Es dient als Junior-Portfolio-Projekt, um zu zeigen, dass Docker-Container nicht nur gestartet, sondern auch geprüft, dokumentiert, abgesichert und in realistischeren Betriebsfällen getestet werden können.

---

## Ziel des Projekts

Dieses Projekt trainiert Grundlagen für einen Einstieg als:

```text
Junior Cloud Engineer
Junior DevOps Engineer
Junior Platform Engineer
Junior System Engineer mit Cloud-/Container-Fokus
```

Im Mittelpunkt stehen nicht nur einzelne Docker-Befehle, sondern typische Betriebsfragen:

```text
Startet der Stack sauber?
Sind die Container wirklich healthy?
Was passiert, wenn Redis ausfällt?
Bleiben Daten nach Container-Neustarts erhalten?
Gibt es Backup und Restore?
Wird ein Restore wirklich getestet?
Sind Logs, Backups und Secrets geschützt?
Ist der Stack aus Betriebssicht bereit?
```

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

---

## Projektstruktur

```text
.
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
├── compose.prod.yml
├── Dockerfile
└── README.md
```

---

## Wichtige Ordner

| Ordner | Zweck |
|---|---|
| `app/` | einfache Web-App / HTML-Datei |
| `docs/architecture/` | Architektur- und Strukturentscheidungen |
| `docs/labs/` | praktische Übungen und Simulationen |
| `docs/operations/` | Betriebsdokumentation, Backup, Logging, Readiness, Secrets |
| `docs/troubleshooting/` | Fehleranalyse und Wiederherstellung |
| `logs/` | lokale Logdateien; echte Logs werden nicht committed |
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

### 2. Lokale Secret-Datei erstellen

Redis nutzt im produktionsnahen Compose-Modus ein lokales Secret.

```powershell
# Erstellt den lokalen Secret-Ordner.
New-Item -ItemType Directory -Force -Path .\secrets

# Erstellt eine lokale Redis-Passwortdatei.
# SECURITY: Dies ist ein Lab-Wert. In Produktion würde ein Secret Manager genutzt.
if (-not (Test-Path .\secrets\redis_password.txt)) {
    Set-Content -Path .\secrets\redis_password.txt -Value "local_redis_password_please_change" -NoNewline
}
```

Prüfen, ob die Secret-Datei ignoriert wird:

```powershell
git check-ignore -v secrets/redis_password.txt
```

Erwartung:

```text
secrets/redis_password.txt wird durch .gitignore ignoriert
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
[OK] Stack ist aus Sicht dieses Readiness-Checks bereit.
```

---

## Redis-Ausfallsimulation

Ein realistischer Fehlerfall wird über dieses Skript simuliert:

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

Dieses Projekt behandelt Security bewusst als wiederkehrendes Thema.

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
docs/operations/backup-strategie-gfs.md
docs/operations/redis-secret-handling-healthcheck.md
docs/operations/stack-readiness-check.md
docs/operations/terminal-session-logging.md
docs/troubleshooting/troubleshooting-backup-restore.md
docs/labs/runtime-dependency-redis-outage.md
docs/labs/runtime-dependency-redis-outage-enterprise.md
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
| Backup | lokale TAR/GZ-Dateien | externe Speicherung, Verschlüsselung, Retention, Restore-Tests |
| Readiness | PowerShell-Skript | Load Balancer, Readiness Probe, Monitoring |
| Logging | lokale Logs und Transcripts | zentrale Logplattform, Zugriffsschutz, Retention |
| CI | GitHub Actions CI vorhanden: Compose prüfen, Web-Image bauen, Stack starten, Web + Redis testen | Pipeline mit Tests, Build, Security Checks, Quality Gates |
| CD/Deployment | noch nicht umgesetzt | Staging-/Production-Deployment mit Freigaben, Rollback und Monitoring |

Das Ziel ist nicht, Production vorzutäuschen, sondern wichtige Betriebsprinzipien praktisch zu trainieren.

---

## Typische Betriebsbefehle

```powershell
# Stack starten
docker compose -f compose.prod.yml up -d --build

# Stack anzeigen
docker compose -f compose.prod.yml ps

# Compose-Konfiguration prüfen
docker compose -f compose.prod.yml config

# Logs anzeigen
docker compose -f compose.prod.yml logs --tail=80

# Readiness prüfen
.\scripts\tests\test-stack-readiness.ps1

# Redis-Ausfall simulieren
.\scripts\incidents\simulate-runtime-redis-outage.ps1

# Stack stoppen
docker compose -f compose.prod.yml down

# Git-Status prüfen
git status
```

---

## Aktueller Lernstand

Dieses Projekt zeigt aktuell:

```text
Docker-Grundlagen
Compose Development/Production
Redis mit persistentem Volume
Backup und Restore
Retention/GFS-Dokumentation
Healthchecks
Restart Policies
Laufzeitausfall-Simulation
Readiness-Checks
Terminal-Session-Logging
Secret-Handling
Repository-Hygiene
Dokumentation und Troubleshooting
```

---

## Geplanter Ausbau

Mögliche nächste Schritte:

```text
CI-Fehlerübungen und GitHub-Actions-Log-Diagnose
erweiterte CI-Prüfungen, z. B. Script-Checks, Security-Checks und Build-Fehler-Simulationen
Monitoring-Fehlerübungen und erste Alerting-Grundlagen
strukturierte Application Logs
Reverse Proxy
HTTPS im Lab
Kubernetes-Grundlagen
Deployment-/Rollback-Szenarien
Secret-Rotation als Übung
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
Ich kann Betriebszustände prüfen.
Ich kann Fehlerfälle simulieren.
Ich kann Backups und Restore-Tests dokumentieren.
Ich beachte Security- und Secret-Handling.
Ich kann eine Repository-Struktur nachvollziehbar aufbauen.
Ich kann technische Änderungen mit Git sauber versionieren.
```




