# Docker Cleanup sicher bewerten

## Zweck

Dieses Dokument beschreibt, wie Docker-Ressourcen sicher geprüft werden, bevor etwas gelöscht wird.

Ziel ist nicht, möglichst viel zu löschen, sondern kontrolliert zu verstehen:

- Welche Container laufen?
- Welche Container sind gestoppt?
- Welche Images werden benutzt?
- Welche Volumes enthalten Daten?
- Welche Ressourcen wären theoretisch cleanup-fähig?

---

## Grundregel

> Cleanup beginnt nicht mit Löschen. Cleanup beginnt mit Inventur.

Besonders Docker Volumes dürfen nicht blind gelöscht werden, weil sie persistente Daten enthalten können.

---

## Sichere Inventur-Befehle

### Speicherübersicht anzeigen

```powershell
docker system df
```

Zeigt Speicherverbrauch für:

- Images
- Container
- lokale Volumes
- Build Cache

---

### Ausführliche Speicherübersicht anzeigen

```powershell
docker system df -v
```

`-v` bedeutet verbose, also ausführlicher.

Diese Ausgabe zeigt genauer:

- welche Images Speicher belegen
- welche Container existieren
- welche Volumes Speicher belegen
- welcher Build Cache vorhanden ist

---

### Alle Container anzeigen

```powershell
docker container ls -a
```

`-a` zeigt alle Container, auch gestoppte.

Wichtige Statuswerte:

| Status | Bedeutung |
|---|---|
| `Up` | Container läuft |
| `Exited` | Container ist beendet |
| `Created` | Container wurde erstellt, aber nicht gestartet |

---

### Images anzeigen

```powershell
docker image ls
```

Images sind Vorlagen, aus denen Container gestartet werden.

Wichtig ist die Spalte `In Use` oder die Information aus `docker system df -v`, ob ein Image noch von Containern genutzt wird.

---

### Volumes anzeigen

```powershell
docker volume ls
```

Volumes enthalten persistente Daten.

Bei Volumes gilt besondere Vorsicht:

| Aktion | Risiko |
|---|---|
| Container löschen | oft unkritisch |
| Image löschen | meist neu ladbar |
| Volume löschen | möglicher Datenverlust |

---

## Gefährliche Befehle

Die folgenden Befehle nicht blind ausführen:

```powershell
docker system prune
docker system prune -a
docker system prune --volumes
docker volume prune
docker compose down -v
```

### Bedeutung

| Befehl | Risiko |
|---|---|
| `docker system prune` | löscht ungenutzte Container, Netzwerke und Cache |
| `docker system prune -a` | löscht zusätzlich ungenutzte Images |
| `docker system prune --volumes` | kann Volumes löschen |
| `docker volume prune` | löscht ungenutzte Volumes |
| `docker compose down -v` | stoppt Compose-Stack und löscht zusätzlich Volumes |

---

## Bewertung im aktuellen Projekt

Im aktuellen Docker-Lab wurde festgestellt:

- Der aktive Stack besteht aus `web`, `redis`, `prometheus`, `grafana` und `cadvisor`.
- Die produktionsnahe Kombination ist `compose.prod.yml` plus `compose.monitoring.yml`.
- Aktive Volumes sind unter anderem:
  - `dockerbung_redis_data_prod`
  - `dockerbung_prometheus_data`
  - `dockerbung_grafana_data`
- Einige alte Redis-Testvolumes existieren noch als Lernartefakte.
- Cleanup ist aktuell nicht dringend nötig, weil der Speichergewinn gering wäre.

---

## Junior-taugliche Betriebsentscheidung

Für dieses Portfolio-Projekt gilt:

> Kein pauschales Cleanup ausführen.  
> Erst prüfen, dann gezielt entscheiden.  
> Volumes nur löschen, wenn klar ist, dass sie keine benötigten Daten enthalten.

---

## Empfohlene sichere Standardentscheidung

| Ressource | Entscheidung |
|---|---|
| Laufende Container | behalten |
| Aktive Volumes | behalten |
| Gestoppte Testcontainer | nur gezielt löschen |
| Alte Testimages | nur gezielt löschen |
| Build Cache | kann später kontrolliert bereinigt werden |
| Redis-/Grafana-/Prometheus-Volumes | nicht blind löschen |

---

## Merksatz

```text
down    = Container und Netzwerk entfernen, Volumes bleiben
down -v = Container, Netzwerk und Volumes entfernen
```

`down -v` ist nur sinnvoll, wenn Datenverlust beabsichtigt ist oder vorher ein Backup/Restore-Test durchgeführt wurde.
