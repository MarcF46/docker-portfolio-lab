# Daily Operations Runbook

## Zweck

Dieses Runbook beschreibt einen kompakten Standardablauf für den täglichen Betrieb des Docker Portfolio Lab.

Ein **Runbook** ist eine Schritt-für-Schritt-Anleitung für wiederkehrende Betriebsaufgaben. Es hilft dabei, nicht jedes Mal neu überlegen zu müssen, sondern einen sauberen, wiederholbaren Ablauf zu haben.

Ziel dieses Dokuments:

```text
Stack starten
Status prüfen
Readiness prüfen
Logs ansehen
Monitoring prüfen
Secrets schützen
sauber stoppen
Ergebnisse nachvollziehbar dokumentieren
```

---

## 1. Job-Szenario

Ein Teamlead sagt:

> „Das Lab enthält inzwischen Web, Redis, Secrets, Healthchecks, Readiness Checks, GitHub Actions CI, Monitoring und Logging. Bitte dokumentiere einen kurzen Standardablauf, wie man den Stack im Alltag prüft und betreibt.“

---

## 2. Betriebsanforderung

| Anforderung | Bedeutung |
|---|---|
| Stack reproduzierbar starten | Dienste sollen zuverlässig hochfahren |
| Status schnell prüfen | Containerstatus und Healthchecks sichtbar machen |
| Readiness fachlich prüfen | Web und Redis müssen wirklich nutzbar sein |
| Logs gezielt prüfen | Warnungen und Fehler einordnen |
| Monitoring prüfen | Prometheus, Grafana und cAdvisor validieren |
| Secrets schützen | keine Passwortdateien committen oder anzeigen |
| Git sauber halten | Änderungen bewusst committen |
| ohne Datenverlust stoppen | Volumes nicht versehentlich löschen |

---

## 3. Voraussetzungen

Projektordner:

```text
C:\Docker Übung
```

Wichtige Dateien:

```text
compose.prod.yml
compose.monitoring.yml
secrets/redis_password.txt
secrets/grafana_admin_password.txt
scripts/tests/test-stack-readiness.ps1
docs/operations/
```

Wichtige lokale Ports:

| Dienst | URL |
|---|---|
| Web-App | http://localhost:8082 |
| Prometheus | http://localhost:9090 |
| Grafana | http://localhost:3000 |
| cAdvisor | http://localhost:8085 |

---

## 4. Standardablauf: Projektordner öffnen

```powershell
# Wechselt sicher in den Projektordner.
# Erwartung: Alle folgenden Befehle werden im richtigen Projektkontext ausgeführt.
cd "C:\Docker Übung"

# Prüft, ob Git sauber ist.
# Erwartung: Vor neuen Arbeiten möglichst "nothing to commit, working tree clean".
git status
```

---

## 5. Stack starten

### Nur Production-Stack starten

```powershell
# Startet Web und Redis im produktionsnahen Modus.
# Erwartung: web und redis werden gestartet.
docker compose -f compose.prod.yml up -d --build

# Zeigt den Status der Production-Services.
# Erwartung: web und redis sind Up/healthy.
docker compose -f compose.prod.yml ps
```

### Production + Monitoring starten

```powershell
# Startet Web, Redis sowie Prometheus, Grafana und cAdvisor.
# Erwartung: alle Services werden gestartet.
docker compose -f compose.prod.yml -f compose.monitoring.yml up -d --build

# Zeigt den Status aller Services.
# Erwartung: web, redis, prometheus, grafana und cadvisor sind Up/healthy.
docker compose -f compose.prod.yml -f compose.monitoring.yml ps
```

---

## 6. Stackstatus prüfen

```powershell
# Zeigt den Status des gesamten Stacks.
# Erwartung: alle relevanten Services sind Up/healthy.
docker compose -f compose.prod.yml -f compose.monitoring.yml ps
```

Wichtige Einordnung:

| Status | Bedeutung |
|---|---|
| `Up` | Container läuft |
| `healthy` | Healthcheck erfolgreich |
| `starting` | Healthcheck läuft noch an |
| `unhealthy` | Healthcheck schlägt fehl |
| `Exited` | Container ist gestoppt |

---

## 7. Fachliche Readiness prüfen

Ein Container kann laufen, aber der Dienst kann trotzdem fachlich nicht nutzbar sein. Deshalb gibt es zusätzlich einen Readiness-Check.

```powershell
# Führt den externen Stack-Readiness-Check aus.
# Erwartung: Web antwortet mit HTTP 200 und Redis antwortet mit PONG.
.\scripts\tests\test-stack-readiness.ps1
```

Einordnung:

```text
Containerstatus zeigt: Läuft der Container?
Healthcheck zeigt: Ist der Dienst technisch gesund?
Readiness Check zeigt: Ist der Stack aus Nutzersicht bereit?
```

---

## 8. Web und Redis manuell prüfen

### Web prüfen

```powershell
# Prüft die Web-App per HTTP.
# Erwartung: StatusCode 200.
Invoke-WebRequest -Uri http://localhost:8082 -UseBasicParsing
```

### Redis prüfen

```powershell
# Prüft Redis im Container per PING.
# REDISCLI_AUTH liest das Passwort aus der Secret-Datei im Container.
# Erwartung: PONG.
docker compose -f compose.prod.yml exec redis sh -c 'REDISCLI_AUTH="$(cat /run/secrets/redis_password)" redis-cli ping'
```

Security-Hinweis:

```text
Das Redis-Passwort wird nicht im Klartext in den Befehl geschrieben.
Es wird aus der Secret-Datei im Container gelesen.
```

---

## 9. Logs prüfen

### Kurzer Überblick

```powershell
# Zeigt die letzten 10 Logzeilen aller Services.
# Erwartung: kurzer Überblick ohne zu viele alte Meldungen.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=10
```

### Service gezielt prüfen

```powershell
# Zeigt die letzten 20 Web-Logs.
# Erwartung: Healthcheck-Zugriffe oder Browserzugriffe sind sichtbar.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 web

# Zeigt die letzten 20 Redis-Logs.
# Erwartung: Redis läuft ohne akuten Fehler.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 redis

# Zeigt die letzten 20 Prometheus-Logs.
# Erwartung: keine Konfigurationsfehler.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 prometheus

# Zeigt die letzten 20 Grafana-Logs.
# Erwartung: Grafana läuft, Provisioning ist geladen.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 grafana

# Zeigt die letzten 20 cAdvisor-Logs.
# Erwartung: mögliche Docker-Desktop-/WSL2-Hinweise, aber kein fataler Ausfall.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 cadvisor
```

### Zeitlich eingrenzen

```powershell
# Zeigt nur Logs der letzten 10 Minuten.
# Erwartung: alte Meldungen werden ausgeblendet.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --since=10m
```

### Live-Logs beobachten

```powershell
# Beobachtet Web-Logs live.
# Erwartung: Browserzugriffe erscheinen sofort im Terminal.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --follow --tail=5 web
```

Dann im Browser öffnen:

```text
http://localhost:8082/?test=logcheck
```

Danach im PowerShell-Terminal:

```text
Ctrl+C
```

Wichtig:

```text
Ctrl+C beendet nur das Live-Mitlesen.
Der Container wird dadurch nicht gestoppt.
```

---

## 10. Monitoring prüfen

### Prometheus prüfen

```powershell
# Prüft, ob Prometheus bereit ist.
# Erwartung: erfolgreiche HTTP-Antwort.
Invoke-WebRequest -Uri http://localhost:9090/-/ready -UseBasicParsing
```

Im Browser prüfen:

```text
http://localhost:9090/targets
```

Erwartung:

```text
prometheus = UP
cadvisor = UP
```

### Grafana prüfen

```powershell
# Prüft den Grafana-Health-Endpunkt.
# Erwartung: erfolgreiche HTTP-Antwort.
Invoke-WebRequest -Uri http://localhost:3000/api/health -UseBasicParsing
```

Im Browser öffnen:

```text
http://localhost:3000
```

Dashboard:

```text
Dashboards → Docker Portfolio Lab → Docker Portfolio Lab Overview
```

### cAdvisor prüfen

```powershell
# Prüft, ob cAdvisor Metriken liefert.
# Erwartung: Prometheus-kompatible Metriken als Text.
Invoke-WebRequest -Uri http://localhost:8085/metrics -UseBasicParsing
```

---

## 11. Screenshots

Screenshots sind sinnvoll bei sichtbaren Meilensteinen.

### Sinnvoll

```text
GitHub Actions erstmalig grün
Prometheus Targets UP
Grafana Dashboard sichtbar
Docker Compose ps mit healthy-Status
Live-Log mit test=logcheck
wichtige Fehlerbilder mit klarer Meldung
```

### Nicht jedes Mal nötig

```text
jeder kleine Doku-Commit
jeder wiederholte grüne CI-Lauf
jede lange Logausgabe
Zwischenstände ohne Portfolio-Wert
```

### Vor öffentlicher Nutzung prüfen

```text
Browserleiste entfernen
private Tabs entfernen
Erweiterungen prüfen
keine Secrets/Tokens zeigen
keine privaten lokalen Pfade zeigen
keine personenbezogenen Daten zeigen
```

---

## 12. Secrets prüfen

```powershell
# Prüft, ob das Redis-Secret ignoriert wird.
# Erwartung: Git zeigt eine .gitignore-Regel.
git check-ignore -v secrets/redis_password.txt

# Prüft, ob das Grafana-Secret ignoriert wird.
# Erwartung: Git zeigt eine .gitignore-Regel.
git check-ignore -v secrets/grafana_admin_password.txt
```

Wichtig:

```text
Secret-Dateien niemals committen.
Secret-Inhalte niemals in Screenshots zeigen.
Secret-Inhalte nicht in Logs schreiben.
```

---

## 13. Git prüfen

```powershell
# Zeigt den aktuellen Git-Zustand.
# Erwartung: bewusst kontrollieren, welche Dateien geändert wurden.
git status

# Zeigt die letzten Commits.
# Erwartung: nachvollziehbare Projekthistorie.
git log --oneline -8
```

Bei Doku- oder Codeänderungen:

```powershell
# Geänderte Datei hinzufügen.
git add <DATEI>

# Commit mit klarer Nachricht erstellen.
git commit -m "Kurze sachliche Commit-Nachricht"

# Nach GitHub hochladen.
git push

# Danach prüfen.
git status
```

---

## 14. Monitoring stoppen, aber Daten behalten

Wenn nur Monitoring gestoppt werden soll:

```powershell
# Stoppt nur Monitoring-Services.
# Redis und Web bleiben unangetastet.
docker compose -f compose.prod.yml -f compose.monitoring.yml stop prometheus grafana cadvisor

# Prüft danach den Status.
# Erwartung: Monitoring-Services gestoppt, Web/Redis laufen weiter.
docker compose -f compose.prod.yml -f compose.monitoring.yml ps
```

Wichtig:

```text
Die Docker Volumes für Prometheus und Grafana bleiben erhalten.
```

---

## 15. Gesamten Stack stoppen, Volumes behalten

```powershell
# Stoppt und entfernt Container und Netzwerk.
# Docker Volumes bleiben erhalten.
docker compose -f compose.prod.yml -f compose.monitoring.yml down
```

Einordnung:

```text
down entfernt Container und Netzwerk.
down entfernt ohne -v keine Volumes.
```

---

## 16. Volumes nur bewusst löschen

```powershell
# Entfernt Container, Netzwerk und Volumes.
# WARNUNG: Dadurch gehen Lab-Daten in Redis, Prometheus und Grafana verloren.
docker compose -f compose.prod.yml -f compose.monitoring.yml down -v
```

Nur nutzen, wenn Datenverlust im Lab akzeptiert ist.

---

## 17. Warnung vs. Fehler einordnen

Nicht jede Warnung ist ein Ausfall.

Professionelle Einordnung:

```text
Läuft der Container?
Ist er healthy?
Antwortet der Dienst fachlich?
Sind Nutzer betroffen?
Ist die Meldung für die Umgebung erwartbar?
Gibt es neue oder wiederkehrende Muster?
```

Beispiel cAdvisor unter Docker Desktop / WSL2:

```text
Failed to get system UUID
machine-id fehlt
product_name fehlt
```

Einordnung im Lab:

```text
Warnung / Umgebungshinweis.
Nicht fatal, solange cAdvisor healthy ist, /metrics liefert und Prometheus das Target als UP erkennt.
```

---

## 18. Unterschied Lab vs. Produktion

| Thema | Lab | Produktion |
|---|---|---|
| Stackstart | Docker Compose lokal | orchestriert, z. B. Kubernetes oder Managed Service |
| Logs | `docker compose logs` | zentrale Logplattform |
| Monitoring | lokales Prometheus/Grafana | zentrale Plattform, Alerting, Retention, Rollen |
| Secrets | lokale Secret-Dateien | Secret Manager, Vault, Cloud/Kubernetes Secrets |
| Readiness | lokales Skript | Health Probes, Load Balancer, synthetische Checks |
| Screenshots | private Dokumentation | nur geprüft und zugeschnitten |
| Stoppen | manuell | Change-/Deployment-Prozess |
| Datenhaltung | lokale Docker Volumes | Backup, Replikation, Retention, Restore-Prozess |

---

## 19. Kurzer Daily-Check

Wenn nur schnell geprüft werden soll:

```powershell
cd "C:\Docker Übung"
git status
docker compose -f compose.prod.yml -f compose.monitoring.yml ps
.\scripts\tests\test-stack-readiness.ps1
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=10
```

Erwartung:

```text
Git sauber
Services healthy
Readiness Check erfolgreich
keine neuen kritischen Logs
```

---

## 20. Portfolio-Formulierung

> Das Projekt enthält ein Daily Operations Runbook für den lokalen Docker-/DevOps-Lab-Stack. Es beschreibt wiederholbare Betriebsabläufe wie Stackstart, Statusprüfung, Readiness Check, Log-Diagnose, Monitoring-Prüfung, Secret-Schutz, Screenshot-Hygiene und sauberes Stoppen ohne Datenverlust. Dadurch wird gezeigt, dass das Lab nicht nur technisch aufgebaut, sondern auch nachvollziehbar betrieben und geprüft werden kann.
