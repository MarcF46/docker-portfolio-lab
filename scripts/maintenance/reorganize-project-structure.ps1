<# 
.SYNOPSIS
  Räumt die Projektstruktur des Docker-/DevOps-Lernprojekts vorsichtig auf.

.DESCRIPTION
  Dieses Skript ist für das Lernprojekt "C:\Docker Übung" gedacht.
  Es erstellt eine sauberere Enterprise-nahe Ordnerstruktur, verschiebt ausgewählte
  Dokumentations- und Skriptdateien in passendere Unterordner und archiviert eine
  alte Compose-Datei, ohne Dateien hart zu löschen.

  Lernregel:
  - Jeder relevante Schritt ist kommentiert.
  - Das Skript arbeitet vorsichtig.
  - Es nutzt git mv, wenn eine Datei bereits von Git getrackt wird.
  - Es nutzt Move-Item, wenn eine Datei noch untracked ist.
  - Es löscht keine Dateien automatisch.

.PARAMETER DryRun
  Zeigt nur, was passieren würde, ohne Dateien zu verschieben.

.EXAMPLE
  .\scripts\maintenance\reorganize-project-structure.ps1 -DryRun

.EXAMPLE
  .\scripts\maintenance\reorganize-project-structure.ps1
#>

param(
    [switch]$DryRun
)

# Bei Fehlern soll das Skript nicht still weiterlaufen.
# Dadurch merken wir früh, wenn ein Befehl nicht funktioniert.
$ErrorActionPreference = "Stop"

# Projektwurzel bestimmen:
# Das Skript liegt später in scripts\maintenance.
# Von dort gehen wir zwei Ebenen nach oben zum Projektordner.
$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptLocation "..\..")

# In den Projektordner wechseln.
# Grund: Alle relativen Pfade sollen eindeutig vom Projektroot aus funktionieren.
Set-Location $ProjectRoot

Write-Host ""
Write-Host "=== Projektstruktur-Aufraeumrunde ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host "DryRun-Modus: $DryRun"
Write-Host ""

# Prüft, ob wir wirklich in einem Git-Repository sind.
# Grund: Wir wollen Verschiebungen möglichst sauber für Git nachvollziehbar machen.
if (-not (Test-Path ".git")) {
    throw "Kein .git-Ordner gefunden. Bitte das Skript im Repository C:\Docker Übung ausführen."
}

# Hilfsfunktion:
# Prüft, ob eine Datei von Git getrackt wird.
function Test-GitTracked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    git ls-files --error-unmatch $Path *> $null
    return ($LASTEXITCODE -eq 0)
}

# Hilfsfunktion:
# Verschiebt Dateien vorsichtig.
# Wenn die Datei von Git getrackt ist, wird git mv verwendet.
# Wenn sie untracked ist, wird Move-Item verwendet.
function Move-ProjectFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    # Wenn die Quelldatei nicht existiert, überspringen wir den Schritt.
    # Grund: Das Skript soll mehrfach ausführbar bleiben.
    if (-not (Test-Path $Source)) {
        Write-Host "[SKIP] Quelle nicht vorhanden: $Source"
        return
    }

    # Wenn die Zieldatei bereits existiert, überschreiben wir nicht automatisch.
    # Grund: Kein Risiko, versehentlich eine Datei zu ersetzen.
    if (Test-Path $Destination) {
        Write-Host "[SKIP] Ziel existiert bereits: $Destination" -ForegroundColor Yellow
        return
    }

    # Zielordner erzeugen, falls er noch nicht existiert.
    $DestinationDirectory = Split-Path -Parent $Destination
    if ($DestinationDirectory -and -not (Test-Path $DestinationDirectory)) {
        if ($DryRun) {
            Write-Host "[DRYRUN] Ordner erstellen: $DestinationDirectory"
        } else {
            New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
            Write-Host "[OK] Ordner erstellt: $DestinationDirectory"
        }
    }

    # Git-getrackte Dateien mit git mv verschieben.
    # Vorteil: Git erkennt die Datei als Verschiebung statt als Löschen + Neu.
    if (Test-GitTracked $Source) {
        if ($DryRun) {
            Write-Host "[DRYRUN] git mv $Source $Destination"
        } else {
            git mv $Source $Destination
            Write-Host "[OK] git mv: $Source -> $Destination"
        }
    }
    else {
        if ($DryRun) {
            Write-Host "[DRYRUN] Move-Item $Source $Destination"
        } else {
            Move-Item $Source $Destination
            Write-Host "[OK] Move-Item: $Source -> $Destination"
        }
    }
}

# Hilfsfunktion:
# Benennt die undatierte Standard-Backup-Datei in einen Zeitstempel-Namen um.
function Rename-LegacyBackup {
    $LegacyBackup = "backups\redis_data_prod_backup.tar.gz"

    # Wenn diese Datei nicht existiert, gibt es nichts zu vereinheitlichen.
    if (-not (Test-Path $LegacyBackup)) {
        Write-Host "[SKIP] Kein undatiertes Legacy-Backup gefunden."
        return
    }

    # Änderungsdatum der Datei auslesen.
    # Grund: Wir nutzen den tatsächlichen Dateizeitpunkt als sinnvollen Backup-Zeitstempel.
    $Item = Get-Item $LegacyBackup
    $Timestamp = $Item.LastWriteTime.ToString("yyyy-MM-dd_HH-mm-ss")
    $NewName = "backups\redis_data_prod_backup_$Timestamp.tar.gz"

    # Falls der Zielname schon existiert, hängen wir _legacy an.
    if (Test-Path $NewName) {
        $NewName = "backups\redis_data_prod_backup_${Timestamp}_legacy.tar.gz"
    }

    if ($DryRun) {
        Write-Host "[DRYRUN] Rename Backup: $LegacyBackup -> $NewName"
    } else {
        Move-Item $LegacyBackup $NewName
        Write-Host "[OK] Backup umbenannt: $LegacyBackup -> $NewName"
    }
}

# Hilfsfunktion:
# Aktualisiert bekannte Pfadverweise in Markdown-Dateien und README.md.
function Update-PathReferences {
    # Diese Ersetzungen halten Dokumentation und README nach den Verschiebungen lesbar.
    $Replacements = @{
        "docs/backup-strategie-gfs.md" = "docs/operations/backup-strategie-gfs.md"
        "docs/troubleshooting-backup-restore.md" = "docs/troubleshooting/troubleshooting-backup-restore.md"
        "docs/runtime-dependency-redis-outage.md" = "docs/labs/runtime-dependency-redis-outage.md"
        "docs/runtime-dependency-redis-outage-enterprise.md" = "docs/labs/runtime-dependency-redis-outage-enterprise.md"
        "docs/simulation-b-kommentierte-befehle.md" = "docs/labs/simulation-b-kommentierte-befehle.md"

        "scripts/backup-and-test-redis.ps1" = "scripts/backup/backup-and-test-redis.ps1"
        "scripts/backup-redis-volume.ps1" = "scripts/backup/backup-redis-volume.ps1"
        "scripts/cleanup-old-backups.ps1" = "scripts/retention/cleanup-old-backups.ps1"
        "scripts/simulate-gfs-retention.ps1" = "scripts/retention/simulate-gfs-retention.ps1"
        "scripts/simulate-restore-value-mismatch.ps1" = "scripts/incidents/simulate-restore-value-mismatch.ps1"
        "scripts/simulate-runtime-redis-outage.ps1" = "scripts/incidents/simulate-runtime-redis-outage.ps1"
        "scripts/test-redis-restore.ps1" = "scripts/restore/test-redis-restore.ps1"

        "scripts\backup-and-test-redis.ps1" = "scripts\backup\backup-and-test-redis.ps1"
        "scripts\backup-redis-volume.ps1" = "scripts\backup\backup-redis-volume.ps1"
        "scripts\cleanup-old-backups.ps1" = "scripts\retention\cleanup-old-backups.ps1"
        "scripts\simulate-gfs-retention.ps1" = "scripts\retention\simulate-gfs-retention.ps1"
        "scripts\simulate-restore-value-mismatch.ps1" = "scripts\incidents\simulate-restore-value-mismatch.ps1"
        "scripts\simulate-runtime-redis-outage.ps1" = "scripts\incidents\simulate-runtime-redis-outage.ps1"
        "scripts\test-redis-restore.ps1" = "scripts\restore\test-redis-restore.ps1"
    }

    # Markdown-Dateien und README.md suchen.
    $Files = @()
    if (Test-Path "README.md") {
        $Files += Get-Item "README.md"
    }
    if (Test-Path "docs") {
        $Files += Get-ChildItem "docs" -Recurse -File -Include "*.md"
    }

    foreach ($File in $Files) {
        $Original = Get-Content $File.FullName -Raw
        $Updated = $Original

        foreach ($Key in $Replacements.Keys) {
            $Updated = $Updated.Replace($Key, $Replacements[$Key])
        }

        if ($Updated -ne $Original) {
            if ($DryRun) {
                Write-Host "[DRYRUN] Pfadverweise aktualisieren: $($File.FullName)"
            } else {
                Set-Content -Path $File.FullName -Value $Updated -NoNewline
                Write-Host "[OK] Pfadverweise aktualisiert: $($File.FullName)"
            }
        }
    }
}

# 1) Zielordner erstellen.
# Grund: Eine klare Ordnerstruktur hilft später bei Portfolio, Betrieb und Kursmaterial.
$TargetDirectories = @(
    "archive",
    "docs\architecture",
    "docs\labs",
    "docs\operations",
    "docs\troubleshooting",
    "scripts\backup",
    "scripts\restore",
    "scripts\retention",
    "scripts\incidents",
    "scripts\maintenance"
)

foreach ($Directory in $TargetDirectories) {
    if (-not (Test-Path $Directory)) {
        if ($DryRun) {
            Write-Host "[DRYRUN] Ordner erstellen: $Directory"
        } else {
            New-Item -ItemType Directory -Path $Directory -Force | Out-Null
            Write-Host "[OK] Ordner erstellt: $Directory"
        }
    }
}

# 2) Alte Compose-Datei archivieren.
# Grund: Nicht direkt löschen, sondern nachvollziehbar aus dem aktiven Root entfernen.
Move-ProjectFile "docker-compose_alt.yml" "archive\docker-compose_alt.yml"

# 3) Dokumentation thematisch sortieren.
# Grund: Doku wird ab jetzt nach Betriebszweck strukturiert.
Move-ProjectFile "docs\backup-strategie-gfs.md" "docs\operations\backup-strategie-gfs.md"
Move-ProjectFile "docs\troubleshooting-backup-restore.md" "docs\troubleshooting\troubleshooting-backup-restore.md"
Move-ProjectFile "docs\runtime-dependency-redis-outage.md" "docs\labs\runtime-dependency-redis-outage.md"
Move-ProjectFile "docs\runtime-dependency-redis-outage-enterprise.md" "docs\labs\runtime-dependency-redis-outage-enterprise.md"
Move-ProjectFile "docs\simulation-b-kommentierte-befehle.md" "docs\labs\simulation-b-kommentierte-befehle.md"

# 4) Skripte thematisch sortieren.
# Grund: Spätere Schüler und du selbst finden Backup-, Restore- und Incident-Skripte schneller.
Move-ProjectFile "scripts\backup-and-test-redis.ps1" "scripts\backup\backup-and-test-redis.ps1"
Move-ProjectFile "scripts\backup-redis-volume.ps1" "scripts\backup\backup-redis-volume.ps1"
Move-ProjectFile "scripts\cleanup-old-backups.ps1" "scripts\retention\cleanup-old-backups.ps1"
Move-ProjectFile "scripts\simulate-gfs-retention.ps1" "scripts\retention\simulate-gfs-retention.ps1"
Move-ProjectFile "scripts\simulate-restore-value-mismatch.ps1" "scripts\incidents\simulate-restore-value-mismatch.ps1"
Move-ProjectFile "scripts\simulate-runtime-redis-outage.ps1" "scripts\incidents\simulate-runtime-redis-outage.ps1"
Move-ProjectFile "scripts\test-redis-restore.ps1" "scripts\restore\test-redis-restore.ps1"

# 5) Undatiertes Backup vereinheitlichen.
# Grund: Backups sollten eindeutig über Zeitstempel identifizierbar sein.
Rename-LegacyBackup

# 6) Pfadverweise in README und docs aktualisieren.
# Grund: Nach Verschiebungen sollen Dokumentationslinks und Befehle nicht auf alte Pfade zeigen.
Update-PathReferences

Write-Host ""
Write-Host "=== Aufraeumrunde abgeschlossen ===" -ForegroundColor Cyan
Write-Host ""

# Git-Status anzeigen.
# Grund: Vor dem Commit musst du sehen, was genau geändert wurde.
Write-Host "Git-Status nach der Aufraeumrunde:"
git status --short

Write-Host ""
Write-Host "Naechste sinnvolle Pruefbefehle:"
Write-Host "  git status"
Write-Host "  git diff --stat"
Write-Host "  docker compose -f compose.prod.yml config"
Write-Host "  docker compose -f compose.prod.yml ps"
