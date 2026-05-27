# Lokales HTTPS mit NGINX Reverse Proxy

## Zweck

Dieses Dokument beschreibt die Erweiterung des Docker Portfolio Lab von HTTP auf lokales HTTPS.

Ziel ist, TLS-Terminierung am Reverse Proxy praktisch zu verstehen:

```text
Browser -> https://localhost -> NGINX Reverse Proxy -> web:80
```

Der Webcontainer selbst bleibt intern über HTTP erreichbar. HTTPS wird am Reverse Proxy beendet.

---

## Ergebnis

Der NGINX Reverse Proxy wurde erweitert um:

```text
Port 80  -> HTTP
Port 443 -> HTTPS
```

Der HTTP-Aufruf wird auf HTTPS weitergeleitet:

```text
http://localhost -> https://localhost
```

Der HTTPS-Aufruf liefert erfolgreich HTTP Status `200 OK`.

---

## Geänderte Dateien

| Datei | Änderung |
|---|---|
| `.gitignore` | lokale Zertifikate und private Schlüssel werden ignoriert |
| `compose.proxy.yml` | Port `443:443` und Zertifikats-Mount ergänzt |
| `proxy/nginx/conf.d/default.conf` | HTTP-Redirect auf HTTPS und TLS-Konfiguration ergänzt |

---

## Lokale Zertifikate

Das Lab nutzt ein selbstsigniertes Zertifikat für `localhost`.

Lokale Dateien:

```text
certs/localhost.crt
certs/localhost.key
```

Wichtig:

| Datei | Bedeutung | Git |
|---|---|---|
| `localhost.crt` | öffentliches Zertifikat | nicht committed |
| `localhost.key` | privater Schlüssel | niemals committen |

Der Ordner `certs/` wird durch `.gitignore` geschützt.

---

## Zertifikat erzeugen

Das Zertifikat wurde mit einem temporären Alpine-Container und OpenSSL erzeugt:

```powershell
docker run --rm -v "${PWD}/certs:/certs" alpine:3.20 sh -c "apk add --no-cache openssl >/dev/null && openssl req -x509 -nodes -newkey rsa:2048 -keyout /certs/localhost.key -out /certs/localhost.crt -days 365 -subj '/CN=localhost' -addext 'subjectAltName=DNS:localhost,IP:127.0.0.1'"
```

### Erklärung

| Teil | Bedeutung |
|---|---|
| `docker run --rm` | startet einen temporären Container und entfernt ihn danach |
| `-v "${PWD}/certs:/certs"` | bindet den lokalen Zertifikatsordner in den Container ein |
| `alpine:3.20` | kleines Linux-Image als Werkzeugcontainer |
| `apk add --no-cache openssl` | installiert OpenSSL im temporären Container |
| `openssl req -x509` | erstellt ein selbstsigniertes Zertifikat |
| `-nodes` | privater Schlüssel wird nicht zusätzlich passwortgeschützt |
| `-newkey rsa:2048` | erzeugt einen neuen RSA-Schlüssel mit 2048 Bit |
| `-keyout /certs/localhost.key` | schreibt den privaten Schlüssel |
| `-out /certs/localhost.crt` | schreibt das Zertifikat |
| `-days 365` | Zertifikat ist 365 Tage gültig |
| `-subj '/CN=localhost'` | setzt den Namen auf `localhost` |
| `-addext 'subjectAltName=DNS:localhost,IP:127.0.0.1'` | macht das Zertifikat passend für `localhost` und `127.0.0.1` |

---

## NGINX-Konfiguration

Die HTTP-Konfiguration leitet auf HTTPS weiter:

```nginx
server {
    listen 80;
    server_name localhost;

    return 301 https://$host$request_uri;
}
```

Die HTTPS-Konfiguration nutzt Zertifikat und privaten Schlüssel:

```nginx
server {
    listen 443 ssl;
    server_name localhost;

    ssl_certificate /etc/nginx/certs/localhost.crt;
    ssl_certificate_key /etc/nginx/certs/localhost.key;

    ssl_protocols TLSv1.2 TLSv1.3;
}
```

---

## Stack starten

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml up -d
```

Dieser Befehl startet den produktionsnahen Stack, Monitoring und den NGINX Reverse Proxy.

---

## Verifikation

### Ports prüfen

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml ps
```

Erwartung beim Reverse Proxy:

```text
0.0.0.0:80->80/tcp
0.0.0.0:443->443/tcp
```

### HTTP-Redirect prüfen

```powershell
curl.exe -I http://localhost
```

Erwartung:

```text
HTTP/1.1 301 Moved Permanently
Location: https://localhost/
```

### HTTPS prüfen

```powershell
curl.exe -k -I https://localhost
```

Erwartung:

```text
HTTP/1.1 200 OK
Server: nginx
```

`-k` bedeutet, dass `curl` die Zertifikatswarnung ignoriert. Das ist in diesem lokalen Lab nötig, weil das Zertifikat selbstsigniert ist.

---

## Browser-Hinweis

Beim Öffnen von:

```text
https://localhost
```

kann der Browser eine Zertifikatswarnung anzeigen.

Das ist im Lab normal, weil das Zertifikat nicht von einer öffentlichen Zertifizierungsstelle signiert wurde.

---

## Lab vs. Produktion

| Thema | Lokales Lab | Produktion |
|---|---|---|
| Zertifikat | selbstsigniert | öffentlich vertrauenswürdige CA oder interne PKI |
| Domain | `localhost` | echte Domain/Subdomain |
| Schlüsselverwaltung | lokaler `certs/`-Ordner | Secret Manager, Vault, Kubernetes Secret oder Zertifikatsmanager |
| Erneuerung | manuell | automatisiert |
| Browservertrauen | Warnung möglich | keine Warnung bei korrekter Konfiguration |
| HTTPS-Ziel | Lernnachweis | verbindlicher Sicherheitsstandard |

---

## Sicherheitsregeln

```text
Private Schlüssel nicht committen.
Zertifikate und Keys nicht ungeprüft teilen.
Screenshots vor Veröffentlichung prüfen.
Produktive Zertifikate nicht im Repository speichern.
```

---

## Fazit

Das Lab zeigt jetzt die Grundidee von HTTPS am Reverse Proxy:

```text
NGINX nimmt HTTPS an,
entschlüsselt die Anfrage,
leitet intern an den Webcontainer weiter
und schützt lokale Zertifikatsdateien vor Git-Commit.
```

Damit ist die Grundlage für spätere produktionsnähere Themen wie echte Domains, Let's Encrypt, Zertifikatsrotation und Secret Management gelegt.
