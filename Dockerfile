# 1. Wir nehmen den fertigen Nginx-Webserver als Basis
FROM nginx:alpine

# 2. Wir kopieren unsere HTML-Datei in den Web-Ordner des Containers
COPY index.html /usr/share/nginx/html/index.html

# 3. Der Container soll auf Port 80 lauschen (Standard für Nginx)
EXPOSE 80