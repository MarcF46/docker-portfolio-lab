# Monitoring Incident Patterns

## Zweck

Diese Dokumentation fasst typische Fehlerbilder aus dem Docker Portfolio Lab zusammen.

Ziel ist Mustererkennung:

```text
Symptom → betroffener Service → betroffener Bereich → Diagnose → Maßnahme → Verifikation
```

Die Datei vergleicht vier bisher trainierte Szenarien:

```text
Redis-Ausfall
Prometheus-Ausfall
Grafana-Ausfall
cAdvisor-Ausfall
```

---

## Warum diese Unterscheidung wichtig ist

Nicht jeder Fehler bedeutet, dass die Anwendung selbst kaputt ist.

Im Betrieb muss unterschieden werden:

```text
Ist die Anwendung fachlich betroffen?
Ist die Metriksammlung betroffen?
Ist die Visualisierung betroffen?
Ist nur eine Metrikquelle betroffen?
```

Diese Unterscheidung hilft, schneller und professioneller zu reagieren.

---

## Übersicht der Fehlerbilder

| Ausfall | Betroffener Bereich | Anwendung fachlich bereit? | Monitoring betroffen? | Typische Auswirkung |
|---|---|---:|---:|---|
| Redis | Laufzeitabhängigkeit der App | nein / nicht vollständig | indirekt | Web kann laufen, aber Redis-Funktion fehlt |
| Prometheus | zentrale Metriksammlung | ja | ja | Targets/Metriken werden nicht mehr zentral gesammelt |
| Grafana | Visualisierung / Dashboard | ja | ja, Anzeige betroffen | Dashboards nicht verfügbar, Prometheus kann aber weiter sammeln |
| cAdvisor | Container-Metrikquelle | ja | ja, Containerdaten betroffen | Prometheus/Grafana laufen, aber Container-Metriken fehlen |

---

## Muster 1: Redis-Ausfall

### Typisches Symptom

```text
Daily-Operations-Check meldet ERROR.
Redis ist nicht verfügbar.
Redis PING/PONG schlägt fehl.
```

### Betroffener Bereich

```text
Laufzeitabhängigkeit der Anwendung
```

### Einordnung

Redis ist Teil des fachlichen App-Stacks.

Wenn Redis fehlt, kann die Anwendung je nach Architektur weiterhin teilweise erreichbar sein, aber sie ist fachlich nicht vollständig bereit.

### Diagnose

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps

.\scripts\tests\test-stack-readiness.ps1

.\scripts\tests\test-daily-operations.ps1

docker compose -f .\compose.prod.yml logs --tail=40 redis
```

### Maßnahme

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml start redis
```

### Verifikation

```text
Redis ist wieder healthy.
Redis antwortet auf PING mit PONG.
Readiness-Check ist erfolgreich.
Daily-Operations-Check meldet ERROR: 0.
```

### Merksatz

```text
Redis-Ausfall betrifft die fachliche Bereitschaft der Anwendung.
```

---

## Muster 2: Prometheus-Ausfall

### Typisches Symptom

```text
Daily-Operations-Check meldet ERROR.
Prometheus ist nicht verfügbar.
Prometheus Ready Check schlägt fehl.
```

### Betroffener Bereich

```text
zentrale Metriksammlung
```

### Einordnung

Prometheus sammelt Metriken und stellt sie Grafana als Datenquelle bereit.

Wenn Prometheus ausfällt, kann die Anwendung weiterlaufen. Monitoring und Metriksammlung sind jedoch zentral gestört.

### Diagnose

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps

.\scripts\tests\test-stack-readiness.ps1

.\scripts\tests\test-daily-operations.ps1

docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 prometheus
```

### Maßnahme

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml start prometheus
```

### Verifikation

```text
Prometheus ist wieder healthy.
Prometheus Ready Endpoint antwortet.
Daily-Operations-Check meldet ERROR: 0.
```

### Merksatz

```text
Prometheus-Ausfall bedeutet: Die Anwendung kann laufen, aber Monitoring-Datensammlung ist gestört.
```

---

## Muster 3: Grafana-Ausfall

### Typisches Symptom

```text
Daily-Operations-Check meldet ERROR.
Grafana ist nicht verfügbar.
Grafana Health API antwortet nicht.
```

### Betroffener Bereich

```text
Visualisierung / Dashboard-Zugriff
```

### Einordnung

Grafana visualisiert Daten aus Prometheus.

Wenn Grafana ausfällt, kann Prometheus weiterhin Metriken sammeln. Die Anwendung kann ebenfalls weiterlaufen. Betroffen ist vor allem die Anzeige, Analyse und Dashboard-Nutzung.

### Diagnose

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps

.\scripts\tests\test-stack-readiness.ps1

.\scripts\tests\test-daily-operations.ps1

docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 grafana
```

### Maßnahme

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml start grafana
```

### Verifikation

```text
Grafana ist wieder healthy.
Grafana Health API antwortet.
Dashboard ist wieder erreichbar.
Daily-Operations-Check meldet ERROR: 0.
```

### Merksatz

```text
Grafana-Ausfall bedeutet: Die Anzeige ist betroffen, nicht automatisch die Metriksammlung.
```

---

## Muster 4: cAdvisor-Ausfall

### Typisches Symptom

```text
Daily-Operations-Check meldet ERROR.
cAdvisor fehlt im Compose-Status.
cAdvisor Metrics Endpoint ist nicht erreichbar.
Prometheus Target cadvisor ist DOWN.
Prometheus Query up zeigt cadvisor = 0.
Grafana zeigt fehlende oder unterbrochene Container-Metriken.
```

### Betroffener Bereich

```text
Container-Metrikquelle
```

### Einordnung

cAdvisor liefert Container-Metriken.

Wenn cAdvisor ausfällt, kann die Anwendung weiterlaufen. Prometheus und Grafana können ebenfalls weiterlaufen, aber Prometheus bekommt keine aktuellen Container-Metriken von cAdvisor.

### Diagnose

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps

.\scripts\tests\test-stack-readiness.ps1

.\scripts\tests\test-daily-operations.ps1

docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 cadvisor
```

Prometheus prüfen:

```text
http://localhost:9090/targets
```

Prometheus Query:

```promql
up
```

### Maßnahme

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml start cadvisor
```

### Verifikation

```text
cAdvisor ist wieder healthy.
cAdvisor Metrics Endpoint antwortet.
Prometheus Target cadvisor ist wieder UP.
Query up zeigt cadvisor = 1.
Grafana zeigt wieder neue Container-Metriken.
Daily-Operations-Check meldet ERROR: 0.
```

### Merksatz

```text
cAdvisor-Ausfall bedeutet: Die Container-Metrikquelle ist gestört, nicht automatisch die Anwendung.
```

---

## Vergleich: Prometheus, Grafana und cAdvisor

| Komponente | Rolle | Wenn sie ausfällt |
|---|---|---|
| cAdvisor | liefert Container-Metriken | Containerdaten fehlen |
| Prometheus | sammelt und speichert Metriken | zentrale Metriksammlung gestört |
| Grafana | visualisiert Metriken | Dashboard/Anzeige gestört |

Vereinfachte Kette:

```text
cAdvisor → Prometheus → Grafana
```

Wenn vorne in der Kette etwas ausfällt, sieht man die Auswirkung oft hinten im Dashboard.

Das bedeutet aber nicht automatisch, dass Grafana die Ursache ist.

---

## Diagnosekette bei fehlenden Grafana-Daten

### Symptom

```text
Im Grafana-Dashboard kommen keine aktuellen Containerdaten mehr an.
```

### Nicht sofort tun

```text
Nicht sofort Grafana neu starten.
```

### Besserer Diagnoseweg

```text
1. Grafana prüfen:
   Ist das Dashboard erreichbar?

2. Prometheus prüfen:
   Ist die Datenquelle erreichbar?
   Sind Targets UP oder DOWN?

3. Query up ausführen:
   Welche Targets sind erreichbar?

4. cAdvisor prüfen:
   Läuft die Container-Metrikquelle?

5. Daily-Operations-Check ausführen:
   Gibt es ERROR-Meldungen?

6. Fix durchführen:
   betroffenen Service starten oder Ursache prüfen

7. Verifizieren:
   ERROR: 0, Targets UP, Dashboard zeigt wieder Daten
```

---

## Entscheidungslogik

### Frage 1: Ist Web erreichbar?

```text
Nein:
App oder Web-Service prüfen.

Ja:
weiter mit Redis / Monitoring.
```

### Frage 2: Antwortet Redis?

```text
Nein:
Redis-Ausfall oder Secret-/Netzwerkproblem prüfen.

Ja:
App-Readiness wahrscheinlich ok.
```

### Frage 3: Ist Prometheus erreichbar?

```text
Nein:
Monitoring-Datensammlung gestört.

Ja:
weiter mit Targets.
```

### Frage 4: Sind Prometheus Targets UP?

```text
prometheus DOWN:
Prometheus selbst oder Konfiguration prüfen.

cadvisor DOWN:
Container-Metrikquelle prüfen.
```

### Frage 5: Ist Grafana erreichbar?

```text
Nein:
Visualisierung gestört.

Ja:
Dashboard zeigt möglicherweise nur Symptome einer vorgelagerten Störung.
```

---

## Standard-Diagnosebefehle

### Stackstatus

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

### Fachliche App-Readiness

```powershell
.\scripts\tests\test-stack-readiness.ps1
```

### Gesamtzustand inklusive Monitoring

```powershell
.\scripts\tests\test-daily-operations.ps1
```

### Logs eines Services

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 <service>
```

Beispiele:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 prometheus

docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 grafana

docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml logs --tail=40 cadvisor
```

---

## Kommunikationsstufe A: ultrakurze Statusmeldungen

### Redis

```text
Redis war nicht verfügbar und wurde wieder gestartet. Danach war der Readiness-Check wieder erfolgreich.
```

### Prometheus

```text
Prometheus war gestoppt und wurde neu gestartet. Danach war der Daily-Operations-Check wieder ohne ERROR.
```

### Grafana

```text
Grafana war gestoppt und wurde neu gestartet. Web, Redis und Prometheus blieben verfügbar. Danach war der Daily-Operations-Check wieder ohne ERROR.
```

### cAdvisor

```text
cAdvisor war nicht erreichbar. Nach dem Neustart war das Target wieder UP und der Daily-Operations-Check wieder ohne ERROR.
```

---

## Kommunikationsstufe B: kurze Ticket-Kommentare

### Redis

```text
Daily-Operations-Check meldete den Stack als nicht bereit, da Redis nicht verfügbar war. Redis wurde neu gestartet, anschließend antwortete Redis wieder mit PONG und der Readiness-Check war erfolgreich.
```

### Prometheus

```text
Daily-Operations-Check meldete den Stack als nicht bereit, da Prometheus nicht verfügbar war. Web und Redis blieben fachlich bereit. Prometheus wurde neu gestartet, anschließend war der Monitoring-Stack wieder healthy und der Daily-Operations-Check meldete ERROR: 0.
```

### Grafana

```text
Daily-Operations-Check meldete den Stack als nicht bereit, da Grafana nicht verfügbar war. Web und Redis blieben fachlich bereit, Prometheus und cAdvisor liefen weiter. Grafana wurde neu gestartet, anschließend war die Grafana Health API wieder erreichbar und der Daily-Operations-Check meldete ERROR: 0.
```

### cAdvisor

```text
Prometheus zeigte das cAdvisor-Target als DOWN, während Web, Redis, Prometheus und Grafana weiter liefen. Die Query up bestätigte prometheus=1 und cadvisor=0. Nach dem Neustart von cAdvisor war der Metrics-Endpunkt wieder erreichbar, Grafana zeigte wieder neue Container-Metriken und der Daily-Operations-Check meldete ERROR: 0.
```

---

## Portfolio-Einordnung

Diese Übungen zeigen nicht nur Docker-Befehle, sondern Betriebsdenken:

```text
Fehler gezielt auslösen
Symptome beobachten
betroffenen Bereich unterscheiden
Diagnosepfad wählen
Service wiederherstellen
Verifikation durchführen
professionell kommunizieren
```

Das ist praxisnäher als nur einen Container zu starten.

---

## Wichtigster Lernpunkt

```text
Nicht jedes sichtbare Symptom zeigt die Ursache.

Grafana kann fehlende Daten anzeigen,
obwohl Grafana selbst nicht kaputt ist.

Prometheus kann laufen,
aber ein Target kann DOWN sein.

Die Anwendung kann laufen,
obwohl Monitoring teilweise beschädigt ist.
```

Professionelle Diagnose bedeutet:

```text
Symptom sehen
Kette verstehen
richtige Stelle prüfen
gezielt beheben
sauber verifizieren
kurz kommunizieren
