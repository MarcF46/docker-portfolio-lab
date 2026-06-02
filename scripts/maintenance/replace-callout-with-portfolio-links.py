from pathlib import Path

index_path = Path("index.html")
text = index_path.read_text(encoding="utf-8")

old_callout = '''    <section class="section callout">
      <div>
        <p class="eyebrow">Einordnung</p>
        <h2>Portfolio mit Betriebsfokus</h2>
        <p>
          Der Schwerpunkt liegt auf Betriebsdenken: prüfen, dokumentieren, absichern,
          Fehler nachvollziehen und technische Entscheidungen begründen.
        </p>
      </div>
      <a class="button primary" href="https://github.com/MarcF46/docker-portfolio-lab" target="_blank" rel="noopener noreferrer">
        Code und Dokumentation ansehen
      </a>
    </section>'''

new_links_section = '''    <section class="section" id="portfolio-links">
      <div class="section-heading">
        <p class="eyebrow">Portfolio-Links</p>
        <h2>Weitere Nachweise und Profile</h2>
        <p>
          Zentrale Links zu meinem GitHub-Profil, LinkedIn-Profil und den aktuellen Portfolio-Projekten.
        </p>
      </div>

      <div class="link-grid">
        <a class="doc-link" href="https://github.com/MarcF46" target="_blank" rel="noopener noreferrer">
          <span>GitHub-Profil</span>
          <small>Übersicht über öffentliche Repositories und Lernprojekte</small>
        </a>
        <a class="doc-link" href="https://www.linkedin.com/in/marc-fahlbusch-1762b3335" target="_blank" rel="noopener noreferrer">
          <span>LinkedIn-Profil</span>
          <small>Berufliches Profil, Lernfortschritte und Projektupdates</small>
        </a>
        <a class="doc-link" href="https://github.com/MarcF46/docker-portfolio-lab" target="_blank" rel="noopener noreferrer">
          <span>Docker Portfolio Lab</span>
          <small>Docker-/DevOps-Lab mit Betriebsfokus, Monitoring, Security und CI/CD</small>
        </a>
        <a class="doc-link" href="https://github.com/MarcF46/linux-borg-backup-restore-lab" target="_blank" rel="noopener noreferrer">
          <span>Linux Borg Backup & Restore Lab</span>
          <small>Backup- und Restore-Lab mit BorgBackup unter Linux/WSL2</small>
        </a>
        <a class="doc-link" href="#top">
          <span>Zurück nach oben</span>
          <small>Zurück zum Einstieg dieser Portfolio-Seite</small>
        </a>
      </div>
    </section>'''

if old_callout not in text:
    raise SystemExit("Old callout section not found. Nothing changed.")

text = text.replace(old_callout, new_links_section, 1)

# Ensure the page has a top anchor for the "Zurück nach oben" link.
text = text.replace("<body>", '<body id="top">', 1)

index_path.write_text(text, encoding="utf-8")
print("Replaced final callout with minimalist portfolio links section.")
