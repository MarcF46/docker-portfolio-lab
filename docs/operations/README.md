# Operations-Dokumentation

## Zweck

Dieser Ordner enthält die betriebsnahen Dokumentationen des Docker Portfolio Lab.

Die Dokumente zeigen nicht nur einzelne Docker-Befehle, sondern typische Betriebsaufgaben aus einer Cloud-/DevOps-/Operations-Perspektive:

```text
Backup und Restore
Troubleshooting
Healthchecks
Readiness Checks
Secret Handling
CI-Prüfungen
Monitoring
Logging
Reverse Proxy
Fehleranalyse
```

Das Ziel ist ein nachvollziehbares Portfolio für einen Junior Cloud-/DevOps-Engineer-Einstieg.

---

## Übersicht der Dokumente

| Dokument | Thema | Gezeigte Betriebsfähigkeit |
|---|---|---|
| `backup-strategie-gfs.md` | Backup-Strategie, GFS, Retention | Backup-Planung, Aufbewahrung, Restore-Prinzip |
| `docker-volume-backup-restore.md` | Docker Volume Backup und Restore | Volume sichern, Restore testen, Daten prüfen |
| `docker-compose-environments.md` | Docker Compose Umgebungen | Dev-, Prod-, Monitoring- und Registry-Compose-Dateien einordnen |
| `docker-cleanup-safety.md` | Docker Cleanup Safety | Container, Images, Volumes und Prune-Risiken sicher bewerten |
| `docker-security-readiness.md` | Docker Security und Readiness | Secret-Handling, Healthchecks und Lernlabor-Grenzen bewerten |
| `docker-final-readiness-check.md` | Finaler Docker Readiness Check | finaler Betriebscheck mit Daily-Operations-Skript |
| `docker-network-basics.md` | Docker Netzwerk Grundlagen | Compose-Netzwerk, Service-DNS, Host-Port und Container-`localhost` verstehen |
| `docker-registry-push-pull.md` | Docker Registry, Push, Pull und Digest | lokale Registry, Image push/pull, Compose-Registry-Test und Digest-Fehlerbild |
| `reverse-proxy-nginx.md` | Reverse Proxy mit NGINX | zentraler HTTP-Einstiegspunkt vor dem Webservice |
| `redis-secret-handling-healthcheck.md` | Redis Secret Handling | Secrets nicht in Compose/Logs hardcoden, Healthcheck verbessern |
| `stack-readiness-check.md` | Stack-Readiness-Prüfung | Web + Redis fachlich prüfen, nicht nur Containerstatus |
| `github-actions-ci.md` | GitHub Actions CI | automatische Prüfung von Compose, Build, Stack, Web und Redis |
| `monitoring-prometheus-grafana.md` | Prometheus, Grafana, cAdvisor | Metriken sammeln, visualisieren, Targets prüfen |
| `prometheus-target-health-cadvisor.md` | Prometheus Target Health: cAdvisor | Prometheus Targets, Query `up`, cAdvisor UP/DOWN einordnen |
| `monitoring-incident-patterns.md` | Monitoring Incident Patterns | Vergleich Redis-, Prometheus-, Grafana- und cAdvisor-Ausfall |
| `logging-basics.md` | Docker Compose Logs | Logs mit `--tail`, `--since`, `--follow` lesen und einordnen |
| `daily-operations-runbook.md` | Daily Operations Runbook | wiederholbarer Betriebsablauf für Start, Checks, Logs, Monitoring, Secrets und Stoppen |
| `terminal-session-logging.md` | Terminal-Mitschnitt mit PowerShell | Nachvollziehbarkeit, private technische Tagesprotokolle |
| `powershell-script-pitfalls.md` | PowerShell-Skriptfallen | typische Stolperfallen bei Skripten, Exitcodes und externer Tool-Ausführung |
| `incident-simulation-redis-stopped.md` | Redis-Stopp Incident-Simulation | kontrollierter Redis-Ausfall, Erkennung, Behebung und Verifikation |
| `incident-simulation-prometheus-stopped.md` | Prometheus-Stopp Incident-Simulation | Monitoring-Ausfall, App-Readiness vs. Operations-Readiness |
| `incident-simulation-grafana-stopped.md` | Grafana-Stopp Incident-Simulation | Ausfall der Monitoring-Visualisierung bei weiterhin laufender App und Metrikerfassung |
| `incident-simulation-cadvisor-stopped.md` | cAdvisor-Stopp Incident-Simulation | Ausfall der Container-Metrikquelle bei weiterhin laufender App |
| `../troubleshooting/troubleshooting-backup-restore.md` | Backup-/Restore-Fehleranalyse | Warnungen, Fehlerbilder, Diagnosewege |

---

## Thematische Gruppierung

### Backup und Restore

Relevante Dokumente:

```text
backup-strategie-gfs.md
docker-volume-backup-restore.md
../troubleshooting/troubleshooting-backup-restore.md
```

Gezeigte Fähigkeiten:

```text
Docker Volume sichern
Restore-Test durchführen
Retention Policy verstehen
GFS-Prinzip einordnen
Warnungen und Fehler beim Restore unterscheiden
```

Wichtiger Betriebsgrundsatz:

```text
Ein Backup ist erst dann zuverlässig, wenn ein Restore erfolgreich getestet wurde.
```

---

### Compose, Netzwerk und Reverse Proxy

Relevante Dokumente:

```text
docker-compose-environments.md
docker-network-basics.md
reverse-proxy-nginx.md
```

Gezeigte Fähigkeiten:

```text
Compose-Dateien sicher kombinieren
Dev-, Prod- und Monitoring-Umgebung unterscheiden
Docker-Netzwerke und Service-Namen verstehen
Reverse Proxy als zentralen Einstiegspunkt vor einen Webservice setzen
```

Wichtige Einordnung:

```text
Direkter Container-Port-Zugriff ist im Lab hilfreich.
Ein Reverse Proxy ist produktionsnäher, weil er den zentralen Einstiegspunkt für HTTP/HTTPS vorbereitet.
```

---

### Secrets und Security

Relevante Dokumente:

```text
redis-secret-handling-healthcheck.md
docker-security-readiness.md
```

Gezeigte Fähigkeiten:

```text
Secrets aus Compose-Dateien herauslösen
lokale Secret-Dateien per .gitignore schützen
Healthchecks ohne unsichere Passwortausgabe verbessern
Lernlabor und produktiven Betrieb bewusst unterscheiden
```

Security-Grundsatz:

```text
Secrets gehören nicht in Git, nicht in öffentliche Logs und nicht in Screenshots.
```

---

### CI/CD-Grundlagen

Relevantes Dokument:

```text
github-actions-ci.md
```

Gezeigte Fähigkeiten:

```text
GitHub Actions Workflow erstellen
Docker Compose Konfiguration automatisch prüfen
Web-Image in CI bauen
Stack im GitHub Actions Runner starten
Web und Redis automatisiert testen
Logs bei Fehlern anzeigen
```

Einordnung:

```text
Dieses Projekt nutzt aktuell CI.
CD/Deployment ist bewusst noch nicht umgesetzt.
```

---

### Monitoring

Relevante Dokumente:

```text
monitoring-prometheus-grafana.md
prometheus-target-health-cadvisor.md
monitoring-incident-patterns.md
```

Gezeigte Fähigkeiten:

```text
Prometheus starten
cAdvisor als Metrikquelle nutzen
Grafana-Dashboard bereitstellen
Prometheus Targets prüfen
Metriken und Dashboards einordnen
Docker-Desktop-/WSL2-Besonderheiten dokumentieren
```

Wichtige Begriffe:

```text
Metrik
Target
Scrape
Dashboard
Exporter
```

---

### Logging

Relevante Dokumente:

```text
logging-basics.md
terminal-session-logging.md
powershell-script-pitfalls.md
```

Gezeigte Fähigkeiten:

```text
docker compose logs nutzen
Logs pro Service abrufen
Logs mit --tail begrenzen
Logs mit --since zeitlich eingrenzen
Live-Logs mit --follow beobachten
Healthcheck-Zugriffe und Browserzugriffe unterscheiden
Warnungen und Fehler einordnen
```

Wichtige Einordnung:

```text
Monitoring zeigt Zahlen über Zeit.
Logging zeigt konkrete Ereignisse.
Für echten Betrieb braucht man beides.
```

---

### Incident-Simulationen

Relevante Dokumente:

```text
incident-simulation-redis-stopped.md
incident-simulation-prometheus-stopped.md
incident-simulation-grafana-stopped.md
incident-simulation-cadvisor-stopped.md
monitoring-incident-patterns.md
```

Gezeigte Fähigkeiten:

```text
kontrollierte Fehler auslösen
betroffenen Service erkennen
App-Readiness und Operations-Readiness unterscheiden
Diagnosekette anwenden
Fix und Verifikation ableiten
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Wichtige Erkenntnis:

```text
Nicht jedes sichtbare Symptom zeigt direkt die Ursache.
Grafana kann fehlende Daten anzeigen, obwohl die Ursache bei Prometheus oder cAdvisor liegt.
```

---

## Portfolio-Wert

Diese Dokumente zeigen, dass das Projekt nicht nur ein einfacher Containerstart ist.

Es zeigt betriebsnahe Grundlagen:

```text
Wie wird ein Stack gestartet?
Wie wird geprüft, ob er wirklich funktioniert?
Wie werden Daten gesichert?
Wie wird ein Restore getestet?
Wie werden Secrets behandelt?
Wie wird CI genutzt?
Wie werden Metriken sichtbar gemacht?
Wie liest man Logs?
Wie ordnet man Warnungen ein?
Wie wird ein wiederholbarer Daily-Operations-Ablauf dokumentiert?
Wie wird ein kontrollierter Fehler erkannt, behoben und verifiziert?
```

Das ist besonders relevant für:

```text
Junior Cloud Engineer
Junior DevOps Engineer
Platform Engineering Einstieg
System Engineering mit Cloud-/Container-Fokus
```

---

## Lab vs. Produktion

Dieses Projekt ist ein lokales Lern- und Portfolio-Lab.

Es ist bewusst nicht gleichzusetzen mit vollständigem produktivem Betrieb.

| Thema | Lab | Produktion |
|---|---|---|
| Docker Compose | lokaler Stack | meist orchestriert, z. B. Kubernetes oder Managed Services |
| Reverse Proxy | NGINX lokal über HTTP | gehärteter Proxy mit HTTPS/TLS, Domain, Zertifikatsverwaltung und Logging |
| Secrets | lokale Secret-Dateien | Secret Manager, Vault, Cloud/Kubernetes Secrets |
| CI | GitHub Actions Grundprüfung | mehrstufige Pipeline mit Tests, Scans, Freigaben |
| Monitoring | Prometheus/Grafana lokal | zentrale Plattform, Alerting, Retention, Rollen |
| Logging | `docker compose logs` | zentrale Logplattform, Suche, Retention, Zugriffsschutz |
| Backup | lokales Volume-Backup | geplante Backups, Restore-Tests, Offsite/Immutable Storage |
| Security | Grundregeln im Lab | Policies, Audits, IAM, Netzwerksegmentierung, Compliance |

---

## Projektkurzbeschreibung

> Dieses Projekt dokumentiert ein lokales Docker-/DevOps-Lab mit praxisnahen Betriebsgrundlagen. Enthalten sind Docker Compose, Redis mit persistentem Volume, Backup-/Restore-Übungen, Healthchecks, Secret Handling, Stack-Readiness-Prüfungen, GitHub Actions CI, Monitoring mit Prometheus/Grafana/cAdvisor, NGINX Reverse Proxy sowie grundlegende Log-Diagnose. Die Dokumentation grenzt Lernlabor und produktiven Betrieb bewusst voneinander ab und zeigt typische Diagnose- und Betriebsabläufe.

- [Lokales HTTPS mit NGINX Reverse Proxy](https-local-nginx.md)

- [Secrets Deep Dive](secrets-deep-dive.md)

- [Docker Log Rotation](docker-log-rotation.md)

- [Prometheus Target API Check](prometheus-target-api-check.md)
