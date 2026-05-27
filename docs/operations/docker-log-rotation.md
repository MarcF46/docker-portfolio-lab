# Docker Log Rotation

## Zweck

Dieses Dokument beschreibt die einfache Log-Rotation-Konfiguration im Docker Portfolio Lab.

Ziel ist, Container-Logs nicht unbegrenzt wachsen zu lassen.

Ohne Begrenzung können Container-Logs im Betrieb viel Speicherplatz belegen. Das kann dazu führen, dass ein Host oder eine Docker-Umgebung instabil wird.

---

## Betroffene Services

In diesem Lab wurde Log Rotation für die Hauptservices ergänzt:

```text
web
redis
```

Die Monitoring-Services bleiben in diesem Schritt unverändert.

---

## Konfiguration in Docker Compose

In `compose.prod.yml` wurde pro Service folgender Block ergänzt:

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## Bedeutung

| Option | Bedeutung |
|---|---|
| `logging` | Logging-Konfiguration für diesen Service |
| `driver: "json-file"` | Docker speichert Container-Logs als JSON-Dateien |
| `max-size: "10m"` | eine einzelne Logdatei darf maximal 10 MB groß werden |
| `max-file: "3"` | Docker behält maximal 3 Logdateien |
| Ergebnis | pro Container ungefähr maximal 30 MB lokale Docker-Logs |

---

## Warum pro Service?

Die Konfiguration wurde bewusst in `compose.prod.yml` gesetzt und nicht global in Docker Desktop oder im Docker-Daemon.

Vorteile im Lab:

```text
sichtbar im Repository
leicht nachvollziehbar
keine globale Änderung an Docker Desktop
keine Auswirkungen auf andere lokale Projekte
```

In Produktion würde man je nach Umgebung zusätzlich globale Docker-Daemon-Logging-Regeln, zentrale Logplattformen oder Orchestrator-Logging nutzen.

---

## Compose-Konfiguration prüfen

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml config
```

Dieser Befehl prüft, ob die Compose-Dateien syntaktisch korrekt sind und wie Docker Compose die finale Konfiguration zusammensetzt.

Gezielt nach Logging suchen:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml config | Select-String -Pattern "logging:", "max-size", "max-file", "json-file"
```

Erwartung:

```text
logging:
  driver: json-file
  max-file: "3"
  max-size: 10m
```

Hinweis:

```text
Docker Compose kann Ausgaben normalisieren.
Es ist okay, wenn max-size in der config-Ausgabe ohne Anführungszeichen erscheint.
```

---

## Container neu erstellen

Damit neue Logging-Optionen tatsächlich am Container aktiv werden, muss Docker Compose die betroffenen Container mit der neuen Konfiguration aktualisieren:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml up -d
```

---

## Aktive Logging-Konfiguration prüfen

```powershell
docker inspect dockerbung-web-1 --format '{{json .HostConfig.LogConfig}}'
docker inspect dockerbung-redis-1 --format '{{json .HostConfig.LogConfig}}'
```

Erwartung:

```json
{"Type":"json-file","Config":{"max-file":"3","max-size":"10m"}}
```

Diese Prüfung zeigt, dass die Logging-Konfiguration nicht nur in Compose steht, sondern wirklich im laufenden Container aktiv ist.

---

## YAML-Falle beim Redis-Healthcheck

Beim Umbau wurde der Redis-Healthcheck robuster geschrieben.

Problematisch war eine Inline-Schreibweise mit verschachtelten Anführungszeichen:

```yaml
test: ["CMD-SHELL", "REDISCLI_AUTH="$$(cat /run/secrets/redis_password)" redis-cli ping"]
```

Robuster ist die Block-Schreibweise:

```yaml
test:
  - CMD-SHELL
  - REDISCLI_AUTH="$$(cat /run/secrets/redis_password)" redis-cli ping
```

Vorteil:

```text
bessere Lesbarkeit
weniger YAML-Parsing-Probleme
klarere Struktur
```

---

## Lab vs. Produktion

| Thema | Lab | Produktion |
|---|---|---|
| Logspeicherung | Docker `json-file` mit Rotation | zentrale Logplattform oder Logging Driver |
| Begrenzung | `max-size: "10m"`, `max-file: "3"` | abhängig von Compliance, Speicher und Betriebsvorgaben |
| Analyse | `docker compose logs`, `docker inspect` | zentrale Suche, Dashboards, Alerting |
| Sicherheit | Logs vor Veröffentlichung prüfen | Zugriffsschutz, Retention, Maskierung sensibler Daten |

---

## Sicherheitsregeln

```text
Logs können sensible Informationen enthalten.
Logs nicht ungeprüft veröffentlichen.
Terminalausgaben und Screenshots vor Veröffentlichung prüfen.
Secrets dürfen nicht in Logs erscheinen.
```

---

## Fazit

Die Services `web` und `redis` nutzen nun eine einfache Log Rotation.

Damit zeigt das Lab einen wichtigen Betriebsgrundsatz:

```text
Container-Logs müssen begrenzt und kontrolliert werden,
damit sie nicht unbemerkt Speicherplatz füllen.
```
