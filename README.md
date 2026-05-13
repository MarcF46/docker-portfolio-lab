# Docker Übung – Erstes Docker-Lernprojekt

## Ziel dieses Projekts

Dieses Projekt ist ein praktisches Docker-Lernprojekt.

Es dient dazu, die Grundlagen von Docker, Dockerfiles, Docker Compose, Images, Containern, Git und einfacher Webserver-Bereitstellung zu verstehen.

Das Projekt unterscheidet bewusst zwischen:

- Development-Modus
- Production-Modus

Dadurch wird sichtbar, warum Änderungen in der Entwicklung sofort erscheinen können, während produktionsnahe Container erst neu gebaut werden müssen.

---

## Was ist Docker?

Docker ist eine Plattform, mit der Anwendungen in sogenannten Containern ausgeführt werden können.

Ein Container ist eine isolierte Laufzeitumgebung.  
Das bedeutet: Eine Anwendung läuft zusammen mit allem, was sie benötigt, in einem abgegrenzten Bereich.

---

## Wichtige Begriffe

### Image

Ein Image ist eine fertige Vorlage für einen Container.  
Man kann es sich wie ein eingefrorenes Software-Paket vorstellen.

### Container

Ein Container ist eine laufende Instanz eines Images.  
Wenn ein Image der Bauplan ist, dann ist der Container das tatsächlich gestartete Objekt.

### Dockerfile

Ein Dockerfile ist eine Textdatei mit Bauanweisungen für ein Docker-Image.

### Docker Compose

Docker Compose ist ein Werkzeug, mit dem mehrere Container gemeinsam über eine YAML-Datei gestartet und verwaltet werden können.

### YAML

YAML ist ein Dateiformat, das häufig für Konfigurationsdateien genutzt wird.  
Bei Docker Compose beschreibt eine YAML-Datei, welche Container gestartet werden sollen.

---

## Projektstruktur

```text
Docker Übung/
├── app/
│   └── index.html
├── Dockerfile
├── compose.dev.yml
├── compose.prod.yml
├── .dockerignore
├── .env.example
├── .gitignore
└── README.md
```

---

## Enthaltene Hauptdateien

| Datei | Zweck |
|---|---|
| `app/index.html` | Beispiel-Webseite |
| `Dockerfile` | Bauanleitung für das produktionsnahe Docker-Image |
| `compose.dev.yml` | Docker-Compose-Datei für den Development-Modus |
| `compose.prod.yml` | Docker-Compose-Datei für den Production-Modus |
| `.dockerignore` | verhindert unnötige Dateien im Docker-Build-Kontext |
| `.gitignore` | verhindert, dass lokale/geheime Dateien zu Git hinzugefügt werden |
| `.env.example` | Beispiel für benötigte Umgebungsvariablen |
| `README.md` | Dokumentation des Projekts |

---

## Development- und Production-Modus

Dieses Projekt enthält zwei unterschiedliche Docker-Compose-Dateien:

```text
compose.dev.yml
compose.prod.yml
```

---

## Development-Modus

Datei:

```text
compose.dev.yml
```

Start:

```powershell
docker compose -f compose.dev.yml up -d
```

Aufruf im Browser:

```text
http://localhost:8081
```

Im Development-Modus wird der Ordner `app/` per Bind Mount in den Container eingebunden.

Das bedeutet: Änderungen an `app/index.html` werden nach dem Speichern direkt im Browser sichtbar.

Die Einbindung erfolgt read-only:

```yaml
- ./app:/usr/share/nginx/html:ro
```

`ro` bedeutet `read-only`, also nur lesbar.  
Der Container darf die Datei lesen, aber nicht verändern oder löschen.

---

## Development-Modus stoppen

```powershell
docker compose -f compose.dev.yml down
```

---

## Production-Modus

Datei:

```text
compose.prod.yml
```

Start:

```powershell
docker compose -f compose.prod.yml up -d --build --force-recreate
```

Aufruf im Browser:

```text
http://localhost:8082
```

Im Production-Modus wird die Datei `app/index.html` nicht live eingebunden.  
Stattdessen wird sie beim Build fest in das Docker-Image kopiert.

Das passiert im Dockerfile über:

```dockerfile
COPY app/index.html ./index.html
```

Wenn `app/index.html` später geändert wird, erscheint diese Änderung im Production-Modus nicht automatisch.  
Dafür muss das Image neu gebaut werden.

---

## Production neu bauen

```powershell
docker compose -f compose.prod.yml up -d --build --force-recreate
```

---

## Production-Modus stoppen

```powershell
docker compose -f compose.prod.yml down --remove-orphans
```

---

## Containerinhalt prüfen

Mit folgendem Befehl kann geprüft werden, welche HTML-Datei wirklich im laufenden Container liegt:

```powershell
docker exec dockerbung-web-1 cat /usr/share/nginx/html/index.html
```

Das ist besonders hilfreich, wenn man prüfen möchte, ob wirklich der neue Stand im Container angekommen ist.

---

## Alte Container aufräumen

Falls Docker Compose meldet, dass es sogenannte Orphan Container gibt, können diese entfernt werden mit:

```powershell
docker compose -f compose.prod.yml down --remove-orphans
```

Ein Orphan Container ist ein alter Container, der noch zu einem früheren Compose-Setup gehört, aber in der aktuellen Compose-Datei nicht mehr definiert ist.

---

## Git und GitHub

Dieses Projekt wird mit Git versioniert und auf GitHub gespeichert.

Wichtige Git-Befehle:

```powershell
git status
git add .
git commit -m "Beschreibung der Änderung"
```

Nach einem Commit kann die Änderung über GitHub Desktop mit **Push origin** zu GitHub hochgeladen werden.

---

## Lernziel

Das Ziel dieses Projekts ist nicht nur, Docker-Befehle auswendig zu lernen, sondern zu verstehen:

- wie Container gestartet werden
- wie Images gebaut werden
- wie Docker Compose mehrere Dienste verwaltet
- wie Development- und Production-Modus sich unterscheiden
- wie Dateien sauber strukturiert werden
- wie man ein Projekt mit Git versioniert
- wie man Änderungen nachvollziehbar auf GitHub dokumentiert
- wie daraus später ein Portfolio-Projekt entstehen kann

---

## Hinweis

Dieses Projekt ist ein Lernprojekt und noch keine produktionsreife Umgebung.

Es bildet aber bereits wichtige Grundlagen ab, die auch in echten DevOps-, Cloud- und Plattform-Teams relevant sind.