# Datendateien der Kreuzweg-Demo

Hier stehen alle Texte, Dialoge, Aufträge und Zahlen – nicht im Code. Die Dateien sind im JSON-Format:
Text steht in "Anführungszeichen", Listen in [eckigen Klammern], Gruppen in {geschweiften Klammern}.
Nach jeder Zeile außer der letzten in einer Gruppe kommt ein Komma.

| Datei | Inhalt |
|-------|--------|
| `kreuzweg.json` | NPCs (Name, Platz, Aussehen, welcher Dialog) und Sammelpunkte in der Stadt |
| `karten.json` | Alle Karten außer Kreuzweg (Weg nach Grünwacht, Waldboden, Wipfelheim) als Bild aus Zeichen, mit Häusern, NPCs, Orten und Ausgängen |
| `dialoge.json` | Gespräche: wer spricht, was, Antwortmöglichkeiten, was danach passiert |
| `auftraege.json` | Aufträge: Titel, Beschreibung, Ziele, Belohnung |
| `gegenstaende.json` | Gegenstände: Name, Beschreibung, Preis |
| `stufen.json` | Erfahrung, die für Stufe 1 bis 10 nötig ist |
| `kaempfe.json` | Kämpfe aus der Stadt (Lektionen, Gruppenkampf): Gegner, erlaubte Fähigkeiten, Erklärungen, Erfahrung |
| `laeden.json` | Läden: welche Waren, wie viel der Händler beim Ankauf zahlt |
| `erfolge.json` | Erfolge (einmalige Auszeichnungen) |
| `klassen.json` | Klassenwahl: Lehrmeister, Werte fürs Diagramm (vorläufig), Ult-Vorschau, Ortsangaben der Regionen |
| `texte.json` | Kurze Meldungen im Spiel („Neuer Auftrag“, „Stufe erreicht“ …) |

## Dialoge (`dialoge.json`)

Jeder Dialog hat einen **Einstieg** (welcher Knoten zuerst kommt, je nach Bedingung – der erste passende gilt)
und **Knoten**. Ein Knoten hat:

- `wer` und `text`: wer spricht und was
- `weiter`: der nächste Knoten (fehlt er, endet das Gespräch)
- `antworten`: Liste von Antworten, jede mit `text`, optional `weiter`, `aktionen` und `wenn`
- `aktionen`: was passiert, wenn der Knoten gezeigt bzw. die Antwort gewählt wird

**Aktionen:** `{"auftrag_starten": "kennung"}`, `{"auftrag_abgeben": "kennung"}`, `{"gold": 10}`,
`{"erfahrung": 50}`, `{"gegenstand": "heiltrank", "anzahl": 1}`, `{"merken": "etwas"}`

**Bedingungen (`wenn`):** `{"und": [Bedingung, Bedingung]}` (alle müssen stimmen), `{"auftrag": "kennung", "stand": "neu" / "aktiv" / "fertig" / "abgegeben"}`,
`{"gemerkt": "etwas"}`, `{"nicht_gemerkt": "etwas"}`, `{"stufe_ab": 3}`

## Aufträge (`auftraege.json`)

`titel`, `beschreibung`, `ziele` (Liste: `{"art": "sammeln", "gegenstand": "…", "anzahl": 3}` oder
`{"art": "reden", "npc": "…"}`), `belohnung` (`gold`, `erfahrung`, `gegenstaende`).
Stand eines Auftrags: neu → aktiv → fertig (alle Ziele erfüllt) → abgegeben (Belohnung erhalten).

## Weitere Felder (seit Schritt 2)

- **Ziel-Art „gemerkt“:** `{"art": "gemerkt", "merken": "schmiedin_bescheid", "bei": "schmiedin", "text": "Der Schmiedin Bescheid sagen"}`
  ist erfüllt, sobald ein Dialog `{"merken": "schmiedin_bescheid"}` ausgeführt hat. `bei` = über welchem NPC das „?“ erscheint.
- **Aufträge:** `abgeben_bei` (wo man ihn abgibt, dort erscheint „?“, wenn er erfüllt ist), `start_bei` und
  `voraussetzung` (wo ein neuer Auftrag mit „!“ angezeigt wird und welcher Auftrag vorher abgeschlossen sein muss).
- **Bedingungen** dürfen mehrere Teile haben, z. B. `{"auftrag": "erster_auftrag", "stand": "aktiv", "nicht_gemerkt": "schmiedin_bescheid"}` – dann muss alles stimmen.
- **`kreuzweg.json` → `start`:** wo neue Spieler die Stadt betreten und welcher Dialog dabei kommt
  (`nur_wenn_nicht_gemerkt`: nur beim ersten Mal).

## Kämpfe (seit Schritt 3, `kaempfe.json`)

- Jeder Kampf hat `name`, `ansage` (erste Zeile im Kampf-Log), `wellen` (Gegner-Kennungen aus `scripts/kampf/sandbox.gd`),
  `erlaubt` (welche Fähigkeiten der Novize schon hat: `schlag`, `kraftschlag`, `erste_hilfe`, `row` = Reihe wechseln),
  `erfahrung` (gibt es nur beim ersten Sieg), optional `begleiter` (Novizen-Mitstreiter, der Computer steuert sie),
  `reaktion: false` (der Novize kann noch nicht parieren, z. B. Lektion 1 und 2),
  `zuerst` (diese Aktion muss als Erstes kommen, alles andere ist bis dahin gesperrt, z. B. `"row"` in Lektion 4),
  `ziel_paraden` (gewonnen nach so vielen perfekten Paraden) und `hinweise` (Erklär-Fenster:
  `erster_zug` = vor deinem ersten Zug, `erste_reaktion` = vor dem ersten Angriff auf dich).
- **Aktion** `{"kampf": "grundausbildung"}` im Dialog startet den Kampf.
- **Ziel-Art** `{"art": "kampf", "kampf": "grundausbildung", "bei": "ye_tor", "text": "…"}` ist erfüllt, sobald der Kampf gewonnen ist.
- **NPCs** können `"wenn"` haben: Sie sind nur da, wenn die Bedingung stimmt (so steht Ye erst in der Gilde, später am Tor).

## Läden und NPCs, die einen ansprechen (seit Schritt 4)

- **Aktion** `{"laden": "bingo"}` im Dialog öffnet den Laden. Waren und Ankauf-Anteil stehen in `laeden.json`,
  die Preise in `gegenstaende.json` (Preis 0 = kauft der Händler nicht an).
- **NPC-Feld** `"anspringen": {"radius": 3}`: Der NPC spricht dich einmal von selbst an, sobald du so nah bist (Marv).
- Im Kampf: `"trank"` in `erlaubt` = der Novize darf Heiltränke aus seiner Tasche trinken.

## Probestunden (seit Schritt 5)

- Kampf-Kennung `probe:<klasse>` (z. B. `probe:archer`) nutzt die Vorlage `probestunde` in `kaempfe.json`:
  Gegner, Begleiter, Ult zu Beginn (`ult_start`), Erfahrung beim ersten Sieg, `merken` (wird bei jedem Sieg gemerkt)
  und `hinweis_vorlage` (Erklärung; Name, Rolle, Mechanik, Reaktion und Ult kommen aus den Klassendaten).
- Die Gesandten und ihre Klassen stehen als Antworten in `dialoge.json` (`{"kampf": "probe:tank"}`).

## Seit Schritt 7

- **Aktionen:** `{"effekt": "sternenfall"}` (Lichtblitz und Wackeln), `{"erfolg": "schild_hoch"}` (Erfolg freischalten).
- **`kreuzweg.json` → `deko`:** Schmuck, der nur unter einer Bedingung zu sehen ist (`festlaterne`, `krater`).
  Der gemerkte Wert `nacht` färbt die Stadt dunkelblau.
- **Kämpfe:** `hintergrund` (`wiese` = vor dem Stadttor, Standard; `wiese_nacht`; `marktplatz_nacht`; `gewoelbe`), `merken_immer` (wird auch bei Niederlage gemerkt), `erfolg` (bei Sieg), `gruppe_staerke` (Gruppenkampf beim Zusammenspielen: so viel mehr Leben für die Gegner je weiterem Spieler, z. B. 0.25 = +25 %), `kein_nochmal` (kein „Nochmal
  versuchen“), `verloren_text` (Meldung bei Niederlage).
- **Gegner** (in `scripts/kampf/sandbox.gd`): `panzer` (Schaden-Faktor, bis eine perfekte Parade ihn erschüttert),
  `erschuettert` (wie viele Züge offen), `wipe_nach` und `wipe_text` (nach so vielen Zügen verliert die Gruppe).

## Seit Schritt 8

- **Aktionen:** `{"szene": "klassenwahl"}` / `{"szene": "abspann"}` (wechselt den Bildschirm),
  `{"vergessen": "nacht"}` (etwas Gemerktes wieder vergessen, z. B. damit es Morgen wird).
- **Platzhalter in Dialogtexten:** `{klasse}`, `{region}`, `{wohin}` („ins Arkanum“), `{lehrmeister}` – aus der gewählten Klasse.

## Seit Schritt 21 (Nebenaufträge, Sitzung 21)

- **Nebenauftrag:** `"neben": true` im Auftrag. Dann sind „!“ und „?“ über der Figur **blau** statt gelb, im Auftragsbuch
  steht „◆ Nebenauftrag:“ davor. Hauptaufträge gehen bei den Zeichen und beim „Ziel:“ oben links immer vor.
- **Ziel mit Bedingung:** Ein Ziel darf `"wenn"` haben – dann erscheint sein „?“ über der Figur erst, wenn die Bedingung
  stimmt (z. B. Ye erst, wenn alle fünf Laternen hängen).
- **Bedingung „oder“:** `{"oder": [Bedingung, Bedingung]}` – eine reicht (z. B. Festlaterne nachts oder wenn aufgehängt).
- **`kreuzweg.json` → `orte`:** Stellen, die man benutzen kann (hinlaufen bzw. antippen, E / Leertaste / „Reden“):
  `art` (Aussehen: `kater`, `laternenhaken`), `feld`, `wenn` (nur dann da), und was passiert: `dialog`, `aktionen`
  und/oder `meldung` (kurzer Text oben).
- **Sammelpunkte** dürfen `"wenn"` haben (z. B. Wiesenkraut nur, solange „Ein Festmahl“ läuft).
- **Gegenstände benutzen:** in `gegenstaende.json` `"benutzen": {"feld": [x, y], "radius": 3, "dialog": "…", "sonst": "…"}`.
  In der Tasche steht dann „[Benutzen]“. Nah genug an `feld` startet der Dialog, sonst kommt die Meldung `sonst`.

## Karten (seit Grünwacht Schritt 1, `karten.json`)

- Jede Karte hat `name` (erscheint beim Betreten), `grund` (Boden, wo ein Zeichen keinen eigenen nennt), `start`
  (wo man ankommt, wenn nichts anderes gilt), optional `licht` (Farbe, z. B. etwas dunkler im Wald) und `raster`.
- **`raster`** ist die Karte als Bild: eine Zeile pro Reihe, ein Zeichen pro Feld. Links oben ist Feld [0, 0],
  x zählt nach rechts, y nach unten (im Spiel liegt x schräg nach rechts unten, y schräg nach links unten).
  Was die Zeichen bedeuten, steht oben in der Datei unter `zeichen`, z. B. `~` Baumkronen (gesperrt), `#` Plattform,
  `-` Hängebrücke, `,` Waldboden, `=` Weg, `t` Baum, `R` Riesenbaum. Neue Zeichen kann man dort dazuschreiben.
- `haeuser` (`feld`: [x, y, Breite, Höhe]), `staende`, `npcs`, `orte`, `sammelpunkte` und `deko` wie in `kreuzweg.json`.
- **`ausgaenge`:** `{"bereich": [x, y, Breite, Höhe], "karte": "waldboden", "feld": [27, 12], "wenn": {…}}` – wer in den Bereich
  läuft, kommt auf die andere Karte an das Feld. Auch `kreuzweg.json` hat einen (Weststraße, erst nach der Klassenwahl).
- **Aktion `{"reisen": "wipfelheim", "feld": [6, 15]}`** bringt einen auf eine andere Karte (z. B. der Seilaufzug als Ort).
- **Deko `wegweiser`:** `"text": "Grünwacht|Kreuzweg"` = oben ein Schild nach links, darunter eins nach rechts.
- **Ziel `{"art": "gemerkt", "merken": "besucht:wipfelheim"}`** ist erfüllt, sobald man die Karte einmal betreten hat.
- **Bedingungen nach Klasse:** `{"klasse": "archer"}` (genau diese Klasse), `{"region": "Grünwacht"}` (Klasse gehört in
  diese Region), `{"nicht_region": "Grünwacht"}` (gehört nicht dorthin). Kennungen der Klassen: siehe `klassen.json` → `reihenfolge`.
- **`monster`** (seit Grünwacht Schritt 2): Monster in der Wildnis, z. B.
  `{"feld": [33, 8], "gegner": ["windfalke", "windfalke"], "stufe": 11}`. Man sieht das erste Monster der Gruppe
  mit Name und Stufe auf der Karte; läuft man hinein oder tippt es an, beginnt der Kampf (mit der eigenen Klasse,
  Gruppenmitglieder in der Nähe kämpfen mit). Jeder Sieg bringt Erfahrung (12 × Stufe je Monster) und Gold (2 × Stufe),
  danach ist das Monster für einen eine Minute weg. Gegner-Kennungen stehen in `scripts/kampf/sandbox.gd` (ENEMIES).
  `kampf_hintergrund` der Karte: Bild im Kampf (`wald`, `wiese`, `gewoelbe` …).
- **Stufen** (`stufen.json`): jetzt bis Stufe 20 (Kreuzweg 1–10, Weg nach Grünwacht 10–15, Grünwacht 15–20).
