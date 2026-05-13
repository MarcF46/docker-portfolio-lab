# Docker Übung – Erstes Docker-Lernprojekt

## Ziel dieses Projekts

Dieses Projekt ist mein erstes praktisches Docker-Lernprojekt.  
Es dient dazu, die Grundlagen von Docker, Dockerfiles, Docker Compose, Images, Containern und einfacher Webserver-Bereitstellung zu verstehen.

## Was ist Docker?

Docker ist eine Plattform, mit der Anwendungen in sogenannten Containern ausgeführt werden können.

Ein Container ist eine isolierte Laufzeitumgebung.  
Das bedeutet: Eine Anwendung läuft zusammen mit allem, was sie benötigt, in einem abgegrenzten Bereich.

## Wichtige Begriffe

### Image

Ein Image ist eine fertige Vorlage für einen Container.  
Man kann es sich wie ein eingefrorenes Software-Paket vorstellen.

### Container

Ein Container ist eine laufende Instanz eines Images.  
Wenn ein Image der Bauplan ist, dann ist der Container das tatsächlich gestartete Objekt.

### Dockerfile

Ein Dockerfile ist eine Textdatei mit Bauanweisungen für ein Docker-Image.

### Docker Compose

Docker Compose ist ein Werkzeug, mit dem mehrere Container gemeinsam über eine YAML-Datei gestartet und verwaltet werden können.

### YAML

YAML ist ein Dateiformat, das häufig für Konfigurationsdateien genutzt wird.  
Bei Docker Compose beschreibt eine YAML-Datei, welche Container gestartet werden sollen.

## Enthaltene Dateien

```text
docker-compose.yml
Dockerfile
index.html
.gitignore
README.md