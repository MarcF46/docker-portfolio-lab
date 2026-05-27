# Secrets Deep Dive

## Zweck

Dieses Dokument fasst den erweiterten Secret-Check des Docker Portfolio Lab zusammen.

Ziel ist, nicht nur einzelne Passwortdateien zu schützen, sondern verschiedene Secret-Arten sauber zu unterscheiden:

```text
Runtime Secrets
Build Secrets
SSH-Mounts
GitHub Actions Secrets
.env-Dateien
TLS-Zertifikate und private Schlüssel
```

---

## Ergebnis des Secret-Audits

Im Projekt existieren lokale sensible Dateien:

```text
secrets/redis_password.txt
secrets/grafana_admin_password.txt
certs/localhost.crt
certs/localhost.key
```

Git verfolgt davon nur:

```text
secrets/.gitkeep
```

Die echten Secret- und Zertifikatsdateien werden durch `.gitignore` geschützt.

---

## Geprüfte lokale Dateien

```powershell
Get-ChildItem .\secrets
Get-ChildItem .\certs
git ls-files .\secrets .\certs
git check-ignore -v .\secrets\redis_password.txt .\secrets\grafana_admin_password.txt .\certs\localhost.key .\certs\localhost.crt
```

### Bedeutung der Befehle

| Befehl | Bedeutung |
|---|---|
| `Get-ChildItem .\secrets` | zeigt lokale Secret-Dateien |
| `Get-ChildItem .\certs` | zeigt lokale Zertifikatsdateien |
| `git ls-files .\secrets .\certs` | zeigt, welche Dateien Git tatsächlich verfolgt |
| `git check-ignore -v ...` | zeigt, welche `.gitignore`-Regel eine Datei schützt |

Erwartung:

```text
Git verfolgt nur secrets/.gitkeep.
Redis-, Grafana- und Zertifikatsdateien werden ignoriert.
```

---

## Runtime Secrets

Runtime Secrets werden im laufenden Container benötigt.

Beispiele in diesem Projekt:

```text
/run/secrets/redis_password
/run/secrets/grafana_admin_password
```

Diese Dateien werden von Docker Compose in den jeweiligen Container eingebunden.

### Prüfung ohne Secret-Ausgabe

```powershell
docker exec dockerbung-redis-1 sh -c 'test -f /run/secrets/redis_password && echo "redis secret file exists"'
docker exec dockerbung-grafana-1 sh -c 'test -f /run/secrets/grafana_admin_password && echo "grafana secret file exists"'
```

Wichtig:

```text
Es wird nur geprüft, ob die Datei existiert.
Der Secret-Inhalt wird nicht ausgegeben.
```

---

## TLS-Zertifikate und private Schlüssel

Für lokales HTTPS nutzt der NGINX Reverse Proxy:

```text
certs/localhost.crt
certs/localhost.key
```

| Datei | Bedeutung | Sicherheitsbewertung |
|---|---|---|
| `localhost.crt` | öffentliches Zertifikat | weniger kritisch, aber trotzdem nicht nötig im Repo |
| `localhost.key` | privater Schlüssel | sehr kritisch, niemals committen |

Prüfung im NGINX-Container:

```powershell
docker exec dockerbung-reverse-proxy sh -c 'test -f /etc/nginx/certs/localhost.key && echo "nginx key file exists"'
```

Auch hier gilt:

```text
Existenz prüfen, aber privaten Schlüssel niemals ausgeben.
```

---

## Compose-Konfiguration prüfen

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml config | Select-String -Pattern "secrets:", "redis_password", "grafana_admin_password", "certs"
```

### Bedeutung

| Teil | Bedeutung |
|---|---|
| `docker compose ... config` | zeigt die zusammengeführte Compose-Konfiguration |
| `Select-String` | filtert relevante Secret- und Zertifikatszeilen |
| `redis_password` | Redis-Secret |
| `grafana_admin_password` | Grafana-Secret |
| `certs` | Zertifikats-Mount für NGINX |

Wichtig:

```text
docker compose config kann lokale Pfade anzeigen.
Ausgaben nicht ungeprüft veröffentlichen.
```

---

## Build Secrets

Build Secrets werden nur während des Image-Builds benötigt.

Typische Beispiele:

```text
Token für private Paketquellen
Lizenzdateien
API-Token für Downloads
Zugriff auf private Artefakte
```

Schlechtes Muster:

```dockerfile
ARG TOKEN
ENV TOKEN=$TOKEN
```

Warum schlecht?

```text
ARG und ENV können in Image-Konfiguration, Build-History oder Logs sichtbar bleiben.
```

Besser:

```powershell
docker build --secret id=npm_token,src=.\secrets\npm_token.txt -t meine-app .
```

Im Dockerfile:

```dockerfile
# syntax=docker/dockerfile:1

RUN --mount=type=secret,id=npm_token \
    NPM_TOKEN="$(cat /run/secrets/npm_token)" && \
    npm install
```

Wichtig:

```text
Build Secrets nur lesen.
Nicht in Dateien kopieren.
Nicht ausgeben.
Nicht in Layer schreiben.
```

---

## SSH-Mounts

SSH-Mounts werden genutzt, wenn ein Build kurz SSH-Zugriff braucht.

Typische Situation:

```text
Während docker build soll ein privates Git-Repository geklont werden.
```

Schlechtes Muster:

```dockerfile
COPY id_rsa /root/.ssh/id_rsa
```

Warum schlecht?

```text
Der private SSH-Key landet im Image.
```

Besser:

```powershell
docker buildx build --ssh default -t meine-app .
```

Im Dockerfile:

```dockerfile
# syntax=docker/dockerfile:1

RUN --mount=type=ssh \
    git clone git@github.com:organisation/private-repo.git /src
```

Vorteil:

```text
Der Build darf kurz den SSH-Agent verwenden.
Der private Schlüssel wird nicht ins Image kopiert.
```

---

## GitHub Actions Secrets

GitHub Actions Secrets werden in GitHub gespeichert und in CI/CD-Workflows bereitgestellt.

Typische Beispiele:

```text
Registry-Token
Cloud-Zugangsdaten
Deployment-Key
API-Token
```

Wichtige Regeln:

```text
Secrets nicht im Workflow ausgeben.
Keine echo-Ausgabe von Secret-Werten.
Secrets nur für notwendige Jobs verwenden.
Berechtigungen minimal halten.
Tokens regelmäßig rotieren.
```

---

## .env-Dateien

`.env`-Dateien sind praktisch für lokale Konfiguration, aber nicht automatisch sicher.

Risiken:

```text
können versehentlich committed werden
können durch docker compose config sichtbar werden
können in Logs oder Screenshots auftauchen
```

Im Projekt gilt:

```text
.env und .env.* werden ignoriert.
.env.example darf Beispielwerte enthalten, aber keine echten Secrets.
```

---

## Vergleich der Secret-Arten

| Secret-Art | Einsatzzeitpunkt | Beispiel | Darf ins Image? |
|---|---|---|---|
| Runtime Secret | laufender Container | Redis-Passwort | nein |
| Build Secret | Image-Build | Paketregistry-Token | nein |
| SSH-Mount | Image-Build | GitHub-SSH-Zugriff | nein |
| GitHub Actions Secret | CI/CD-Lauf | Registry-Token | nein |
| `.env` | lokale Konfiguration | Port, Modus, Beispielwerte | keine echten Secrets |
| TLS-Key | Reverse Proxy | `localhost.key` | nein |

---

## Typische Fehler

```text
Secret über ARG oder ENV ins Image bauen
private SSH-Keys ins Image kopieren
Secret-Werte in Logs ausgeben
docker compose config ungeprüft veröffentlichen
Screenshots mit sichtbaren Tokens oder Pfaden teilen
Zertifikats-Keys committen
```

---

## Merksätze

```text
Runtime Secret:
wird im laufenden Container gebraucht.

Build Secret:
wird nur beim Image-Build gebraucht.

SSH-Mount:
erlaubt temporären SSH-Zugriff während des Builds, ohne private Keys ins Image zu kopieren.

Private Keys:
niemals committen, niemals ungeprüft teilen.
```

---

## Bewertung für dieses Projekt

Der aktuelle Stand ist für ein Junior-Portfolio sauber:

```text
lokale Secret-Dateien vorhanden
echte Secrets werden nicht von Git verfolgt
Zertifikatsdateien werden ignoriert
Container sehen nur die benötigten Dateien
Secret-Inhalte werden in Prüfungen nicht ausgegeben
```

Für Produktion wären weitere Schritte nötig:

```text
zentraler Secret Manager
automatisierte Zertifikatsverwaltung
Secret-Rotation
rollenbasierte Zugriffe
Audit-Logs
CI/CD-Secrets mit minimalen Rechten
```
