# Website Analytics

This document describes the lightweight analytics setup for the Docker Portfolio Lab.

## Purpose

The portfolio landing page should provide a basic operational overview of how the public project is used:

- How often the landing page is opened
- Which important links are clicked
- Which GitHub repository traffic is visible
- How repository traffic can be archived beyond GitHub's short traffic window

The goal is not to identify individual visitors. The setup is used only for general portfolio and operations insight.

## Components

```text
GitHub Pages landing page
        ├── GoatCounter pageview tracking
        ├── GoatCounter click events
        └── GitHub repository traffic archive
                ├── GitHub Actions scheduled workflow
                ├── GitHub REST API traffic endpoints
                └── archived JSON/CSV summaries
```

## Landing Page Analytics

The landing page uses GoatCounter as a lightweight, privacy-friendly analytics tool.

The tracking script is embedded in `index.html`:

```html
<script data-goatcounter="https://marcf46-portfolio.goatcounter.com/count"
        async src="https://gc.zgo.at/count.js"></script>
```

## Tracked Click Events

Important portfolio links are marked with `data-goatcounter-click`.

Examples:

```html
<a data-goatcounter-click="click-repo-docker-portfolio-lab"
   href="https://github.com/MarcF46/docker-portfolio-lab">
```

```html
<a data-goatcounter-click="click-linkedin-profile"
   href="https://www.linkedin.com/in/marc-fahlbusch-1762b3335">
```

Currently tracked event groups include:

- Navigation clicks
- Docker Portfolio Lab repository clicks
- Documentation clicks
- Monitoring lab clicks
- BorgBackup lab clicks
- GitHub profile clicks
- LinkedIn profile clicks
- Attribution link clicks

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

GitHub only provides repository traffic data for a short rolling window.

By collecting this data regularly, the project keeps a longer-term history of:

- Repository views
- Unique visitors
- Repository clones
- Unique cloners
- Top referrers
- Popular repository paths

## Security Notes

A dedicated GitHub secret is used for the workflow:

```text
TRAFFIC_TOKEN
```

The token should be stored only as a GitHub Actions repository secret and, if needed, in a secure password manager such as KeePass.

The token should not be stored in:

- Source code
- Markdown documentation
- PowerShell history
- Screenshots
- Chat messages
- Plain text files

## Privacy Notes

This setup is intentionally limited.

It does not aim to identify individual visitors. It provides only general operational signals such as pageviews, referrers, browser/system categories and selected click events.

Important limitations:

- Browser tracking protection and ad blockers can block GoatCounter
- Own test visits can appear in the dashboard
- GitHub clone statistics may include automated systems, CI jobs or repeated local activity
- Events in GoatCounter can appear as path-like entries in the dashboard

## Operational Verification

The setup was verified by checking:

1. GitHub Actions workflow runs successfully
2. GitHub traffic data is archived into JSON and CSV files
3. GoatCounter script is present in the live GitHub Pages HTML
4. Pageviews appear in the GoatCounter dashboard
5. Click events appear in the GoatCounter dashboard

## Current Status

```text
GitHub traffic archive: active
GoatCounter pageviews: active
GoatCounter click events: active
Additional server/VPS required: no
Monthly cost: 0 EUR
```

## Future Improvements

Possible future improvements:

- Add a small local script to summarize the CSV data
- Create a simple chart from archived GitHub traffic
- Add a short README section linking to this analytics documentation
- Review the GoatCounter dashboard after real LinkedIn or GitHub traffic
- Add a privacy note to the public landing page if needed
