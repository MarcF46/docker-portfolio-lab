# Troubleshooting: Docker Backup und Restore

## Ziel dieses Dokuments

Dieses Dokument sammelt typische Fehlerbilder, die bei Docker-Volume-Backups, Restore-Tests, Redis-Prüfungen und lokaler Protokollierung auftreten können.

Es geht nicht nur darum, dass ein Skript funktioniert. Es geht darum, echte Betriebsfragen beantworten zu können:

```text
Welche Fehlermeldung sehe ich?
Was bedeutet sie wahrscheinlich?
Wie kritisch ist der Fehler?
Welche Prüfung mache ich als Nächstes?
Wie löse ich das Problem sicher?
Wie dokumentiere ich das Ergebnis?
```

Dieses Dokument dient als Runbook. Ein Runbook ist eine praktische Betriebsanleitung für wiederkehrende technische Situationen.

---

## Wichtige Einordnung

Dieses Dokument ist keine mathematische Wahrscheinlichkeitsliste.

Eine allgemeingültige Statistik nach dem Motto „Fehler A tritt zu 37 Prozent auf“ gibt es für lokale Docker-, Redis- und Backup-Umgebungen normalerweise nicht zuverlässig.

Die Häufigkeit hängt stark ab von:

```text
Betriebssystem
Docker Desktop oder Linux Server
lokale Umgebung oder Cloud
Speicherort der Backups
Team-Erfahrung
CI/CD-Umgebung
Sicherheitsvorgaben
Netzwerk
Storage-System
```

Deshalb nutzt dieses Dokument eine Praxis-Priorisierung:

```text
sehr häufig
häufig
gelegentlich
selten, aber kritisch
```

Diese Einordnung ist eine Lern- und Betriebshilfe, keine exakte Statistik.

---

## Grundregel für Backup-Fehler

Bei Backup- und Restore-Prozessen gilt:

```text
Nicht sofort reparieren.
Erst verstehen.
Dann Risiko bewerten.
Dann sicher handeln.
Dann dokumentieren.
```

Besonders gefährlich sind schnelle Reaktionen wie:

```text
Volume löschen
Backup überschreiben
Container neu erstellen
Datenbank neu initialisieren
alte Dateien blind entfernen
```

Solche Aktionen können Datenverlust verursachen, wenn noch nicht klar ist, was genau passiert ist.

---

## Schneller Diagnoseablauf

Wenn ein Backup- oder Restore-Prozess fehlschlägt, ist ein sinnvoller erster Ablauf:

```text
1. Fehlermeldung vollständig lesen
2. Zeitpunkt notieren
3. Logdatei prüfen
4. Docker-Status prüfen
5. Volume-Liste prüfen
6. Backup-Ordner prüfen
7. Backup-Archiv prüfen
8. Restore-Test-Volume prüfen
9. Redis-Wert prüfen
10. Ergebnis dokumentieren
```

Wichtige Befehle:

```powershell
docker ps -a
docker volume ls
docker volume inspect dockerbung_redis_data_prod
dir backups
Get-Content .\logs\backup-restore.log
```

---

## Troubleshooting-Matrix

| Fehlerklasse | Praxis-Häufigkeit | Risiko | Erste Prüfung |
|---|---|---|---|
| Docker läuft nicht | häufig lokal | mittel | `docker ps` |
| Volume existiert nicht | häufig | hoch | `docker volume ls` |
| Backup-Ordner fehlt | sehr häufig lokal | mittel | `dir backups` |
| Backup-Datei beschädigt | gelegentlich | sehr hoch | `tar tzf` |
| Speicherplatz voll | häufig im Betrieb | hoch | `Get-PSDrive`, `docker system df` |
| Redis-Passwort falsch | häufig bei Secrets | mittel | Redis `PING` mit Secret |
| Restore-Container startet nicht | häufig | mittel | `docker ps -a` |
| Volume ist in Benutzung | gelegentlich | hoch | `docker ps -a` |
| Restore fachlich falsch | gelegentlich | sehr hoch | Redis `GET training_status` |
| Logdatei kann nicht geschrieben werden | gelegentlich | mittel | `dir logs` |
| PowerShell fängt Fehler nicht ab | häufig bei externen Tools | hoch | `$LASTEXITCODE`, `$?` |
| Falsches Arbeitsverzeichnis | sehr häufig bei Anfängern | niedrig bis mittel | `pwd`, `dir` |

---

## Fehlerklasse 1: Docker läuft nicht

### Typische Fehlermeldungen

```text
Cannot connect to the Docker daemon
docker daemon is not running
error during connect
```

### Wahrscheinliche Ursache

Docker Desktop oder die Docker Engine läuft nicht. Das Skript kann dadurch keine Container starten, keine Volumes einhängen und keine Backup-Container ausführen.

### Praxis-Häufigkeit

```text
häufig in lokalen Lern- und Entwicklungsumgebungen
gelegentlich auf Servern nach Neustarts oder Docker-Problemen
```

### Erste Prüfung

```powershell
docker version
docker ps
```

### Mögliche Lösung

```text
Docker Desktop starten
Docker Engine prüfen
System neu starten, falls Docker hängt
danach docker ps erneut testen
```

### Risiko

```text
Backup kann nicht erstellt werden.
Restore-Test kann nicht durchgeführt werden.
Es wurden aber noch keine Docker-Volume-Daten verändert.
```

---

## Fehlerklasse 2: Docker Volume existiert nicht

### Typische Fehlermeldung

```text
Error response from daemon: get dockerbung_redis_data_prod: no such volume
no such volume
```

### Wahrscheinliche Ursache

Das erwartete Docker Volume wurde nicht gefunden.

Mögliche Gründe:

```text
Volume-Name falsch geschrieben
falsches Compose-Projekt
dev/prod verwechselt
Volume wurde gelöscht
Docker Desktop nutzt anderen Kontext
Compose-Projektname hat sich geändert
```

### Praxis-Häufigkeit

```text
häufig bei Docker Compose und Lernumgebungen
häufig nach Umbenennungen von Projekten oder Compose-Dateien
```

### Erste Prüfung

```powershell
docker volume ls
docker volume inspect dockerbung_redis_data_prod
```

### Mögliche Lösung

```text
korrekten Volume-Namen ermitteln
Compose-Konfiguration prüfen
Projektname prüfen
nicht blind ein neues Volume erzeugen, bevor klar ist, ob alte Daten noch existieren
```

### Risiko

```text
Wenn versehentlich ein neues leeres Volume verwendet wird, können Anwendungen scheinbar starten, aber ohne die erwarteten Daten.
```

### Merksatz

```text
Ein leerer Start ist nicht automatisch ein erfolgreicher Restore.
```

---

## Fehlerklasse 3: Backup-Ordner fehlt oder Pfad ist falsch

### Typische Fehlermeldungen

```text
Cannot find path
No such file or directory
tar: can't open
```

### Wahrscheinliche Ursache

Der lokale Ordner `backups/` existiert nicht oder wurde falsch in den temporären Backup-Container eingebunden.

Typische Ursachen unter Windows:

```text
Leerzeichen im Pfad
falsche Anführungszeichen
falsches Arbeitsverzeichnis
PowerShell-Zeilenumbruch falsch gesetzt
Backup-Ordner wurde gelöscht
```

### Praxis-Häufigkeit

```text
sehr häufig in lokalen Windows-/PowerShell-Umgebungen
```

### Erste Prüfung

```powershell
pwd
dir backups
```

### Mögliche Lösung

```powershell
New-Item -ItemType Directory -Path backups -Force
```

### Risiko

```text
Backup wird nicht geschrieben.
Wenn das Skript diesen Fehler nicht erkennt, glaubt man eventuell fälschlich, ein Backup sei vorhanden.
```

---

## Fehlerklasse 4: Backup-Datei ist leer oder beschädigt

### Typische Fehlermeldungen

```text
Dateigröße: 0 Bytes
tar: unexpected EOF
gzip: stdin: unexpected end of file
```

### Wahrscheinliche Ursache

Die Backup-Datei wurde zwar erzeugt, ist aber nicht brauchbar.

Mögliche Gründe:

```text
Backup-Prozess wurde abgebrochen
Speicherplatz voll
Volume war leer
tar konnte nicht vollständig schreiben
Datei wurde beschädigt
```

### Praxis-Häufigkeit

```text
gelegentlich
kritisch, wenn Backups nicht geprüft werden
```

### Erste Prüfung

```powershell
dir backups
```

Danach Archivinhalt prüfen:

```powershell
docker run --rm `
  -v "${PWD}/backups:/backup" `
  alpine `
  tar tzf /backup/redis_data_prod_backup.tar.gz
```

### Mögliche Lösung

```text
Backup neu erstellen
Speicherplatz prüfen
Archiv erneut prüfen
Restore-Test durchführen
beschädigte Datei nicht als gültiges Backup verwenden
```

### Risiko

```text
Sehr hoch, wenn der Fehler erst im Ernstfall auffällt.
```

### Merksatz

```text
Eine vorhandene Datei ist noch kein brauchbares Backup.
```

---

## Fehlerklasse 5: Speicherplatz voll

### Typische Fehlermeldungen

```text
no space left on device
write error
failed to copy
not enough space
```

### Wahrscheinliche Ursache

Das Backup kann nicht vollständig geschrieben werden, weil ein Speicherbereich voll ist.

Mögliche betroffene Bereiche:

```text
lokaler Backup-Ordner
Docker Desktop Speicherbereich
WSL2-Disk
Server-Dateisystem
NAS oder Backup-Ziel
temporärer Docker-Speicher
```

### Praxis-Häufigkeit

```text
häufig in realen Betriebsumgebungen
häufig bei fehlender Retention Policy
```

### Erste Prüfung

```powershell
Get-PSDrive
docker system df
dir backups
```

### Mögliche Lösung

```text
alte lokale Testbackups prüfen
Retention Policy anwenden
nicht benötigte Docker-Images und Container prüfen
Backup-Ziel erweitern
Speicherplatz-Monitoring ergänzen
```

Wichtig:

```text
Nicht blind docker system prune ausführen.
Erst prüfen, was gelöscht würde.
```

### Risiko

```text
Backup-Datei kann unvollständig sein.
Der Prozess kann scheinbar teilweise funktioniert haben.
Restore-Test ist danach Pflicht.
```

---

## Fehlerklasse 6: Redis-Passwort falsch

### Typische Fehlermeldungen

```text
WRONGPASS invalid username-password pair or user is disabled
NOAUTH Authentication required
```

### Wahrscheinliche Ursache

Redis läuft, aber die Authentifizierung ist falsch oder fehlt.

Mögliche Gründe:

```text
falsches Passwort im Skript
Secret-Datei wurde geändert
dev/prod verwechselt
Secret falsch eingespielt
Redis-Konfiguration geändert
Passwort im Container und Prüfskript stimmen nicht überein
```

### Praxis-Häufigkeit

```text
häufig bei Umgebungsvariablen, Secrets und getrennten dev/prod-Konfigurationen
```

### Erste Prüfung

Das Passwort soll nicht als Klartextargument mit `redis-cli -a ...` im Terminal erscheinen. Im Projekt wird es aus der Secret-Datei im Container gelesen:

```powershell
docker exec dockerbung-redis-1 sh -c 'export REDISCLI_AUTH=$(cat /run/secrets/redis_password); redis-cli PING'
```

Erwartung:

```text
PONG
```

### Mögliche Lösung

```text
Secret-Datei prüfen
Compose-Secrets prüfen
compose.dev.yml und compose.prod.yml vergleichen
Skripte auf hart codierte Werte prüfen
Secret-Handling vereinheitlichen
```

### Risiko

```text
Backup kann technisch vorhanden sein, aber Restore-Prüfung schlägt fehl.
Ohne korrekte Authentifizierung kann nicht geprüft werden, ob die erwarteten Daten vorhanden sind.
```

---

## Fehlerklasse 7: Restore-Testcontainer startet nicht

### Typische Fehlermeldungen

```text
Conflict. The container name "/redis-restore-test" is already in use
No such image: redis:alpine
port is already allocated
```

### Wahrscheinliche Ursache

Der Testcontainer kann nicht gestartet werden.

Mögliche Gründe:

```text
alter Testcontainer existiert noch
Image fehlt und kann nicht geladen werden
Port ist belegt
Docker hat keinen Netzwerkzugriff
Containername ist bereits vergeben
```

### Praxis-Häufigkeit

```text
häufig in lokalen Testumgebungen
gelegentlich in CI/CD-Pipelines
```

### Erste Prüfung

```powershell
docker ps -a
docker images
```

### Mögliche Lösung

Nur für den Restore-Testcontainer:

```powershell
docker rm -f redis-restore-test
```

Falls das Image fehlt:

```powershell
docker pull redis:alpine
```

### Risiko

```text
Restore-Test kann nicht durchgeführt werden.
Das Backup darf dadurch nicht automatisch als gültig betrachtet werden.
```

---

## Fehlerklasse 8: Restore-Volume ist in Benutzung

### Typische Fehlermeldung

```text
volume is in use
remove dockerbung_redis_data_restore_test: volume is in use
```

### Wahrscheinliche Ursache

Ein Container verwendet das Restore-Test-Volume noch.

### Praxis-Häufigkeit

```text
gelegentlich
häufig nach abgebrochenen Tests
```

### Erste Prüfung

```powershell
docker ps -a
docker volume ls
```

### Mögliche Lösung

Nur für Testressourcen:

```powershell
docker rm -f redis-restore-test
docker volume rm dockerbung_redis_data_restore_test
```

Wichtig:

```text
Nur Restore-Test-Volumes löschen.
Produktions-Volumes nicht blind löschen.
```

### Risiko

```text
Bei falschem Volume-Namen kann Datenverlust entstehen.
```

---

## Fehlerklasse 9: Restore fachlich fehlgeschlagen

### Typische Symptome

```text
Redis startet
Restore-Testcontainer läuft
GET training_status liefert nil
erwarteter Wert fehlt
falscher Wert wird gelesen
```

### Wahrscheinliche Ursache

Der Restore war technisch möglich, aber der Dateninhalt entspricht nicht der Erwartung.

Mögliche Gründe:

```text
falsches Volume gesichert
falsches Backup verwendet
Testwert wurde nie geschrieben
Backup-Zeitpunkt war falsch
Redis-Persistenz war nicht aktiv
falsche Umgebung wurde getestet
```

### Praxis-Häufigkeit

```text
gelegentlich
besonders gefährlich, weil es auf den ersten Blick erfolgreich wirken kann
```

### Erste Prüfung

Das Passwort soll auch hier nicht als Klartextargument erscheinen:

```powershell
docker exec redis-restore-test sh -c 'export REDISCLI_AUTH=$(cat /run/secrets/redis_password); redis-cli GET training_status'
```

Zusätzlich:

```powershell
docker volume inspect dockerbung_redis_data_prod
docker volume inspect dockerbung_redis_data_restore_test
dir backups
```

### Mögliche Lösung

```text
korrekte Backup-Datei identifizieren
Zeitpunkt prüfen
Volume-Namen prüfen
Testdaten erneut schreiben
Backup erneut erstellen
Restore-Test erneut durchführen
```

### Risiko

```text
Sehr hoch.
Ein technisch erfolgreicher Restore ist wertlos, wenn die fachlich erwarteten Daten fehlen.
```

### Merksatz

```text
Restore erfolgreich heißt nicht nur: Container startet.
Restore erfolgreich heißt: erwartete Daten sind wieder vorhanden.
```

---

## Fehlerklasse 10: Logdatei kann nicht geschrieben werden

### Typische Fehlermeldungen

```text
Access to the path is denied
Cannot find path
UnauthorizedAccessException
```

### Wahrscheinliche Ursache

Das Skript kann nicht in den Ordner `logs/` oder die Datei `logs/backup-restore.log` schreiben.

Mögliche Gründe:

```text
Ordner fehlt
Datei ist gesperrt
fehlende Schreibrechte
Antivirus blockiert Zugriff
Pfad falsch
Datei ist schreibgeschützt
```

### Praxis-Häufigkeit

```text
gelegentlich
häufiger in eingeschränkten Unternehmensumgebungen
```

### Erste Prüfung

```powershell
dir logs
Get-Item .\logs\backup-restore.log
```

Testweise schreiben:

```powershell
Add-Content -Path .\logs\backup-restore.log -Value "test"
```

### Mögliche Lösung

```text
logs-Ordner neu erstellen
Schreibrechte prüfen
Datei schließen, falls sie in einem Editor gesperrt ist
Pfad im Skript prüfen
```

### Risiko

```text
Backup kann eventuell funktionieren, aber es gibt keinen Betriebsnachweis.
Fehler sind später schwer nachvollziehbar.
```

---

## Fehlerklasse 11: PowerShell-Fehler wird nicht abgefangen

### Typisches Verhalten

```text
Fehler erscheint rot im Terminal
Skript läuft trotzdem weiter
Log enthält keinen ERROR-Eintrag
$LASTEXITCODE wird nicht geprüft
```

### Wahrscheinliche Ursache

Nicht jeder externe Befehl erzeugt automatisch einen PowerShell-Fehler, der von `try/catch` abgefangen wird. Docker, Redis CLI oder TAR können mit Exitcodes arbeiten.

### Praxis-Häufigkeit

```text
häufig bei Skripten, die externe Programme starten
```

### Erste Prüfung

```powershell
$LASTEXITCODE
$?
```

### Mögliche Lösung

```text
nach externen Befehlen $LASTEXITCODE prüfen
bei Fehler explizit throw verwenden
Fehler mit try/catch protokollieren
```

### Risiko

```text
Skript meldet Erfolg, obwohl ein Teilbefehl fehlgeschlagen ist.
```

### Merksatz

```text
Ein Skript ist erst robust, wenn es Fehler nicht nur anzeigt, sondern korrekt bewertet.
```

---

## Fehlerklasse 12: Falsches Arbeitsverzeichnis

### Typische Fehlermeldungen

```text
The argument '.\scripts\backup\backup-and-test-redis.ps1' is not recognized
Cannot find path '.\scripts\...'
dir backups zeigt nichts
```

### Wahrscheinliche Ursache

Der Befehl wurde nicht aus dem Projektordner gestartet.

### Praxis-Häufigkeit

```text
sehr häufig bei Anfängern
häufig nach Neustart von VS Code oder Terminal
```

### Erste Prüfung

```powershell
pwd
dir
```

Erwarteter Projektordner:

```text
C:\Docker Übung
```

### Mögliche Lösung

```powershell
cd "C:\Docker Übung"
```

Dann Befehl erneut starten.

### Risiko

```text
Skript findet Dateien nicht oder schreibt Backups/Logs an unerwartete Orte.
```

---

## Realistische Logeinträge

Gute Logeinträge sollten nicht nur sagen:

```text
ERROR
```

Sondern möglichst auch:

```text
Was ist fehlgeschlagen?
Welche Datei oder welches Volume war betroffen?
Was war der nächste sinnvolle Prüfpunkt?
```

Beispiele:

```text
2026-05-15 22:14:03 | ERROR | Backup fehlgeschlagen: Docker Volume dockerbung_redis_data_prod wurde nicht gefunden.
2026-05-15 22:14:03 | ERROR | Naechste Pruefung: docker volume ls und docker volume inspect ausfuehren.
```

```text
2026-05-15 22:18:40 | ERROR | Restore-Test fehlgeschlagen: Redis-Wert training_status konnte nicht gelesen werden.
2026-05-15 22:18:40 | ERROR | Erwartet: volume-test-erfolgreich | Erhalten: nil
```

```text
2026-05-15 22:21:11 | ERROR | Backup-Archiv konnte nicht gelesen werden: tar meldet unexpected EOF.
2026-05-15 22:21:11 | ERROR | Backup-Datei gilt als nicht vertrauenswuerdig und darf nicht fuer Restore verwendet werden.
```

---

## Sichere Labor-Reproduktion

Für das Training sollen Fehler nur dann nachgestellt werden, wenn sie keine produktiven Daten gefährden.

Geeignete sichere Fehlerübungen:

```text
falscher erwarteter Redis-Wert
nicht vorhandener Testcontainer
nicht vorhandenes Test-Volume
temporär umbenannter Backup-Ordner
falscher Pfad zu einer Kopie
falsches Passwort in einer Testumgebung
```

Nicht geeignet für Anfängerübungen ohne Schutz:

```text
Produktionsvolume löschen
echte Backups überschreiben
echte Secrets absichtlich veröffentlichen
Live-Datenbank beschädigen
```

---

## Diagnose-Routine für dieses Projekt

Bei Fehlern in diesem Docker-Lab zuerst ausführen:

```powershell
git status -uall
docker ps -a
docker volume ls
dir backups
dir logs
Get-Content .\logs\backup-restore.log
```

Danach je nach Fehler:

```powershell
docker volume inspect dockerbung_redis_data_prod
docker volume inspect dockerbung_redis_data_restore_test
docker compose -f compose.prod.yml ps
```

Redis prüfen:

```powershell
docker exec dockerbung-redis-1 sh -c 'export REDISCLI_AUTH=$(cat /run/secrets/redis_password); redis-cli GET training_status'
```

Backup-Archiv prüfen:

```powershell
docker run --rm `
  -v "${PWD}/backups:/backup" `
  alpine `
  tar tzf /backup/redis_data_prod_backup.tar.gz
```

---

## Dokumentationsschema für Fehlerfälle

Wenn ein Fehler auftritt, sollte er so dokumentiert werden:

```text
Datum/Uhrzeit:
Betroffener Prozess:
Befehl:
Fehlermeldung:
Vermutete Ursache:
Erste Prüfung:
Ergebnis der Prüfung:
Risiko:
Lösung:
Restore-Test durchgeführt:
Ergebnis:
Nächste Verbesserung:
```

Beispiel:

```text
Datum/Uhrzeit: 2026-05-15 22:18
Betroffener Prozess: Redis Restore-Test
Befehl: powershell -ExecutionPolicy Bypass -File .\scripts\backup\backup-and-test-redis.ps1
Fehlermeldung: GET training_status liefert nil
Vermutete Ursache: falsches Backup oder falsches Volume
Erste Prüfung: docker volume ls, dir backups, Redis GET
Ergebnis der Prüfung: Backup war technisch lesbar, aber falscher Datenstand
Risiko: Restore wäre fachlich unbrauchbar
Lösung: korrektes Backup identifizieren und Restore-Test wiederholen
Restore-Test durchgeführt: ja
Ergebnis: erfolgreich nach Verwendung der korrekten Datei
Nächste Verbesserung: Backup-Dateinamen und erwarteten Datenstand besser dokumentieren
```

---

## Quellenbasis und Einordnung

Dieses Dokument orientiert sich an folgenden Quellenarten:

```text
offizielle Docker-Dokumentation zu Volumes, Backup, Restore und Migration
offizielle Microsoft-Dokumentation zu PowerShell try/catch/finally
offizielle Redis-Dokumentation zu Persistenz mit RDB und AOF
praxisnahe Betriebsprinzipien aus Backup, Restore, Logging und Incident Response
```

Fremde Skripte oder Community-Beispiele sollten nie blind übernommen werden.

Stattdessen gilt:

```text
erst verstehen
gegen offizielle Dokumentation prüfen
Risiken bewerten
Dry-Run oder Testumgebung nutzen
Restore- oder Rollback-Möglichkeit sicherstellen
dokumentieren
```

---

## Praxis-Fazit

Ein guter Backup-und-Restore-Prozess besteht nicht nur aus einem erfolgreichen Befehl.

Er besteht aus:

```text
funktionierendem Backup
technischer Archivprüfung
erfolgreichem Restore-Test
fachlicher Datenprüfung
Logging
Retention Policy
Troubleshooting-Dokumentation
sicherer Fehlerdiagnose
```

Der wichtigste Merksatz:

```text
Ein Backup-Prozess ist erst dann betrieblich wertvoll, wenn auch seine Fehlerfälle verstanden, sichtbar und sicher diagnostizierbar sind.
```
