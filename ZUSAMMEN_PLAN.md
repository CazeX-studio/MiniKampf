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
| 1 | **Zusammen in Kreuzweg laufen:** Bildschirm „Zusammen spielen“ (Name, Figur, Adresse), Gastgeber werden (PC) oder beitreten. Alle sehen sich mit Namen in der Stadt laufen. Derselbe Spielstand wie allein (Entscheidung 20.10.). Kämpfe noch allein. Server ohne Grafik für später. | eingebaut – Marco testet |
| 2 | **Über das Internet:** Server ohne Grafik bei einem **kostenlosen Anbieter** (Entscheidung 20.10.), sichere Verbindung (nötig für Browser und Handy), Adresse fest in der Web-Version, damit Freunde einfach auf „Beitreten“ tippen. Marco legt das Konto an (Anleitung: `SERVER_ANLEITUNG.md`). | vorbereitet – Marco legt das Render-Konto an |
| 3 | **Chat:** freier Text (Schnellsätze und Emotes sind hinten angestellt, Vorschläge in design.md im Ideen-Parkplatz), Chatfenster (Enter am PC, Knopf am Handy) und Sprechblase über dem Kopf. Erst ein Kanal für alle in Kreuzweg, später Gruppe und Flüstern (design.md: Welt, Gruppe, Gilde, Flüstern). | eingebaut – Marco testet |
| 4 | **Gruppe bilden:** Mitspieler antippen → „In Gruppe einladen“. Gruppenfenster mit Namen, Stufe und Leben. Bis zu 4 Spieler, einer ist Gruppenführer. | eingebaut – Marco testet |
| 5 | **Geschichte gemeinsam erleben** (Entscheidung 20.10.): Spricht jemand aus der Gruppe eine Figur an, sehen alle Mitglieder in der Nähe (8 Felder, Entscheidung 20.10.) das Gespräch. Bei Antworten **stimmen alle ab**, bei Gleichstand entscheidet der **Gruppenführer**. Wer die Szene schon erlebt hat, sieht sie mit, stimmt aber nicht mit ab (er hat seine Entscheidung schon getroffen, sie bleibt für ihn bestehen). Der Fortschritt zählt für alle, die die Szene noch nicht hatten. Allein bleibt alles wie bisher. | eingebaut – Marco testet |
| 6 | **Gemeinsamer Kampf:** Beginnt in einer gemeinsamen Szene ein Kampf, kämpfen alle zusammen, die abgestimmt haben (Entscheidung 20.10.). Die Kampfregeln laufen beim Gastgeber (die Trennung aus Runde 2 macht das möglich), jeder steuert seine eigene Figur. **Zeitlimit 25 Sekunden pro Zug** (design.md: 20–30 s, sonst Standardangriff). Parieren wird am eigenen Gerät gemessen, damit die Verbindung das Timing nicht verdirbt. Freie Plätze füllen die Novizen-NPCs. | eingebaut – Marco testet |
| 7 | **Nacht des Sternenfalls zusammen:** Der Sternenfall ist für alle in der Stadt sichtbar, der Sternenfresser als eigene Instanz für die Gruppe (passt sich der Gruppengröße an, wie in design.md). | eingebaut – Marco testet |
| 8 | **Feinschliff:** Verbindungsabbruch und Wiederkommen, eigene Figur läuft ohne Verzögerung, Test mit 4 Spielern, automatischer Durchlauf zu zweit. | offen |

## Regeln

- Pro Auftrag genau einen Schritt bauen (wie bei der Kreuzweg-Demo).
- Allein spielen muss immer weiter funktionieren (design.md: allein leveln muss möglich sein).
- Jeder Schritt bekommt einen automatischen Test mit zwei echten Programmen (Gastgeber + Mitspieler).
- Nach jedem Schritt: committen, pushen, in `FORTSCHRITT.md` eintragen, was Marco testen kann
  (dazu im Chat eine kurze Test-Liste mit 3 bis 5 Punkten).

## Entscheidungen von Marco (20.10.2026, auch in design.md unter „MMO-Teil“)

1. **Server:** zum Ausprobieren erst ein kostenloses Angebot, später bei Bedarf ein gemieteter Server.
2. **Geschichte in der Gruppe:** gemeinsam erleben, bei Antworten stimmen alle ab (Schritt 5).
3. **Chat:** freier Text und dazu Schnellsätze und Emotes (Schritt 3). Schnellsätze und Emotes sind hinten angestellt (Entscheidung 20.10.).
4. **Spielstand:** ein Charakter für alles – beim Zusammenspielen derselbe Spielstand wie allein.
   Damit man am PC trotzdem mit zwei Fenstern testen kann, bekommt ein **zweites Fenster auf demselben Gerät**
   automatisch einen eigenen Spielstand.
5. **Gleichstand bei Abstimmungen:** Der Gruppenführer entscheidet.
6. **Wer in der Geschichte schon weiter ist:** spielt die Szene mit, kann aber nicht mehr mit abstimmen, weil er die
   Entscheidung schon getroffen hat. Seine eigene Wahl bleibt für ihn bestehen.
7. **Gemeinsame Szene nur in der Nähe:** Mitglieder müssen in der Nähe stehen (etwa 8 Felder).
8. **Wer gemeinsam kämpft:** Beginnt in einer gemeinsamen Szene ein Kampf, kämpfen alle zusammen, die mit abgestimmt haben.
