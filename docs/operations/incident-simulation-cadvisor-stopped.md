# Incident-Simulation: cAdvisor-Service gestoppt

## Zweck

Diese kurze Dokumentation beschreibt eine kontrollierte Fehlersimulation im Docker Portfolio Lab.

Ziel war es, zu prüfen, wie sich ein Ausfall von cAdvisor auswirkt und wie sich dieser Fehler von Redis-, Prometheus- und Grafana-Ausfällen unterscheidet.

---

## Szenario

Ein cAdvisor-Ausfall wurde kontrolliert simuliert:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml stop cadvisor
```

Danach wurde der Stackstatus geprüft:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

---

## Beobachtetes Symptom

Nach dem Stoppen von cAdvisor liefen die Kernservices weiter:

```text
web         weiterhin erreichbar
redis       weiterhin erreichbar
prometheus  weiterhin erreichbar
grafana     weiterhin erreichbar
cadvisor    gestoppt / nicht vollständig verfügbar
```

Wichtige Einordnung:

```text
Die Anwendung bleibt fachlich bereit.
Prometheus und Grafana laufen weiter.
Aber cAdvisor liefert keine Container-Metriken mehr.
```

---

## App-Readiness

Der Stack-Readiness-Check wurde ausgeführt:

```powershell
.\scripts\tests\test-stack-readiness.ps1
```

Ergebnis:

```text
Web-Service antwortet mit HTTP Status 200.
Redis antwortet korrekt mit PONG.
Stack ist aus Sicht des Readiness-Checks bereit.
```

Einordnung:

```text
Ein cAdvisor-Ausfall macht die Anwendung nicht automatisch unbenutzbar.
Web und Redis bleiben fachlich bereit.
```

---

## Erkennung durch Daily-Operations-Check

Der farbige Daily-Operations-Check wurde im Fehlerzustand ausgeführt:

```powershell
.\scripts\tests\test-daily-operations.ps1
```

Beobachtetes Ergebnis:

```text
[ERROR] Service 'cadvisor' wurde im Compose-Status nicht gefunden.
[ERROR] cAdvisor liefert Metriken fehlgeschlagen.

OK:    13
WARN:  1
ERROR: 2

GESAMTSTATUS: NICHT BEREIT - es gibt ERROR-Meldungen.
```

Damit wurde der Ausfall korrekt erkannt.

---

## Diagnose

Typische Diagnosebefehle:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps

.\scripts\tests\test-stack-readiness.ps1

.\scripts\tests\test-daily-operations.ps1

docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 cadvisor
```

Einordnung:

```text
Wenn Web, Redis, Prometheus und Grafana weiter verfügbar sind,
liegt der Fehler nicht im Kernpfad der Anwendung,
sondern bei der Container-Metrikquelle.
```

---

## Behebung

cAdvisor wurde wieder gestartet:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml start cadvisor
```

Danach wurde kurz gewartet:

```powershell
Start-Sleep -Seconds 20
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

Git war anschließend sauber:

```text
nothing to commit, working tree clean
```

Die verbleibende Warnung betrifft bekannte cAdvisor-/WSL2-Hinweise im lokalen Docker-Desktop-Lab und ist in diesem Kontext nicht fatal.

---

## Kommunikationsstufe A: ultrakurze Statusmeldung

```text
cAdvisor war gestoppt und wurde neu gestartet. Web, Redis, Prometheus und Grafana liefen weiter. Danach war der Daily-Operations-Check wieder ohne ERROR.
```

---

## Kommunikationsstufe B: kurzer Ticket-Kommentar

```text
Daily-Operations-Check meldete den Stack als nicht bereit, da cAdvisor nicht verfügbar war und keine Container-Metriken geliefert hat. Web und Redis blieben fachlich bereit, Prometheus und Grafana liefen weiter. cAdvisor wurde neu gestartet, anschließend war der Metrics-Endpunkt wieder erreichbar und der Daily-Operations-Check meldete ERROR: 0.
```

---

## Lessons Learned

- App-Bereitschaft und Container-Metrikerfassung sind nicht dasselbe.
- Ein cAdvisor-Ausfall macht die Anwendung nicht automatisch unbenutzbar.
- Prometheus und Grafana können weiter laufen, obwohl keine Container-Metriken mehr von cAdvisor kommen.
- cAdvisor ist im Lab die Container-Metrikquelle.
- Der Daily-Operations-Check erkennt den Fehler sowohl über den Compose-Status als auch über den Metrics-Endpunkt.

---

## Mustererkennung

```text
Symptom:
Daily-Operations-Check meldet ERROR.

Betroffener Bereich:
Container-Metrikquelle.

Betroffener Service:
cAdvisor.

Mögliche Ursache:
cAdvisor-Service wurde gestoppt oder ist ausgefallen.

Diagnose:
docker compose ps
test-stack-readiness.ps1
test-daily-operations.ps1
cAdvisor-Logs prüfen
cAdvisor Metrics Endpoint prüfen

Bewertung:
Web + Redis bleiben fachlich bereit.
Prometheus und Grafana laufen weiter.
Container-Metriken fehlen.

Maßnahme:
cAdvisor neu starten.

Verifikation:
cAdvisor ist wieder healthy.
cAdvisor Metrics Endpoint antwortet.
Daily-Operations-Check meldet ERROR: 0.

Kommunikation:
Kurze Statusmeldung oder Ticket-Kommentar.
```

---

## Portfolio-Einordnung

Diese Simulation ergänzt die bisherigen Fehlerbilder:

```text
Redis-Ausfall:
Anwendung fachlich nicht vollständig bereit.

Prometheus-Ausfall:
Metrikerfassung / Monitoring-Datensammlung gestört.

Grafana-Ausfall:
Visualisierung / Dashboard-Zugriff gestört.

cAdvisor-Ausfall:
Container-Metrikquelle gestört.
```

Damit trainiert das Lab unterschiedliche Betriebszustände und hilft, Fehler fachlich einzuordnen.
