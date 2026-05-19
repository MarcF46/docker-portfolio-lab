# Incident-Simulation: Redis-Service gestoppt

## Zweck

Diese kurze Dokumentation beschreibt eine kontrollierte Fehlersimulation im Docker Portfolio Lab.

Ziel war es, zu prüfen, ob der farbige Daily-Operations-Check einen gestoppten Redis-Service erkennt und ob der Stack danach sauber wiederhergestellt werden kann.

---

## Szenario

Ein Redis-Ausfall wurde kontrolliert simuliert:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml stop redis
```

Danach wurde der Stackstatus geprüft:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

---

## Beobachtetes Symptom

Nach dem Stoppen von Redis lief der restliche Stack weiter:

```text
web         healthy
prometheus  healthy
grafana     healthy
cadvisor    healthy
redis       gestoppt / nicht im laufenden Compose-Status sichtbar
```

Der Web-Service war weiterhin erreichbar, aber der Gesamtstack war fachlich nicht vollständig bereit, weil Redis nicht verfügbar war.

---

## Erkennung durch Daily-Operations-Check

Der farbige Daily-Operations-Check wurde im Fehlerzustand ausgeführt:

```powershell
.\scripts\tests\test-daily-operations.ps1
```

Wichtige Meldungen:

```text
[ERROR] Service 'redis' wurde im Compose-Status nicht gefunden.
[ERROR] Readiness-Check meldete Exit-Code 1.
GESAMTSTATUS: NICHT BEREIT - es gibt ERROR-Meldungen.
```

Damit wurde der Fehler erfolgreich erkannt.

---

## Diagnose

Der Readiness-Check zeigte:

```text
Web-Service antwortet mit HTTP Status 200.
Redis-Service antwortet nicht, weil der Container nicht läuft.
Stack ist aus Sicht des Readiness-Checks NICHT bereit.
```

Einordnung:

```text
Der Webcontainer war technisch erreichbar.
Der Stack war aber fachlich nicht vollständig bereit, weil Redis fehlte.
```

Das ist wichtig, weil ein teilweise laufender Stack nicht automatisch bedeutet, dass die Anwendung vollständig betriebsbereit ist.

---

## Behebung

Redis wurde wieder gestartet:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml start redis
```

Danach wurde kurz gewartet:

```powershell
Start-Sleep -Seconds 10
```

Anschließend wurde der Status erneut geprüft:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

Redis war danach wieder `Up` und `healthy`.

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
Redis war gestoppt. Ich habe den Service neu gestartet. Danach waren Healthcheck und Readiness wieder erfolgreich.
```

---

## Kommunikationsstufe B: kurzer Ticket-Kommentar

```text
Daily-Operations-Check meldete den Stack als nicht bereit, da Redis nicht lief. Redis wurde neu gestartet. Anschließend war Redis wieder healthy, Web antwortete mit HTTP 200 und Redis mit PONG. Status: erledigt.
```

---

## Lessons Learned

- Ein laufender Web-Service bedeutet nicht automatisch, dass der gesamte Stack fachlich bereit ist.
- Redis ist eine Laufzeitabhängigkeit des Labs und muss separat geprüft werden.
- Der farbige Daily-Operations-Check erkennt fehlende oder gestoppte Services verständlich.
- Der Readiness-Check ist wichtig, weil er mehr prüft als nur den Containerstatus.
- Bekannte cAdvisor-/WSL2-Warnungen müssen fachlich eingeordnet werden und sind im lokalen Lab nicht automatisch kritisch.

---

## Mustererkennung

```text
Symptom:
Daily-Operations-Check meldet ERROR / Stack nicht bereit.

Betroffener Service:
Redis.

Mögliche Ursache:
Redis-Service wurde gestoppt oder ist ausgefallen.

Diagnose:
docker compose ps
test-stack-readiness.ps1
test-daily-operations.ps1

Bewertung:
Web läuft weiter, aber Stack ist fachlich nicht vollständig bereit.

Maßnahme:
Redis neu starten.

Verifikation:
Redis ist wieder healthy.
Readiness-Check erfolgreich.
Daily-Operations-Check meldet ERROR: 0.

Kommunikation:
Kurze Statusmeldung oder Ticket-Kommentar.
```

---

## Portfolio-Einordnung

Diese Simulation zeigt eine einfache, aber realistische Betriebsübung:

```text
Fehler kontrolliert auslösen
Fehler durch Prüfskript erkennen
betroffenen Service identifizieren
Service wiederherstellen
Zustand verifizieren
Ergebnis kurz dokumentieren
```

Das ist eine wichtige Grundlage für späteres Incident-, Monitoring- und Troubleshooting-Training.
