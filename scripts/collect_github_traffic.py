#!/usr/bin/env python3
"""
Collect GitHub repository traffic data and archive it in the repository.

Collected data:
- Repository views
- Repository clones
- Top referrers
- Popular paths

Why archive the data?
GitHub exposes traffic metrics only for a rolling recent window. The collector
stores daily snapshots so the lab keeps a longer-term history.

Authentication:
The script intentionally uses TRAFFIC_TOKEN only. GitHub's traffic endpoints
require repository Administration: Read for a fine-grained personal access
token. The workflow's temporary GITHUB_TOKEN is still used by git push, but it
is not a fallback for these traffic API calls.
"""

import csv
import json
import os
import sys
import urllib.error
import urllib.request
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path


REPOSITORY = os.getenv("GITHUB_REPOSITORY", "")
TOKEN = os.getenv("TRAFFIC_TOKEN")

BASE_DIR = Path("analytics/github-traffic")
RAW_DIR = BASE_DIR / "raw"
SUMMARY_DIR = BASE_DIR / "summary"

API_VERSION = "2026-03-10"


def fail(message: str) -> None:
    """Print a clear error message and stop the workflow."""
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def api_get(path: str):
    """Call one GitHub REST API endpoint and return decoded JSON."""
    if not TOKEN:
        fail(
            "TRAFFIC_TOKEN is missing. Create/update the repository secret "
            "TRAFFIC_TOKEN with repository permission 'Administration: Read'."
        )

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

        if exc.code == 401:
            fail(
                "TRAFFIC_TOKEN was rejected with HTTP 401 (Bad credentials). "
                "The token is probably expired, revoked or incorrect. "
                "Create a new fine-grained token and update the repository "
                "secret TRAFFIC_TOKEN."
            )

        if exc.code == 403:
            fail(
                "GitHub returned HTTP 403. Check that TRAFFIC_TOKEN can access "
                f"{REPOSITORY} and has repository permission "
                "'Administration: Read'. "
                f"API response: {body}"
            )

        fail(f"GitHub API request failed for {path}: HTTP {exc.code} {body}")
    except Exception as exc:
        fail(f"GitHub API request failed for {path}: {exc}")


def write_json(path: Path, data) -> None:
    """Write stable, human-readable JSON."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(data, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def read_json(path: Path, default):
    """Read JSON from disk and return default when a file is absent."""
    if not path.exists():
        return default

    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return default


def read_csv_rows(path: Path):
    """Read a CSV file into a list of dictionaries."""
    if not path.exists():
        return []

    with path.open("r", encoding="utf-8", newline="") as file:
        return list(csv.DictReader(file))


def read_csv_as_dict(path: Path, key_field: str):
    """Read a CSV file and index rows by one field."""
    return {row[key_field]: row for row in read_csv_rows(path)}


def write_csv(path: Path, fieldnames, rows) -> None:
    """Write rows to CSV and create parent directories when necessary."""
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def update_daily_csv(
    path: Path,
    key_field: str,
    fieldnames,
    daily_items,
    item_key: str,
    snapshot_date: str,
) -> None:
    """
    Merge GitHub's rolling daily data into the long-term archive.

    A date is the key, so later snapshots update that date instead of creating
    duplicates.
    """
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


def rebuild_snapshot_histories() -> None:
    """
    Rebuild referrer/path histories from every archived raw snapshot.

    Referrers and popular paths do not contain a per-day timestamp. Therefore
    these CSVs are explicitly snapshot histories. Their counts must not be
    added across snapshots because the same traffic can appear repeatedly in
    GitHub's rolling window.
    """
    referrer_rows = []
    path_rows = []

    if not RAW_DIR.exists():
        return

    for snapshot_dir in sorted(path for path in RAW_DIR.iterdir() if path.is_dir()):
        snapshot_date = snapshot_dir.name

        for item in read_json(snapshot_dir / "referrers.json", []):
            referrer_rows.append(
                {
                    "snapshot_date": snapshot_date,
                    "referrer": item.get("referrer", ""),
                    "count": item.get("count", 0),
                    "uniques": item.get("uniques", 0),
                }
            )

        for item in read_json(snapshot_dir / "paths.json", []):
            path_rows.append(
                {
                    "snapshot_date": snapshot_date,
                    "path": item.get("path", ""),
                    "title": item.get("title", ""),
                    "count": item.get("count", 0),
                    "uniques": item.get("uniques", 0),
                }
            )

    write_csv(
        SUMMARY_DIR / "referrers_snapshots.csv",
        ["snapshot_date", "referrer", "count", "uniques"],
        referrer_rows,
    )
    write_csv(
        SUMMARY_DIR / "paths_snapshots.csv",
        ["snapshot_date", "path", "title", "count", "uniques"],
        path_rows,
    )


def build_monthly_summary() -> list[dict]:
    """
    Aggregate deduplicated daily view/clone rows by month.

    The *_daily_uniques_sum fields are sums of daily unique counts. They are
    intentionally not labelled "monthly unique visitors" because GitHub does
    not provide a stable identity that would let us deduplicate one person
    across multiple days.
    """
    monthly = defaultdict(
        lambda: {
            "views": 0,
            "views_daily_uniques_sum": 0,
            "active_view_days": 0,
            "clones": 0,
            "clones_daily_uniques_sum": 0,
            "active_clone_days": 0,
        }
    )

    for row in read_csv_rows(SUMMARY_DIR / "views_daily.csv"):
        month = row["date"][:7]
        count = int(row.get("count", 0) or 0)
        uniques = int(row.get("uniques", 0) or 0)
        monthly[month]["views"] += count
        monthly[month]["views_daily_uniques_sum"] += uniques
        if count > 0:
            monthly[month]["active_view_days"] += 1

    for row in read_csv_rows(SUMMARY_DIR / "clones_daily.csv"):
        month = row["date"][:7]
        count = int(row.get("count", 0) or 0)
        uniques = int(row.get("uniques", 0) or 0)
        monthly[month]["clones"] += count
        monthly[month]["clones_daily_uniques_sum"] += uniques
        if count > 0:
            monthly[month]["active_clone_days"] += 1

    rows = []
    for month in sorted(monthly):
        rows.append({"month": month, **monthly[month]})

    write_csv(
        SUMMARY_DIR / "monthly.csv",
        [
            "month",
            "views",
            "views_daily_uniques_sum",
            "active_view_days",
            "clones",
            "clones_daily_uniques_sum",
            "active_clone_days",
        ],
        rows,
    )
    return rows


def totals_from_daily(path: Path) -> dict:
    """Return archive totals from a deduplicated daily CSV."""
    rows = read_csv_rows(path)
    return {
        "count": sum(int(row.get("count", 0) or 0) for row in rows),
        "daily_uniques_sum": sum(
            int(row.get("uniques", 0) or 0) for row in rows
        ),
        "active_days": sum(
            int(row.get("count", 0) or 0) > 0 for row in rows
        ),
        "first_date": rows[0]["date"] if rows else "-",
        "last_date": rows[-1]["date"] if rows else "-",
    }


def markdown_table_rows(items, formatter, empty_row: str) -> str:
    """Format list items as Markdown table rows."""
    if not items:
        return empty_row
    return "\n".join(formatter(item) for item in items)


def create_markdown_summary(
    snapshot_date: str,
    views,
    clones,
    referrers,
    paths,
    monthly_rows,
) -> None:
    """Generate the human-readable dashboard in analytics/github-traffic/."""
    total_views = views.get("count", 0)
    unique_views = views.get("uniques", 0)
    total_clones = clones.get("count", 0)
    unique_clones = clones.get("uniques", 0)

    archive_views = totals_from_daily(SUMMARY_DIR / "views_daily.csv")
    archive_clones = totals_from_daily(SUMMARY_DIR / "clones_daily.csv")

    referrer_rows = markdown_table_rows(
        referrers[:10],
        lambda item: (
            f"| {item.get('referrer', '')} | "
            f"{item.get('count', 0)} | {item.get('uniques', 0)} |"
        ),
        "| No data | 0 | 0 |",
    )

    path_rows = markdown_table_rows(
        paths[:10],
        lambda item: (
            f"| `{item.get('path', '')}` | {item.get('title', '')} | "
            f"{item.get('count', 0)} | {item.get('uniques', 0)} |"
        ),
        "| No data | No data | 0 | 0 |",
    )

    month_rows = markdown_table_rows(
        monthly_rows[-12:],
        lambda item: (
            f"| {item['month']} | {item['views']} | "
            f"{item['views_daily_uniques_sum']} | {item['clones']} | "
            f"{item['clones_daily_uniques_sum']} |"
        ),
        "| No data | 0 | 0 | 0 | 0 |",
    )

    content = f"""# GitHub Traffic Summary

Last successful snapshot: `{snapshot_date}`

## Purpose

GitHub exposes repository traffic only for a rolling recent window. This
collector archives snapshots so this lab keeps a longer-term history.

## Current GitHub Window

These values come directly from the latest successful API call.

| Metric | Count | Unique |
|---|---:|---:|
| Views | {total_views} | {unique_views} |
| Clones | {total_clones} | {unique_clones} |

## Long-term Archive

The daily view/clone rows are merged by date, so overlapping API windows are
not added repeatedly.

| Metric | Total count | Sum of daily uniques | Active days | Archived range |
|---|---:|---:|---:|---|
| Views | {archive_views['count']} | {archive_views['daily_uniques_sum']} | {archive_views['active_days']} | {archive_views['first_date']} – {archive_views['last_date']} |
| Clones | {archive_clones['count']} | {archive_clones['daily_uniques_sum']} | {archive_clones['active_days']} | {archive_clones['first_date']} – {archive_clones['last_date']} |

> **Important:** "Sum of daily uniques" is not the number of unique people
> across the whole archive. The same person/client can be counted again on a
> different day. Clone traffic can also contain automated clients and CI.

## Monthly Development

| Month | Views | Daily uniques (sum) | Clones | Daily clone uniques (sum) |
|---|---:|---:|---:|---:|
{month_rows}

## Top Referrers — Current Window

| Referrer | Count | Unique |
|---|---:|---:|
{referrer_rows}

Referrer history is stored as snapshots in
`summary/referrers_snapshots.csv`. Snapshot values overlap and must **not** be
summed to calculate long-term traffic.

## Popular Paths — Current Window

| Path | Title | Count | Unique |
|---|---|---:|---:|
{path_rows}

Path history is stored as snapshots in `summary/paths_snapshots.csv`.
Snapshot values overlap and must **not** be summed.

## Generated Files

- `summary/views_daily.csv` — deduplicated daily view history
- `summary/clones_daily.csv` — deduplicated daily clone history
- `summary/monthly.csv` — monthly aggregation of daily data
- `summary/referrers_snapshots.csv` — historical referrer snapshots
- `summary/paths_snapshots.csv` — historical popular-path snapshots
- `summary/referrers_latest.csv` — latest referrer snapshot
- `summary/paths_latest.csv` — latest popular-path snapshot
- `raw/<date>/` — unmodified API responses for each successful snapshot

## Authentication

The collector requires repository secret `TRAFFIC_TOKEN` with fine-grained
repository permission **Administration: Read**. The workflow's temporary
`GITHUB_TOKEN` is used only for committing generated files back to the
repository.
"""

    (BASE_DIR / "README.md").write_text(content, encoding="utf-8")


def main() -> None:
    """Collect one snapshot and refresh all derived summaries."""
    if not REPOSITORY or "/" not in REPOSITORY:
        fail("GITHUB_REPOSITORY is missing or invalid. Expected: owner/repo")

    owner, repo = REPOSITORY.split("/", 1)
    snapshot_date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    snapshot_timestamp = datetime.now(timezone.utc).strftime(
        "%Y-%m-%dT%H:%M:%SZ"
    )

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    SUMMARY_DIR.mkdir(parents=True, exist_ok=True)

    print(f"Collecting GitHub traffic for {owner}/{repo}")
    print(f"Snapshot date: {snapshot_date}")

    views = api_get(f"/repos/{owner}/{repo}/traffic/views?per=day")
    clones = api_get(f"/repos/{owner}/{repo}/traffic/clones?per=day")
    referrers = api_get(
        f"/repos/{owner}/{repo}/traffic/popular/referrers"
    )
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

    write_csv(
        SUMMARY_DIR / "referrers_latest.csv",
        ["snapshot_timestamp", "referrer", "count", "uniques"],
        referrer_rows,
    )

    write_csv(
        SUMMARY_DIR / "paths_latest.csv",
        ["snapshot_timestamp", "path", "title", "count", "uniques"],
        path_rows,
    )

    rebuild_snapshot_histories()
    monthly_rows = build_monthly_summary()

    create_markdown_summary(
        snapshot_date,
        views,
        clones,
        referrers,
        paths,
        monthly_rows,
    )

    print("Traffic snapshot archived successfully.")


if __name__ == "__main__":
    main()
