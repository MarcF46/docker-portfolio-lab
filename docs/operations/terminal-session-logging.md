# Terminal-Session-Logging mit PowerShell Transcript

## Zweck

Diese Dokumentation beschreibt, wie Terminal-Sitzungen im Docker-/DevOps-Lernprojekt lokal mitgeschnitten werden können, ohne sensible Logs versehentlich ins Git-Repository zu übernehmen.

Das Ziel ist nicht „mehr Logs um jeden Preis“, sondern kontrollierte Nachvollziehbarkeit:

- Was wurde wann ausgeführt?
- Welche Ausgabe kam zurück?
- Welche Diagnose wurde durchgeführt?
- Welche Informationen dürfen nicht veröffentlicht werden?

---

## 1. Job-Szenario

Ein Incident oder eine Betriebsübung läuft:

> „Redis war kurz nicht verfügbar. Bitte dokumentiere nachvollziehbar, wann welche Befehle ausgeführt wurden und welche Ergebnisse sichtbar waren.“

In einem echten Betrieb ist eine nachvollziehbare Zeitlinie wichtig. Gleichzeitig dürfen Terminal-Logs nicht unkontrolliert geteilt werden, weil sie Passwörter, Tokens, lokale Pfade oder andere sensible Informationen enthalten können.

---

## 2. Betriebsanforderung

| Anforderung | Bedeutung |
|---|---|
| Terminal-Sitzung lokal mitschneiden | Befehle und Ausgaben bleiben nachvollziehbar |
| Datei mit Zeitstempel speichern | mehrere Sessions überschreiben sich nicht |
| Logs nicht committen | Schutz vor Secrets und privaten Informationen |
| `.gitignore` prüfen | Git muss Terminal-Logs ignorieren |
| Security-Hinweis beachten | Logs können sensible Daten enthalten |

---

## 3. Begriffe

| Begriff | Erklärung |
|---|---|
| Terminal | Eingabefenster für Befehle |
| Transcript | Mitschnitt einer PowerShell-Sitzung |
| Timestamp | Zeitstempel im Dateinamen oder in einer Ausgabe |
| Secret | sensibles Geheimnis wie Passwort, Token, API-Key |
| Incident | Betriebsstörung oder untersuchter Fehlerfall |
| Audit | nachvollziehbare Prüfung, wer wann was gemacht hat |

---

## 4. Terminal-Session starten

```powershell
# Wechselt sicher in den Projektordner.
cd "C:\Docker Übung"

# Erstellt einen lokalen Ordner für Terminal-Mitschnitte.
# Dieser Ordner wird durch .gitignore geschützt und soll nicht nach GitHub.
New-Item -ItemType Directory -Force -Path .\logs\terminal-sessions

# Startet einen PowerShell-Mitschnitt.
# Der Zeitstempel im Dateinamen verhindert, dass alte Sessions überschrieben werden.
Start-Transcript -Path ".\logs\terminal-sessions\session_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
```

---

## 5. Beispielbefehle während einer Session

```powershell
# Prüft, ob Docker Compose die Produktionsdatei lesen kann.
docker compose -f compose.prod.yml config

# Prüft, ob die Services laufen und healthy sind.
docker compose -f compose.prod.yml ps

# Prüft, ob Git sauber ist.
git status
```

---

## 6. Terminal-Session beenden

```powershell
# Beendet den Terminal-Mitschnitt.
Stop-Transcript
```

---

## 7. Verifikation

```powershell
# Zeigt die vorhandenen Terminal-Mitschnitte.
Get-ChildItem .\logs\terminal-sessions

# Prüft, ob Terminal-Mitschnitte von Git ignoriert werden.
git check-ignore -v logs/terminal-sessions/test.txt
```

Erwartung:

```text
.gitignore:...:logs/terminal-sessions/   logs/terminal-sessions/test.txt
```

Das bedeutet: Git ignoriert Terminal-Mitschnitte korrekt.

---

## 8. Security-Hinweis

Terminal-Mitschnitte können sensible Informationen enthalten, zum Beispiel:

- Passwörter
- Tokens
- API-Keys
- lokale Pfade
- Benutzernamen
- interne Hostnamen
- IP-Adressen
- Konfigurationen
- Ausgaben von `docker compose config`

Besonders wichtig:

```text
docker compose config kann aufgelöste Umgebungsvariablen anzeigen.
Dadurch können Passwörter oder Secrets im Terminal-Log landen.
```

Deshalb gilt:

```text
Terminal-Logs lokal behalten.
Nicht committen.
Nicht ungeprüft in Tickets, Chats oder Screenshots teilen.
Vor Weitergabe immer auf Secrets prüfen.
```

---

## 9. Realistischer Fehlerfall

Ein Engineer erstellt ein Terminal-Transcript und führt aus:

```powershell
docker compose -f compose.prod.yml config
```

Die Ausgabe enthält ein Redis-Passwort. Wenn das Transcript danach versehentlich committed oder in ein öffentliches Ticket kopiert wird, ist das Secret geleakt.

### Diagnose

```powershell
# Sucht nach bekannten sensiblen Begriffen in Terminal-Logs.
Select-String -Path .\logs\terminal-sessions\*.txt -Pattern "password", "token", "secret", "REDIS_PASSWORD", "requirepass"
```

### Fix

```powershell
# Wenn ein Terminal-Log nicht mehr gebraucht wird:
Remove-Item .\logs\terminal-sessions\<dateiname>.txt

# Wenn eine Datei versehentlich gestaged wurde:
git restore --staged .\logs\terminal-sessions\<dateiname>.txt
```

Wenn ein echtes Secret bereits veröffentlicht wurde, reicht Löschen aus Git nicht aus. Dann muss das Secret rotiert werden, also durch ein neues ersetzt werden.

---

## 10. Unterschied Lernlabor vs. Produktion

| Thema | Lernlabor | Produktion |
|---|---|---|
| Terminal-Mitschnitt | PowerShell Transcript lokal | zentrale Logging-/Audit-Systeme |
| Speicherort | `logs/terminal-sessions/` | geschützte Logplattform, SIEM, Ticket-System |
| Zugriff | nur lokal | rollenbasierte Berechtigungen |
| Secret-Schutz | `.gitignore`, manuelle Kontrolle | Secret Scanning, DLP, Vault, IAM |
| Aufbewahrung | manuell | Retention Policy |
| Weitergabe | nicht ungeprüft | kontrolliert, redigiert, freigegeben |

---

## 11. Portfolio-Formulierung

> Für Betriebs- und Incident-Übungen wurde ein lokales Terminal-Session-Logging eingeführt. PowerShell-Transcripts werden mit Zeitstempel im lokalen Logordner gespeichert und durch `.gitignore` vom Repository ausgeschlossen. Zusätzlich wurde dokumentiert, dass Terminal-Logs sensible Informationen enthalten können und vor jeder Weitergabe geprüft werden müssen.

---

## 12. Architect-Notiz

Die größere Architekturentscheidung lautet:

> Wie schaffen wir Nachvollziehbarkeit, ohne neue Sicherheitsrisiken zu erzeugen?

Logging ist nur dann professionell, wenn es mit Schutzmaßnahmen kombiniert wird:

- Zugriff begrenzen
- Secrets vermeiden
- Logs nicht öffentlich speichern
- Aufbewahrung bewusst regeln
- Weitergabe prüfen
- bei Leaks Secrets rotieren

Gute Betriebsdokumentation heißt nicht „alles speichern“, sondern „das Richtige nachvollziehbar und sicher speichern“.
