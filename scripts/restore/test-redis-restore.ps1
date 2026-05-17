# test-redis-restore.ps1
# Zweck:
# Dieses Skript testet, ob das neueste Redis-Volume-Backup wiederherstellbar ist.
#
# Ablauf:
# 1. Neueste Backup-Datei im Ordner backups/ finden
# 2. Alten Restore-Testcontainer entfernen, falls vorhanden
# 3. Altes Restore-Test-Volume entfernen, falls vorhanden
# 4. Neues Restore-Test-Volume erstellen
# 5. Backup in das Restore-Test-Volume entpacken
# 6. Redis-Testcontainer mit diesem Volume starten
# 7. Testwert training_status auslesen
# 8. Testcontainer wieder entfernen
#
# Wichtig:
# Das produktive Volume dockerbung_redis_data_prod wird NICHT überschrieben.
# Der Restore-Test läuft bewusst in einem separaten Test-Volume.
#
# Hinweis:
# TAR bedeutet Tape Archive. Das ist ein Archivformat aus der Unix-/Linux-Welt.
# Eine .tar.gz-Datei ist ein TAR-Archiv, das zusätzlich mit gzip komprimiert wurde.

$ErrorActionPreference = "Stop"

$BackupDirectory = Join-Path (Get-Location) "backups"
$RestoreVolumeName = "dockerbung_redis_data_restore_test"
$RestoreContainerName = "redis-restore-test"
$RedisPassword = "local_redis_password_please_change"
$TestKey = "training_status"
$ExpectedValue = "volume-test-erfolgreich"

Write-Host "Starte Redis-Restore-Test..."
Write-Host "Backup-Ordner: $BackupDirectory"
Write-Host "Restore-Test-Volume: $RestoreVolumeName"
Write-Host "Restore-Testcontainer: $RestoreContainerName"
Write-Host ""

# Prüfen, ob der Backup-Ordner existiert.
if (-Not (Test-Path $BackupDirectory)) {
    throw "Backup-Ordner wurde nicht gefunden: $BackupDirectory"
}

# Neueste Backup-Datei suchen.
$LatestBackup = Get-ChildItem -Path $BackupDirectory -Filter "*.tar.gz" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($null -eq $LatestBackup) {
    throw "Keine Backup-Datei mit Endung .tar.gz im Ordner backups/ gefunden."
}

Write-Host "Neueste Backup-Datei gefunden:"
Write-Host $LatestBackup.FullName
Write-Host ""

# Alten Restore-Testcontainer nur entfernen, wenn er wirklich existiert.
Write-Host "Pruefe, ob ein alter Restore-Testcontainer existiert..."
$ExistingContainer = docker ps -a --format "{{.Names}}" | Where-Object { $_ -eq $RestoreContainerName }

if ($ExistingContainer) {
    Write-Host "Alter Restore-Testcontainer gefunden. Entferne Container..."
    docker rm -f $RestoreContainerName | Out-Null
    Write-Host "Alter Restore-Testcontainer entfernt."
}
else {
    Write-Host "Kein alter Restore-Testcontainer vorhanden. Weiter geht es."
}

Write-Host ""

# Altes Restore-Test-Volume nur entfernen, wenn es wirklich existiert.
Write-Host "Pruefe, ob ein altes Restore-Test-Volume existiert..."
$ExistingVolume = docker volume ls --format "{{.Name}}" | Where-Object { $_ -eq $RestoreVolumeName }

if ($ExistingVolume) {
    Write-Host "Altes Restore-Test-Volume gefunden. Entferne Volume..."
    docker volume rm $RestoreVolumeName | Out-Null
    Write-Host "Altes Restore-Test-Volume entfernt."
}
else {
    Write-Host "Kein altes Restore-Test-Volume vorhanden. Weiter geht es."
}

Write-Host ""

# Neues Restore-Test-Volume erstellen.
Write-Host "Erstelle neues Restore-Test-Volume..."
docker volume create $RestoreVolumeName | Out-Null
Write-Host "Restore-Test-Volume erstellt."
Write-Host ""

# Backup in das Restore-Test-Volume entpacken.
# tar xzf bedeutet:
# x = extract / entpacken
# z = gzip-komprimiert
# f = Datei verwenden
Write-Host "Spiele Backup in Restore-Test-Volume zurueck..."
docker run --rm `
  -v "${RestoreVolumeName}:/data" `
  -v "${BackupDirectory}:/backup" `
  alpine `
  sh -c "cd /data && tar xzf /backup/$($LatestBackup.Name)"

Write-Host "Backup wurde in das Restore-Test-Volume entpackt."
Write-Host ""

# Redis-Testcontainer mit dem wiederhergestellten Volume starten.
Write-Host "Starte Redis-Testcontainer mit wiederhergestelltem Volume..."
docker run -d `
  --name $RestoreContainerName `
  -v "${RestoreVolumeName}:/data" `
  redis:alpine `
  redis-server --appendonly yes --requirepass $RedisPassword | Out-Null

Start-Sleep -Seconds 2

Write-Host "Redis-Testcontainer gestartet."
Write-Host ""

# Testwert aus Redis lesen.
# REDISCLI_AUTH ist eine Redis-Umgebungsvariable.
# Dadurch muss das Passwort nicht mit redis-cli -a übergeben werden.
# Das vermeidet die Warnung, die das alte Skript abgebrochen hat.
Write-Host "Pruefe wiederhergestellten Redis-Wert..."

$RestoredOutput = docker exec `
  -e "REDISCLI_AUTH=$RedisPassword" `
  $RestoreContainerName `
  redis-cli GET $TestKey

if ($null -eq $RestoredOutput) {
    throw "Redis hat keinen Wert fuer den Schluessel '$TestKey' zurueckgegeben."
}

$RestoredValue = ($RestoredOutput | Select-Object -Last 1).ToString().Trim()
$CleanValue = $RestoredValue.Trim('"')

Write-Host "Geladener Wert fuer '$TestKey': $CleanValue"
Write-Host ""

if ($CleanValue -ne $ExpectedValue) {
    throw "Restore-Test fehlgeschlagen. Erwartet wurde: $ExpectedValue, erhalten wurde: $CleanValue"
}

Write-Host "Restore-Test erfolgreich."
Write-Host "Das Backup konnte wiederhergestellt werden und Redis konnte den erwarteten Wert lesen."
Write-Host ""

# Testcontainer entfernen, Restore-Test-Volume aber behalten.
Write-Host "Entferne Redis-Testcontainer..."
docker rm -f $RestoreContainerName | Out-Null
Write-Host "Testcontainer entfernt."
Write-Host ""

Write-Host "Das Restore-Test-Volume bleibt erhalten:"
Write-Host $RestoreVolumeName
Write-Host ""
Write-Host "Fertig."