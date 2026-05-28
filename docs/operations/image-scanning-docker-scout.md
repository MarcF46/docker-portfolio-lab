# Image Scanning mit Docker Scout

## Zweck

Dieses Dokument beschreibt den Image-Scanning-Block im Docker Portfolio Lab.

Ziel ist, Container-Images auf bekannte Schwachstellen zu prüfen, Ergebnisse fachlich einzuordnen und daraus eine kontrollierte Verbesserung abzuleiten.

---

## Betriebsfrage

Ein realistischer Auftrag wäre:

```text
Das Web-Image läuft technisch.
Bitte prüfe, ob bekannte Schwachstellen im Image enthalten sind und ob ein sichereres Basis-Image möglich ist.
```

Wichtig:

```text
Image Scanning ist kein Panik-Auslöser.
Es ist ein Bewertungs- und Entscheidungswerkzeug.
```

---

## Tool

Genutzt wurde Docker Scout.

Docker Scout analysiert ein Image und zeigt:

```text
Pakete im Image
bekannte CVEs
Schweregrade
Fix-Verfügbarkeit
Basis-Image-Empfehlungen
```

CVE bedeutet:

```text
Common Vulnerabilities and Exposures
also öffentlich bekannte Schwachstellen.
```

---

## Schweregrade verstehen

Docker Scout zeigt Schwachstellen mit Kürzeln an:

| Kürzel | Bedeutung |
|---|---|
| `C` | Critical / kritisch |
| `H` | High / hoch |
| `M` | Medium / mittel |
| `L` | Low / niedrig |
| `?` | Unspecified / nicht eindeutig bewertet |

Beispiel:

```text
0C  3H  12M  0L  curl 8.17.0-r1
```

Bedeutung:

```text
Das Paket curl hat 0 kritische, 3 hohe, 12 mittlere und 0 niedrige bekannte Schwachstellen.
```

Die Gesamtübersicht summiert die Werte aller betroffenen Pakete im Image.

---

## Ausgangslage: Image v1.2

Gescannt wurde zunächst:

```powershell
docker scout cves handsonlabs/my-web:v1.2
```

Ergebnis:

```text
0C  4H  15M  1L  2?
22 vulnerabilities in 8 packages
88 packages
26 MB
```

Wichtiges Ergebnis:

```text
Die Schwachstellen kamen im Wesentlichen aus dem Basis-Image nginx:alpine,
nicht aus der eigenen HTML-Datei.
```

Vergleich mit:

```powershell
docker scout cves nginx:alpine
```

zeigte praktisch dieselben Werte.

---

## Empfehlungen prüfen

```powershell
docker scout recommendations handsonlabs/my-web:v1.2
```

Docker Scout empfahl zwei Richtungen:

```text
Refresh base image
Change base image
```

### Refresh base image

Bedeutung:

```text
Gleiches Basis-Image nutzen, aber mit aktuellerem Stand neu bauen.
```

Erwartete Verbesserung:

```text
0C  4H  15M  1L  2?
-> 0C  2H   9M  0L
```

### Change base image

Bedeutung:

```text
Auf eine andere Image-Variante wechseln.
```

Empfohlene Variante:

```text
nginx:alpine-slim
```

Erwartete Verbesserung:

```text
0C  0H  1M  0L
```

Grund:

```text
slim enthält deutlich weniger Pakete.
Weniger Pakete bedeuten weniger mögliche Angriffsfläche.
```

---

## Refresh-Test: Image v1.3

Das Image wurde mit frischem Basis-Image neu gebaut:

```powershell
docker build --pull -t handsonlabs/my-web:v1.3 .
```

### Erklärung

| Teil | Bedeutung |
|---|---|
| `docker build` | baut ein neues Image |
| `--pull` | zieht aktiv den neuesten Stand des Basis-Images |
| `-t handsonlabs/my-web:v1.3` | setzt den Image-Tag auf `v1.3` |
| `.` | aktueller Ordner ist der Build-Kontext |

Danach:

```powershell
docker scout cves handsonlabs/my-web:v1.3
```

Ergebnis:

```text
0C  2H  9M  0L
11 vulnerabilities in 4 packages
87 packages
26 MB
```

Bewertung:

```text
Der reine Refresh hat die Schwachstellen deutlich reduziert.
```

---

## Slim-Test: separates Test-Dockerfile

Um das funktionierende Dockerfile nicht sofort zu verändern, wurde eine Testdatei erstellt:

```powershell
Copy-Item .\Dockerfile .\Dockerfile.slim-test

(Get-Content .\Dockerfile.slim-test) -replace '^FROM nginx:alpine$', 'FROM nginx:alpine-slim' |
    Set-Content .\Dockerfile.slim-test -Encoding UTF8
```

### Erklärung

| Befehlsteil | Bedeutung |
|---|---|
| `Copy-Item` | kopiert das bestehende Dockerfile |
| `Dockerfile.slim-test` | separate Testdatei |
| `-replace` | ersetzt nur die Basis-Image-Zeile |
| `Set-Content` | schreibt die geänderte Testdatei zurück |

Testbasis:

```dockerfile
FROM nginx:alpine-slim
```

---

## Slim-Testimage bauen

```powershell
docker build --pull -f .\Dockerfile.slim-test -t handsonlabs/my-web:v1.4-slim-test .
```

### Erklärung

| Teil | Bedeutung |
|---|---|
| `--pull` | zieht aktuelle Basis |
| `-f .\Dockerfile.slim-test` | nutzt die Test-Dockerfile-Datei |
| `-t handsonlabs/my-web:v1.4-slim-test` | erzeugt ein separates Testimage |
| `.` | Projektordner als Build-Kontext |

---

## Slim-Testimage scannen

```powershell
docker scout cves handsonlabs/my-web:v1.4-slim-test
```

Ergebnis:

```text
0C  0H  1M  0L
1 vulnerability in 1 package
26 packages
5.8 MB
```

Bewertung:

```text
Die Slim-Variante reduziert die Angriffsfläche deutlich.
```

---

## Funktionstest der Slim-Variante

Der Testcontainer wurde separat auf Port 8090 gestartet:

```powershell
docker run --rm -d --name my-web-slim-test -p 8090:80 handsonlabs/my-web:v1.4-slim-test
```

### Erklärung

| Teil | Bedeutung |
|---|---|
| `docker run` | startet einen Container |
| `--rm` | löscht ihn automatisch nach dem Stop |
| `-d` | läuft im Hintergrund |
| `--name my-web-slim-test` | eindeutiger Containername |
| `-p 8090:80` | Host-Port 8090 auf Container-Port 80 |
| Image | Slim-Testimage |

Funktionstest:

```powershell
curl.exe -I http://localhost:8090
docker ps --filter name=my-web-slim-test
docker exec my-web-slim-test sh -c 'which wget || true'
```

Ergebnis:

```text
HTTP/1.1 200 OK
Container healthy
/usr/bin/wget
```

Bedeutung:

```text
Webserver funktioniert.
Healthcheck-Werkzeug wget ist vorhanden.
Slim-Variante ist für diesen Anwendungsfall geeignet.
```

Testcontainer stoppen:

```powershell
docker stop my-web-slim-test
```

---

## Vergleich der Images

| Image | Pakete | Größe | Findings |
|---|---:|---:|---:|
| `handsonlabs/my-web:v1.2` | 88 | 26 MB | `0C 4H 15M 1L 2?` |
| `handsonlabs/my-web:v1.3` | 87 | 26 MB | `0C 2H 9M 0L` |
| `handsonlabs/my-web:v1.4-slim-test` | 26 | 5.8 MB | `0C 0H 1M 0L` |

---

## Übernahme ins Projekt

Nach erfolgreichem Test wurde das echte Dockerfile angepasst:

```dockerfile
FROM nginx:alpine-slim
```

Außerdem wurde in `compose.prod.yml` der Image-Tag aktualisiert:

```yaml
image: handsonlabs/my-web:v1.4
```

Das temporäre Test-Dockerfile wurde entfernt:

```powershell
Remove-Item .\Dockerfile.slim-test
```

---

## Wichtige Einordnung

Warum wurde nicht sofort blind gewechselt?

```text
Slim-Images enthalten weniger Pakete.
Das ist sicherheitlich oft gut.
Aber fehlende Pakete können Funktionen, Debugging oder Healthchecks brechen.
```

Deshalb wurde geprüft:

```text
Build erfolgreich?
Scan besser?
Webserver erreichbar?
Container healthy?
Healthcheck-Werkzeug vorhanden?
```

Erst danach wurde die Änderung übernommen.

---

## Typische berufliche Bewertung

Ein professioneller Kommentar könnte lauten:

```text
Das Web-Image wurde mit Docker Scout geprüft.
Die ursprünglichen Findings kamen überwiegend aus dem Basis-Image.
Durch Aktualisierung und Wechsel auf nginx:alpine-slim konnte die Zahl der Findings deutlich reduziert werden.
Die Funktion wurde anschließend per HTTP-Test, Containerstatus und Healthcheck-Abhängigkeit verifiziert.
```

---

## Lab vs. Produktion

| Thema | Lab | Produktion |
|---|---|---|
| Scan | lokal mit Docker Scout | automatisiert in CI/CD |
| Bewertung | manuell | definierter Vulnerability-Prozess |
| Entscheidung | Image-Wechsel nach Funktionstest | Risikoanalyse, Freigabe, Rollback-Plan |
| Fix | Basis-Image aktualisieren | Patch-Management und SLA |
| Dokumentation | Markdown-Doku | Security-Ticket, Change, Audit Trail |

---

## Fazit

Der Image-Scanning-Block zeigt drei wichtige Betriebsprinzipien:

```text
Images müssen regelmäßig gescannt werden.
Findings müssen bewertet und nicht blind übernommen werden.
Kleinere Basis-Images können die Angriffsfläche deutlich reduzieren,
müssen aber funktional getestet werden.
```

Das Projekt nutzt nun ein schlankeres NGINX-Basis-Image und hat die Schwachstellenanzahl im Web-Image deutlich reduziert.
