# Docker Network Basics im Docker Portfolio Lab

## Zweck

Diese Dokumentation fasst die Docker-Netzwerk-Lerneinheit im Docker Portfolio Lab zusammen.

Ziel war es, den Unterschied zwischen Host-Zugriffen, Container-Ports, internen Docker-Netzwerken, Service-Namen und `localhost` aus verschiedenen Perspektiven praktisch zu verstehen.

---

## Grundidee

Docker Compose erstellt für ein Projekt automatisch ein internes Netzwerk.

In diesem Lab heißt das Netzwerk:

```text
dockerbung_default
```

Alle wichtigen Container hängen in diesem Netzwerk:

```text
web
redis
prometheus
grafana
cadvisor
```

Dadurch können sie sich intern über Service-Namen erreichen.

---

## Wichtige Begriffe

| Begriff | Bedeutung |
|---|---|
| Host | dein Windows-/Docker-Desktop-Umfeld |
| Container | laufende isolierte Instanz eines Images |
| Docker-Netzwerk | internes Netzwerk zwischen Containern |
| Bridge-Netzwerk | lokales Docker-Netzwerk für Container-Kommunikation |
| Service-Name | Name aus Docker Compose, z. B. `web`, `redis`, `cadvisor` |
| Docker-DNS | interne Namensauflösung von Service-Namen zu Container-IP-Adressen |
| Host-Port | Port auf deinem Windows-Host, z. B. `8082` |
| Container-Port | Port innerhalb des Containers, z. B. `80` |
| Port-Mapping | Weiterleitung von Host-Port auf Container-Port |

---

## Netzwerkübersicht aus dem Lab

Der Befehl:

```powershell
docker network ls
```

zeigte unter anderem:

```text
dockerbung_default   bridge   local
```

Einordnung:

```text
dockerbung_default ist das automatisch erstellte Docker-Compose-Netzwerk.
Der Driver bridge bedeutet: Es ist ein lokales internes Container-Netzwerk.
Scope local bedeutet: Es existiert nur auf diesem Docker-Host.
```

---

## Netzwerkdetails

Der Befehl:

```powershell
docker network inspect dockerbung_default
```

zeigte:

```text
Name:    dockerbung_default
Driver:  bridge
Subnet:  172.18.0.0/16
Gateway: 172.18.0.1
```

Einordnung:

```text
Docker hat für die Container ein internes Netzwerk im Bereich 172.18.0.0/16 erstellt.
Das Gateway ist 172.18.0.1.
Die Container bekommen darin eigene interne IP-Adressen.
```

---

## Container und interne IP-Adressen

Die kompakte Prüfung:

```powershell
docker network inspect dockerbung_default --format "{{range .Containers}}{{.Name}} -> {{.IPv4Address}}{{println}}{{end}}"
```

zeigte:

```text
dockerbung-web-1 -> 172.18.0.3/16
dockerbung-grafana-1 -> 172.18.0.6/16
dockerbung-prometheus-1 -> 172.18.0.5/16
dockerbung-redis-1 -> 172.18.0.2/16
dockerbung-cadvisor-1 -> 172.18.0.4/16
```

Wichtige Einordnung:

```text
Diese IP-Adressen sind interne Docker-IP-Adressen.
Sie können sich bei Neustarts oder Neuaufbau des Stacks ändern.
Im Alltag sollte man Container deshalb nicht über feste IPs ansprechen,
sondern über Service-Namen.
```

---

## Service-Namen und Docker-DNS

Der Befehl:

```powershell
docker exec dockerbung-web-1 sh -c "getent hosts cadvisor prometheus grafana redis web"
```

zeigte:

```text
172.18.0.4        cadvisor  cadvisor
172.18.0.5        prometheus  prometheus
172.18.0.6        grafana  grafana
172.18.0.2        redis  redis
172.18.0.3        web  web
```

Einordnung:

```text
Docker Compose macht die Service-Namen im internen Netzwerk auflösbar.
Der web-Container kann also z. B. cadvisor über den Namen cadvisor erreichen.
```

Merksatz:

```text
Container sprechen sich im Compose-Netzwerk über Service-Namen an,
nicht über localhost und nicht über feste IP-Adressen.
```

---

## Aliases und DNSNames

Für den Webcontainer wurde geprüft:

```powershell
docker inspect dockerbung-web-1 --format "{{json .NetworkSettings.Networks}}"
```

Darin waren unter anderem sichtbar:

```json
"Aliases":["dockerbung-web-1","web"]
"DNSNames":["dockerbung-web-1","web","0dd36c1687ee"]
```

Einordnung:

```text
Der Container ist intern unter mehreren Namen erreichbar.
Für die Praxis ist vor allem der Service-Name web wichtig.
```

Weitere Service-Namen im Lab:

```text
web
redis
prometheus
grafana
cadvisor
```

---

## Host-Port vs. Container-Port

Der Befehl:

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

zeigte:

```text
web          0.0.0.0:8082->80/tcp
grafana      0.0.0.0:3000->3000/tcp
prometheus   0.0.0.0:9090->9090/tcp
cadvisor     0.0.0.0:8085->8080/tcp
redis        6379/tcp
```

Bedeutung:

| Service | Host-Zugriff | Container-intern | Von außen erreichbar? |
|---|---|---|---|
| web | `localhost:8082` | `web:80` | ja |
| grafana | `localhost:3000` | `grafana:3000` | ja |
| prometheus | `localhost:9090` | `prometheus:9090` | ja |
| cadvisor | `localhost:8085` | `cadvisor:8080` | ja |
| redis | kein Host-Port | `redis:6379` | nein, nur intern |

Merksatz:

```text
Links vom Pfeil = Port auf deinem Windows-Host.
Rechts vom Pfeil = Port im Container.
```

Beispiel:

```text
0.0.0.0:8082->80/tcp
```

bedeutet:

```text
Windows/Browser: http://localhost:8082
↓
Docker leitet weiter
↓
web-Container intern: Port 80
```

---

## Warum Redis keinen Host-Port braucht

Redis zeigte:

```text
6379/tcp
```

aber nicht:

```text
0.0.0.0:6379->6379/tcp
```

Einordnung:

```text
Redis lauscht intern auf Port 6379.
Der Port ist aber nicht auf dem Windows-Host veröffentlicht.
```

Das ist sinnvoll, weil Redis im Lab nur intern gebraucht wird.

Sicherheitsgrundsatz:

```text
Nur Ports veröffentlichen, die von außen wirklich benötigt werden.
```

---

## localhost aus verschiedenen Perspektiven

Ein wichtiger Lernpunkt war:

```text
localhost bedeutet immer: dieses System selbst.
```

Das heißt:

| Perspektive | Bedeutung von `localhost` |
|---|---|
| Browser auf Windows | Windows-/Docker-Host |
| web-Container | web-Container selbst |
| prometheus-Container | prometheus-Container selbst |
| grafana-Container | grafana-Container selbst |

Deshalb funktioniert im Browser:

```text
http://localhost:8085
```

aber im web-Container nicht automatisch:

```text
http://localhost:8085
```

Im Container muss stattdessen der Service-Name genutzt werden:

```text
http://cadvisor:8080
```

---

## Praktischer Beweis: Host-Zugriff

Vom Windows-Host wurde geprüft:

```powershell
(Invoke-WebRequest http://localhost:8082 -UseBasicParsing).StatusCode

(Invoke-WebRequest http://localhost:8085 -UseBasicParsing).StatusCode
```

Ergebnis:

```text
200
200
```

Einordnung:

```text
Vom Windows-Host aus sind die veröffentlichten Ports erreichbar.
```

---

## Praktischer Beweis: Container-zu-Container-Zugriff

Aus dem web-Container wurde cAdvisor per Service-Name aufgerufen:

```powershell
docker exec dockerbung-web-1 sh -c "wget -qO- http://cadvisor:8080/metrics | head -n 5"
```

Ergebnis:

```text
cadvisor_version_info ...
```

Einordnung:

```text
Der web-Container kann den cAdvisor-Container über den Service-Namen cadvisor erreichen.
```

---

## Praktischer Beweis: falsches localhost im Container

Absichtlich falscher Test:

```powershell
docker exec dockerbung-web-1 sh -c "wget -qO- http://localhost:8085 2>&1 | head -n 5"
```

Ergebnis:

```text
wget: can't connect to remote host: Connection refused
```

Einordnung:

```text
localhost im web-Container bedeutet web-Container selbst.
Dort läuft kein Dienst auf Port 8085.
Deshalb ist die Verbindung abgelehnt worden.
```

Das war der erwartete Lerneffekt.

---

## Netzwerk-Landkarte

Vereinfachte Sicht:

```text
Windows / Browser
│
├── localhost:8082 ─────→ web:80
├── localhost:3000 ─────→ grafana:3000
├── localhost:9090 ─────→ prometheus:9090
└── localhost:8085 ─────→ cadvisor:8080


Docker-Netzwerk: dockerbung_default
│
├── web
├── redis:6379
├── prometheus:9090
├── grafana:3000
└── cadvisor:8080
```

Metrikfluss:

```text
cAdvisor → Prometheus → Grafana
```

Anwendungsabhängigkeit:

```text
web → redis
```

---

## Typische Fehlerbilder

### Fehlerbild 1: localhost im Container falsch verwendet

Symptom:

```text
Container kann Dienst über localhost nicht erreichen.
```

Mögliche Ursache:

```text
localhost zeigt im Container auf den Container selbst,
nicht auf den Host und nicht auf einen anderen Container.
```

Besser:

```text
Service-Name verwenden, z. B. redis:6379 oder cadvisor:8080.
```

---

### Fehlerbild 2: falscher Port verwendet

Symptom:

```text
Browser erreicht Dienst nicht.
Container erreicht Dienst aber intern.
```

Mögliche Ursache:

```text
Host-Port und Container-Port verwechselt.
```

Beispiel:

```text
Browser: localhost:8085
Container intern: cadvisor:8080
```

---

### Fehlerbild 3: Service-Name falsch geschrieben

Symptom:

```text
Prometheus meldet Target DOWN oder "no such host".
```

Mögliche Ursache:

```text
Service-Name in der Konfiguration stimmt nicht mit dem Compose-Service überein.
```

Prüfung:

```powershell
docker exec dockerbung-web-1 sh -c "getent hosts cadvisor prometheus grafana redis web"
```

---

### Fehlerbild 4: Container hängt nicht im richtigen Netzwerk

Symptom:

```text
Container kann andere Services nicht erreichen.
```

Mögliche Ursache:

```text
Container ist nicht im gleichen Docker-Netzwerk.
```

Prüfung:

```powershell
docker ps --format "table {{.Names}}\t{{.Networks}}\t{{.Ports}}"
```

oder:

```powershell
docker network inspect dockerbung_default
```

---

## Diagnosebefehle

### Stack und Port-Mapping prüfen

```powershell
docker compose -f .\compose.prod.yml -f .\compose.monitoring.yml ps
```

### Docker-Netzwerke anzeigen

```powershell
docker network ls
```

### Container-Netzwerke und Ports kompakt anzeigen

```powershell
docker ps --format "table {{.Names}}\t{{.Networks}}\t{{.Ports}}"
```

### Compose-Netzwerk inspizieren

```powershell
docker network inspect dockerbung_default
```

### Container und interne IPs kompakt anzeigen

```powershell
docker network inspect dockerbung_default --format "{{range .Containers}}{{.Name}} -> {{.IPv4Address}}{{println}}{{end}}"
```

### Service-Namen aus Container prüfen

```powershell
docker exec dockerbung-web-1 sh -c "getent hosts cadvisor prometheus grafana redis web"
```

### Interne HTTP-Verbindung testen

```powershell
docker exec dockerbung-web-1 sh -c "wget -qO- http://cadvisor:8080/metrics | head -n 5"
```

### Absichtlich falsches localhost prüfen

```powershell
docker exec dockerbung-web-1 sh -c "wget -qO- http://localhost:8085 2>&1 | head -n 5"
```

---

## Profi-/Später-Wissen

Diese Docker-Netzwerkgrundlagen helfen später bei Kubernetes.

Ähnliche Konzepte dort:

| Docker Compose | Kubernetes |
|---|---|
| Service-Name | Kubernetes Service |
| Container-Port | containerPort |
| veröffentlichter Port | Service / Ingress / LoadBalancer |
| Compose-Netzwerk | Cluster-Netzwerk |
| Healthcheck | Readiness/Liveness Probe |

Wichtig:

```text
Kubernetes ist komplexer,
aber viele Grundideen beginnen schon bei Docker Compose.
```

---

## Kommunikationsstufe A

```text
Docker-Netzwerk geprüft: Alle Lab-Container hängen im Compose-Netzwerk dockerbung_default. Service-Namen werden intern aufgelöst, Host-Zugriffe über localhost funktionieren, Git ist sauber.
```

---

## Kommunikationsstufe B

```text
Das Docker-Compose-Netzwerk dockerbung_default wurde geprüft. Alle Services hängen im internen Bridge-Netzwerk und sind dort über Service-Namen erreichbar. Host-Zugriffe erfolgen über veröffentlichte Ports wie localhost:8082 oder localhost:8085, während Container intern Service-Namen wie cadvisor:8080 verwenden. Git ist sauber.
```

---

## Lessons Learned

- Docker Compose erstellt automatisch ein internes Netzwerk pro Projekt.
- In diesem Lab heißt das Netzwerk `dockerbung_default`.
- Alle Lab-Container hängen in diesem Netzwerk.
- Container können sich intern über Service-Namen erreichen.
- Service-Namen werden über Docker-DNS aufgelöst.
- Interne Docker-IP-Adressen existieren, sollten aber nicht hart verwendet werden.
- Host-Port und Container-Port sind unterschiedliche Dinge.
- `localhost` bedeutet immer "dieses System selbst".
- Vom Windows-Browser nutzt man `localhost:<Host-Port>`.
- Zwischen Containern nutzt man `<Service-Name>:<Container-Port>`.
- Redis braucht keinen veröffentlichten Host-Port, weil es nur intern gebraucht wird.
