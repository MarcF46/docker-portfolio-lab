# Redis Secret Handling und Healthcheck ohne `redis-cli -a`

## Zweck

Diese Übung verbessert den Redis-Healthcheck und das lokale Secret-Handling im Docker-/DevOps-Lernprojekt.

Bisher wurde Redis mit einem Passwort geschützt, aber im Redis-Healthcheck wurde `redis-cli -a` verwendet. Das funktioniert technisch, erzeugt aber eine Warnung, weil das Passwort als Kommandozeilenargument übergeben wird.

Ziel dieser Übung:

- Redis-Passwort in eine lokale Secret-Datei auslagern
- Secret-Datei nicht committen
- Redis-Server liest Passwort aus `/run/secrets/redis_password`
- Redis-Healthcheck nutzt `REDISCLI_AUTH`
- Warnung durch `redis-cli -a` vermeiden
- Unterschied Lab-Secret vs. Production-Secret verstehen

---

## 1. Job-Szenario

Ein Review ergibt:

> „Der Stack funktioniert, aber der Redis-Healthcheck erzeugt eine Security-Warnung. Außerdem ist das Passwort im gerenderten Compose-Output sichtbar. Bitte verbessere das Secret-Handling im Lab, ohne direkt ein komplexes Enterprise-Secret-System einzuführen.“

---

## 2. Betriebsanforderung

| Anforderung | Bedeutung |
|---|---|
| Passwort nicht direkt im Healthcheck per `-a` übergeben | weniger unsaubere CLI-Passwortnutzung |
| Secret-Datei nicht committen | kein Passwort in GitHub |
| Redis bleibt passwortgeschützt | keine Security-Verschlechterung |
| Healthcheck bleibt funktionsfähig | Redis wird weiterhin geprüft |
| Compose-Konfiguration bleibt lesbar | gute Wartbarkeit |
| Änderung wird praktisch verifiziert | nicht nur „Datei geändert“, sondern getestet |

---

## 3. Lernziel

Nach dieser Übung sollst du erklären können:

```text
Secrets gehören nicht in Git.
Ein Healthcheck darf funktionieren, sollte aber keine unnötigen Security-Warnungen erzeugen.
Eine lokale Secret-Datei ist besser als ein Passwort direkt in der Compose-Datei, aber noch kein vollständiges Enterprise-Secret-Management.
```

---

## 4. Umsetzung im Lab

Neue/angepasste Bestandteile:

```text
compose.prod.yml
.gitignore
.dockerignore
secrets/redis_password.txt   # lokal, nicht committen
```

Die Datei `secrets/redis_password.txt` bleibt lokal und wird durch `.gitignore` geschützt.

---

## 5. Befehle

```powershell
# Wechselt in den Projektordner.
cd "C:\Docker Übung"

# Erstellt den lokalen Secrets-Ordner.
New-Item -ItemType Directory -Force -Path .\secrets

# Erstellt die lokale Redis-Passwortdatei, falls sie noch nicht existiert.
# SECURITY: Dieses Passwort ist nur ein Lab-Wert.
if (-not (Test-Path .\secrets\redis_password.txt)) {
    Set-Content -Path .\secrets\redis_password.txt -Value "local_redis_password_please_change" -NoNewline
}

# Prüft, ob Git die Secret-Datei ignoriert.
git check-ignore -v secrets/redis_password.txt
```

Erwartung:

```text
.gitignore:...:secrets/*   secrets/redis_password.txt
```

---

## 6. Verifikation

```powershell
# Prüft, ob Docker Compose die neue Konfiguration lesen kann.
docker compose -f compose.prod.yml config

# Erzeugt die Container neu, damit Secret und Healthcheck sicher übernommen werden.
docker compose -f compose.prod.yml up -d --force-recreate

# Prüft, ob beide Container healthy sind.
docker compose -f compose.prod.yml ps

# Prüft den Redis-Healthcheck im Detail.
docker inspect dockerbung-redis-1 --format '{{json .State.Health}}'
```

Erwartung:

- Redis ist `healthy`
- Web ist `healthy`
- Healthcheck-Output enthält `PONG`
- Die alte Warnung zu `redis-cli -a` soll nicht mehr erscheinen

---

## 7. Realistischer Fehlerfall

Die Secret-Datei fehlt.

Dann kann Redis nicht korrekt starten, weil `/run/secrets/redis_password` nicht bereitgestellt werden kann.

### Diagnose

```powershell
docker compose -f compose.prod.yml config
docker compose -f compose.prod.yml ps
docker compose -f compose.prod.yml logs --tail=80 redis
Test-Path .\secrets\redis_password.txt
```

### Fix

```powershell
New-Item -ItemType Directory -Force -Path .\secrets
Set-Content -Path .\secrets\redis_password.txt -Value "local_redis_password_please_change" -NoNewline
docker compose -f compose.prod.yml up -d --force-recreate
```

---

## 8. Unterschied Lernlabor vs. Produktion

| Thema | Lernlabor | Produktion |
|---|---|---|
| Secret-Quelle | lokale Datei `secrets/redis_password.txt` | Secret Manager, Vault, Kubernetes Secret, Docker Swarm Secret |
| Schutz | `.gitignore`, lokale Vorsicht | Zugriffskontrolle, Rotation, Audit, Least Privilege |
| Passwortrotation | manuell | kontrollierter Rotationsprozess |
| Compose-Datei | liest Secret aus Datei | meist Orchestrator-/Cloud-nativ |
| Risiko | lokale Datei kann trotzdem geleakt werden | zentrales Secret-Management reduziert Risiko |

---

## 9. Security-Hinweis

Auch lokale Secret-Dateien sind echte Geheimnisse.

Deshalb:

```text
Nicht committen.
Nicht screenshotten.
Nicht in Chat/Tickets kopieren.
Nicht in Terminal-Logs veröffentlichen.
Bei Leak: Secret rotieren.
```

Wichtig:

```text
Ein Secret aus Git zu löschen reicht nicht, wenn es bereits veröffentlicht wurde.
Dann muss das Secret ersetzt/rotiert werden.
```

---

## 10. Portfolio-Formulierung

> Der Redis-Healthcheck wurde so angepasst, dass `REDISCLI_AUTH` statt `redis-cli -a` verwendet wird. Zusätzlich wurde das Redis-Passwort in eine lokale Docker-Compose-Secret-Datei ausgelagert, die durch `.gitignore` geschützt ist. Damit wurde die Warnung im Healthcheck entfernt und das Lab näher an sauberes Secret-Handling herangeführt, ohne ein vollständiges Enterprise-Secret-System vorzutäuschen.

---

## 11. Architect-Notiz

Die größere Architekturentscheidung lautet:

> Wo und wie werden Secrets verwaltet?

Es gibt mehrere Reifegrade:

```text
Passwort direkt in Datei
Passwort in .env
lokale Secret-Datei
Docker Compose Secret
Kubernetes Secret
Cloud Secret Manager / Vault
automatische Rotation und Audit
```

Diese Übung ist ein Schritt von „einfaches Lab“ zu „bewussteres Secret-Handling“. Sie ist noch nicht Production-grade, aber deutlich sauberer als ein Passwort direkt im Healthcheck.
