---
name: grafikauftrag
description: Bildaufträge (Prompts für ChatGPT) für MiniKampf schreiben und speichern, immer mit Referenzbild. Benutzen, sobald ein Bild fehlt, nachgebessert werden soll oder ein Effekt, eine Figur, ein Monster, ein Hintergrund oder ein Symbol gemalt werden muss, auch mitten in einem Bauauftrag.
---

# Grafikauftrag schreiben und speichern

Marcos Regel (11.11.2026): **Jeder Prompt wird gespeichert, immer mit Referenzbild, wenn es eins gibt.** Marco malt die Bilder meist später am PC oder wenn er danach fragt. Darum muss alles fertig im Repo liegen, nichts nur im Chat.

## Ablauf

1. **Prompt schreiben** in `GRAFIK_AUFTRAG.md` (Repo Spieldesign): im passenden Teil oder in einem neuen Teil (nächster freier Buchstabe), im Stil der bisherigen Teile (Teil E bei Effekten, Teil G bei Monstern usw.). Jeder Prompt steht in einem Code-Block, damit Marco ihn wörtlich kopieren kann.
2. **Referenzbild dazulegen:** Für jeden Prompt das passende Vorbild suchen (Figur, Monster, Hintergrund, ein schon gemalter Effekt wie `fx_hieb.png`), meist unter `tools/vorlagen/` oder `assets/`. Eine Kopie nach MiniKampf `tools/referenz/teil_<buchstabe>/` legen (in den Ordner eine leere Datei `.gdignore`, damit Godot die Bilder nicht einliest und sie nicht in die Web-Version kommen) und beim Prompt nennen: „· Anhang: `name.png`“. Nur wenn es wirklich kein Vorbild gibt, beim Prompt „Anhang: keiner“ schreiben.
3. **Übersicht pflegen:** Oben in `GRAFIK_AUFTRAG.md` die Stand-Zeile und die Tabelle „Gesamtstand“ ergänzen, am Ende des Teils eine Liste zum Abhaken (Blatt, wofür, Stand).
4. **Im Spiel** bis zur Lieferung einen gezeichneten Platzhalter einbauen und im Code vermerken, welcher Teil ihn ersetzt.
5. **Committen und pushen:** Spieldesign (`GRAFIK_AUFTRAG.md`) und MiniKampf (`tools/referenz/teil_<buchstabe>/*.png`, ohne `.import`-Dateien).
6. **Im Chat:** Marco nur kurz sagen, dass neue Bildaufträge in Teil X liegen. Die Prompts und Anhänge schickt Claude erst, wenn Marco danach fragt (dann alle Prompts zum Kopieren und die Referenzbilder als Dateien).

## Bilder selbst bei ChatGPT machen (Marco, 13.11.2026)

Sagt Marco, dass Claude seinen Browser nutzen darf, schickt Claude die Aufträge selbst ab (Claude in Chrome, chatgpt.com, Projekt „AsterFall Design“). Marco ist dort angemeldet, das Projekt ist mit Katie geteilt.

1. **Erst eine Probe.** Bei einer neuen Art von Blatt ein einziges Blatt machen und Marco zeigen. Die übrigen erst nach seinem Ja.
2. **Ein Chat je Figur oder Familie**, im Projekt öffnen (Stift neben dem Projektnamen). Anhänge über das Datei-Feld „Dateien anhängen“ hochladen, den Prompt einfügen (nicht tippen, die Eingabetaste schickt sonst zu früh ab), dann senden. Ein Bild dauert ein bis zwei Minuten.
3. **Prüfen, bevor Marco es sieht:** Bild groß öffnen und zählen. Reihen und Felder wie verlangt, kein Feld leer oder doppelt, Figur überall gleich groß und gleich angezogen, Füße auf einer Höhe, nichts abgeschnitten, Hintergrund einfarbig, Blickrichtungen richtig, Kopf-Oval reines Grün.
4. **Nachbessern:** höchstens zweimal im selben Chat, mit genau dem Fehler („Reihe 2, Bild 5: …“). Wird es nicht besser, neuer Chat mit geschärftem Prompt. Was geholfen hat, in den Prompt in `GRAFIK_AUFTRAG.md` übernehmen.
5. **Herunterladen und Einbauen** erst nach Marcos Ja. Bis dahin eine Vorschau (Bildschirmfoto) nach `tools/referenz/teil_<buchstabe>/` legen und in der Liste zum Abhaken vermerken, in welchem Chat das Bild liegt.
6. **Projekt-Anweisung** (Teil A, steht wörtlich auch in `LOOK.md` Abschnitt 9) nie selbst ändern. Vorschläge in `GRAFIK_AUFTRAG.md` schreiben, Marco entscheidet, dann an allen drei Stellen gleich eintragen.

## So wird ein Prompt gut

- **Jeder Anhang bekommt eine Rolle:** „1. `<blatt>` = die FIGUR (Aussehen und Malstil exakt übernehmen). 2. `<vorlage>` = die AUFTEILUNG und die POSEN.“ Ohne Rolle mischt ChatGPT die Bilder.
- **Blätter mit Bewegung bekommen eine Posen-Vorlage:** selbst gerechnete Gliederpuppen an den Plätzen und in den Posen, die gemalt werden sollen (`tools/posen_vorlage.py`, 1536 × 1024; je Geschlecht drei Blätter: Gehen 1, Gehen 2, Stehen und Sitzen; fünf Richtungen wie in Ragnarok). Rot ist die rechte Körperseite, Blau die linke. Im Prompt steht, dass die Puppen nicht ins Bild kommen und dass jeder Fuß dort steht, wo der Fuß der Puppe steht.
- **Text und Vorlage müssen dasselbe sagen.** Bei der ersten Probe (13.11.) stand im Text „Bild 1: rechtes Bein vorne“, die Vorlage zeigte in Bild 1 aber geschlossene Beine. ChatGPT hat gemischt, die Beine standen falsch. Vor dem Abschicken die Vorlage ansehen und Bild für Bild mit dem Text vergleichen.
- **Höchstens 24 Figuren je Blatt**, lieber weniger und dafür größer. Weibliche Figuren bekommen die w-Vorlage und den Zusatz aus Teil U5 (schmale Schultern, Taille, Hüfte, anmutige Haltung).
- **Format festlegen:** Querformat 3:2, Zahl der Reihen und Felder, Hintergrund reines Pink (#FF00FF).
- **Reihen Bild für Bild beschreiben**, bei Schleifen die Schlüsselbilder nennen (welches Bein setzt auf, welches schwingt durch).
- **Sagen, was es nicht sein soll** („ruhiges Gehen, kein Rennen“).
- **Prüfliste am Ende:** Anzahl der Figuren, nichts abgeschnitten, kein Feld leer.
- Ragnarok und andere Spiele nur als Vorbild für Richtungen und Posen nennen. Ihre Bilder nie anhängen und nie abmalen lassen.

## Wenn Bilder kommen

Bilder aus dem Chat unter `tools/vorlagen/` mit sprechendem Namen ablegen, zuschneiden (z. B. `tools/effekt_bilder.py`, `tools/faehigkeit_bilder.py`), einbauen, mit `tools/web_bilder.py` aufs Web-Format stellen und in der Liste zum Abhaken auf „eingebaut“ setzen.
