# simulate-restore-value-mismatch.ps1
# Zweck:
# Dieses Skript simuliert einen realistischen fachlichen Restore-Fehler.
#
# Szenario:
# Das Backup wird technisch erfolgreich in ein separates Test-Volume zurueckgespielt.
# Redis startet mit dem wiederhergestellten Volume.
# Danach wird absichtlich ein falscher erwarteter Wert verglichen.
#
# Dadurch entsteht ein realistischer Fehlerfall:
# Der Restore laeuft technisch, aber die fachlich erwarteten Daten stimmen nicht.
#
# Wichtig:
# Dieses Skript veraendert NICHT das produktive Redis-Volume.
# Es nutzt ein separates Test-Volume:
# dockerbung_redis_data_mismatch_test
#
# Die Logdatei liegt unter:
# logs/backup-restore.log

param(
    # Absichtlich falscher Erwartungswert fuer die Fehleruebung.
    [string]$ExpectedValue = "absichtlich-falscher-wert",

    # Redis-Passwort aus der Lernumgebung.
    [string]$RedisPassword = "local_redis_password_please_change"
)

$ErrorActionPreference = "Stop"

$ScriptDirectory = $PSScriptRoot
$ProjectDirectory = Split-Path -Parent $ScriptDirectory

$BackupDirectory = Join-Path $ProjectDirectory "backups"
$LogDirectory = Join-Path $ProjectDirectory "logs"
$LogFile = Join-Path $LogDirectory "backup-restore.log"

$RestoreVolumeName = "dockerbung_redis_data_mismatch_test"
$RestoreContainerName = "redis-mismatch-test"
$RedisKey = "training_status"

function Write-Log {
    param(
        [string]$Level,
        [string]$Message
    )

    if (-Not (Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
    }

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "$Timestamp | $Level | $Message"
    Add-Content -Path $LogFile -Value $Line -Encoding UTF8
}

function Test-DockerContainerExists {
    param(
        [string]$ContainerName
    )

    $Result = docker ps -a --filter "name=^/$ContainerName$" --format "{{.Names}}"
    return ($Result -eq $ContainerName)
}

function Test-DockerVolumeExists {
    param(
        [string]$VolumeName
    )

    # Kein docker volume inspect verwenden:
    # Wenn das Volume nicht existiert, schreibt Docker eine Fehlermeldung.
    # Bei $ErrorActionPreference = "Stop" kann das die Uebung zu frueh abbrechen.
    $ExistingVolumes = @(docker volume ls --format "{{.Name}}")
    return ($ExistingVolumes -contains $VolumeName)
}

Write-Host "Starte realistische Restore-Fehleruebung..."
Write-Host ""
Write-Host "Szenario:"
Write-Host "Das Backup wird technisch wiederhergestellt."
Write-Host "Danach wird absichtlich ein falscher erwarteter Redis-Wert verglichen."
Write-Host "So wird ein fachlich fehlgeschlagener Restore-Test simuliert."
Write-Host ""

Write-Log -Level "INFO" -Message "Restore-Fehleruebung gestartet: fachlicher Datenvergleich wird absichtlich fehlschlagen."

try {
    Write-Host "Projektordner: $ProjectDirectory"
    Write-Host "Backup-Ordner: $BackupDirectory"
    Write-Host "Test-Volume: $RestoreVolumeName"
    Write-Host "Testcontainer: $RestoreContainerName"
    Write-Host ""

    Write-Log -Level "INFO" -Message "Projektordner: $ProjectDirectory"
    Write-Log -Level "INFO" -Message "Backup-Ordner: $BackupDirectory"
    Write-Log -Level "INFO" -Message "Test-Volume: $RestoreVolumeName"
    Write-Log -Level "INFO" -Message "Testcontainer: $RestoreContainerName"

    if (-Not (Test-Path $BackupDirectory)) {
        throw "Backup-Ordner wurde nicht gefunden: $BackupDirectory"
    }

    $LatestBackup = Get-ChildItem -Path $BackupDirectory -Filter "redis_data_prod_backup_*.tar.gz" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if ($null -eq $LatestBackup) {
        throw "Keine zeitgestempelte Redis-Backup-Datei im Backup-Ordner gefunden."
    }

    Write-Host "Neueste Backup-Datei gefunden:"
    Write-Host $LatestBackup.FullName
    Write-Host ""

    Write-Log -Level "INFO" -Message "Neueste Backup-Datei gefunden: $($LatestBackup.FullName)"

    Write-Host "Entferne alten Testcontainer, falls vorhanden..."
    if (Test-DockerContainerExists -ContainerName $RestoreContainerName) {
        docker rm -f $RestoreContainerName | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Alter Testcontainer konnte nicht entfernt werden: $RestoreContainerName"
        }
        Write-Log -Level "INFO" -Message "Alter Testcontainer wurde entfernt: $RestoreContainerName"
    }
    else {
        Write-Log -Level "INFO" -Message "Kein alter Testcontainer vorhanden: $RestoreContainerName"
    }

    Write-Host "Entferne altes Test-Volume, falls vorhanden..."
    if (Test-DockerVolumeExists -VolumeName $RestoreVolumeName) {
        docker volume rm $RestoreVolumeName | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Altes Test-Volume konnte nicht entfernt werden: $RestoreVolumeName"
        }
        Write-Log -Level "INFO" -Message "Altes Test-Volume wurde entfernt: $RestoreVolumeName"
    }
    else {
        Write-Log -Level "INFO" -Message "Kein altes Test-Volume vorhanden: $RestoreVolumeName"
    }

    Write-Host "Erstelle neues Test-Volume..."
    docker volume create $RestoreVolumeName | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Test-Volume konnte nicht erstellt werden: $RestoreVolumeName"
    }

    Write-Log -Level "INFO" -Message "Neues Test-Volume wurde erstellt: $RestoreVolumeName"

    Write-Host "Spiele Backup in Test-Volume zurueck..."
    $BackupFileName = $LatestBackup.Name

    docker run --rm `
        -v "${RestoreVolumeName}:/data" `
        -v "${BackupDirectory}:/backup" `
        alpine `
        sh -c "cd /data && tar xzf /backup/$BackupFileName"

    if ($LASTEXITCODE -ne 0) {
        throw "Backup konnte nicht in das Test-Volume entpackt werden."
    }

    Write-Log -Level "SUCCESS" -Message "Backup wurde technisch erfolgreich in das Test-Volume entpackt."

    Write-Host "Starte Redis-Testcontainer mit wiederhergestelltem Volume..."
    docker run -d `
        --name $RestoreContainerName `
        -v "${RestoreVolumeName}:/data" `
        redis:alpine `
        redis-server --appendonly yes --requirepass $RedisPassword | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "Redis-Testcontainer konnte nicht gestartet werden."
    }

    Start-Sleep -Seconds 2

    Write-Log -Level "INFO" -Message "Redis-Testcontainer wurde gestartet: $RestoreContainerName"

    Write-Host "Pruefe wiederhergestellten Redis-Wert..."

    # --no-auth-warning verhindert die bekannte Redis-Warnung bei -a.
    # --raw gibt den Wert ohne Anfuehrungszeichen aus.
    # Dadurch wird die Warnung nicht faelschlich als Skriptfehler behandelt.
    $RawValue = docker exec $RestoreContainerName redis-cli --no-auth-warning --raw -a $RedisPassword GET $RedisKey

    if ($LASTEXITCODE -ne 0) {
        throw "Redis-Wert konnte nicht gelesen werden. Moegliche Ursache: Redis laeuft nicht oder Passwort ist falsch."
    }

    $ActualValue = ($RawValue | Out-String).Trim()

    Write-Host "Erwarteter Wert: $ExpectedValue"
    Write-Host "Gelesener Wert:  $ActualValue"
    Write-Host ""

    Write-Log -Level "INFO" -Message "Fachlicher Restore-Test: Erwartet='$ExpectedValue' | Erhalten='$ActualValue'"

    if ($ActualValue -ne $ExpectedValue) {
        Write-Log -Level "ERROR" -Message "Restore-Test fachlich fehlgeschlagen: Redis-Wert '$RedisKey' stimmt nicht. Erwartet='$ExpectedValue' | Erhalten='$ActualValue'"
        Write-Log -Level "ERROR" -Message "Naechste Pruefung: Backup-Zeitpunkt, Volume-Name, Redis-Persistenz und verwendete Backup-Datei pruefen."
        throw "Restore-Test fachlich fehlgeschlagen: Erwarteter Redis-Wert wurde nicht gefunden."
    }

    Write-Log -Level "SUCCESS" -Message "Restore-Test fachlich erfolgreich. Erwarteter Redis-Wert wurde gefunden."

    Write-Host "Restore-Test erfolgreich."
}
catch {
    Write-Host ""
    Write-Host "FEHLER:"
    Write-Host $_.Exception.Message
    Write-Host ""

    Write-Log -Level "ERROR" -Message $_.Exception.Message
    Write-Log -Level "ERROR" -Message "Restore-Fehleruebung wurde mit Fehler beendet."

    Write-Host "Das ist in dieser Uebung erwartet, wenn der absichtlich falsche Erwartungswert genutzt wurde."
    Write-Host "Produktives Volume wurde nicht veraendert."
    Write-Host ""
    Write-Host "Logdatei:"
    Write-Host $LogFile
    Write-Host ""

    exit 1
}
finally {
    if (Test-DockerContainerExists -ContainerName $RestoreContainerName) {
        docker rm -f $RestoreContainerName | Out-Null
        Write-Log -Level "INFO" -Message "Testcontainer wurde nach der Uebung entfernt: $RestoreContainerName"
    }

    if (Test-DockerVolumeExists -VolumeName $RestoreVolumeName) {
        Write-Log -Level "INFO" -Message "Test-Volume bleibt fuer Diagnosezwecke erhalten: $RestoreVolumeName"
    }
    else {
        Write-Log -Level "INFO" -Message "Kein Test-Volume vorhanden: $RestoreVolumeName"
    }
}
