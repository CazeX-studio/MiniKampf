# Bauaufträge

Kleine Bauaufträge für Claude Code, übertragen aus dem Abschnitt „Bauaufträge-Entwurf (Stand 21.10.2026)“
im Brainstorm-Doc „CazeX MMO – Brainstorming“. Die Beschlüsse in design.md (Repo Spieldesign) gelten.
Sagt Marco „Mach den nächsten Bauauftrag“: kurz FORTSCHRITT.md prüfen, den nächsten offenen Schritt von oben nehmen, bauen, committen, Status auf „fertig“ setzen und in FORTSCHRITT.md eintragen.

Status: offen / in Arbeit / fertig

## Demo-Reihenfolge (Stand 01.11.2026)

**Marcos Beschluss (02.11.2026): Alle Testtage stehen am Ende.** Nirgends wegen eines Testtags anhalten, D10 bis D36 der Reihe nach bauen. Marco testet am Schluss das volle Spiel zusammen (T1 bis T4). Die Testpunkte gesammelt in FORTSCHRITT.md eintragen.

Sagt Marco „Mach weiter“, „Mach den nächsten Bauauftrag“ oder „Mach D12“: **Diese Liste gilt zuerst.** Den obersten offenen Punkt nehmen, die Einzelheiten stehen beim genannten Projekt oder im Brainstorm-Doc unter „Fahrplan zur Demo“. T-Punkte sind Testtage: Dort hält Claude an, nennt Marco, was zu testen ist, und baut erst nach seiner Rückmeldung weiter. Braucht ein Punkt Bilder, die noch nicht da sind, wird er mit Platzhalter gebaut oder übersprungen, der fertige Prompt kommt in `Spieldesign/GRAFIK_AUFTRAG.md` (im Chat nur, wenn Marco nach Prompts fragt).

### Vorbereitung

- **D1:** Bildaufträge für alles, was noch fehlt, in GRAFIK_AUFTRAG.md schreiben: acht NPC-Grundkörper, Körper der fünf Demo-Klassen nach dem neuen Stil, Kurzschwert, Probe-Hut und Probe-Umhang. (neu) – Status: fertig (01.11.2026, 113 Blätter in GRAFIK_AUFTRAG.md Teil D, dazu Haupt- und Nebenfiguren)

### Aussehen

- **D2a:** Regeln festschreiben, Bilder prüfen. (Fahrplan A.1, Projekt 13 Schritt 1–2) – Status: fertig (02.11.2026, LOOK.md Abschnitt 9a und 12; der Zusatz zum Stil-Block ist seit 02.11. von Marco bestätigt)
- **D2b:** Kurzschwert als eigenes Teil (braucht Marcos Novizen-Blätter ohne Klinge). (Fahrplan A.1, Projekt 13 Schritt 3) – Status: fertig (02.11.2026)
- **D3a:** Hut und Rückenteil als Schicht, mit Platzhaltern bis Marcos Probe-Hut und Probe-Umhang da sind. (Fahrplan A.2, Projekt 13 Schritt 4) – Status: fertig (02.11.2026)
- **D3b:** Umfärben, Probe an Hut und Umhang. (Fahrplan A.2, Projekt 13 Schritt 5) – Status: fertig (02.11.2026)
- **D3c:** Aussehen-Plätze: Fenster zum Auswählen, im Spielstand gespeichert. (Fahrplan A.2, Projekt 13 Schritt 6) – Status: fertig (02.11.2026; Waffen-Aussehen kam mit D2b)

### Kampfgefühl

- **D4:** Werte für Waffen und Rüstung. (K.1) – Status: fertig (02.11.2026: sechs Plätze, Grundausrüstung, Waffenkraft, Verteidigung und Widerstand, Waffen-Tempo, Bonus-Werte nach Seltenheit, Vergleich mit Pfeilen; Probe-Teile bei Bingo. Noch nicht drin: Waffen nur für ihre Klasse, Sonderwerte ab Selten, zufällige Bonus-Werte bei Beute)
- **D5a:** Mana nur durch Handeln, Abklingzeiten nur für die stärksten Fähigkeiten, Manatrank. (K.2) – Status: fertig (02.11.2026)
- **D5b:** Hinsetzen außerhalb des Kampfes, am Lagerfeuer schneller (Mana bleibt zwischen Kämpfen). (K.2) – Status: fertig (02.11.2026; Sitzen vorerst als gestauchte Figur, eigene Sitz-Bilder fehlen)
- **D6a:** Fähigkeiten-Baum: Klassenstufe und Punkte, Lernen-Fenster (K), Neuverteilen beim Lehrmeister, Baum des Bogenschützen als erster. (K.3) – Status: fertig (02.11.2026)
- **D6b:** Feste Leiste mit 6 Plätzen, vor dem Kampf bestückt; Angriff, Abwarten, Gürtel und Ult immer dabei. (K.3) – Status: fertig (02.11.2026; die 6 Plätze kommen zu Angriff, Abwarten, Gürtel und Ult dazu, von Marco bestätigt)
- **D7:** Effekt-Liste als feste Bausteine. (K.4) – Status: fertig (02.11.2026: neun Bausteine in `scripts/kampf/effekte.gd`, Effekt-Probe in der Kampf-Sandbox; Klassen und Monster nutzen sie mit D8 und D22)
- **D8a:** Novize: Hieb, Schildstoß, Doppelschlag, Erste Hilfe, Deckung geben, kleine Ult Sternenmut in der Festnacht. (K.5) – Status: fertig (02.11.2026)
- **D8b:** Ye's Lektionen auf Stufe 2, 4, 6 und 8 verteilen (je Lektion eine Fähigkeit), statt alles in der Grundausbildung. (K.5) – Status: fertig (02.11.2026; die drei späteren Lektionen sind Nebenaufträge bei Ye am Tor)
- **D8c:** Baum des Bogenschützen fertig: Adlerauge, Durchschlag, Jagdinstinkt, Schwachstelle markieren, Elementpfeil. (K.5) – Status: fertig (02.11.2026; Schnellfeuer nach Steckbrief auf ein Ziel; besondere Pfeile vorerst bei Bingo)
- **D8d:** Baum des Monster-Zähmers. (K.5) – Status: fertig (02.11.2026; Befehl entfällt laut Steckbrief)
- **D8e:** Baum des Rüstungsschmieds. (K.5) – Status: fertig (02.11.2026; Ult Meisterstück nach Steckbrief, dazu ein Schild)
- **D8f:** Baum der Klingentänzerin. (K.5) – Status: fertig (02.11.2026)
- **D8g:** Baum der Sternensängerin. (K.5) – Status: fertig (02.11.2026; Lieder nach Steckbrief umgebaut, Himmelszelt behält seinen Schaden, Urbaum mit 5 statt 4 Zügen bis zum Verschlingen)
- **D9a:** Filmische Ult, 3 bis 4 Sekunden, in den Einstellungen auf kurz stellbar. (K.6) – Status: fertig (02.11.2026; Ablauf für alle Klassen gleich, je Klasse eigener Hintergrund; die Effekte der Steckbriefe kommen mit D9b bis D9g)
- **D9b:** Eigene Bewegungen und Effekte: Novize. (K.6) – Status: fertig (02.11.2026; alle Bewegungen nach Steckbrief aus den vorhandenen Bildern, Klänge aus den vorhandenen Geräuschen; ein eigenes Knie-Bild und Schild-Bild fehlen noch, Sternenmut hat kein lila Schwert-Bild, die Figur leuchtet)
- **D9c:** Eigene Bewegungen und Effekte: Bogenschütze. (K.6) – Status: fertig (02.11.2026; alle aktiven Fähigkeiten und die Ult; ohne die Zeichen der passiven Fähigkeiten und ohne bleibendes Fadenkreuz, ohne eigene Knie- und Zielbilder)
- **D9d:** Eigene Bewegungen und Effekte: Monster-Zähmer. (K.6) – Status: fertig (02.11.2026; alle aktiven Fähigkeiten und die Ult; ohne Monsterrufe, ohne Kameraschwenk über die drei Monster im Ult-Film, passive Fähigkeiten ohne Zeichen)
- **D9e:** Eigene Bewegungen und Effekte: Rüstungsschmied. (K.6) – Status: fertig (02.11.2026; alle aktiven Fähigkeiten, Funkenflug und die Ult; Amboss vorerst gezeichnet; Risse im Boden, Rüstungsbilder je Art und Glanz je Stufe fehlen noch)
- **D9f:** Eigene Bewegungen und Effekte: Klingentänzerin. (K.6) – Status: fertig (02.11.2026; alle aktiven Fähigkeiten und die Ult; Klingensturm zeigt die Klingen einzeln, die Schadenszahl bleibt eine; Käfig bleibt nicht zwei Runden sichtbar, Trommel-Zeichen und goldene Klingen bei fünf fehlen noch)
- **D9g:** Eigene Bewegungen und Effekte: Sternensängerin. (K.6) – Status: fertig (02.11.2026; Abläufe aller aktiven Fähigkeiten und der Ult; die gezeichneten Effekte sind Platzhalter, siehe D9h; Sternbilder über ihr und bleibende Monde fehlen noch)
- **D9h:** Effekte überarbeiten: Die gezeichneten Effekte gefallen Marco nicht (02.11.). Sie sollen als Bildfolgen von ChatGPT kommen, Claude Code schneidet sie und setzt sie in `scripts/kampf/faehigkeit_fx.gd` ein. Zuerst ein Probe-Effekt, erst nach Marcos Ja die übrigen. LOOK.md sagt bisher „Effekte macht das Spiel“, das wird nach der Probe angepasst. Probe seit 02.11. im Spiel: der Hieb (`assets/fx/hieb_f0-5.png`). (K.6) – Die Bildaufträge stehen in `Spieldesign/GRAFIK_AUFTRAG.md`, Teil E. Status: fertig (06.11.2026; alle 31 Effekt-Blätter geschnitten und eingesetzt, dazu Funken bei jedem Treffer und Heil-Funken bei jeder Heilung; noch gezeichnet: Glühen der Figuren, Ringe, Zeichen über den Köpfen, Lichtblitze)

### Kreuzweg und Grünwacht rund machen

- **D10:** Liste aus dem Playtest 25.10. prüfen, Fehlendes bauen. (1.1) – Status: fertig (02.11.2026; alle Punkte waren schon gebaut, Liste in FORTSCHRITT.md; neu ist eine Prüfung, dass die Gruppe den Silberhirsch angehen kann)
- **D11:** Zähmer lernt bei Tilda, Esche gibt das erste Monster. (1.2, Projekt 12) – Status: fertig (02.11.2026; Neuverteilen der Punkte jetzt bei Tilda; Texte sind Platzhalter)
- **D12:** Gemeinsame Trank-Wartezeit. (1.3, Projekt 5 Schritt 3) – Status: fertig (03.11.2026; dazu haben jetzt alle Klassen ihre Tränke im Kampf, bisher nur der Novize)
- **D13:** Händler, in Grünwacht die Kräuterhändlerin. (1.4, Projekt 6) – Status: fertig (03.11.2026; Salbei mit Stand auf dem Hauptplatz von Wipfelheim, Bingo verkauft auch Grundmaterialien; Bilder der neuen Waren: GRAFIK_AUFTRAG.md B6c)
- **D14:** Tag und Nacht nach der Uhrzeit, nachts andere Monster. (1.5, Projekt 7) – Status: fertig (03.11.2026; Licht nach der Uhr, Testknopf in der Tasche, nachts Heulwolf und Irrlicht auf dem Weg, Nachtuhu und Funkenmarder im Wald; Kämpfe sehen nachts noch aus wie tags)
- **D15:** Kartenalbum, Teil 1: Album, Karten aktivieren, Monster-Infos. (1.6, Projekt 8 Schritt 1–3) – Status: fertig (03.11.2026; Taste L statt K, weil K schon die Fähigkeiten öffnet; Seiten Kreuzweg und Grünwacht, dazu Karten für die vier Nacht-Monster)
- **D16:** Kartenalbum, Teil 2: Besitzeffekte, Deck, doppelte Karten verkaufen. (1.6, Projekt 8 Schritt 4–6) – Status: fertig (03.11.2026; Boni vorläufig je Karte +1 bis +5 Leben, Mana, Angriff oder Tempo; Bingos Laden lässt sich jetzt rollen)
- **D17:** Kartenalbum, Teil 3: Belohnung volle Seite, Marv, Karten bis +10. (1.6, Projekt 8 Schritt 7–9) – Status: fertig (03.11.2026; Sternenreif und Geweih-Band mit Marcos Bildern, B6d; Sternen-Kartenrücken vorerst als goldener Rand der eigenen Karten)
- **D18:** Körper für Bogenschütze und Monster-Zähmer einbauen (braucht Marcos Bilder). (1.8, Projekt 11 Schritt 4) – Status: fertig (03.11.2026; je männlich und weiblich, nach dem Lernen der Klasse in Welt und Kampf, Kopf und Aussehen bleiben; die Waffen fehlen noch, siehe D18b)
- **D18b:** Klassenwaffen als eigenes Teil an der Hand: Langbogen für den Bogenschützen, Schleuder für den Zähmer (Bilder in `tools/vorlagen/klassen_waffen.png` und `klassen_bogen_gespannt.png`). Die Klassen-Körper haben leere Fäuste, darum braucht jedes Bild einen Handpunkt. (geteilt aus D18) – Status: fertig (03.11.2026; Handpunkte mit `tools/klassen_waffen.py`, beim Schuss und bei der Konzentration der gespannte Bogen mit Pfeil; beim Fallen, Siegen, Getroffen-Werden und Ausweichen keine Waffe)
- **D19:** Figuren-Baukasten mit den acht Grundkörpern einbauen (braucht Marcos Bilder). (neu, NPC.md) – Status: fertig (03.11.2026; acht Grundkörper und zwölf Volks-Köpfe, Figur als „grund_<körper>+<kopf>“ z. B. „grund_frau+v_w1“; zu sehen im Baukasten-Testfeld. Noch nicht: Umfärben nach Region; Hüte der Regionen und Zeichen über Diensten kommen mit D20)
- **D20:** Kreuzweg nach Sitzung 30: Hatta, Zeichen über Diensten, Figuren tags und nachts, Ye mit Regenschirm. (1.9) – am 03.11. geteilt:
- **D20a:** Hutmacher Hatta mit Laden neben Bingo (tauscht Monster-Beute gegen Hüte), die acht Hüte der Regionen, Monster-Beute (Material nach MONSTER.md), Zeichen über den Diensten (Münze, Truhe, Hut, Laterne an der neuen Wegelaterne am Brunnen). – Status: fertig (03.11.2026; Hattas Maßband und Porträts seit 10.11. mit eigenen Blättern, Tauschpreise vorläufig)
- **D20b:** Ye mit Regenschirm und seinen neuen Sprüchen (Bilder `haupt_ye_welt.png`, `haupt_ye_portraets.png`). – Status: fertig
- **D20c:** Kreuzweg-Figuren nach Steckbrief: eigene Köpfe und Baukasten-Körper für Lene, Hanne, Ilse, Edmar, Brom, Quill, Pip, Lotte; Bingo, Marv, Mira mit ihren eigenen Bildern; Porträts im Gespräch. – Status: fertig (04.11.2026; geteilt, Rest in D20c2)
- **D20c2:** Tessa und Gorm mit eigenen Köpfen auf den Novizen-Körpern (Welt und Kampf), Zubehör der Nebenfiguren (Hannes Schürze und Kochlöffel, Ilses Schlüsselbund, Edmars Amtskette und Festschärpe, Broms Helm, Quills Meißel, Pips Holzschwert, Lottes Papierkrone), Mira krank liegend. – Status: fertig (04.11.2026; Ilses Ärmelschoner seit 10.11. mit eigenem Welt-Blatt, Edmars Festschärpe seit 10.11. mit eigenem Welt-Blatt, Mira liegt erst im Krankenzelt der Glutoase)
- **D20d:** Figuren tags und nachts an ihren Plätzen (Steckbriefe), Volk aus dem Baukasten (Wachen, Marktleute, Bürger, Gäste im Wegrast), Marktstände nachts zu. – Status: fertig (04.11.2026; Volk steht, läuft noch keine Runden)
- **D21:** Grünwacht-Figuren nach Steckbrief: Salbei, Borko, Ysolde nachts, Oma Hagebutte; dazu Tamm, Kobalt (Köpfe) und Ysolde, Fenn, Tilda, Esche, Kael (eigene Bilder), Porträts, Plätze bei Tag und Nacht. (1.10) – Status: fertig (04.11.2026; geteilt, Volk in D21b; Hagebuttes Strickjacke seit 10.11. als eigenes Welt-Blatt, Kael kämpft noch als Platzhalter)
- **D21b:** Volk in Grünwacht (Jäger, Sammlerinnen, Kinder an den Hängebrücken, Gäste im Gasthaus nachts). – Status: fertig (04.11.2026; Volk steht, läuft noch keine Runden)
- **D22:** Monster nach Regelblatt in Kreuzwegfeldern, Hirschtal, Wachtwald, Tiefwurzel und Pilzhöhle, dazu die Spezialbewegungen der Pilzhöhlen-Bosse. (1.11) – Status: fertig (04.11.2026, in D22a bis D22c)
- **D22a:** Werte-Tabelle nach Rolle und Stufe, Monster-Fähigkeiten mit Effekten (Schutz, Heilen, Herbeirufen, mehrere Treffer, Ziele), Kreuzwegfelder- und Hirschtal-Monster nach Steckbrief, Hirschtal auf dem Weg nach Grünwacht, seltene Monster (immer Karte, kommen später wieder). – Status: fertig (04.11.2026; Kreuzwegfelder-Monster nur in Ye's Lektionen, es gibt noch kein Gebiet „Kreuzwegfelder“ zum Herumlaufen)
- **D22b:** Wachtwald und Tiefwurzel nach Steckbrief (Waldboden, Splitter-Monster), Start-Monster wild und sehr selten, Wipfelluchs und Splitterbär als seltene Monster. – Status: fertig (04.11.2026; Tiefwurzel ist seit dem Nachtrag eine eigene Karte südlich vom Waldboden (Marco, 04.11.), alle Monster dort auf Stufe 20 = Höchststufe der Demo)
- **D22c:** Pilzhöhle nach Steckbrief (Fähigkeiten der Dungeon-Monster, Schatzpilzling als Flüchter) und die Spezialbewegungen der Pilzhöhlen-Bosse. – Status: fertig (04.11.2026; ein weggelaufener Schatzpilzling zählt noch als Sieg)

### Glutoase

- **D23:** Aschensteppe mit Rastplatz, dann Palmenrast. (2.1) – Status: fertig (04.11.2026, in D23a und D23b)
- **D23a:** Aschensteppe (Straße von Kreuzweg nach Süden) mit dem Rastplatz der Karawanen (keine Monster, Wegelaterne), Monster nach Steckbrief. – Status: fertig (04.11.2026; der Rastplatz-Händler kommt mit D27, der Weg nach Süden endet noch an der Karte)
- **D23b:** Palmenrast (Heimat-Gebiet der Glutoase) südlich der Aschensteppe, Monster nach Steckbrief. – Status: fertig (04.11.2026; bis die Stadt steht, führt die Aschensteppe direkt in die Palmenrast)
- **D24:** Stadt Glutoase als Terrassenstadt. (2.2) – Status: fertig (04.11.2026; noch ohne Figuren, die kommen mit D27; Dürrewald-Tor, Bergpfad und Vulkanschmiede sind noch zu)
- **D25:** Körper der drei Glutoase-Klassen einbauen (braucht Marcos Bilder). (2.11, Rest; die Wüsten- und Schmiede-Teile liegen schon bereit) – Status: geteilt (04.11.2026)
- **D25a:** Körper der Klingentänzerin (m und w) aus Marcos Blättern. – Status: fertig (04.11.2026)
- **D25b:** Körper von Rüstungsschmied (m und w) und Sternensängerin (w). – Status: fertig (04.11.2026; Bilder lagen schon unter `tools/vorlagen/`; ein Sternensänger (m) bleibt vorerst in der Klassenfigur)
- **D26:** Klassen lernen in der Glutoase. (2.3) – Status: fertig (04.11.2026; Rüstungsschmied und Sternensängerin kämpfen bis D25b noch in der Platzhalter-Figur)
- **D27:** Glutoase-Figuren nach Steckbrief, Rastplatz-Händler. (2.13, vorgezogen) – Status: fertig (04.11.2026; Zaids Reiseumhang seit 10.11. als eigenes Welt-Blatt, die Aufträge der Figuren kommen mit der Geschichte)
- **D28:** Geschichte Teil 1: Kochende Brunnen, Miras Lied. (2.4) – Status: fertig (04.11.2026)
- **D29:** Geschichte Teil 2: Tanz mit der Pause, Rivalenkampf gegen Kael. (2.5) – Status: fertig (04.11.2026)
- **D30:** Glutgrat über den Bergpfad. (2.6) – Status: fertig (04.11.2026)
- **D31:** Monster nach Regelblatt in Aschensteppe, Palmenrast und Glutgrat. (2.12, vorgezogen) – Status: fertig (04.11.2026; Aschensteppe und Palmenrast mit D23, Glutgrat mit D30)
- **D32:** Vulkanschmiede Teil 1: drei Abschnitte, Lava-Takt, Monster, Kampf-Hintergrund. (2.7) – Status: fertig (04.11.2026)
- **D33:** Vulkanschmiede Teil 2: Hammerbrüder. (2.8) – Status: fertig (04.11.2026)
- **D34:** Vulkanschmiede Teil 3: Kettenschmied. (2.9) – Status: fertig (04.11.2026)
- **D35:** Ende der Glutoase: Entscheidung um Miras Splitter. (2.10) – Status: fertig (04.11.2026)

### Demo abschließen

- **D36:** Bilder für das Web verkleinern, Ladezeit prüfen, von Marco offene Punkte aus FORTSCHRITT.md einsammeln, Demo-Seite vorbereiten. (neu) – Status: fertig (04.11.2026)
- **T1:** Testtag Aussehen (Marco). – Status: offen
- **T2:** Testtag Kampfgefühl (Marco). – Status: offen
- **T3:** Testtag 1 (Marco): Kreuzweg und Grünwacht komplett, allein und in der Gruppe, dazu der Sternenfresser. – Status: offen
- **T4:** Testtag 2 (Marco): die ganze Demo von Kreuzweg bis zum Ende der Glutoase. – Status: offen

### Alpha-Test (Plan vom 09.11.2026, aus ALPHA_FEEDBACK.md)

Marcos Beschluss (09.11.): **Erst die Blocker (A1a, A1b), dann S3b, S4 und S5, danach A2 bis A13 von oben nach unten.** Die Nummern in Klammern sind die Punkte aus `ALPHA_FEEDBACK.md`. Beschlüsse dazu stehen in design.md (Tagebuch 09.11.).

- **A1a:** Blocker beim Weiterkommen: Nach der Glutoase und dem Gespräch mit der Wache fehlt der Marker und der Seilaufzug nach Wipfelheim geht nicht (40); „Der Tanz mit der Pause“ ohne Warten bis nachts (32); „Kochende Brunnen“ zeigt keinen Weg (30, Wegweiser für alle Ziele); nach dem Klassenwechsel läuft man in der Welt noch als Novize (24). – Status: fertig (09.11.2026; Wegweiser findet jetzt auch Seilaufzüge, der Aufzug reagiert aufs ganze Bild; die Sternensängerin können männliche Figuren nicht wählen und nicht ausprobieren (Marco, 09.11.); Marcos Klingentänzer als Novize kam vermutlich vom Online-Spiel, das ist A2)
- **A1b:** Blocker in Kampf und Menüs: Heiltrank heilt im Kampf nicht (35); in allen Menüs lässt sich mit Maus und Finger klicken, z. B. Seiten im Kartenalbum (L) wechseln, Fähigkeiten anklicken (28, 29); die Klingen bei Klingenschritt treffen nicht nach (36); der alte kleine Ortsname kommt raus, nur der große bleibt (46). – Status: fertig (09.11.2026; die Fenster wurden in jedem Bild neu aufgebaut, darum ging kein Klick durch, jetzt nur bei Änderungen; Tränke heilten nur beim Novizen; Klingen treffen jetzt immer nach, Klingenkranz macht sie stärker)
- *(danach S3b, S4, S5 aus „Nach der Demo“)*
- **A2:** Start und Online: Startbildschirm nur „Offline“ und „Online“, beide dasselbe Spiel ohne Unterschiede (48, 49, 3: online noch das alte Figuren-Modell); Feedback nur im Spiel oben rechts, Dankesliste in den Abspann; weißer Fleck (Silberkraut) online beheben (4); gemeinsamer Kampf sieht schöner aus (16, Plätze und Größen der Figuren); online nach dem Lernen der Klasse noch als Novize gesehen (Klingentänzer, Alpha-Punkt 24); Gruppenfenster ein-/ausklappbar und halb durchsichtig, Verlassen-Knopf kleiner (8). – Status: fertig (09.11.2026, in A2a und A2b)
  - **A2a:** Startmenü nur „Offline“ und „Online“ (Werkstatt dazu Editor), Online mit eigener Figur und eigenem Spielstand (ohne Figur erst „Figur erstellen“), Server nimmt eigene Figuren an (vorher kam jede als alte Elfe an, darum alte Modelle und kein Klassen-Körper online), Dankesliste im Abspann am Ende der Demo. – Status: fertig (09.11.2026)
  - **A2b:** Weißer Fleck (Silberkraut) online (4), gemeinsamer Kampf schöner (16), Gruppenfenster ein-/ausklappbar und halb durchsichtig, Verlassen-Knopf kleiner (8). – Status: fertig (09.11.2026; der weiße Fleck kam von der Browser-Grafik, nicht vom Online-Spiel)
- **A3:** Klassen außerhalb der Demo (Runenwächter, Mechaniker, Zwielicht, Ritualist, Quartiermeister, Kunoichi) bei der Klassenwahl sichtbar, aber gesperrt („kommt später“); ihre Lehrmeister verschwinden aus der Welt; auf dem Weg sind nur die Klassen aus Grünwacht und Glutoase offen (9, 15). – Status: fertig (09.11.2026; nach Marcos Änderung bleiben die Gesandten aus Arkanum, Messinghafen und von den Nebelinseln stehen und bieten noch nichts an; eigene Lehrmeister haben diese Klassen in der Welt nicht)
- **A3b:** Klassenwahl mit gemalten Klassenbildern statt der alten Pixel-Figuren (Marco, 09.11.): großes Bild je Klasse, Bildaufträge in `Spieldesign/GRAFIK_AUFTRAG.md` Teil H (H1 die fünf der Demo, H2 die sechs späteren). – Status: wartet auf Marcos Bilder (`tools/vorlagen/klassenbild_<klasse>.png`)
- **A4:** Kreuzweg-Geschichte: Ye erklärt vor dem Kampf, nicht mittendrin; beim Parieren sagt Ye, dass man jetzt zweimal perfekt parieren soll (5); nach der Probestunde schließt sich das Fenster und ein Gespräch sagt, dass man ein Abzeichen bekommt und mit dem Auftrag weitermachen kann, Weiterprobieren bleibt möglich (10); Mira kommt beim Auftrag einfach von oben vom Marktplatz (13); Rettung in der Sternenfall-Nacht als Szene im Kampf, mehr Bewegung (14). – Status: fertig (09.11.2026, in A4a und A4b)
  - **A4a:** Ye erklärt jede Lektion vor dem ersten Zug, in der Paradeschule sagt er nach den zwei vorgeführten Paraden „jetzt zweimal perfekt“ (5); nach der Probestunde beim Gesandten zurück in die Stadt, der Gesandte überreicht ein Abzeichen, weitere Probestunden bleiben möglich (10). – Status: fertig (09.11.2026)
  - **A4b:** Mira kommt beim Auftrag einfach von oben vom Marktplatz (13); Rettung in der Sternenfall-Nacht als Szene im Kampf, mehr Bewegung (14). – Status: fertig (09.11.2026; Rens eigene Bilder für Welt, Kampf und Porträts eingebaut)
- **A5:** Glutoase: Sternensängerin-Aufträge führen nach dem Abschluss direkt zum nächsten Auftrag (23); Mira liegt krank auf einem Bett im Zelt statt davor (31, Bett-Bild: Prompt für Marco); Lava in der Vulkanschmiede mit Glut-Effekt deutlich sichtbar (33); Weg in der Vulkanschmiede überall erkennbar (34). – Status: fertig (09.11.2026; Mira liegt auf dem gemalten Bett im Krankenzelt, kein neues Bild nötig; Lava wird vom Spiel gemalt)
- **A6:** Kampf-Anzeige: Schild der Monster als Leiste über dem Leben und als Symbol mit Zahl beim Namen (6); beim Angreifen unten eine Liste aller Ziele mit Zahlen, „Zurück“ immer auf der 6 (43); Klang beim Stufenaufstieg (11, freier Klang, Quelle in CREDITS.md); Auftragsbelohnungen übersichtlich mit Bildern und Mengen (7). – Status: fertig (09.11.2026; Stufen-Klang selbst erzeugt wie die anderen Geräusche; „Zurück“ auf der 6 auch bei Auswahl-Menüs)
- **A7:** Figuren richten: Köpfe m1 und w1 in der Welt und beim Laufen/Angriff in die richtige Richtung (1, 2); Frauen-Köpfe schauen zur Seite, Körper nach unten: Wirtin Layla, Brunnenhüterin Nadia und alle anderen (19, 20, 21); Broms Helm sitzt richtig (12); Prompts für die Zielscheiben (neuer Körper, 22) und für Echsenschuppe und Sonnenmähne (25). – Status: fertig, soweit ohne neue Bilder möglich (10.11.2026; m1 und w1 schauen richtig: gespiegelt werden nur noch die Köpfe, die nach links gezeichnet sind (m2, m3, w2, w3, a_m1, k_w1, Borko); Broms Helm größer, tiefer, Inneres frei. Warten auf deine Bilder: Köpfe von vorne für die Frauen, Zielscheiben, Beute-Bilder, Prompts in `Spieldesign/GRAFIK_AUFTRAG.md` Teil K; seit 10.11. alle Bilder aus Teil K eingebaut, dazu der neue Körper „Frau, korpulent“ für Salbei)
- **A8:** Bilder statt Schrift: Fähigkeiten-Baum mit Symbolen, Name beim Drüberfahren bzw. Antippen (26); wie in WoW: Reihen von oben nach unten, frei ab Klassenstufe 1, 10, 20, 30 (wie beschlossen), Linien zu den Voraussetzungen, dieselben Symbole in der Kampfleiste (Marco, 10.11.); Ausrüstung als Plätze mit dem Bild der Waffe/Rüstung (27). Prompts für Symbol-Blätter (je Klasse ein Blatt, dazu Ausrüstung) in GRAFIK_AUFTRAG.md, bis dahin Platzhalter. – Status: geteilt (10.11.2026)
  - **A8a:** Fähigkeiten-Baum mit Feldern statt Textliste: Grundreihe oben, Reihen 1 bis 4 nach unten, Stufe auf jedem Feld, Linien zu den Voraussetzungen, Name beim Drüberfahren, Antippen zeigt Beschreibung mit „Lernen“ und „Auf die Leiste“, Leiste als sechs Felder; Bilder auch auf den Kampfknöpfen, sobald sie da sind. – Status: fertig (10.11.2026; Prompts in `Spieldesign/GRAFIK_AUFTRAG.md` Teil L, Zuschneiden mit `tools/faehigkeit_bilder.py`; seit 11.11. haben alle fünf Demo-Klassen und der Novize gemalte Bilder, die übrigen sechs Klassen noch Anfangsbuchstaben)
  - **A8b:** Ausrüstung als Plätze mit dem Bild der Waffe oder Rüstung (27). – Status: fertig (10.11.2026; im Werte-Fenster die Figur mit sechs Plätzen, Antippen zeigt Werte und „Ablegen“; seit 10.11. haben die 13 Ausrüstungsteile gemalte Bilder, K3f)
- **A9:** Pilzhöhle und Vulkanschmiede (Marco, 10.11.: beide Dungeons): Am Eingang bis zu 2 Computer-Verbündete wählen (oder keinen), sie bleiben für alle Kämpfe im Dungeon (37); Film/Bewegung, wenn der Boss in Phase 2 geht, Fesseln stärker (38); Phase 2 nur mit der Mechanik zu schaffen (39, Zahlen mit dem Kampf-Editor prüfen). – Status: geteilt (10.11.2026)
  - **A9a:** Am Eingang beider Dungeons wählen, wer mitkommt: allein, mit Tessa, mit Gorm oder mit beiden. Die Wahl gilt für alle Kämpfe des Durchgangs, auch gegen die normalen Monster (37). – Status: fertig (10.11.2026)
  - **A9b:** Bosse beider Dungeons (Wurzelmutter, Sporenkönigin, Hammerbrüder, Kettenschmied): Film beim Wechsel in Phase 2, Fesseln stärker, Phase 2 nur mit der Mechanik zu schaffen, Zahlen mit dem Kampf-Editor prüfen (38, 39). – Status: fertig (11.11.2026, in A9b1 bis A9b3)
    - **A9b1:** Kettenschmied: Film „Entfesselt!“ (die Ketten reißen), Fesseln stärker (Gefesselte nehmen zusammen mehr Schaden, die Kette brennt), Phase 2 nur mit dem Kühlbecken zu schaffen. – Status: fertig (11.11.2026; gemessen mit `tests/boss_messen.gd`: mit Kühlbecken gewinnt die Gruppe 85 von 100, ohne keinen; allein schafft man ihn selten, schon Phase 1 ist zu schwer, das gehört zu E4)
    - **A9b2:** Wurzelmutter und Vorbote (Pilzhöhle): Film, wenn der Vorbote aus dem Splitter bricht, Phase 2 nur mit Laternen und Splitterlicht zu schaffen, messen mit `tests/boss_messen.gd`. – Status: fertig (11.11.2026; im Dunkeln trifft man den Vorboten kaum, voll nur mit dem Splitterlicht oder wenn Laternen das Feld hell halten; gemessen: mit Mechanik 85 von 100 gewonnen, ohne 5 (vorher 83 und 64))
    - Die gezeichneten Effekte beider Dungeons (Ketten, Lava, Laternen, Splitterlicht, Giftwolken, Riss der Leere) malt ChatGPT neu: Prompts in `Spieldesign/GRAFIK_AUFTRAG.md` Teil M, Anhänge in `tools/referenz/teil_m/` (Marco, 11.11.). Einbau, sobald die Bilder da sind.
    - **A9b3:** Sporenkönigin und Hammerbrüder: Sie haben bisher keine Phase 2. Marco (11.11.): ab halbem Leben eine Wut-Phase mit kurzem Film, in der die Mechanik (Sporenknospen, Doppelschlag oder Gleichschritt) Pflicht wird. – Status: fertig (11.11.2026; gemessen je Mechanik, mit / ohne: Sporenblüte 79 / 0, Zwillinge 59 / 11, Doppelschlag 95 / 0, Gleichschritt 94 / 15 von 100)
- **A10:** Monster-Bilder (großer Arbeitsblock): Jedes Monster bekommt volle eigene Bilder statt der Familien-Teile (44, 17 Mähne der Steppenhyäne, 18 Monster sehen in Bewegungen anders aus); Abwehr und Fernkampf-Angriffe als ChatGPT-Bildfolgen statt gezeichnet (45). Ablauf: alle Prompts gesammelt in GRAFIK_AUFTRAG.md, **ein ChatGPT-Chat pro Familie**, jeder Prompt mit Referenzbildern der Familie und dem Bild der Bewegung, damit es einheitlich bleibt. Danach Einbau Familie für Familie. – Status: offen Stand 10.11.: Punkte 17, 18, 44 fertig (eigene Blätter für alle Monster der Demo, 09./10.11.), offen sind 45 und das Aufräumen der alten Familien-Bilder.
- **A11:** Orientierung: kleine Karte oben in der Ecke (einklappbar) und große Karte auf Taste M mit Ortsnamen und Wegen, damit man sieht, wo man entlanggehen und hinreisen kann (41, 42). – Status: offen
- **A12:** Gebäude betreten: zuerst je Stadt die Taverne (Wegrast in Kreuzweg, Gasthaus in Wipfelheim, Taverne der Glutoase) mit Innenraum und den Figuren, die dort sind (47). – Status: offen
- **A13:** Neues Gebiet zwischen Glutoase und Grünwacht (51): eigene Karte mit Übergang Steppe → Wald (im Süden trockenes Gras, nach Norden lichter Wald), Monster um Stufe 20, neue Übergangs-Böden (52, Prompts für Marco). – Status: offen
- **A14:** Kreuzwegfelder als eigenes Gebiet vor der Stadt (design.md: durch das Südtor auf die Felder und weiter in die Aschensteppe, vom Trainingsplatz der Gilde ein Seitentor). Die Monster dort haben schon ihre eigenen Blätter, sie kommen bisher nur in Ye's Lektionen vor (Marco, 10.11.). – Status: offen
- **A15:** Nachholen vom 21.10. (lagen auf dem Zweig `ccr-3050ae70-usmme8` und kamen nie ins Spiel, design.md hat sie beschlossen): Nebenauftrag „Ein Brief vom Tor“ (Brom bittet einen, einen Brief an Hanne zu bringen), Sternenfresser mit „Sternenschlund“ (ohne perfekte Parade sofort besiegt, Explosion nach 8 Zügen), Empfehlungsschreiben von Ye beim Abschied. Auf dem heutigen Stand neu bauen, der Zweig dient als Vorlage. – Status: offen
- **A16:** Novizen-Fähigkeiten nach der Klassenwahl behalten (Marco, 11.11., Beschluss in design.md): Schildstoß, Doppelschlag, Erste Hilfe und Deckung geben bleiben nach dem Klassenwechsel erhalten und lassen sich weiter benutzen. Vorschlag: im Fähigkeiten-Baum als eigene Reihe „Novize“ oben, frei auf die Leiste legbar (sechs Felder), die gemalten Bilder sind seit 11.11. da (`assets/faehigkeiten/novize_*`). Wie genau sie im Kampf erscheinen, entscheidet Marco beim Bauen. – Status: offen
- Punkt 50 (Städte umbauen) ist E3h. Fertig (E3h1 bis E3h3b, 10.11.).

### Endspurt (Plan vom 04.11.2026, sparsam mit Tokens)

Wenig Tokens übrig: Arbeit in wenigen großen Blöcken statt vieler kleiner Runden. **Pro Block ein neuer Chat**, Marco schreibt nur „Mach weiter“; alles Wichtige steht in FORTSCHRITT.md.

- **E1:** Fünf Entscheidungen einbauen. – Status: fertig (04.11.2026: Sporenkönigin mit Mechanik in der Welt, Glutgeist und Namen bleiben, Kobalt vorerst Zähmer-Körper; Lichter in Kreuzweg: Vergleichsbilder geschickt, ohne Zusage bleiben die echten Lichter)
- **E2:** D25b auf einen Schlag. – Status: fertig (04.11.2026, Bilder lagen schon unter `tools/vorlagen/`)
- **E3:** T1 und T2 zusammen spielen. – Status: Marcos erste Liste da (04.11.2026), geteilt in E3a bis E3h:
  - **E3a:** Wegweiser nach dem Klassenwechsel (z. B. Klingentänzerin: man weiß nicht, wohin). Alle Aufträge nach der Klassenwahl bekommen Wegweiser. – Status: fertig (05.11.2026)
  - **E3b:** Kopfrichtung: Bei den Novizen und beim eigenen Charakter schaut der Kopf in eine andere Richtung als der Körper. Fehler suchen und beheben. – Status: fertig (05.11.2026)
  - **E3c:** Ortsnamen beim Betreten eines Gebiets groß und in einer schöneren Schrift einblenden, damit man merkt, wo man hingeht (freie Schrift, Quelle in CREDITS.md). – Status: fertig (05.11.2026)
  - **E3d:** Kampf-Hintergründe: jedes Gebiet mindestens ein eigener (fehlen: Aschensteppe, Palmenrast, Glutgrat, Tiefwurzel, Kreuzwegfelder; Kämpfe in Städten), gern mehrere je nach Ort im Gebiet. – Status: fertig (05.11.2026; elf neue Hintergründe, dazu nachts dunkle Kämpfe unter freiem Himmel; seit 06.11. mit Marcos gemalten Bildern aus ChatGPT, GRAFIK_AUFTRAG.md Teil F)
  - **E3e:** Klingentänzerin hat noch die alten Schwerter: ihre eigenen Klingen aus Marcos Waffen-Blatt einbauen (sonst Prompt). – Status: fertig (05.11.2026)
  - **E3f:** Kräuter sammeln: neues Bild für die Kräuter in der Welt (Prompt für Marco). – Status: fertig (05.11.2026)
  - **E3g:** Laufbewegung der Novizen sieht schlecht aus: feiner, ggf. mit mehr Bildern (Prompt für Marco). – Status: fertig (05.11.2026)
  - **E3i:** Abschied von Kreuzweg ohne Versetzen: Ye schickt einen nach dem Abschied zur Torwache in Richtung der eigenen Region (West-/Südtor, mit Wegweiser), man läuft selbst hin und durchs Tor. Die Wache nennt die Richtung. „Ende von Akt 1“ erscheint erst beim ersten Gang durchs Tor (Vorschlag, sonst ganz weglassen). Heute steht in Yes Abschied `reisen` nach weg_gruenwacht bzw. aschensteppe (data/dialoge.json, ye_tor). – Status: fertig (05.11.2026)
  - **E3h:** (nach S1 bis S5) Städte umbauen: zu viele Figuren und zu viele Deko-Teile auf einem Fleck (Kreuzweg, Wipfelheim, Glutoase), Figuren und Deko verteilen, Plätze freier lassen. – Status: geteilt (10.11.2026), Claude baut grob um, Marco macht den Feinschliff im Stadt-Editor:
    - **E3h1:** Kreuzweg. – Status: fertig (10.11.2026; Marktstände mit Rosa und Jost vom Marktplatz in eine Marktgasse neben Bingo und Hatta, Pip und Lotte zum Brunnen, Pavillons von Ilwen und Mei auseinander, Tessa und Gorm an die Übungspuppen, Lene ans Auftragsbrett, Bäume beim neuen Markt verteilt)
    - **E3h2:** Wipfelheim. – Status: fertig (10.11.2026; keine Baumkronen mehr vor den Plattformen, Salbeis Stand frei sichtbar; ein Gast vom Gasthaus-Eingang an die Ecke des Gasthauses, eine Sammlerin zu Esches Labor. Wipfelheim war weniger voll als Kreuzweg, die Abstände der Figuren prüft eine Prüfung)
    - **E3h3:** Glutoase, mit Ebenen, die zur Schmiede hin ansteigen (Marco, 10.11.). – Status: geteilt (10.11.2026):
      - **E3h3a:** Stadt umdrehen: Oase mit Tor vorne, Hadraks Schmiede hinten oben, damit die Terrassenmauern zum Betrachter zeigen; Figuren vor ihre Häuser, Bank etwas abgerückt. – Status: fertig (10.11.2026; im Kartenwerkzeug `tools/glutoase_karten.py`, `spiegeln()`)
      - **E3h3b:** Echte Höhen: Die drei Stufen werden höher gezeichnet (Boden, Teile, Figuren), die Mauern werden zur Felswand, Treppen steigen sichtbar an, Antippen trifft das richtige Feld. Gilt in der Welt und im Stadt-Editor. – Status: fertig (10.11.2026; Höhen stehen in `data/karten.json` unter „hoehen“, gezeichnet von `scripts/welt/hoehen.gd`; die Felswände sind gemalte Flächen mit Fugen, ein eigenes Felswand-Bild fehlt noch; Monster und Kämpfe sind davon nicht betroffen)
- **E4:** Eine Balancing-Runde: Marcos Liste plus die Zahlen aus den Prüfungen (Kael, Glasskorpion, Vulkanschmiede allein, Ritualist/Zwielicht), alle Werte in einer Sitzung. Dazu (Marco, 07.11.): Grünwacht ist jetzt das zweite Gebiet, Monster und Bosse dort auf Stufe 20–25 heben (man kommt mit etwa 20 aus der Glutoase). – Status: offen
- **E5:** T3 und T4 am Stück spielen, danach wieder eine Liste und eine Sitzung für die Korrekturen. – Status: offen

### Demo-Start (Plan vom 06.11.2026, Start der Demo Ende der Woche ab 09.11.)

Marcos Beschluss (06.11.): **Diese Punkte kommen vor E3h.** Die Städte baut Claude grob um, den Feinschliff macht Marco im Stadt-Editor (S4). Reihenfolge von oben nach unten.

- **S1:** Demo und Editor trennen. Die Demo unter `/spiel/` wird ohne Editor und ohne Testknöpfe gebaut (Uhr stellen, Geld dazu …). Die volle Fassung mit Editor bekommt eine eigene, nirgends verlinkte Adresse (`/werkstatt-<Wort>/`, das Wort sagt Claude Marco). Beide bei jedem Push veröffentlichen, beide laufen am PC und am Handy. Startseite mit großem Knopf „Demo testen“, kurzer Anleitung (Steuerung PC und Handy, Spielstand bleibt im Browser), Knopf „Fehler melden / Feedback“ (Google-Formular ohne E-Mail-Adresse, Fragen schreibt Claude), Versionsnummer im Spiel und auf der Seite. Dazu (Marco, 06.11.): Dankesliste der Tester im Spiel (Spitznamen, ohne E-Mail) und Tester-Code. Ablauf: Beim ersten Start der Demo gibt der Tester einen Spitznamen ein, der dann fest ist; das Spiel erzeugt dazu eine eindeutige Tester-Nummer (bleibt im Browser, auch bei neuem Spielstand). Der Feedback-Knopf öffnet das Formular mit Spitzname, Tester-Nummer, Version und Ort im Spiel schon ausgefüllt. Am Ende der Demo zeigt das Spiel einen Tester-Code und einen Knopf „Abschluss melden“: Das Formular kommt mit „Demo durchgespielt“ und dem Code ausgefüllt, so steht alles in Marcos Tabelle. Zum Release gilt nur ein Code, der in der Tabelle steht (doppelte prüft Claude). Marco legt das Formular an (Fragen von Claude) und schickt den „vorausgefüllten Link“.
  Das Repo bleibt für die Demo öffentlich (Marco, 06.11.): Privat stellen und Umzug kommen nach der Demo zusammen mit Server und Datenbank (siehe „Nach der Demo“). Für die Demo: Datei „Alle Rechte vorbehalten“ ins Repo; die Editor-Fassung ist nicht verlinkt, aber nicht wirklich geheim. – Status: fertig (06.11.2026; Werkstatt unter `/werkstatt-glutfunke/`; das Formular verbindet Claude, sobald Marco den vorausgefüllten Link schickt, bis dahin sagt der Knopf „kommt bald“; die Demo endet nach beiden Regionen, der Code kommt am Ende der zweiten, Marco 06.11.)

### Nach der Demo (Plan vom 06.11.2026)

- **N1:** Umzug mit Server und Datenbank: Konten mit Anmeldung, Spielstände auf dem Server, Tester-Codes einlösen (Skin oder Titel), Code-Repo privat, Webseite aus einem eigenen öffentlichen Repo oder vom Server. Wird nach der Demo genauer geplant. – Status: später
- **S1b:** Ablauf der Demo nach der Reihenfolge der Regionen (Marco, 07.11.): Die Glutoase ist das erste Gebiet der Geschichte, Grünwacht das zweite und das Ende der Demo. Bogenschütze und Zähmer lernen ihre Klasse in Grünwacht, berichten Ysolde und reisen dann in die Glutoase; alle anderen Klassen beginnen in der Glutoase. Nach dem Ende der Glutoase geht es nach Grünwacht (Teil 2 und Pilzhöhle), die Demo endet mit „Die Wahrheit über Rowan“. – Status: fertig (07.11.2026; neue Aufträge „Bericht bei Ysolde“ und „Zurück nach Grünwacht“, Texte sind Platzhalter)
- **S2:** Kampf-Editor: Monster (bis zu vier), deren Stufe, eigene Gruppe mit Klasse und Stufe, Ort (Kampf-Hintergrund) und Tageszeit wählen, dann kämpfen. Dazu ein „Probe-Lauf“: Der Kampf läuft 100-mal von selbst und zeigt, wie oft man gewinnt (hilft bei E4). – Status: fertig (08.11.2026; Monster-Stufe gilt für alle Gegner gemeinsam; Ye's Lernkämpfe und der Sternenfresser sind für Novizen gebaut)
- **S3:** Bewegungs- und Effekt-Editor: Figur wählen (Klassen, Körper, Köpfe, Monster, Hauptfiguren), jede Bewegung in Welt und Kampf einzeln abspielen (langsam, Bild für Bild), jede Fähigkeit und jeden Effekt einzeln abspielen. Baut auf der Vega-Probe und der Effekt-Probe auf. – Status: geteilt (08.11.2026)
  - **S3a:** im Kampf: Held (Klasse, Aussehen) und Monster wählen, jede Kampf-Bewegung für Held und Monster, jede Fähigkeit der Klasse wirklich auslösen, jeden Effekt (Abläufe und gemalte Bildfolgen), Tempo normal, langsam, sehr langsam. – Status: fertig (08.11.2026)
  - **S3b:** in der Welt: Figuren (Klassen-Körper, Novizen, Baukasten-Figuren, Hauptfiguren) in allen Richtungen stehen und laufen lassen, Bild für Bild. – Status: fertig (09.11.2026; Editor → „Bewegungen in der Welt“: vier Richtungen nebeneinander, Stehen, Laufen, Liegen, Sitzen, drei Tempos und Bild für Bild; Novizen und Klassen-Körper mit jedem passenden Kopf, Baukasten-Körper mit Volks-Köpfen, alle 69 Figuren der Welt)
- **S4:** Stadt-Editor: in einer Stadt Baukasten-Teile und Figuren auswählen, verschieben (auch Feld für Feld mit Knöpfen, fürs Handy), hinzufügen und löschen. Am PC in Godot speichert er direkt in die Kartendaten, im Browser gibt er eine Datei aus, die Marco Claude schickt. – Status: geteilt (09.11.2026)
  - **S4a:** Stadt zeigen (alle Baukasten-Karten), Teile und Figuren antippen, verschieben (Ziehen, Pfeilknöpfe Feld für Feld), Teile spiegeln und löschen, rückgängig, Figuren tags/nachts, speichern (Godot-Editor direkt in data/, Browser als Datei; übernehmen mit `tools/stadt_editor_uebernehmen.py`). – Status: fertig (09.11.2026)
  - **S4a2:** Drehen (Marco, 09.11.): flache Teile frei in 45°-Schritten, stehende Teile vorne, quer, von hinten und von hinten quer (Ansicht von hinten mit eigenen Bildern, `bild_hinten` in baukasten_teile.json, Prompts in GRAFIK_AUFTRAG.md Teil J). – Status: fertig (09.11.2026; Bilder von hinten fehlen noch, bis dahin nur vorne und quer)
  - **S4c:** Online speichern, damit Katie mithelfen und Marco am Handy bauen kann. – Status: erst besprechen (Marco, 09.11.)
  - **S4b:** Hinzufügen: Teile aus dem Baukasten mit Bild auswählen und setzen, neue Volks-Figuren (Körper und Kopf), Figuren löschen (nur Volk, keine Figuren mit Aufträgen). – Status: fertig (09.11.2026; Fenster „Hinzufügen“ mit allen Teilen als Bild, Filter nach Region und Suche; neue Figuren sagen vorerst einen allgemeinen Satz)
- **S5:** Spielstand-Editor: Stufe, Klasse, Gold, Gegenstände und Akt setzen, um schnell an jede Stelle der Demo zu springen (erweitert „Demo ab einem Akt“). – Status: fertig (09.11.2026; Editor → „Spielstand-Editor“: Klasse, Figur, Stufe, Geld, Tränke, weitere Gegenstände und einer von 25–27 Punkten der Geschichte je Klasse; der Sternenfall-Punkt beginnt nach dem Kampf, Dungeons am Eingang)
- **S6:** (Marco, 10.11.: ganz am Ende, nach E3h, E4 und E5) Eigene Sitz-Bilder und flüssigeres Laufen in der Welt für alle Figuren: 8 Laufbilder je Richtung wie bei den Novizen (bisher 4 bis 6), Sitzen schräg von vorne, hinten und von der Seite statt der gestauchten Figur. Braucht Marcos Blätter, Prompts in `Spieldesign/GRAFIK_AUFTRAG.md` Teil I. Vielleicht baut Marco die Welt-Figuren ganz um, mit Ragnarok-Figuren als Vorlage für Richtungen und Posen; dann kommen neue Prompts. – Status: offen (wartet auf Bilder)
  - *Hinweis (10.11.): S3b, S4 und S5 wurden am 10.11. in einem zweiten Chat noch einmal gebaut. Beim Zusammenführen gilt die Fassung vom 09.11. (oben), dazu kamen die Ebenen der Glutoase (E3h3b) in den Stadt-Editor.*

**So arbeitet Claude im Endspurt:** nur die Prüfungen laufen lassen, die zur Änderung passen (`bash tools/alle_tests.sh <wort>`), die volle Prüfung einmal am Ende der Sitzung; Fotos aus dem Spiel nur, wenn sich das Aussehen ändert; kurze Antworten.

## Projekt 0: Playtest 25.10. (Rest) – kommt vor allen anderen

Teil 1 ist gebaut (siehe FORTSCHRITT.md). Schritte 1–4 fertig (26.10.). Die Details stehen im Brainstorm-Doc unter „Testtag-Notizen“ → „Playtest 25.10.2026“.

### Schritt 1: Tasche wie in klassischen Spielen
- **Ziel:** Die Tasche zeigt Kästchen, in jedem liegt ein Gegenstand mit Bild und Anzahl. Gegenstände lassen sich per Ziehen und Ablegen verschieben (die Reihenfolge wird gemerkt). Passt zu Projekt 4 (Tasche und Bank).
- **So testest du es:** Mit I die Tasche öffnen, einen Gegenstand in ein anderes Kästchen ziehen, Tasche schließen und wieder öffnen: Er liegt noch dort.
- **Status:** fertig (26.10.)

### Schritt 2: Klasse erst beim Lehrmeister lernen
- **Ziel:** Am Ende von Kreuzweg wählt man nur die Klasse und bekommt einen Auftrag, der zum Lehrmeister in der Region führt. Erst dort lernt man die Klasse (bis dahin kämpft man als Novize). Gilt für alle Klassen, Grünwacht zuerst (Fenn, Tilda).
- **So testest du es:** Neu beginnen, bis zur Klassenwahl spielen, eine Grünwacht-Klasse wählen: Der Wegweiser führt zum Lehrmeister, erst nach dem Gespräch dort kämpft man mit der Klasse.
- **Status:** fertig (26.10.; Bogenschütze bei Fenn, Zähmer bei Esche; die anderen Klassen kämpfen wie bisher gleich mit ihrer Klasse, bis es ihre Region gibt)

### Schritt 3: Kael kommt auf einer anderen Plattform dazu
- **Ziel:** Kael steht nicht mehr direkt neben Ysolde. Ein kleiner Auftrag schickt einen auf eine andere Plattform in Wipfelheim, dort kommt Kael angelaufen und spricht einen an.
- **So testest du es:** Nach den veränderten Tieren dem Wegweiser folgen: Kael läuft auf der anderen Plattform zu dir.
- **Status:** fertig (26.10.; Westplattform beim Seilaufzug, Auftrag „Ein Fremder in Wipfelheim“ von Ysolde)

### Schritt 4: Grünwacht größer
- **Ziel:** Weg nach Grünwacht, Waldboden und Wipfelheim werden größer und weniger eng (mehr Platz zwischen Bäumen, Figuren und Orten). Monster, Orte und Wegweiser passen sich an, die automatischen Durchläufe laufen weiter.
- **So testest du es:** Durch den Wald und Wipfelheim laufen: Es fühlt sich weiter an, nichts klemmt, keine Figur steht zu dicht an einer anderen.
- **Status:** fertig (26.10.; alle drei Karten um die Hälfte größer, Pilzhöhle unverändert)

## Projekt 1: Aussehen

### Schritt 1: Licht wie bei Octopath Traveler
- **Ziel:** Lichtquellen wie Fackeln, Laternen, leuchtende Sternensplitter und Glut, dazu ein leichtes Abdunkeln der Umgebung, damit das Licht wirkt.
- **So testest du es:** Kreuzweg und die Pilzhöhle ansehen, die Lichter werfen einen Schein und die Splitter glühen.
- **Status:** fertig (22.10.)

### Schritt 2: Einheitliches Pixel-Paket
- **Ziel:** Ein einheitliches kostenloses Pixel-Paket (freie Lizenz) im Stil von Ragnarok und Octopath. Claude Code schlägt vorher zwei bis drei Pakete zur Auswahl vor und stellt nach Marcos Wahl alle Platzhalter darauf um.
- **So testest du es:** Durch Kreuzweg laufen und einen Kampf spielen, alles wirkt wie aus einem Guss.
- **Vorschläge (22.10.):** A) Flare (schräge Sicht wie jetzt, Ausrüstung sichtbar, CC-BY-SA), B) LPC-Figurenbaukasten (Sicht von oben, riesige Auswahl, CC-BY-SA/GPL/OGA-BY, Welt müsste umgebaut werden), C) Ninja Adventure (Sicht von oben, niedlich, CC0). Empfehlung Claude: A. Marco (22.10.): Flare gefällt nicht, gewünscht ist Pixel-Grafik wie Octopath, er schaut sich selbst um (selbst zeichnen, KI als Vorlage oder Pixel-Künstler).
- **Status:** zurückgestellt (wartet auf die Look-Bibel, Abendthema 12 im Brainstorm-Doc)

### Schritt 3: Licht im Kampf
- **Ziel:** Der Kampf übernimmt das Grundlicht des Ortes (Höhle dunkel, Fest-Nacht bläulich, tagsüber hell). Im Gewölbe stehen Fackeln am Rand. Feuer-, Blitz-, Licht- und Splitter-Angriffe leuchten kurz auf (wie die Zauber bei Octopath Traveler).
- **So testest du es:** Einen Kampf in Kreuzweg, einen in der Pilzhöhle und einen in der Fest-Nacht spielen: Jeder Kampf sieht aus wie sein Ort, ein Feuerangriff taucht das Feld kurz in oranges Licht.
- **Status:** fertig (22.10.)

### Schritt 4: Licht als Mechanik in der Pilzhöhle
- **Ziel:** Beim Vorboten wird das Licht Teil der Anzeige: Bei „Lichtfraß“ schrumpfen die Lichtkreise sichtbar, „Laterne entzünden“ stellt eine echte Laterne mit Lichtkreis aufs Feld, wer das Splitterlicht hält („Das letzte Licht“), leuchtet lila, und beim Weiterreichen wandert das Licht sichtbar. Die Regeln bleiben gleich, nur die Anzeige ändert sich.
- **So testest du es:** Gegen den Vorboten kämpfen, eine Laterne entzünden und das Splitterlicht weiterreichen: Man sieht immer, wo Licht ist und wer sicher ist.
- **Status:** fertig (22.10.)

## Projekt 2: Kampfgefühl

### Schritt 1: Parieren mit Klang und Funken
- **Ziel:** Parieren mit knackigem Klang und kurzem Funkenblitz. Beim perfekten Parieren zusätzlich ein heller Ton und ein kleiner Zeitlupen-Moment. Klänge vorerst aus kostenlosen Paketen mit freier Lizenz.
- **So testest du es:** Im Kampf normal und perfekt parieren, beides klingt und sieht unterschiedlich aus und fühlt sich gut an.
- **Schon da:** Parade-Klirren und bei der perfekten Parade ein heller Dreiklang (selbst erzeugte Platzhalter, Schritt 19 in FORTSCHRITT.md). Offen sind Funkenblitz, Zeitlupe und Klänge aus einem freien Paket.
- **Hinweis (22.10.):** Klänge neu selbst erzeugt (knackiger), weil die Seiten der freien Klang-Pakete aus der Cloud gesperrt sind. Ein freies Paket (z. B. Kenney „Impact Sounds“, CC0) kann später am PC eingesetzt werden.
- **Status:** fertig (22.10.)

### Schritt 2: Harte Treffer spürbar machen
- **Ziel:** Harte Treffer lassen das Bild für einen Augenblick anhalten, dazu wackelt der Bildschirm leicht.
- **So testest du es:** Einen starken Angriff ausführen und einen harten Treffer einstecken, beides spürt man deutlich.
- **Status:** fertig (22.10.)

### Schritt 3: Schadenszahlen
- **Ziel:** Kritische Treffer erscheinen groß und farbig. Bei Mehrfach-Treffern ploppt jede Zahl einzeln schnell nacheinander auf. Welche Fähigkeiten mehrfach treffen, kommt später aus Abendthema 13.
- **So testest du es:** Einen kritischen Treffer und einen Mehrfach-Angriff (z. B. Schnellfeuer) ansehen.
- **Status:** fertig (22.10.)

## Projekt 3: Geld (Bronze, Silber, Gold)

### Schritt 1: Geld speichern und anzeigen
- **Ziel:** Geld wird als eine Zahl gespeichert und als Bronze, Silber und Gold angezeigt (z. B. 100 Bronze = 1 Silber, 100 Silber = 1 Gold). Die Münznamen stehen an einer einzigen Stelle.
- **So testest du es:** Geld-Anzeige ansehen, per Testknopf Geld dazugeben und prüfen, ob die Münzen richtig umspringen.
- **Status:** fertig (27.10.; bisherige Beträge zählen jetzt als Bronze, die Feinabstimmung kommt mit Schritt 2)

### Schritt 2: Monster lassen wenig Geld fallen
- **Ziel:** Besiegte Monster geben einen kleinen Geldbetrag, damit Geld knapp bleibt.
- **So testest du es:** Monster besiegen, das Geld steigt um einen kleinen Betrag.
- **Schon da:** Monster in der Wildnis geben bereits „etwas Gold“. Offen ist, die Beträge auf Bronze/Silber/Gold umzustellen und knapp zu halten.
- **Status:** fertig (27.10.; Monster 3–5 Bronze, Aufträge ein paar Silber, Heiltrank 25 Bronze)

## Projekt 4: Tasche und Bank

### Schritt 1: Tasche mit 30 Plätzen
- **Ziel:** Die Tasche hat 30 Plätze.
- **So testest du es:** Gegenstände aufheben, bis die Tasche voll ist, danach erscheint ein Hinweis.
- **Status:** fertig (27.10.; Sammeln und Kaufen klappen bei voller Tasche nicht, Geschenke aus Aufträgen kommen trotzdem hinein)

### Schritt 1b: Wegwerfen und Beute-Fenster
- **Ziel:** Gegenstände lassen sich aus der Tasche wegwerfen (mit Nachfrage; nicht bei Gegenständen der Geschichte oder für laufende Aufträge). Passt Beute nach einem Sieg nicht mehr in die Tasche, wartet sie im Beute-Fenster: erst etwas wegwerfen, dann nehmen, oder liegen lassen. (Marcos Wunsch vom 27.10.)
- **So testest du es:** Tasche füllen, Beute bekommen, das Beute-Fenster erscheint. Etwas wegwerfen, dann die Beute nehmen.
- **Status:** fertig (27.10.; Monster lassen noch keine Gegenstände fallen, darum vorerst Testknopf „Test: Beute“)

### Schritt 2: Bank, die überall dasselbe enthält
- **Ziel:** Jede Bankstelle zeigt dieselben eingelagerten Sachen.
- **So testest du es:** Etwas einlagern und wieder herausholen, an zwei Bankstellen prüfen, dass beide dasselbe zeigen.
- **Status:** fertig (28.10.; Bankstellen: Bankhüterin Ilse in Kreuzweg neben der Gilde, Bankhüter Tamm in Wipfelheim; 20 Plätze, ganze Stapel einlagern und abholen)

### Schritt 3: Bankplätze gegen Gold erweitern
- **Ziel:** Man kann mehr Bankplätze kaufen.
- **So testest du es:** Erweiterung kaufen, das Geld sinkt, die Bank hat mehr Plätze.
- **Status:** fertig (28.10.; an jeder Bankstelle: +10 Plätze für 50 Silber, 1 Gold, 2 Gold, 4 Gold, dann voll ausgebaut mit 60 Plätzen; Preise in data/laeden.json)

## Projekt 5: Gürtel und Tränke

### Schritt 1: Vier Gürtelplätze
- **Ziel:** Vier Gürtelplätze, jeder fasst einen kleinen Stapel (z. B. 5). Befüllen nur außerhalb des Kampfes.
- **So testest du es:** Heiltränke auf den Gürtel legen, im Kampf lässt sich der Gürtel nicht umräumen.
- **Status:** fertig (28.10.; Gürtel unter der Tasche, nur Heiltränke, Stapel bis 5; im Kampf zählen Gürtel und Tasche zusammen, verbraucht wird zuerst vom Gürtel – dass nur der Gürtel zählt, kommt mit Schritt 2)

### Schritt 2: Ein Gürtel-Gegenstand pro Runde gratis
- **Ziel:** Im Kampf ist ein Gürtel-Gegenstand pro Runde gratis, jeder weitere kostet den Zug.
- **So testest du es:** Trank nehmen und in derselben Runde noch angreifen, ein zweiter Gegenstand beendet den Zug.
- **Status:** fertig (28.10.; „Runde“ = eigener Zug; im Kampf zählen nur noch Tränke am Gürtel, neue Tränke hängen sich von selbst an den Gürtel)

### Schritt 3: Gemeinsame Trank-Wartezeit
- **Ziel:** Gemeinsame Wartezeit von 3 Runden für alle Tränke, sichtbar am Gürtel.
- **So testest du es:** Nach einem Trank sind alle Tränke 3 Runden gesperrt und zählen sichtbar herunter.
- **Status:** fertig (03.11.2026)

## Projekt 6: Händler

### Schritt 1: Händler verkauft Tränke und Grundmaterialien
- **Ziel:** Ein Händler verkauft Heiltränke und Grundmaterialien (Garn, Öl, Leder) gegen Geld.
- **So testest du es:** Etwas kaufen, das Geld sinkt, der Gegenstand liegt in der Tasche. Ohne genug Geld klappt der Kauf nicht.
- **Schon da:** Bingos Laden in Kreuzweg verkauft Heiltränke (mit „Zu wenig Gold“). Offen sind die Grundmaterialien und die neuen Münzen.
- **Status:** fertig (03.11.2026)

## Projekt 7: Tag und Nacht
_Aus Marcos Entscheidung vom 22.10.2026: Tageszeit nach der echten Uhrzeit, nachts andere Monster und eigene Stimmung._

### Schritt 1: Tageszeit nach der echten Uhrzeit
- **Ziel:** Das Licht wechselt fließend zwischen Morgen, Tag, Abend und Nacht (Nacht von 21 bis 6 Uhr, dazwischen Dämmerung; die Fest-Nacht der Geschichte bleibt immer Nacht). Das Licht richtet sich nach der lokalen Uhrzeit des Spielers. Nachts ist die Welt dunkler, Laternen, Fenster und Fackeln leuchten stärker. Ein Testknopf stellt die Uhrzeit vor.
- **So testest du es:** Mit dem Testknopf die Uhrzeit auf Abend und Nacht stellen: Die Welt wird langsam dunkler und die Lichter wirken stärker.
- **Status:** fertig (03.11.2026, als D14)

### Schritt 2: Nachts andere Monster
- **Ziel:** In der Wildnis stehen nachts andere Monster als tagsüber. Ob Nacht ist, bestimmt hier die Uhrzeit des Servers, damit alle am selben Ort dieselben Monster sehen.
- **So testest du es:** Testknopf auf Nacht: Auf dem Weg nach Grünwacht stehen andere Monster, auf Tag wieder die gewohnten.
- **Status:** fertig (03.11.2026, als D14)

## Projekt 8: Monsterkarten und Kartenalbum (Beschluss 27.10.)

### Schritt 1: Kartenalbum
- **Ziel:** Eigenes Menü (Taste K und Knopf oben) mit einer Seite pro Region. Feste Plätze für jedes Monster der Region, fehlende Karten nur als dunkler Umriss, Zähler „Grünwacht: 5 / 12“, doppelte Karten mit Anzahl. Die Textzeile unten in der Tasche entfällt.
- **So testest du es:** Mit K das Album öffnen, zwischen den Seiten blättern; gesammelte Karten sind zu sehen, fehlende als Umriss, der Zähler stimmt.
- **Status:** fertig (03.11.2026, als D15)

### Schritt 2: Karten aktivieren
- **Ziel:** Eine gefundene Karte fällt als „unbekannte Monsterkarte“ in die Tasche (bei voller Tasche ins Beute-Fenster). „Aktivieren“ dreht sie mit einem kleinen Aufdeck-Moment um, danach liegt sie im Album und die Tasche ist wieder frei.
- **So testest du es:** Monster besiegen, bis eine Karte kommt, in der Tasche „Aktivieren“ wählen: Die Karte dreht sich um und steht im Album.
- **Status:** fertig (03.11.2026, als D15)

### Schritt 3: Monster-Infos im Album
- **Ziel:** Schon die erste Karte eines Monsters zeigt im Album sein Element und seine Schwäche.
- **So testest du es:** Im Album eine Karte anklicken: Element und Schwäche stehen dabei, bei fehlenden Karten nicht.
- **Status:** fertig (03.11.2026, als D15)

### Schritt 4: Besitzeffekte
- **Ziel:** Jede Karte im Album gibt einen kleinen dauerhaften Bonus, der zum Monster passt (z. B. Rindenbär +1 Leben, Windfalke +1 Tempo) und im Kampf wirkt. Doppelte zählen nicht mehrfach. Im Album und unter „Werte (C)“ steht, was die Karten zusammen bringen. Vorerst nur Werte, die es im Kampf schon gibt (Leben, Mana, Angriff, Tempo); Verteidigung kommt mit der Ausrüstung dazu.
- **So testest du es:** Werte (C) ansehen, eine neue Karte aktivieren: Der Wert steigt um den Bonus der Karte.
- **Status:** fertig (03.11.2026, als D16)

### Schritt 5: Deck für Kreuzweg-Karten wählen
- **Ziel:** Im Album wählt man die 5 Karten, mit denen man bei Kreuzweg-Karten antritt.
- **So testest du es:** Im Album 5 Karten markieren, gegen Marv spielen: Genau diese Karten sind auf der Hand.
- **Status:** fertig (03.11.2026, als D16)

### Schritt 6: Doppelte Karten bei Bingo verkaufen
- **Ziel:** Bingo kauft doppelte Karten für ein paar Bronze. Die letzte Karte einer Sorte bleibt immer im Album.
- **So testest du es:** Mit einer doppelten Karte zu Bingo gehen, sie verkaufen: Das Geld steigt, im Album steht eine weniger.
- **Status:** fertig (03.11.2026, als D16)

### Schritt 7: Belohnung für eine volle Seite
- **Ziel:** Wer alle Karten einer Region hat, bekommt eine Belohnung (Titel, besonderer Kartenrücken oder Extra-Platz in der Tasche; welche genau, entscheidet Marco).
- **So testest du es:** Per Testknopf alle Karten einer Region geben: Die Belohnung erscheint mit einer Meldung.
- **Status:** fertig (03.11.2026, als D17)

### Schritt 8: Marv kommentiert neue Karten
- **Ziel:** Hat man eine Karte, die Marv noch nicht gesehen hat, spricht er einen darauf an („Ooooh, die hab ich noch nicht!“).
- **So testest du es:** Eine neue Karte aktivieren und in Kreuzweg zu Marv gehen.
- **Status:** fertig (03.11.2026, als D17)

### Schritt 9: Karten verbessern bis +10
- **Ziel:** Karten lassen sich bis +10 verbessern, mit einer doppelten Karte derselben Sorte plus etwas Gold. Bis +4 klappt es immer, ab +5 kann es misslingen. Jede Stufe stärkt den Besitzeffekt (und später den Sockel). Bei einem Fehlschlag bleibt die Karte auf ihrer Stufe, nur die doppelte Karte und das Gold sind weg. (Beschluss 27.10.)
- **So testest du es:** Eine Karte verbessern: Sie zeigt „+1“, der Bonus unter „Werte (C)“ steigt, eine doppelte Karte und etwas Gold sind weg. Ab +5 klappt es manchmal nicht.
- **Status:** fertig (03.11.2026, als D17)

## Projekt 9: Kreuzweg im Baukasten
_Aus Marcos Entscheidung vom 27.10.2026: Die Welt bleibt in Rautenansicht und wird aus Einzelbildern zusammengesetzt (Vorbild: Marcos Bild vom Kreuzweg-Marktplatz bei Nacht). Bild-Regeln in `data/BAUKASTEN.md`._

### Schritt 1: Baukasten-Testfeld
- **Ziel:** Ein kleiner Marktplatz aus Platzhalter-Bildern (Boden, Häuser, Stände, Statue, Torbogen, Brücke, Laternen, Bäume, Kleinkram). Man kann laufen, Häuser werden durchsichtig, wenn man dahinter steht, Laternen und Fackeln leuchten nachts. Welche Teile es gibt und wo sie stehen, steht in Datendateien, nicht im Code.
- **So testest du es:** Im Startmenü „Baukasten-Testfeld“: herumlaufen, über die Brücke gehen, hinter ein Haus laufen, mit N Tag und Nacht umschalten, mit G das Raster ansehen.
- **Status:** fertig (27.10.)

### Schritt 2: Echte Bilder einsetzen
- **Ziel:** Marcos Bildblätter (KI-Vorlagen nach `data/BAUKASTEN.md`) zuschneiden, verkleinern und die Platzhalter ersetzen.
- **So testest du es:** Im Testfeld sieht alles aus wie auf Marcos Bild, jedes Teil steht sauber auf seinem Feld (Raster mit G).
- **Status:** fertig (27.10.; 44 Teile aus 7 Bildblättern, Testfeld nach Kreuzweg aus design.md neu aufgebaut; dazu Splitterkreis, zwei Krater und Sternsplitter mit Umschalten der Geschichte per K)

### Schritt 3: Übergänge und Ufer
- **Ziel:** Weiche Übergänge zwischen Gras, Pflaster und Erde, Ufer am Wasser, damit der Boden nicht kariert wirkt.
- **So testest du es:** Im Testfeld an Straßenrand und Fluss entlanglaufen: keine harten Kanten mehr.
- **Status:** fertig (27.10.; ausgefranste Ränder nach Vorrang Gras > Erde > Pflaster > Platz > Wasser, Uferschatten im Wasser, dunkle Kachelränder entfernt)

### Schritt 4: Figuren in vier Richtungen
- **Ziel:** Vega (dann alle Figuren) läuft schräg nach oben und unten mit eigenen Bildern statt nur seitlich.
- **So testest du es:** Im Testfeld in alle Richtungen laufen: Vega schaut immer in Laufrichtung.
- **Status:** fertig für Vega im Testfeld (27.10.; 24 Bilder: Stehen und Laufen nach vorne und hinten, nach links gespiegelt; in der Kreuzweg-Demo und für andere Figuren noch nicht)

### Schritt 5: Kreuzweg aus dem Baukasten
- **Ziel:** Die echte Stadt Kreuzweg wird aus den Baukasten-Teilen aufgebaut (Plan nach design.md: Marktplatz, Gilde, Wegrast, Gesandten-Hof, Bingos Stand, sechstes Tor). Figuren, Aufträge und Geschichte bleiben, wie sie sind.
- **So testest du es:** Die Kreuzweg-Demo spielen: Alles ist wie vorher, sieht aber aus wie im Testfeld.
- **Entschieden (28.10.):** rund mit Ringstraße und sechs Toren. Norden: sechstes Tor hinter der Statue; Süden: Glutoase und Haupteingang; Westen: Grünwacht; Nordwesten Arkanum, Nordosten Nebelinseln, Osten Messinghafen (siehe design.md „Kreuzweg im Detail“).
- **Geändert (01.11.):** Die Tore folgen dem Kreis der Städte: Süden Glutoase, Westen Grünwacht, Nordwesten Nebelinseln, Norden Arkanum, Osten Messinghafen, Südosten sechstes Tor.
- **Status:** fertig (01.11.2026)

### Schritt 6: Grünwacht aus dem Baukasten
- **Ziel:** Weg nach Grünwacht, Waldboden, Wipfelheim und Pilzhöhle ebenso umstellen (braucht eigene Wald-Teile).
- **So testest du es:** Grünwacht durchspielen: alles wie vorher, im neuen Aussehen.
- **Status:** fertig (01.11.2026)

## Projekt 10: Oberfläche nach Marcos UI-Entwurf (27.10.)

Grundlage: Marcos Asterfall-UI-Set (zwei Bildblätter in `tools/vorlagen/ui/`) und der Entwurf mit Auftragsbuch, Tasche,
Werten, Zugleiste, Kampfmenü, Sieg-Fenster und Meldungen. Look überall eingebaut und Meldungen mit Rahmen: fertig (27.10.).

### Schritt 1: Kampf nach Entwurf
- **Ziel:** Zugleiste mit Bildern in Goldfeldern, Namensschilder mit Goldrahmen und Leisten aus dem Set, Kampfmenü links
  (Angriff, Fähigkeiten, Gegenstände, Verteidigen, Fliehen) neben den Fähigkeiten.
- **So testest du es:** Einen Kampf beginnen: „Angriff“ lässt gleich ein Ziel wählen, „Verteidigen“ wartet ab, „Gegenstände“ zeigt nur Tränke.
- **Status:** fertig (27.10.)

### Schritt 2: Sieg-Fenster und Gegenstands-Infofenster
- **Ziel:** Sieg-Fenster mit Banner, Belohnung mit Symbolen und goldenem Knopf; Infofenster beim Darüberfahren über einem Gegenstand.
- **So testest du es:** Einen Kampf gewinnen; in der Tasche mit der Maus über einen Gegenstand fahren.
- **Status:** fertig (27.10.)

### Schritt 3: Auftragsbuch, Werte und Tasche nach Entwurf
- **Ziel:** Auftragsbuch mit Liste links und Einzelheiten rechts (Häkchen, Belohnung), Werte mit Bild der Figur und Leisten,
  Tasche mit Gold und belegten Plätzen unten, Schnellleiste mit Symbolen, goldene und rote Knöpfe.
- **So testest du es:** J, C und I drücken und die drei Fenster ansehen.
- **Status:** fertig (27.10.; Reiter mit Gegenstandsarten in der Tasche fehlen noch, weil Gegenstände noch keine Art haben)

### Schritt 4: Teile vom Art Designer einsetzen
- **Ziel:** Element- und Fähigkeits-Symbole, Fliehen-Symbol, Bildlaufleiste, Trennlinie, Ruf-Leiste mit 10 Feldern,
  Weiter-Dreieck, Pergament-Sprechblase, Bilderrahmen und Auftrags-Bändchen einbauen (Prompt am 27.10. an Marco gegeben).
- **So testest du es:** Kampf, Werte (Ruf) und Auftragsbuch ansehen: überall die neuen Symbole.
- **Status:** fertig (27.10.; Gegenstandsarten-Symbole liegen bereit, Reiter in der Tasche erst, wenn Gegenstände eine Art haben)

## Projekt 11: Figuren wie bei Ragnarok (Kopf und Körper getrennt)
_Aus Marcos Entscheidung vom 28.10.2026: Spielfiguren werden aus Kopf und Körper zusammengesetzt. Jede Klasse hat einen männlichen und einen weiblichen Körper (Kleidung, Waffe, alle Bewegungen), der Kopf (Gesicht, Haut, Haare) liegt darüber und bleibt beim Klassenwechsel gleich. Erste Figur: Kofi._

### Schritt 1: Probe mit Kofi
- **Ziel:** Kofis fertige Bilder in Kopf und Körper zerlegen (Kopf pro Bild ausschneiden, Ankerpunkt am Hals merken) und im Spiel wieder zusammensetzen. Zeigt, ob das mit KI-Bildern sauber klappt, bevor neue Blätter bestellt werden.
- **So testest du es:** Im Editor bei „Figuren-Animationen“ Kofi ansehen: Er sieht aus wie vorher, Kopf und Körper sind aber getrennte Teile (Knopf „Bilder: ganz / aus Teilen / Standardkopf“).
- **Status:** fertig (28.10.2026: 46 von 49 Bildern getrennt, liegend und Parade-Anfang bleiben ganz)

### Schritt 2: Kopf-Blätter der sechs Novizen
_Am 28.10. geteilt: Kofis Kopf-Blatt kam zuerst._
- **Ziel:** Pro Novize ein Kopf-Blatt (Kopf schräg vorne, seitlich, schräg hinten; Gesichter normal, Schmerz, Freude, Augen zu). Prompt steht in Spieldesign/GRAFIK_AUFTRAG.md (B7).

#### Schritt 2a: Kofis Kopf-Blatt
- **Ziel:** Kofis Kopf-Blatt einbauen: Köpfe ausschneiden, in jedem Bild den Kopf finden und tauschen, Gesicht passend zur Bewegung (Schmerz beim Treffer, entschlossen beim Angriff, Freude beim Sieg, Augen zu bei Fähigkeit und Fallen).
- **So testest du es:** Editor → „Figur: Kofi“ → „Figuren-Animationen“ → Knopf auf „Bilder: neuer Kopf“: Kofi trägt die Köpfe aus dem Blatt.
- **Status:** fertig (28.10.2026)

#### Schritt 2b: Kopf-Blätter der anderen fünf Novizen
- **Ziel:** Die fünf übrigen Kopf-Blätter einbauen und im Editor zwischen den Köpfen wechseln (auf Kofis Körper).
- **So testest du es:** Im Editor zwischen den sechs Köpfen wechseln, der Körper bleibt gleich.
- **Status:** fertig (28.10.2026: alle sechs Köpfe da: m1 (Kofis Kopf), m2, m3, w1, w2, w3; bei „Figur erstellen“ je nach Geschlecht wählbar. Weitere Köpfe: Datei `tools/vorlagen/<kennung>_kopf.png`, Kennung in `WEITERE_KOEPFE` in `tools/kopf_koerper.py`, dann `tools/kopf_koerper.py` und `tools/koerper_blatt.py` laufen lassen.)

### Schritt 3: Novizen-Körper männlich und weiblich
- **Ziel:** Ein gemeinsamer Novizen-Körper je Geschlecht für alle sechs; Schal- und Schildfarbe färbt das Spiel pro Figur. Prompt: Spieldesign/GRAFIK_AUFTRAG.md (B8), Kopf als grünes Oval, keine Haut sichtbar.
- **So testest du es:** Alle sechs Novizen laufen und kämpfen mit demselben Körper, aber eigenem Kopf und eigener Farbe.
- **Status:** fertig (28.10.2026: beide Körper komplett, je drei Blätter; Kopf neigt sich mit. Einfärben entfällt: Marco hat entschieden, dass alle Novizen gleich aussehen.)

### Schritt 4: Körper der Grünwacht-Klassen
- **Ziel:** Bogenschütze und Monster-Zähmer, je männlich und weiblich. Beim Lernen der Klasse wechselt der Körper, der Kopf bleibt.
- **So testest du es:** In Grünwacht die Klasse lernen: Die Figur trägt danach die Klassenkleidung.
- **Status:** fertig (03.11.2026, als D18; Waffen folgen mit D18b. Früher: 29.10.2026: Prompts B9 in Spieldesign/GRAFIK_AUFTRAG.md bei Marco. Erster Bogenschützen-Versuch zu düster und realistisch, zweiter mit festem Kopf statt grünem Oval; Marco entscheidet: Kopf durch Oval ersetzen lassen oder als Grünwacht-NPC nehmen.)

### Schritt 5: Figur erstellen
- **Ziel:** Zu Spielbeginn Geschlecht wählen (daraus folgt der Körper), einen passenden Kopf (namenlos: m1, w1 …) wählen, Namen eingeben (design.md: „Charakter erstellen“). Später kommen Frisuren dazu (Ideen-Parkplatz).
- **So testest du es:** Neues Spiel: Figur zusammenstellen, sie läuft so durch Kreuzweg.
- **Status:** fertig (28.10.2026: Körper männlich/weiblich, Kopf blättern, Name; gespeichert im Spielstand. Wählbar sind die Köpfe, die es schon gibt: Novize m1 und Novizin w1, je nach Geschlecht. Frisuren kommen später.)

### Schritt 6: Körper der übrigen Klassen
- **Ziel:** Die übrigen neun Klassen je männlich und weiblich, Region für Region.
- **So testest du es:** Jede Klasse in der Kampf-Sandbox mit eigenem Körper ansehen.
- **Status:** offen

## Projekt 12: Grünwacht nachbessern (Beschluss 29.10.)

### Schritt 1: Zähmer lernt bei Tilda, Esche gibt das erste Monster
- **Ziel:** Nach der Klassenwahl führt der Auftrag zu Rudelmeisterin Tilda, sie lehrt das Zähmen und schickt einen zu Professor Esche. Dort wählt man das erste Monster (Glutwelpe, Moosling oder Bachotter).
- **So testest du es:** Neu beginnen, Monster-Zähmer wählen, dem Wegweiser zu Tilda folgen, danach zu Esche, das Monster wählen und als Zähmer kämpfen.
- **Status:** fertig (02.11.2026)

## Projekt 13: Aussehen nach Variante C „Ragnarok plus“ (Beschluss 29.10.)

### Schritt 0: Im Stil bleiben (kommt vor allem anderen)
- **Ziel:** LOOK.md als einzige Quelle für den Look (Farbpalette, Figurgröße in Pixeln, Umrisslinie, Licht von oben links, Schattenstufen, Blickwinkel), die Farbpalette als Datei mit automatischer Prüfung jedes neuen Bildes, ein Ordner mit zwei bis drei Referenzbildern, die Marco abnimmt, ein fester Stil-Block, der wörtlich in jeden Bild-Prompt kommt, eine immer gleiche Nachbearbeitung für KI-Bilder (Größe, Palette, Umriss) und vor jedem Einbauen ein Vergleichsbild für Marcos Abnahme. Ohne Marcos Ja kommt kein Bild ins Spiel.
- **So testest du es:** LOOK.md lesen, ein Testbild mit falschen Farben einbauen lassen, die Prüfung meldet es, und das Vergleichsbild erscheint vor dem Einbauen.
- **Status:** fertig (01.11.2026: LOOK.md, `data/look_palette.json`, `tools/look_pruefen.py` mit pruefen/nachbearbeiten/vergleich/palette, Referenzbilder in `tools/referenz/`: Vega, Gilde und Moosling, von Marco am 01.11. abgenommen; Stil bleibt wie jetzt. Dazu MONSTER.md und NPC.md angelegt, Fahrplan Schritt 0.2.)

### Schritt 1: Regeln festschreiben
- **Ziel:** Den Stil-Block in GRAFIK_AUFTRAG.md erweitern: Körper ohne Waffe (Hand greift ins Leere), Köpfe ohne Hut und gleich groß, feste Farbflächen (Hauptfarbe, Zweitfarbe, Metall, Leder, Haut) mit wenigen festen Farbtönen, Platz am Rücken.
- **So testest du es:** GRAFIK_AUFTRAG.md lesen, die Regeln stehen verständlich drin.
- **Status:** fertig (02.11.2026: Entwurf „FIGUREN“ in LOOK.md Abschnitt 9a; kommt nach Marcos Ja wörtlich in den Stil-Block von LOOK.md und GRAFIK_AUFTRAG.md Teil A)

### Schritt 2: Vorhandene Bilder prüfen
- **Ziel:** Sind Waffen in die Novizen-Körper und Kofis Bilder eingemalt? Passen die Farbflächen? Kurze Liste, was neu gezeichnet oder angepasst werden muss (der Schild der Novizen bleibt am Körper).
- **So testest du es:** Die Liste lesen.
- **Status:** fertig (02.11.2026: Liste in LOOK.md Abschnitt 12. Neu zeichnen muss Marco nur die fünf fehlenden Novizen-Blätter ohne Klinge, den Rest räumt Claude beim Einbauen auf.)

### Schritt 3: Waffe als eigenes Teil
- **Ziel:** Pro Bild ein Handpunkt, die Waffe hängt dort und bewegt sich mit. Probe mit dem Kurzschwert des Novizen.
- **So testest du es:** Mit dem Novizen laufen und kämpfen, das Schwert sitzt immer in der Hand.
- **Status:** fertig (02.11.2026: Novizen-Körper kommen aus Marcos Blättern ohne Klinge. `griff` und `waffe_winkel` je Bild in `data/figurteile.json` (`tools/waffe_punkte.py`), Klinge und Parierstange als Bild in `assets/teile/waffe/` (`tools/aussehen_bilder.py`), der gemalte Griff bleibt in der Hand. Beim Wirken ist kein Schwert zu sehen. Wanderhut und Reiseumhang sind jetzt Marcos Bilder, der Umhang weht im Laufen. Waffen-Aussehen wählbar: Kurzschwert und Krummklinge.)

### Schritt 4: Kopfbedeckung und Rückenteil als Schichten
- **Ziel:** Ein Probe-Hut über dem Kopf, ein Probe-Umhang hinter dem Körper.
- **So testest du es:** Hut und Umhang an- und ablegen, beide sitzen in allen Richtungen und Bewegungen richtig.
- **Status:** fertig (02.11.2026: Hut wird auf den Kopf gesetzt und neigt sich mit, Rückenteil hängt am Hals, von hinten liegt es über dem Körper, beim Liegen ist es nicht zu sehen. Teile in `data/aussehen_teile.json`, Bilder in `assets/teile/hut/` und `assets/teile/ruecken/`. Wanderhut und Reiseumhang waren zuerst Platzhalter, seit D2b sind es Marcos Blätter.)

### Schritt 5: Umfärben
- **Ziel:** Das Spiel tauscht die festen Farbtöne eines Klassen-Körpers gegen eine andere Palette (Probe: Set der Vulkanschmiede in Glutrot und Schwarz). Novizen werden nicht umgefärbt.
- **So testest du es:** Im Editor eine Farbpalette wählen, der Körper färbt sich sauber um.
- **Status:** fertig (02.11.2026: Paletten in `data/farbpaletten.json` (Glutrot und Schwarz für die Vulkanschmiede, dazu Waldgrün als zweite Probe). Probe an den Platzhaltern Hut und Umhang, weil es noch keinen Klassen-Körper nach den neuen Regeln gibt. Klassen-Körper werden umgefärbt, sobald sie in `data/figurteile.json` ihre Farbflächen (`_flaechen`) haben. Novizen-Körper haben keine und bleiben, wie sie sind.)

### Schritt 6: Aussehen-Plätze
- **Ziel:** Werte und Aussehen getrennt, ein Fenster zum Auswählen von Hut, Rückenteil und Waffen-Aussehen, im Spielstand gespeichert.
- **So testest du es:** Ein anderes Aussehen wählen, die Werte bleiben gleich, nach dem Neustart ist das Aussehen noch da.
- **Status:** fertig (02.11.2026: Im Werte-Fenster (C) gibt es „Aussehen“ mit Hut, Rücken und Farben, nur für Figuren aus „Figur erstellen“. Das Aussehen hängt am Namen der Figur (`novize_w+mira#hut=…,ruecken=…,farben=…`), kommt so in Welt, Kampf, zu Mitspielern und in den Spielstand. Befehl `aussehen` in WorldState. Das Waffen-Aussehen kam mit der Waffe als eigenem Teil (D2b).)

### Testtag Aussehen
- Marco prüft, ob alles einheitlich aussieht. Erst danach werden die Klassen-Körper nach den neuen Regeln gezeichnet (Projekt 11, Schritte 4 und 6, Bogenschütze neu).

## Später (wartet auf andere Teile des Spiels)
- Kobalt bekommt einen eigenen Körper (bis dahin der des Zähmers, Marco 04.11.)
- Taschen vom Schneider und Lagerfeuer-Essen (brauchen Berufe)
- Marktstand-Gebühr (braucht den Markt)
- Schriftrollen (auch „Licht im Dunkeln“, beschlossen 28.10.), Wiederbelebungs-Rolle und besondere Munition
- Testversion bis Stufe 20 mit Kauf (braucht Online-Konten)
- Sternen-Glanz und Siegel-Zähler (braucht den Server)
- Erste eigene Grafiken (wartet auf die Look-Bibel aus Thema 12)
- Nachts geschlossene Läden und andere NPCs (Erweiterung von Tag und Nacht, Projekt 7)
- Monsterkarten sockeln (braucht die Ausrüstung) und Karten mit Freunden tauschen (braucht den Server)
