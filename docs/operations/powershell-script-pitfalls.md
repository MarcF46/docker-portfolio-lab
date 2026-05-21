# PowerShell-Skriptfallen im Docker Lab

## Zweck

Diese kurze Dokumentation hält typische PowerShell-Fallen fest, die im Docker Portfolio Lab beim Arbeiten mit Maintenance-Skripten und Terminal-Blöcken aufgetreten sind.

Ziel ist nicht, PowerShell vollständig zu erklären, sondern wiederkehrende Fehlerbilder schneller zu erkennen.

---

## 1. ExecutionPolicy: Skriptausführung blockiert

### Typisches Symptom

Beim Ausführen eines `.ps1`-Skripts erscheint eine Meldung wie:

```text
cannot be loaded because running scripts is disabled
```

oder:

```text
is not digitally signed. You cannot run this script on the current system.
```

### Bedeutung

PowerShell blockiert die Ausführung des Skripts aus Sicherheitsgründen.

Das Skript selbst kann technisch korrekt sein, wird aber wegen der aktuellen Ausführungsrichtlinie nicht gestartet.

### Lösung im Lab

Für das aktuelle Terminalfenster:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### Wichtige Einordnung

```text
Scope Process bedeutet:
Die Erlaubnis gilt nur für dieses aktuelle Terminalfenster.
```

Wenn VS Code oder PowerShell neu gestartet wird, ist diese temporäre Erlaubnis wieder weg.

### Merksatz

```text
Neues Terminal = Set-ExecutionPolicy bei Bedarf erneut setzen.
```

---

## 2. ParserError: Syntaxfehler im Skript

### Typisches Symptom

PowerShell meldet:

```text
ParserError
```

oder:

```text
The Unicode escape sequence is not valid.
```

### Bedeutung

PowerShell konnte das Skript nicht korrekt einlesen.

Das ist kein Sicherheitsproblem und wird nicht durch `Set-ExecutionPolicy` gelöst.

### Wichtig

```text
Set-ExecutionPolicy hilft bei blockierter Skriptausführung.
Set-ExecutionPolicy hilft NICHT bei Syntaxfehlern im Skript.
```

Wenn ein Skript einen ParserError hat, muss der Skriptinhalt korrigiert werden.

---

## 3. Backtick in PowerShell

### Zeichen

Der Backtick sieht so aus:

```text
`
```

Er ist nicht dasselbe wie ein Apostroph:

```text
'
```

und nicht dasselbe wie ein Akzent:

```text
´
```

### Problem

In PowerShell ist der Backtick ein Escape-Zeichen.

Das bedeutet: PowerShell behandelt ihn nicht immer als normalen Text.

### Beispielproblem

Markdown nutzt Backticks häufig für Inline-Code:

```markdown
Query `up`
```

In einem PowerShell-String kann daraus ein Problem werden, weil PowerShell `u als Sondersequenz lesen kann.

Dann kann eine Fehlermeldung entstehen wie:

```text
The Unicode escape sequence is not valid.
```

### Sichere Variante

In PowerShell-Skripten für README-Text besser vermeiden:

```text
Query up
```

oder sehr bewusst mit einfachen Anführungszeichen arbeiten.

### Merksatz

```text
Backtick ist in Markdown harmlos,
aber in PowerShell ein Sonderzeichen.
```

---

## 4. Here-Strings in PowerShell

### Start und Ende

Ein PowerShell-Here-String kann so aussehen:

```powershell
$Text = @'
Hier steht langer Text.
Auch mehrere Zeilen.
'@
```

### Bedeutung

```text
@'  startet den Textblock.
'@  beendet den Textblock.
```

### Typisches Symptom bei Fehler

Das Terminal zeigt weiter:

```powershell
>>
```

und scheint nicht weiterzumachen.

### Bedeutung

PowerShell wartet noch auf das Ende des Blocks.

Der Computer arbeitet dann nicht unbedingt. PowerShell wartet nur auf weitere Eingabe.

### Abbrechen

Wenn man versehentlich in so einem offenen Block gelandet ist:

```text
Ctrl + C
```

### Merksatz

```text
Wenn PowerShell mit >> weiterfragt,
ist meistens noch ein Block offen.
```

Typische Ursachen:

```text
offener Here-String
offenes Anführungszeichen
offene Klammer
offener if/else-Block
```

---

## 5. if / elseif / else muss zusammenhängend ausgeführt werden

### Problem

PowerShell akzeptiert `elseif` und `else` nur als Teil desselben zusammenhängenden Blocks.

### Falsch

```powershell
if ($Condition) {
    Write-Host "Ja"
}

elseif ($OtherCondition) {
    Write-Host "Vielleicht"
}
```

Wenn der erste Block schon abgeschlossen wurde, kann `elseif` danach als eigener Befehl interpretiert werden.

Dann erscheint:

```text
elseif: The term 'elseif' is not recognized
```

### Richtig

Alles zusammenhängend ausführen:

```powershell
if ($Condition) {
    Write-Host "Ja"
}
elseif ($OtherCondition) {
    Write-Host "Vielleicht"
}
else {
    Write-Host "Nein"
}
```

### Merksatz

```text
if / elseif / else gehört in PowerShell als ein zusammenhängender Block zusammen.
```

---

## 6. Wann Skript, wann direkte Änderung?

### Skript sinnvoll

Ein Maintenance-Skript ist sinnvoll, wenn:

```text
mehrere Änderungen zuverlässig wiederholt werden sollen
mehrere Stellen in einer Datei angepasst werden
eine Änderung später nachvollziehbar bleiben soll
```

### Direkte Änderung sinnvoll

Eine direkte kleine Änderung ist sinnvoll, wenn:

```text
nur eine Tabellenzeile ergänzt wird
nur ein kleiner Text ersetzt wird
ein Skript mehr Komplexität erzeugt als Nutzen bringt
```

Beispiel:

```powershell
$Readme = $Readme.Replace($Anchor, "$Anchor`r`n$Line")
```

### Merksatz

```text
Nicht jede kleine README-Änderung braucht ein eigenes Maintenance-Skript.
```

---

## 7. Diagnoseweg bei Skriptproblemen

Wenn ein Skript fehlschlägt:

```text
1. Fehlermeldung genau lesen.
2. Ist es ExecutionPolicy oder ParserError?
3. Bei ExecutionPolicy: Scope Process setzen.
4. Bei ParserError: Skriptinhalt prüfen.
5. Bei offenem Terminalblock: auf >> achten.
6. Bei kleinen Änderungen: notfalls direkt und gezielt ändern.
7. Danach mit git status und Select-String prüfen.
```

---

## 8. Verifikationsbefehle

Nach einer Dateiänderung:

```powershell
git status
```

Sucht wichtige Begriffe:

```powershell
Select-String -Path .\docs\operations\README.md -Pattern "Suchbegriff1", "Suchbegriff2"
```

Zeigt Änderungssumme:

```powershell
git diff --stat docs/operations/README.md
```

### Einordnung

```text
git status zeigt, welche Dateien geändert sind.
Select-String zeigt, ob erwartete Inhalte vorhanden sind.
git diff --stat zeigt, wie groß die Änderung ist.
```

---

## 9. Wichtigster Lernpunkt

```text
PowerShell-Fehler sauber unterscheiden:

ExecutionPolicy:
Skript darf nicht ausgeführt werden.

ParserError:
Skript ist syntaktisch kaputt oder enthält problematische Zeichen.

Offener Block:
PowerShell wartet noch auf das Ende einer Eingabe.
```

Diese Unterscheidung spart im Betrieb viel Zeit.
