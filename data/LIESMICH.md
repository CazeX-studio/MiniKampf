# Datendateien der Kreuzweg-Demo

Hier stehen alle Texte, Dialoge, Aufträge und Zahlen – nicht im Code. Die Dateien sind im JSON-Format:
Text steht in "Anführungszeichen", Listen in [eckigen Klammern], Gruppen in {geschweiften Klammern}.
Nach jeder Zeile außer der letzten in einer Gruppe kommt ein Komma.

| Datei | Inhalt |
|-------|--------|
| `kreuzweg.json` | NPCs (Name, Platz, Aussehen, welcher Dialog) und Sammelpunkte in der Stadt |
| `dialoge.json` | Gespräche: wer spricht, was, Antwortmöglichkeiten, was danach passiert |
| `auftraege.json` | Aufträge: Titel, Beschreibung, Ziele, Belohnung |
| `gegenstaende.json` | Gegenstände: Name, Beschreibung, Preis |
| `stufen.json` | Erfahrung, die für Stufe 1 bis 10 nötig ist |
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

**Bedingungen (`wenn`):** `{"auftrag": "kennung", "stand": "neu" / "aktiv" / "fertig" / "abgegeben"}`,
`{"gemerkt": "etwas"}`, `{"nicht_gemerkt": "etwas"}`, `{"stufe_ab": 3}`

## Aufträge (`auftraege.json`)

`titel`, `beschreibung`, `ziele` (Liste: `{"art": "sammeln", "gegenstand": "…", "anzahl": 3}` oder
`{"art": "reden", "npc": "…"}`), `belohnung` (`gold`, `erfahrung`, `gegenstaende`).
Stand eines Auftrags: neu → aktiv → fertig (alle Ziele erfüllt) → abgegeben (Belohnung erhalten).
