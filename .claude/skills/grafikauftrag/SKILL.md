---
name: grafikauftrag
description: Bildaufträge (Prompts für ChatGPT) für MiniKampf schreiben und speichern, immer mit Referenzbild. Benutzen, sobald ein Bild fehlt, nachgebessert werden soll oder ein Effekt, eine Figur, ein Monster, ein Hintergrund oder ein Symbol gemalt werden muss, auch mitten in einem Bauauftrag.
---

# Grafikauftrag schreiben und speichern

Marcos Regel (11.11.2026): **Jeder Prompt wird gespeichert, immer mit Referenzbild, wenn es eins gibt.** Marco malt die Bilder meist später am PC oder wenn er danach fragt. Darum muss alles fertig im Repo liegen, nichts nur im Chat.

## Ablauf

1. **Prompt schreiben** in `GRAFIK_AUFTRAG.md` (Repo Spieldesign): im passenden Teil oder in einem neuen Teil (nächster freier Buchstabe), im Stil der bisherigen Teile (Teil E bei Effekten, Teil G bei Monstern usw.). Jeder Prompt steht in einem Code-Block, damit Marco ihn wörtlich kopieren kann.
2. **Referenzbild dazulegen:** Für jeden Prompt das passende Vorbild suchen (Figur, Monster, Hintergrund, ein schon gemalter Effekt wie `fx_hieb.png`), meist unter `tools/vorlagen/` oder `assets/`. Eine Kopie nach MiniKampf `tools/referenz/teil_<buchstabe>/` legen und beim Prompt nennen: „· Anhang: `name.png`“. Nur wenn es wirklich kein Vorbild gibt, beim Prompt „Anhang: keiner“ schreiben.
3. **Übersicht pflegen:** Oben in `GRAFIK_AUFTRAG.md` die Stand-Zeile und die Tabelle „Gesamtstand“ ergänzen, am Ende des Teils eine Liste zum Abhaken (Blatt, wofür, Stand).
4. **Im Spiel** bis zur Lieferung einen gezeichneten Platzhalter einbauen und im Code vermerken, welcher Teil ihn ersetzt.
5. **Committen und pushen:** Spieldesign (`GRAFIK_AUFTRAG.md`) und MiniKampf (`tools/referenz/teil_<buchstabe>/*.png`, ohne `.import`-Dateien).
6. **Im Chat:** Marco nur kurz sagen, dass neue Bildaufträge in Teil X liegen. Die Prompts und Anhänge schickt Claude erst, wenn Marco danach fragt (dann alle Prompts zum Kopieren und die Referenzbilder als Dateien).

## Wenn Bilder kommen

Bilder aus dem Chat unter `tools/vorlagen/` mit sprechendem Namen ablegen, zuschneiden (z. B. `tools/effekt_bilder.py`, `tools/faehigkeit_bilder.py`), einbauen, mit `tools/web_bilder.py` aufs Web-Format stellen und in der Liste zum Abhaken auf „eingebaut“ setzen.
