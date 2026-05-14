# backup-and-test-redis.ps1
# Zweck:
# Dieses Master-Skript führt den kompletten Redis-Backup-Prüfprozess aus.
#
# Ablauf:
# 1. Backup-Skript starten
# 2. Backup-Datei technisch prüfen lassen
# 3. Restore-Test-Skript starten
# 4. Prüfen, ob das Backup wirklich wiederherstellbar ist
#
# Wichtig:
# Dieses Skript löscht NICHT das produktive Redis-Volume.
# Der Restore-Test läuft über ein separates Restore-Test-Volume.
#
# Begriffe:
# TAR bedeutet Tape Archive.
# Das ist ein Archivformat aus der Unix-/Linux-Welt.
# Eine .tar.gz-Datei ist ein TAR-Archiv, das zusätzlich mit gzip komprimiert wurde.

$ErrorActionPreference = "Stop"

Write-Host "Starte Redis Backup-und-Restore-Gesamtprozess..."
Write-Host ""

# Projektordner automatisch bestimmen.
# $PSScriptRoot ist der Ordner, in dem dieses Skript liegt.
# Da dieses Skript in scripts/ liegt, ist der Projektordner eine Ebene darüber.
$ScriptDirectory = $PSScriptRoot
$ProjectDirectory = Split-Path -Parent $ScriptDirectory

Write-Host "Skript-Ordner: $ScriptDirectory"
Write-Host "Projektordner: $ProjectDirectory"
Write-Host ""

# In den Projektordner wechseln.
# Das ist wichtig, weil die Einzelskripte mit relativen Pfaden arbeiten.
Set-Location $ProjectDirectory

# Pfade zu den Einzelskripten.
$BackupScript = Join-Path $ProjectDirectory "scripts\backup-redis-volume.ps1"
$RestoreTestScript = Join-Path $ProjectDirectory "scripts\test-redis-restore.ps1"

# Prüfen, ob das Backup-Skript vorhanden ist.
if (-Not (Test-Path $BackupScript)) {
    throw "Backup-Skript wurde nicht gefunden: $BackupScript"
}

# Prüfen, ob das Restore-Test-Skript vorhanden ist.
if (-Not (Test-Path $RestoreTestScript)) {
    throw "Restore-Test-Skript wurde nicht gefunden: $RestoreTestScript"
}

Write-Host "Gefundene Skripte:"
Write-Host "Backup-Skript: $BackupScript"
Write-Host "Restore-Test-Skript: $RestoreTestScript"
Write-Host ""

Write-Host "=============================================="
Write-Host "SCHRITT 1: Backup erstellen und Archiv pruefen"
Write-Host "=============================================="
Write-Host ""

# Backup-Skript ausführen.
& $BackupScript

Write-Host ""
Write-Host "=============================================="
Write-Host "SCHRITT 2: Restore-Test aus neuestem Backup"
Write-Host "=============================================="
Write-Host ""

# Restore-Test-Skript ausführen.
& $RestoreTestScript

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
Write-Host "Fertig."