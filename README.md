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
---

## Professioneller Blick auf Backup, Restore und Betrieb

In diesem Lernprojekt wurde ein Redis-Volume nicht nur gesichert, sondern auch praktisch wiederhergestellt und geprüft.

Das ist ein wichtiger Unterschied:

```text
Es gibt ein Backup.
```

ist nicht dasselbe wie:

```text
Das Backup wurde erfolgreich wiederhergestellt und geprüft.
```

Ein Backup ist erst dann wirklich belastbar, wenn ein Restore erfolgreich getestet wurde.

---

## Aktueller Stand im Lernprojekt

Dieses Projekt enthält inzwischen drei Skripte für den Backup- und Restore-Prozess:

| Skript | Zweck |
|---|---|
| `scripts/backup-redis-volume.ps1` | erstellt ein Redis-Volume-Backup und prüft das Archiv technisch |
| `scripts/test-redis-restore.ps1` | spielt ein Backup in ein Restore-Test-Volume zurück und prüft den Redis-Wert |
| `scripts/backup-and-test-redis.ps1` | führt Backup und Restore-Test als Gesamtprozess aus |

---

## Master-Skript ausführen

Der komplette Backup-und-Restore-Testprozess kann mit folgendem Befehl gestartet werden:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\backup-and-test-redis.ps1
```

Wichtig: Der Befehl wird im Projektordner ausgeführt:

```text
C:\Docker Übung
```

Nicht im Unterordner `scripts/`.

---

## Was das Master-Skript macht

Das Master-Skript führt zwei Teilschritte aus.

### Schritt 1: Backup erstellen und technisch prüfen

Dabei wird:

```text
1. geprüft, ob das Redis-Production-Volume existiert
2. eine Backup-Datei mit Zeitstempel erstellt
3. geprüft, ob die Backup-Datei existiert
4. geprüft, ob die Backup-Datei nicht leer ist
5. der Inhalt des TAR-Archivs angezeigt
```

### Schritt 2: Restore-Test durchführen

Dabei wird:

```text
1. ein separates Restore-Test-Volume vorbereitet
2. das neueste Backup in dieses Test-Volume zurückgespielt
3. ein Redis-Testcontainer mit diesem Volume gestartet
4. der Wert training_status aus Redis gelesen
5. geprüft, ob der erwartete Wert vorhanden ist
6. der Testcontainer wieder entfernt
7. das Restore-Test-Volume für weitere Übungen behalten
```

---

## Wichtige Begriffe

### TAR

TAR steht ursprünglich für `Tape Archive`.

Das ist ein Archivformat aus der Unix-/Linux-Welt. Man kann es sich ähnlich wie eine ZIP-Datei vorstellen.

Eine Datei mit der Endung `.tar.gz` besteht aus zwei Teilen:

```text
.tar = mehrere Dateien werden in ein Archiv gepackt
.gz  = dieses Archiv wird mit gzip komprimiert
```

Wichtige TAR-Befehle aus diesem Projekt:

```text
tar czf = Archiv erstellen
tar tzf = Archivinhalt anzeigen
tar xzf = Archiv entpacken
```

Merksatz:

```text
tar czf = Backup bauen
tar tzf = Backup anschauen
tar xzf = Backup zurückspielen
```

---

## Redis-Persistenz: RDB und AOF

Redis arbeitet stark im Arbeitsspeicher. Damit Daten nach einem Neustart erhalten bleiben können, nutzt Redis Persistenzmechanismen.

Persistenz bedeutet:

```text
Daten werden dauerhaft gespeichert und verschwinden nicht einfach nach einem Neustart.
```

### RDB

RDB bedeutet `Redis Database`.

Einfach erklärt:

```text
RDB = Foto der Datenbank
```

Redis erstellt dabei eine Momentaufnahme der Daten zu einem bestimmten Zeitpunkt.

Vorteile:

```text
kompakt
gut für Backups
gut für schnelle Wiederherstellung
```

Nachteil:

```text
Änderungen seit dem letzten Snapshot können verloren gehen
```

### AOF

AOF bedeutet `Append Only File`.

Einfach erklärt:

```text
AOF = Tagebuch der Datenbankänderungen
```

Redis schreibt dabei Änderungsbefehle fortlaufend mit.

Beispiel:

```text
SET training_status "volume-test-erfolgreich"
```

Beim Neustart kann Redis diese Befehle erneut abspielen und den Datenbestand wiederherstellen.

Vorteile:

```text
genauere Wiederherstellung möglich
weniger Datenverlust als bei seltenen Snapshots
```

Nachteile:

```text
größere Dateien
mehr Schreiblast
mehr Konfigurationsaufwand
```

Merksatz:

```text
RDB = Foto
AOF = Tagebuch
```

---

## Backup-Prüfung: drei Stufen

Nicht jede Prüfung ist gleich stark.

### Stufe 1: Backup-Datei existiert

Beispiel:

```powershell
dir backups
```

Das beweist nur:

```text
Es gibt eine Datei.
```

Das ist wichtig, aber noch schwach.

---

### Stufe 2: Backup-Archiv ist lesbar

Beispiel:

```powershell
tar tzf redis_data_prod_backup.tar.gz
```

Das beweist:

```text
Das Archiv kann geöffnet werden.
Im Archiv sind Dateien sichtbar.
```

Das ist besser, aber noch kein vollständiger Restore-Test.

---

### Stufe 3: Restore-Test

Dabei wird geprüft:

```text
Kann das Backup in ein neues Volume zurückgespielt werden?
Kann Redis mit diesem Volume starten?
Sind die erwarteten Daten wieder lesbar?
```

Das ist der wichtigste Nachweis.

In diesem Projekt wird dafür der Wert geprüft:

```text
training_status = volume-test-erfolgreich
```

Wenn dieser Wert nach dem Restore-Test wieder gelesen werden kann, ist bewiesen:

```text
Das Backup ist praktisch wiederherstellbar.
```

---

## Warum ein separates Restore-Test-Volume?

Der Restore-Test nutzt nicht direkt das produktive Volume.

Produktives Volume:

```text
dockerbung_redis_data_prod
```

Restore-Test-Volume:

```text
dockerbung_redis_data_restore_test
```

Das ist wichtig, weil ein Restore in ein echtes produktives Volume Daten überschreiben kann.

Sicherer Ablauf:

```text
1. Backup erstellen
2. Backup technisch prüfen
3. Backup in separates Test-Volume zurückspielen
4. Anwendung mit Test-Volume starten
5. Daten prüfen
6. erst danach über produktiven Restore nachdenken
```

---

## Warum Backups nicht auf GitHub gehören

Der Ordner `backups/` wird in `.gitignore` ausgeschlossen.

Grund:

```text
Backups können echte Daten enthalten.
```

Beispiele:

```text
Benutzerdaten
Sitzungsdaten
Datenbankinhalte
Passwörter
Tokens
interne Systeminformationen
```

Deshalb gilt:

```text
Backups gehören nicht automatisch in ein öffentliches GitHub-Repository.
```

---

## Sensible Daten und Secrets

Sensible Daten sind geheime oder schützenswerte Werte.

Beispiele:

```text
Passwörter
API-Keys
Tokens
SSH-Schlüssel
Zertifikate
Datenbankzugänge
Cloud-Zugangsdaten
```

Solche Werte gehören nicht direkt in:

```text
README.md
Dockerfile
compose.dev.yml
compose.prod.yml
öffentliche Logs
Screenshots
GitHub
```

---

## Aktueller Lernansatz mit `.env`

In diesem Lernprojekt wird für lokale Werte eine `.env`-Datei genutzt.

Beispiel:

```env
REDIS_PASSWORD=local_redis_password_please_change
```

Die Datei `.env` wird nicht zu GitHub hochgeladen, weil sie in `.gitignore` steht.

Das ist für die Lernumgebung akzeptabel.

Dazu gibt es eine `.env.example`.

Die Datei `.env.example` enthält nur Beispielwerte und darf auf GitHub liegen.

Merksatz:

```text
.env = echte lokale Werte, nicht hochladen
.env.example = Vorlage, darf ins Repository
```

---

## Docker Compose Secrets

Ein Secret ist ein geheimer Wert.

Docker Compose Secrets sind eine Möglichkeit, solche geheimen Werte gezielter an Container zu übergeben.

Statt ein Passwort direkt in eine Compose-Datei zu schreiben, kann ein Secret als Datei bereitgestellt werden.

Im Container liegt das Secret typischerweise unter:

```text
/run/secrets/<secret_name>
```

Beispiel-Idee:

```yaml
secrets:
  redis_password:
    file: ./secrets/redis_password.txt
```

Ein Service kann dann gezielt Zugriff auf dieses Secret bekommen.

Wichtig:

```text
Nicht jeder Container bekommt automatisch jedes Secret.
Nur Services, die das Secret ausdrücklich verwenden, erhalten Zugriff.
```

Für dieses Lernprojekt wird Docker Compose Secrets noch nicht aktiv eingesetzt.  
Das Thema wird später als eigene Sicherheitslektion behandelt.

---

## Lernumgebung vs. Produktion

Dieses Projekt ist bewusst ein Lernprojekt.

Es zeigt:

```text
Docker Volumes
Redis-Persistenz
Backup-Erstellung
Backup-Prüfung
Restore-Test
Git-Dokumentation
Skript-Automatisierung
```

Für echte Produktion müssten zusätzliche Themen berücksichtigt werden.

---

## Produktionsanforderung 1: Externe Backup-Speicherung

Im Lernprojekt liegen Backups lokal im Ordner:

```text
C:\Docker Übung\backups
```

Für Produktion reicht das nicht.

Wenn derselbe Rechner kaputtgeht, gestohlen wird oder durch Schadsoftware verschlüsselt wird, kann auch das lokale Backup verloren sein.

Produktionsnäher wäre:

```text
lokales Backup
+
externes Backup
+
regelmäßiger Restore-Test
```

Mögliche externe Speicherorte:

```text
Backup-Server
NAS-System
Cloud Storage
offline gelagerter Datenträger
immutable Storage
```

NAS bedeutet `Network Attached Storage`, also ein Speichergerät im Netzwerk.

Immutable Storage bedeutet unveränderbarer Speicher.  
Daten können dort für eine bestimmte Zeit nicht verändert oder gelöscht werden.

Das ist besonders wichtig gegen Ransomware.

---

## Produktionsanforderung 2: Verschlüsselung

Backups können sensible Daten enthalten.

Deshalb sollten produktive Backups verschlüsselt werden.

Verschlüsselung bedeutet:

```text
Die Backup-Datei ist ohne passenden Schlüssel nicht sinnvoll lesbar.
```

Produktionsnaher Ablauf:

```text
Backup erstellen
Backup prüfen
Backup verschlüsseln
Backup extern speichern
Restore-Test regelmäßig durchführen
```

Wichtig:

```text
Der Schlüssel für die Verschlüsselung darf nicht zusammen mit dem Backup offen abgelegt werden.
```

---

## Produktionsanforderung 3: Rechtekonzept

Ein Rechtekonzept beantwortet:

```text
Wer darf Backups erstellen?
Wer darf Backups lesen?
Wer darf Backups löschen?
Wer darf Restore ausführen?
Wer darf Passwörter sehen?
```

Warum ist das wichtig?

Wer ein Backup lesen kann, kann oft indirekt auch die Datenbank lesen.

Beispielrollen:

| Rolle | Typische Rechte |
|---|---|
| Entwickler | darf lokale Testdaten nutzen |
| DevOps/Admin | darf Backups erstellen und Restore testen |
| Security/Compliance | darf Prozesse prüfen |
| normale Benutzer | kein Zugriff auf Backups |

---

## Produktionsanforderung 4: Monitoring

Monitoring bedeutet Überwachung.

Ein Backup-Prozess darf nicht still fehlschlagen.

Schlechtes Szenario:

```text
Backups schlagen seit 30 Tagen fehl.
Niemand merkt es.
Dann fällt das System aus.
Es gibt kein brauchbares Backup.
```

Gutes Szenario:

```text
Backup läuft regelmäßig.
Ergebnis wird überwacht.
Bei Fehler wird ein Alarm ausgelöst.
Restore-Tests werden dokumentiert.
```

Mögliche Prüfungen:

```text
Backup-Datei wurde erstellt
Backup-Datei ist nicht leer
Archiv ist lesbar
Restore-Test war erfolgreich
Backup ist nicht zu alt
Speicherplatz reicht aus
```

---

## Produktionsanforderung 5: Protokollierung

Protokollierung bedeutet:

```text
Wichtige Ereignisse werden nachvollziehbar gespeichert.
```

Beispiel:

```text
Backup gestartet: 2026-05-15 00:05:14
Volume: dockerbung_redis_data_prod
Backup-Datei: redis_data_prod_backup_2026-05-15_00-05-14.tar.gz
Archivprüfung: erfolgreich
Restore-Test: erfolgreich
Dauer: 12 Sekunden
```

Warum wichtig?

Bei Problemen muss nachvollziehbar sein:

```text
Wann lief das letzte Backup?
War es erfolgreich?
Wurde es wiederhergestellt getestet?
Welche Datei wurde verwendet?
Gab es Fehler oder Warnungen?
```

---

## Produktionsanforderung 6: Retention Policy

Retention Policy bedeutet Aufbewahrungsregel.

Sie beantwortet:

```text
Wie lange werden Backups behalten?
Wie viele tägliche Backups werden behalten?
Wie viele wöchentliche Backups werden behalten?
Wann wird automatisch gelöscht?
```

Beispiel:

```text
stündliche Backups: 24 Stunden behalten
tägliche Backups: 30 Tage behalten
wöchentliche Backups: 12 Wochen behalten
monatliche Backups: 12 Monate behalten
```

Ohne Retention Policy entstehen zwei typische Probleme:

```text
Backups werden nie gelöscht und der Speicher läuft voll.
```

oder:

```text
Backups werden zu früh gelöscht und eine Wiederherstellung ist nicht mehr möglich.
```

---

## Produktionsanforderung 7: Secret Management

Secret Management bedeutet sichere Verwaltung geheimer Werte.

In einfachen Lernprojekten kann `.env` ausreichen, solange die Datei nicht veröffentlicht wird.

In Produktion nutzt man eher:

```text
Docker Compose Secrets
Kubernetes Secrets
Cloud Secret Manager
Azure Key Vault
AWS Secrets Manager
Google Secret Manager
HashiCorp Vault
```

Ziel:

```text
Geheime Werte nicht in Code schreiben
Geheime Werte nicht in GitHub speichern
Geheime Werte nicht in Logs ausgeben
Zugriff auf Secrets gezielt einschränken
```

---

## Saubere Backup-Denkweise

Ein professioneller Backup-Prozess besteht nicht nur aus einem Befehl.

Er besteht aus mehreren Fragen:

```text
Welche Daten müssen gesichert werden?
Wie oft muss gesichert werden?
Wo wird gespeichert?
Ist das Backup verschlüsselt?
Wer darf darauf zugreifen?
Wie lange wird es behalten?
Wird überwacht, ob das Backup funktioniert?
Wird regelmäßig ein Restore getestet?
Ist der Restore dokumentiert?
```

---

## Lernversion dieses Projekts

Dieses Projekt bildet bewusst eine verständliche Lernversion ab:

```text
1. Redis-Daten in Docker Volume speichern
2. Testwert schreiben
3. Persistenz nach Container-Neustart prüfen
4. Backup-Datei erstellen
5. Backup-Datei technisch prüfen
6. Restore in separates Test-Volume durchführen
7. Redis aus Restore-Volume starten
8. Testwert wieder auslesen
9. Skripte für Backup und Restore erstellen
10. Gesamtprozess mit Master-Skript starten
```

---

## Produktionsnahe Erweiterungen für später

Spätere sinnvolle Erweiterungen wären:

```text
Backups verschlüsseln
Backups extern speichern
alte Backups automatisch nach Regel löschen
Log-Datei für Backup-Prozess schreiben
Monitoring/Alarmierung ergänzen
Docker Compose Secrets verwenden
Restore-Test regelmäßig automatisieren
Kubernetes-Backup-Konzepte kennenlernen
```

---

## Praxis-Fazit

Dieses Projekt zeigt nicht nur, wie ein Docker-Volume gesichert wird.

Es zeigt den wichtigeren betrieblichen Gedanken:

```text
Ein Backup ohne Restore-Test ist nur eine Hoffnung.
Ein Backup mit erfolgreichem Restore-Test ist ein belastbarer Betriebsprozess.
```

Das Ziel ist nicht nur, Docker-Befehle auswendig zu lernen.

Das Ziel ist zu verstehen:

```text
Wie bleiben Daten erhalten?
Wie sichere ich sie?
Wie prüfe ich sie?
Wie stelle ich sie wieder her?
Wie dokumentiere ich den Prozess?
Wie unterscheidet sich eine Lernumgebung von echter Produktion?
```

Damit ist dieses Lernprojekt ein wichtiger Schritt in Richtung DevOps-, Cloud- und Plattform-Betrieb.
---

## Erweiterung: Einfache Retention Policy vs. GFS und 3-2-1-Backup-Regel

Dieses Lernprojekt nutzt aktuell eine einfache Retention Policy.

Retention Policy bedeutet:

```text
Aufbewahrungsregel für Backups
```

Das aktuelle Skript `scripts/cleanup-old-backups.ps1` prüft:

```text
Wie alt sind Backup-Dateien?
Wie viele neue Backups sollen mindestens erhalten bleiben?
Welche Dateien wären Löschkandidaten?
Soll wirklich gelöscht werden oder nur ein Dry-Run stattfinden?
```

Das ist eine gute Lernversion, aber noch keine vollständige Enterprise-Backup-Strategie.

---

## Was unsere aktuelle Retention Policy macht

Die aktuelle Laborregel arbeitet vereinfacht nach diesem Prinzip:

```text
Backups älter als X Tage dürfen gelöscht werden.
Aber mindestens die neuesten Y Backups bleiben immer erhalten.
```

Beispiel:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\cleanup-old-backups.ps1 -RetentionDays 7 -MinimumBackupsToKeep 2
```

Bedeutung:

```text
Backups älter als 7 Tage werden als mögliche Löschkandidaten betrachtet.
Die neuesten 2 Backups bleiben immer geschützt.
Ohne -Execute wird nichts gelöscht.
```

Das ist eine sogenannte einfache Rolling Retention.

Rolling Retention bedeutet:

```text
Es wird laufend nach Alter und Anzahl entschieden, welche Backups erhalten bleiben.
```

---

## Warum das noch nicht vollständig produktionsnah ist

In echter Produktion reicht eine einfache Regel oft nicht aus.

Unternehmen brauchen häufig Antworten auf Fragen wie:

```text
Gibt es ein Backup von gestern?
Gibt es ein Backup von letzter Woche?
Gibt es ein Backup vom Monatsabschluss?
Gibt es ein Backup vom Jahresabschluss?
Wie lange müssen Daten aus rechtlichen Gründen aufbewahrt werden?
Wie schnell muss ein System nach Ausfall wieder laufen?
Wie viel Datenverlust ist maximal erlaubt?
```

Deshalb werden in der Praxis oft abgestufte Backup-Strategien eingesetzt.

---

## GFS: Großvater-Vater-Sohn-Prinzip

GFS steht für:

```text
Grandfather-Father-Son
```

Auf Deutsch:

```text
Großvater-Vater-Sohn
```

Das ist eine klassische Backup-Aufbewahrungsstrategie.

Sie arbeitet mit verschiedenen Zeitstufen:

| Ebene | Bedeutung | Typisches Beispiel |
|---|---|---|
| Sohn | kurzfristige Backups | tägliche Backups |
| Vater | mittelfristige Backups | wöchentliche Backups |
| Großvater | langfristige Backups | monatliche oder jährliche Backups |

Die Grundidee:

```text
Aktuelle Backups werden engmaschig behalten.
Ältere Backups werden ausgedünnt.
Wichtige Wochen-, Monats- oder Jahresstände bleiben länger erhalten.
```

---

## Einfaches GFS-Beispiel

Eine mögliche GFS-Regel könnte sein:

```text
Tägliche Backups: 14 Tage behalten
Wöchentliche Backups: 8 Wochen behalten
Monatliche Backups: 12 Monate behalten
Jährliche Backups: 5 Jahre behalten
```

Dadurch hat man kurzfristig viele Wiederherstellungspunkte, aber langfristig nicht jeden einzelnen Tag als Backup-Datei.

Das spart Speicherplatz und hält trotzdem wichtige Wiederherstellungspunkte verfügbar.

---

## Vergleich: einfache Retention vs. GFS

| Ansatz | Idee | Vorteil | Nachteil |
|---|---|---|---|
| einfache Retention | nach Alter und Mindestanzahl löschen | leicht verständlich, gut für Labor | weniger flexibel |
| GFS | tägliche, wöchentliche, monatliche, jährliche Stufen | produktionsnäher, besser für langfristige Aufbewahrung | deutlich komplexer |
| 3-2-1-Regel | mehrere Kopien auf verschiedenen Speicherorten | schützt gegen Hardwareverlust und Standortausfall | braucht zusätzliche Infrastruktur |

---

## 3-2-1-Backup-Regel

Die 3-2-1-Regel ist eine bekannte Grundregel für robuste Backups.

Sie bedeutet:

```text
3 Kopien der Daten
2 verschiedene Speichermedien
1 Kopie extern/offsite
```

Einfach erklärt:

| Zahl | Bedeutung |
|---|---|
| 3 | Originaldaten plus zwei Backup-Kopien |
| 2 | Daten auf mindestens zwei unterschiedlichen Speichermedien |
| 1 | eine Kopie außerhalb des Hauptstandorts |

Beispiel:

```text
1. Redis-Daten im Docker Volume
2. lokales Backup im Ordner backups/
3. externe Kopie auf Backup-Server, NAS oder Cloud Storage
```

NAS bedeutet `Network Attached Storage`, also ein Speichergerät im Netzwerk.

Offsite bedeutet:

```text
nicht am selben Ort wie das Hauptsystem
```

---

## Warum 3-2-1 wichtig ist

Wenn Backups nur lokal liegen, können sie gemeinsam mit dem System verloren gehen.

Beispiele:

```text
Laptop defekt
Server-Festplatte kaputt
Ransomware verschlüsselt lokale Dateien
Brand oder Wasserschaden
Diebstahl
versehentliches Löschen
```

Die 3-2-1-Regel reduziert dieses Risiko, weil nicht alles am selben Ort und auf demselben Medium liegt.

---

## Moderne Erweiterung: 3-2-1-1-0

In modernen Backup-Konzepten wird die klassische 3-2-1-Regel oft erweitert.

Eine bekannte Erweiterung ist:

```text
3-2-1-1-0
```

Bedeutung:

| Teil | Erklärung |
|---|---|
| 3 | drei Kopien der Daten |
| 2 | zwei unterschiedliche Speichermedien |
| 1 | eine Kopie offsite |
| 1 | eine zusätzliche unveränderbare oder offline Kopie |
| 0 | null Fehler bei der Wiederherstellungsprüfung |

Unveränderbar bedeutet:

```text
Ein Backup kann für eine festgelegte Zeit nicht verändert oder gelöscht werden.
```

Das ist besonders wichtig gegen Ransomware.

Der Punkt `0` ist für dieses Lernprojekt besonders interessant:

```text
0 ungeprüfte Wiederherstellungsfehler
```

Das passt zu unserem Grundsatz:

```text
Ein Backup ist erst dann belastbar, wenn ein Restore erfolgreich getestet wurde.
```

---

## Bezug zu Docker, Images, Containern und Volumes

Bei Docker muss man sauber unterscheiden:

```text
Image
Container
Volume
```

### Images

Images sind Bauvorlagen für Container.

Beispiel:

```text
handsonlabs/my-web:v1.2
```

Images werden normalerweise versioniert und in einer Registry gespeichert.

Für Images nutzt man eher:

```text
Tags
Container Registry
Rollback
CI/CD-Pipeline
Release-Versionen
```

CI/CD bedeutet `Continuous Integration / Continuous Deployment`.

Einfach erklärt:

```text
Code wird automatisch geprüft, gebaut und verteilt.
```

### Container

Container sind laufende Instanzen von Images.

Container selbst werden normalerweise nicht klassisch gesichert.

Warum?

```text
Container sollen ersetzbar sein.
Wenn ein Container kaputt ist, startet man einen neuen aus dem Image.
```

### Volumes

Volumes enthalten die wichtigen veränderlichen Daten.

Beispiele:

```text
Datenbankdaten
Uploads
persistente Anwendungsdaten
Konfigurationszustände
```

Deshalb gilt:

```text
Images werden versioniert.
Container werden ersetzt.
Volumes werden gesichert.
```

Für Backup-Strategien wie Retention, GFS und 3-2-1 sind also besonders die Volumes wichtig.

---

## Bezug zu unserem Projekt

In diesem Projekt ist das wichtigste produktive Volume:

```text
dockerbung_redis_data_prod
```

Dieses Volume enthält Redis-Daten.

Redis speichert darin unter anderem Dateien wie:

```text
dump.rdb
appendonlydir/
appendonly.aof.manifest
```

Das Backup-Skript erstellt daraus lokale `.tar.gz`-Dateien im Ordner:

```text
backups/
```

Diese Dateien werden durch `.gitignore` bewusst nicht nach GitHub hochgeladen.

---

## BSI- und NIST-Einordnung

Für produktionsnahe Systeme sollte ein Backup-Konzept nicht nur technisch funktionieren, sondern auch organisatorisch sauber geplant sein.

Das BSI (Bundesamt für Sicherheit in der Informationstechnik) beschreibt im IT-Grundschutz-Baustein CON.3, dass Datensicherung dazu dient, durch redundante Datenbestände den IT-Betrieb kurzfristig wiederaufnehmen zu können.

NIST (National Institute of Standards and Technology) behandelt in SP 800-34 Notfall- und Wiederherstellungsplanung. Dabei geht es nicht nur um Dateien, sondern um Prozesse, Tests, Rollen, Wiederherstellungsziele und dokumentierte Verfahren.

Für dieses Lernprojekt bedeutet das:

```text
Nicht nur Backup-Datei erzeugen.
Restore testen.
Ergebnis dokumentieren.
Risiken kennen.
Aufbewahrung regeln.
Zugriff schützen.
```

---

## RPO und RTO

In professionellen Backup- und Wiederherstellungskonzepten tauchen oft zwei Begriffe auf:

```text
RPO
RTO
```

### RPO

RPO bedeutet:

```text
Recovery Point Objective
```

Einfach erklärt:

```text
Wie viel Datenverlust ist maximal akzeptabel?
```

Beispiel:

```text
RPO = 24 Stunden
```

Das bedeutet:

```text
Im schlimmsten Fall dürfen Daten seit dem letzten täglichen Backup verloren gehen.
```

### RTO

RTO bedeutet:

```text
Recovery Time Objective
```

Einfach erklärt:

```text
Wie schnell muss das System nach einem Ausfall wieder laufen?
```

Beispiel:

```text
RTO = 2 Stunden
```

Das bedeutet:

```text
Nach einem Ausfall muss der Dienst spätestens nach 2 Stunden wieder verfügbar sein.
```

---

## Produktionsnahe Backup-Fragen

Ein professionelles Backup-Konzept beantwortet mindestens diese Fragen:

```text
Welche Daten müssen gesichert werden?
Wie oft werden sie gesichert?
Wie lange werden Backups behalten?
Wo werden Backups gespeichert?
Sind Backups verschlüsselt?
Wer darf Backups lesen?
Wer darf Backups löschen?
Wer darf Restore durchführen?
Wie wird geprüft, ob Backups funktionieren?
Wie wird ein Restore dokumentiert?
Wie wird ein Backup-Fehler gemeldet?
Wie schnell muss das System wiederhergestellt werden?
Wie viel Datenverlust ist akzeptabel?
```

---

## Einordnung unserer aktuellen Umsetzung

Unsere aktuelle Umsetzung ist eine starke Lernversion:

```text
Backup erstellen
Backup-Datei prüfen
Restore-Test durchführen
Master-Skript nutzen
Retention-Dry-Run ausführen
ältere Backups kontrolliert erkennen
GitHub-Dokumentation pflegen
```

Sie ist aber noch keine vollständige produktionsreife Backup-Lösung.

Eine produktionsnähere Erweiterung wäre:

```text
GFS-Retention ergänzen
3-2-1-Strategie einplanen
Backups verschlüsseln
Backups extern speichern
Restore-Tests regelmäßig automatisieren
Monitoring ergänzen
Logdateien schreiben
RPO/RTO definieren
Secret Management verbessern
```

---

## Merksatz

```text
Docker-Image = versionierter Bauplan
Docker-Container = ersetzbare Laufzeitinstanz
Docker-Volume = schützenswerter Datenbestand
```

Und für Backups:

```text
Ein Backup ohne Restore-Test ist nur eine Hoffnung.
Ein Backup mit erfolgreichem Restore-Test ist ein belastbarer Betriebsprozess.
```

---

## Nächster sinnvoller Schritt

Dieses Projekt nutzt aktuell eine einfache Retention Policy.

Eine spätere Lerneinheit kann daraus eine produktionsnähere GFS-Simulation machen:

```text
daily backups
weekly backups
monthly backups
yearly backups
```

Ziel wäre dann:

```text
Nicht alle Backups gleich behandeln,
sondern je nach Bedeutung und Alter unterschiedlich lange behalten.
```