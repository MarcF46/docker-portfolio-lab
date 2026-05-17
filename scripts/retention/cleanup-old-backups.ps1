# cleanup-old-backups.ps1
# Zweck:
# Dieses Skript verwaltet alte lokale Redis-Backup-Dateien im Ordner backups/.
#
# Es löscht standardmäßig NICHTS.
# Ohne -Execute läuft es im Dry-Run-Modus.
#
# Dry-Run bedeutet:
# Das Skript zeigt nur an, welche Dateien gelöscht werden würden.
#
# Erst mit -Execute werden Dateien wirklich gelöscht.
#
# Wichtig:
# Dieses Skript löscht nur Backup-Dateien, die diesem Muster entsprechen:
# redis_data_prod_backup_*.tar.gz
#
# Die Datei redis_data_prod_backup.tar.gz ohne Zeitstempel wird bewusst nicht gelöscht.

param(
    # Anzahl der Tage, wie lange Backups behalten werden sollen.
    [int]$RetentionDays = 7,

    # Mindestanzahl neuer Backups, die immer behalten werden.
    [int]$MinimumBackupsToKeep = 2,

    # Wenn dieser Schalter gesetzt ist, wird wirklich gelöscht.
    # Ohne diesen Schalter läuft das Skript nur als Vorschau.
    [switch]$Execute
)

$ErrorActionPreference = "Stop"

# Backup-Ordner im aktuellen Projektverzeichnis.
$BackupDirectory = Join-Path (Get-Location) "backups"

# Nur Dateien mit Zeitstempel im Namen werden berücksichtigt.
$BackupPattern = "redis_data_prod_backup_*.tar.gz"

# Stichtag berechnen.
# Alles, was älter ist als dieser Zeitpunkt, ist grundsätzlich ein Löschkandidat.
$CutoffDate = (Get-Date).AddDays(-$RetentionDays)

Write-Host "Starte Backup-Retention-Pruefung..."
Write-Host "Backup-Ordner: $BackupDirectory"
Write-Host "Dateimuster: $BackupPattern"
Write-Host "Aufbewahrung in Tagen: $RetentionDays"
Write-Host "Mindestens behaltene Backups: $MinimumBackupsToKeep"

if ($Execute) {
    Write-Host "Modus: EXECUTE - Dateien koennen wirklich geloescht werden."
}
else {
    Write-Host "Modus: DRY-RUN - Es wird nichts geloescht."
}

Write-Host ""

# Prüfen, ob der Backup-Ordner existiert.
if (-Not (Test-Path $BackupDirectory)) {
    throw "Backup-Ordner wurde nicht gefunden: $BackupDirectory"
}

# Backup-Dateien finden.
$BackupFiles = Get-ChildItem -Path $BackupDirectory -Filter $BackupPattern -File |
    Sort-Object LastWriteTime

if ($BackupFiles.Count -eq 0) {
    Write-Host "Keine passenden Backup-Dateien gefunden."
    Write-Host "Fertig."
    exit 0
}

Write-Host "Gefundene Backup-Dateien:"
foreach ($File in $BackupFiles) {
    Write-Host "- $($File.Name) | Datum: $($File.LastWriteTime) | Groesse: $($File.Length) Bytes"
}

Write-Host ""

# Die neuesten Backups schützen.
$ProtectedFiles = $BackupFiles |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First $MinimumBackupsToKeep

$ProtectedPaths = $ProtectedFiles.FullName

Write-Host "Geschuetzte neueste Backups:"
foreach ($File in $ProtectedFiles) {
    Write-Host "- $($File.Name)"
}

Write-Host ""

# Löschkandidaten bestimmen:
# Datei ist älter als CutoffDate
# UND gehört nicht zu den geschützten neuesten Backups.
$DeleteCandidates = $BackupFiles | Where-Object {
    ($_.LastWriteTime -lt $CutoffDate) -and ($_.FullName -notin $ProtectedPaths)
}

if ($DeleteCandidates.Count -eq 0) {
    Write-Host "Keine Backup-Dateien zum Loeschen gefunden."
    Write-Host "Grund: Entweder sind die Dateien noch jung genug oder sie gehoeren zu den geschuetzten neuesten Backups."
    Write-Host "Fertig."
    exit 0
}

Write-Host "Loeschkandidaten:"
foreach ($File in $DeleteCandidates) {
    Write-Host "- $($File.Name) | Datum: $($File.LastWriteTime) | Groesse: $($File.Length) Bytes"
}

Write-Host ""

if (-Not $Execute) {
    Write-Host "DRY-RUN abgeschlossen."
    Write-Host "Es wurde nichts geloescht."
    Write-Host ""
    Write-Host "Wenn diese Liste korrekt aussieht, kann spaeter bewusst mit -Execute geloescht werden."
    Write-Host "Beispiel:"
    Write-Host "powershell -ExecutionPolicy Bypass -File .\scripts\cleanup-old-backups.ps1 -RetentionDays 7 -MinimumBackupsToKeep 2 -Execute"
    Write-Host ""
    Write-Host "Fertig."
    exit 0
}

Write-Host "EXECUTE-Modus aktiv. Loesche Dateien..."

foreach ($File in $DeleteCandidates) {
    Remove-Item -LiteralPath $File.FullName -Force
    Write-Host "Geloescht: $($File.Name)"
}

Write-Host ""
Write-Host "Retention-Cleanup abgeschlossen."
Write-Host "Fertig."