# Repository Traffic & Portfolio Analytics

This document describes the traffic and analytics setup that remains relevant after the central portfolio website was moved out of this repository.

## Current Structure

The responsibilities are now separated:

```text
MarcF46.github.io
└── central portfolio website and GoatCounter pageview/click tracking

MarcF46/docker-portfolio-lab
└── Docker/DevOps lab and GitHub repository traffic archive
```

The public portfolio is available at:

```text
https://marcf46.github.io/
```

The Docker lab remains available at:

```text
https://github.com/MarcF46/docker-portfolio-lab
```

## GitHub Repository Traffic Archive

GitHub repository traffic is collected through a GitHub Actions workflow:

```text
.github/workflows/collect-github-traffic.yml
```

The workflow runs automatically once per day and can also be started manually from the GitHub Actions UI.

The collection script is located here:

```text
scripts/collect_github_traffic.py
```

The output is stored in:

```text
analytics/github-traffic/
```

Generated files include:

```text
analytics/github-traffic/raw/<date>/views.json
analytics/github-traffic/raw/<date>/clones.json
analytics/github-traffic/raw/<date>/referrers.json
analytics/github-traffic/raw/<date>/paths.json

analytics/github-traffic/summary/views_daily.csv
analytics/github-traffic/summary/clones_daily.csv
analytics/github-traffic/summary/referrers_latest.csv
analytics/github-traffic/summary/paths_latest.csv
```

## Why the Archive Exists

GitHub provides repository traffic data only for a limited rolling window.

By collecting the data regularly, the project keeps a longer-term history of:

- Repository views
- Unique visitors
- Repository clones
- Unique cloners
- Top referrers
- Popular repository paths

## Portfolio Website Analytics

The central portfolio website is no longer hosted in this repository.

Pageviews and selected click events are tracked on the dedicated portfolio repository:

```text
https://github.com/MarcF46/MarcF46.github.io
```

The website itself is published at:

```text
https://marcf46.github.io/
```

GoatCounter remains the lightweight analytics service used for the portfolio website. Website-specific HTML and click-event configuration therefore belong to the dedicated portfolio repository rather than to this Docker lab.

## Security Notes

A dedicated GitHub secret is used for the repository traffic workflow:

```text
TRAFFIC_TOKEN
```

The token should be stored only as a GitHub Actions repository secret and, if needed, in a secure password manager.

The token should not be stored in:

- Source code
- Markdown documentation
- PowerShell history
- Screenshots
- Chat messages
- Plain text files

## Privacy Notes

The traffic archive and portfolio analytics are intended only for general operational insight.

Important limitations:

- Repository traffic may include automated systems, CI jobs or repeated local activity
- Browser tracking protection and ad blockers can block website analytics
- Own test visits can appear in analytics data
- The setup is not intended to identify individual visitors

## Current Status

```text
Central portfolio website: MarcF46.github.io
Docker repository traffic archive: active
Portfolio GoatCounter analytics: active on the dedicated portfolio site
Additional server/VPS required: no
Monthly cost: 0 EUR
```

## Architecture Decision

The former combined setup has intentionally been separated so that the Docker repository remains a technical project repository while the personal portfolio website can grow independently as more labs are added.
