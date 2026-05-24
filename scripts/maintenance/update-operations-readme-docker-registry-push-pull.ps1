<#
.SYNOPSIS
  Aktualisiert docs/operations/README.md nach der Docker Registry Push/Pull/Digest Doku.

.DESCRIPTION
  Dieses Skript ergänzt die Operations-Dokumentationsübersicht:
  - Tabellenzeile für docker-registry-push-pull.md
  - Abschnitt "Docker Registry, Push, Pull und Digest"

  Zweck:
  Die neue Registry-Doku soll in der zentralen Operations-Übersicht auffindbar sein.

  Das Skript ist idempotent:
  - Vorhandene Tabellenzeilen werden nicht doppelt eingefügt.
  - Vorhandene Abschnitte werden nicht doppelt eingefügt.
#>

$ErrorActionPreference = "Stop"

# Das Skript liegt in scripts\maintenance.
# Von dort gehen wir zwei Ebenen nach oben in die Projektwurzel.
$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptLocation "..\..")
Set-Location $ProjectRoot

$Path = ".\docs\operations\README.md"

if (-not (Test-Path $Path)) {
    throw "docs/operations/README.md wurde nicht gefunden."
}

Write-Host ""
Write-Host "=== Operations-README Docker Registry Push/Pull Aktualisierung ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Readme = Get-Content $Path -Raw

$PatternsLine = "| monitoring-incident-patterns.md | Monitoring Incident Patterns | Vergleich Redis-, Prometheus-, Grafana- und cAdvisor-Ausfall |"
$TargetHealthLine = "| prometheus-target-health-cadvisor.md | Prometheus Target Health: cAdvisor | Prometheus Targets, Query up, cAdvisor UP/DOWN einordnen |"
$RegistryLine = "| docker-registry-push-pull.md | Docker Registry, Push, Pull und Digest | lokale Registry, Image push/pull, Compose-Registry-Test und Digest-Fehlerbild |"

# 1) Tabellenzeile ergänzen.
if ($Readme.Contains($RegistryLine)) {
    Write-Host "[INFO] Docker-Registry-Tabellenzeile ist bereits vorhanden."
}
elseif ($Readme.Contains($PatternsLine)) {
    $Readme = $Readme.Replace($PatternsLine, "$PatternsLine`r`n$RegistryLine")
    Write-Host "[OK] Docker-Registry-Tabellenzeile nach Monitoring-Incident-Patterns eingefügt."
}
elseif ($Readme.Contains($TargetHealthLine)) {
    $Readme = $Readme.Replace($TargetHealthLine, "$TargetHealthLine`r`n$RegistryLine")
    Write-Host "[OK] Docker-Registry-Tabellenzeile nach Prometheus-Target-Health eingefügt."
}
else {
    throw "Kein Tabellenanker gefunden. Erwartet wurde monitoring-incident-patterns.md oder prometheus-target-health-cadvisor.md."
}

# 2) Abschnitt ergänzen.
$RegistrySection = @'

### Docker Registry, Push, Pull und Digest

Relevantes Dokument:

```text
docker-registry-push-pull.md
```

Gezeigte Fähigkeiten:

```text
lokale Registry starten
Image für Registry taggen
Image in Registry pushen
Image aus Registry pullen
Registry per API prüfen
Compose mit fertigem Registry-Image nutzen
Digest auslesen und einordnen
Fehler durch fehlende Registry-Adresse erkennen
```

Einordnung:

```text
Diese Doku zeigt den Unterschied zwischen lokalem Docker Image Store,
Docker Build Cache und Registry.
Sie erklärt außerdem, warum ein Digest genauer ist als ein Tag
und warum die Registry-Adresse beim Pull entscheidend ist.
```

Wichtige Erkenntnis:

```text
Git speichert Code.
Docker baut daraus Images.
Die Registry verteilt Images an Server, Cloud oder Kubernetes.
Der Digest beschreibt einen eindeutigen Image-Inhalt.
```

'@

if ($Readme -match '(?m)^### Docker Registry, Push, Pull und Digest\s*$') {
    Write-Host "[INFO] Abschnitt 'Docker Registry, Push, Pull und Digest' ist bereits vorhanden."
}
elseif ($Readme -match '(?m)^### Monitoring Incident Patterns\s*$') {
    $Readme = $Readme -replace '(?m)^### Monitoring Incident Patterns\s*$', ($RegistrySection.TrimEnd() + "`r`n`r`n### Monitoring Incident Patterns")
    Write-Host "[OK] Docker-Registry-Abschnitt vor Monitoring Incident Patterns eingefügt."
}
elseif ($Readme -match '(?m)^### Prometheus Target Health: cAdvisor\s*$') {
    $Readme = $Readme -replace '(?m)^### Prometheus Target Health: cAdvisor\s*$', ($RegistrySection.TrimEnd() + "`r`n`r`n### Prometheus Target Health: cAdvisor")
    Write-Host "[OK] Docker-Registry-Abschnitt vor Prometheus Target Health eingefügt."
}
else {
    throw "Kein Abschnittsanker gefunden. Erwartet wurde 'Monitoring Incident Patterns' oder 'Prometheus Target Health: cAdvisor'."
}

Set-Content -Path $Path -Value $Readme -Encoding UTF8

Write-Host ""
Write-Host "[OK] docs/operations/README.md wurde aktualisiert." -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\docs\operations\README.md -Pattern 'docker-registry-push-pull.md', 'Docker Registry, Push, Pull und Digest', 'lokale Registry', 'Digest'"
Write-Host "  git diff --stat docs/operations/README.md"
Write-Host ""
