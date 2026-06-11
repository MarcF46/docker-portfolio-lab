#!/usr/bin/env python3
"""
Antenna / sensor simulator for a local Docker + Prometheus + Grafana lab.

Purpose:
- expose realistic operations-style Prometheus metrics
- simulate common field-device symptoms such as no packets, delayed packets,
  many errors, weak signal and low battery
- provide a tiny lab-only HTTP control endpoint to switch modes without restarting

Security note:
- /set-mode is intentionally unauthenticated for this local lab only.
- Do not expose this service to the internet in production.
"""

from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from prometheus_client import CollectorRegistry, Counter, Gauge, generate_latest, CONTENT_TYPE_LATEST
from urllib.parse import urlparse, parse_qs
import json
import os
import random
import threading
import time

VALID_MODES = {
    "normal",
    "no_packets",
    "delayed_packets",
    "many_errors",
    "weak_signal",
    "low_battery",
}

ANTENNA_ID = os.getenv("ANTENNA_ID", "hannover-linden-ant-01")
SITE = os.getenv("ANTENNA_SITE", "Hannover-Linden")
PROVIDER = os.getenv("ANTENNA_PROVIDER", "lab-mobile-provider")
PORT = int(os.getenv("METRICS_PORT", "8000"))
INITIAL_MODE = os.getenv("ANTENNA_INITIAL_MODE", "normal")
if INITIAL_MODE not in VALID_MODES:
    INITIAL_MODE = "normal"

LABELS = ["antenna_id", "site", "provider"]
LABEL_VALUES = [ANTENNA_ID, SITE, PROVIDER]

registry = CollectorRegistry()

packets_total = Counter(
    "antenna_packets_total",
    "Total number of successfully received packets from the simulated antenna.",
    LABELS,
    registry=registry,
)

errors_total = Counter(
    "antenna_errors_total",
    "Total number of simulated packet or device errors.",
    LABELS + ["error_type"],
    registry=registry,
)

last_seen_age_seconds = Gauge(
    "antenna_last_seen_age_seconds",
    "Seconds since the last successfully received packet.",
    LABELS,
    registry=registry,
)

last_seen_timestamp_seconds = Gauge(
    "antenna_last_seen_timestamp_seconds",
    "Unix timestamp of the last successfully received packet.",
    LABELS,
    registry=registry,
)

signal_strength_dbm = Gauge(
    "antenna_signal_strength_dbm",
    "Simulated mobile signal strength in dBm. More negative values mean weaker signal.",
    LABELS,
    registry=registry,
)

battery_percent = Gauge(
    "antenna_battery_percent",
    "Simulated antenna battery level in percent.",
    LABELS,
    registry=registry,
)

packet_delay_seconds = Gauge(
    "antenna_packet_delay_seconds",
    "Simulated packet delivery delay in seconds.",
    LABELS,
    registry=registry,
)

online = Gauge(
    "antenna_online",
    "1 if the simulated antenna is considered online, 0 if no packets arrive.",
    LABELS,
    registry=registry,
)

mode_info = Gauge(
    "antenna_mode_info",
    "Current simulator mode. Exactly one mode label should have value 1.",
    LABELS + ["mode"],
    registry=registry,
)

state_lock = threading.Lock()
state = {
    "mode": INITIAL_MODE,
    "battery": 87.0,
    "last_packet_time": time.time(),
    "started_at": time.time(),
}


def set_mode(new_mode: str) -> None:
    with state_lock:
        state["mode"] = new_mode
        if new_mode != "no_packets":
            state["last_packet_time"] = time.time()


def get_state_snapshot() -> dict:
    with state_lock:
        return dict(state)


def update_mode_metric(mode: str) -> None:
    for candidate in VALID_MODES:
        value = 1 if candidate == mode else 0
        mode_info.labels(*LABEL_VALUES, candidate).set(value)


def simulation_loop() -> None:
    # Initialize visible gauges before the first scrape.
    last_seen_timestamp_seconds.labels(*LABEL_VALUES).set(state["last_packet_time"])
    battery_percent.labels(*LABEL_VALUES).set(state["battery"])
    signal_strength_dbm.labels(*LABEL_VALUES).set(-76)
    packet_delay_seconds.labels(*LABEL_VALUES).set(1.2)
    online.labels(*LABEL_VALUES).set(1)
    update_mode_metric(INITIAL_MODE)

    while True:
        now = time.time()
        snapshot = get_state_snapshot()
        mode = snapshot["mode"]

        # Defaults represent a healthy antenna on a normal mobile connection.
        packets_to_add = random.randint(1, 4)
        errors_to_add = 0
        error_type = "none"
        signal = random.uniform(-72, -84)
        delay = random.uniform(0.5, 2.8)
        is_online = 1
        battery_drain = random.uniform(0.01, 0.04)
        successful_packet = True

        if mode == "no_packets":
            packets_to_add = 0
            errors_to_add = 0
            successful_packet = False
            is_online = 0
            signal = random.uniform(-115, -125)
            delay = 0
        elif mode == "delayed_packets":
            packets_to_add = random.randint(1, 2)
            delay = random.uniform(12, 45)
            signal = random.uniform(-88, -104)
        elif mode == "many_errors":
            packets_to_add = random.randint(0, 2)
            errors_to_add = random.randint(3, 9)
            error_type = random.choice(["firmware", "payload_format", "api_reject"])
            delay = random.uniform(2, 8)
            signal = random.uniform(-75, -92)
            successful_packet = packets_to_add > 0
        elif mode == "weak_signal":
            packets_to_add = random.randint(0, 2)
            signal = random.uniform(-103, -116)
            delay = random.uniform(5, 25)
            errors_to_add = random.randint(0, 2)
            error_type = "weak_signal"
            successful_packet = packets_to_add > 0
        elif mode == "low_battery":
            packets_to_add = random.randint(1, 3)
            signal = random.uniform(-75, -90)
            delay = random.uniform(1, 5)
            battery_drain = random.uniform(0.2, 0.7)

        if packets_to_add > 0:
            packets_total.labels(*LABEL_VALUES).inc(packets_to_add)
            with state_lock:
                state["last_packet_time"] = now

        if errors_to_add > 0 and error_type != "none":
            errors_total.labels(*LABEL_VALUES, error_type).inc(errors_to_add)

        with state_lock:
            state["battery"] = max(0.0, state["battery"] - battery_drain)
            current_battery = state["battery"]
            last_packet_time = state["last_packet_time"]

        if mode == "low_battery":
            current_battery = min(current_battery, random.uniform(8, 18))
            with state_lock:
                state["battery"] = current_battery

        if mode == "normal" and current_battery < 30:
            # Lab convenience: slowly recover normal mode battery so repeated tests stay useful.
            with state_lock:
                state["battery"] = 87.0
                current_battery = state["battery"]

        last_seen_age_seconds.labels(*LABEL_VALUES).set(max(0, now - last_packet_time))
        last_seen_timestamp_seconds.labels(*LABEL_VALUES).set(last_packet_time)
        signal_strength_dbm.labels(*LABEL_VALUES).set(signal)
        battery_percent.labels(*LABEL_VALUES).set(current_battery)
        packet_delay_seconds.labels(*LABEL_VALUES).set(delay)
        online.labels(*LABEL_VALUES).set(is_online)
        update_mode_metric(mode)

        print(
            json.dumps(
                {
                    "timestamp": int(now),
                    "antenna_id": ANTENNA_ID,
                    "mode": mode,
                    "packets_added": packets_to_add,
                    "errors_added": errors_to_add,
                    "signal_dbm": round(signal, 1),
                    "delay_seconds": round(delay, 1),
                    "battery_percent": round(current_battery, 1),
                    "last_seen_age_seconds": round(max(0, now - last_packet_time), 1),
                }
            ),
            flush=True,
        )
        time.sleep(5)


class Handler(BaseHTTPRequestHandler):
    def _send_json(self, payload: dict, status: int = 200) -> None:
        body = json.dumps(payload, indent=2).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 - required by BaseHTTPRequestHandler
        parsed = urlparse(self.path)

        if parsed.path == "/metrics":
            data = generate_latest(registry)
            self.send_response(200)
            self.send_header("Content-Type", CONTENT_TYPE_LATEST)
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)
            return

        if parsed.path == "/health":
            snapshot = get_state_snapshot()
            self._send_json(
                {
                    "status": "healthy",
                    "antenna_id": ANTENNA_ID,
                    "mode": snapshot["mode"],
                    "uptime_seconds": int(time.time() - snapshot["started_at"]),
                }
            )
            return

        if parsed.path == "/mode":
            snapshot = get_state_snapshot()
            self._send_json(
                {
                    "antenna_id": ANTENNA_ID,
                    "mode": snapshot["mode"],
                    "valid_modes": sorted(VALID_MODES),
                }
            )
            return

        if parsed.path == "/set-mode":
            query = parse_qs(parsed.query)
            requested = query.get("mode", [""])[0]
            if requested not in VALID_MODES:
                self._send_json(
                    {
                        "status": "error",
                        "message": "Invalid mode.",
                        "valid_modes": sorted(VALID_MODES),
                    },
                    status=400,
                )
                return

            set_mode(requested)
            self._send_json(
                {
                    "status": "ok",
                    "antenna_id": ANTENNA_ID,
                    "mode": requested,
                    "note": "Lab-only control endpoint. Do not expose this in production.",
                }
            )
            return

        self._send_json(
            {
                "service": "antenna-simulator",
                "endpoints": ["/health", "/metrics", "/mode", "/set-mode?mode=normal"],
                "valid_modes": sorted(VALID_MODES),
            }
        )

    def log_message(self, format: str, *args) -> None:  # noqa: A002 - inherited API name
        # Keep HTTP access logs quiet; the simulation loop already prints useful state.
        return


def main() -> None:
    thread = threading.Thread(target=simulation_loop, daemon=True)
    thread.start()

    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(
        json.dumps(
            {
                "event": "antenna_simulator_started",
                "antenna_id": ANTENNA_ID,
                "site": SITE,
                "provider": PROVIDER,
                "port": PORT,
                "initial_mode": INITIAL_MODE,
            }
        ),
        flush=True,
    )
    server.serve_forever()


if __name__ == "__main__":
    main()
