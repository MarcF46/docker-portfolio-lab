# Docker Compose Umgebungen

## Zweck

Dieses Dokument erklärt die Docker-Compose-Dateien dieses Projekts.

Das Projekt nutzt mehrere Compose-Dateien, damit Entwicklung, produktionsnähere Ausführung, Monitoring und Registry-Tests getrennt betrachtet werden können.

---

## Compose-Dateien

| Datei | Services | Zweck |
|---|---|---|
| `compose.dev.yml` | `redis`, `web` | Entwicklungsumgebung |
| `compose.prod.yml` | `redis`, `web` | produktionsnähere App-Umgebung |
| `compose.monitoring.yml` | `prometheus`, `grafana`, `cadvisor` | Monitoring-Erweiterung |
| `compose.registry-test.yml` | Registry-Test | Test für lokale Registry und Image-Pull |

---

## Aktuell verwendeter Stack

Für den normalen Portfolio-Stand wird aktuell diese Kombination genutzt:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml up -d
```

Diese Kombination startet:

```text
redis
web
prometheus
grafana
cadvisor
```

---

## Status prüfen

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

Erwartung:

- `web` läuft und ist healthy
- `redis` läuft und ist healthy
- `prometheus` läuft und ist healthy
- `grafana` läuft und ist healthy
- `cadvisor` läuft und ist healthy

---

## Volumes dieser Kombination

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml config --volumes
```

Erwartete Volumes:

```text
redis_data_prod
prometheus_data
grafana_data
```

Docker Compose erzeugt daraus tatsächliche Docker-Volumes mit Projektpräfix:

```text
dockerbung_redis_data_prod
dockerbung_prometheus_data
dockerbung_grafana_data
```

---

## Sichere Standardbefehle

### Stack starten

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml up -d
```

`up` erstellt und startet die Services.  
`-d` bedeutet detached, also Start im Hintergrund.

### Stack anzeigen

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

`ps` zeigt die Container dieser Compose-Kombination.

### Stack stoppen

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml down
```

`down` stoppt und entfernt Container und Netzwerk.  
Benannte Volumes bleiben dabei erhalten.

---

## Wichtige Warnung

Nicht im normalen Lernbetrieb ausführen:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml down -v
```

`down -v` entfernt zusätzlich Volumes.  
Das kann Daten löschen.

Merksatz:

```text
down    = Container und Netzwerk weg, Volumes bleiben
down -v = Container, Netzwerk und Volumes weg
```

---

## Dev-Stack starten

```powershell
docker compose -f .\compose.dev.yml up -d
```

Der Dev-Stack ist für Entwicklung gedacht.  
Typisch ist hier ein Bind Mount, sodass Änderungen an Dateien im Projektordner schneller sichtbar werden können.

---

## Prod-Stack starten

```powershell
docker compose -f .\compose.prod.yml up -d --build
```

Der Prod-Stack ist produktionsnäher.  
Die Web-Dateien werden beim Build ins Image kopiert.

Wenn sich Dateien im App-Ordner ändern, muss das Image neu gebaut werden.

---

## Monitoring ergänzen

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml up -d
```

Damit wird die produktionsnähere App-Umgebung zusammen mit Monitoring gestartet.

---

## Registry-Test

```powershell
docker compose -f .\compose.registry-test.yml up -d
```

Diese Datei dient zum Testen von Image-Pull aus der lokalen Registry.

---

## Betriebsregel

Bei Docker Compose immer unterscheiden:

| Sicht | Befehl | Bedeutung |
|---|---|---|
| Konfigurationssicht | `docker compose ... config` | Was berechnet Compose aus den Dateien? |
| Laufzeitsicht | `docker compose ... ps` | Welche Container laufen aktuell? |
| Detailprüfung | `docker inspect` | Welche Mounts, Volumes und Einstellungen nutzt ein Container wirklich? |

Wichtiger Merksatz:

> Für Backup und Restore zählt im Ernstfall, welches Volume der laufende Container tatsächlich nutzt.
