# Prometheus Target API Check

## Zweck

Dieses Dokument beschreibt eine vertiefte Monitoring-Prüfung im Docker Portfolio Lab.

Ziel ist, nicht nur zu prüfen, ob die Monitoring-Container laufen, sondern ob Prometheus seine Targets fachlich erreichen kann.

---

## Betriebsfrage

Ein realistischer Auftrag wäre:

```text
Der Stack läuft laut Docker.
Bitte prüfe, ob Prometheus die Monitoring-Targets wirklich sieht.
```

Diese Prüfung unterscheidet zwischen:

```text
Container läuft
Container ist healthy
Prometheus ist ready
Prometheus kann Targets scrapen
Grafana kann Daten visualisieren
```

---

## Geprüfter Stack

Der Stack wurde mit produktionsnaher Compose-Datei, Monitoring und Reverse Proxy betrieben:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml ps
```

Zum Prüfzeitpunkt liefen unter anderem:

```text
web
redis
prometheus
grafana
cadvisor
reverse-proxy
```

Die relevanten Services waren aus Docker-Sicht `healthy`.

---

## Prometheus Readiness prüfen

```powershell
Invoke-WebRequest -Uri "http://localhost:9090/-/ready" -UseBasicParsing
```

Erwartetes Ergebnis:

```text
StatusCode : 200
Prometheus Server is Ready.
```

Bedeutung:

```text
Prometheus selbst ist betriebsbereit.
```

Wichtig:

```text
Prometheus ready bedeutet noch nicht automatisch,
dass alle Targets erfolgreich überwacht werden.
```

---

## Prometheus Query API prüfen

```powershell
Invoke-RestMethod -Uri "http://localhost:9090/api/v1/query?query=up"
```

Die PromQL-Abfrage `up` zeigt, ob Prometheus ein Target erfolgreich erreichen konnte.

Bedeutung:

| Wert | Bedeutung |
|---|---|
| `1` | Target erreichbar |
| `0` | Target nicht erreichbar |

---

## Prometheus Targets über API anzeigen

```powershell
$response = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/targets"

$response.data.activeTargets | Select-Object `
  @{Name="Job";Expression={$_.labels.job}},
  @{Name="Health";Expression={$_.health}},
  @{Name="ScrapeUrl";Expression={$_.scrapeUrl}},
  @{Name="LastError";Expression={$_.lastError}}
```

Ergebnis im Lab:

```text
Job        Health ScrapeUrl                      LastError
---        ------ ---------                      ---------
cadvisor   up     http://cadvisor:8080/metrics
prometheus up     http://prometheus:9090/metrics
```

Bedeutung:

```text
Prometheus sieht sich selbst.
Prometheus erreicht cAdvisor.
cAdvisor liefert Metriken über /metrics.
Es gibt keine aktuelle LastError-Meldung.
```

---

## Unterschied der Prüfungen

| Prüfung | Aussage |
|---|---|
| `docker compose ps` | Container laufen und Healthchecks sind aus Docker-Sicht okay |
| `/-/ready` | Prometheus selbst ist bereit |
| `query=up` | Prometheus kann Targets fachlich bewerten |
| `/api/v1/targets` | zeigt Ziel-URLs, Health und letzte Fehler |
| Grafana Dashboard | visualisiert Daten, ist aber nicht die eigentliche Datenquelle |

---

## Warum das wichtig ist

Ein Monitoring-System kann äußerlich laufen, aber trotzdem fachlich unbrauchbar sein.

Beispiele:

```text
Prometheus läuft, aber cAdvisor ist DOWN.
Grafana läuft, aber Prometheus-Datenquelle ist falsch.
cAdvisor läuft, aber /metrics liefert keine verwertbaren Daten.
Targets sind DOWN, obwohl Docker-Container laufen.
```

Darum reicht im Betrieb nicht:

```text
docker compose ps
```

Man muss zusätzlich prüfen:

```text
Prometheus Targets
Prometheus Queries
Grafana Datenquelle
Logs bei Fehlern
```

---

## Typische Fehlerbilder

| Symptom | Mögliche Ursache | Erste Prüfung |
|---|---|---|
| Target `cadvisor` ist DOWN | cAdvisor nicht erreichbar | `/api/v1/targets` |
| `LastError` ist gefüllt | Scrape-Fehler | Prometheus Target API |
| Grafana zeigt keine Daten | Datenquelle oder Query falsch | Grafana Data Source + Prometheus Query |
| Prometheus ready, aber keine Targets | falsche `prometheus.yml` | Prometheus Config und Logs |
| cAdvisor healthy, aber eingeschränkte Metriken | Docker Desktop/WSL2-Besonderheit | cAdvisor Logs und `/metrics` |

---

## Lab vs. Produktion

| Thema | Lab | Produktion |
|---|---|---|
| Prometheus | lokaler Container | zentrale oder hochverfügbare Monitoring-Plattform |
| Targets | Prometheus + cAdvisor | viele Services, Nodes, Exporter, Kubernetes Targets |
| Alerting | noch nicht aktiv | Alertmanager, On-Call, Eskalation |
| Retention | lokales Docker Volume | definierte Aufbewahrung und Storage-Planung |
| Zugriff | lokale Ports | Authentifizierung, TLS, Rollen, Netzwerkgrenzen |

---

## Fazit

Die vertiefte Prüfung zeigt:

```text
Prometheus ist ready.
Prometheus kann seine aktiven Targets abfragen.
cadvisor ist UP.
prometheus ist UP.
Es gibt keine LastError-Meldung.
```

Damit ist die Monitoring-Basis im Lab fachlich bestätigt.
