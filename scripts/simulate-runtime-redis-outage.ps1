# simulate-runtime-redis-outage.ps1
# Zweck:
# - simuliert einen Redis-Laufzeitausfall im lokalen Docker-Compose-Lab
# - zeigt den Unterschied zwischen manuellem Stop und Prozess-Ausfall
# - prüft, ob Restart Policy und Healthchecks erwartbar reagieren
#
# Lernhinweis:
# Dieses Skript ist stark kommentiert, damit jeder Befehl nachvollziehbar bleibt.
# In echter Production wären solche Skripte meistens kürzer; die ausführliche Erklärung
# gehört dort eher in ein Runbook oder eine Betriebsdokumentation.

# Stoppt das Skript bei schwerwiegenden Fehlern.
# Dadurch laufen Folgebefehle nicht einfach weiter, wenn ein wichtiger Schritt scheitert.
$ErrorActionPreference = "Stop"

# Definiert die Compose-Datei, mit der wir arbeiten.
# Vorteil: Wenn sich der Dateiname später ändert, muss er nur hier angepasst werden.
$ComposeFile = "compose.prod.yml"

# Definiert den Redis-Containernamen aus deinem aktuellen Projekt.
# Dieser Name kommt aus Docker Compose: Projektname + Service + Nummer.
$RedisContainer = "dockerbung-redis-1"

# Definiert das Redis-Passwort für das Lab.
# In echter Production würde so ein Passwort nicht hart im Skript stehen,
# sondern aus einem Secret Manager, einer sicheren CI/CD-Variable oder einer geschützten Umgebung kommen.
$RedisPassword = "local_redis_password_please_change"

Write-Host ""
Write-Host "=== Redis-Laufzeitausfall-Simulation ==="
Write-Host ""

# Prüft den aktuellen Compose-Status.
# Erwartung: redis und web sollten vor der Simulation laufen.
Write-Host "1) Ausgangszustand prüfen"
docker compose -f $ComposeFile ps

Write-Host ""

# Startet Redis vorsichtshalber.
# Grund: Wenn Redis vorher manuell gestoppt wurde, kann eine Crash-Simulation nicht sauber funktionieren.
Write-Host "2) Redis vorsichtshalber starten"
docker compose -f $ComposeFile start redis

# Wartet, damit Redis starten und seinen Healthcheck bestehen kann.
# Ohne Wartezeit würden wir eventuell zu früh prüfen.
Write-Host "3) 15 Sekunden warten, bis Redis healthy werden kann"
Start-Sleep -Seconds 15

# Prüft erneut den Status.
# Erwartung: redis sollte jetzt Up/healthy sein.
Write-Host "4) Status nach Redis-Start prüfen"
docker compose -f $ComposeFile ps

Write-Host ""

# Liest den RestartCount vor der Simulation aus.
# Dieser Wert zeigt, wie oft Docker den Container bereits automatisch neu gestartet hat.
Write-Host "5) RestartCount VOR dem simulierten Redis-Ausfall"
docker inspect $RedisContainer --format '{{.RestartCount}}'

Write-Host ""

# Simuliert einen Redis-Prozessausfall aus dem Container heraus.
# Warum nicht docker stop?
# - docker stop ist ein geplanter manueller Stop.
# - Docker ignoriert danach die Restart Policy, bis der Container manuell neu gestartet wird.
#
# Warum nicht docker kill?
# - docker kill ist ebenfalls ein manueller Eingriff von außen.
# - Für diese Übung wollen wir besser simulieren, dass der Hauptprozess im Container beendet wird.
#
# docker exec führt redis-cli IM laufenden Container aus.
# Redis SHUTDOWN NOSAVE beendet den Redis-Serverprozess.
# Dadurch endet der Hauptprozess des Containers, und Docker kann die Restart Policy anwenden.
Write-Host "6) Redis-Prozess im Container per redis-cli SHUTDOWN NOSAVE beenden"
docker exec $RedisContainer redis-cli -a $RedisPassword SHUTDOWN NOSAVE

# Wartet, damit Docker Zeit hat, Redis neu zu starten.
# Zusätzlich bekommt Redis Zeit, wieder healthy zu werden.
Write-Host "7) 20 Sekunden warten, damit Docker Recovery + Healthcheck durchführen kann"
Start-Sleep -Seconds 20

Write-Host ""

# Prüft den Compose-Status nach der Simulation.
# Erwartung: redis sollte wieder laufen und healthy werden.
Write-Host "8) Status NACH dem simulierten Redis-Ausfall prüfen"
docker compose -f $ComposeFile ps

Write-Host ""

# Liest den RestartCount nach der Simulation aus.
# Erwartung: Der Wert sollte höher sein als vorher.
Write-Host "9) RestartCount NACH dem simulierten Redis-Ausfall"
docker inspect $RedisContainer --format '{{.RestartCount}}'

Write-Host ""

# Zeigt die letzten Redis-Logs.
# Damit kann man nachvollziehen, ob Redis beendet und neu gestartet wurde.
Write-Host "10) Redis-Logs prüfen"
docker compose -f $ComposeFile logs --tail=60 redis

Write-Host ""
Write-Host "=== Simulation beendet ==="
Write-Host "Bewertung:"
Write-Host "- Wenn Redis wieder Up/healthy ist und RestartCount gestiegen ist, hat die Restart Policy gegriffen."
Write-Host "- Wenn web weiterhin healthy ist, prüft der Web-Healthcheck nur Nginx, nicht die Redis-Abhängigkeit."
Write-Host "- Das ist der Übergang zur nächsten Lerneinheit: fachliche Readiness Checks."
