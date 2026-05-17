# GitHub Actions CI für das Docker Portfolio Lab

## Zweck

Diese Einheit ergänzt das Projekt um eine erste einfache CI-Pipeline mit GitHub Actions.

CI/CD gehört zu den wichtigsten Grundbegriffen im DevOps-Umfeld. In diesem Projekt starten wir bewusst mit einem kleinen, glaubwürdigen CI-Schritt: GitHub soll automatisch prüfen, ob die Docker-Compose-Konfiguration gültig ist, das Web-Image gebaut werden kann und der Stack mit Web + Redis grundsätzlich funktioniert.

---

## 0. Begriffsklärung: CI, CD und CI/CD

### CI = Continuous Integration

**Continuous Integration** bedeutet auf Deutsch ungefähr:

> fortlaufende Integration von Änderungen

Praktisch heißt das:

```text
Entwickler ändern Code.
Die Änderungen werden regelmäßig ins Repository gepusht oder per Pull Request vorgeschlagen.
Danach laufen automatisch Prüfungen.
Fehler sollen möglichst früh auffallen.
```

Typische CI-Prüfungen sind:

```text
Code auschecken
Abhängigkeiten installieren
Konfigurationsdateien prüfen
Tests ausführen
Docker Images bauen
Skripte prüfen
Build-Ergebnis bewerten
```

In diesem Projekt bedeutet CI konkret:

```text
GitHub prüft automatisch:
- Ist compose.prod.yml gültig?
- Kann das Web-Image gebaut werden?
- Startet der Stack?
- Antwortet Web?
- Antwortet Redis?
```

---

### CD = Continuous Delivery oder Continuous Deployment

CD kann zwei Bedeutungen haben. Beide hängen zusammen, sind aber nicht identisch.

#### Continuous Delivery

**Continuous Delivery** bedeutet:

> Die Software wird nach erfolgreichen Tests automatisch in einen bereitstellbaren Zustand gebracht.

Das heißt: Die Software könnte ausgeliefert werden, aber ein Mensch entscheidet meist noch, ob wirklich veröffentlicht wird.

Beispiel:

```text
Code wird gepusht.
CI läuft erfolgreich.
Docker Image wird gebaut.
Image wird in eine Registry hochgeladen.
Deployment nach Staging ist vorbereitet.
Ein Mensch gibt Production frei.
```

#### Continuous Deployment

**Continuous Deployment** geht einen Schritt weiter:

> Nach erfolgreichen Tests wird automatisch in eine Zielumgebung deployed.

Beispiel:

```text
Code wird gepusht.
Tests laufen grün.
Image wird gebaut.
Deployment nach Production passiert automatisch.
```

Das ist mächtiger, aber auch riskanter. Dafür braucht man sehr gute Tests, Rollback-Strategien, Monitoring und Freigabeprozesse.

---

### CI/CD als Sammelbegriff

**CI/CD** ist der Sammelbegriff für den automatisierten Weg von einer Änderung bis zur Bereitstellung oder Auslieferung.

Vereinfacht:

```text
Commit → automatische Prüfung → Build → optional Release/Deployment
```

In diesem Projekt machen wir aktuell nur den ersten sinnvollen Teil:

```text
CI: prüfen, bauen, starten, Web und Redis testen
```

Noch nicht:

```text
CD: automatisch deployen
```

Das ist bewusst so, weil das Projekt ein Lern- und Portfolio-Lab ist und keine echte Production-Umgebung betreibt.

---

## 1. Job-Szenario

Ein Teamlead sagt:

> „Du hast lokal viele manuelle Prüfungen gemacht. Bitte sorge dafür, dass GitHub bei jedem Push automatisch prüft, ob die Compose-Konfiguration weiterhin gültig ist und der Stack grundsätzlich startet.“

Das ist eine realistische Junior-Aufgabe: nicht direkt eine komplette Enterprise-Pipeline bauen, sondern einen ersten automatischen Qualitätscheck einführen.

---

## 2. Betriebsanforderung

| Anforderung | Bedeutung |
|---|---|
| Workflow läuft bei Push auf `main` | Änderungen werden automatisch geprüft |
| Workflow läuft bei Pull Requests | spätere Review-Prozesse werden vorbereitet |
| Compose-Konfiguration wird geprüft | YAML-/Compose-Fehler werden früh erkannt |
| Web-Image wird gebaut | Dockerfile und Build-Kontext werden geprüft |
| Stack wird im CI-Runner gestartet | Integrationstest statt nur Dateiprüfung |
| Web wird per HTTP geprüft | Webdienst ist erreichbar |
| Redis wird per PING geprüft | Redis ist fachlich erreichbar |
| CI-Secret wird nicht committed | keine Secrets im Repository |
| Bei Fehlern werden Logs angezeigt | bessere Diagnose |
| Stack wird am Ende entfernt | CI-Runner bleibt sauber |

---

## 3. Lernziel

Nach dieser Einheit sollst du erklären können:

```text
Ich kann mit GitHub Actions eine einfache CI-Prüfung für ein Docker-Compose-Projekt aufbauen.
Die Pipeline prüft nicht nur Dateien, sondern startet den Stack und testet Web + Redis.
```

Außerdem sollst du den Unterschied erklären können:

```text
CI prüft automatisch.
Continuous Delivery bereitet Auslieferung vor.
Continuous Deployment rollt automatisch aus.
```

---

## 4. Wichtige Begriffe

| Begriff | Erklärung |
|---|---|
| Repository | Git-Projekt auf GitHub |
| Workflow | YAML-Datei, die GitHub Actions ausführt |
| Job | Ausführungseinheit innerhalb eines Workflows |
| Step | einzelner Arbeitsschritt im Job |
| Runner | virtuelle Maschine, auf der der Workflow läuft |
| Push | Hochladen lokaler Commits zu GitHub |
| Pull Request | Vorschlag, Änderungen in einen Branch zu übernehmen |
| Build | Erzeugen eines lauffähigen Artefakts, z. B. Docker Image |
| Test | automatische Prüfung, ob etwas funktioniert |
| Exit-Code | Rückgabewert eines Befehls; `0` bedeutet Erfolg |
| Pipeline | Abfolge automatisierter Schritte |
| Secret | sensibles Geheimnis wie Passwort, Token oder API-Key |

---

## 5. Datei

Neue Datei:

```text
.github/workflows/docker-lab-ci.yml
```

Diese Datei definiert die automatische CI-Pipeline.

---

## 6. Was die Pipeline macht

```text
Repository auschecken
Docker-Versionen anzeigen
lokale CI-Secret-Datei erzeugen
docker compose config ausführen
Web-Image bauen
Stack starten
Healthcheck-Zeit abwarten
Web per curl prüfen
Redis per PING/PONG prüfen
bei Fehlern Logs anzeigen
Stack aufräumen
```

---

## 7. Security-Hinweis

Die Pipeline erzeugt im GitHub-Actions-Runner eine lokale Secret-Datei:

```text
secrets/redis_password.txt
```

Diese Datei wird nur im kurzlebigen Runner erzeugt und nicht committed.

Wichtig:

```text
Secrets niemals in Workflow-Dateien hardcoden.
Secrets niemals in Logs ausgeben.
Für echte produktive Secrets: GitHub Actions Secrets oder einen Secret Manager nutzen.
```

Für dieses Lab wird ein zufälliges CI-Passwort erzeugt:

```bash
openssl rand -hex 32 > secrets/redis_password.txt
```

Das ist für den CI-Test ausreichend, weil der Stack nur innerhalb des kurzlebigen Runners läuft.

---

## 8. Verifikation

Nach dem Commit und Push:

1. GitHub Repository öffnen
2. Tab **Actions** öffnen
3. Workflow **Docker Lab CI** auswählen
4. Prüfen, ob der Lauf grün ist

Erwartung:

```text
Repository auschecken ✅
Docker-Versionen anzeigen ✅
Lokale CI-Secret-Datei erzeugen ✅
Docker Compose Konfiguration prüfen ✅
Web-Image bauen ✅
Stack starten ✅
Web per HTTP prüfen ✅
Redis per PING prüfen ✅
Stack aufräumen ✅
```

---

## 9. Realistischer Fehlerfall

Wenn jemand später eine falsche YAML-Einrückung in `compose.prod.yml` macht, sollte dieser Schritt fehlschlagen:

```text
Docker Compose Konfiguration prüfen
```

Wenn jemand `app/index.html` oder den Dockerfile-Pfad beschädigt, könnte dieser Schritt fehlschlagen:

```text
Web-Image bauen
```

Wenn Redis wegen Secret-/Healthcheck-Problemen nicht startet, sollte dieser Schritt fehlschlagen:

```text
Redis per PING prüfen
```

---

## 10. Diagnoseweg

Bei fehlerhaftem Workflow:

```text
GitHub → Repository → Actions → fehlgeschlagener Workflow → fehlgeschlagenen Step öffnen
```

Dann prüfen:

| Fehlerstelle | Mögliche Ursache |
|---|---|
| Compose config | YAML-/Compose-Fehler |
| Build web | Dockerfile oder Build-Kontext fehlerhaft |
| Stack starten | Secret-Datei fehlt, Image-Problem, Compose-Problem |
| Web prüfen | Port nicht erreichbar, Webcontainer nicht healthy |
| Redis prüfen | Redis nicht healthy, Passwort/Secret-Problem |
| Logs bei Fehler anzeigen | Hinweise aus Containerlogs lesen |

---

## 11. Fix oder Rollback

Wenn der Workflow fehlerhaft ist und noch nicht committed wurde:

```powershell
git restore .github/workflows/docker-lab-ci.yml
```

Wenn der Workflow committed wurde, aber korrigiert werden soll:

```powershell
# Datei korrigieren
git add .github/workflows/docker-lab-ci.yml
git commit -m "Korrigiere Docker Lab CI Workflow"
git push
```

Wenn der Workflow komplett entfernt werden soll:

```powershell
git rm .github/workflows/docker-lab-ci.yml
git commit -m "Entferne Docker Lab CI Workflow"
git push
```

---

## 12. Unterschied Lernlabor vs. Produktion

| Thema | Lernlabor | Produktion |
|---|---|---|
| CI-Ziel | Compose/Build/Start prüfen | Tests, Security Scans, Deployments |
| Secret | zufällig im Runner erzeugt | GitHub Secrets, Vault, Cloud Secret Manager |
| Umgebung | GitHub-hosted Runner | kontrollierte Build-/Deploy-Umgebung |
| Testtiefe | Web + Redis erreichbar | Unit, Integration, E2E, Security, Performance |
| Deployment | keines | Staging/Production mit Freigaben |
| Freigabe | automatisch bei Push | Pull Request, Review, Branch Protection |
| Rollback | nicht Teil dieser Einheit | geplanter Prozess |

---

## 13. Architect-Notiz

Die größere Architekturentscheidung lautet:

> Welche Qualitätschecks müssen automatisch laufen, bevor Änderungen als vertrauenswürdig gelten?

In diesem Projekt starten wir klein:

```text
Compose-Datei gültig
Image baubar
Stack startbar
Web erreichbar
Redis erreichbar
```

Das ist bewusst noch keine vollständige Enterprise-Pipeline. Es ist aber ein glaubwürdiger und sinnvoller erster CI-Schritt.

Später könnte daraus werden:

```text
Linting
Unit Tests
Integration Tests
Container Security Scan
Secret Scanning
Image Push in Registry
Deployment nach Staging
manuelle Freigabe für Production
Rollback-Automation
```
