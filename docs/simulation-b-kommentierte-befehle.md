# Simulation B – Redis-Laufzeitausfall mit kommentierten Befehlen

## Zweck

Diese Befehlsnotiz dokumentiert die manuelle Variante der Redis-Laufzeitausfall-Simulation.

Wichtig: Diese Notiz ist als Lern- und Wiederholungsunterlage gedacht.  
Das ausführbare Skript dazu liegt unter:

```text
scripts/simulate-runtime-redis-outage.ps1
```

---

## Warum wir die Simulation angepasst haben

Ein manueller Stop mit `docker compose stop redis` oder ein manueller Kill mit `docker kill dockerbung-redis-1` ist kein perfekter Crash-Test.

Docker behandelt manuell gestoppte Container besonders: Die Restart Policy wird dann ignoriert, bis der Docker-Daemon neu startet oder der Container manuell wieder gestartet wird.

Darum simulieren wir den Laufzeitausfall besser so:

```text
docker exec → redis-cli → SHUTDOWN NOSAVE
```

Das bedeutet:

1. Wir führen einen Befehl im laufenden Redis-Container aus.
2. Redis beendet seinen eigenen Serverprozess.
3. Der Container-Hauptprozess endet.
4. Docker kann die Restart Policy anwenden.

---

## Manuelle Befehlsfolge

```powershell
# Wechselt in den Projektordner.
# Dadurch finden Docker Compose und Git die richtigen Projektdateien.
cd "C:\Docker Übung"

# Prüft den aktuellen Zustand der Services.
# Erwartung: redis und web sollten laufen.
docker compose -f compose.prod.yml ps

# Startet Redis vorsichtshalber.
# Grund: Wenn Redis vorher manuell gestoppt wurde, kann die Crash-Simulation nicht sauber geprüft werden.
docker compose -f compose.prod.yml start redis

# Wartet 15 Sekunden, damit Redis starten und seinen Healthcheck bestehen kann.
Start-Sleep -Seconds 15

# Prüft, ob Redis jetzt Up/healthy ist.
docker compose -f compose.prod.yml ps

# Zeigt, wie oft Docker den Redis-Container bisher automatisch neu gestartet hat.
# Diesen Wert merken wir uns, damit wir nach dem simulierten Ausfall vergleichen können.
docker inspect dockerbung-redis-1 --format '{{.RestartCount}}'

# Führt einen Befehl im laufenden Redis-Container aus.
# redis-cli verbindet sich mit Redis.
# -a übergibt das Passwort.
# SHUTDOWN NOSAVE beendet Redis ohne zusätzlichen Speichervorgang.
# Dadurch endet der Redis-Hauptprozess im Container.
docker exec dockerbung-redis-1 redis-cli -a local_redis_password_please_change SHUTDOWN NOSAVE

# Wartet 20 Sekunden.
# Docker bekommt Zeit, Redis wegen restart: unless-stopped neu zu starten.
# Redis bekommt zusätzlich Zeit, seinen Healthcheck wieder zu bestehen.
Start-Sleep -Seconds 20

# Prüft den Zustand der Services nach dem simulierten Ausfall.
# Erwartung: redis läuft wieder und wird healthy.
docker compose -f compose.prod.yml ps

# Zeigt den RestartCount erneut.
# Erwartung: Der Wert ist höher als vor SHUTDOWN NOSAVE.
docker inspect dockerbung-redis-1 --format '{{.RestartCount}}'

# Zeigt die letzten 60 Redis-Logzeilen.
# Damit prüfen wir, ob Redis beendet und neu gestartet wurde.
docker compose -f compose.prod.yml logs --tail=60 redis
```

---

## Erwartetes Ergebnis

```text
redis   Up ... (healthy)
web     Up ... (healthy)
RestartCount ist gestiegen
```

---

## Interpretation

Wenn Redis nach `SHUTDOWN NOSAVE` automatisch wieder startet, zeigt das:

```text
Die Restart Policy greift bei einem Prozess-Ausfall.
```

Wenn `web` weiterhin healthy bleibt, zeigt das:

```text
Der Web-Healthcheck prüft aktuell nur Nginx, nicht die Redis-Abhängigkeit.
```

Das ist nicht automatisch falsch. Es zeigt nur, dass der aktuelle Healthcheck technisch ist, aber noch kein vollständiger fachlicher Readiness Check.

---

## Portfolio-Notiz

Diese Übung zeigt den Unterschied zwischen:

| Begriff | Bedeutung |
|---|---|
| Start-Abhängigkeit | web wartet beim Start auf healthy redis |
| Laufzeit-Ausfall | redis fällt nach dem Start aus |
| Restart Policy | Docker startet Redis nach Prozess-Ende neu |
| technischer Healthcheck | prüft, ob ein Dienst grundsätzlich antwortet |
| fachlicher Readiness Check | prüft, ob die App inklusive Abhängigkeiten wirklich betriebsbereit ist |
