# Logging-Grundlagen im Docker Compose Lab

## Zweck

Diese Lerneinheit dokumentiert die Grundlagen zum Lesen und Einordnen von Docker-Compose-Logs.

Ziel ist nicht, ein vollständiges zentrales Logging-System aufzubauen, sondern die operative Grundfähigkeit zu trainieren:

```text
Logs gezielt abrufen
Logs pro Service lesen
Logs zeitlich eingrenzen
Live-Logs beobachten
Warnungen von echten Fehlern unterscheiden
```

---

## 1. Job-Szenario

Ein Teamlead sagt:

> „Der Stack läuft und Monitoring ist sichtbar. Jetzt möchte ich wissen: Wie schauen wir in die Logs, wenn ein Dienst Probleme macht?“

In einer Junior-Cloud-/DevOps-Rolle ist das eine typische Aufgabe:

```text
Status prüfen
Logs eingrenzen
auffällige Meldungen einordnen
nächsten Diagnose-Schritt ableiten
```

---

## 2. Betriebsanforderung

| Anforderung | Bedeutung |
|---|---|
| Stackstatus prüfen | Sind die Container gestartet und healthy? |
| Logs aller Services ansehen | Groben Überblick bekommen |
| Logs pro Service ansehen | Zielgerichtete Diagnose |
| `--tail` nutzen | Logmenge begrenzen |
| `--since` nutzen | Zeitraum eingrenzen |
| `--follow` nutzen | Live beobachten |
| Warnung vs. Fehler unterscheiden | Nicht jede rote Meldung ist ein Ausfall |
| Security beachten | Keine Secrets oder personenbezogenen Daten in Logs |

---

## 3. Wichtige Begriffe

| Begriff | Erklärung |
|---|---|
| Log | Textmeldung eines Programms oder Containers |
| stdout | normale Ausgabe eines Prozesses |
| stderr | Fehler- oder Warn-Ausgabe eines Prozesses |
| `--tail` | zeigt nur die letzten X Logzeilen |
| `--since` | zeigt Logs ab einem Zeitpunkt oder Zeitraum |
| `--follow` | bleibt live an den Logs dran |
| Logging Driver | Docker-Komponente, die entscheidet, wohin Container-Ausgaben geschrieben werden |
| Loglevel | Schweregrad einer Meldung, z. B. info, warning, error |

---

## 4. Logging Driver kurz erklärt

Ein Container schreibt normalerweise Text nach:

```text
stdout = normale Ausgabe
stderr = Warnungen oder Fehler
```

Docker nimmt diese Ausgaben entgegen. Der Logging Driver entscheidet, wie diese Ausgaben gespeichert oder weitergeleitet werden.

Vereinfacht:

```text
Container erzeugt Ausgabe
→ Docker nimmt Ausgabe entgegen
→ Logging Driver speichert/leitet sie weiter
→ docker logs / docker compose logs zeigt sie an
```

Im lokalen Lab reicht:

```powershell
docker compose logs
```

In Produktion stellt man zusätzliche Fragen:

```text
Wo landen Logs zentral?
Wie lange werden Logs aufbewahrt?
Wer darf Logs lesen?
Sind Secrets oder personenbezogene Daten enthalten?
Wie sucht man nach Zeit, Service, Fehlerlevel oder Request-ID?
Was passiert bei sehr großen Logmengen?
```

Typische produktionsnahe Lösungen können sein:

```text
Cloud Logging
Elastic / OpenSearch
Grafana Loki
Splunk
Fluent Bit / Fluentd
SIEM-Systeme
```

---

## 5. Grundbefehle

### Stackstatus prüfen

```powershell
# Wechselt sicher in den Projektordner.
cd "C:\Docker Übung"

# Zeigt den Status des gesamten Stacks.
# Erwartung: web, redis, prometheus, grafana und cadvisor sind Up/healthy.
docker compose -f compose.prod.yml -f compose.monitoring.yml ps
```

### Logs aller Services kurz ansehen

```powershell
# Zeigt die letzten 10 Logzeilen aller Services.
# Grund: Überblick bekommen, ohne von Logs erschlagen zu werden.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=10
```

### Logs pro Service lesen

```powershell
# Zeigt die letzten 20 Web-Logs.
# Grund: Webzugriffe und Healthchecks erkennen.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 web

# Zeigt die letzten 20 Redis-Logs.
# Grund: Redis-Start, Persistenz und mögliche Warnungen prüfen.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 redis

# Zeigt die letzten 20 Prometheus-Logs.
# Grund: Start, Konfigurationsladen und Scraping-Probleme erkennen.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 prometheus

# Zeigt die letzten 20 Grafana-Logs.
# Grund: Start, Provisioning und Dashboard-/Datenquellen-Hinweise erkennen.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 grafana

# Zeigt die letzten 20 cAdvisor-Logs.
# Grund: Container-Metrik-Erfassung und WSL2-/Host-Hinweise einordnen.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=20 cadvisor
```

### Logs zeitlich eingrenzen

```powershell
# Zeigt nur Logs der letzten 10 Minuten.
# Grund: In echten Incidents will man nicht alte Meldungen durchsuchen.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --since=10m

# Zeigt nur Grafana-Logs der letzten 10 Minuten.
# Grund: Service gezielt prüfen.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --since=10m grafana
```

### Live-Logs beobachten

```powershell
# Hängt sich live an die Web-Logs.
# Erwartung: Neue HTTP-Zugriffe erscheinen sofort im Terminal.
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --follow --tail=5 web
```

Dann im Browser öffnen:

```text
http://localhost:8082/?test=logcheck
```

Danach im PowerShell-Terminal:

```text
Ctrl+C
```

Wichtig:

```text
Ctrl+C beendet nur das Live-Mitlesen.
Der Container wird dadurch nicht gestoppt.
```

---

## 6. Beobachtetes Ergebnis im Lab

### Stackstatus

Alle relevanten Services liefen als `healthy`:

```text
web
redis
prometheus
grafana
cadvisor
```

### cAdvisor-Logs

In den cAdvisor-Logs traten wiederkehrende Meldungen auf:

```text
Failed to get system UUID
Error while reading product_name
Couldn't collect info from machine-id
```

Einordnung:

```text
Diese Meldungen sind in diesem Docker-Desktop-/WSL2-Lab erwartbare Umgebungshinweise.
Sie sind nicht automatisch fatal.
```

Warum nicht fatal?

```text
cAdvisor läuft weiterhin.
Prometheus Target cadvisor ist UP.
cAdvisor /metrics liefert Daten.
Grafana zeigt Container-Metriken.
Der Containerstatus ist healthy.
```

### Web-Logs

Die Web-Logs zeigten zwei Arten von Zugriffen.

#### Automatische Healthcheck-Zugriffe

```text
127.0.0.1 ... "GET / HTTP/1.1" 200 ... "Wget"
```

Einordnung:

```text
Das sind normale Healthcheck-Zugriffe.
Der Webcontainer prüft regelmäßig, ob Nginx auf HTTP antwortet.
HTTP 200 bedeutet erfolgreich.
```

#### Browserzugriff

```text
172.18.0.1 ... "GET /?test=logcheck HTTP/1.1" 200 ... "Mozilla/5.0 ..."
```

Einordnung:

```text
Das war der bewusst ausgelöste Browseraufruf.
Der Query-String ?test=logcheck macht den Zugriff eindeutig erkennbar.
Mozilla/5.0 zeigt, dass die Anfrage aus dem Browser kam.
HTTP 200 bedeutet erfolgreich.
```

---

## 7. Warnung vs. Fehler

Eine Meldung mit `error`, `failed` oder `warning` ist nicht automatisch ein Ausfall.

Die professionelle Einordnung fragt:

```text
Läuft der Container?
Ist der Container healthy?
Antwortet der Dienst fachlich?
Ist das Verhalten für die Umgebung erwartbar?
Gibt es Auswirkungen auf Nutzer oder abhängige Services?
Gibt es wiederkehrende oder neue Fehler?
```

Beispiel cAdvisor:

```text
Logmeldung: Failed to get system UUID
Status: Container healthy
Prometheus Target: UP
Metrics-Endpunkt: erreichbar
Einordnung: Umgebungshinweis, kein akuter Ausfall im Lab
```

Beispiel Web:

```text
Logmeldung: GET / HTTP/1.1 200
Status: Container healthy
Einordnung: normaler erfolgreicher Request
```

---

## 8. Typische Diagnosefragen im Betrieb

Ein erfahrener Engineer oder Teamlead könnte fragen:

```text
Welcher Service ist betroffen?
Seit wann tritt das Problem auf?
Gibt es neue Logs seit dem letzten Deployment?
Ist es eine Warnung oder ein echter Fehler?
Ist der Service healthy?
Antwortet der Service fachlich?
Gibt es auffällige Muster alle X Sekunden?
Kannst du nur die letzten 10 Minuten anzeigen?
Kannst du live beobachten, was beim Browseraufruf passiert?
```

Dafür sind diese Befehle wichtig:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml ps
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --tail=50 SERVICE
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --since=10m SERVICE
docker compose -f compose.prod.yml -f compose.monitoring.yml logs --follow --tail=10 SERVICE
```

---

## 9. Security-Hinweise zu Logs

Logs können sensible Informationen enthalten:

```text
Passwörter
Tokens
API Keys
Session IDs
Benutzernamen
IP-Adressen
interne Hostnamen
interne Pfade
personenbezogene Daten
```

Deshalb:

```text
Keine Secrets in Logs schreiben.
Terminal-Ausgaben vor Screenshots prüfen.
Öffentliche Screenshots zuschneiden.
Logs nicht ungeprüft in GitHub committen.
Retention und Zugriffsschutz für Logs planen.
```

Im Projekt gilt:

```text
logs/backup-restore.log wird ignoriert.
Terminal-Mitschnitte bleiben privat.
Screenshots werden vor öffentlicher Nutzung geprüft und zugeschnitten.
```

---

## 10. Unterschied Lernlabor vs. Produktion

| Thema | Lernlabor | Produktion |
|---|---|---|
| Logzugriff | `docker compose logs` | zentrale Logplattform |
| Zeitraum | manuell mit `--since` | Zeitfilter und Suchabfragen |
| Live-Logs | `--follow` | Streaming / zentrale Suche |
| Zugriffsschutz | lokal | Rollen, Rechte, Audit |
| Speicherung | Docker Standard-Logs | definierte Retention |
| Analyse | manuell | Suchabfragen, Dashboards, Alerts |
| Datenschutz | manuell prüfen | Richtlinien, Maskierung, Compliance |
| Korrelation | Serviceweise | Trace-ID, Request-ID, Correlation-ID |

---

## 11. Portfolio-Formulierung

> Das Projekt dokumentiert grundlegende Log-Diagnose mit Docker Compose. Logs werden servicebezogen gelesen, mit `--tail` und `--since` eingegrenzt und mit `--follow` live beobachtet. Anhand von Web-Healthchecks, Browserzugriffen und cAdvisor-Meldungen wird gezeigt, wie normale Betriebslogs, Umgebungshinweise und potenzielle Fehler unterschieden werden. Security-Aspekte wie Secrets und sensible Informationen in Logs werden ausdrücklich berücksichtigt.

---

## 12. Architect-Notiz

Logging beantwortet eine andere Frage als Monitoring:

```text
Monitoring fragt: Wie entwickelt sich der Zustand über Zeit?
Logging fragt: Was ist konkret passiert?
```

Für professionellen Betrieb braucht man beides:

```text
Metrics zeigen Auffälligkeiten.
Logs erklären Ereignisse.
Alerts melden Probleme.
Dashboards helfen bei Überblick und Diagnose.
```
