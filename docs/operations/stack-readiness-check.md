# Stack-Readiness-Check

## Zweck

Diese Übung ergänzt die bisherigen Docker-Healthchecks um einen externen Betriebscheck.

Bisher wurde geprüft:

- Container laufen
- Docker Healthchecks sind `healthy`
- Redis kann nach einem Ausfall neu starten
- Web bleibt technisch erreichbar

Jetzt prüfen wir zusätzlich:

> Ist der Stack aus Betriebssicht bereit?

Das ist nicht automatisch dasselbe wie „Container läuft“.

---

## 1. Job-Szenario

Ein Entwicklerteam sagt:

> „Docker zeigt alles als healthy an. Aber können wir von außen beweisen, dass Web erreichbar ist und Redis wirklich antwortet?“

Als Junior Cloud/DevOps Engineer sollst du einen einfachen, nachvollziehbaren Readiness-Check bereitstellen.

---

## 2. Betriebsanforderung

| Anforderung | Bedeutung |
|---|---|
| Web muss per HTTP antworten | Nutzer oder Load Balancer erreichen die App |
| Redis muss mit `PONG` antworten | Redis ist fachlich ansprechbar |
| Passwort darf nicht im Befehl sichtbar übergeben werden | Security-Basisregel |
| Check muss Exit-Code liefern | später für CI/CD nutzbar |
| Ausgabe soll Zeitstempel enthalten | bessere Nachvollziehbarkeit |
| keine Daten verändern | sicherer Betriebscheck |

---

## 3. Lernziel

Nach dieser Einheit sollst du erklären können:

```text
Containerstatus ist nicht dasselbe wie fachliche Betriebsbereitschaft.
Ein externer Readiness-Check prüft, ob wichtige Dienste wirklich erreichbar sind.
```

Wichtige Begriffe:

| Begriff | Erklärung |
|---|---|
| Healthcheck | Prüfung, ob ein einzelner Container gesund wirkt |
| Readiness | Prüfung, ob ein Dienst bereit ist, sinnvoll Traffic/Anfragen zu verarbeiten |
| Exit-Code | Rückgabewert eines Skripts; `0` bedeutet Erfolg, ungleich `0` bedeutet Fehler |
| Betriebscheck | externer Check, der einen nutzbaren Zustand nachweist |
| PING/PONG | einfacher Redis-Test: Redis antwortet auf `PING` mit `PONG` |

---

## 4. Umsetzung im Lab

Neue Datei:

```text
scripts/tests/test-stack-readiness.ps1
```

Das Skript prüft:

1. Docker-Compose-Status
2. Web über `http://localhost:8082`
3. Redis per `redis-cli ping`
4. Gesamtergebnis
5. Exit-Code

---

## 5. Befehle

```powershell
# Wechselt in den Projektordner.
cd "C:\Docker Übung"

# Führt den Stack-Readiness-Check aus.
.\scripts\tests\test-stack-readiness.ps1
```

---

## 6. Verifikation

Erwartung bei gesundem Stack:

```text
[OK] Web-Service antwortet mit HTTP Status 200.
[OK] Redis antwortet korrekt mit PONG.
[OK] Stack ist aus Sicht dieses Readiness-Checks bereit.
```

Zusätzlich kann der Exit-Code geprüft werden:

```powershell
# Zeigt den Exit-Code des letzten Befehls.
$LASTEXITCODE
```

Erwartung:

```text
0
```

---

## 7. Realistischer Fehlerfall

Redis ist gestoppt oder defekt.

Dann sollte der Check nicht „alles gut“ melden, sondern fehlschlagen.

Beispiel:

```powershell
# Stoppt Redis bewusst.
docker compose -f compose.prod.yml stop redis

# Führt den Readiness-Check aus.
.\scripts\tests\test-stack-readiness.ps1

# Startet Redis wieder.
docker compose -f compose.prod.yml start redis
```

Erwartung:

```text
Web kann noch erreichbar sein.
Redis antwortet nicht.
Stack ist aus Sicht des Readiness-Checks nicht bereit.
```

---

## 8. Diagnoseweg

Wenn der Check fehlschlägt:

```powershell
# Containerstatus prüfen.
docker compose -f compose.prod.yml ps

# Weblogs prüfen.
docker compose -f compose.prod.yml logs --tail=80 web

# Redislogs prüfen.
docker compose -f compose.prod.yml logs --tail=80 redis

# Redis-Health-Details prüfen.
docker inspect dockerbung-redis-1 --format '{{json .State.Health}}'
```

---

## 9. Fix oder Rollback

Redis wieder starten:

```powershell
docker compose -f compose.prod.yml start redis
```

Stack neu starten:

```powershell
docker compose -f compose.prod.yml up -d
```

Falls die neue Skriptdatei fehlerhaft ist und noch nicht committed wurde:

```powershell
git restore scripts/tests/test-stack-readiness.ps1
```

Falls sie untracked ist und entfernt werden soll:

```powershell
Remove-Item .\scripts\tests\test-stack-readiness.ps1
```

---

## 10. Dokumentation fürs Portfolio

Portfolio-Formulierung:

> Das Projekt enthält zusätzlich zu Docker-Healthchecks einen externen Stack-Readiness-Check. Dieser prüft, ob der Webdienst über HTTP erreichbar ist und Redis mit `PONG` antwortet. Das Skript gibt Zeitstempel aus, verwendet `REDISCLI_AUTH` statt Passwortübergabe über `redis-cli -a` und liefert einen Exit-Code, sodass es später in CI/CD-Checks integrierbar wäre.

---

## 11. Unterschied Lernlabor vs. Produktion

| Thema | Lernlabor | Produktion |
|---|---|---|
| Readiness-Check | PowerShell-Skript lokal | Load Balancer, Kubernetes Readiness Probe, Monitoring |
| Webprüfung | `localhost:8082` | DNS, Ingress, TLS, Auth, echte Endpunkte |
| Redisprüfung | `redis-cli ping` im Container | Managed Redis Monitoring, App-Level Dependency Check |
| Exit-Code | manuell prüfbar | CI/CD, Deployment Gate, Alerting |
| Secret-Handling | `REDISCLI_AUTH` | Secret Manager, Vault, Kubernetes Secrets |
| Logs | Terminalausgabe | zentrale Logging-/Monitoringplattform |

---

## 12. Architect-Notiz

Die größere Architekturfrage lautet:

> Was bedeutet „bereit“ für eine Anwendung?

Es gibt mehrere Ebenen:

```text
Container läuft
Dienst antwortet technisch
Abhängigkeiten antworten
Anwendung kann fachlich korrekt arbeiten
Nutzer können die Anwendung sinnvoll verwenden
```

Ein einzelner Healthcheck reicht selten für alle Ebenen. Gute Systeme unterscheiden zwischen:

- technischer Gesundheit
- fachlicher Betriebsbereitschaft
- Nutzererreichbarkeit
- Abhängigkeitsstatus
- Recovery-Fähigkeit

Diese Übung ist ein kleiner, aber wichtiger Schritt in diese Denkweise.
