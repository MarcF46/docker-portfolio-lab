# CI/CD Build Pipeline

## Zweck

Dieses Dokument beschreibt die erweiterte Docker-Image-Pipeline im Docker Portfolio Lab.

Ziel ist, nicht nur Docker Compose lokal zu testen, sondern eine eigene GitHub-Actions-Pipeline zu nutzen, die ein Docker-Image baut, startet und fachlich prüft.

---

## Betriebsfrage

Ein realistischer Auftrag wäre:

```text
Das Dockerfile wurde angepasst.
Bitte stelle sicher, dass das Web-Image in CI gebaut werden kann,
der Container startet und die Webseite erreichbar ist.
```

---

## CI/CD kurz erklärt

CI/CD steht für:

| Begriff | Bedeutung |
|---|---|
| CI | Continuous Integration, also automatisches Prüfen von Änderungen |
| CD | Continuous Delivery oder Deployment, also automatisiertes Bereitstellen |

In diesem Projekt wird aktuell vor allem CI umgesetzt:

```text
bauen
testen
prüfen
Logs bei Fehlern anzeigen
```

Ein echter automatischer Push in eine externe Registry oder ein Deployment ist bewusst noch nicht aktiv.

---

## Workflow-Datei

Die Pipeline liegt in:

```text
.github/workflows/docker-image-pipeline.yml
```

Name des Workflows:

```text
Docker Image Pipeline
```

Auslöser:

```yaml
on:
  push:
    branches:
      - main
  pull_request:
```

Bedeutung:

```text
Die Pipeline läuft bei Push auf main und bei Pull Requests.
```

---

## Pipeline-Ziel

Die Pipeline führt diese Schritte aus:

```text
Repository auschecken
Docker-Versionen anzeigen
Docker Buildx vorbereiten
Image bauen und lokal laden
Image anzeigen
Testcontainer starten
Webserver per HTTP testen
wget im Container prüfen
Containerstatus prüfen
optional Docker Scout ausführen
Logs bei Fehlern anzeigen
Testcontainer entfernen
```

---

## Warum eine zweite Pipeline?

Im Projekt gibt es bereits:

```text
.github/workflows/docker-lab-ci.yml
```

Diese vorhandene Pipeline prüft den Compose-Stack mit Web und Redis.

Die neue Datei:

```text
.github/workflows/docker-image-pipeline.yml
```

prüft dagegen gezielt den Image-Lebenszyklus:

```text
Dockerfile -> Image -> Container -> HTTP-Test
```

Damit sind die Verantwortlichkeiten getrennt:

| Workflow | Fokus |
|---|---|
| `Docker Lab CI` | Compose-Konfiguration, Stack, Redis, Web |
| `Docker Image Pipeline` | einzelnes Web-Image bauen, starten und testen |

---

## Buildx

Die Pipeline nutzt:

```yaml
- name: Docker Buildx vorbereiten
  uses: docker/setup-buildx-action@v4
```

Buildx ist der moderne Docker-Builder.

Vorteile:

```text
bessere Build-Funktionen
CI/CD-tauglich
später Multi-Arch-Builds möglich
Integration mit Docker Build GitHub Actions
```

---

## Image bauen

Die Pipeline nutzt:

```yaml
- name: Image bauen und lokal laden
  uses: docker/build-push-action@v7
  with:
    context: .
    file: ./Dockerfile
    load: true
    pull: true
    tags: ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
```

### Bedeutung

| Option | Bedeutung |
|---|---|
| `context: .` | aktueller Repository-Inhalt ist Build-Kontext |
| `file: ./Dockerfile` | dieses Dockerfile wird genutzt |
| `load: true` | Image wird in den lokalen Docker-Daemon des Runners geladen |
| `pull: true` | aktuelle Basis-Images werden aktiv gezogen |
| `tags` | Image bekommt den CI-Tag `handsonlabs/my-web:ci` |

Wichtig:

```text
load: true ist nötig, damit der Runner das gebaute Image danach direkt mit docker run starten kann.
```

---

## Testcontainer starten

```yaml
docker run --rm -d --name web-ci-test -p 8088:80 ${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
```

### Bedeutung

| Teil | Bedeutung |
|---|---|
| `docker run` | startet einen Container |
| `--rm` | Container wird nach Stop automatisch entfernt |
| `-d` | läuft im Hintergrund |
| `--name web-ci-test` | fester Name für Prüfung und Logs |
| `-p 8088:80` | GitHub-Runner-Port 8088 auf Container-Port 80 |
| Image | das gerade gebaute CI-Image |

---

## Webserver testen

```yaml
curl --fail --show-error --silent --head http://localhost:8088
```

### Bedeutung

| Option | Bedeutung |
|---|---|
| `curl` | HTTP-Anfrage ausführen |
| `--fail` | bei HTTP-Fehlercodes mit Fehler abbrechen |
| `--show-error` | Fehler trotz Silent-Modus anzeigen |
| `--silent` | normale Fortschrittsausgabe unterdrücken |
| `--head` | nur Header abrufen |

Erwartung:

```text
HTTP/1.1 200 OK
```

Wenn dieser Schritt fehlschlägt, schlägt die Pipeline fehl.

---

## Healthcheck-Werkzeug prüfen

```yaml
docker exec web-ci-test sh -c 'which wget'
```

Warum?

Das Dockerfile nutzt im Healthcheck:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget --quiet --tries=1 --spider http://127.0.0.1 || exit 1
```

Darum prüft die Pipeline, ob `wget` im Image vorhanden ist.

Das war besonders wichtig nach dem Wechsel auf:

```dockerfile
FROM nginx:alpine-slim
```

Slim-Images enthalten weniger Pakete. Deshalb muss geprüft werden, ob benötigte Werkzeuge weiterhin vorhanden sind.

---

## Optionaler Docker Scout Schritt

Die Pipeline enthält einen optionalen Scout-Block.

Er läuft nur, wenn diese GitHub Secrets gesetzt sind:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

Wenn diese Secrets fehlen, wird Docker Scout übersprungen.

Warum?

```text
Die Pipeline soll ohne Docker-Hub-Zugangsdaten nicht rot werden.
Der lokale Docker-Scout-Scan wurde bereits separat dokumentiert.
Später kann der CI-Scan sauber aktiviert werden.
```

---

## Fehlerdiagnose

Bei Fehlern zeigt die Pipeline:

```yaml
docker ps -a
docker logs web-ci-test || true
```

Das hilft bei typischen CI-Problemen:

```text
Image wurde nicht gebaut
Container startet nicht
Port ist nicht erreichbar
NGINX liefert Fehler
Healthcheck-Werkzeug fehlt
```

---

## Cleanup

Am Ende wird der Testcontainer entfernt:

```yaml
docker stop web-ci-test || true
```

Bedeutung:

```text
Auch wenn vorher ein Schritt fehlschlägt,
versucht die Pipeline aufzuräumen.
```

---

## Ergebnis

Nach dem Commit wurde der neue Workflow in GitHub Actions sichtbar:

```text
Docker Image Pipeline
```

Zusätzlich liefen weiterhin:

```text
Docker Lab CI
pages-build-deployment
```

Das ist erwartetes Verhalten, weil ein Push auf `main` mehrere Workflows auslösen kann.

---

## Lab vs. Produktion

| Thema | Lab | Produktion |
|---|---|---|
| Build | Image in GitHub Actions bauen | versionierter Build mit Release-Strategie |
| Test | HTTP-Test und Tool-Prüfung | Unit-, Integration-, Security- und Smoke-Tests |
| Scan | optionaler Scout-Schritt | verpflichtender Scan mit Policy |
| Push | noch nicht aktiv | Push zu GHCR, Docker Hub, ECR, ACR oder Harbor |
| Secrets | Scout optional | Registry-/Cloud-Secrets mit minimalen Rechten |
| Deployment | noch nicht aktiv | automatisiertes oder freigegebenes Deployment |

---

## Typische nächste Ausbaustufen

Sinnvolle spätere Schritte:

```text
GitHub Container Registry vorbereiten
Docker Scout in CI aktivieren
Registry-Push nach erfolgreichem Test
Image-Tags aus Git-Commit oder Release erzeugen
Digest dokumentieren
Rollback-Szenario üben
Deployment in Testumgebung vorbereiten
```

---

## Fazit

Die CI/CD Build Pipeline zeigt:

```text
Das Dockerfile wird automatisch in GitHub Actions gebaut.
Das erzeugte Image wird im Runner gestartet.
Die Webseite wird per HTTP geprüft.
Benötigte Werkzeuge wie wget werden kontrolliert.
Fehlerdiagnose und Cleanup sind vorbereitet.
```

Damit ist ein wichtiger Schritt Richtung professioneller Build-Pipeline umgesetzt.
