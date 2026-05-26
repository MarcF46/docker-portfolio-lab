# Reverse Proxy mit NGINX

## Zweck

Dieses Dokument beschreibt den ersten Reverse-Proxy-Ausbau des Docker Portfolio Lab.

Ziel ist, den Webservice nicht mehr nur direkt über den veröffentlichten Container-Port aufzurufen, sondern über einen vorgeschalteten NGINX-Reverse-Proxy.

---

## Architektur

Vorher:

```text
Browser -> localhost:8082 -> web:80
```

Nachher:

```text
Browser -> localhost:80 -> reverse-proxy:80 -> web:80
```

Der Reverse Proxy ist damit der zentrale Einstiegspunkt für HTTP-Anfragen.

---

## Dateien

| Datei | Zweck |
|---|---|
| `compose.proxy.yml` | ergänzt den Stack um den Service `reverse-proxy` |
| `proxy/nginx/conf.d/default.conf` | NGINX-Konfiguration für Weiterleitung an den internen Service `web` |

---

## Startbefehl

Der Reverse Proxy wird zusammen mit dem produktionsnahen Stack und Monitoring gestartet:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml up -d
```

---

## Status prüfen

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml ps
```

Erwartung:

```text
reverse-proxy   Up   0.0.0.0:80->80/tcp
web             healthy
redis           healthy
prometheus      healthy
grafana         healthy
cadvisor        healthy
```

---

## HTTP-Test

```powershell
Invoke-WebRequest -Uri http://localhost -UseBasicParsing
```

Erwartung:

```text
StatusCode : 200
Server     : nginx
```

Zusätzlich kann die Web-App im Browser geöffnet werden:

```text
http://localhost
```

---

## Wichtige NGINX-Konfiguration

Die Datei `proxy/nginx/conf.d/default.conf` enthält die Weiterleitung:

```nginx
location / {
    proxy_pass http://web:80;

    proxy_http_version 1.1;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

---

## Bedeutung der Header

| Header | Zweck |
|---|---|
| `Host` | ursprünglicher Hostname aus der Anfrage |
| `X-Real-IP` | IP-Adresse des anfragenden Clients aus Sicht des Proxys |
| `X-Forwarded-For` | Weiterleitungskette von Client-IP-Adressen |
| `X-Forwarded-Proto` | ursprüngliches Protokoll, z. B. `http` oder später `https` |

Diese Header sind wichtig, weil die App hinter dem Proxy sonst nur den Proxy selbst sieht.

---

## Betriebsnutzen

Ein Reverse Proxy hilft dabei:

```text
einen zentralen Einstiegspunkt bereitzustellen
interne Services nicht direkt öffentlich anzubieten
Routing später sauber zu erweitern
HTTPS/TLS zentral vorzubereiten
Logs am Eingangspunkt zu sammeln
spätere Domain- oder Subdomain-Strukturen vorzubereiten
```

---

## Lab vs. Produktion

Dieses Lab nutzt zunächst HTTP auf `localhost`.

In einer produktiven Umgebung wären zusätzlich nötig:

```text
HTTPS/TLS
echte Domain oder Subdomain
Zertifikatsverwaltung
restriktive Firewall-Regeln
Härtung der Proxy-Konfiguration
saubere Access- und Error-Logs
Monitoring des Proxys
```

---

## Wichtige Einordnung

Dieser Schritt ist bewusst noch kein HTTPS-Setup.

Er beantwortet zuerst die Betriebsfrage:

```text
Kann ein Reverse Proxy als zentraler Einstiegspunkt vor den Webservice geschaltet werden?
```

Der nächste sinnvolle Schritt ist:

```text
HTTPS/TLS im lokalen Lab ergänzen und erklären.
```

---

## Ergebnis

Der Reverse Proxy wurde erfolgreich gestartet.

Der Aufruf über `http://localhost` liefert HTTP Status `200` und wird von NGINX bedient.
