# Grafana Monitoring Lab mit Docker, Prometheus, Alerting und Sensor-Simulation

Dieses Projekt erweitert ein lokales Docker-Monitoring-Lab um eine praxisnahe Observability- und Alerting-Strecke. Ziel war es, nicht nur Container-Metriken sichtbar zu machen, sondern typische BetriebszustÃ¤nde zu simulieren, automatisch zu erkennen und Ã¼ber Grafana-Alerts an einen lokalen Webhook-Receiver zu senden.

Der Stack besteht aus Docker Compose, Prometheus, Grafana, cAdvisor, einem HTTPS-Reverse-Proxy, einem lokalen Webhook-Receiver und einem selbst entwickelten Antennen-/Sensor-Simulator.

## Ziel des Labs

Das Lab zeigt eine vollstÃ¤ndige Monitoring-Kette:

```text
Simulator â†’ Prometheus â†’ Grafana Dashboard â†’ Grafana Alert â†’ Contact Point â†’ Webhook Receiver
```

Damit wird nicht nur sichtbar, dass Metriken angezeigt werden. Es wird auch gezeigt, dass ein simulierter Fehler automatisch erkannt, als Alert bewertet und an ein Zielsystem ausgeliefert wird.

## ArchitekturÃ¼berblick

| Komponente | Aufgabe |
|---|---|
| Docker Compose | Startet und verbindet die lokalen Services |
| Prometheus | Sammelt Metriken von cAdvisor, Prometheus selbst und dem Antennen-Simulator |
| Grafana | Visualisiert Metriken, Dashboards und Alerts |
| cAdvisor | Liefert Container-Metriken wie CPU- und Speicherwerte |
| HTTPS-Reverse-Proxy | Stellt den Webdienst Ã¼ber HTTP/HTTPS bereit |
| Webhook-Receiver | EmpfÃ¤ngt lokale Grafana-Alert-Benachrichtigungen |
| Antennen-/Sensor-Simulator | Simuliert BetriebszustÃ¤nde einer entfernten Antenne |

## Wichtige Projektdateien

| Datei / Ordner | Zweck |
|---|---|
| `compose.monitoring.yml` | Monitoring-Services wie Prometheus, Grafana und cAdvisor |
| `compose.proxy.yml` | HTTPS-Reverse-Proxy |
| `compose.antenna-simulator.yml` | Antennen-/Sensor-Simulator |
| `monitoring/prometheus/prometheus.yml` | Prometheus-Scrape-Konfiguration |
| `monitoring/antenna-simulator/antenna_simulator.py` | Simulator mit Metriken, Status-Endpunkten und GeoJSON |
| `monitoring/grafana/exports/` | Exportierte Dashboards, Alert Rules und Contact Points |
| `scripts/maintenance/` | Wartungs- und Automatisierungsskripte |

## Prometheus Target Health

Prometheus erreicht die relevanten Targets: `antenna-simulator`, `cadvisor` und `prometheus`.

![Prometheus Target Health](../assets/screenshots/grafana-monitoring/01-prometheus-target-health-up.png)

## HTTPS-Reverse-Proxy mit Healthcheck

Der Reverse Proxy wurde um einen Docker Healthcheck erweitert. Dadurch zeigt Docker nicht nur `Up`, sondern `healthy`. ZusÃ¤tzlich wurde der HTTPS-Zugriff per `curl.exe -k -I https://localhost` geprÃ¼ft.

![Reverse Proxy healthy](../assets/screenshots/grafana-monitoring/02-reverse-proxy-healthy-https-ok.png)

## Simulierter Target-Ausfall im Docker Stack

FÃ¼r einen realistischen Monitoring-Test wurde cAdvisor absichtlich gestoppt. Das Docker Stack Health Dashboard zeigte daraufhin `cadvisor DOWN`, `prometheus UP` und `Targets Down = 1`.

![cAdvisor down](../assets/screenshots/grafana-monitoring/03-docker-stack-cadvisor-down.png)

## Alerting und Webhook-Receiver

Grafana erkannte den Target-Ausfall und lÃ¶ste einen Alert aus. Der Alert wurde Ã¼ber den Contact Point an den lokalen Webhook-Receiver gesendet. Im Terminal war der Payload sichtbar.

![Webhook target down](../assets/screenshots/grafana-monitoring/04-webhook-prometheus-target-down.png)

## Antennen-/Sensor-Simulator

Der Simulator erzeugt Prometheus-Metriken fÃ¼r einen fiktiven Antennenstandort. Er kann verschiedene BetriebszustÃ¤nde simulieren:

| Modus | Bedeutung |
|---|---|
| `normal` | Normalbetrieb |
| `weak_signal` | Schwaches Mobilfunksignal |
| `many_errors` | Viele Fehler, z. B. Firmware-, API- oder Datenformatproblem |
| `delayed_packets` | VerzÃ¶gerte Pakete, z. B. schlechte NetzqualitÃ¤t oder Gateway-Ãœberlastung |
| `low_battery` | Niedriger Batteriestand, Wartung nÃ¶tig |
| `no_packets` | Keine Pakete, mÃ¶gliche Ursachen: Stromausfall, Netzproblem oder Antennendefekt |

## Normalbetrieb

Im Normalbetrieb ist die Antenne online, die SignalstÃ¤rke ist stabil, die PaketverzÃ¶gerung niedrig und der aktuelle Modus ist `normal`.

![Antenna normal](../assets/screenshots/grafana-monitoring/05-antenna-dashboard-normal.png)

## Fehlerfall: weak_signal

Im Modus `weak_signal` fÃ¤llt die SignalstÃ¤rke deutlich ab. Gleichzeitig steigt die PaketverzÃ¶gerung. Dieser Zustand kann auf Standort-, Wetter-, Provider-, SIM- oder Antennenprobleme hinweisen.

![Antenna weak signal](../assets/screenshots/grafana-monitoring/06-antenna-dashboard-weak-signal.png)

## Fehlerfall: many_errors

Im Modus `many_errors` steigt die Fehlerrate sichtbar. Dieser Zustand eignet sich zur Simulation von Firmware-, API-, Datenformat- oder Sensorproblemen.

![Antenna many errors](../assets/screenshots/grafana-monitoring/07-antenna-dashboard-many-errors.png)

## Fehlerfall: no_packets

Im Modus `no_packets` kommen keine Pakete mehr an. Das Dashboard zeigt die Antenne als `OFFLINE`, der Paketdurchsatz fÃ¤llt auf `0` und der aktuelle Modus ist `no_packets`.

![Antenna no packets](../assets/screenshots/grafana-monitoring/08-antenna-dashboard-no-packets-offline.png)

## Antennen-Alert per Webhook

ZusÃ¤tzlich zu den Dashboard-ZustÃ¤nden wurden Grafana-Alert-Regeln fÃ¼r den Simulator erstellt. Eine AntennenstÃ¶rung wurde automatisch erkannt und an den lokalen Webhook-Receiver gesendet.

![Webhook antenna alert](../assets/screenshots/grafana-monitoring/09-webhook-antenna-weak-signal-alert.png)

## Standortvisualisierung mit GeoJSON

Das Dashboard wurde um eine Geomap erweitert. Der Simulator stellt dafÃ¼r einen GeoJSON-Endpunkt bereit:

```text
/location.geojson
```

Dieser Endpunkt beschreibt einen ungefÃ¤hren Demo-Standort der simulierten Antenne. Die Koordinaten sind bewusst nicht als private Adresse zu verstehen, sondern dienen nur als Standortbeispiel.

![Antenna site map](../assets/screenshots/grafana-monitoring/10-antenna-site-map-geomap.png)

## Statisches vs. dynamisches GeoJSON

Ein wichtiger Lernpunkt war der Unterschied zwischen statischem und dynamischem GeoJSON.

Statisches GeoJSON beantwortet die Frage:

```text
Wo ist das Objekt?
```

Dynamisches GeoJSON kann zusÃ¤tzlich aktuelle Betriebsdaten enthalten:

```text
Wie ist der aktuelle Zustand dieses Objekts?
```

Im Lab gibt es deshalb zusÃ¤tzlich einen dynamischen Status-Endpunkt:

```text
/location-status.geojson
```

Dieser enthÃ¤lt neben dem Standort auch aktuelle Werte wie:

- aktueller Modus
- Online-Status
- Severity
- SignalstÃ¤rke
- Batteriestand
- PaketverzÃ¶gerung
- Last-Seen-Age

Die experimentelle Dynamic-GeoJSON-/Alpha-Layer-Idee in Grafana ist ein interessanter technischer Ausblick. FÃ¼r dieses Portfolio wurde jedoch bewusst zunÃ¤chst die stabilere Standardvorgehensweise mit einem GeoJSON-Layer verwendet.

## Export und Versionierung

Alle relevanten Konfigurationen wurden exportiert und versioniert:

| Konfiguration | Format |
|---|---|
| Grafana Dashboards | JSON |
| Grafana Alert Rules | YAML |
| Grafana Contact Points | YAML |
| Docker Compose | YAML |
| Prometheus-Konfiguration | YAML |

Der Merksatz aus dem Lernprozess: Im Projekt kamen â€žJammel und Jasonâ€œ zum Einsatz â€“ gemeint sind YAML und JSON.

## Produktion vs. Lab

Dieses Projekt ist ein lokales Lern- und Portfolio-Lab. In einer produktiven Umgebung wÃ¤ren zusÃ¤tzliche SchutzmaÃŸnahmen notwendig:

- keine ungeschÃ¼tzten Lab-Control-Endpunkte Ã¶ffentlich bereitstellen
- Webhooks per HTTPS absichern
- HMAC-Signaturen oder Ã¤hnliche Verfahren zur PrÃ¼fung von Webhook-Nachrichten nutzen
- Secrets und Tokens niemals in Repositories oder Screenshots verÃ¶ffentlichen
- Zugriff auf Grafana und Prometheus absichern
- Alerts an reale Systeme wie E-Mail, Slack, Microsoft Teams oder Incident-Management anbinden
- Dashboards, Alert Rules und Contact Points standardisiert provisionieren

## Ergebnis

Das Lab zeigt einen vollstÃ¤ndigen Monitoring- und Alerting-Workflow mit Docker, Prometheus und Grafana. Besonders praxisnah ist der Antennen-/Sensor-Simulator, weil typische Betriebsprobleme gezielt ausgelÃ¶st und im Dashboard sichtbar gemacht werden kÃ¶nnen.

Der wichtigste Nachweis ist die vollstÃ¤ndige Kette:

```text
StÃ¶rung simulieren â†’ Metrik Ã¤ndert sich â†’ Grafana erkennt Zustand â†’ Alert wird ausgelÃ¶st â†’ Webhook empfÃ¤ngt Payload
```
