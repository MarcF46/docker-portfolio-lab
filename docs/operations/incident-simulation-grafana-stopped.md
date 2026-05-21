# Incident-Simulation: Grafana-Service gestoppt

## Zweck

Diese kurze Dokumentation beschreibt eine kontrollierte Fehlersimulation im Docker Portfolio Lab.

Ziel war es, zu prüfen, wie sich ein Ausfall von Grafana von einem Prometheus-Ausfall und einem Redis-Ausfall unterscheidet.

---

## Szenario

Ein Grafana-Ausfall wurde kontrolliert simuliert:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml stop grafana
```

Danach wurde der Stackstatus geprüft:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

---

## Beobachtetes Symptom

Nach dem Stoppen von Grafana liefen die Kernservices weiter:

```text
web        weiterhin erreichbar
redis      weiterhin erreichbar
prometheus weiterhin erreichbar
cadvisor   weiterhin erreichbar
grafana    gestoppt / nicht vollständig verfügbar
```

Wichtige Einordnung:

```text
Die Anwendung bleibt fachlich bereit.
Prometheus sammelt weiterhin Metriken.
cAdvisor liefert weiterhin Metriken.
Grafana als Visualisierungsoberfläche ist jedoch nicht verfügbar.
```

---

## Erkennung durch Daily-Operations-Check

Der farbige Daily-Operations-Check wurde im Fehlerzustand ausgeführt:

```powershell
.\scripts\tests\test-daily-operations.ps1
```

Beobachtetes Ergebnis:

```text
[ERROR] Service 'grafana' wurde im Compose-Status nicht gefunden.
[ERROR] Grafana Health API antwortet fehlgeschlagen.

OK:    13
WARN:  1
ERROR: 2

GESAMTSTATUS: NICHT BEREIT - es gibt ERROR-Meldungen.
```

---

## App-Readiness vs. Monitoring-Visualisierung

Diese Simulation zeigt eine wichtige Unterscheidung:

| Prüfung | Bedeutung |
|---|---|
| App-Readiness | Web und Redis sind fachlich nutzbar |
| Metrikerfassung | Prometheus und cAdvisor arbeiten weiter |
| Visualisierung | Grafana stellt Dashboards bereit |

Bei einem Grafana-Ausfall kann gelten:

```text
App-Readiness: erfolgreich
Metrikerfassung: weiterhin möglich
Dashboard-Visualisierung: nicht verfügbar
Operations-Readiness: nicht vollständig bereit
```

Das ist fachlich wichtig, weil Monitoring nicht nur aus Datensammlung besteht, sondern auch aus nutzbarer Visualisierung.

---

## Diagnose

Typische Diagnosebefehle:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps

.\scripts\tests\test-stack-readiness.ps1

.\scripts\tests\test-daily-operations.ps1

docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 grafana
```

Einordnung:

```text
Wenn Web, Redis, Prometheus und cAdvisor weiter verfügbar sind,
liegt der Fehler nicht im Kernpfad der Anwendung und nicht in der Metrikerfassung,
sondern in der Visualisierungsschicht des Monitorings.
```

---

## Behebung

Grafana wurde wieder gestartet:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml start grafana
```

Danach wurde kurz gewartet:

```powershell
Start-Sleep -Seconds 20
```

Anschließend wurde der Status erneut geprüft:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

---

## Verifikation

Der Daily-Operations-Check wurde erneut ausgeführt:

```powershell
.\scripts\tests\test-daily-operations.ps1
```

Ergebnis nach der Behebung:

```text
OK:    15
WARN:  1
ERROR: 0

GESAMTSTATUS: BEREIT MIT HINWEISEN - Warnungen fachlich pruefen.
```

Die verbleibende Warnung betrifft bekannte cAdvisor-/WSL2-Hinweise im lokalen Docker-Desktop-Lab und ist in diesem Kontext nicht fatal.

---

## Kommunikationsstufe A: ultrakurze Statusmeldung

```text
Grafana war gestoppt und wurde neu gestartet. Web, Redis und Prometheus blieben verfügbar. Danach war der Daily-Operations-Check wieder ohne ERROR.
```

---

## Kommunikationsstufe B: kurzer Ticket-Kommentar

```text
Daily-Operations-Check meldete den Stack als nicht bereit, da Grafana nicht verfügbar war. Web und Redis blieben fachlich bereit, Prometheus und cAdvisor liefen weiter. Grafana wurde neu gestartet, anschließend war die Grafana Health API wieder erreichbar und der Daily-Operations-Check meldete ERROR: 0.
```

---

## Lessons Learned

- App-Bereitschaft und Monitoring-Visualisierung sind nicht dasselbe.
- Ein Grafana-Ausfall macht die Anwendung nicht automatisch unbenutzbar.
- Prometheus kann weiterhin Metriken sammeln, auch wenn Grafana als Dashboard-Oberfläche nicht verfügbar ist.
- Ein Visualisierungsausfall ist trotzdem betrieblich relevant, weil Dashboards und manuelle Analyse betroffen sind.
- Der Daily-Operations-Check erkennt den Fehler sowohl über den Compose-Status als auch über die Grafana Health API.

---

## Mustererkennung

```text
Symptom:
Daily-Operations-Check meldet ERROR.

Betroffener Bereich:
Monitoring-Visualisierung.

Betroffener Service:
Grafana.

Mögliche Ursache:
Grafana-Service wurde gestoppt oder ist ausgefallen.

Diagnose:
docker compose ps
test-stack-readiness.ps1
test-daily-operations.ps1
Grafana-Logs prüfen
Grafana Health API prüfen

Bewertung:
Web + Redis bleiben fachlich bereit.
Prometheus und cAdvisor bleiben verfügbar.
Grafana-Dashboards sind nicht verfügbar.

Maßnahme:
Grafana neu starten.

Verifikation:
Grafana ist wieder healthy.
Grafana Health API antwortet.
Daily-Operations-Check meldet ERROR: 0.

Kommunikation:
Kurze Statusmeldung oder Ticket-Kommentar.
```

---

## Portfolio-Einordnung

Diese Simulation zeigt ein weiteres Fehlerbild:

```text
Redis-Ausfall:
Anwendung fachlich nicht vollständig bereit.

Prometheus-Ausfall:
Metrikerfassung / Monitoring-Datensammlung gestört.

Grafana-Ausfall:
Visualisierung / Dashboard-Zugriff gestört.
```

Damit trainiert das Lab unterschiedliche Betriebszustände und hilft, Fehler nicht nur technisch, sondern auch fachlich einzuordnen.
