# simulate-gfs-retention.ps1
# Zweck:
# Dieses Skript simuliert eine GFS-Retention-Strategie fuer Redis-Backups.
#
# GFS bedeutet Grandfather-Father-Son.
# Auf Deutsch: Grossvater-Vater-Sohn.
#
# Dieses Skript arbeitet NUR mit simulierten Backup-Dateien.
# Es loescht keine echten Dateien.
# Es veraendert keine echten Dateien.
#
# Ziel:
# Erst verstehen und pruefen, welche Backups nach GFS-Regeln geschuetzt waeren,
# bevor spaeter echte Loeschlogik gebaut wird.

param(
    # Wie viele Tage in die Vergangenheit simuliert werden sollen.
    [int]$DaysToSimulate = 420,

    # Wie viele taegliche Backups inklusive heute behalten werden sollen.
    [int]$DailyRetentionDays = 14,

    # Wie viele woechentliche Backups behalten werden sollen.
    [int]$WeeklyRetentionWeeks = 8,

    # Wie viele monatliche Backups behalten werden sollen.
    [int]$MonthlyRetentionMonths = 12,

    # Wie viele jaehrliche Backups behalten werden sollen.
    [int]$YearlyRetentionYears = 5
)

$ErrorActionPreference = "Stop"

Write-Host "Starte GFS-Retention-Simulation..."
Write-Host ""
Write-Host "Diese Simulation arbeitet nur mit fiktiven Backup-Dateien."
Write-Host "Es werden keine echten Dateien erstellt, veraendert oder geloescht."
Write-Host ""

$Today = (Get-Date).Date

Write-Host "Simulationsdatum: $Today"
Write-Host "Simulierte Tage rueckwaerts: $DaysToSimulate"
Write-Host ""
Write-Host "Regeln:"
Write-Host "- Daily:   letzte $DailyRetentionDays Tage inklusive heute"
Write-Host "- Weekly:  letzte $WeeklyRetentionWeeks Wochen, jeweils Sonntags-Backup"
Write-Host "- Monthly: letzte $MonthlyRetentionMonths Monatsstaende, jeweils Monatsanfang"
Write-Host "- Yearly:  letzte $YearlyRetentionYears Jahresstaende, jeweils Jahresanfang"
Write-Host ""

# Fiktive Backup-Liste erzeugen.
# Es wird angenommen, dass es fuer jeden Tag ein Backup gibt.
$SimulatedBackups = @()

for ($i = 0; $i -lt $DaysToSimulate; $i++) {
    $Date = $Today.AddDays(-$i)

    $FileName = "redis_data_prod_backup_{0}.tar.gz" -f $Date.ToString("yyyy-MM-dd")

    $SimulatedBackups += [PSCustomObject]@{
        Date = $Date
        FileName = $FileName
        KeepReasons = @()
        Decision = "DELETE_CANDIDATE"
    }
}

# Stichtage berechnen.
# DailyRetentionDays soll inklusive heute genau diese Anzahl an Tagen behalten.
# Beispiel:
# DailyRetentionDays = 7 bedeutet heute + 6 Tage zurueck = 7 Backups.
$DailyCutoff = $Today.AddDays(-($DailyRetentionDays - 1))

# Weekly arbeitet mit Sonntags-Backups innerhalb des Wochenfensters.
$WeeklyCutoff = $Today.AddDays(-7 * $WeeklyRetentionWeeks)

# Monthly soll exakt Monatsstaende zaehlen.
# Beispiel:
# Wenn heute Mai 2026 ist und MonthlyRetentionMonths = 6,
# dann sollen Monatsanfang Mai, April, Maerz, Februar, Januar und Dezember geschuetzt werden.
$CurrentMonthStart = [datetime]::new($Today.Year, $Today.Month, 1)
$MonthlyCutoff = $CurrentMonthStart.AddMonths(-($MonthlyRetentionMonths - 1))

# Yearly soll exakt Jahresstaende zaehlen.
# Beispiel:
# Wenn heute 2026 ist und YearlyRetentionYears = 5,
# dann sollen Jahresanfang 2026, 2025, 2024, 2023 und 2022 geschuetzt werden,
# sofern diese simulierten Backups in der erzeugten Liste vorhanden sind.
$CurrentYearStart = [datetime]::new($Today.Year, 1, 1)
$YearlyCutoff = $CurrentYearStart.AddYears(-($YearlyRetentionYears - 1))

# GFS-Regeln anwenden.
foreach ($Backup in $SimulatedBackups) {

    # Daily-Regel:
    # Alles innerhalb der letzten X Tage inklusive heute behalten.
    if ($Backup.Date -ge $DailyCutoff) {
        $Backup.KeepReasons += "DAILY"
    }

    # Weekly-Regel:
    # Sonntags-Backups innerhalb der letzten X Wochen behalten.
    if (($Backup.Date.DayOfWeek -eq "Sunday") -and ($Backup.Date -ge $WeeklyCutoff)) {
        $Backup.KeepReasons += "WEEKLY"
    }

    # Monthly-Regel:
    # Backups vom 1. Tag des Monats innerhalb der letzten X Monatsstaende behalten.
    if (($Backup.Date.Day -eq 1) -and ($Backup.Date -ge $MonthlyCutoff)) {
        $Backup.KeepReasons += "MONTHLY"
    }

    # Yearly-Regel:
    # Backups vom 1. Januar innerhalb der letzten X Jahresstaende behalten.
    if (($Backup.Date.Month -eq 1) -and ($Backup.Date.Day -eq 1) -and ($Backup.Date -ge $YearlyCutoff)) {
        $Backup.KeepReasons += "YEARLY"
    }

    if ($Backup.KeepReasons.Count -gt 0) {
        $Backup.Decision = "KEEP"
    }
}

# Fuer bessere Anzeige KeepReasons als Text ausgeben.
$Result = $SimulatedBackups | ForEach-Object {
    [PSCustomObject]@{
        Date = $_.Date.ToString("yyyy-MM-dd")
        FileName = $_.FileName
        KeepReasons = if ($_.KeepReasons.Count -gt 0) { ($_.KeepReasons -join ",") } else { "-" }
        Decision = $_.Decision
    }
}

$KeepItems = @($Result | Where-Object { $_.Decision -eq "KEEP" })
$DeleteCandidates = @($Result | Where-Object { $_.Decision -eq "DELETE_CANDIDATE" })

$DailyCount = @($KeepItems | Where-Object { $_.KeepReasons -match "DAILY" }).Count
$WeeklyCount = @($KeepItems | Where-Object { $_.KeepReasons -match "WEEKLY" }).Count
$MonthlyCount = @($KeepItems | Where-Object { $_.KeepReasons -match "MONTHLY" }).Count
$YearlyCount = @($KeepItems | Where-Object { $_.KeepReasons -match "YEARLY" }).Count

Write-Host "=============================================="
Write-Host "ZUSAMMENFASSUNG"
Write-Host "=============================================="
Write-Host ""

Write-Host "Simulierte Backup-Dateien insgesamt: $($Result.Count)"
Write-Host "Davon geschuetzt nach GFS-Regeln:     $($KeepItems.Count)"
Write-Host "Theoretische Loeschkandidaten:        $($DeleteCandidates.Count)"
Write-Host ""

Write-Host "Geschuetzte Backups nach Kategorie:"
Write-Host "- DAILY:   $DailyCount"
Write-Host "- WEEKLY:  $WeeklyCount"
Write-Host "- MONTHLY: $MonthlyCount"
Write-Host "- YEARLY:  $YearlyCount"
Write-Host ""

Write-Host "=============================================="
Write-Host "GESCHUETZTE BACKUPS"
Write-Host "=============================================="
Write-Host ""

$KeepItems |
    Sort-Object Date -Descending |
    Select-Object -First 80 |
    Format-Table -AutoSize

Write-Host ""
Write-Host "=============================================="
Write-Host "ERSTE THEORETISCHE LOESCHKANDIDATEN"
Write-Host "=============================================="
Write-Host ""

$DeleteCandidates |
    Sort-Object Date -Descending |
    Select-Object -First 40 |
    Format-Table -AutoSize

Write-Host ""
Write-Host "=============================================="
Write-Host "ERGEBNIS"
Write-Host "=============================================="
Write-Host ""

Write-Host "GFS-Simulation abgeschlossen."
Write-Host "Es wurde nichts geloescht."
Write-Host "Es wurden keine echten Backup-Dateien erstellt oder veraendert."
Write-Host ""
Write-Host "Interpretation:"
Write-Host "KEEP bedeutet: Dieses Backup wuerde nach mindestens einer GFS-Regel behalten."
Write-Host "DELETE_CANDIDATE bedeutet: Dieses Backup waere theoretisch loeschbar."
Write-Host ""
Write-Host "Wichtig:"
Write-Host "In echter Produktion duerfte Loeschlogik erst nach Restore-Test, Freigabe, Monitoring und Dokumentation aktiv werden."
Write-Host ""
Write-Host "Fertig."