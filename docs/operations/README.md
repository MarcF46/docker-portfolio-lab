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
Fehleranalyse
```

Das Ziel ist ein nachvollziehbares Portfolio für einen Junior Cloud-/DevOps-Engineer-Einstieg.

---

## Übersicht der Dokumente

| Dokument | Thema | Gezeigte Betriebsfähigkeit |
|---|---|---|
| `backup-strategie-gfs.md` | Backup-Strategie, GFS, Retention | Backup-Planung, Aufbewahrung, Restore-Prinzip |
| `troubleshooting-backup-restore.md` | Backup-/Restore-Fehleranalyse | Warnungen, Fehlerbilder, Diagnosewege |
| `runtime-dependency-redis-outage.md` | Redis-Laufzeitausfall | Unterschied Startabhängigkeit vs. Laufzeitabhängigkeit |
| `runtime-dependency-redis-outage-enterprise.md` | Enterprise-Einordnung Redis-Ausfall | Incident-Denken, Diagnose, Rollback, Betriebsbewertung |
| `simulation-b-kommentierte-befehle.md` | Kommentierte Redis-Ausfallsimulation | Lernfreundliche Befehlsanalyse |
| `terminal-session-logging.md` | Terminal-Mitschnitt mit PowerShell | Nachvollziehbarkeit, private technische Tagesprotokolle |
| `stack-readiness-check.md` | Stack-Readiness-Prüfung | Web + Redis fachlich prüfen, nicht nur Containerstatus |
| `redis-secret-handling-healthcheck.md` | Redis Secret Handling | Secrets nicht in Compose/Logs hardcoden, Healthcheck verbessern |
| `github-actions-ci.md` | GitHub Actions CI | automatische Prüfung von Compose, Build, Stack, Web und Redis |
| `monitoring-prometheus-grafana.md` | Prometheus, Grafana, cAdvisor | Metriken sammeln, visualisieren, Targets prüfen |
| `logging-basics.md` | Docker Compose Logs | Logs mit `--tail`, `--since`, `--follow` lesen und einordnen |
| incident-simulation-redis-stopped.md | Redis-Stopp Incident-Simulation | kontrollierter Redis-Ausfall, Erkennung, Behebung und Verifikation |
| incident-simulation-prometheus-stopped.md | Prometheus-Stopp Incident-Simulation | Monitoring-Ausfall, App-Readiness vs. Operations-Readiness |
| incident-simulation-grafana-stopped.md | Grafana-Stopp Incident-Simulation | Ausfall der Monitoring-Visualisierung bei weiterhin laufender App und Metrikerfassung |
| incident-simulation-cadvisor-stopped.md | cAdvisor-Stopp Incident-Simulation | Ausfall der Container-Metrikquelle bei weiterhin laufender App |
| prometheus-target-health-cadvisor.md | Prometheus Target Health: cAdvisor | Prometheus Targets, Query up, cAdvisor UP/DOWN einordnen |
| daily-operations-runbook.md | Daily Operations Runbook | wiederholbarer Betriebsablauf für Start, Checks, Logs, Monitoring, Secrets und Stoppen |

---

## Thematische Gruppierung

### Backup und Restore

Relevante Dokumente:

```text
backup-strategie-gfs.md
troubleshooting-backup-restore.md
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

### Runtime Dependencies und Incident-Denken

Relevante Dokumente:

```text
runtime-dependency-redis-outage.md
runtime-dependency-redis-outage-enterprise.md
simulation-b-kommentierte-befehle.md
```

Gezeigte Fähigkeiten:

```text
Redis-Ausfall simulieren
Containerstatus prüfen
Serviceabhängigkeiten verstehen
Laufzeitfehler von Startfehlern unterscheiden
Diagnose und Wiederherstellung durchführen
```

Wichtige Einordnung:

```text
depends_on mit service_healthy hilft beim Start.
Es ersetzt aber keine echte Laufzeitüberwachung, kein Retry-Verhalten und kein vollständiges Incident Handling.
```

---

### Secrets und Security

Relevantes Dokument:

```text
redis-secret-handling-healthcheck.md
```

Gezeigte Fähigkeiten:

```text
Secrets aus Compose-Dateien herauslösen
lokale Secret-Dateien per .gitignore schützen
Healthchecks ohne unsichere Passwortausgabe verbessern
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

Relevantes Dokument:

```text
monitoring-prometheus-grafana.md
```

Gezeigte Fähigkeiten:

```text
Prometheus starten
cAdvisor als Metrikquelle nutzen
Grafana-Dashboard bereitstellen
Prometheus Targets prüfen
Metriken und Dashboards einordnen
Docker Desktop / WSL2 Besonderheiten dokumentieren
```

Wichtige Begriffe:

```text
Metric
Target
Scrape
Dashboard
Exporter
```

---

### Logging

Relevantes Dokument:

```text
logging-basics.md
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






### Incident-Simulation: cAdvisor gestoppt

Relevantes Dokument:

```text
incident-simulation-cadvisor-stopped.md
```

Gezeigte Fähigkeiten:

```text
cAdvisor-Ausfall kontrolliert auslösen
Container-Metrikquelle als betroffenen Bereich erkennen
Daily-Operations-Check auswerten
App-Readiness und Container-Metrikerfassung unterscheiden
cAdvisor wiederherstellen
Fix verifizieren
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Einordnung:

```text
Die Simulation zeigt, dass Web und Redis fachlich bereit bleiben können,
während cAdvisor als Container-Metrikquelle nicht verfügbar ist.
```

Wichtige Erkenntnis:

```text
Ohne cAdvisor fehlen Container-Metriken,
obwohl Web, Redis, Prometheus und Grafana weiter laufen können.
```

### Incident-Simulation: Grafana gestoppt
Relevantes Dokument:

```text
incident-simulation-grafana-stopped.md
```

Gezeigte Fähigkeiten:

```text
Grafana-Ausfall kontrolliert auslösen
Visualisierungsausfall erkennen
Daily-Operations-Check auswerten
App-Readiness und Monitoring-Visualisierung unterscheiden
Grafana wiederherstellen
Fix verifizieren
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Einordnung:

```text
Die Simulation zeigt, dass Web und Redis fachlich bereit bleiben können,
während Grafana als Dashboard- und Visualisierungsschicht nicht verfügbar ist.
```

Wichtige Erkenntnis:

```text
Monitoring-Daten können weiterhin gesammelt werden,
auch wenn die grafische Visualisierung über Grafana gestört ist.
```

### Incident-Simulation: Prometheus gestoppt
Relevantes Dokument:

```text
incident-simulation-prometheus-stopped.md
```

Gezeigte Fähigkeiten:

```text
Monitoring-Ausfall kontrolliert auslösen
Prometheus-Ausfall erkennen
Daily-Operations-Check auswerten
App-Readiness und Operations-Readiness unterscheiden
Prometheus wiederherstellen
Fix verifizieren
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Einordnung:

```text
Die Simulation zeigt, dass Web und Redis fachlich bereit bleiben können,
während die Beobachtbarkeit durch einen Prometheus-Ausfall beschädigt ist.
```

Wichtige Erkenntnis:

```text
App-Stack bereit ist nicht automatisch gleich Operations-Stack vollständig bereit.
```

### Incident-Simulation: Redis gestoppt
Relevantes Dokument:

```text
incident-simulation-redis-stopped.md
```

Gezeigte Fähigkeiten:

```text
kontrollierten Fehler auslösen
Redis-Ausfall erkennen
Daily-Operations-Check auswerten
Readiness-Fehler fachlich einordnen
Redis wiederherstellen
Fix verifizieren
kurze Statusmeldung und Ticket-Kommentar formulieren
```

Einordnung:

```text
Die Simulation zeigt, dass ein teilweise laufender Stack nicht automatisch fachlich bereit ist.
Web, Prometheus, Grafana und cAdvisor können weiter laufen, während Redis als Laufzeitabhängigkeit fehlt.
```

### Daily Operations Runbook
Relevantes Dokument:

```text
daily-operations-runbook.md
```

Gezeigte Fähigkeiten:

```text
Stack reproduzierbar starten
Stackstatus prüfen
Readiness Check ausführen
Logs und Monitoring prüfen
Secrets kontrollieren
Git-Zustand prüfen
Monitoring ohne Datenverlust stoppen
Screenshots bewusst und sicher verwenden
```

Einordnung:

```text
Das Runbook bündelt wiederkehrende Betriebsabläufe.
Es hilft dabei, den Stack nicht nur aufzubauen, sondern auch nachvollziehbar zu betreiben.
```

### Terminal-Session-Logging
Relevantes Dokument:

```text
terminal-session-logging.md
```

Gezeigte Fähigkeiten:

```text
PowerShell-Sitzungen mitschneiden
Befehle und Ausgaben nachvollziehbar speichern
Tagesablauf technisch dokumentieren
```

Einordnung:

```text
Terminal-Mitschnitte sind für private Unterlagen sinnvoll.
Sie gehören nicht ungeprüft ins öffentliche Portfolio.
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
| Secrets | lokale Secret-Dateien | Secret Manager, Vault, Cloud/Kubernetes Secrets |
| CI | GitHub Actions Grundprüfung | mehrstufige Pipeline mit Tests, Scans, Freigaben |
| Monitoring | Prometheus/Grafana lokal | zentrale Plattform, Alerting, Retention, Rollen |
| Logging | `docker compose logs` | zentrale Logplattform, Suche, Retention, Zugriffsschutz |
| Backup | lokales Volume-Backup | geplante Backups, Restore-Tests, Offsite/Immutable Storage |
| Security | Grundregeln im Lab | Policies, Audits, IAM, Netzwerksegmentierung, Compliance |

---

## Recruiter-taugliche Kurzbeschreibung

> Dieses Projekt dokumentiert ein lokales Docker-/DevOps-Lab mit produktionsnahen Betriebsgrundlagen. Enthalten sind Docker Compose, Redis mit persistentem Volume, Backup-/Restore-Übungen, Healthchecks, Secret Handling, Stack-Readiness-Prüfungen, GitHub Actions CI, Monitoring mit Prometheus/Grafana/cAdvisor sowie grundlegende Log-Diagnose. Die Dokumentation grenzt Lernlabor und produktiven Betrieb bewusst voneinander ab und zeigt typische Diagnose- und Betriebsabläufe.

---

## Nächste sinnvolle Ausbaustufen

Kurzfristig sinnvoll:

```text
README weiter schlank und recruiter-tauglich halten
Screenshots für Praxisarbeiten zuschneiden
Monitoring-/Logging-Praxisarbeit erstellen
praktisches Befehlstraining und Simulationen vorbereiten
```

Später sinnvoll:

```text
CI-Fehlerübungen
Log-Diagnose-Simulationen
kleine Alerting-Grundlagen
Cloud-Grundlagen
Kubernetes-Grundlagen
```

Nicht Ziel dieser Datei:

```text
private Karriereplanung
persönliche Motivation
emotionale Notizen
vollständige Enterprise-Architektur behaupten
```








