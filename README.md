# Docker Übung – Erstes Docker-Lernprojekt

## Ziel dieses Projekts

Dieses Projekt ist ein praktisches Docker-Lernprojekt.

Es dient dazu, die Grundlagen von Docker, Dockerfiles, Docker Compose, Images, Containern, Volumes, Backup/Restore, Git und einfacher Webserver-Bereitstellung zu verstehen.

Das Projekt unterscheidet bewusst zwischen:

- Development-Modus
- Production-Modus
- lokaler Konfiguration mit `.env`
- persistenter Datenspeicherung mit Docker Volumes
- Backup und Restore von Volume-Daten

Dadurch wird sichtbar, warum Änderungen in der Entwicklung sofort erscheinen können, während produktionsnahe Container erst neu gebaut werden müssen und wichtige Daten nicht im Container selbst gespeichert werden sollten.

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

### Git

Git ist ein Versionskontrollsystem.  
Es speichert Änderungen an Dateien nachvollziehbar ab, sodass man später sehen kann, was geändert wurde.

### GitHub

GitHub ist eine Online-Plattform für Git-Projekte.  
Dort können Projekte gespeichert, dokumentiert und später als Portfolio gezeigt werden.

### Umgebungsvariable

Eine Umgebungsvariable ist ein Wert, der nicht fest in den Programmcode geschrieben wird, sondern von außen an eine Anwendung oder einen Container übergeben wird.

Das ist besonders nützlich für:

- Passwörter
- Ports
- Zugangsdaten
- Umgebungsnamen
- technische Konfigurationen

### Bind Mount

Ein Bind Mount ist eine direkte Verbindung zwischen einem Ordner auf dem eigenen Computer und einem Ordner im Container.

Beispiel:

```yaml
- ./app:/usr/share/nginx/html:ro
```

Das bedeutet: Der lokale Ordner `app/` wird im Container unter `/usr/share/nginx/html` sichtbar.

Das `:ro` bedeutet `read-only`, also nur lesbar. Der Container darf die Dateien lesen, aber nicht verändern oder löschen.

### Volume

Ein Volume ist ein dauerhafter Speicherbereich, der von Docker verwaltet wird.

Ein Volume bleibt erhalten, auch wenn ein Container gelöscht wird.

Bildlich:

```text
Image      = Bauplan
Container  = laufende Maschine
Volume     = externe Festplatte für wichtige Daten
```

### TAR

TAR steht ursprünglich für `Tape Archive`.

Es ist ein Archivformat aus der Unix-/Linux-Welt. Man kann es sich ähnlich wie eine ZIP-Datei vorstellen.

Eine Datei mit der Endung `.tar.gz` ist:

```text
.tar  = Archiv mit mehreren Dateien
.gz   = mit gzip komprimiert
```

Die wichtigsten TAR-Befehle aus dieser Übung:

```text
tar czf = Backup erstellen
tar tzf = Backup-Inhalt anzeigen
tar xzf = Backup wiederherstellen
```

---

## Projektstruktur

```text
Docker Übung/
├── app/
│   └── index.html
├── backups/
│   └── redis_data_prod_backup.tar.gz
├── Dockerfile
├── compose.dev.yml
├── compose.prod.yml
├── .dockerignore
├── .env
├── .env.example
├── .gitignore
└── README.md
```

Wichtig: Der Ordner `backups/` ist lokal vorhanden, wird aber nicht zu GitHub hochgeladen.

---

## Enthaltene Hauptdateien

| Datei | Zweck |
|---|---|
| `app/index.html` | Beispiel-Webseite |
| `Dockerfile` | Bauanleitung für das produktionsnahe Docker-Image |
| `compose.dev.yml` | Docker-Compose-Datei für den Development-Modus |
| `compose.prod.yml` | Docker-Compose-Datei für den Production-Modus |
| `.dockerignore` | verhindert unnötige Dateien im Docker-Build-Kontext |
| `.env` | lokale Datei für echte Konfigurationswerte, wird nicht zu GitHub hochgeladen |
| `.env.example` | Beispiel für benötigte Umgebungsvariablen, darf auf GitHub liegen |
| `.gitignore` | verhindert, dass lokale/geheime Dateien zu Git hinzugefügt werden |
| `backups/` | lokaler Ordner für Sicherungen, wird nicht zu GitHub hochgeladen |
| `README.md` | Dokumentation des Projekts |

---

## Umgebungsvariablen mit `.env`

Dieses Projekt nutzt eine `.env`-Datei für lokale Konfigurationswerte.

Eine Umgebungsvariable ist ein Wert, der nicht fest in den Programmcode geschrieben wird, sondern von außen an die Anwendung oder den Container übergeben wird.

Das ist besonders nützlich für Passwörter, Ports, Zugangsdaten oder andere Einstellungen.

Beispiel:

```env
REDIS_PASSWORD=local_redis_password_please_change
```

Die echte `.env`-Datei wird nicht zu GitHub hochgeladen, weil sie in `.gitignore` eingetragen ist.

Damit andere Nutzer wissen, welche Werte benötigt werden, gibt es zusätzlich eine `.env.example`.

```text
.env           = echte lokale Werte, nicht für GitHub
.env.example   = Beispielwerte, darf auf GitHub liegen
```

Wichtig: In echte `.env`-Dateien gehören keine Werte, die später öffentlich sichtbar sein sollen.

Die Datei `.env.example` dient nur als Vorlage. Andere Personen können sie kopieren, in `.env` umbenennen und eigene Werte eintragen.

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

Ein Bind Mount ist eine direkte Verbindung zwischen einem Ordner auf dem eigenen Computer und einem Ordner im Container.

Das bedeutet: Änderungen an `app/index.html` werden nach dem Speichern direkt im Browser sichtbar.

Die Einbindung erfolgt read-only:

```yaml
- ./app:/usr/share/nginx/html:ro
```

`ro` bedeutet `read-only`, also nur lesbar.  
Der Container darf die Datei lesen, aber nicht verändern oder löschen.

Das ist wichtig, weil bei einer normalen Schreibfreigabe Dateien im Container auch Dateien auf dem eigenen Computer verändern oder löschen könnten.

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

Bedeutung:

| Teil | Erklärung |
|---|---|
| `docker compose` | startet Docker Compose |
| `-f compose.prod.yml` | nutzt die Production-Compose-Datei |
| `up -d` | startet die Container im Hintergrund |
| `--build` | baut das Image neu |
| `--force-recreate` | erstellt die Container sicher neu |

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

## Docker Volumes und Persistenz

Redis speichert Daten im Ordner `/data`.

Damit diese Daten nicht verloren gehen, wenn der Container gelöscht wird, nutzt dieses Projekt ein Docker Volume.

In `compose.prod.yml` wird dafür ein Named Volume verwendet:

```yaml
volumes:
  - redis_data_prod:/data
```

Unten in der Compose-Datei wird das Volume definiert:

```yaml
volumes:
  redis_data_prod:
```

Docker Compose erstellt daraus auf diesem System ein Volume mit dem Namen:

```text
dockerbung_redis_data_prod
```

Der Name setzt sich aus dem Compose-Projektnamen und dem Volume-Namen zusammen.

---

## Volumes anzeigen

Mit folgendem Befehl werden alle Docker Volumes angezeigt:

```powershell
docker volume ls
```

Beispielausgabe:

```text
dockerbung_redis_data
dockerbung_redis_data_dev
dockerbung_redis_data_prod
dockerbung_redis_data_restore_test
```

---

## Volume genauer prüfen

Mit folgendem Befehl kann ein Volume genauer angesehen werden:

```powershell
docker volume inspect dockerbung_redis_data_prod
```

Darin sieht man unter anderem:

```text
Name
Mountpoint
Labels
Scope
```

Der Mountpoint zeigt, wo Docker die Daten intern speichert.

Wichtig: Diese Daten sollte man normalerweise nicht direkt im Dateisystem bearbeiten. Besser ist es, über Container und Docker-Befehle mit den Daten zu arbeiten.

---

## Redis-Testwert schreiben

Für diese Übung wurde ein Testwert in Redis geschrieben.

```powershell
docker exec -it dockerbung-redis-1 redis-cli -a local_redis_password_please_change SET training_status "volume-test-erfolgreich"
```

Bedeutung:

| Teil | Erklärung |
|---|---|
| `docker exec` | führt einen Befehl in einem laufenden Container aus |
| `-it` | interaktiver Terminalmodus |
| `dockerbung-redis-1` | Name des Redis-Containers |
| `redis-cli` | Kommandozeilenwerkzeug für Redis |
| `-a ...` | Passwort für Redis |
| `SET` | speichert einen Wert |
| `training_status` | Schlüsselname |
| `"volume-test-erfolgreich"` | gespeicherter Wert |

---

## Redis-Testwert lesen

```powershell
docker exec -it dockerbung-redis-1 redis-cli -a local_redis_password_please_change GET training_status
```

Erwartete Ausgabe:

```text
"volume-test-erfolgreich"
```

Wenn diese Ausgabe erscheint, wurde der Wert erfolgreich in Redis gespeichert.

---

## Warnung bei Passwort in der Kommandozeile

Redis zeigt bei der Nutzung von `-a` eine Warnung:

```text
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
```

Das bedeutet:

> Das Passwort ist direkt in der Kommandozeile sichtbar und könnte in bestimmten Fällen in der Shell-Historie oder Prozessliste auftauchen.

Für dieses lokale Lernprojekt ist das akzeptabel. In produktiven Umgebungen sollte man Passwörter nicht offen in Befehlen verwenden.

---

## Persistenz testen

Ziel:

> Prüfen, ob Redis-Daten erhalten bleiben, obwohl Container gelöscht und neu gestartet werden.

Schritte:

```powershell
docker compose -f compose.prod.yml down
docker compose -f compose.prod.yml up -d
docker exec -it dockerbung-redis-1 redis-cli -a local_redis_password_please_change GET training_status
```

Wichtig:

```powershell
docker compose -f compose.prod.yml down
```

löscht Container und Netzwerk, aber nicht das Volume.

Nicht verwenden, wenn Daten erhalten bleiben sollen:

```powershell
docker compose -f compose.prod.yml down -v
```

Das `-v` würde die Volumes entfernen.

Wenn nach dem Neustart wieder erscheint:

```text
"volume-test-erfolgreich"
```

dann ist bewiesen:

> Die Daten liegen nicht nur im Container, sondern dauerhaft im Docker Volume.

---

## Backup-Ordner

Für lokale Backups wurde ein Ordner erstellt:

```powershell
New-Item -ItemType Directory -Path backups
```

Dieser Ordner wird durch `.gitignore` von GitHub ausgeschlossen.

In `.gitignore` steht dafür:

```gitignore
backups/
```

Dadurch werden Backup-Dateien nicht versehentlich in das GitHub-Repository hochgeladen.

---

## Backup erstellen

Das Redis-Production-Volume wurde mit einem temporären Alpine-Container gesichert.

Alpine ist eine sehr kleine Linux-Distribution, die sich gut für Hilfsaufgaben eignet.

Backup-Befehl:

```powershell
docker run --rm `
  -v dockerbung_redis_data_prod:/data `
  -v "${PWD}/backups:/backup" `
  alpine `
  tar czf /backup/redis_data_prod_backup.tar.gz -C /data .
```

Bedeutung:

| Teil | Erklärung |
|---|---|
| `docker run` | startet einen einmaligen Hilfscontainer |
| `--rm` | löscht diesen Hilfscontainer nach Abschluss automatisch |
| `-v dockerbung_redis_data_prod:/data` | hängt das Redis-Volume in den Hilfscontainer ein |
| `-v "${PWD}/backups:/backup"` | hängt den lokalen Backup-Ordner ein |
| `alpine` | kleines Linux-Image als Werkzeugcontainer |
| `tar czf` | erstellt ein komprimiertes TAR-Archiv |
| `/backup/redis_data_prod_backup.tar.gz` | Ziel-Datei im Backup-Ordner |
| `-C /data .` | wechselt nach `/data` und sichert den Inhalt |

---

## Backup-Datei prüfen

```powershell
dir backups
```

Beispiel:

```text
redis_data_prod_backup.tar.gz
```

Wenn die Datei vorhanden ist, wurde ein Backup erstellt.

---

## Backup-Inhalt anzeigen

```powershell
docker run --rm `
  -v "${PWD}/backups:/backup" `
  alpine `
  tar tzf /backup/redis_data_prod_backup.tar.gz
```

Erwartete Beispielausgabe:

```text
./
./dump.rdb
./appendonlydir/
./appendonlydir/appendonly.aof.1.incr.aof
./appendonlydir/appendonly.aof.1.base.rdb
./appendonlydir/appendonly.aof.manifest
```

Das zeigt, dass im Backup echte Redis-Dateien enthalten sind.

---

## Restore sicher testen

Ein Restore sollte zuerst nicht direkt in das produktive Volume erfolgen.

Besser ist ein Restore-Test-Volume:

```text
Produktions-Volume: dockerbung_redis_data_prod
Restore-Test-Volume: dockerbung_redis_data_restore_test
```

Dadurch kann geprüft werden, ob ein Backup funktioniert, ohne die produktiven Daten zu gefährden.

---

## Restore-Test vorbereiten

Alten Testcontainer entfernen, falls vorhanden:

```powershell
docker rm -f redis-restore-test
```

Altes Restore-Test-Volume entfernen, falls vorhanden:

```powershell
docker volume rm dockerbung_redis_data_restore_test
```

Wenn Docker meldet, dass Container oder Volume nicht existieren, ist das nicht schlimm. Dann gab es einfach noch keinen alten Restore-Test.

Neues Restore-Test-Volume erstellen:

```powershell
docker volume create dockerbung_redis_data_restore_test
```

---

## Backup in Restore-Test-Volume zurückspielen

```powershell
docker run --rm `
  -v dockerbung_redis_data_restore_test:/data `
  -v "${PWD}/backups:/backup" `
  alpine `
  sh -c "cd /data && tar xzf /backup/redis_data_prod_backup.tar.gz"
```

Bedeutung:

| Teil | Erklärung |
|---|---|
| `docker run --rm` | startet einen temporären Hilfscontainer und löscht ihn danach |
| `-v dockerbung_redis_data_restore_test:/data` | hängt das neue Restore-Test-Volume ein |
| `-v "${PWD}/backups:/backup"` | hängt den lokalen Backup-Ordner ein |
| `alpine` | kleines Linux als Werkzeugcontainer |
| `sh -c` | führt einen Shell-Befehl aus |
| `cd /data` | wechselt in das Ziel-Volume |
| `tar xzf ...` | entpackt das Backup in das Volume |

---

## Restore-Testcontainer starten

```powershell
docker run -d `
  --name redis-restore-test `
  -v dockerbung_redis_data_restore_test:/data `
  redis:alpine `
  redis-server --appendonly yes --requirepass local_redis_password_please_change
```

Dieser Container nutzt nicht das produktive Redis-Volume, sondern das wiederhergestellte Test-Volume.

---

## Restore prüfen

```powershell
docker exec -it redis-restore-test redis-cli -a local_redis_password_please_change GET training_status
```

Erwartete Ausgabe:

```text
"volume-test-erfolgreich"
```

Wenn diese Ausgabe erscheint, ist der Restore erfolgreich.

Das bedeutet:

```text
Backup-Datei ist vorhanden
Backup enthält Redis-Daten
Restore in neues Volume funktioniert
Redis kann die wiederhergestellten Daten lesen
```

---

## Restore-Testcontainer entfernen

Nach dem erfolgreichen Test kann der Testcontainer entfernt werden:

```powershell
docker rm -f redis-restore-test
```

Das Restore-Test-Volume bleibt dabei erhalten.

Das ist sinnvoll für weitere Lernübungen.

---

## Restore-Test-Volume behalten oder löschen

Das Restore-Test-Volume kann behalten werden:

```text
dockerbung_redis_data_restore_test
```

Wenn man es später löschen möchte:

```powershell
docker volume rm dockerbung_redis_data_restore_test
```

In dieser Übung bleibt es bewusst erhalten, weil es für weitere Lernschritte nützlich sein kann.

---

## Kontrolle nach Restore-Test

Container anzeigen:

```powershell
docker ps -a
```

Volumes anzeigen:

```powershell
docker volume ls
```

Erwartung:

- Der Container `redis-restore-test` soll nicht mehr laufen.
- Das Volume `dockerbung_redis_data_restore_test` darf weiterhin vorhanden sein.

---

## Job-Szenario: Backup & Restore

Ein realistischer Arbeitsauftrag könnte lauten:

> „Vor einem Redis-Update bitte die Daten sichern. Danach soll geprüft werden, ob das Backup auch wirklich wiederhergestellt werden kann, ohne das produktive Volume zu gefährden.“

Saubere Lösung:

```text
1. Produktives Volume identifizieren
2. Testdaten prüfen
3. Backup erstellen
4. Backup-Inhalt anzeigen
5. Restore in separates Test-Volume durchführen
6. Testcontainer mit Restore-Volume starten
7. Wiederhergestellte Daten prüfen
8. Testcontainer entfernen
9. Restore-Test-Volume für spätere Übungen behalten
```

---

## Wichtige Betriebsregel

Ein Backup ist erst dann wirklich wertvoll, wenn ein Restore erfolgreich getestet wurde.

Nur eine vorhandene Backup-Datei reicht nicht aus.

Man muss prüfen:

```text
Kann das Backup gelesen werden?
Sind Daten enthalten?
Kann es zurückgespielt werden?
Startet die Anwendung mit den wiederhergestellten Daten?
Sind die erwarteten Daten wirklich vorhanden?
```

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

## Typischer Arbeitsablauf

Ein einfacher Arbeitsablauf sieht so aus:

```text
Datei ändern
↓
Speichern
↓
git status prüfen
↓
Änderung mit git add vormerken
↓
Commit erstellen
↓
Push origin in GitHub Desktop ausführen
```

Beispiel:

```powershell
git status
git add README.md
git commit -m "Dokumentiere Docker Volume Backup und Restore"
git status
```

Danach in GitHub Desktop:

```text
Push origin
```

---

## Wichtige Sicherheitsregel

Echte Zugangsdaten, Passwörter, Tokens oder API-Schlüssel gehören nicht direkt in:

- `README.md`
- `Dockerfile`
- `compose.dev.yml`
- `compose.prod.yml`
- öffentlich sichtbare Dateien auf GitHub

Dafür nutzt man lokale Konfigurationsdateien wie `.env`, die nicht hochgeladen werden.

Auch lokale Backups gehören nicht automatisch auf GitHub.

Backups können echte Daten enthalten und werden deshalb durch `.gitignore` ausgeschlossen.

---

## Lernziel

Das Ziel dieses Projekts ist nicht nur, Docker-Befehle auswendig zu lernen, sondern zu verstehen:

- wie Container gestartet werden
- wie Images gebaut werden
- wie Docker Compose mehrere Dienste verwaltet
- wie Development- und Production-Modus sich unterscheiden
- wie Umgebungsvariablen genutzt werden
- wie sensible Werte aus GitHub herausgehalten werden
- wie Docker Volumes Daten dauerhaft speichern
- wie Daten nach Container-Neustarts erhalten bleiben
- wie Volume-Backups erstellt werden
- wie Backup-Inhalte geprüft werden
- wie ein Restore sicher in einem Test-Volume durchgeführt wird
- wie man Risiken für produktive Daten reduziert
- wie Dateien sauber strukturiert werden
- wie man ein Projekt mit Git versioniert
- wie man Änderungen nachvollziehbar auf GitHub dokumentiert
- wie daraus später ein Portfolio-Projekt entstehen kann

---

## Hinweis

Dieses Projekt ist ein Lernprojekt und noch keine produktionsreife Umgebung.

Es bildet aber bereits wichtige Grundlagen ab, die auch in echten DevOps-, Cloud- und Plattform-Teams relevant sind.

Besonders wichtig ist der Unterschied zwischen:

```text
Es gibt ein Backup.
```

und:

```text
Das Backup wurde erfolgreich wiederhergestellt und geprüft.
```

Erst der zweite Punkt ist im professionellen Betrieb wirklich belastbar.