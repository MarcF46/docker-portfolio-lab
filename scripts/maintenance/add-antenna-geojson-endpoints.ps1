$ErrorActionPreference = 'Stop'

# Replaces monitoring/antenna-simulator/antenna_simulator.py with an enhanced version.
# Adds:
# - /location.geojson         static approximate site location
# - /location-status.geojson  dynamic GeoJSON with current simulator state in properties
# - CORS headers for local Grafana/browser access
# Safe behavior:
# - creates a timestamped backup first
# - does not print secrets
# - keeps the existing simulator metric names and lab control endpoint

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir = Split-Path -Parent $ScriptPath
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

$TargetPath = Join-Path $ProjectRoot 'monitoring\antenna-simulator\antenna_simulator.py'

if (-not (Test-Path $TargetPath)) {
    $ProjectRoot = Get-Location
    $TargetPath = Join-Path $ProjectRoot 'monitoring\antenna-simulator\antenna_simulator.py'
}

if (-not (Test-Path $TargetPath)) {
    throw "Target file not found: $TargetPath"
}

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupPath = "$TargetPath.backup-$Timestamp"
Copy-Item -Path $TargetPath -Destination $BackupPath -Force

$PythonCode = @'
import json
import random
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, urlparse

from prometheus_client import Counter, Gauge, CONTENT_TYPE_LATEST, generate_latest


ANTENNA_ID = "hannover-linden-ant-01"
SITE = "Hannover-Linden"
PROVIDER = "lab-mobile-provider"

# Approximate demo coordinates for the Hannover-Linden area.
# Do not use private addresses or exact personal locations in portfolio screenshots.
LATITUDE = 52.3705
LONGITUDE = 9.7166

VALID_MODES = [
    "normal",
    "weak_signal",
    "many_errors",
    "delayed_packets",
    "low_battery",
    "no_packets",
]

LABELS = {
    "antenna_id": ANTENNA_ID,
    "site": SITE,
    "provider": PROVIDER,
}

packets_total = Counter(
    "antenna_packets_total",
    "Total number of successfully received packets from the simulated antenna.",
    ["antenna_id", "site", "provider"],
)

errors_total = Counter(
    "antenna_errors_total",
    "Total number of simulated packet or device errors.",
    ["antenna_id", "site", "provider"],
)

last_seen_age_seconds = Gauge(
    "antenna_last_seen_age_seconds",
    "Seconds since the last successfully received packet.",
    ["antenna_id", "site", "provider"],
)

last_seen_timestamp_seconds = Gauge(
    "antenna_last_seen_timestamp_seconds",
    "Unix timestamp of the last successfully received packet.",
    ["antenna_id", "site", "provider"],
)

signal_strength_dbm = Gauge(
    "antenna_signal_strength_dbm",
    "Simulated mobile signal strength in dBm. More negative values mean weaker signal.",
    ["antenna_id", "site", "provider"],
)

battery_percent = Gauge(
    "antenna_battery_percent",
    "Simulated antenna battery level in percent.",
    ["antenna_id", "site", "provider"],
)

packet_delay_seconds = Gauge(
    "antenna_packet_delay_seconds",
    "Simulated packet delivery delay in seconds.",
    ["antenna_id", "site", "provider"],
)

antenna_online = Gauge(
    "antenna_online",
    "1 if the simulated antenna is considered online, 0 if no packets arrive.",
    ["antenna_id", "site", "provider"],
)

antenna_mode_info = Gauge(
    "antenna_mode_info",
    "Current simulator mode. Exactly one mode label should have value 1.",
    ["antenna_id", "site", "provider", "mode"],
)


state_lock = threading.Lock()
state = {
    "mode": "normal",
    "start_time": time.time(),
    "last_seen": time.time(),
    "signal_strength_dbm": -80.0,
    "battery_percent": 87.0,
    "packet_delay_seconds": 0.5,
    "online": 1,
}


def label_values():
    return (ANTENNA_ID, SITE, PROVIDER)


def mode_label_values(mode):
    return (ANTENNA_ID, SITE, PROVIDER, mode)


def set_mode(mode):
    if mode not in VALID_MODES:
        raise ValueError(f"Invalid mode: {mode}")

    with state_lock:
        state["mode"] = mode

        # Make mode changes visible quickly in Grafana.
        if mode == "normal":
            state["last_seen"] = time.time()
            state["online"] = 1
            state["signal_strength_dbm"] = -78.0
            state["battery_percent"] = max(state["battery_percent"], 85.0)
            state["packet_delay_seconds"] = 0.5
        elif mode == "no_packets":
            state["online"] = 0
            state["signal_strength_dbm"] = -118.0
            state["packet_delay_seconds"] = 0.0

    update_mode_metric()


def update_mode_metric():
    with state_lock:
        active_mode = state["mode"]

    for mode in VALID_MODES:
        antenna_mode_info.labels(*mode_label_values(mode)).set(1 if mode == active_mode else 0)


def update_common_metrics():
    with state_lock:
        now = time.time()
        age = max(0.0, now - state["last_seen"])

        last_seen_age_seconds.labels(*label_values()).set(age)
        last_seen_timestamp_seconds.labels(*label_values()).set(state["last_seen"])
        signal_strength_dbm.labels(*label_values()).set(state["signal_strength_dbm"])
        battery_percent.labels(*label_values()).set(state["battery_percent"])
        packet_delay_seconds.labels(*label_values()).set(state["packet_delay_seconds"])
        antenna_online.labels(*label_values()).set(state["online"])

    update_mode_metric()


def simulate_tick():
    now = time.time()

    with state_lock:
        mode = state["mode"]

        if mode == "normal":
            state["online"] = 1
            state["last_seen"] = now
            state["signal_strength_dbm"] = random.uniform(-84.0, -72.0)
            state["battery_percent"] = random.uniform(84.0, 90.0)
            state["packet_delay_seconds"] = random.uniform(0.2, 1.2)
            packets_total.labels(*label_values()).inc()

        elif mode == "weak_signal":
            state["online"] = 1
            state["last_seen"] = now
            state["signal_strength_dbm"] = random.uniform(-115.0, -103.0)
            state["battery_percent"] = random.uniform(78.0, 88.0)
            state["packet_delay_seconds"] = random.uniform(8.0, 24.0)
            packets_total.labels(*label_values()).inc()
            if random.random() < 0.25:
                errors_total.labels(*label_values()).inc()

        elif mode == "many_errors":
            state["online"] = 1
            state["last_seen"] = now
            state["signal_strength_dbm"] = random.uniform(-88.0, -74.0)
            state["battery_percent"] = random.uniform(78.0, 88.0)
            state["packet_delay_seconds"] = random.uniform(1.0, 5.0)
            packets_total.labels(*label_values()).inc()
            errors_total.labels(*label_values()).inc(random.randint(1, 4))

        elif mode == "delayed_packets":
            state["online"] = 1
            state["last_seen"] = now
            state["signal_strength_dbm"] = random.uniform(-94.0, -80.0)
            state["battery_percent"] = random.uniform(78.0, 88.0)
            state["packet_delay_seconds"] = random.uniform(12.0, 35.0)
            packets_total.labels(*label_values()).inc()

        elif mode == "low_battery":
            state["online"] = 1
            state["last_seen"] = now
            state["signal_strength_dbm"] = random.uniform(-86.0, -74.0)
            state["battery_percent"] = random.uniform(5.0, 18.0)
            state["packet_delay_seconds"] = random.uniform(0.4, 1.8)
            packets_total.labels(*label_values()).inc()

        elif mode == "no_packets":
            state["online"] = 0
            state["signal_strength_dbm"] = random.uniform(-120.0, -108.0)
            state["packet_delay_seconds"] = 0.0
            # Do not update last_seen and do not increase packets_total.

    update_common_metrics()


def simulator_loop():
    update_mode_metric()

    while True:
        simulate_tick()
        time.sleep(1)


def current_snapshot():
    with state_lock:
        now = time.time()
        return {
            "status": "healthy",
            "antenna_id": ANTENNA_ID,
            "site": SITE,
            "provider": PROVIDER,
            "mode": state["mode"],
            "online": int(state["online"]),
            "signal_strength_dbm": round(float(state["signal_strength_dbm"]), 2),
            "battery_percent": round(float(state["battery_percent"]), 2),
            "packet_delay_seconds": round(float(state["packet_delay_seconds"]), 2),
            "last_seen_age_seconds": round(float(max(0.0, now - state["last_seen"])), 2),
            "uptime_seconds": int(now - state["start_time"]),
            "latitude": LATITUDE,
            "longitude": LONGITUDE,
        }


def severity_for_snapshot(snapshot):
    if snapshot["online"] == 0:
        return "critical"
    if snapshot["battery_percent"] < 20:
        return "warning"
    if snapshot["signal_strength_dbm"] < -100:
        return "warning"
    if snapshot["packet_delay_seconds"] > 10:
        return "warning"
    return "normal"


def static_location_geojson():
    return {
        "type": "FeatureCollection",
        "name": "antenna-simulator-location",
        "features": [
            {
                "type": "Feature",
                "properties": {
                    "antenna_id": ANTENNA_ID,
                    "name": ANTENNA_ID,
                    "site": SITE,
                    "provider": PROVIDER,
                    "description": "Approximate demo location for the simulated antenna site.",
                },
                "geometry": {
                    "type": "Point",
                    "coordinates": [LONGITUDE, LATITUDE],
                },
            }
        ],
    }


def dynamic_location_geojson():
    snapshot = current_snapshot()
    severity = severity_for_snapshot(snapshot)

    return {
        "type": "FeatureCollection",
        "name": "antenna-simulator-live-status",
        "features": [
            {
                "type": "Feature",
                "properties": {
                    "antenna_id": ANTENNA_ID,
                    "name": ANTENNA_ID,
                    "site": SITE,
                    "provider": PROVIDER,
                    "mode": snapshot["mode"],
                    "online": snapshot["online"],
                    "severity": severity,
                    "signal_strength_dbm": snapshot["signal_strength_dbm"],
                    "battery_percent": snapshot["battery_percent"],
                    "packet_delay_seconds": snapshot["packet_delay_seconds"],
                    "last_seen_age_seconds": snapshot["last_seen_age_seconds"],
                    "updated_at_unix": int(time.time()),
                },
                "geometry": {
                    "type": "Point",
                    "coordinates": [LONGITUDE, LATITUDE],
                },
            }
        ],
    }


class AntennaRequestHandler(BaseHTTPRequestHandler):
    server_version = "AntennaSimulatorHTTP/1.1"

    def log_message(self, format, *args):
        # Keep container logs focused on meaningful lab output.
        return

    def add_common_headers(self, content_type):
        self.send_header("Content-Type", content_type)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def send_json(self, payload, status=200):
        data = json.dumps(payload, indent=2).encode("utf-8")
        self.send_response(status)
        self.add_common_headers("application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_OPTIONS(self):
        self.send_response(204)
        self.add_common_headers("text/plain")
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path
        query = parse_qs(parsed.query)

        if path == "/metrics":
            data = generate_latest()
            self.send_response(200)
            self.add_common_headers(CONTENT_TYPE_LATEST)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
            return

        if path == "/health":
            health = {
                "status": "healthy",
                "antenna_id": ANTENNA_ID,
                "mode": current_snapshot()["mode"],
                "uptime_seconds": current_snapshot()["uptime_seconds"],
            }
            self.send_json(health)
            return

        if path == "/status":
            status = current_snapshot()
            status["service"] = "antenna-simulator"
            status["endpoints"] = [
                "/health",
                "/metrics",
                "/mode",
                "/set-mode?mode=normal",
                "/location.geojson",
                "/location-status.geojson",
            ]
            status["valid_modes"] = sorted(VALID_MODES)
            self.send_json(status)
            return

        if path == "/mode":
            self.send_json({"mode": current_snapshot()["mode"], "valid_modes": sorted(VALID_MODES)})
            return

        if path == "/set-mode":
            mode = query.get("mode", [""])[0]
            if mode not in VALID_MODES:
                self.send_json(
                    {
                        "status": "error",
                        "message": f"Invalid mode: {mode}",
                        "valid_modes": sorted(VALID_MODES),
                    },
                    status=400,
                )
                return

            set_mode(mode)
            self.send_json(
                {
                    "status": "ok",
                    "antenna_id": ANTENNA_ID,
                    "mode": mode,
                    "note": "Lab-only control endpoint. Do not expose this in production.",
                }
            )
            return

        if path == "/location.geojson":
            self.send_json(static_location_geojson())
            return

        if path == "/location-status.geojson":
            self.send_json(dynamic_location_geojson())
            return

        self.send_json(
            {
                "service": "antenna-simulator",
                "message": "Use /health, /metrics, /status, /mode, /location.geojson or /location-status.geojson",
            }
        )


def main():
    thread = threading.Thread(target=simulator_loop, daemon=True)
    thread.start()

    host = "0.0.0.0"
    port = 8000
    print(f"Starting antenna simulator on {host}:{port}", flush=True)
    print(f"Metrics endpoint: http://{host}:{port}/metrics", flush=True)
    print(f"Static GeoJSON endpoint: http://{host}:{port}/location.geojson", flush=True)
    print(f"Dynamic GeoJSON endpoint: http://{host}:{port}/location-status.geojson", flush=True)

    server = HTTPServer((host, port), AntennaRequestHandler)
    server.serve_forever()


if __name__ == "__main__":
    main()
'@

Set-Content -Path $TargetPath -Value $PythonCode -Encoding UTF8

Write-Host "OK: Enhanced antenna simulator with GeoJSON endpoints."
Write-Host "Updated file:"
Write-Host "  $TargetPath"
Write-Host "Backup created:"
Write-Host "  $BackupPath"
Write-Host ""
Write-Host "New endpoints:"
Write-Host "  http://localhost:18000/location.geojson"
Write-Host "  http://localhost:18000/location-status.geojson"
Write-Host ""
Write-Host "Next commands:"
Write-Host "  docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml -f compose.antenna-simulator.yml up -d --build antenna-simulator"
Write-Host "  curl.exe http://localhost:18000/location.geojson"
Write-Host "  curl.exe http://localhost:18000/location-status.geojson"
