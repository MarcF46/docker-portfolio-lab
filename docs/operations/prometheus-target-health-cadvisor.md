# Prometheus Target Health: cAdvisor erkennen und einordnen

## Zweck

Diese kurze Dokumentation ergänzt die cAdvisor-Incident-Simulation.

Ziel ist zu zeigen, wie Prometheus selbst erkennt, ob cAdvisor als Metrikquelle erreichbar ist.

Dabei geht es nicht um die Anwendung selbst, sondern um die Beobachtbarkeit des Docker-Labs.

---

## Ausgangslage

Im Monitoring-Lab gilt vereinfacht:

```text
cAdvisor → Prometheus → Grafana
```

Bedeutung:

```text
cAdvisor liefert Container-Metriken.
Prometheus fragt diese Metriken regelmäßig ab.
Grafana visualisiert die Metriken aus Prometheus.
```

Wenn cAdvisor nicht erreichbar ist, kann Prometheus keine aktuellen Container-Metriken von cAdvisor abrufen.

---

## Normalzustand: cAdvisor ist UP

Prometheus Targets wurden im Browser geprüft:

```text
http://localhost:9090/targets
```

Im Normalzustand waren beide Targets erreichbar:

```text
cadvisor     UP
prometheus   UP
```

Einordnung:

```text
Prometheus kann cAdvisor erreichen.
Prometheus kann sich selbst erreichen.
Container-Metriken können grundsätzlich gesammelt werden.
```

Screenshot-Hinweis:

```text
Screenshot 1: Prometheus Targets im Normalzustand
Erkennbar: cadvisor UP, prometheus UP
```

---

## Fehlerzustand: cAdvisor ist DOWN

cAdvisor wurde kontrolliert gestoppt:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml stop cadvisor
```

Danach wurde kurz gewartet, damit Prometheus den Ausfall beim nächsten Scrape bemerken kann:

```powershell
Start-Sleep -Seconds 20
```

Prometheus Targets zeigte danach:

```text
cadvisor     DOWN
prometheus   UP
```

Zusätzlich erschien eine Fehlermeldung beim cAdvisor-Target:

```text
Error scraping target:
Get "http://cadvisor:8080/metrics":
dial tcp: lookup cadvisor ... no such host
```

Einordnung:

```text
Der cAdvisor-Container ist gestoppt.
Prometheus kann den Hostnamen cadvisor im Docker-Netzwerk nicht mehr erreichen.
Die Anwendung kann trotzdem weiterlaufen.
Container-Metriken fehlen jedoch.
```

Screenshot-Hinweis:

```text
Screenshot 2: Prometheus Targets im Fehlerzustand
Erkennbar: cadvisor DOWN, prometheus UP, Error scraping target
```

---

## Prometheus Query: up

In Prometheus wurde die Query ausgeführt:

```promql
up
```

Das Ergebnis zeigte:

```text
up{instance="prometheus:9090", job="prometheus"}  1
up{instance="cadvisor:8080", job="cadvisor"}      0
```

Bedeutung:

| Wert | Bedeutung |
|---:|---|
| `1` | Target ist erreichbar |
| `0` | Target ist nicht erreichbar |

Einordnung:

```text
prometheus = 1 bedeutet:
Prometheus selbst ist erreichbar.

cadvisor = 0 bedeutet:
cAdvisor ist für Prometheus nicht erreichbar.
```

Screenshot-Hinweis:

```text
Screenshot 3: Prometheus Query up
Erkennbar: prometheus=1, cadvisor=0
```

---

## Wiederherstellung

cAdvisor wurde wieder gestartet:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml start cadvisor
```

Danach wurde kurz gewartet:

```powershell
Start-Sleep -Seconds 25
```

Anschließend wurde der Daily-Operations-Check erneut ausgeführt:

```powershell
.\scripts\tests\test-daily-operations.ps1
```

Ergebnis nach der Wiederherstellung:

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

---

## Grafana-Sicht

Ein zusätzlicher Grafana-Screenshot kann sinnvoll sein, wenn sichtbar wird, dass Dashboards keine aktuellen cAdvisor-/Container-Metriken mehr anzeigen.

Mögliche Beobachtung:

```text
Prometheus zeigt cadvisor DOWN.
Grafana läuft weiter.
Grafana kann aber nur Daten anzeigen, die Prometheus noch verfügbar hat.
Aktuelle Container-Metriken können fehlen oder auslaufen.
```

Einordnung:

```text
Für Support- oder Betriebssituationen ist das realistisch:
Ein Fachbereich oder Team meldet, dass im Dashboard keine aktuellen Daten mehr ankommen.
Die technische Diagnose beginnt dann nicht zwingend bei Grafana selbst,
sondern bei Prometheus Targets und der Metrikquelle cAdvisor.
```

Screenshot-Hinweis:

```text
Optionaler Screenshot 4:
Grafana-Dashboard während cAdvisor nicht erreichbar ist,
falls Panels sichtbar keine aktuellen Containerdaten mehr erhalten.
```

---

## Mustererkennung

```text
Symptom:
Prometheus Target cadvisor ist DOWN
oder
Prometheus Query up zeigt cadvisor = 0

Betroffener Bereich:
Container-Metrikquelle

Betroffener Service:
cAdvisor

Nicht primär betroffen:
Web
Redis
Grafana als Oberfläche
Prometheus selbst

Diagnose:
Prometheus Targets prüfen
Prometheus Query up ausführen
docker compose ps prüfen
Daily-Operations-Check ausführen

Bewertung:
Die Anwendung kann weiterlaufen.
Die Container-Metrikerfassung ist gestört.

Maßnahme:
cAdvisor starten oder Fehlerursache prüfen.

Verifikation:
Prometheus Target cadvisor wieder UP
up{job="cadvisor"} wieder 1
Daily-Operations-Check ERROR: 0
```

---

## Kommunikationsstufe A: ultrakurze Statusmeldung

```text
Prometheus zeigte cAdvisor als DOWN. Nach dem Neustart von cAdvisor war das Target wieder erreichbar und der Daily-Operations-Check wieder ohne ERROR.
```

---

## Kommunikationsstufe B: kurzer Ticket-Kommentar

```text
Prometheus zeigte das cAdvisor-Target als DOWN, während Web, Redis, Prometheus und Grafana weiter liefen. Die Query up bestätigte prometheus=1 und cadvisor=0. Nach dem Neustart von cAdvisor war der Metrics-Endpunkt wieder erreichbar, und der Daily-Operations-Check meldete ERROR: 0.
```

---

## Lessons Learned

- Prometheus Targets zeigen, ob eine Metrikquelle erreichbar ist.
- Die Query `up` ist eine einfache und wichtige Prometheus-Grundlage.
- `up = 1` bedeutet erreichbar, `up = 0` bedeutet nicht erreichbar.
- Ein cAdvisor-Ausfall betrifft die Container-Metrikquelle, nicht automatisch die Anwendung.
- Grafana kann nur visualisieren, was Prometheus als Datenquelle bereitstellt.
- Bei fehlenden Dashboard-Daten sollte nicht nur Grafana geprüft werden, sondern auch Prometheus Targets und die eigentliche Metrikquelle.
