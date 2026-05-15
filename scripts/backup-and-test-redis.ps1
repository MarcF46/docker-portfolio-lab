# backup-and-test-redis.ps1
# Zweck:
# Dieses Skript startet den kompletten Redis Backup-und-Restore-Testprozess.
#
# Es fuehrt aus:
# 1. Backup erstellen und Archiv technisch pruefen
# 2. Restore-Test aus dem neuesten Backup durchfuehren
# 3. Ergebnis lokal protokollieren
#
# Neu in Mini-Lerneinheit 3H:
# Mit -SimulateFailure kann ein kontrollierter Fehler ausgeloest werden.
# Dadurch wird getestet, ob die Fehlerprotokollierung funktioniert.
#
# Die Logdatei liegt unter:
# logs/backup-restore.log
#
# Hinweis:
# Der Ordner logs/ wird lokal genutzt.
# Echte Logdateien werden durch .gitignore nicht zu GitHub hochgeladen.

param(
    # Kontrollierter Testfehler.
    # Damit kann geprueft werden, ob ERROR-Eintraege sauber in die Logdatei geschrieben werden.
    [switch]$SimulateFailure
)

$ErrorActionPreference = "Stop"

# Projektpfade bestimmen
$ScriptDirectory = $PSScriptRoot
$ProjectDirectory = Split-Path -Parent $ScriptDirectory

$BackupScript = Join-Path $ScriptDirectory "backup-redis-volume.ps1"
$RestoreTestScript = Join-Path $ScriptDirectory "test-redis-restore.ps1"

$LogDirectory = Join-Path $ProjectDirectory "logs"
$LogFile = Join-Path $LogDirectory "backup-restore.log"

function Write-Log {
    param(
        [string]$Level,
        [string]$Message
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "$Timestamp | $Level | $Message"

    Add-Content -Path $LogFile -Value $Line -Encoding UTF8
}

function Write-Step {
    param(
        [string]$Message
    )

    Write-Host $Message
    Write-Log -Level "INFO" -Message $Message
}

# Sicherstellen, dass der Log-Ordner existiert
if (-Not (Test-Path $LogDirectory)) {
    New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
}

Write-Host "Starte Redis Backup-und-Restore-Gesamtprozess..."
Write-Host ""

Write-Log -Level "INFO" -Message "Backup-und-Restore-Gesamtprozess gestartet."

try {
    Write-Step "Skript-Ordner: $ScriptDirectory"
    Write-Step "Projektordner: $ProjectDirectory"

    Write-Host ""
    Write-Step "Gefundene Skripte:"
    Write-Step "Backup-Skript: $BackupScript"
    Write-Step "Restore-Test-Skript: $RestoreTestScript"

    if ($SimulateFailure) {
        Write-Step "Simulationsmodus: Fehlerfall ist aktiviert."
        Write-Step "Dieser Testfehler prueft nur die Fehlerprotokollierung."
        Write-Step "Es werden dabei keine produktiven Docker-Volumes geloescht oder veraendert."
    }

    if (-Not (Test-Path $BackupScript)) {
        throw "Backup-Skript wurde nicht gefunden: $BackupScript"
    }

    if (-Not (Test-Path $RestoreTestScript)) {
        throw "Restore-Test-Skript wurde nicht gefunden: $RestoreTestScript"
    }

    Write-Host ""
    Write-Host "=============================================="
    Write-Host "SCHRITT 1: Backup erstellen und Archiv pruefen"
    Write-Host "=============================================="
    Write-Host ""

    Write-Log -Level "INFO" -Message "Schritt 1 gestartet: Backup erstellen und Archiv pruefen."

    & powershell -ExecutionPolicy Bypass -File $BackupScript

    if ($LASTEXITCODE -ne 0) {
        throw "Backup-Skript wurde mit Exitcode $LASTEXITCODE beendet."
    }

    Write-Log -Level "SUCCESS" -Message "Schritt 1 erfolgreich: Backup wurde erstellt und technisch geprueft."

    if ($SimulateFailure) {
        throw "Absichtlich simulierter Fehler nach erfolgreichem Backup. Dieser Fehler dient nur zum Test der ERROR-Protokollierung."
    }

    Write-Host ""
    Write-Host "=============================================="
    Write-Host "SCHRITT 2: Restore-Test aus neuestem Backup"
    Write-Host "=============================================="
    Write-Host ""

    Write-Log -Level "INFO" -Message "Schritt 2 gestartet: Restore-Test aus neuestem Backup."

    & powershell -ExecutionPolicy Bypass -File $RestoreTestScript

    if ($LASTEXITCODE -ne 0) {
        throw "Restore-Test-Skript wurde mit Exitcode $LASTEXITCODE beendet."
    }

    Write-Log -Level "SUCCESS" -Message "Schritt 2 erfolgreich: Restore-Test wurde erfolgreich abgeschlossen."

    Write-Host ""
    Write-Host "=============================================="
    Write-Host "GESAMTERGEBNIS"
    Write-Host "=============================================="
    Write-Host ""

    Write-Host "Gesamtprozess erfolgreich abgeschlossen."
    Write-Host "Backup wurde erstellt, technisch geprueft und erfolgreich wiederhergestellt getestet."
    Write-Host ""

    Write-Host "Wichtig:"
    Write-Host "Dieses Lernskript ist ein guter Betriebsprozess fuer das Labor."
    Write-Host "Fuer echte Produktion waeren zusaetzlich externe Speicherung, Verschluesselung, Rechtekonzept, Monitoring, Protokollierung, Retention Policy und Secret Management noetig."
    Write-Host ""

    Write-Log -Level "SUCCESS" -Message "Gesamtprozess erfolgreich abgeschlossen. Backup wurde erstellt, geprueft und per Restore-Test verifiziert."

    Write-Host "Logdatei:"
    Write-Host $LogFile
    Write-Host ""

    Write-Host "Fertig."
}
catch {
    Write-Host ""
    Write-Host "FEHLER:"
    Write-Host $_.Exception.Message

    Write-Log -Level "ERROR" -Message $_.Exception.Message
    Write-Log -Level "ERROR" -Message "Backup-und-Restore-Gesamtprozess fehlgeschlagen."

    Write-Host ""
    Write-Host "Logdatei:"
    Write-Host $LogFile
    Write-Host ""

    exit 1
}
