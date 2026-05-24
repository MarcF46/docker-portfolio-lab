# Docker Registry, Push, Pull und Digest

## Zweck

Diese Dokumentation beschreibt die Registry-Lerneinheit im Docker Portfolio Lab.

Ziel war es, den Unterschied zwischen lokal gebauten Images, lokalem Docker Image Store, Docker Build Cache, Registry, Push, Pull, Tags und Digests praktisch zu verstehen.

---

## Grundbegriffe

| Begriff | Bedeutung |
|---|---|
| Git Repository | speichert Code und Konfigurationsdateien |
| Docker Build | baut aus Projektdateien ein Image |
| Docker Image | fertiges Paket / Vorlage für Container |
| Lokaler Docker Image Store | lokaler Speicher für fertig gebaute Images |
| Docker Build Cache | wiederverwendete Zwischenschritte beim Bauen |
| Registry | zentraler Speicherort für Container Images |
| Push | Image in eine Registry hochladen |
| Pull | Image aus einer Registry herunterladen |
| Container | laufende Instanz eines Images |

---

## Wichtige Unterscheidung

```text
Lokal gebaut ≠ nur Docker-Cache

Lokal gebaut:
Das fertige Image liegt im lokalen Docker Image Store.

Docker Build Cache:
Docker merkt sich Zwischenschritte, damit spätere Builds schneller laufen.

Registry:
zentraler Speicherort für Images, damit andere Systeme sie ziehen können.
```

Merksatz:

```text
Git speichert Code.
Docker baut daraus Images.
Der lokale Image Store hält Images auf deinem Rechner.
Die Registry verteilt Images an Server, Cloud oder Kubernetes.
Der Build Cache beschleunigt das erneute Bauen.
```

Eine Registry ist damit als grobe Vorstellung ähnlich wie ein Cloudspeicher, aber genauer:

```text
Registry = spezialisierter Cloud-/Server-Speicher für Container Images.
```

---

## Ablauf im Unternehmen

Typischer Ablauf:

```text
Code im Git-Repository
↓
CI/CD-System baut Image
↓
Image bekommt einen Tag
↓
Image wird in Registry gepusht
↓
Server/Kubernetes/Cloud pullt Image
↓
Container läuft aus diesem Image
```

Wichtig:

```text
Build passiert häufig in CI/CD.
Deployment-Systeme nutzen später fertige Images aus einer Registry.
```

---

## Beispiele für Registries

| Abkürzung / Name | Voller Name | Kurz erklärt |
|---|---|---|
| Docker Hub | Docker Hub | öffentliche/kommerzielle Registry von Docker |
| GHCR | GitHub Container Registry | Container-Image-Speicher von GitHub |
| GitLab Container Registry | GitLab Container Registry | Container-Image-Speicher von GitLab |
| ECR | Amazon Elastic Container Registry | Container-Image-Speicher von Amazon Web Services |
| ACR | Azure Container Registry | Container-Image-Speicher von Microsoft Azure |
| GAR | Google Artifact Registry | Speicher für Container Images und andere Build-Artefakte bei Google Cloud |
| Private Registry | unternehmenseigene Registry | interne Registry innerhalb einer Firma |

Hinweis:

```text
Diese Dienste muss man an dieser Stelle noch nicht tief beherrschen.
Wichtig ist zuerst das Prinzip:
Image bauen → taggen → pushen → pullen → starten.
```

---

## Lokale Registry starten

Im Lab wurde eine lokale Registry als Container gestartet:

```powershell
docker run -d --name local-registry -p 5000:5000 registry:2
```

Erklärung:

| Teil | Bedeutung |
|---|---|
| `docker run` | startet einen neuen Container |
| `-d` | läuft im Hintergrund |
| `--name local-registry` | Container bekommt den Namen `local-registry` |
| `-p 5000:5000` | Host-Port 5000 wird auf Container-Port 5000 weitergeleitet |
| `registry:2` | offizielles Registry-Image |

Beim ersten Start war `registry:2` lokal noch nicht vorhanden. Docker hat das Image automatisch heruntergeladen.

Prüfung:

```powershell
docker ps --filter "name=local-registry"
```

Ergebnis:

```text
local-registry läuft auf localhost:5000
```

---

## Lokale Images

Vor dem Push waren lokale Images vorhanden:

```text
handsonlabs/my-web:v1.1
handsonlabs/my-web:v1.2
```

Diese Images lagen im lokalen Docker Image Store.

Prüfung:

```powershell
docker image ls handsonlabs/my-web
```

---

## Image für lokale Registry taggen

Damit Docker weiß, in welche Registry das Image gepusht werden soll, wurde dem Image ein zusätzlicher Registry-Name gegeben:

```powershell
$RegistryImage = "localhost:5000/handsonlabs/my-web:v1.2"

docker image tag handsonlabs/my-web:v1.2 $RegistryImage
```

Bedeutung:

```text
Es wird kein neues Image gebaut.
Das vorhandene Image bekommt nur ein zusätzliches Namensschild.
```

Der Registry-Name lautet:

```text
localhost:5000/handsonlabs/my-web:v1.2
```

Aufteilung:

| Teil | Bedeutung |
|---|---|
| `localhost:5000` | Adresse der lokalen Registry |
| `handsonlabs/my-web` | Repository/Image-Name |
| `v1.2` | Tag |

---

## Image in Registry pushen

Das getaggte Image wurde in die lokale Registry hochgeladen:

```powershell
docker image push $RegistryImage
```

Beobachtung:

```text
The push refers to repository [localhost:5000/handsonlabs/my-web]
...
v1.2: digest: sha256:7bceb63...
```

Einordnung:

```text
Docker hat das Image in die lokale Registry hochgeladen.
Die einzelnen Image-Layer wurden übertragen.
Die Registry hat dem Inhalt einen Digest zugeordnet.
```

---

## Registry per API prüfen

Die Registry wurde per HTTP-API abgefragt.

Repository-Liste:

```powershell
Invoke-RestMethod http://localhost:5000/v2/_catalog
```

Ergebnis:

```text
repositories:
handsonlabs/my-web
```

Tag-Liste:

```powershell
Invoke-RestMethod http://localhost:5000/v2/handsonlabs/my-web/tags/list | ConvertTo-Json
```

Ergebnis:

```json
{
  "name": "handsonlabs/my-web",
  "tags": [
    "v1.2"
  ]
}
```

Einordnung:

```text
Die Registry kennt das Repository handsonlabs/my-web.
Der Tag v1.2 ist in der Registry vorhanden.
```

---

## Pull aus Registry testen

Zuerst wurde der lokale Registry-Tag entfernt:

```powershell
docker image rm $RegistryImage
```

Wichtig:

```text
Das löscht nicht die Registry.
Das löscht nur den lokalen Namen localhost:5000/handsonlabs/my-web:v1.2.
```

Danach wurde das Image wieder aus der Registry gezogen:

```powershell
docker image pull $RegistryImage
```

Ergebnis:

```text
Image localhost:5000/handsonlabs/my-web:v1.2 Pulled
```

Einordnung:

```text
Das Image lag wirklich in der lokalen Registry.
Docker konnte es von dort wieder herunterladen.
```

---

## Registry-Image in Compose verwenden

Eine zusätzliche Compose-Datei wurde erstellt:

```text
compose.registry-test.yml
```

Zweck:

```text
Testen, ob ein bereits gebautes Image aus der Registry verwendet werden kann.
```

Wichtiger Unterschied:

| Datei | Verhalten |
|---|---|
| `compose.prod.yml` | baut den Web-Service aus Dockerfile + Build-Kontext |
| `compose.registry-test.yml` | baut nichts, nutzt ein fertiges Image aus der lokalen Registry |

Relevant in der Datei:

```yaml
services:
  web-registry-test:
    image: localhost:5000/handsonlabs/my-web:v1.2
    ports:
      - "8083:80"
```

Ergebnis:

```text
web-registry-test läuft auf http://localhost:8083
```

Einordnung:

```text
Compose kann ein fertiges Image aus der Registry nutzen,
ohne selbst ein Dockerfile zu bauen.
```

---

## Orphan-Warnung bei Compose

Beim Start der Registry-Test-Datei erschien eine Warnung über "orphan containers".

Einordnung:

```text
Die Datei compose.registry-test.yml kennt nur web-registry-test.
Im gleichen Projekt laufen aber auch web, redis, prometheus, grafana und cadvisor.
Docker Compose weist deshalb auf Container hin, die in dieser einzelnen Compose-Datei nicht definiert sind.
```

Wichtig:

```text
Nicht blind --remove-orphans verwenden.
Das könnte normale Lab-Container entfernen.
```

---

## Digest verstehen

Beim Push erschien ein Digest:

```text
v1.2: digest: sha256:7bceb63...
```

Bedeutung:

```text
Der Digest ist ein eindeutiger Inhalts-Fingerabdruck aus der Registry.
```

Vergleich:

| Begriff | Beispiel | Bedeutung |
|---|---|---|
| Tag | `v1.2` | lesbarer Name, kann später neu gesetzt werden |
| Image-ID | `sha256:7bceb...` | lokaler Fingerabdruck des Images |
| Digest | `sha256:7bceb...` | Registry-Fingerabdruck für exakt diesen Image-Inhalt |
| Image per Digest | `localhost:5000/handsonlabs/my-web@sha256:...` | exakt dieses Image, unabhängig vom Tag |

Merksatz:

```text
Tag sagt: Nimm, was aktuell unter diesem Namen liegt.
Digest sagt: Nimm exakt diesen Inhalt.
```

---

## RepoDigests prüfen

RepoDigests wurden ausgelesen:

```powershell
docker image inspect localhost:5000/handsonlabs/my-web:v1.2 --format "{{json .RepoDigests}}"
```

Beobachtung:

```text
handsonlabs/my-web@sha256:...
localhost:5000/handsonlabs/my-web@sha256:...
```

Einordnung:

```text
Es gab zwei Digest-Einträge.
Einer ohne Registry-Adresse.
Einer mit localhost:5000.
```

---

## Fehlerfall: falsche Registry-Adresse beim Digest-Pull

Zuerst wurde der erste RepoDigest-Eintrag verwendet:

```powershell
$RepoDigest = docker image inspect localhost:5000/handsonlabs/my-web:v1.2 --format "{{index .RepoDigests 0}}"
```

Dieser Eintrag lautete sinngemäß:

```text
handsonlabs/my-web@sha256:...
```

Beim Pull:

```powershell
docker image pull $RepoDigest
```

kam ein Fehler, weil Docker daraus automatisch Docker Hub machte:

```text
docker.io/handsonlabs/my-web@sha256:... not found
```

Einordnung:

```text
Ohne Registry-Adresse sucht Docker standardmäßig bei Docker Hub.
Das lokale Lab-Image existiert dort nicht.
```

---

## Korrektur: Digest mit Registry-Adresse verwenden

Richtig war der zweite RepoDigest-Eintrag:

```powershell
$RepoDigest = docker image inspect localhost:5000/handsonlabs/my-web:v1.2 --format "{{index .RepoDigests 1}}"
```

Dieser Eintrag enthielt:

```text
localhost:5000/handsonlabs/my-web@sha256:...
```

Pull per Digest:

```powershell
docker image pull $RepoDigest
```

Ergebnis:

```text
Status: Image is up to date for localhost:5000/handsonlabs/my-web@sha256:...
```

Einordnung:

```text
Docker hat exakt dieses Image in der lokalen Registry gefunden.
```

---

## Entscheidender Lernpunkt

```text
Digest allein reicht nicht.
Die Registry-Adresse davor ist entscheidend.
```

Falsch für dieses Lab:

```text
handsonlabs/my-web@sha256:...
```

Bedeutet:

```text
Suche bei Docker Hub.
```

Richtig für dieses Lab:

```text
localhost:5000/handsonlabs/my-web@sha256:...
```

Bedeutet:

```text
Suche in der lokalen Registry auf localhost:5000.
```

---

## Professionelle Einordnung

In professionellen Umgebungen ist das relevant, weil Images aus unterschiedlichen Registries kommen können:

```text
Docker Hub
GitHub Container Registry
Amazon Elastic Container Registry
Azure Container Registry
Google Artifact Registry
private Unternehmens-Registry
```

Wichtig ist immer:

```text
Welche Registry?
Welches Repository?
Welcher Tag?
Welcher Digest?
```

---

## Mustererkennung

```text
Symptom:
docker pull per Digest meldet "not found".

Mögliche Ursache:
Docker sucht in der falschen Registry.

Prüfung:
Steht vor dem Repository eine Registry-Adresse?

Falsch:
handsonlabs/my-web@sha256:...

Richtig für lokale Registry:
localhost:5000/handsonlabs/my-web@sha256:...

Maßnahme:
Digest mit korrekter Registry-Adresse verwenden.

Verifikation:
docker image pull meldet "Image is up to date" oder lädt das Image erfolgreich.
```

---

## Kommunikationsstufe A

```text
Das Image wurde erfolgreich in die lokale Registry gepusht und per Pull sowie Digest-Pull wieder abgerufen. Ein Fehler entstand durch einen Digest ohne Registry-Adresse; mit localhost:5000 funktionierte der Pull korrekt.
```

---

## Kommunikationsstufe B

```text
Für das Web-Image wurde eine lokale Registry auf localhost:5000 genutzt. Das Image handsonlabs/my-web:v1.2 wurde für die Registry getaggt, gepusht und anschließend wieder gepullt. Zusätzlich wurde ein Compose-Test mit einem fertigen Registry-Image durchgeführt. Beim Digest-Test zeigte sich, dass ein Digest ohne Registry-Adresse von Docker als Docker-Hub-Referenz interpretiert wird. Mit localhost:5000/handsonlabs/my-web@sha256:... war der Digest-Pull erfolgreich.
```

---

## Lessons Learned

- Eine Registry ist ein spezialisierter Speicher für Container Images.
- Ein lokaler Build erzeugt ein Image im lokalen Docker Image Store.
- Docker Build Cache ist nicht dasselbe wie der lokale Image Store.
- `docker image tag` baut kein neues Image, sondern vergibt einen zusätzlichen Namen.
- `docker image push` lädt ein Image in eine Registry.
- `docker image pull` lädt ein Image aus einer Registry.
- Compose kann ein fertiges Registry-Image verwenden, ohne selbst zu bauen.
- Ein Tag ist ein lesbarer Name, kann aber später auf anderen Inhalt zeigen.
- Ein Digest ist ein genauer Inhalts-Fingerabdruck.
- Die Registry-Adresse ist entscheidend, damit Docker am richtigen Ort sucht.
