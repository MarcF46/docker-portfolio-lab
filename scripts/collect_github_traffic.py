#!/usr/bin/env python3
"""
Collect GitHub repository traffic data and archive it in the repository.

Collected data:
- Repository views
- Repository clones
- Top referrers
- Popular paths

Purpose:
GitHub traffic data is available only for a rolling recent window.
This script archives snapshots regularly so the portfolio lab keeps a longer-term history.
"""

import csv
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


REPOSITORY = os.getenv("GITHUB_REPOSITORY", "")
TOKEN = os.getenv("TRAFFIC_TOKEN") or os.getenv("GITHUB_TOKEN")

BASE_DIR = Path("analytics/github-traffic")
RAW_DIR = BASE_DIR / "raw"
SUMMARY_DIR = BASE_DIR / "summary"

API_VERSION = "2022-11-28"


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def api_get(path: str):
    if not TOKEN:
        fail("Missing GitHub token. Set TRAFFIC_TOKEN or GITHUB_TOKEN.")

    url = f"https://api.github.com{path}"

    request = urllib.request.Request(
        url,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {TOKEN}",
            "X-GitHub-Api-Version": API_VERSION,
            "User-Agent": "portfolio-github-traffic-collector",
        },
    )

    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        fail(f"GitHub API request failed for {path}: HTTP {exc.code} {body}")
    except Exception as exc:
        fail(f"GitHub API request failed for {path}: {exc}")


def write_json(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")


def read_csv_as_dict(path: Path, key_field: str):
    if not path.exists():
        return {}

    with path.open("r", encoding="utf-8", newline="") as file:
        reader = csv.DictReader(file)
        return {row[key_field]: row for row in reader}


def write_csv(path: Path, fieldnames, rows) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def update_daily_csv(path: Path, key_field: str, fieldnames, daily_items, item_key: str, snapshot_date: str) -> None:
    existing = read_csv_as_dict(path, key_field)

    for item in daily_items:
        date_value = item[item_key][:10]

        existing[date_value] = {
            "date": date_value,
            "count": str(item.get("count", 0)),
            "uniques": str(item.get("uniques", 0)),
            "last_seen_snapshot": snapshot_date,
        }

    rows = [existing[key] for key in sorted(existing.keys())]
    write_csv(path, fieldnames, rows)


def write_snapshot_csv(path: Path, fieldnames, rows) -> None:
    write_csv(path, fieldnames, rows)


def markdown_table_rows(items, formatter, empty_row: str) -> str:
    if not items:
        return empty_row
    return "\n".join(formatter(item) for item in items)


def create_markdown_summary(snapshot_date: str, views, clones, referrers, paths) -> None:
    total_views = views.get("count", 0)
    unique_views = views.get("uniques", 0)
    total_clones = clones.get("count", 0)
    unique_clones = clones.get("uniques", 0)

    referrer_rows = markdown_table_rows(
        referrers[:10],
        lambda item: f"| {item.get('referrer', '')} | {item.get('count', 0)} | {item.get('uniques', 0)} |",
        "| No data | 0 | 0 |",
    )

    path_rows = markdown_table_rows(
        paths[:10],
        lambda item: f"| {item.get('path', '')} | {item.get('title', '')} | {item.get('count', 0)} | {item.get('uniques', 0)} |",
        "| No data | No data | 0 | 0 |",
    )

    content = f"""# GitHub Traffic Summary

Last snapshot: `{snapshot_date}`

## Purpose

GitHub traffic endpoints provide recent repository traffic data.
This project archives snapshots so the portfolio lab can keep a longer-term history.

## Current Snapshot Totals

| Metric | Count | Unique |
|---|---:|---:|
| Views | {total_views} | {unique_views} |
| Clones | {total_clones} | {unique_clones} |

## Top Referrers

| Referrer | Count | Unique |
|---|---:|---:|
{referrer_rows}

## Popular Paths

| Path | Title | Count | Unique |
|---|---|---:|---:|
{path_rows}

## Generated Files

- `summary/views_daily.csv`
- `summary/clones_daily.csv`
- `summary/referrers_latest.csv`
- `summary/paths_latest.csv`
- `raw/<date>/`
"""

    (BASE_DIR / "README.md").write_text(content, encoding="utf-8")


def main() -> None:
    if not REPOSITORY or "/" not in REPOSITORY:
        fail("GITHUB_REPOSITORY is missing or invalid. Expected format: owner/repo")

    owner, repo = REPOSITORY.split("/", 1)
    snapshot_date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    snapshot_timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    SUMMARY_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Collecting GitHub traffic for {owner}/{repo}")
    print(f"Snapshot date: {snapshot_date}")

    views = api_get(f"/repos/{owner}/{repo}/traffic/views?per=day")
    clones = api_get(f"/repos/{owner}/{repo}/traffic/clones?per=day")
    referrers = api_get(f"/repos/{owner}/{repo}/traffic/popular/referrers")
    paths = api_get(f"/repos/{owner}/{repo}/traffic/popular/paths")

    snapshot_dir = RAW_DIR / snapshot_date

    write_json(snapshot_dir / "views.json", views)
    write_json(snapshot_dir / "clones.json", clones)
    write_json(snapshot_dir / "referrers.json", referrers)
    write_json(snapshot_dir / "paths.json", paths)

    update_daily_csv(
        SUMMARY_DIR / "views_daily.csv",
        key_field="date",
        fieldnames=["date", "count", "uniques", "last_seen_snapshot"],
        daily_items=views.get("views", []),
        item_key="timestamp",
        snapshot_date=snapshot_date,
    )

    update_daily_csv(
        SUMMARY_DIR / "clones_daily.csv",
        key_field="date",
        fieldnames=["date", "count", "uniques", "last_seen_snapshot"],
        daily_items=clones.get("clones", []),
        item_key="timestamp",
        snapshot_date=snapshot_date,
    )

    referrer_rows = [
        {
            "snapshot_timestamp": snapshot_timestamp,
            "referrer": item.get("referrer", ""),
            "count": item.get("count", 0),
            "uniques": item.get("uniques", 0),
        }
        for item in referrers
    ]

    path_rows = [
        {
            "snapshot_timestamp": snapshot_timestamp,
            "path": item.get("path", ""),
            "title": item.get("title", ""),
            "count": item.get("count", 0),
            "uniques": item.get("uniques", 0),
        }
        for item in paths
    ]

    write_snapshot_csv(
        SUMMARY_DIR / "referrers_latest.csv",
        ["snapshot_timestamp", "referrer", "count", "uniques"],
        referrer_rows,
    )

    write_snapshot_csv(
        SUMMARY_DIR / "paths_latest.csv",
        ["snapshot_timestamp", "path", "title", "count", "uniques"],
        path_rows,
    )

    create_markdown_summary(snapshot_date, views, clones, referrers, paths)

    print("Traffic snapshot archived successfully.")


if __name__ == "__main__":
    main()
