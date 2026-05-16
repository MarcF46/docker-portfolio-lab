# Enterprise-/Betriebsübung: Redis fällt nach dem Start aus

## Zweck der Übung

Diese Übung trainiert den Unterschied zwischen:

- Start-Abhängigkeit: Ein Service startet erst, wenn eine Abhängigkeit bereit ist.
- Laufzeit-Abhängigkeit: Eine Abhängigkeit fällt später im Betrieb aus.
- Health Check: Ein periodischer Zustandstest eines Containers oder Dienstes.
- Restart Policy: Eine Regel, ob ein Container nach einem Exit automatisch neu gestartet wird.
- Incident Response: Systematisches Vorgehen bei Störungen.

Diese Übung ist bewusst nicht nur ein Tutorial, sondern eine realistische Betriebsübung für Cloud-/DevOps-Arbeit.

---

## 1. Job-Szenario

Ein Entwicklerteam meldet:

> "Der Stack startet sauber. Redis und Web sind healthy. Trotzdem wollen wir wissen, was passiert, wenn Redis später im Betrieb ausfällt. Bleibt die Website erreichbar? Startet Redis automatisch neu? Reagiert web darauf?"

Du bist als Cloud-/DevOps Engineer dafür verantwortlich, das Verhalten im Labor kontrolliert zu testen, zu dokumentieren und daraus eine Betriebsentscheidung abzuleiten.

---

## 2. Betriebsanforderung

Das System soll nachweisbar folgende Fragen beantworten:

1. Startet `web` erst, wenn `redis` healthy ist?
2. Was passiert, wenn `redis` manuell gestoppt wird?
3. Was passiert, wenn `redis` hart beendet wird?
4. Wird `redis` durch `restart: unless-stopped` automatisch neu gestartet?
5. Bleibt `web` weiterhin healthy?
6. Ist der aktuelle Web-Healthcheck ausreichend oder fachlich zu oberflächlich?

---

## 3. Lernziel

Nach dieser Übung sollst du erklären können:

- `depends_on: condition: service_healthy` wirkt beim Start.
- `depends_on` ist kein dauerhaftes Laufzeit-Monitoring.
- `restart: unless-stopped` reagiert auf Container-Exit, aber nicht auf jeden fachlichen Fehler.
- Ein Web-Healthcheck, der nur Nginx prüft, erkennt keine Redis-Abhängigkeit.
- In Production trennt man häufig Liveness und Readiness.
- Ein guter Betrieb braucht Beweise: Status, Logs, Inspect-Ausgabe und dokumentierte Testergebnisse.

---

## 4. Umsetzung im Lab

Diese Übung verändert deine Compose-Datei nicht.

Stattdessen führst du zwei Simulationen aus:

### Simulation A: Geplanter Redis-Stopp

Redis wird mit Docker Compose bewusst gestoppt.

Erwartung:
- Redis bleibt gestoppt.
- `restart: unless-stopped` startet Redis nicht automatisch neu, weil der Stopp absichtlich war.
- Web bleibt wahrscheinlich healthy, weil der Web-Healthcheck nur Nginx lokal prüft.

### Simulation B: Harter Redis-Crash

Redis wird mit `docker kill` hart beendet.

Erwartung:
- Docker erkennt, dass der Container unerwartet beendet wurde.
- Wegen `restart: unless-stopped` sollte Redis automatisch neu starten.
- Nach kurzer Zeit sollte Redis wieder healthy werden.
- Der Restart Count sollte steigen.

---

## 5. Befehle und Dateien

### Arbeitsordner

```powershell
cd "C:\Docker Übung"
```

### Vorbereitende Prüfung

```powershell
git status
docker compose -f compose.prod.yml ps
docker compose -f compose.prod.yml config
```

### Optional: aktuellen Commit zu GitHub pushen

```powershell
git push
```

### Simulation A: Redis bewusst stoppen

```powershell
docker compose -f compose.prod.yml stop redis
docker compose -f compose.prod.yml ps -a
docker compose -f compose.prod.yml ps web
docker compose -f compose.prod.yml logs --tail=30 redis
```

### Redis wieder starten

```powershell
docker compose -f compose.prod.yml start redis
Start-Sleep -Seconds 15
docker compose -f compose.prod.yml ps
```

### Simulation B: Redis hart beenden

```powershell
docker inspect dockerbung-redis-1 --format '{{.RestartCount}}'
docker kill dockerbung-redis-1
Start-Sleep -Seconds 15
docker compose -f compose.prod.yml ps
docker inspect dockerbung-redis-1 --format '{{.RestartCount}}'
docker compose -f compose.prod.yml logs --tail=40 redis
```

---

## 6. Verifikation: Wie beweisen wir, dass es funktioniert?

Sammle folgende Beweise:

1. Baseline:
   - `docker compose -f compose.prod.yml ps`
   - beide Services healthy

2. Nach geplantem Stopp:
   - `docker compose -f compose.prod.yml ps -a`
   - Redis ist stopped/exited
   - Web läuft weiter

3. Nach manuellem Start:
   - Redis ist wieder healthy

4. Nach hartem Kill:
   - Redis startet automatisch neu
   - `RestartCount` ist gestiegen
   - Redis wird wieder healthy

5. Logs:
   - `docker compose -f compose.prod.yml logs --tail=40 redis`

---

## 7. Realistischer Fehlerfall

Ein echter Redis-Ausfall könnte entstehen durch:

- Redis-Prozess stürzt ab.
- Host hat Speicherprobleme.
- Redis-Konfiguration ist fehlerhaft.
- Passwort/Secret wurde falsch geändert.
- Volume ist beschädigt oder voll.
- Netzwerk zwischen App und Redis ist gestört.
- Redis antwortet technisch, aber enthält fachlich falsche Daten.

---

## 8. Diagnoseweg

### Schritt 1: Gesamtstatus prüfen

```powershell
docker compose -f compose.prod.yml ps -a
```

### Schritt 2: Redis-Logs prüfen

```powershell
docker compose -f compose.prod.yml logs --tail=80 redis
```

### Schritt 3: Health-Status detailliert prüfen

```powershell
docker inspect dockerbung-redis-1 --format '{{json .State.Health}}'
```

### Schritt 4: Restart Count prüfen

```powershell
docker inspect dockerbung-redis-1 --format '{{.RestartCount}}'
```

### Schritt 5: Web separat prüfen

```powershell
docker compose -f compose.prod.yml ps web
```

### Schritt 6: Architekturfrage stellen

Wenn Web healthy bleibt, obwohl Redis down ist:

> Prüft der Web-Healthcheck wirklich die fachliche Betriebsfähigkeit oder nur den Nginx-Prozess?

---

## 9. Fix oder Rollback

### Fix bei geplant gestopptem Redis

```powershell
docker compose -f compose.prod.yml start redis
```

### Fix bei instabilem Redis

```powershell
docker compose -f compose.prod.yml restart redis
```

### Vollständiger Stack-Neustart

```powershell
docker compose -f compose.prod.yml down
docker compose -f compose.prod.yml up -d --build
```

### Rollback bei fehlerhafter Compose-Änderung

```powershell
git status
git restore compose.prod.yml
docker compose -f compose.prod.yml config
docker compose -f compose.prod.yml up -d --build
```

---

## 10. Dokumentation fürs Portfolio

Empfohlene neue Datei im Repository:

```text
docs/runtime-dependency-redis-outage.md
```

Empfohlener Commit:

```powershell
git add docs/runtime-dependency-redis-outage.md
git commit -m "Dokumentiere Redis-Laufzeitausfall und Diagnoseweg"
git push
```

Möglicher README-Hinweis:

```markdown
### Runtime Dependency Incident: Redis-Ausfall nach Start

Diese Übung dokumentiert den Unterschied zwischen Start-Abhängigkeit und Laufzeit-Abhängigkeit. Redis wird geplant gestoppt und hart beendet, um das Verhalten von `depends_on`, Healthchecks und Restart Policies zu prüfen. Die Ergebnisse zeigen, dass `depends_on: condition: service_healthy` beim Start hilft, aber kein vollständiges Runtime-Monitoring ersetzt.
```

---

## 11. Unterschied Lernlabor vs. Produktion

| Bereich | Lernlabor | Produktion |
|---|---|---|
| Orchestrierung | Docker Compose lokal | Kubernetes, Swarm, Nomad oder Cloud-Service |
| Healthcheck | ein Docker Healthcheck | getrennte Liveness-/Readiness-/Startup-Probes |
| Monitoring | manuelle Prüfung mit `ps`, `logs`, `inspect` | Prometheus, Grafana, Alertmanager, Cloud Monitoring |
| Recovery | manuelles `start`/`restart` | automatisierte Orchestrierung, Rolling Restart, Failover |
| Redis | einzelner Container | Managed Redis, Redis Sentinel, Redis Cluster oder HA-Service |
| Secrets | `.env`/lokale Variable | Secret Manager, Vault, Kubernetes Secrets mit klaren Policies |
| Doku | Markdown im Repo | Runbook, Incident Report, Change-Doku, Architekturentscheidung |
| Beweisführung | Terminalausgabe | Pipeline-Logs, Monitoring-Dashboards, Incident-Timeline |

---

## 12. Architect-Notiz

Die größere Architekturentscheidung lautet:

> Soll Redis eine harte Start- und Laufzeitabhängigkeit der Webanwendung sein oder darf die Anwendung degraded weiterlaufen?

Mögliche Architekturvarianten:

### Variante 1: Harte Abhängigkeit

Wenn Redis down ist, gilt die App als nicht bereit.

Geeignet für:
- Sessions liegen ausschließlich in Redis.
- Ohne Redis funktionieren Logins nicht.
- Caching ist fachlich kritisch.

### Variante 2: Weiche Abhängigkeit

Die App läuft weiter, aber mit eingeschränkter Funktion.

Geeignet für:
- Redis ist nur Cache.
- Daten können aus einer Datenbank neu geladen werden.
- Temporäre Performanceverschlechterung ist akzeptabel.

### Variante 3: Hochverfügbarer Redis-Dienst

Redis wird nicht als einzelner Container betrieben, sondern hochverfügbar.

Geeignet für:
- produktive Systeme
- kritische Sessions
- verteilte Locks
- Job Queues
- Anwendungen mit hoher Verfügbarkeit

Wichtige Architekturfrage:

> Ist Redis in diesem System Cache, Datenbank, Session Store, Queue oder kritische Infrastruktur?

Davon hängt ab, wie streng Healthchecks, Restart-Verhalten, Monitoring, Alerting, Backup/Restore und Hochverfügbarkeit geplant werden müssen.
