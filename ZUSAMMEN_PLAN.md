# Fahrplan Zusammen spielen (Lernprojekt 4)

Ziel aus `design.md` (Repo CazeX-studio/Spieldesign): **2–4 Spieler gleichzeitig in Kreuzweg, gemeinsamer Kampf, Chat.**
Das ist der Schritt zum Online-Spiel. Grundlage ist die Kreuzweg-Demo (Lernprojekt 3).

## So funktioniert das Zusammenspielen (einfach erklärt)

- Einer ist **Gastgeber** (später ein **Server** im Internet). Nur bei ihm gibt es die „echte“ Stadt mit allen Regeln.
- Die **Mitspieler** schicken nur Befehle („laufe nach rechts“, „rede mit Ye“, „wähle Antwort 2“) und bekommen zurück,
  wo alle stehen, dazu ihren eigenen Fortschritt, Gespräche und Meldungen.
- Das ist genau die Trennung aus Lernprojekt 3 („Regeln getrennt von der Anzeige, alles über Befehle“). Deshalb
  musste an der Spiellogik der Stadt fast nichts geändert werden.
- Verbindung über **WebSocket**: Das geht auch im Browser und am Handy, also passt es zur Web-Version.
- Allein spielen bleibt wie bisher (Menü → „Kreuzweg-Demo“).

| Nr. | Schritt | Stand |
|-----|---------|-------|
| 0 | Plan schreiben (diese Datei) | erledigt |
| 1 | **Zusammen in Kreuzweg laufen:** Bildschirm „Zusammen spielen“ (Name, Figur, Adresse), Gastgeber werden (PC) oder beitreten. Alle sehen sich mit Namen in der Stadt laufen. Jeder behält seinen eigenen Fortschritt und spielt die Geschichte für sich, Kämpfe noch allein. Server ohne Grafik für später. | eingebaut – Marco testet |
| 2 | **Über das Internet:** Server ohne Grafik bei einem Anbieter, sichere Verbindung (nötig für Browser und Handy), Adresse fest in der Web-Version, damit Freunde einfach auf „Beitreten“ tippen. Braucht Marcos Entscheidung (siehe unten). | offen |
| 3 | **Chat:** Chatfenster (Enter am PC, Knopf am Handy) und Sprechblase über dem Kopf. Erst ein Kanal für alle in Kreuzweg, später Gruppe und Flüstern (design.md: Welt, Gruppe, Gilde, Flüstern). | offen |
| 4 | **Gruppe bilden:** Mitspieler antippen → „In Gruppe einladen“. Gruppenfenster mit Namen, Stufe und Leben. Bis zu 4 Spieler. | offen |
| 5 | **Gemeinsamer Kampf:** Gruppenkampf bei Ye und Probestunden mit der Gruppe. Die Kampfregeln laufen beim Gastgeber (die Trennung aus Runde 2 macht das möglich), jeder steuert seine eigene Figur. **Zeitlimit 25 Sekunden pro Zug** (design.md: 20–30 s, sonst Standardangriff). Parieren wird am eigenen Gerät gemessen, damit die Verbindung das Timing nicht verdirbt. Freie Plätze füllen Ida, Bo und Tom. | offen |
| 6 | **Nacht des Sternenfalls zusammen:** Der Sternenfall ist für alle in der Stadt sichtbar, der Sternenfresser als eigene Instanz für die Gruppe (passt sich der Gruppengröße an, wie in design.md). | offen |
| 7 | **Feinschliff:** Verbindungsabbruch und Wiederkommen, eigene Figur läuft ohne Verzögerung, Test mit 4 Spielern, automatischer Durchlauf zu zweit. | offen |

## Regeln

- Pro Auftrag genau einen Schritt bauen (wie bei der Kreuzweg-Demo).
- Allein spielen muss immer weiter funktionieren (design.md: allein leveln muss möglich sein).
- Jeder Schritt bekommt einen automatischen Test mit zwei echten Programmen (Gastgeber + Mitspieler).
- Nach jedem Schritt: committen, pushen, in `FORTSCHRITT.md` eintragen, was Marco testen kann
  (dazu im Chat eine kurze Test-Liste mit 3 bis 5 Punkten).

## Offene Entscheidungen für Marco

1. **Wo läuft der Server fürs Internet (Schritt 2)?** Vorschlag: ein kleiner gemieteter Server (ein paar Euro im Monat)
   oder ein kostenloses Angebot zum Ausprobieren. Dort läuft dasselbe Spiel ohne Grafik. Dafür braucht es ein Konto bei
   einem Anbieter, das legst du an; ich schreibe die Anleitung und richte den Rest ein.
   Bis dahin geht das Zusammenspielen am PC (mehrere Fenster) und mit der PC-Version im eigenen WLAN.
2. **Geschichte in der Gruppe:** Vorläufig spielt jeder seine eigene Geschichte, man sieht sich nur in der Stadt.
   Soll später die Gruppe Story-Schritte gemeinsam erleben (z. B. alle sehen Ye's Gespräch, Abstimmung bei Antworten)?
   design.md sagt: „große Wendepunkte per Abstimmung“.
3. **Chat:** nur freier Text, oder zusätzlich Schnellsätze und Emotes (praktisch am Handy)?
4. **Spielstand beim Zusammenspielen:** Vorläufig hat jeder Name einen eigenen Spielstand, getrennt vom Allein-Spiel
   (so gehen auch mehrere Fenster auf einem PC). Oder soll man seinen Allein-Spielstand mitnehmen?
