# GitHub Traffic Archive

This folder contains archived GitHub repository traffic data for the Docker Portfolio Lab.

## Purpose

GitHub only provides repository traffic data for a short rolling time window.  
This automation archives the data regularly so the project can keep a longer-term history.

## Collected Data

- Repository views
- Repository clones
- Top referrers
- Popular paths

## Automation

The data is collected by this GitHub Actions workflow:

```text
.github/workflows/collect-github-traffic.yml
```

The collection script is located here:

```text
scripts/collect_github_traffic.py
```

## Output

```text
analytics/github-traffic/raw/
analytics/github-traffic/summary/views_daily.csv
analytics/github-traffic/summary/clones_daily.csv
analytics/github-traffic/summary/referrers_latest.csv
analytics/github-traffic/summary/paths_latest.csv
```

## Privacy Note

This archive uses GitHub repository traffic data only.  
It does not identify individual visitors.
