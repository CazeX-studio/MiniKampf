# Fahrplan Grünwacht (Lernprojekt 5)

Ziel aus `design.md` (Repo CazeX-studio/Spieldesign): **die erste Region komplett** – Professor Esche, Kobalt,
Bogenschütze und Zähmer, Kreuzweg-Karten mit Sternentafel. Grundlage sind die Kreuzweg-Demo (Lernprojekt 3) und
„Zusammen spielen“ (Lernprojekt 4). Was wir dabei lernen: eine zweite Karte, eine echte Klasse in der Welt,
einen Dungeon in der Welt und ein Mini-Spiel.

## Worum es geht (einfach erklärt)

- Nach der Klassenwahl in Kreuzweg ist die Demo bisher zu Ende. Jetzt geht es **weiter**: Man reist nach Grünwacht,
  ins Dorf **Wipfelheim** in den Baumkronen, mit Hängebrücken oben und dichtem Wald unten.
- Ab hier spielt man **mit seiner gewählten Klasse** statt als Novize. Bogenschützen lernen bei **Pfadmeister Fenn**,
  Zähmer starten bei **Professor Esche** (wie bei Pokémon) und treffen ihren Rivalen **Kobalt**.
- Die Geschichte der Region (Ysolde, Kael, Rowans leeres Grab) führt zur **Pilzhöhle unter dem Urbaum**. Die gibt es
  schon in der Kampf-Sandbox; jetzt wird sie ein echter Dungeon in der Welt mit Entscheidung am Ende.
- Endlich gibt es **Kreuzweg-Karten**: die Sternentafel kaufen, Monsterkarten sammeln, einmal mit Marv spielen.
- Alles geht **allein und zusammen** (bis zu 4 Spieler, Geschichte gemeinsam mit Abstimmung, wie in Lernprojekt 4).
- Texte der Hauptfiguren bleiben Platzhalter, Marco schreibt sie (Leitfaden „Sprache der Figuren“: in Grünwacht
  wenige Worte, Natur-Vergleiche, lange Pausen).

| Nr. | Schritt | Stand |
|-----|---------|-------|
| 0 | Plan schreiben (diese Datei) | erledigt |
| 1 | **Die Reise und Wipfelheim:** Nach „Leb wohl, Ye.“ geht es mit demselben Spielstand weiter nach Grünwacht. Neuer Baustein **mehrere Karten**: Wipfelheim (Baumkronen mit Hängebrücken) und der Waldboden darunter als eigene Karten, verbunden über Leitern bzw. einen Seilaufzug. Karten stehen wie Kreuzweg in Datendateien. Der Spielstand merkt sich, auf welcher Karte man ist. Figuren an ihrem Platz: Ysolde, Fenn, Tilda, Esche, Marv (an einer Hängebrücke). Erst nur ankommen, umsehen, reden. Zusammen spielen: Der Server kennt mehrere Karten, man sieht nur die Mitspieler auf derselben Karte, die Gruppe bleibt über Kartenwechsel bestehen. | offen |
| 2 | **Die eigene Klasse in der Welt:** Die gewählte Klasse wird zur eigenen Figur (Fähigkeiten aus der Kampf-Sandbox). Stufen über 10 hinaus (Vorschlag: Grünwacht deckt Stufe 10–20 ab). Monster der Region laufen sichtbar auf dem Waldboden herum (Rindenbär, Windfalke, Donnerhirsch, Steinkröte, Sporenling, selten Bachotter, Moosling, Glutwelpe); Berühren startet den Kampf. Neuer Kampfhintergrund „Wald“. Ida, Bo und Tom (bzw. Tessa und Gorm) füllen allein die Gruppe weiter auf. | offen |
| 3 | **Einstieg Bogenschütze – Fenns Prüfung der drei Ziele:** stehende Ziele (Abstand, hintere Reihe), bewegte Ziele (aufgeladener Schuss), dann den Silberhirsch aufspüren. Wer nicht schießt, besteht; wer schießt, besteht auch, aber Fenn ist enttäuscht (wird gemerkt). „Ein Jäger weiß, wann er nicht schießt.“ | offen |
| 4 | **Einstieg Zähmer – Professor Esche und Kobalt:** Auswahl aus Moosling, Glutwelpe und Bachotter, dazu die Schleuder. Kobalt nimmt das Gegenstück und fordert sofort heraus (Sieg = Erfolg, Niederlage ist kein Spielende). Danach bringt Rudelmeisterin Tilda die Klasse bei: Befehl, Wechsel, Zähmen draußen in der Welt. | offen |
| 5 | **Geschichte Teil 1 und 2:** Splitter im Wald verändern Tiere. Ysolde will sie jagen lassen, Tilda und Esche wollen sie retten → **persönliche Entscheidung Jäger oder Zähmer**. Neuer Baustein **Ruf** (bei Ysoldes Jägern und bei den Zähmern). Kael taucht auf und will Ysolde zu einem Geständnis zwingen. | offen |
| 6 | **Geschichte Teil 3 – Rowans leeres Grab:** Ein Splitter zeigt eine Erinnerung: Ysolde schießt am sechsten Weg auf Fliehende, Rowan dreht sich zu ihr um. Neuer Baustein **Erinnerungs-Szene** (Bild wird blass, Figuren aus der Vergangenheit, kein Kampf). | offen |
| 7 | **Dungeon Pilzhöhle unter dem Urbaum:** Eingang in den Wurzeln. Die Pilzhöhle aus der Sandbox wird ein echter Dungeon in kurzen Abschnitten: Dungeon-Monster unterwegs (Leuchtmotten, Wurzelkriecher, Sporenwölfe, Glimmerkäfer), Zwischenboss Sporenkönigin, Endboss Wurzelmutter und Vorbote. Am Ende die **Entscheidung** Baum fällen oder retten (nur beim ersten Abschluss über den Auftrag, ohne Spoiler). Splitter als Belohnung. Eigene Instanz für die Gruppe, Abstimmung wie in Lernprojekt 4. | offen |
| 8 | **Ende der Region:** Konfrontation mit Ysolde und Kael, Gruppen-Abstimmung: Wahrheit für Wipfelheim oder Geheimnis bewahren. Ysolde: „Rowan … er könnte noch leben.“ Wipfelheim verändert sich je nach Entscheidungen (Baum gerettet = Wald blüht auf). Abspann „Ende Grünwacht“. | offen |
| 9 | **Kreuzweg-Karten:** die Sternentafel kaufen (jetzt ist genug Gold da), das Mini-Spiel (3×3-Feld, je 5 Karten, vier Zahlen pro Karte, höhere Seite dreht um), Monsterkarten als Beute von Monstern, Sammel-Album. **Marv** spielt genau einmal (Erfolg „Marv hatte Zeit“), danach hängt er mit einer Ausrede an der Hängebrücke („Sorry, ich muss gerade Eichhörnchen zählen.“). **Oma Hagebutte** als erste richtige Gegnerin. | offen |
| 10 | **Nebenaufträge (blaues Zeichen):** zweiter Rivalenkampf gegen Kobalt (nur Zähmer), Oma Hagebutte (aus Schritt 9), der verrückte Bienenstock (Hinweis auf die spätere Bienenhüterin). | offen |
| 11 | **Feinschliff:** Grünwacht am Stück testen (allein und zu zweit), Platzhalter-Musik Grünwacht (Holzflöte, Harfe, Vogelrufe, Tag und Nacht), automatischer Durchlauf von der Ankunft in Wipfelheim bis zum Abspann, Stufen und Kämpfe abstimmen. | offen |

## Regeln

- Pro Auftrag genau einen Schritt bauen (wie bei den bisherigen Plänen).
- **Allein und zusammen:** Jeder Schritt funktioniert allein und in der Gruppe. Geschichte, Kämpfe und der Dungeon
  laufen über den Gastgeber bzw. Server, die Regeln von Lernprojekt 4 gelten weiter (Abstimmung, 8 Felder Nähe,
  wer abgestimmt hat, kämpft mit).
- Kreuzweg und die Kampf-Sandbox müssen weiter funktionieren. Alte Spielstände aus der Kreuzweg-Demo laufen weiter.
- Karten, Figuren, Dialoge, Aufträge, Monster und Karten-Werte stehen in Datendateien, nicht im Code.
- Für Dialoge der Hauptfiguren Platzhalter-Texte einsetzen und in `FORTSCHRITT.md` vermerken, dass Marco sie noch schreibt.
- Selbst gewählte Zahlen (Leben der Monster, Stufen, Kartenwerte, Preise) sind **vorläufig, Feinschliff am Ende**
  und kommen in `FORTSCHRITT.md` unter „Vorläufige Werte“.
- Jeder Schritt bekommt einen automatischen Test (bei Gruppen-Teilen mit zwei echten Programmen).
- Nach jedem Schritt: committen, pushen, in `FORTSCHRITT.md` eintragen, was Marco testen kann
  (dazu im Chat den Link und eine kurze Test-Liste mit 3 bis 5 Punkten).

## Offene Fragen an Marco (bitte vor Schritt 1 entscheiden)

Bei jeder Frage steht mein Vorschlag. Antwort reicht kurz, z. B. „1 ja, 2 ja, 3 B …“.

1. **Andere Klassen in Grünwacht:** In Grünwacht lernen nur Bogenschütze und Zähmer. Was ist mit den anderen
   neun Klassen?
   - A (Vorschlag): **Alle dürfen nach Grünwacht** (design.md: „die anderen Regionen in beliebiger Reihenfolge“).
     Den Klassen-Einstieg gibt es nur für die zwei, die anderen spielen ihre Klasse gleich wie in der Probestunde,
     ihr eigener Einstieg kommt später in ihrer Region.
   - B: Weiter nach Grünwacht geht es nur als Bogenschütze oder Zähmer, die anderen sehen „Deine Region kommt später“.
2. **Übergang aus der Demo:** Nach „Leb wohl, Ye.“ mit **demselben Spielstand** weiter nach Grünwacht (Vorschlag),
   der bisherige Abspann wird zu „Ende von Akt 1“. Oder Grünwacht als eigener Menüpunkt mit fertigem Charakter?
3. **Stufen:** Grünwacht deckt **Stufe 10–20** ab (Vorschlag). Die Klassenstufe (Fähigkeitspunkte wie in Ragnarok)
   kommt erst später (Lernprojekt 6), hier werden Fähigkeiten einfach mit der Stufe freigeschaltet. Einverstanden?
4. **Wo gibt es die Sternentafel?** Vorschlag: **Bingos Wanderkarren** in Wipfelheim („Kundschaft! Ich wusste, dass
   ihr kommt.“). Oder man muss dafür zurück nach Kreuzweg (dann braucht es den Rückweg schon jetzt).
5. **Beruf Kochen** (Grünwacht-Beruf laut design.md): Vorschlag, ihn **nicht** in diesem Lernprojekt zu bauen,
   sondern später mit allen Berufen. Oder soll ein einfaches Kochen (Kräuter + Wild = Bufffood) mit rein?
6. **Ruf:** Soll man den Ruf (Jäger und Zähmer) als Zahl sehen, z. B. im Auftragsbuch, oder nur an den Reaktionen
   der Figuren merken (Vorschlag: sichtbar als kleine Leiste, damit man die Entscheidung spürt)?
