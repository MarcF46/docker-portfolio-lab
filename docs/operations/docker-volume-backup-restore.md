# Docker Volume Backup und Restore

## Zweck

Dieses Runbook dokumentiert einen einfachen, nachvollziehbaren Backup- und Restore-Ablauf für ein Docker Named Volume.

Ziel ist nicht nur, eine Backup-Datei zu erzeugen, sondern den Restore praktisch zu testen.

Wichtiger Betriebsgrundsatz:

> Ein Backup ist erst dann vertrauenswürdig, wenn ein Restore erfolgreich getestet wurde.

---

## Ausgangssituation

In der Übung wurde ein Docker Volume verwendet:

```text
dockerbung_data_test
```

In dieses Volume wurde eine Testdatei geschrieben:

```text
/data/test.txt
```

Inhalt:

```text
Hallo Volume
```

---

## Grundbegriffe

| Begriff | Bedeutung |
|---|---|
| Container | Laufende oder gestoppte Instanz eines Images |
| Image | Vorlage, aus der Container gestartet werden |
| Volume | Von Docker verwalteter persistenter Speicher |
| Named Volume | Volume mit bewusst vergebenem Namen |
| Anonymous Volume | Volume ohne eigenen Namen; Docker vergibt eine lange ID |
| Bind Mount | Direkter Host-Ordner wird in einen Container eingebunden |
| Backup | Sicherung von Daten |
| Restore | Wiederherstellung von Daten |
| TAR | Archivformat zum Bündeln von Dateien |
| gzip | Komprimierungsverfahren |

---

## Wichtige Erkenntnis

Container sind austauschbar.

Daten, die erhalten bleiben sollen, müssen außerhalb des kurzlebigen Containers gespeichert werden, zum Beispiel in einem Docker Volume.

Ein Image-Backup ersetzt kein Volume-Backup.

---

## 1. Volume erstellen

```powershell
docker volume create dockerbung_data_test
```

Erwartete Ausgabe:

```text
dockerbung_data_test
```

Bedeutung:

Docker erstellt ein benanntes Volume.

---

## 2. Testdaten in das Volume schreiben

```powershell
docker run --rm -v dockerbung_data_test:/data alpine sh -c "echo Hallo Volume > /data/test.txt"
```

Erklärung:

| Teil | Bedeutung |
|---|---|
| `docker run` | startet einen neuen Container |
| `--rm` | entfernt den Container automatisch nach Ende |
| `-v dockerbung_data_test:/data` | bindet das Volume im Container unter `/data` ein |
| `alpine` | kleines Linux-Image |
| `sh -c` | führt einen Shell-Befehl aus |
| `echo Hallo Volume > /data/test.txt` | schreibt eine Testdatei in das Volume |

---

## 3. Daten im Volume prüfen

```powershell
docker run --rm -v dockerbung_data_test:/data alpine cat /data/test.txt
```

Erwartete Ausgabe:

```text
Hallo Volume
```

Bedeutung:

Ein neuer Container kann die Daten aus dem Volume lesen. Das zeigt, dass die Daten nicht nur im alten Container lagen.

---

## 4. Backup-Ordner außerhalb des Repositories erstellen

```powershell
New-Item -ItemType Directory -Path "C:\Docker-Backups\volume-lab" -Force
```

Erklärung:

| Teil | Bedeutung |
|---|---|
| `New-Item` | erstellt ein neues Objekt |
| `-ItemType Directory` | erstellt einen Ordner |
| `-Path` | Zielpfad |
| `-Force` | kein Fehler, wenn der Ordner bereits existiert |

Hinweis:

Der Backup-Ordner liegt bewusst außerhalb des Git-Repositories, weil Backups echte Daten, Secrets oder personenbezogene Daten enthalten können.

---

## 5. Backup aus dem Volume erstellen

```powershell
docker run --rm -v dockerbung_data_test:/data -v "C:\Docker-Backups\volume-lab:/backup" alpine tar -czf /backup/dockerbung_data_test.tar.gz -C /data .
```

Erklärung:

| Teil | Bedeutung |
|---|---|
| `docker run --rm` | startet einen Hilfscontainer und löscht ihn danach |
| `-v dockerbung_data_test:/data` | bindet das Docker Volume unter `/data` ein |
| `-v "C:\Docker-Backups\volume-lab:/backup"` | bindet den Windows-Backup-Ordner unter `/backup` ein |
| `alpine` | kleines Linux-Image |
| `tar -czf` | erstellt ein gzip-komprimiertes TAR-Archiv |
| `/backup/dockerbung_data_test.tar.gz` | Ziel-Datei des Backups |
| `-C /data .` | wechselt nach `/data` und archiviert den Inhalt |

### Bedeutung von `tar -czf`

| Option | Bedeutung |
|---|---|
| `-c` | create: Archiv erstellen |
| `-z` | gzip: Archiv komprimieren |
| `-f` | file: danach folgt der Dateiname |

---

## 6. Backup-Datei prüfen

```powershell
Get-ChildItem "C:\Docker-Backups\volume-lab"
```

Erwartung:

```text
dockerbung_data_test.tar.gz
```

Bedeutung:

Die Backup-Datei wurde im Windows-Ordner erstellt.

---

## 7. Inhalt des Backups prüfen

```powershell
docker run --rm -v "C:\Docker-Backups\volume-lab:/backup" alpine tar -tzf /backup/dockerbung_data_test.tar.gz
```

Erwartete Ausgabe:

```text
./
./test.txt
```

### Bedeutung von `tar -tzf`

| Option | Bedeutung |
|---|---|
| `-t` | table/list: Archivinhalt anzeigen |
| `-z` | gzip-komprimiertes Archiv lesen |
| `-f` | danach folgt der Dateiname |

Bedeutung:

Das Backup ist nicht nur vorhanden, sondern auch lesbar und enthält die erwartete Datei.

---

## 8. Datenverlust simulieren

```powershell
docker volume rm dockerbung_data_test
```

Erwartete Ausgabe:

```text
dockerbung_data_test
```

Bedeutung:

Das ursprüngliche Test-Volume wurde gelöscht.

Wichtig:

Nur gezielt das Test-Volume löschen. Produktive Volumes wie Redis, Prometheus oder Grafana dürfen nicht versehentlich entfernt werden.

---

## 9. Prüfen, ob das Volume entfernt wurde

```powershell
docker volume ls
```

Erwartung:

```text
dockerbung_data_test
```

sollte nicht mehr in der Liste erscheinen.

---

## 10. Neues Restore-Volume erstellen

```powershell
docker volume create dockerbung_data_test_restore
```

Erwartete Ausgabe:

```text
dockerbung_data_test_restore
```

Bedeutung:

Der Restore wird bewusst in ein separates Test-Volume durchgeführt.

Das ist sicherer als ein direkter Restore in ein produktives Volume.

---

## 11. Backup in Restore-Volume zurückspielen

```powershell
docker run --rm -v dockerbung_data_test_restore:/data -v "C:\Docker-Backups\volume-lab:/backup" alpine sh -c "cd /data && tar -xzf /backup/dockerbung_data_test.tar.gz"
```

Erklärung:

| Teil | Bedeutung |
|---|---|
| `dockerbung_data_test_restore:/data` | bindet das Restore-Volume unter `/data` ein |
| `C:\Docker-Backups\volume-lab:/backup` | bindet den Backup-Ordner unter `/backup` ein |
| `sh -c` | führt mehrere Shell-Befehle aus |
| `cd /data` | wechselt in das Zielverzeichnis |
| `&&` | nächster Befehl läuft nur, wenn der vorherige erfolgreich war |
| `tar -xzf` | entpackt das Backup |

### Bedeutung von `tar -xzf`

| Option | Bedeutung |
|---|---|
| `-x` | extract: Archiv entpacken |
| `-z` | gzip-komprimiertes Archiv verwenden |
| `-f` | danach folgt der Dateiname |

---

## 12. Restore beweisen

```powershell
docker run --rm -v dockerbung_data_test_restore:/data alpine cat /data/test.txt
```

Erwartete Ausgabe:

```text
Hallo Volume
```

Bedeutung:

Der Restore war erfolgreich. Die Datei aus dem gelöschten Original-Volume wurde aus dem Backup wiederhergestellt.

---

## Ergebnisbewertung

| Prüfschritt | Ergebnis |
|---|---|
| Volume erstellt | erfolgreich |
| Testdaten geschrieben | erfolgreich |
| Backup-Datei erstellt | erfolgreich |
| Backup-Inhalt geprüft | erfolgreich |
| Original-Volume gelöscht | erfolgreich |
| Restore-Volume erstellt | erfolgreich |
| Backup zurückgespielt | erfolgreich |
| Restore verifiziert | erfolgreich |

---

## Betriebsbewertung

Dieser Ablauf ist für ein Lernlabor sehr gut geeignet.

Für produktive Systeme muss zusätzlich beachtet werden:

| Thema | Produktionshinweis |
|---|---|
| Konsistenz | Datenbankdienste vor Dateibackup sauber stoppen oder datenbankspezifische Backup-Tools nutzen |
| Automatisierung | Backups geplant und überwacht ausführen |
| Rotation | alte Backups kontrolliert aufbewahren und löschen |
| Verschlüsselung | Backups mit sensiblen Daten verschlüsseln |
| Zugriffsschutz | Backup-Ordner und Backup-Ziele schützen |
| Offsite-Backup | Backups nicht nur auf demselben System speichern |
| Restore-Test | regelmäßig Wiederherstellung testen |
| Dokumentation | Ablauf, Zeitpunkte, Ergebnis und Verantwortlichkeit dokumentieren |

---

## Typische Fehlerquellen

| Fehler | Auswirkung |
|---|---|
| Nur Container oder Image sichern | Volume-Daten fehlen |
| Backup nie testen | Restore kann im Ernstfall scheitern |
| Falsches Volume sichern | Backup enthält nicht die benötigten Daten |
| Backup ins Repository legen | Risiko für Daten- oder Secret-Leaks |
| Produktives Volume direkt überschreiben | Risiko für weiteren Datenverlust |
| Kein Restore-Protokoll führen | Nachvollziehbarkeit fehlt |

---

## Kurzkommunikation

### Stufe A: ultrakurze Statusmeldung

```text
Volume-Backup wurde erstellt, Archivinhalt geprüft und Restore in separates Test-Volume erfolgreich verifiziert.
```

### Stufe B: kurzer Ticket-Kommentar

```text
Backup des Docker Volumes wurde als TAR.GZ-Archiv erstellt und anschließend geprüft. Zur Verifikation wurde das Original-Test-Volume entfernt, ein neues Restore-Volume angelegt und das Backup erfolgreich zurückgespielt. Die Testdatei konnte danach mit erwartetem Inhalt gelesen werden.
```

---

## Quellen und Einordnung

- Docker Dokumentation: Volumes können unabhängig von Containern erstellt und verwaltet werden.
- Docker Dokumentation: Named Volumes und Compose Volumes sind persistente Datenspeicher.
- Docker Dokumentation: Volume-Daten sind nicht automatisch Teil eines Images und müssen separat gesichert werden.
- Docker Dokumentation: `docker volume prune` entfernt standardmäßig ungenutzte anonyme Volumes.

Dieses Runbook ist ein Lern- und Laborprozess. Für echte Produktionsdaten müssen zusätzlich Applikationskonsistenz, Backup-Rotation, Zugriffsschutz, Verschlüsselung, Monitoring und regelmäßige Restore-Tests geplant werden.
