# Container Security Stage 1

## Zweck

Dieses Dokument beschreibt die erste Container-Security-Härtung im Docker Portfolio Lab.

Ziel ist nicht, den Stack maximal restriktiv zu konfigurieren, sondern einen sicheren ersten Härtungsschritt kontrolliert umzusetzen, zu prüfen und zu dokumentieren.

---

## Ausgangslage

Vor der Härtung liefen die geprüften Hauptcontainer ohne zusätzliche Security-Optionen.

Prüfung:

```powershell
docker exec dockerbung-web-1 sh -c 'id'
docker exec dockerbung-redis-1 sh -c 'id'
docker exec dockerbung-reverse-proxy sh -c 'id'
```

Ergebnis:

```text
uid=0(root)
```

Die Container liefen also als `root` im Container.

Zusätzlich wurde geprüft:

```powershell
docker inspect dockerbung-web-1 --format '{{json .Config.User}} {{json .HostConfig.SecurityOpt}} {{json .HostConfig.CapDrop}} {{json .HostConfig.ReadonlyRootfs}}'
docker inspect dockerbung-redis-1 --format '{{json .Config.User}} {{json .HostConfig.SecurityOpt}} {{json .HostConfig.CapDrop}} {{json .HostConfig.ReadonlyRootfs}}'
docker inspect dockerbung-reverse-proxy --format '{{json .Config.User}} {{json .HostConfig.SecurityOpt}} {{json .HostConfig.CapDrop}} {{json .HostConfig.ReadonlyRootfs}}'
```

Typische ungehärtete Ausgabe:

```text
"" null null false
```

Bedeutung:

| Wert | Bedeutung |
|---|---|
| `""` | kein expliziter User gesetzt |
| `null` bei `SecurityOpt` | keine zusätzlichen Security-Optionen |
| `null` bei `CapDrop` | keine Capabilities entfernt |
| `false` bei `ReadonlyRootfs` | Root-Dateisystem ist beschreibbar |

---

## Umgesetzte Härtung

In `compose.prod.yml` und `compose.proxy.yml` wurde für die Services `web`, `redis` und `reverse-proxy` ergänzt:

```yaml
security_opt:
  - no-new-privileges:true
```

Betroffene Services:

```text
web
redis
reverse-proxy
```

---

## Was bedeutet `no-new-privileges:true`?

`no-new-privileges:true` verhindert, dass Prozesse innerhalb des Containers neue zusätzliche Privilegien erlangen.

Das ist ein Schutz gegen bestimmte Formen von Privilege Escalation.

Wichtig:

```text
Es macht root nicht automatisch zu non-root.
Es entfernt keine Linux-Capabilities.
Es macht das Dateisystem nicht read-only.
Es ersetzt kein Image Scanning.
Es ersetzt keine vollständige Container-Härtung.
```

Aber es ist ein sinnvoller erster Härtungsschritt, weil er meist wenig Risiko für einfache Dienste verursacht.

---

## Privilege Escalation

Privilege Escalation bedeutet:

```text
Ein Prozess startet mit begrenzten Rechten,
findet aber einen Weg,
höhere Rechte zu bekommen.
```

Beispiele:

```text
normaler User -> root im Container
Containerprozess -> zusätzliche Linux-Rechte
Container-root -> mehr Zugriff durch falsche Mounts oder Schwachstellen
```

Container teilen sich den Kernel mit dem Host beziehungsweise bei Docker Desktop mit der Docker-VM. Deshalb ist es sinnvoll, Containerrechte möglichst klein zu halten.

---

## Capabilities

Linux Capabilities sind einzelne Teilrechte, die früher grob unter „root darf alles“ zusammengefasst waren.

Beispiele:

| Capability | Bedeutung |
|---|---|
| `NET_BIND_SERVICE` | an privilegierte Ports wie 80 oder 443 binden |
| `NET_RAW` | Raw-Sockets nutzen, z. B. für bestimmte Netzwerktools |
| `CHOWN` | Dateibesitzer ändern |
| `SETUID` | User-ID wechseln |
| `SETGID` | Gruppen-ID wechseln |
| `SYS_ADMIN` | sehr mächtige Admin-Fähigkeit, möglichst vermeiden |
| `SYS_PTRACE` | Prozesse debuggen oder untersuchen |

Docker gibt Containern standardmäßig nicht alle Linux-Capabilities, sondern eine begrenzte Auswahl.

---

## `cap_drop`

Mit `cap_drop` kann man Capabilities entfernen.

Beispiel:

```yaml
cap_drop:
  - NET_RAW
```

Das bedeutet:

```text
Der Container darf keine Raw-Sockets mehr verwenden.
```

Stärker:

```yaml
cap_drop:
  - ALL
```

Das bedeutet:

```text
Alle Linux-Capabilities werden entfernt.
```

Wenn ein Dienst danach eine bestimmte Capability benötigt, kann sie gezielt wieder ergänzt werden:

```yaml
cap_drop:
  - ALL
cap_add:
  - NET_BIND_SERVICE
```

Das folgt dem Least-Privilege-Prinzip:

```text
So wenig Rechte wie möglich,
so viele wie nötig.
```

---

## Warum nicht direkt `cap_drop: ALL`?

`cap_drop: ALL` ist eine stärkere Härtung, kann aber Dienste beschädigen.

Beispiele:

```text
NGINX kann Probleme bekommen, wenn bestimmte Port-/Prozessrechte fehlen.
Tools im Container funktionieren nicht mehr.
Healthchecks oder interne Startskripte verhalten sich anders.
```

Deshalb wurde in Stage 1 bewusst nur `no-new-privileges:true` gesetzt.

---

## Weitere Schutzmechanismen

### Non-root User

```yaml
user: "1000:1000"
```

Der Containerprozess läuft dann nicht als root.

Vorteil:

```text
weniger Rechte bei kompromittierter Anwendung
```

Risiko:

```text
Dateirechte, Volumes und Ports müssen passend konfiguriert sein.
```

---

### Read-only Root Filesystem

```yaml
read_only: true
```

Das Root-Dateisystem wird schreibgeschützt.

Vorteil:

```text
Angreifer oder fehlerhafte Prozesse können schwieriger Dateien im Container verändern.
```

Risiko:

```text
Viele Dienste brauchen Schreibpfade wie /tmp, /var/run oder /var/cache.
```

Dann braucht man gezielte temporäre Schreibbereiche:

```yaml
tmpfs:
  - /tmp
  - /var/run
```

---

### Ressourcenlimits

Beispiele:

```yaml
mem_limit: 256m
cpus: "0.50"
```

Vorteil:

```text
Ein Container kann nicht unbegrenzt RAM oder CPU verbrauchen.
```

Das ist nicht nur Performance, sondern auch Betriebssicherheit.

---

### Keine unnötigen Ports

Gute Praxis:

```text
Nur notwendige Services veröffentlichen.
Interne Dienste bleiben im Docker-Netzwerk.
```

Im aktuellen Lab ist Redis nicht direkt am Host veröffentlicht. Das ist gut.

---

### Keine Secrets in ENV, Logs oder Images

Secrets sollen nicht:

```text
in Git landen
in Dockerfiles stehen
in ENV sichtbar sein
in Logs erscheinen
in Screenshots auftauchen
```

Dieses Projekt nutzt für Redis und Grafana lokale Secret-Dateien und schützt sie per `.gitignore`.

---

### Kein `privileged: true`

`privileged: true` gibt einem Container sehr weitreichende Rechte.

Beispiel:

```yaml
privileged: true
```

Das sollte nur mit sehr guter Begründung genutzt werden.

Im Betrieb wäre eine wichtige Frage:

```text
Warum braucht dieser Container privilegierten Zugriff?
Gibt es eine gezieltere Alternative?
```

---

## Verifikation

Nach der Änderung wurde der Stack neu gestartet:

```powershell
docker compose -f compose.prod.yml -f compose.monitoring.yml -f compose.proxy.yml up -d
```

Danach wurde geprüft:

```powershell
docker inspect dockerbung-web-1 --format '{{json .HostConfig.SecurityOpt}}'
docker inspect dockerbung-redis-1 --format '{{json .HostConfig.SecurityOpt}}'
docker inspect dockerbung-reverse-proxy --format '{{json .HostConfig.SecurityOpt}}'
```

Erwartung:

```json
["no-new-privileges:true"]
```

---

## Warum Security-Härtung testpflichtig ist

Security-Härtung kann Dienste beschädigen.

Beispiele:

| Härtung | Mögliche Nebenwirkung |
|---|---|
| `read_only: true` | Dienst kann nicht mehr in benötigte Pfade schreiben |
| `cap_drop: ALL` | Prozess verliert benötigte Linux-Rechte |
| `user: nonroot` | Dateirechte oder Portbindung passen nicht |
| Ressourcenlimits | Dienst hat bei Last zu wenig RAM oder CPU |
| strenge Mounts | Anwendung findet benötigte Dateien nicht mehr |

Deshalb gilt:

```text
Härten
testen
Logs prüfen
Funktion verifizieren
erst dann committen
```

---

## Lab vs. Produktion

| Thema | Lab | Produktion |
|---|---|---|
| `no-new-privileges` | Stage-1-Härtung | sinnvoller Standardkandidat |
| Non-root User | noch nicht umgesetzt | meist empfehlenswert |
| Capabilities | noch nicht reduziert | pro Service prüfen und minimieren |
| Read-only Root FS | noch nicht umgesetzt | sinnvoll, aber testpflichtig |
| Ressourcenlimits | noch nicht gesetzt | meist erforderlich |
| Seccomp/AppArmor | Standardprofile | ggf. eigene Profile |
| Image Scanning | nächster Block | Teil der Pipeline |

---

## Fazit

Stage 1 setzt eine erste Security-Option:

```text
no-new-privileges:true
```

Damit wird eine wichtige Schutzschicht gegen bestimmte Privilegien-Eskalationen ergänzt.

Der wichtigste Lernpunkt:

```text
Container Security besteht aus mehreren Schutzschichten.
Jede Härtung muss getestet werden,
weil sie das Verhalten von Diensten verändern kann.
```
