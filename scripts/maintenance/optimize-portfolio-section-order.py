from pathlib import Path

index_path = Path("index.html")
text = index_path.read_text(encoding="utf-8")

# 1) Navigation klarer sortieren und benennen
old_nav = '''        <a href="#skills">Kompetenzen</a>
        <a href="#proof">Nachweise</a>
        <a href="#external-projects">Weitere Projekte</a>
        <a href="#docs">Dokumentation</a>'''

new_nav = '''        <a href="#skills">Kompetenzen</a>
        <a href="#proof">Nachweise</a>
        <a href="#docs">Docker-Dokumentation</a>
        <a href="#external-projects">Weitere Projekte</a>'''

if old_nav in text:
    text = text.replace(old_nav, new_nav, 1)

# 2) Dokumentationsbereich klarer als Docker-Dokumentation benennen
text = text.replace(
    '''        <p class="eyebrow">Dokumentation</p>
        <h2>Technische Vertiefung im Repository</h2>
        <p>
          Diese Links führen zu den wichtigsten Dokumentationsbereichen und Nachweisen im Projekt.
        </p>''',
    '''        <p class="eyebrow">Docker-Dokumentation</p>
        <h2>Technische Vertiefung im Docker Portfolio Lab</h2>
        <p>
          Diese Links führen zu den wichtigsten Dokumentationsbereichen und Nachweisen des Docker-Projekts.
        </p>''',
    1
)

# 3) Borg-Abschnitt nach der Docker-Dokumentation platzieren
section_start = text.find('    <section class="section split-section" id="external-projects">')
if section_start == -1:
    raise SystemExit("Borg section not found.")

next_section = text.find('\n    <section ', section_start + 1)
if next_section == -1:
    raise SystemExit("Could not find end of Borg section.")

borg_section = text[section_start:next_section].strip() + "\n\n"
text_without_borg = text[:section_start] + text[next_section + 1:]

callout_marker = '    <section class="section callout">'
callout_pos = text_without_borg.find(callout_marker)
if callout_pos == -1:
    raise SystemExit("Callout section marker not found.")

text = text_without_borg[:callout_pos] + borg_section + text_without_borg[callout_pos:]

index_path.write_text(text, encoding="utf-8")
print("Optimized portfolio section order.")
