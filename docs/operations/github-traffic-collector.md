# GitHub-Traffic-Collector

## Zweck

Der Traffic-Collector archiviert die GitHub-Traffic-Daten dieses Repositories
dauerhaft. GitHub stellt diese Kennzahlen nur für ein rollierendes aktuelles
Zeitfenster bereit. Ohne Archivierung verschwinden ältere Werte aus der
GitHub-Oberfläche bzw. aus der Traffic-API.

Gesammelt werden:

- Repository-Views
- Repository-Clones
- Top-Referrer
- Popular Paths

Der Collector läuft als GitHub Action und speichert die Ergebnisse unter
`analytics/github-traffic/`.

## Datenfluss

```text
GitHub Actions
    |
    |  TRAFFIC_TOKEN
    v
scripts/collect_github_traffic.py
    |
    +--> GitHub REST API
    |       |
    |       +--> /traffic/views
    |       +--> /traffic/clones
    |       +--> /traffic/popular/referrers
    |       +--> /traffic/popular/paths
    |
    +--> analytics/github-traffic/raw/<date>/
    |
    +--> analytics/github-traffic/summary/
    |
    +--> analytics/github-traffic/README.md
    |
    v
git commit + git push
```

## Workflow

Datei:

```text
.github/workflows/collect-github-traffic.yml
```

Der Workflow kann manuell gestartet werden und läuft zusätzlich einmal täglich
per Cron-Schedule.

### Warum zwei verschiedene Token-Rollen existieren

Es gibt zwei logisch getrennte Aufgaben:

1. Traffic-Daten über die GitHub REST API lesen.
2. Neu erzeugte Statistikdateien zurück in das Repository schreiben.

### TRAFFIC_TOKEN

`TRAFFIC_TOKEN` ist ein Repository-Secret und wird vom Python-Skript für die
Traffic-API verwendet.

Für einen Fine-Grained Personal Access Token wird für dieses Repository
folgende Berechtigung benötigt:

```text
Repository permissions
└── Administration: Read
```

Der Token sollte nur Zugriff auf das benötigte Repository erhalten.

### GITHUB_TOKEN

GitHub Actions erzeugt bei jedem Workflow-Job automatisch einen temporären
`GITHUB_TOKEN`.

Dieser wird in diesem Workflow für den späteren `git push` genutzt. Die
Workflow-Berechtigung

```yaml
permissions:
  contents: write
```

erlaubt das Schreiben der archivierten Dateien zurück in das Repository.

Der automatische `GITHUB_TOKEN` wird bewusst **nicht** als Fallback für die
Traffic-API verwendet. So entsteht kein irreführender zweiter
Authentifizierungsweg.

## Warum der Workflow im Oktober 2026 fehlgeschlagen ist

Run #116 brach im Schritt

```text
Collect GitHub traffic data
```

mit

```text
HTTP 401
Bad credentials
```

ab.

Der Workflow hatte weiterhin ein Secret namens `TRAFFIC_TOKEN`, aber der
hinterlegte Token war nicht mehr gültig. Möglich sind insbesondere:

- Token abgelaufen
- Token widerrufen
- Token ersetzt
- falscher Token im Secret gespeichert

Der neue Collector gibt für HTTP 401 deshalb eine gezielte Fehlermeldung aus.

HTTP 403 wird separat behandelt und weist auf fehlende Berechtigungen oder
fehlenden Repository-Zugriff hin.

## Token erneuern

1. In GitHub einen neuen Fine-Grained Personal Access Token erzeugen.
2. Als Repository nur `MarcF46/docker-portfolio-lab` auswählen.
3. Unter Repository Permissions `Administration: Read` erlauben.
4. Token erzeugen und den Wert kopieren.
5. Repository öffnen.
6. `Settings -> Secrets and variables -> Actions` öffnen.
7. Das Secret `TRAFFIC_TOKEN` aktualisieren.
8. Anschließend den Workflow manuell über `Actions -> Collect GitHub traffic`
   starten.

Der Tokenwert gehört niemals in YAML-, Python-, Markdown- oder Logdateien.

## Archivstruktur

```text
analytics/github-traffic/
├── README.md
├── raw/
│   └── YYYY-MM-DD/
│       ├── views.json
│       ├── clones.json
│       ├── referrers.json
│       └── paths.json
└── summary/
    ├── views_daily.csv
    ├── clones_daily.csv
    ├── monthly.csv
    ├── referrers_latest.csv
    ├── paths_latest.csv
    ├── referrers_snapshots.csv
    └── paths_snapshots.csv
```

## Interpretation der Daten

### Views und Clones

Die Traffic-API liefert Views und Clones mit Tageszeitstempeln. Deshalb können
überlappende API-Fenster anhand des Datums zusammengeführt werden.

`views_daily.csv` und `clones_daily.csv` enthalten deshalb jeweils nur eine
Zeile pro Kalendertag.

### Unique-Werte

Ein täglicher `uniques`-Wert bedeutet nicht, dass sich diese Person bzw.
dieser Client über den gesamten Archivzeitraum nur einmal wiederfindet.

Beispiel:

```text
Montag:    1 Unique
Dienstag:  1 Unique
```

Das können zwei unterschiedliche Besucher sein, aber auch dieselbe Person an
zwei Tagen.

Deshalb heißt die Monatskennzahl bewusst:

```text
views_daily_uniques_sum
```

und nicht:

```text
monthly_unique_visitors
```

### Clone-Zahlen

Clone-Zahlen dürfen nicht direkt als Zahl menschlicher Besucher interpretiert
werden. Automatisierte Git-Clients, Scanner, CI/CD und andere Systeme können
Clone-Aktivität erzeugen.

### Referrer und Popular Paths

Referrer und Popular Paths enthalten keinen Tageszeitstempel pro Ereignis.
Jeder API-Aufruf liefert erneut das aktuelle rollierende Fenster.

Deshalb werden sie als **Snapshots** archiviert:

```text
referrers_snapshots.csv
paths_snapshots.csv
```

Die Werte verschiedener Snapshots dürfen nicht einfach addiert werden, weil
dieselben Zugriffe in mehreren aufeinanderfolgenden Snapshots enthalten sein
können.

## Bereits beobachtete Beispiele

In den historischen Rohdaten wurden unter anderem folgende Referrer gefunden:

```text
linkedin.com
github.com
```

Zu den gespeicherten Popular Paths gehörten unter anderem:

```text
/MarcF46/docker-portfolio-lab
/MarcF46/docker-portfolio-lab/tree/main/.github/workflows
/MarcF46/docker-portfolio-lab/blob/main/docs/operations/backup-strategie-gfs.md
/MarcF46/docker-portfolio-lab/blob/main/ATTRIBUTION.md
/MarcF46/docker-portfolio-lab/issues
/MarcF46/docker-portfolio-lab/pulls
```

Diese Daten zeigen, dass nicht nur die Repository-Startseite, sondern zeitweise
auch technische Unterbereiche und Dokumentation aufgerufen wurden.

## Fehlersuche

### HTTP 401 – Bad credentials

Wahrscheinliche Ursache:

```text
TRAFFIC_TOKEN abgelaufen, widerrufen oder falsch
```

Maßnahme:

```text
Fine-Grained PAT erneuern -> TRAFFIC_TOKEN aktualisieren -> Workflow erneut starten
```

### HTTP 403 – Forbidden

Prüfen:

- Hat der Token Zugriff auf dieses Repository?
- Besitzt er `Administration: Read`?
- Wurde der richtige Token im Secret gespeichert?

### Workflow läuft, aber erzeugt keinen Commit

Der Commit-Schritt prüft mit:

```bash
git status --porcelain analytics/github-traffic
```

ob sich im Analytics-Verzeichnis tatsächlich Dateien geändert haben.

Ohne Änderungen wird absichtlich kein Commit erzeugt.

## Lernziel des Labs

Der Collector verbindet mehrere typische Betriebs- und DevOps-Bausteine:

- GitHub Actions
- Cron-Scheduling
- Secret Management
- REST-API-Aufrufe
- HTTP-Fehlerbehandlung
- Python-Automatisierung
- JSON- und CSV-Verarbeitung
- persistente Langzeitarchivierung
- Git-Commits durch Automation
- nachvollziehbare Betriebsdokumentation

Damit ist der Collector nicht nur eine Statistikfunktion, sondern ein kleines
Automation-Lab mit einem realen Betriebszweck.
