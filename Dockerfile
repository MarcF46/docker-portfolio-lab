# Wir starten mit einem fertigen Nginx-Image.
# Nginx ist ein sehr verbreiteter Webserver.
# Alpine ist eine besonders kleine Linux-Variante.
FROM nginx:alpine-slim

# Wir setzen das Arbeitsverzeichnis im Container.
# In diesem Ordner sucht Nginx standardmäßig nach Webseiten-Dateien.
WORKDIR /usr/share/nginx/html

# Wir kopieren die Webseite aus unserem Projektordner app/
# fest in das Docker-Image.
# Dadurch ist die Datei später unabhängig von deinem Windows-Ordner.
COPY app/index.html ./index.html

# Wir dokumentieren, dass der Container intern auf Port 80 lauscht.
# EXPOSE öffnet den Port nicht automatisch, sondern beschreibt ihn nur.
EXPOSE 80

# Der Healthcheck prüft regelmäßig, ob der Webserver noch antwortet.
# Wenn wget die Seite nicht erreichen kann, gilt der Container als ungesund.
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget --quiet --tries=1 --spider http://127.0.0.1 || exit 1
