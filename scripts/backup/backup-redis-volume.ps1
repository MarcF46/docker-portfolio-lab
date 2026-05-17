# backup-redis-volume.ps1
# Zweck:
# Dieses Skript erstellt ein Backup des Docker-Volumes dockerbung_redis_data_prod.
# Das Backup wird im lokalen Ordner backups/ abgelegt.
# Die Backup-Datei bekommt automatisch einen Zeitstempel.
#
# Wichtig:
# Der Ordner backups/ wird durch .gitignore nicht zu GitHub hochgeladen,
# weil Backup-Dateien später echte Daten enthalten können.
#
# Hinweis:
# Dieses Skript prüft, ob das Archiv erstellt und gelesen werden kann.
# Es ersetzt keinen echten Restore-Test.
# Der Restore-Test folgt in einem separaten Skript.

$ErrorActionPreference = "Stop"

# Name des Docker-Volumes, das gesichert werden soll.
$VolumeName = "dockerbung_redis_data_prod"

# Lokaler Backup-Ordner im aktuellen Projektverzeichnis.
$BackupDirectory = Join-Path (Get-Location) "backups"

# Zeitstempel für eindeutige Backup-Dateinamen.
# Format: Jahr-Monat-Tag_Stunde-Minute-Sekunde
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Name der Backup-Datei.
# TAR steht für Tape Archive, ein Archivformat aus der Unix-/Linux-Welt.
# GZ bedeutet gzip-komprimiert.
# .tar.gz ist also ein gepacktes und komprimiertes Archiv.
$BackupFileName = "redis_data_prod_backup_$Timestamp.tar.gz"

# Vollständiger lokaler Pfad zur Backup-Datei.
$BackupFilePath = Join-Path $BackupDirectory $BackupFileName

Write-Host "Starte Redis-Volume-Backup..."
Write-Host "Volume: $VolumeName"
Write-Host "Backup-Ordner: $BackupDirectory"
Write-Host "Backup-Datei: $BackupFileName"
Write-Host ""

# Backup-Ordner erstellen, falls er noch nicht existiert.
New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null

# Prüfen, ob das Docker-Volume existiert.
Write-Host "Pruefe, ob das Docker-Volume existiert..."
docker volume inspect $VolumeName | Out-Null
Write-Host "Volume gefunden."
Write-Host ""

# Backup erstellen.
# Dafuer wird ein temporaerer Alpine-Linux-Container gestartet.
# Alpine ist eine sehr kleine Linux-Distribution.
# Das Redis-Volume wird in diesen Hilfscontainer unter /data eingebunden.
# Der lokale Backup-Ordner wird unter /backup eingebunden.
# tar czf erstellt ein gzip-komprimiertes TAR-Archiv.
Write-Host "Erstelle Backup..."
docker run --rm `
  -v "${VolumeName}:/data" `
  -v "${BackupDirectory}:/backup" `
  alpine `
  tar czf "/backup/$BackupFileName" -C /data .

Write-Host ""
Write-Host "Backup wurde erstellt:"
Write-Host $BackupFilePath
Write-Host ""

# Backup-Datei lokal prüfen.
if (-Not (Test-Path $BackupFilePath)) {
    throw "Backup-Datei wurde nicht gefunden: $BackupFilePath"
}

$BackupFile = Get-Item $BackupFilePath

if ($BackupFile.Length -le 0) {
    throw "Backup-Datei ist leer: $BackupFilePath"
}

Write-Host "Backup-Datei existiert und ist nicht leer."
Write-Host "Dateigroesse in Bytes: $($BackupFile.Length)"
Write-Host ""

# Backup-Inhalt anzeigen.
# tar tzf listet den Inhalt eines gzip-komprimierten TAR-Archivs auf.
# Das ist eine technische Archivpruefung, aber noch kein Restore-Test.
Write-Host "Pruefe Backup-Inhalt mit tar tzf..."
docker run --rm `
  -v "${BackupDirectory}:/backup" `
  alpine `
  tar tzf "/backup/$BackupFileName"

Write-Host ""
Write-Host "Backup-Archiv konnte gelesen werden."
Write-Host "Wenn oben Redis-Dateien wie dump.rdb oder appendonlydir angezeigt wurden, sieht das Backup technisch sinnvoll aus."
Write-Host ""
Write-Host "Wichtig: Ein echter Restore-Test wurde mit diesem Skript noch NICHT durchgefuehrt."
Write-Host "Der Restore-Test folgt in Mini-Lerneinheit 3B."
Write-Host ""
Write-Host "Fertig."