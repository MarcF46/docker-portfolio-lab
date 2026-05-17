# Backup-Strategie: GFS, 3-2-1 und Docker-Volumes

## Ziel dieses Dokuments

Dieses Dokument erklärt, wie eine einfache Backup-Retention-Policy aus dem Lernprojekt später in Richtung einer professionelleren Backup-Strategie erweitert werden kann.

Im Projekt wurde bereits umgesetzt:

```text
Backup erstellen
Backup-Datei technisch prüfen
Restore-Test durchführen
Retention Policy mit Dry-Run testen
```

Dieses Dokument erklärt nun die nächste fachliche Stufe:

```text
GFS / Grandfather-Father-Son
3-2-1-Backup-Regel
RPO und RTO
Bezug zu Docker Images, Containern und Volumes
Unterschied zwischen Lernumgebung und Produktion
```

---

## Ausgangspunkt im Projekt

Das Projekt nutzt aktuell ein Redis-Volume:

```text
dockerbung_redis_data_prod
```

Dieses Volume wird durch ein Skript gesichert:

```text
scripts/backup/backup-redis-volume.ps1
```

Ein zweites Skript testet die Wiederherstellung:

```text
scripts/restore/test-redis-restore.ps1
```

Ein Master-Skript führt beide Schritte zusammen aus:

```text
scripts/backup/backup-and-test-redis.ps1
```

Ein weiteres Skript prüft, welche alten Backup-Dateien nach einer einfachen Aufbewahrungsregel gelöscht werden könnten:

```text
scripts/retention/cleanup-old-backups.ps1
```

---

## Aktuelle Backup-Aufbewahrung im Lernprojekt

Das aktuelle Retention-Skript arbeitet einfach:

```text
Behalte mindestens X neueste Backups.
Behandle Backups älter als Y Tage als mögliche Löschkandidaten.
Lösche nur, wenn -Execute ausdrücklich gesetzt wurde.
```

Beispiel:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\retention\cleanup-old-backups.ps1 -RetentionDays 7 -MinimumBackupsToKeep 2
```

Bedeutung:

```text
Backups älter als 7 Tage wären grundsätzlich Löschkandidaten.
Die neuesten 2 Backups bleiben immer geschützt.
Ohne -Execute wird nichts gelöscht.
```

Das ist eine gute Lernversion.

Diese Art nennt man vereinfacht:

```text
Rolling Retention
```

Rolling Retention bedeutet:

```text
Es wird laufend nach Alter und Anzahl entschieden, welche Backups behalten werden.
```

---

## Warum einfache Retention nicht immer reicht

In kleinen Lernumgebungen reicht eine einfache Regel oft aus.

In echten Unternehmen reicht sie häufig nicht aus, weil dort weitere Fragen wichtig werden:

```text
Gibt es ein Backup von gestern?
Gibt es ein Backup von letzter Woche?
Gibt es ein Backup vom Monatsabschluss?
Gibt es ein Backup vom Jahresabschluss?
Wie lange müssen Daten aufbewahrt werden?
Wie schnell muss das System wieder laufen?
Wie viel Datenverlust ist maximal erlaubt?
Wer darf Backups lesen oder löschen?
Sind Backups gegen Ransomware geschützt?
```

Deshalb nutzen Unternehmen oft abgestufte Backup-Strategien.

---

## GFS: Grandfather-Father-Son

GFS steht für:

```text
Grandfather-Father-Son
```

Auf Deutsch:

```text
Großvater-Vater-Sohn
```

GFS ist eine klassische langfristige Backup-Aufbewahrungsstrategie.

Die Idee:

```text
Nicht jedes Backup wird gleich lange behalten.
Aktuelle Backups werden engmaschig behalten.
Ältere Backups werden ausgedünnt.
Wichtige Wochen-, Monats- und Jahresstände bleiben länger erhalten.
```

---

## Die drei GFS-Ebenen

| GFS-Ebene | Deutsch | Typischer Zweck |
|---|---|---|
| Son | Sohn | tägliche Backups |
| Father | Vater | wöchentliche Backups |
| Grandfather | Großvater | monatliche oder jährliche Backups |

---

## Einfaches GFS-Beispiel

Eine mögliche Regel könnte so aussehen:

```text
Tägliche Backups: 14 Tage behalten
Wöchentliche Backups: 8 Wochen behalten
Monatliche Backups: 12 Monate behalten
Jährliche Backups: 5 Jahre behalten
```

Dadurch gibt es kurzfristig viele Wiederherstellungspunkte, aber langfristig wird nicht jedes einzelne Tagesbackup behalten.

Das spart Speicherplatz und hält trotzdem wichtige Zeitpunkte verfügbar.

---

## Vergleich: einfache Retention vs. GFS

| Ansatz | Idee | Vorteil | Nachteil |
|---|---|---|---|
| Einfache Retention | nach Alter und Mindestanzahl löschen | leicht verständlich, gut für Labor | weniger flexibel |
| GFS | tägliche, wöchentliche, monatliche und jährliche Stufen | produktionsnäher, besser für langfristige Aufbewahrung | komplexer |
| 3-2-1-Regel | mehrere Kopien auf verschiedenen Speicherorten | schützt gegen Datenverlust durch Standort- oder Hardwareausfall | braucht zusätzliche Infrastruktur |

---

## Mögliche GFS-Dateinamen im Docker-Projekt

Aktuell sehen Backups so aus:

```text
redis_data_prod_backup_2026-05-15_00-05-14.tar.gz
```

Für eine spätere GFS-Simulation könnten Dateinamen so aussehen:

```text
redis_data_prod_daily_2026-05-15.tar.gz
redis_data_prod_weekly_2026-W20.tar.gz
redis_data_prod_monthly_2026-05.tar.gz
redis_data_prod_yearly_2026.tar.gz
```

Damit wäre bereits im Namen sichtbar, zu welcher Aufbewahrungsebene ein Backup gehört.

---

## 3-2-1-Backup-Regel

Die 3-2-1-Regel ist eine bekannte Grundregel für robuste Backup-Strategien.

Sie bedeutet:

```text
3 Kopien der Daten
2 unterschiedliche Speichermedien
1 Kopie extern/offsite
```

Einfach erklärt:

| Zahl | Bedeutung |
|---|---|
| 3 | Originaldaten plus zwei Backup-Kopien |
| 2 | Backups auf mindestens zwei unterschiedlichen Speichermedien |
| 1 | eine Kopie außerhalb des Hauptstandorts |

Beispiel für dieses Projekt:

```text
1. Originaldaten im Docker Volume
2. lokales Backup im Ordner backups/
3. externe Kopie auf NAS, Backup-Server oder Cloud Storage
```

NAS bedeutet:

```text
Network Attached Storage
```

Das ist ein Speichergerät im Netzwerk.

Offsite bedeutet:

```text
nicht am selben Standort wie das Hauptsystem
```

---

## Moderne Erweiterung: 3-2-1-1-0

Eine moderne Erweiterung ist:

```text
3-2-1-1-0
```

Bedeutung:

| Teil | Erklärung |
|---|---|
| 3 | drei Kopien der Daten |
| 2 | zwei unterschiedliche Speichermedien |
| 1 | eine Kopie extern/offsite |
| 1 | eine zusätzliche unveränderbare oder offline Kopie |
| 0 | null Fehler bei der Wiederherstellungsprüfung |

Unveränderbar bedeutet:

```text
Das Backup kann für eine festgelegte Zeit nicht verändert oder gelöscht werden.
```

Das ist wichtig gegen Ransomware.

Der Punkt `0` passt besonders gut zu diesem Lernprojekt:

```text
0 ungeprüfte Wiederherstellungsfehler
```

Merksatz:

```text
Ein Backup ist erst dann belastbar, wenn ein Restore erfolgreich getestet wurde.
```

---

## RPO und RTO

In professionellen Backup-Konzepten gibt es zwei sehr wichtige Begriffe.

```text
RPO
RTO
```

---

## RPO: Recovery Point Objective

RPO bedeutet:

```text
Recovery Point Objective
```

Einfach erklärt:

```text
Wie viel Datenverlust ist maximal erlaubt?
```

Beispiel:

```text
RPO = 24 Stunden
```

Das bedeutet:

```text
Im schlimmsten Fall dürfen Daten seit dem letzten täglichen Backup verloren gehen.
```

Je kleiner das RPO, desto häufiger muss gesichert werden.

---

## RTO: Recovery Time Objective

RTO bedeutet:

```text
Recovery Time Objective
```

Einfach erklärt:

```text
Wie schnell muss ein System nach einem Ausfall wieder laufen?
```

Beispiel:

```text
RTO = 2 Stunden
```

Das bedeutet:

```text
Nach einem Ausfall muss der Dienst spätestens nach 2 Stunden wieder verfügbar sein.
```

Je kleiner das RTO, desto besser müssen Restore-Prozess, Dokumentation und Automatisierung vorbereitet sein.

---

## Bezug zu Docker: Image, Container und Volume

Bei Docker muss man im Backup-Kontext sauber unterscheiden:

```text
Image
Container
Volume
```

---

## Docker Image

Ein Docker Image ist ein Bauplan.

Beispiel:

```text
handsonlabs/my-web:v1.2
```

Images werden normalerweise nicht wie klassische Datenbankdaten gesichert.

Sie werden eher versioniert und in einer Registry gespeichert.

Typische Methoden:

```text
Image Tags
Container Registry
Release-Versionen
Rollback
CI/CD-Pipeline
```

CI/CD bedeutet:

```text
Continuous Integration / Continuous Deployment
```

Einfach erklärt:

```text
Code wird automatisch geprüft, gebaut und verteilt.
```

---

## Docker Container

Ein Docker Container ist die laufende Instanz eines Images.

Container selbst werden normalerweise nicht langfristig gesichert.

Warum?

```text
Container sollen ersetzbar sein.
```

Wenn ein Container kaputt ist:

```text
Container löschen
aus Image neu starten
Volume wieder einbinden
```

---

## Docker Volume

Ein Docker Volume enthält veränderliche Daten.

Beispiele:

```text
Datenbankdaten
Uploads
persistente Anwendungsdaten
Konfigurationszustände
```

Deshalb sind Volumes im Backup-Kontext besonders wichtig.

Merksatz:

```text
Images werden versioniert.
Container werden ersetzt.
Volumes werden gesichert.
```

---

## Bezug zu Redis

Redis arbeitet stark im Arbeitsspeicher.

Damit Daten nach einem Neustart erhalten bleiben können, nutzt Redis Persistenzmechanismen.

Persistenz bedeutet:

```text
Daten bleiben dauerhaft erhalten.
```

In diesem Projekt sieht man im Backup zum Beispiel:

```text
dump.rdb
appendonlydir/
appendonly.aof.manifest
```

---

## RDB

RDB bedeutet:

```text
Redis Database
```

Einfach erklärt:

```text
RDB = Foto der Datenbank
```

Redis speichert dabei Momentaufnahmen des Datenbestands.

---

## AOF

AOF bedeutet:

```text
Append Only File
```

Einfach erklärt:

```text
AOF = Tagebuch der Datenbankänderungen
```

Redis schreibt Änderungen fortlaufend mit und kann sie beim Neustart wieder abspielen.

Merksatz:

```text
RDB = Foto
AOF = Tagebuch
```

---

## BSI- und NIST-Einordnung

Ein professionelles Backup-Konzept besteht nicht nur aus einem Skript.

Es braucht auch organisatorische Regeln:

```text
Verantwortlichkeiten
Aufbewahrungsfristen
Wiederherstellungstests
Zugriffsrechte
Dokumentation
Schutz vor Manipulation
Notfallplanung
```

Das BSI, also das Bundesamt für Sicherheit in der Informationstechnik, behandelt Datensicherung im IT-Grundschutz als eigenes Konzeptthema.

NIST, also das National Institute of Standards and Technology, behandelt Backup und Wiederherstellung im Rahmen von Notfall- und Wiederherstellungsplanung.

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

## Warum Restore-Tests Pflicht sind

Eine Backup-Datei allein beweist noch nicht, dass die Wiederherstellung funktioniert.

Deshalb unterscheidet dieses Projekt drei Stufen:

```text
1. Backup-Datei existiert
2. Backup-Archiv ist lesbar
3. Backup wurde erfolgreich wiederhergestellt getestet
```

Die wichtigste Stufe ist die dritte.

Denn nur ein Restore-Test beweist:

```text
Die Daten können praktisch wiederhergestellt werden.
```

---

## Produktionsnahe Backup-Fragen

Ein professionelles Backup-Konzept sollte mindestens diese Fragen beantworten:

```text
Welche Daten müssen gesichert werden?
Wie oft werden sie gesichert?
Wie lange werden sie behalten?
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

## Einordnung der aktuellen Projektumsetzung

Die aktuelle Umsetzung ist eine starke Lernversion.

Sie enthält:

```text
Docker Volume für Redis-Daten
Backup-Skript
Restore-Test-Skript
Master-Skript
Retention-Skript mit Dry-Run
GitHub-Dokumentation
README-Erweiterung
```

Sie ist aber noch keine vollständige produktionsreife Backup-Lösung.

---

## Was für Produktion noch fehlen würde

Produktionsnäher wären zusätzlich:

```text
GFS-Retention
3-2-1-Strategie
externe Speicherung
Verschlüsselung
Monitoring
Protokollierung
Rechtekonzept
Secret Management
regelmäßige Restore-Tests
RPO/RTO-Definition
```

---

## Risikoanalyse

| Risiko | Bedeutung | Gegenmaßnahme |
|---|---|---|
| Backup liegt nur lokal | Rechnerausfall kann Backup zerstören | externe Kopie |
| Backup ist nicht getestet | Restore kann im Notfall scheitern | regelmäßiger Restore-Test |
| Backup ist unverschlüsselt | Daten können bei Diebstahl gelesen werden | Verschlüsselung |
| jeder darf Backups löschen | versehentliches oder absichtliches Löschen möglich | Rechtekonzept |
| alte Backups werden nie gelöscht | Speicher läuft voll | Retention Policy |
| Backups werden zu früh gelöscht | benötigter Restore-Punkt fehlt | GFS-Regel |
| Secrets liegen im Klartext | Zugangsdaten können leaken | Secret Management |

---

## Lernversion vs. Produktion

| Bereich | Lernversion | Produktion |
|---|---|---|
| Backup-Speicher | lokaler Ordner `backups/` | externer, geschützter Speicher |
| Restore-Test | manuell oder per Skript lokal | regelmäßig geplant und dokumentiert |
| Retention | einfache Alter-/Anzahl-Regel | GFS oder vergleichbare Strategie |
| Schutz | `.gitignore`, lokale Trennung | Verschlüsselung, Rechte, Immutable Storage |
| Secrets | `.env` lokal | Secret Manager oder Orchestrator-Secrets |
| Monitoring | manuelle Prüfung | automatische Alarmierung |
| Dokumentation | README und Praxisarbeit | Betriebsdokumentation, Notfallhandbuch |

---

## Merksätze

```text
Ein Backup ohne Restore-Test ist nur eine Hoffnung.
```

```text
Images werden versioniert.
Container werden ersetzt.
Volumes werden gesichert.
```

```text
Retention löscht nicht einfach alte Dateien.
Retention entscheidet kontrolliert, welche Wiederherstellungspunkte erhalten bleiben müssen.
```

```text
GFS hilft, kurzfristige und langfristige Wiederherstellungspunkte sinnvoll zu kombinieren.
```

```text
3-2-1 schützt davor, dass Hauptsystem und Backup gleichzeitig verloren gehen.
```

---

## Nächste mögliche Erweiterung

Eine spätere Übung könnte ein GFS-Simulationsskript erstellen.

Mögliche Datei:

```text
scripts/retention/simulate-gfs-retention.ps1
```

Dieses Skript könnte prüfen:

```text
Welche Backups sind daily?
Welche Backups sind weekly?
Welche Backups sind monthly?
Welche Backups sind yearly?
Welche Backups müssten geschützt werden?
Welche wären Löschkandidaten?
```

Wichtig:

```text
Auch ein GFS-Skript sollte zuerst nur im Dry-Run laufen.
```

Erst wenn die Logik absolut klar ist, sollte es echte Dateien löschen dürfen.

---

## Quellen und Orientierung

Dieses Dokument orientiert sich fachlich an:

```text
Docker Dokumentation zu Volumes und Backup/Restore:
https://docs.docker.com/engine/storage/volumes/

Docker Desktop Backup/Restore-Hinweis zu named volumes:
https://docs.docker.com/desktop/settings-and-maintenance/backup-and-restore/

BSI IT-Grundschutz CON.3 Datensicherungskonzept:
https://www.bsi.bund.de/

NIST SP 800-34 Contingency Planning Guide:
https://csrc.nist.gov/publications/detail/sp/800-34/rev-1/final

Veeam Dokumentation zu GFS Retention:
https://helpcenter.veeam.com/docs/vbr/userguide/gfs_retention_policy.html

Redis Dokumentation zu Persistenz:
https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/
```