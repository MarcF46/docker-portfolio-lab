# Docker Portfolio Lab

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
| CI/CD | noch nicht vollständig umgesetzt | Pipeline mit Tests, Build, Security Checks |

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
GitHub Actions / CI-Prüfungen
automatischer Compose-Config-Check bei Push
einfaches Monitoring mit Prometheus/Grafana
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
