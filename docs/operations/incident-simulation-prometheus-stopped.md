# Incident-Simulation: Prometheus-Service gestoppt

## Zweck

Diese kurze Dokumentation beschreibt eine kontrollierte Fehlersimulation im Docker Portfolio Lab.

Ziel war es, zu prüfen, wie sich ein Ausfall des Monitoring-Services Prometheus vom Ausfall einer fachlichen Laufzeitabhängigkeit wie Redis unterscheidet.

---

## Szenario

Ein Prometheus-Ausfall wurde kontrolliert simuliert:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml stop prometheus
```

Danach wurde der Stackstatus geprüft:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

---

## Beobachtetes Symptom

Nach dem Stoppen von Prometheus liefen die Kernservices weiter:

```text
web        weiterhin erreichbar
redis      weiterhin erreichbar
grafana    läuft, kann aber ohne Prometheus keine aktuellen Metriken abfragen
cadvisor   läuft, stellt weiterhin Metriken bereit
prometheus gestoppt / nicht vollständig verfügbar
```

Wichtige Einordnung:

```text
Die Anwendung kann weiterhin fachlich bereit sein,
obwohl das Monitoring beschädigt ist.
```

Das unterscheidet diesen Fehler vom Redis-Ausfall.

---

## Erkennung durch Daily-Operations-Check

Der farbige Daily-Operations-Check wurde im Fehlerzustand ausgeführt:

```powershell
.\scripts\tests\test-daily-operations.ps1
```

Beobachtetes Ergebnis:

```text
OK:    13
WARN:  1
ERROR: 2

GESAMTSTATUS: NICHT BEREIT - es gibt ERROR-Meldungen.
```

---

## App-Readiness vs. Operations-Readiness

Diese Simulation zeigt eine wichtige Unterscheidung:

| Prüfung | Bedeutung |
|---|---|
| App-Readiness | Web und Redis sind fachlich nutzbar |
| Operations-Readiness | gesamter Betriebszustand inklusive Monitoring ist in Ordnung |

Bei einem Prometheus-Ausfall kann gelten:

```text
App-Readiness: erfolgreich
Operations-Readiness: nicht vollständig bereit
```

Das ist fachlich wichtig, weil eine Anwendung zwar noch funktioniert, aber die Beobachtbarkeit eingeschränkt ist.

---

## Diagnose

Typische Diagnosebefehle:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps

.\scripts\tests\test-stack-readiness.ps1

.\scripts\tests\test-daily-operations.ps1

docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 prometheus
```

Einordnung:

```text
Wenn Web und Redis weiter erfolgreich geprüft werden,
liegt der Fehler nicht im Kernpfad der Anwendung,
sondern im Monitoring-Bereich.
```

---

## Behebung

Prometheus wurde wieder gestartet:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml start prometheus
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

Erwartetes Ergebnis nach der Behebung:

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
Prometheus war gestoppt und wurde neu gestartet. Web und Redis blieben bereit. Danach war der Daily-Operations-Check wieder ohne ERROR.
```

---

## Kommunikationsstufe B: kurzer Ticket-Kommentar

```text
Daily-Operations-Check meldete den Stack als nicht bereit, da Prometheus nicht verfügbar war. Web und Redis blieben fachlich bereit. Prometheus wurde neu gestartet, anschließend war der Monitoring-Stack wieder healthy und der Daily-Operations-Check meldete wieder ERROR: 0.
```

---

## Lessons Learned

- App-Bereitschaft und Monitoring-Bereitschaft sind nicht dasselbe.
- Ein Prometheus-Ausfall macht die Anwendung nicht zwingend sofort unbenutzbar.
- Ein Monitoring-Ausfall ist trotzdem betrieblich relevant, weil Metriken, Dashboards und spätere Alerts betroffen sein können.
- Der Daily-Operations-Check ist hilfreich, weil er nicht nur Web und Redis prüft, sondern auch Monitoring-Komponenten.
- Für den Betrieb ist wichtig zu unterscheiden: Ist die Anwendung betroffen oder die Beobachtbarkeit?

---

## Mustererkennung

```text
Symptom:
Daily-Operations-Check meldet ERROR.

Betroffener Bereich:
Monitoring.

Betroffener Service:
Prometheus.

Mögliche Ursache:
Prometheus-Service wurde gestoppt oder ist ausgefallen.

Diagnose:
docker compose ps
test-stack-readiness.ps1
test-daily-operations.ps1
Prometheus-Logs prüfen

Bewertung:
Web + Redis können weiterhin fachlich bereit sein.
Monitoring ist jedoch beschädigt.

Maßnahme:
Prometheus neu starten.

Verifikation:
Prometheus ist wieder healthy.
Daily-Operations-Check meldet ERROR: 0.

Kommunikation:
Kurze Statusmeldung oder Ticket-Kommentar.
```

---

## Portfolio-Einordnung

Diese Simulation zeigt ein anderes Fehlerbild als ein Redis-Ausfall:

```text
Redis-Ausfall:
Anwendung fachlich nicht vollständig bereit.

Prometheus-Ausfall:
Anwendung läuft weiter, aber Monitoring ist gestört.
```

Damit trainiert das Lab nicht nur einzelne Befehle, sondern auch betriebliche Bewertung und Mustererkennung.
