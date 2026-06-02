from pathlib import Path

index_path = Path("index.html")
text = index_path.read_text(encoding="utf-8")

replacements = {
    'href="docs/operations/README.md"':
        'href="https://github.com/MarcF46/docker-portfolio-lab/blob/main/docs/operations/README.md" target="_blank" rel="noopener noreferrer"',
    'href="docs/operations/https-local-nginx.md"':
        'href="https://github.com/MarcF46/docker-portfolio-lab/blob/main/docs/operations/https-local-nginx.md" target="_blank" rel="noopener noreferrer"',
    'href="docs/operations/container-security-stage-1.md"':
        'href="https://github.com/MarcF46/docker-portfolio-lab/blob/main/docs/operations/container-security-stage-1.md" target="_blank" rel="noopener noreferrer"',
    'href="docs/operations/image-scanning-docker-scout.md"':
        'href="https://github.com/MarcF46/docker-portfolio-lab/blob/main/docs/operations/image-scanning-docker-scout.md" target="_blank" rel="noopener noreferrer"',
    'href="docs/operations/prometheus-target-api-check.md"':
        'href="https://github.com/MarcF46/docker-portfolio-lab/blob/main/docs/operations/prometheus-target-api-check.md" target="_blank" rel="noopener noreferrer"',
    'href="docs/operations/registry-deep-dive.md"':
        'href="https://github.com/MarcF46/docker-portfolio-lab/blob/main/docs/operations/registry-deep-dive.md" target="_blank" rel="noopener noreferrer"',
    'href="docs/operations/cicd-build-pipeline.md"':
        'href="https://github.com/MarcF46/docker-portfolio-lab/blob/main/docs/operations/cicd-build-pipeline.md" target="_blank" rel="noopener noreferrer"',
    'href="docs/operations/backup-strategie-gfs.md"':
        'href="https://github.com/MarcF46/docker-portfolio-lab/blob/main/docs/operations/backup-strategie-gfs.md" target="_blank" rel="noopener noreferrer"',
}

changed = False

for old, new in replacements.items():
    if old in text:
        text = text.replace(old, new)
        changed = True

if not changed:
    print("No matching local documentation links found. Nothing changed.")
else:
    index_path.write_text(text, encoding="utf-8")
    print("Updated documentation links to GitHub-rendered Markdown pages.")
