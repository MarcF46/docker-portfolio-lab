# Registry Deep Dive

## Zweck

Dieses Dokument beschreibt den erweiterten Registry-Test im Docker Portfolio Lab.

Ziel ist, nicht nur ein Image lokal zu bauen, sondern den Registry-Workflow sauber nachzuvollziehen:

```text
Image bauen
Image taggen
Image pushen
Registry prüfen
Image aus Registry verwenden
Digest einordnen
Testcontainer starten
Funktion verifizieren
```

---

## Betriebsfrage

Ein realistischer Auftrag wäre:

```text
Das Web-Image v1.4 wurde gebaut, getestet und gescannt.
Bitte veröffentliche es in der internen Registry und prüfe,
ob es aus der Registry wieder verwendet werden kann.
```

---

## Wichtige Begriffe

| Begriff | Bedeutung |
|---|---|
| Image | gebautes Container-Dateisystem mit Metadaten |
| Tag | lesbarer Versionsname, z. B. `v1.4` |
| Registry | Speicherort für Container-Images |
| Repository | Image-Sammlung innerhalb einer Registry |
| Digest | eindeutiger Inhalts-Fingerabdruck |
| Push | Image in eine Registry hochladen |
| Pull | Image aus einer Registry herunterladen |

---

## Tag vs. Digest

Ein Tag ist gut lesbar:

```text
localhost:5000/handsonlabs/my-web:v1.4
```

Ein Digest ist eindeutig:

```text
sha256:ca98bf6595c3b5671c69954241e9d4d3a4cf950f881396d15220cd03c32afe16
```

Wichtige Einordnung:

```text
Ein Tag kann später auf ein anderes Image zeigen.
Ein Digest beschreibt einen konkreten Image-Inhalt eindeutig.
```

Darum sind Digests im Betrieb wichtig für Nachvollziehbarkeit, Rollbacks und Security-Prüfungen.

---

## Registry-Testdatei

Die Datei `compose.registry-test.yml` nutzt ein bereits gebautes Image aus der lokalen Registry:

```yaml
image: localhost:5000/handsonlabs/my-web:v1.4
```

Wichtig:

```text
Diese Datei baut kein Image.
Sie verwendet ein Image, das vorher in die Registry gepusht wurde.
```

Unterschied zu `compose.prod.yml`:

| Datei | Zweck |
|---|---|
| `compose.prod.yml` | baut oder nutzt das produktionsnahe Web-Image |
| `compose.registry-test.yml` | testet die Verwendung eines Registry-Images |

---

## Lokale Registry starten

Falls die Registry noch nicht läuft:

```powershell
docker run -d --name dockerbung-registry -p 5000:5000 registry:2
```

### Erklärung

| Teil | Bedeutung |
|---|---|
| `docker run` | startet einen Container |
| `-d` | läuft im Hintergrund |
| `--name dockerbung-registry` | fester Containername |
| `-p 5000:5000` | Host-Port 5000 auf Registry-Port 5000 |
| `registry:2` | offizielles Registry-Image |

---

## Registry-Katalog prüfen

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/v2/_catalog"
```

Bedeutung:

```text
Fragt die lokale Registry nach vorhandenen Repositories.
```

Bei leerer Registry ist eine leere Liste normal.

---

## Image für Registry taggen

```powershell
docker tag handsonlabs/my-web:v1.4 localhost:5000/handsonlabs/my-web:v1.4
```

### Erklärung

| Teil | Bedeutung |
|---|---|
| `docker tag` | erstellt einen zusätzlichen Namen für ein Image |
| `handsonlabs/my-web:v1.4` | lokales Quellimage |
| `localhost:5000/...` | Zielname passend zur lokalen Registry |

Wichtig:

```text
docker tag kopiert das Image nicht.
Es vergibt nur einen zusätzlichen Namen.
```

---

## Image pushen

```powershell
docker push localhost:5000/handsonlabs/my-web:v1.4
```

Ergebnis im Lab:

```text
v1.4: digest: sha256:ca98bf6595c3b5671c69954241e9d4d3a4cf950f881396d15220cd03c32afe16
```

Bedeutung:

```text
Das Image wurde erfolgreich in die lokale Registry hochgeladen.
Der Digest identifiziert den konkreten Image-Inhalt.
```

---

## Repository und Tags prüfen

```powershell
Invoke-RestMethod -Uri "http://localhost:5000/v2/_catalog"
Invoke-RestMethod -Uri "http://localhost:5000/v2/handsonlabs/my-web/tags/list"
```

Erwartung:

```text
Repository: handsonlabs/my-web
Tag: v1.4
```

---

## Registry-Test starten

```powershell
docker compose -f compose.registry-test.yml up -d
```

Diese Compose-Datei startet einen Testcontainer aus dem Registry-Image:

```text
localhost:5000/handsonlabs/my-web:v1.4
```

---

## Funktion prüfen

```powershell
curl.exe -I http://localhost:8083
docker compose -f compose.registry-test.yml ps
```

Ergebnis im Lab:

```text
HTTP/1.1 200 OK
dockerbung-web-registry-test Up
```

Bedeutung:

```text
Das Image aus der Registry konnte verwendet werden.
Der gestartete Container liefert die Webseite erfolgreich aus.
```

---

## Test stoppen

```powershell
docker compose -f compose.registry-test.yml down
```

Im Lab erschien danach:

```text
Network dockerbung_default Resource is still in use
```

Das ist kein schwerer Fehler.

Bedeutung:

```text
Der Registry-Testcontainer wurde entfernt.
Das Netzwerk konnte nicht entfernt werden,
weil der Hauptstack es noch verwendet.
```

Der Hauptstack nutzt ebenfalls das Projekt-Netzwerk `dockerbung_default`.

---

## Besserer Test mit eigenem Compose-Projektnamen

Um den Registry-Test vom Hauptstack zu trennen, kann man künftig einen eigenen Projektnamen verwenden:

```powershell
docker compose -p registrytest -f compose.registry-test.yml up -d
```

Stoppen:

```powershell
docker compose -p registrytest -f compose.registry-test.yml down
```

Dann erzeugt Docker Compose ein eigenes Netzwerk:

```text
registrytest_default
```

Vorteil:

```text
Der Registry-Test vermischt sich nicht mit dem Hauptstack-Netzwerk.
```

---

## Typische Fehlerbilder

| Symptom | Mögliche Ursache | Prüfung |
|---|---|---|
| Push schlägt fehl | Registry läuft nicht | `docker ps --filter name=dockerbung-registry` |
| Repository fehlt im Katalog | Image wurde nicht gepusht | `/v2/_catalog` prüfen |
| Tag fehlt | falscher Tag oder falscher Repository-Name | `/tags/list` prüfen |
| Testcontainer startet nicht | Image nicht vorhanden oder Registry nicht erreichbar | `docker compose logs` |
| Netzwerk kann nicht entfernt werden | andere Container nutzen es noch | `docker network inspect dockerbung_default` |

---

## Lab vs. Produktion

| Thema | Lab | Produktion |
|---|---|---|
| Registry | lokale Registry auf `localhost:5000` | Docker Hub, GHCR, ECR, ACR, Harbor oder interne Registry |
| Authentifizierung | keine | Login, Token, Rollen, Pull Secrets |
| Transport | lokales HTTP | HTTPS/TLS |
| Tags | manuell | CI/CD-Versionierung |
| Digest | sichtbar im Push | wichtig für Freigabe, Rollback und Nachvollziehbarkeit |
| Security | manueller Scout-Scan | automatisierte Scans und Policies |

---

## Fazit

Der Registry-Deep-Dive zeigt:

```text
Ein lokal gebautes und gescanntes Image kann versioniert,
in eine Registry gepusht,
über Repository und Tag geprüft
und aus der Registry wieder gestartet werden.
```

Wichtiger Betriebsgrundsatz:

```text
Tags sind praktisch,
Digests sind eindeutig.
```

Damit ist die Grundlage für spätere CI/CD-Pipelines mit Build, Scan und Push gelegt.
