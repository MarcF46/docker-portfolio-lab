# Repair README.md mojibake without non-ASCII characters in this script file.
# Example repaired text: geprÃ¼ft -> geprueft with correct German umlaut.
# The script first creates a backup in TEMP.
#
# Why this script is ASCII-only:
# Windows PowerShell 5.1 may read UTF-8 scripts without BOM incorrectly.
# Therefore this file constructs all special characters by character codes.

$path = ".\README.md"

if (-not (Test-Path $path)) {
    Write-Host "STOPP: README.md was not found in the current folder."
    exit 1
}

$resolvedPath = (Resolve-Path $path).Path
$backupPath = Join-Path $env:TEMP ("README-before-encoding-fix-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".md")
Copy-Item -Path $resolvedPath -Destination $backupPath -Force

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText($resolvedPath, $utf8NoBom)

# Build typical mojibake marker characters without writing them literally.
$charAtilde = [string][char]0x00C3
$charAcirc  = [string][char]0x00C2
$charSmallAWithCircumflex = [string][char]0x00E2

if (-not ($content.Contains($charAtilde) -or $content.Contains($charAcirc) -or $content.Contains($charSmallAWithCircumflex))) {
    Write-Host "STOPP: No typical mojibake marker characters found. README.md was not changed."
    Write-Host "Backup: $backupPath"
    exit 0
}

# Convert visible mojibake text back to its original byte sequence using Windows-1252,
# then decode those bytes correctly as UTF-8.
try {
    $cp1252 = [System.Text.Encoding]::GetEncoding(1252)
    $utf8Strict = New-Object System.Text.UTF8Encoding($false, $true)

    $bytes = $cp1252.GetBytes($content)
    $fixed = $utf8Strict.GetString($bytes)

    if ($fixed.Contains([char]0xFFFD)) {
        throw "Decoded text contains replacement characters."
    }

    [System.IO.File]::WriteAllText($resolvedPath, $fixed, $utf8NoBom)

    Write-Host "README.md was repaired and saved as UTF-8 without BOM."
    Write-Host "Backup: $backupPath"
}
catch {
    Copy-Item -Path $backupPath -Destination $resolvedPath -Force
    Write-Host "ERROR: Repair failed. README.md was restored from backup."
    Write-Host $_.Exception.Message
    Write-Host "Backup: $backupPath"
    exit 1
}
