## Projektstruktur

Dieses Repository ist als praxisnahes Docker-/DevOps-Lernprojekt aufgebaut. Die Struktur trennt Anwendung, Konfiguration, Dokumentation, Skripte, Logs und Backups bewusst voneinander.

```text
├── app/                 # einfache Web-App / HTML-Inhalt
├── archive/             # alte oder nicht mehr aktive Dateien
├── backups/             # lokale Redis-Backup-Dateien
├── docs/                # Dokumentation, Labs, Betrieb, Architektur, Troubleshooting
├── logs/                # lokale Logdateien; echte Logs werden nicht committed
├── scripts/             # PowerShell-Skripte für Backup, Restore, Retention und Incidents
├── compose.dev.yml      # Development-Compose-Datei
├── compose.prod.yml     # produktionsnahe Compose-Datei
├── Dockerfile           # Image-Bauanleitung für den Webcontainer
└── README.md            # Einstieg und Projektübersicht
```

Unter `docs/` werden die Inhalte nach Zweck sortiert:

```text
docs/
├── architecture/        # Architektur- und Strukturentscheidungen
├── labs/                # praktische Übungseinheiten und Simulationen
├── operations/          # Betriebsprozesse, z. B. Backup-Strategie
└── troubleshooting/     # Fehleranalyse und Wiederherstellung
```

Unter `scripts/` werden Automatisierungen nach Aufgabe sortiert:

```text
scripts/
├── backup/              # Backup-Skripte
├── restore/             # Restore- und Testskripte
├── retention/           # Aufbewahrungs- und GFS-Simulationen
├── incidents/           # realistische Fehler- und Ausfallsimulationen
└── maintenance/         # Projektpflege und Strukturwartung
```

Ziel dieser Struktur ist, dass ein anderer Engineer schnell erkennt, welche Dateien für Betrieb, Diagnose, Wiederherstellung und Weiterentwicklung relevant sind.
