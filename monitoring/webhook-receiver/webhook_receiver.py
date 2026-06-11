from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime, timezone
import json
import sys


class WebhookHandler(BaseHTTPRequestHandler):
    """
    Minimaler lokaler Webhook-Receiver für Grafana-Alert-Tests.

    Zweck im Lab:
    - Grafana sendet Alert-Benachrichtigungen per HTTP POST an /webhook.
    - Dieser Receiver schreibt den empfangenen JSON-Payload ins Container-Log.
    - So lässt sich prüfen, ob Grafana den Alert wirklich an ein anderes System übergibt.

    Hinweis:
    Das ist bewusst ein Lern-/Lab-Service und kein produktionsreifer Webhook-Endpunkt.
    In Produktion wären u. a. Authentifizierung, TLS, Rate Limits, Validierung,
    Logging-Konzept und Zugriffsschutz notwendig.
    """

    def _send_json(self, status_code: int, payload: dict) -> None:
        response = json.dumps(payload).encode("utf-8")

        self.send_response(status_code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(response)))
        self.end_headers()
        self.wfile.write(response)

    def do_GET(self) -> None:
        """
        Einfacher Healthcheck-Endpunkt.

        Docker nutzt /health, um zu prüfen, ob der Container antwortet.
        Vom Windows-Host aus kann getestet werden:
        curl.exe http://localhost:15005/health
        """
        if self.path == "/health":
            self._send_json(200, {"status": "healthy"})
            return

        self._send_json(
            200,
            {
                "service": "local-webhook-receiver",
                "message": "Use POST /webhook to send Grafana alert notifications.",
                "health": "/health",
                "webhook": "/webhook",
            },
        )

    def do_POST(self) -> None:
        """
        Empfängt Webhook-Nachrichten.

        Grafana sendet seine Alert-Benachrichtigung als JSON.
        Der Payload wird formatiert ins Container-Log geschrieben.
        """
        content_length = int(self.headers.get("Content-Length", "0"))
        raw_body = self.rfile.read(content_length).decode("utf-8", errors="replace")

        try:
            payload = json.loads(raw_body) if raw_body else {}
        except json.JSONDecodeError:
            payload = {"raw_body": raw_body}

        timestamp = datetime.now(timezone.utc).isoformat()

        print("\n" + "=" * 80)
        print(f"[{timestamp}] Webhook received")
        print(f"Client: {self.client_address[0]}")
        print(f"Path: {self.path}")
        print("-" * 80)
        print(json.dumps(payload, indent=2, ensure_ascii=False))
        print("=" * 80 + "\n")
        sys.stdout.flush()

        self._send_json(
            200,
            {
                "status": "received",
                "path": self.path,
                "timestamp": timestamp,
            },
        )

    def log_message(self, format: str, *args) -> None:
        """
        Reduziert Standard-HTTP-Lograuschen.
        Die wichtigen Webhook-Inhalte werden in do_POST bewusst strukturiert geloggt.
        """
        return


if __name__ == "__main__":
    host = "0.0.0.0"
    port = 5000

    print(f"Starting local webhook receiver on http://{host}:{port}")
    print("Health endpoint:  GET  /health")
    print("Webhook endpoint: POST /webhook")
    sys.stdout.flush()

    server = HTTPServer((host, port), WebhookHandler)
    server.serve_forever()
