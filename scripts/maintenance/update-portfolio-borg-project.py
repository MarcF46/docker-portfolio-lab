from pathlib import Path

repo_root = Path.cwd()
index_path = repo_root / "index.html"

text = index_path.read_text(encoding="utf-8")

nav_anchor = '        <a href="#docs">Dokumentation</a>'
nav_addition = '        <a href="#external-projects">Weitere Projekte</a>\n' + nav_anchor

if 'href="#external-projects"' not in text:
    if nav_anchor not in text:
        raise SystemExit("Navigation marker not found.")
    text = text.replace(nav_anchor, nav_addition, 1)

docs_marker = '    <section class="section" id="docs">'

borg_section = '''    <section class="section split-section" id="external-projects">
      <div>
        <p class="eyebrow">Weitere Portfolio-Projekte</p>
        <h2>Linux Borg Backup & Restore Lab</h2>
        <p>
          Ergänzendes Linux-Backup- und Restore-Lab mit BorgBackup. Das Projekt zeigt,
          wie ein verschlüsseltes Backup-Repository erstellt, Testdaten gesichert,
          eine gelöschte Datei wiederhergestellt und der Restore anschließend überprüft wird.
        </p>
        <div class="hero-actions">
          <a class="button primary" href="https://github.com/MarcF46/linux-borg-backup-restore-lab" target="_blank" rel="noopener noreferrer">
            Borg Backup Lab öffnen
          </a>
        </div>
      </div>

      <div class="proof-list">
        <div class="proof-item">
          <span>01</span>
          <p>Ich kann mit BorgBackup ein verschlüsseltes Backup-Repository unter Linux/WSL2 erstellen.</p>
        </div>
        <div class="proof-item">
          <span>02</span>
          <p>Ich kann Testdaten sichern, Archivinhalte prüfen und eine gelöschte Datei wiederherstellen.</p>
        </div>
        <div class="proof-item">
          <span>03</span>
          <p>Ich kann einen Restore-Test dokumentieren und mit <code>borg check</code> ergänzend prüfen.</p>
        </div>
        <div class="proof-item">
          <span>04</span>
          <p>Ich beachte Sicherheitsgrenzen wie Passphrases, lokale Backup-Repositories und <code>.gitignore</code>.</p>
        </div>
      </div>
    </section>

'''

if 'id="external-projects"' not in text:
    if docs_marker not in text:
        raise SystemExit("Docs section marker not found.")
    text = text.replace(docs_marker, borg_section + docs_marker, 1)
else:
    print("Borg portfolio section already exists. No duplicate section inserted.")

index_path.write_text(text, encoding="utf-8")
print("Updated index.html with Borg Backup portfolio section.")
