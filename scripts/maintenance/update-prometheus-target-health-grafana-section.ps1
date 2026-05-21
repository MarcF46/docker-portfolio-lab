<#
.SYNOPSIS
  Ergänzt die Prometheus Target Health Doku um die Grafana-Sicht auf den cAdvisor-Ausfall.

.DESCRIPTION
  Dieses Skript aktualisiert:
  - docs/operations/prometheus-target-health-cadvisor.md

  Es fügt einen Abschnitt ein:
  - "Grafana-Sicht auf den cAdvisor-Ausfall"

  Zweck:
  Die Doku soll nicht nur Prometheus Targets und Query up zeigen,
  sondern auch erklären, was ein Supporter in Grafana sieht, wenn cAdvisor ausfällt.

  Das Skript ist idempotent:
  - Wenn der Abschnitt bereits vorhanden ist, wird nichts doppelt eingefügt.
#>

$ErrorActionPreference = "Stop"

# Das Skript liegt in scripts\maintenance.
# Von dort gehen wir zwei Ebenen nach oben in die Projektwurzel.
$ScriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Resolve-Path (Join-Path $ScriptLocation "..\..")
Set-Location $ProjectRoot

$Path = ".\docs\operations\prometheus-target-health-cadvisor.md"

if (-not (Test-Path $Path)) {
    throw "docs/operations/prometheus-target-health-cadvisor.md wurde nicht gefunden."
}

Write-Host ""
Write-Host "=== Prometheus Target Health Doku: Grafana-Sicht ergänzen ===" -ForegroundColor Cyan
Write-Host "Projektordner: $ProjectRoot"
Write-Host ""

$Doc = Get-Content $Path -Raw

$GrafanaSection = @'

## Grafana-Sicht auf den cAdvisor-Ausfall

Zusätzlich zur Prometheus-Sicht wurde das Grafana-Dashboard geprüft.

Dabei wurde sichtbar:

```text
Grafana selbst läuft weiter.
Prometheus läuft weiter.
Die Anwendung läuft weiter.
Aber cAdvisor liefert keine aktuellen Container-Metriken mehr.
```

Im Grafana-Dashboard kann sich das so zeigen:

```text
Prometheus Targets Up fällt von 2 auf 1.
Scrape Samples für cadvisor fallen aus oder gehen auf 0.
Container-CPU- oder Container-Memory-Zeitreihen bekommen Lücken oder laufen nicht weiter.
Nach dem Neustart von cAdvisor kommen neue Messpunkte wieder sichtbar rein.
```

Wichtige Einordnung:

```text
Grafana ist in diesem Szenario nicht die eigentliche Fehlerursache.
Grafana zeigt nur das Symptom.
Die technische Ursache liegt weiter vorne in der Monitoring-Kette:
cAdvisor liefert keine Container-Metriken mehr.
```

Diagnosekette:

```text
Symptom in Grafana:
Dashboard zeigt fehlende oder unterbrochene Container-Metriken.

Nächster Prüfschritt:
Prometheus Targets prüfen.

Bestätigung:
Query up ausführen.

Ursache:
cAdvisor ist DOWN oder nicht erreichbar.

Maßnahme:
cAdvisor wieder starten oder Ursache prüfen.

Verifikation:
Prometheus Target cadvisor wieder UP.
Query up zeigt cadvisor = 1.
Grafana zeigt wieder neue Container-Metriken.
Daily-Operations-Check meldet ERROR: 0.
```

Support-Szenario:

```text
Meldung aus einer Fachabteilung oder vom Monitoring-Bildschirm:
"Im Grafana-Dashboard kommen keine aktuellen Containerdaten mehr an."

Professionelle Einordnung:
Nicht sofort Grafana neu starten.
Zuerst prüfen, ob die Datenquelle und die Metrikquelle funktionieren.
```

Screenshot-Hinweis:

```text
Sinnvolle Screenshots für private Lernunterlagen:
1. Grafana während cAdvisor-Ausfall: Prometheus Targets Up fällt auf 1
2. Grafana nach cAdvisor-Neustart: Prometheus Targets Up geht wieder auf 2
3. Prometheus Targets: cadvisor DOWN
4. Prometheus Query up: cadvisor = 0
```

Merksatz:

```text
Grafana zeigt Symptome.
Prometheus zeigt Target-Zustände.
cAdvisor ist die eigentliche Container-Metrikquelle.
```

'@

if ($Doc -match '(?m)^## Grafana-Sicht auf den cAdvisor-Ausfall\s*$') {
    Write-Host "[INFO] Abschnitt 'Grafana-Sicht auf den cAdvisor-Ausfall' ist bereits vorhanden."
}
elseif ($Doc -match '(?m)^## Mustererkennung\s*$') {
    $Doc = $Doc -replace '(?m)^## Mustererkennung\s*$', ($GrafanaSection.TrimEnd() + "`r`n`r`n## Mustererkennung")
    Set-Content -Path $Path -Value $Doc -Encoding UTF8
    Write-Host "[OK] Grafana-Sicht vor Mustererkennung eingefügt." -ForegroundColor Green
}
elseif ($Doc -match '(?m)^## Kommunikationsstufe A: ultrakurze Statusmeldung\s*$') {
    $Doc = $Doc -replace '(?m)^## Kommunikationsstufe A: ultrakurze Statusmeldung\s*$', ($GrafanaSection.TrimEnd() + "`r`n`r`n## Kommunikationsstufe A: ultrakurze Statusmeldung")
    Set-Content -Path $Path -Value $Doc -Encoding UTF8
    Write-Host "[OK] Grafana-Sicht vor Kommunikationsstufe A eingefügt." -ForegroundColor Green
}
else {
    throw "Kein passender Einfügepunkt gefunden. Erwartet wurde Abschnitt 'Mustererkennung' oder 'Kommunikationsstufe A'."
}

Write-Host ""
Write-Host "Nächste Prüfungen:"
Write-Host "  git status"
Write-Host "  Select-String -Path .\docs\operations\prometheus-target-health-cadvisor.md -Pattern 'Grafana-Sicht', 'Prometheus Targets Up', 'cadvisor = 1', 'Grafana zeigt Symptome'"
Write-Host "  git diff --stat docs/operations/prometheus-target-health-cadvisor.md"
Write-Host ""
