# Fortschritt

Hier steht, was fertig ist, was als Nächstes kommt und welche Fragen offen sind.
Wird nach jedem Arbeitsschritt aktualisiert.

## Aktueller Stand (2026-10-27, ergänzt 11.11.)

- **Stand 11.11.2026 (nach dem Grafik-Block):** Alle Bilder aus `Spieldesign/GRAFIK_AUFTRAG.md` Teil K (Nachbesserungen) und Teil L (Fähigkeiten der fünf Demo-Klassen und des Novizen) sind eingebaut und online. Offen bei den Bildern: Teil H (Klassenbilder, Bauauftrag A3b), Teil J (Häuser von hinten, S4a2), Teil I (Sitzen und Laufen, S6, ganz am Ende); die Übersicht steht oben in `GRAFIK_AUFTRAG.md`. **Nächster Bauauftrag:** Die Alpha-Aufträge sind fertig (A3b, A10b, A13b warten auf deine Bilder). E4 (Balancing) kommt später (Marco, 11.11.: braucht viele Tests), dann E5 (T3 und T4 am Stück); neu für dich: Teil M bis Q in `GRAFIK_AUFTRAG.md` (neu: A16 Novizen-Fähigkeiten nach der Klassenwahl behalten), dann E4 und E5.
- **Bilder von Marco (02.11. abends):** 38 Blätter liegen unter `tools/vorlagen/`: alle sechs Novizen-Blätter ohne Klinge, Kurzschwert, Probe-Hut, Probe-Umhang, Waffen und Rückenteile der Klassen, Körper der fünf Klassen.
  - Dazu der Baukasten (02.11.): acht Grundkörper (`grund_*.png`), Köpfe (`koepfe_*.png`), Hüte (`huete_regionen.png`), Zeichen (`zeichen_dienste.png`) und die Klingentänzerin Blatt 1. Bei den Fäusten der Abwehr-Bilder von Blatt 1 prüft Claude beim Einbauen, ob sie am Oval stören.
  - Dazu Figuren 4 und 5 (02.11.): 22 Blätter Nebenfiguren (`neben_*.png`) und 42 Blätter Hauptfiguren (`haupt_*.png`) aller drei Städte, damit ist Teil D vollständig. `neben_reserve_rashid_tarek.png` ist ein doppeltes Sammelblatt und bleibt Reserve.
  - Beim Einbauen behebt Claude: Hintergrund raus bei `haupt_ilwen_portraets`, `haupt_brakkus_portraets`, `haupt_hadrak_welt`, `haupt_ren_kampf_a` und `haupt_ysolde_welt` (Probe klappt, dazu kleine weiße Reste in Lücken der Haare), Köpfe von `neben_zaid` und `neben_rashid` auf die gleiche Größe bringen. Zaid trägt den Turban schon am Kopf, das Zubehör-Teil entfällt bei ihm. Bei `haupt_ren_kampf_b` hat Reihe 3 ein Bild zu viel (Fähigkeit wirken 5 statt 4).
  - Zusatz „FIGUREN“ für den Stil-Block: von Marco bestätigt (02.11.), steht in `LOOK.md`, `GRAFIK_AUFTRAG.md` Teil A und im ChatGPT-Projekt.

- **Neu (10.11.): Köpfe von Layla, Nadia, Hanne, Lene, Salbei und Lotte schauen nach vorne** (Alpha 19–21, GRAFIK_AUFTRAG.md K1): Wirtin Layla, Brunnenhüterin Nadia, Wirtin Hanne (rote Locken, gestreiftes Kopftuch), Schreiberin Lene (Brille, Feder), Kräuterhändlerin Salbei (Blüten im Haar) und Lotte (Zöpfe mit Schleifen) haben neue Köpfe von vorne, die in dieselbe Richtung schauen wie ihr Körper. Das Spiel dreht Köpfe von vorne jetzt selbst passend zum Körper (nur der Frauen-Körper schaut nach links), das gilt auch für die Köpfe der Leute im Dorf. Die Frauen und das Mädchen aus dem Volk (v_w1–3, a_w1–2, k_w1) haben ebenfalls neue Köpfe von vorne mit Blinzeln. Neuer Baukasten-Körper „Frau, korpulent“ (GRAFIK_AUFTRAG.md K1c): Kräuterhändlerin Salbei in Wipfelheim trägt ihn jetzt (Kleid mit Kräutern, grünes Tuch, Gürteltasche), auch im Stadt-Editor wählbar. Zielscheiben im Kampf (GRAFIK_AUFTRAG.md K2): Fenns Prüfung (und die Prüfungen von Brakkus, Samira und Xavina) zeigen echte Strohscheiben auf dem Holzgestell und die laufende Scheibe auf dem Schlitten; getroffen steckt ein Pfeil darin, besiegt kippen sie um. Beute-Symbole der Aschensteppe und Palmenrast (K3a): Echsenschuppe, Sonnenmähne, Struppiges Fell, Trockenzweig, Kaktusblüte, Aschefell, Schwarzer Panzer, Wurmhaut, Feuerschuppe, Blitzglas, Oasenschleim und Geisterstaub haben gemalte Bilder in der Tasche. Ebenso die Beute von Glutgrat und Vulkanschmiede (K3b, 15 Symbole von Schakalfell bis Messingzahnrad) und der Kreuzwegfelder (K3c, 7 Symbole von Schleimklecks bis Splitter der Schleimkrone) und von Hirschtal und Wachtwald (K3d, 13 Symbole von Borsten bis Krötenstein) und von Tiefwurzel und Pilzhöhle (K3e, 13 Symbole von Sporenkappe bis Goldspore). Die Ausrüstung hat ebenfalls gemalte Bilder in der Tasche und auf den Ausrüstungs-Plätzen im Werte-Fenster (K3f, 13 Symbole von Kurzschwert bis Kettenglut-Stiefel). Der Bogenschütze hat gemalte Fähigkeiten-Bilder im Fähigkeiten-Baum und auf den Kampf-Knöpfen statt Anfangsbuchstaben (L1), ebenso der Monster-Zähmer (L2) , der Rüstungsschmied (L3), die Klingentänzerin (L4), die Sternensängerin (L5) und der Novize (L6, auf den Kampf-Knöpfen), dazu Blinzeln. Neues Werkzeug `tools/koepfe_vorn.py` für die übrigen Frauen-Köpfe (Blätter `kopf_vorn_<figur>.png`).
  - **So testest du es:**
    1. In der Glutoase zur Glutstube gehen: Laylas Gesicht und Körper schauen in dieselbe Richtung.
    2. Kurz warten: Sie blinzelt.
    3. Nachts wiederkommen: Sie schenkt Hadrak nach, der Kopf sitzt auch dann richtig.
    4. Zum Brunnen gehen: Nadia schaut ebenfalls in Körper-Richtung.

- **Neu (10.11.): Vogt Edmar mit Festschärpe** (Rest aus D20c2, GRAFIK_AUFTRAG.md B6j): Edmar läuft jetzt mit deinem eigenen Welt-Blatt (`haupt_edmar_welt.png`) statt mit Baukasten-Körper: Amtskette und Festschärpe in den fünf Farben der Regionen. Porträts bleiben.
  - **So testest du es:**
    1. Tagsüber in Kreuzweg zur Festbühne gehen: Edmar mit bunter Schärpe und Amtskette.
    2. Um ihn herumlaufen: Die Schärpe ist auch von hinten zu sehen.
    3. Mit ihm sprechen: Gespräch geht wie vorher.

- **Neu (10.11.): Bankhüterin Ilse mit Ärmelschonern** (Rest aus D20c2, GRAFIK_AUFTRAG.md B6i): Ilse läuft jetzt mit deinem eigenen Welt-Blatt (`haupt_ilse_welt.png`) statt mit Baukasten-Körper: Ärmelschoner und Schlüsselbund am Gürtel. Porträts bleiben.
  - **So testest du es:**
    1. In Kreuzweg in die Bank gehen: Ilse mit Ärmelschonern und Schlüsselbund.
    2. Um sie herumlaufen: Sie sieht von hinten aus wie von vorne.
    3. Etwas in die Bank legen: geht wie vorher.

- **Neu (10.11.): Hutmacher Hatta als eigene Figur** (Rest aus D20a, GRAFIK_AUFTRAG.md B6h): Hatta läuft jetzt mit deinem eigenen Welt-Blatt (`haupt_hatta_welt.png`) statt mit Baukasten-Körper, Kopf und Zylinder als Einzelteilen: Weste, gelbes Maßband um den Hals, der riesige Zylinder wird nicht mehr oben abgeschnitten und sitzt von hinten richtig. Dazu fünf Porträts im Gespräch (ruhig, lächelnd, wütend, traurig, überrascht), vorher hatte er keine.
  - **So testest du es:**
    1. In Kreuzweg zu Hatta neben Bingos Stand gehen: Zylinder ganz zu sehen, Maßband um den Hals.
    2. Um ihn herumlaufen: Von hinten sitzt der Zylinder auf dem Kopf.
    3. Mit ihm Hüte tauschen: geht wie vorher, im Gespräch ist sein Bild zu sehen.

- **Neu (10.11.): Oma Hagebutte mit Strickjacke** (Rest aus D21, GRAFIK_AUFTRAG.md B6g): Hagebutte läuft jetzt mit deinem eigenen Welt-Blatt (`haupt_hagebutte_welt.png`) statt mit Baukasten-Körper: moosgrüne Strickjacke, braunes Kleid, Karten in der Hand. Der Kartenstapel sitzt von hinten nicht mehr auf dem Rücken. Porträts bleiben.
  - **So testest du es:**
    1. In Wipfelheim zu Oma Hagebutte gehen: Sie trägt die grüne Strickjacke.
    2. Um sie herumlaufen: Von hinten keine Karten am Rücken.
    3. Nachts beim Gasthaus nachsehen: Dort steht sie genauso.

- **Neu (10.11.): Zaid mit Reiseumhang** (Rest aus D27, GRAFIK_AUFTRAG.md B6f): Karawanenführer Zaid läuft jetzt mit deinem eigenen Welt-Blatt (`haupt_zaid_welt.png`) statt mit Baukasten-Körper und Kopf, mit sandgelbem Umhang und rotem Saum. Ein einzelner Umhang auf dem Händler-Körper saß nicht sauber, darum ist er ganz neu gemalt. Dazu fünf neue Porträts im Gespräch (ruhig, lächelnd, wütend, traurig, überrascht) passend zum neuen Gesicht.
  - **So testest du es:**
    1. In der Stadt Glutoase zum Karawanenplatz gehen: Zaid steht dort mit Umhang.
    2. Um ihn herumlaufen: Von hinten bedeckt der Umhang den Rücken.
    3. Mit ihm sprechen: Gespräch geht wie vorher.

- **Neu (09.11.): Monster der Kreuzwegfelder mit eigenen Blättern** (Alpha-Feedback Nr. 44): Tauschleim, Kronenschleim, Wiesenhoppler, Knollenkäfer, Schattenskarabäus, Glimmerkäfer, Löwenzahnling, Kaktusling, Stachelflitzer, Glutigel und Funkenflirr haben jetzt deine vollständigen Bilder statt der umgefärbten Familien. Die Familie Schwärme ist raus, der Funkenflirr ist ein einzelnes fliegendes Insekt. Dazu (09.11.) aus der Aschensteppe und Palmenrast: Steppenhyäne (Mähne sitzt jetzt), Funkenechse, Steppenroller, Aschefuchs, Sonnenlöwe, Sandwurm, Feuerechse, Oasenkröte, Glasskorpion, Staubgeist und Mondschakal. Dazu (09.11.) Glutgrat und Vulkanschmiede: Schlackenbock, Glutsalamander, Rauchgeier, Geysirkrabbe, Glutfledermaus, Obsidiangolem, Gewitterwyvern, Schlackenkriecher, Glutgeist, Ambossknecht, Aschefalter, Magmaschnecke und Messingwächter. Damit hat jedes Monster der Glutoase sein eigenes Blatt. Dazu (10.11.) Hirschtal und Wachtwald: Borstenkeiler, Dornenranke, Bachkrebs, Zankelster, Heulwolf, Irrlicht, Kronhirsch, Rindenbär, Windfalke, Steinkröte, Sporenling, Nachtuhu, Funkenmarder und Wipfelluchs. Dazu (10.11.) Tiefwurzel und Pilzhöhle: Donnerhirsch, Sumpfschnapper, Moosgolem, Rankenschlinger, Splitterwolf, Moderfalter, Splitterbär, Leuchtmotte, Wurzelkriecher, Sporenwolf und Schatzpilzling. Damit hat auch jedes Monster von Grünwacht sein eigenes Blatt. Dazu (10.11.) die Nebenfiguren: der Wilde Bienenschwarm (jetzt eine einzelne wütende Biene) und die Splitter-Knoten der Wurzelmutter, die beim Nachwachsen sichtbar wieder hochwachsen. Als Nächstes nur noch die alten Familien-Bilder aufräumen.
  - **So testest du es:**
    1. Auf den Kreuzwegfeldern einen Tauschleim oder Wiesenhoppler angreifen: Das Monster sieht in jeder Bewegung gleich aus.
    2. Einen Kronenschleim suchen und seine besondere Bewegung abwarten: Er wirft die Krone.
    3. Nachts einen Funkenflirr angreifen: ein einzelnes Glühwürmchen statt eines Schwarms.
    4. In der Aschensteppe eine Steppenhyäne angreifen: Die Mähne bleibt in jeder Bewegung am Rücken.
    5. In der Palmenrast Sandwurm und Oasenkröte ansehen, nachts den Mondschakal.
    6. Auf dem Glutgrat Schlackenbock und Rauchgeier angreifen, in der Vulkanschmiede Ambossknecht und Magmaschnecke.
    7. Im Hirschtal Borstenkeiler und Heulwolf angreifen, nachts das Irrlicht: Es wird bei „Erlöschen“ immer kleiner.
    8. Im Wachtwald Rindenbär und Sporenling ansehen, den seltenen Wipfelluchs suchen.
    9. In Tiefwurzel Moosgolem und Sumpfschnapper angreifen: Der Sumpfschnapper zieht sich bei „Panzerrückzug“ ganz in den Panzer zurück.
    10. In der Pilzhöhle den Wurzelkriecher abwarten: Er gräbt sich bei „Durch den Boden“ ein, nur ein Erdhügel bleibt.
    11. Beim Bienenstock in Grünwacht näher herangehen: Es kommen zwei wütende Bienen statt der alten Ersatzbilder.
    12. Bei der Wurzelmutter einen Knoten zerstören und den anderen stehen lassen: Der zerstörte wächst sichtbar aus dem Stumpf nach.

- **Nächster Schritt (11.11.):** E4 später (viele Tests), E5 und S6 am Ende von oben nach unten (A3b wartet auf deine Klassenbilder), danach E4 (Balancing), E5 (T3 und T4 am Stück) und S6 (Sitzen und Laufen, wartet auf Bilder). Offen von S1: dein Google-Formular verbinden.

- **Neu (11.11.): Bildaufträge für die sechs späteren Klassen** (`Spieldesign/GRAFIK_AUFTRAG.md` Teil R, nicht eilig, nach der Demo):
  - R1: je Klasse ein Blatt Fähigkeiten-Symbole (Runenwächter, Mechaniker mit Roboter, Zwielicht-Wandler, Ritualist, Quartiermeister, Kunoichi). Sobald ein Blatt zugeschnitten ist (`tools/faehigkeit_bilder.py <klasse>`), zeigen die Kampfknöpfe die Bilder.
  - R2: je Klasse männlich und weiblich drei Körper-Blätter (zwei Kampf, eins Welt), nach demselben Muster wie bei den Demo-Klassen. Roboter, Karren und Waffen kommen später als eigene Blätter.
  - Die Anhänge liegen in `tools/referenz/teil_r/` (Novizen-Blätter ohne Schwert, Vega, zwei fertige Symbol-Blätter als Stil).

- **Neu (11.11.): A19 Die Stadtwachen verlangen das Empfehlungsschreiben** (design.md: Novizen kommen ohne nicht in die Städte):
  - An den Eingängen von der Straße (Aschensteppe und Dürrewald in die Glutoase, Seilaufzug nach Wipfelheim) prüft die Stadtwache Ye's Schreiben. Beim ersten Mal: „Die Stadtwache wirft einen Blick auf Yes Empfehlungsschreiben und winkt dich hinein.“
  - Ohne Schreiben: „Halt! Ohne Empfehlungsschreiben kommen Novizen nicht in die Stadt. Lene in der Gilde von Kreuzweg stellt dir eins aus.“ Lene schreibt dann ein neues.
  - Auf dem Rückweg aus den Gebieten einer Stadt (Glutgrat, Vulkanschmiede, Palmenrast) und aus Gasthäusern fragt niemand.
  - Alte Spielstände, die sich schon von Ye verabschiedet haben, und der Spielstand-Editor geben das Schreiben von selbst, damit niemand festsitzt.
  - **So testest du es:**
    1. Bei Ye den Abschied nehmen, durch die Aschensteppe zur Glutoase: Die Wache winkt dich hinein.
    2. Im Werkstatt-Editor das Empfehlungsschreiben aus der Tasche wegwerfen und wieder zur Glutoase: Die Wache hält dich auf.
    3. Zu Lene in die Gilde: Sie schreibt dir ein neues.

- **Neu (11.11.): A18 Web-Version geprüft und kleiner** (deine Wahl):
  - Gemessen an einem eigenen Web-Export wie auf GitHub: Das Spielpaket war seit D36 von 73 auf 80,7 MB gewachsen (die vielen neuen Monster, Effekte und Karten). Zwei Drittel davon sind die gemalten Figuren.
  - Figuren und Figurteile werden jetzt etwas stärker gepackt (Qualität 0,7 statt 0,8). Weil das Spiel sie auf ein Drittel verkleinert zeigt, sieht man keinen Unterschied (im Spiel weichen die Farben im Schnitt um 2,4 statt 2,1 von 255 ab). Das Paket ist jetzt 74,5 MB.
  - Beim ersten Start lädt der Browser damit rund 85 MB (Spielpaket und Godot, das GitHub gepackt schickt), mit guter Leitung etwa 10 bis 20 Sekunden, im Mobilfunk deutlich länger.
  - Alle Figuren-Bilder werden benutzt, es gab nichts zu streichen.
  - **Für später (Marco, 11.11.: nach der Demo):** Die Figuren sind dreimal so groß gespeichert, wie das Spiel sie zeigt. Auf zwei Drittel verkleinert würde das Paket noch etwa 20 MB kleiner (rund 55 MB). Steht als N2 in BAUAUFTRAEGE.md unter „Nach der Demo“.
  - **So testest du es:** Die Demo im Browser öffnen und die Ladezeit beobachten; im Kampf und in der Welt sehen die Figuren aus wie vorher.

- **Neu (11.11.): A17 Nachts im Gasthaus:**
  - Marv, Tessa und Gorm sind nachts jetzt drinnen im Wegrast (vorher standen sie davor). Morgens sind sie wieder draußen.
  - Stehst du in einem Gasthaus, wenn es 21 Uhr oder Morgen wird, kommen und gehen die Gäste sofort (vorher erst nach dem Hinausgehen). Gilt auch für Hadrak in der Glutstube.
  - **So testest du es:**
    1. Nach 21 Uhr in Kreuzweg ins Wegrast: Marv, Tessa und Gorm sitzen drinnen bei Hanne.
    2. Im Wegrast warten, bis es 6 Uhr wird (oder im Werkstatt-Editor die Uhr stellen): Die Nachtgäste gehen, Marv, Tessa und Gorm sind wieder draußen.

- **Neu (11.11.): A16 Novizen-Fähigkeiten nach der Klassenwahl behalten** (dein Beschluss vom 11.11.):
  - Im Fähigkeiten-Baum (K) steht jetzt oben die Reihe „Novize (von Ye)“ mit allem, was du bei Ye gelernt hast: Schildstoß, Doppelschlag, Erste Hilfe, Deckung geben. Sie sind schon gelernt und kosten keine Punkte. Antippen zeigt die Beschreibung und „Auf die Leiste“.
  - Was auf der Leiste liegt, kannst du im Kampf als Klasse benutzen, mit den gemalten Novizen-Bildern auf den Knöpfen. Sie wirken wie beim Novizen und werden mit deiner Stärke besser. Der Hieb bleibt beim Novizen, jede Klasse hat ihren eigenen Grundangriff.
  - So hatte es der Bauauftrag vorgeschlagen; willst du es anders (z. B. immer da, ohne Leiste), sag Bescheid.
  - **So testest du es:**
    1. Mit dem Spielstand-Editor eine Klasse nehmen (z. B. Bogenschütze, nach dem Lernen beim Lehrmeister) und K drücken: Oben steht die Reihe „Novize (von Ye)“.
    2. Schildstoß antippen, „Auf die Leiste“: Er liegt auf einem der sechs Plätze, das Feld zeigt „Leiste“.
    3. Ein Monster angreifen: Schildstoß ist als Knopf da und schiebt den Gegner auf der Zugleiste zurück.
    4. Schildstoß wieder von der Leiste nehmen: Im nächsten Kampf ist er nicht mehr da.

- **Neu (11.11.): A15 Nachgeholt vom 21.10.** (Beschlüsse aus design.md, die nie ins Spiel kamen):
  - **Ein Brief vom Tor** (Nebenauftrag): Nach dem Essenskorb bittet Torwache Brom dich, einen Brief zu Wirtin Hanne ins Wegrast zu bringen („Ein Liebesbrief?“ – „Ein … Dienstschreiben. Nicht lesen!“). Hanne schickt eine Antwort zurück, Brom freut sich. 10 Bronze und 60 Erfahrung.
  - **Sternenschlund:** Der Sternenfresser kündigt ihn einen Zug vorher an („Nur eine PERFEKTE Parade rettet dich!“). Er trifft einen Spieler, nie Tessa oder Gorm; wer ihn nicht perfekt pariert, ist sofort besiegt. Der Splitter explodiert jetzt nach 8 statt 10 Zügen. Seine anderen Treffer bleiben so tödlich wie seit dem 22.10. (normal pariert bleibt ein Rest Leben).
  - **Empfehlungsschreiben:** Ye gibt es dir beim Abschied („Ohne das lassen dich die Stadtwachen nicht hinein. Novizen gibt es viele.“). Es liegt in der Tasche; dass die Wachen es wirklich verlangen, kommt später.
  - Die beiden neuen Gegenstände sind noch gezeichnete Tafeln, die Bilder stehen in `Spieldesign/GRAFIK_AUFTRAG.md` Teil Q.
  - **So testest du es:**
    1. Den Korb zu Brom bringen, ihn noch einmal ansprechen: Er bittet um den Brief.
    2. Den Brief zu Hanne ins Wegrast bringen, dann zurück zu Brom: Auftrag abgeschlossen.
    3. In der Festnacht gegen den Sternenfresser: Über ihm steht vorher „Sternenschlund“, nur eine perfekte Parade rettet dich; „EXPLOSION in 8 Zügen“.
    4. Bei Ye den Abschied nehmen: Das Empfehlungsschreiben liegt danach in der Tasche (I).

- **Neu (11.11.): A14 Kreuzwegfelder als eigenes Gebiet** (Marco, 10.11.):
  - Durch das Südtor kommst du jetzt auf die Kreuzwegfelder: Wiesen mit Feldwegen, Zäunen, Heuballen, einem Bach mit Steg und einem Wegweiser. Vom Trainingsplatz der Gilde führt ein Seitentor (Westrand, neben der Gilde) auf die Felder. Unten geht es weiter in die Aschensteppe.
  - Das Südtor ist offen, sobald du dich bei Lene in der Gilde angemeldet hast; weiter in die Aschensteppe geht es wie bisher erst nach der Klassenwahl.
  - Monster nach Steckbrief (Stufe 1–8): nah an der Stadt Tauschleime und Wiesenhoppler, hinter dem Bach Knollenkäfer und Löwenzahnlinge, nachts Funkenflirr und Glutigel, ganz hinten selten der Kronenschleim. Alle sieben haben jetzt eine Karte, die Kreuzweg-Seite im Album hat 14 Plätze.
  - Auf der großen Karte liegen die Felder unter Kreuzweg, der Weg in die Glutoase führt über sie.
  - **So testest du es:**
    1. Neu beginnen, bei Lene anmelden, dann durch das Südtor: Du stehst auf den Kreuzwegfeldern.
    2. Einen Tauschleim nahe der Stadt angreifen (Stufe 1), dann über den Steg: Dort sind die Käfer und Löwenzahnlinge stärker.
    3. Zurück, auf dem Trainingsplatz hinter der Gilde zum Seitentor am Westrand: Es führt ebenfalls auf die Felder.
    4. Nachts (nach 21 Uhr) noch einmal hinaus: Funkenflirr und Glutigel sind unterwegs.
    5. Ganz unten auf den Feldern: Vor der Klassenwahl geht es nicht weiter, danach in die Aschensteppe.

- **Neu (11.11.): A13a Dürrewald zwischen Glutoase und Grünwacht** (Alpha-Punkte 51 und 52):
  - Das Tor zum Dürrewald am Westrand der Oase ist offen. Dahinter liegt ein langes Gebiet: unten Sand, Kakteen und Felsen, in der Mitte Steppengras mit ersten Bäumen, oben lichter Wald. Am Nordende geht es nach Tiefwurzel (dort ist unten ein neuer Pfad).
  - Monster aus Steppe und Wald gemischt: Steppenhyäne, Staubgeist, Sonnenlöwe im Süden, Heulwolf, Dornenranke, Rindenbär, Windfalke im Norden, nachts Aschefuchs, Mondschakal und Nachtuhu. Stufe 18 bis 20 (die Demo endet bei 20; Grünwacht auf 20–25 heben gehört zu E4). Kämpfe im Süden zeigen die Steppe, im Norden den Wald.
  - Der Heimweg „Zurück nach Grünwacht“ führt jetzt hier entlang (der Wegweiser nimmt den kürzeren Weg); der alte Weg über Kreuzweg geht weiter.
  - A13b: Die harten Kanten zwischen Sand, Gras und Wald werden mit neuen Übergangsböden weicher. Die Bildaufträge stehen in `Spieldesign/GRAFIK_AUFTRAG.md` Teil P (Böden, Pflanzen und ein Grenzstein).
  - **So testest du es:**
    1. Mit dem Spielstand-Editor in die Glutoase, ganz links am Westrand zum Tor zum Dürrewald: Es öffnet sich.
    2. Nach Norden laufen: Der Sand wird zu Gras und dann zu Wald, die Monster wechseln mit.
    3. Ein Monster im Süden und eins im Norden angreifen: unterschiedliche Kampf-Hintergründe.
    4. Oben durch den Ausgang: Du kommst in Tiefwurzel an. M drücken: Der Dürrewald liegt zwischen Glutoase und Grünwacht.

- **Neu (11.11.): A12c Gasthaus Glutstube in der Glutoase betreten** (Alpha-Punkt 47, damit hat jede Stadt ihr Gasthaus):
  - Die Tür ist an der rechten Seite der Glutstube beim großen Torbogen (unten in der Oase). Hingehen bringt dich hinein, Vorbeilaufen nicht.
  - Drinnen steht Wirtin Layla hinter der Theke, ein Gast sitzt tagsüber am Feuer, abends zwei mehr. Nachts trinkt Hadrak drinnen statt vor dem Haus (Figuren können jetzt nachts in einen Innenraum wechseln).
  - Der Raum ist aus vorhandenen Teilen gebaut (Terrassenkanten als Wände, Fässer und Tonkrüge, Lagerfeuer, Teppiche, Tanzlaternen). Die gemalten Teile stehen in `Spieldesign/GRAFIK_AUFTRAG.md` Teil O (Blätter IN5 und IN6).
  - **So testest du es:**
    1. Mit dem Spielstand-Editor in die Glutoase, unten rechts zur Glutstube.
    2. An der rechten Seite zur Tür gehen: Du bist in der Glutstube, Layla steht hinter der Theke.
    3. Nachts (nach 21 Uhr) hinein: Hadrak sitzt in der Ecke und trinkt, Layla erzählt von ihm.
    4. Über „Hinaus“ zurück in die Glutoase.

- **Neu (11.11.): A12b Baumhaus-Gasthaus in Wipfelheim betreten** (Alpha-Punkt 47):
  - Die Tür ist an der rechten Seite des Baumhaus-Gasthauses bei den Stufen. Wie beim Wegrast: Hingehen bringt dich hinein, Vorbeilaufen nicht; hat drinnen jemand etwas für dich, steht „!“ oder „?“ über der Tür.
  - Drinnen kocht Wirt Borko an der Feuerstelle, tagsüber sitzt ein Gast an den Tischen, abends drei. Oma Hagebutte bleibt nachts draußen vor dem Gasthaus.
  - Der Raum ist aus vorhandenen Teilen gebaut (Wurzelwände, Feuerstelle, Bänke, Baumstümpfe, Leuchtpilze). Die gemalten Teile stehen in `Spieldesign/GRAFIK_AUFTRAG.md` Teil O (Blätter IN3 und IN4; die Wegrast-Blätter heißen jetzt IN1 und IN2).
  - **So testest du es:**
    1. Mit dem Spielstand-Editor nach Wipfelheim, zum Baumhaus-Gasthaus links vom Seilaufzug.
    2. An der rechten Seite zu den Stufen gehen: Du bist im Baumhaus-Gasthaus, Borko steht an der Feuerstelle.
    3. Borko ansprechen, dann über „Hinaus“ zurück nach Wipfelheim.
    4. Abends noch einmal hinein: Drei Gäste sitzen da.

- **Neu (11.11.): A12a Gasthaus Wegrast betreten** (Alpha-Punkt 47):
  - Vor der Tür des Wegrast (Südwesten von Kreuzweg) geht es hinein. Wer nur vorbeiläuft, bleibt draußen; wer zur Tür geht oder sie antippt, ist drinnen.
  - Drinnen steht Wirtin Hanne hinter der Theke, tagsüber sitzt ein Gast an den Tischen, abends sind es drei. Hannes Aufträge (Kater, Festmahl, Essen für Brom) gibt es jetzt drinnen; hat sie etwas für dich, steht ein „!“ oder „?“ über der Tür.
  - An der Tür drinnen fällt Licht herein und „Hinaus“ steht darüber. Die kleine Karte zeigt den Raum, die große Karte zählt ihn zu Kreuzweg.
  - Der Raum ist noch aus vorhandenen Teilen gebaut (Stadtmauer als Wände, Fässer und Kisten als Theke, Holzbänke). Die gemalten Innenraum-Teile stehen in `Spieldesign/GRAFIK_AUFTRAG.md` Teil O, mit Anhängen in `tools/referenz/teil_o/`.
  - **So testest du es:**
    1. Nach der Anmeldung bei Lene zum Wegrast gehen: Über der Tür steht ein blaues „!“.
    2. An der Tür vorbeilaufen: Du bleibst draußen. Zur Tür laufen: Du bist im Gasthaus, der Ortsname erscheint.
    3. Hanne ansprechen und „Hannes Kater“ annehmen, dann über „Hinaus“ zurück nach Kreuzweg.
    4. Abends (nach 21 Uhr) noch einmal hinein: Jetzt sitzen drei Gäste da.
    5. M drücken: Auf der großen Karte bist du „in“ Kreuzweg.

- **Neu (11.11.): A11 Kleine und große Karte** (Alpha-Punkte 41 und 42):
  - Oben rechts unter der Leiste liegt eine kleine Karte der Gegend, schräg wie die Welt: Wege und Böden in ihren Farben, Häuser und Wald dunkler, Ausgänge gold. Darauf du (weißer Punkt), andere Spieler (blau), Leute mit Auftrag (gold „!“, hell „?“, blau Nebenaufträge) und das Ziel des Wegweisers (orange Raute). Der Knopf mit dem Ortsnamen klappt sie ein und aus.
  - Taste M, der Knopf „Karte“ oder Antippen der kleinen Karte öffnet die große Karte: alle Gegenden als Schilder mit Namen und den Wegen dazwischen (auch Seilaufzug, Bergpfad und Dungeon-Eingänge). Unbetretene Gegenden gleich nebenan stehen als „???“ da, weiter entfernte sind verborgen. „Du bist hier“ pulsiert, das Ziel der Geschichte hat einen Stern. Schließen mit M, Esc oder dem Knopf.
  - **Achtung:** Die Musik schaltest du jetzt mit **N** an und aus (M ist die Karte). Auf der Startseite steht es auch.
  - Wo jede Gegend auf der großen Karte liegt, steht in `data/weltkarte.json`; neue Gebiete (A13, A14) kommen dort dazu.
  - **So testest du es:**
    1. Ins Spiel gehen: Oben rechts ist die kleine Karte, dein weißer Punkt bewegt sich mit, wenn du läufst.
    2. Einen Auftrag annehmen: Die orange Raute zeigt das Ziel, Ausgänge leuchten gold.
    3. M drücken: Die große Karte zeigt Kreuzweg mit „Du bist hier“ und „???“ für die Wege nach Grünwacht und in die Aschensteppe.
    4. Durch ein Tor gehen und M drücken: Die neue Gegend hat jetzt ihren Namen, dahinter kommen neue „???“.
    5. Auf den Knopf mit dem Ortsnamen über der kleinen Karte tippen: Sie klappt ein und wieder aus.

- **Neu (11.11.): A10 Monster-Bilder aufgeräumt, Abwehr und Geschosse vorbereitet** (Alpha-Punkte 44 und 45):
  - A10a: Die alten Familien-Grundkörper (Schleim, Hase, Käfer, Wolf, Bär … 30 Stück, 898 Bilddateien) sind raus. Jedes Monster hat sein eigenes Blatt, nur der Hirsch bleibt für einen Fähigkeiten-Effekt.
  - A10b: Die Bildaufträge stehen in `Spieldesign/GRAFIK_AUFTRAG.md` Teil N: ein Geschoss je Element (Feuerball, Steinbrocken, Dorn, Blitzkugel, Wasserblase, Windklinge, Lichtball, Schattenkugel, Sternensplitter) und drei Abwehr-Bilder (perfekte Parade, Parade, Ausweichen). Das Spiel nimmt jedes Blatt, sobald es zugeschnitten ist; bis dahin bleiben die gezeichneten Kugeln und Funken.
  - **So testest du es:**
    1. Im Kampf-Editor ein paar Monster zusammenstellen (z. B. Wiesenhoppler und Knollenkäfer) und kämpfen: Alle sehen aus wie vorher, mit ihren eigenen Bildern.
    2. Im Bewegungs-Editor die Monster-Liste durchsehen: Die alten Familien (Schleim, Hase …) tauchen nicht mehr auf.
    3. Wenn die Bilder aus Teil N eingebaut sind: Ein Feuer-Monster (z. B. Glutigel) aus der Ferne angreifen lassen, es wirft einen gemalten Feuerball; bei einer perfekten Parade erscheint der gemalte Glanzstern.

- **Neu (11.11.): A9b3 Wut-Phase für Sporenkönigin und Hammerbrüder** (Alpha-Punkte 38 und 39, dein Beschluss):
  - Ab halbem Leben läuft ein kurzer Film: Bei der Sporenkönigin quellen Sporenwolken auf und platzen („Die Königin erblüht!“), bei den Hammerbrüdern schlagen zwei Hämmer auf einen glühenden Amboss („Hammerwut!“).
  - Danach ist die Mechanik Pflicht. Sporenblüte: Sie stößt bei jedem Zug eine Giftwolke aus. Zwillinge: Solange eine Sporenknospe lebt, kommt an ihr kaum Schaden an. Doppelschlag: Er kommt alle 3 statt alle 5 Züge. Gleichschritt: Der Schwächere rast schon bei kleinem Abstand und steckt dann viel weg.
  - Gemessen (je 150 Kämpfe zu dritt), gewonnen mit / ohne Mechanik: Sporenblüte 79 / 0, Zwillinge 59 / 11, Doppelschlag 95 / 0, Gleichschritt 94 / 15 von 100.
  - **So testest du es:**
    1. Mit dem Spielstand-Editor zur Pilzhöhle springen und die Sporenkönigin angreifen: Bei halbem Leben läuft der Sporen-Film, über ihr steht „WÜTEND!“.
    2. Bei den Zwillingen nur auf die Königin schlagen: Es kommt kaum Schaden an, bis beide Knospen in derselben Runde fallen.
    3. In der Vulkanschmiede die Hammerbrüder auf halbes Leben bringen: Der Amboss-Film läuft, über ihnen steht „Hammerwut!“.
    4. Beim Doppelschlag nicht stören: Er kommt schnell und besiegt alle.

- **Neu (11.11.): A9b2 Vorbote schwerer, mit Film** (Alpha-Punkte 38 und 39, Pilzhöhle):
  - Stirbt die Wurzelmutter, läuft ein kurzer Film: Ein schwarzer Riss mit violettem Rand öffnet sich, schwarze Ranken greifen heraus, groß erscheint „Der Vorbote“.
  - Im Dunkeln trifft man ihn kaum (ein Fünftel des Schadens, auch bei Brennen und Gift). Voll trifft, wer das Splitterlicht hält, oder alle, solange Laternen das Feld fast ganz hell halten. Die Anzeige über ihm sagt „im Dunkeln kaum zu treffen“.
  - Gemessen (je 150 Kämpfe zu dritt auf Stufe 20): mit Laternen und Splitterlicht 85 von 100 gewonnen, ohne 5 (vorher 83 und 64).
  - Die Effekte beider Dungeons sind noch vom Spiel gezeichnet. Die Prompts für gemalte Bilder stehen in `Spieldesign/GRAFIK_AUFTRAG.md` Teil M (12 Blätter), die Anhänge in `tools/referenz/teil_m/`.
  - **So testest du es:**
    1. Mit dem Spielstand-Editor zur Pilzhöhle springen, beim Herz des Urbaums die Wurzelmutter angreifen.
    2. Sie besiegen: Der Film mit dem Riss der Leere läuft, danach steht der Vorbote da und es wird dunkel.
    3. Ohne Splitterlicht zuschlagen: Es kommen nur kleine Zahlen durch.
    4. „Laterne entzünden“, bis die Anzeige „kaum zu treffen“ verschwindet: Jetzt trifft jeder voll. Wer das Splitterlicht hält, trifft immer voll, brennt aber, also weiterreichen.

- **Neu (11.11.): A9b1 Kettenschmied schwerer, mit Film** (Alpha-Punkte 38 und 39):
  - Geht der Kettenschmied in Phase 2, läuft ein kurzer Film: Das Bild wird dunkel, die drei Ketten glühen auf und reißen, die Glieder fliegen davon, groß erscheint „Entfesselt!“.
  - Fesseln sind jetzt gefährlich: Die beiden Gefesselten bekommen zusammen mehr Schaden ab als einer allein, und die glühende Kette brennt bei jedem Zug des Kettenschmieds. Er fesselt früher wieder.
  - Phase 2 geht nur noch mit dem Kühlbecken: Solange sein Panzer hält, kommt nur ein Zehntel des Schadens durch, auch bei Brennen und Gift. Nass wird nur, wer das Becken gezielt angreift. Dafür steigt die Lava langsamer und er schlägt etwas schwächer zu.
  - Gemessen (je 150 Kämpfe zu dritt auf Stufe 20): mit Kühlbecken 85 von 100 gewonnen, ohne keiner (vorher 87 und 91, die Mechanik war egal).
  - Für E4: Allein schafft man ihn selten, schon Phase 1 ist allein zu schwer. Der Rüstungsschmied gewinnt auch zu dritt selten.
  - **So testest du es:**
    1. Mit dem Spielstand-Editor zur Vulkanschmiede springen, in der Ankerkammer den Kettenschmied angreifen (mit Tessa und Gorm).
    2. Ihn in Phase 1 besiegen: Der Film mit den reißenden Ketten läuft, danach steht er mit dem Kühlbecken da.
    3. Nur auf ihn einschlagen: Es kommen fast keine Schadenszahlen durch, die Lava steigt.
    4. Erst ins Kühlbecken schlagen (nass), dann ihn hart treffen: Ein Stück Panzer splittert ab, nach drei Stücken trifft man voll.
    5. Werden zwei gefesselt: Beide verlieren bei jedem seiner Züge Leben, bis ein Dritter die Kette zerschlägt.

- **Neu (10.11.): A9a Begleiter im Dungeon** (Alpha-Punkt 37, Pilzhöhle und Vulkanschmiede):
  - Am Eingang beider Dungeons fragt das Spiel, wer mitkommt: „Allein“, „Mit Tessa“, „Mit Gorm“ oder „Mit Tessa und Gorm“. Die Wahl gilt für den ganzen Durchgang, bei den Bossen und bei jedem Monster dort. Beim nächsten Betreten wählst du neu.
  - Vorher war es uneinheitlich: gegen die Monster immer allein, bei den Bossen fest zu dritt.
  - **So testest du es:**
    1. Mit dem Spielstand-Editor zu „Der Splitter im Urbaum“ springen, zum Höhleneingang im Waldboden: Die Frage erscheint.
    2. „Mit Gorm“ wählen und ein Monster in der Höhle angreifen: Gorm kämpft mit.
    3. Hinter Hadraks Schmiede in die Vulkanschmiede: dieselbe Frage, „Allein“ wählen, die Hammerbrüder allein angehen.

- **Neu (10.11.): A8b Ausrüstung als Plätze** (Taste C, Alpha-Punkt 27):
  - Im Werte-Fenster steht unter dem Aussehen jetzt deine Figur, links die Plätze Kopf, Körper und Schuhe, rechts Waffe und zwei Schmuckplätze, jeweils mit dem Bild des Teils. Leere Plätze zeigen blass ihren Namen.
  - Einen Platz antippen zeigt darunter Name, Seltenheit und Werte, dazu „Ablegen“. Anlegen geht wie bisher in der Tasche.
  - **Für dich:** Die 13 Ausrüstungsteile (Kurzschwert, Kappe, Weste, Stiefel, Kettenglut-Set …) haben noch gezeichnete Platzhalter. Prompt K3f in `Spieldesign/GRAFIK_AUFTRAG.md`, das Zuschneiden ist vorbereitet.
  - **So testest du es:**
    1. Taste C, nach unten rollen: Figur mit sechs Plätzen.
    2. Die Waffe antippen: Werte und „Ablegen“ erscheinen. Ablegen, dann ist der Platz leer.
    3. In der Tasche (I) die Waffe wieder anlegen: Sie steht wieder im Platz.

- **Neu (10.11.): A8a Fähigkeiten-Baum mit Feldern** (Taste K, Alpha-Punkt 26):
  - Statt der Textliste: oben die Leiste mit sechs Feldern, darunter die Grundreihe und die Reihen 1 bis 4 von oben nach unten. Jede Fähigkeit ist ein Feld mit Stufe (z. B. 2/5), gesperrte Reihen sind grau, Linien zeigen, welche Fähigkeit eine andere voraussetzt.
  - Drüberfahren zeigt den Namen, Antippen zeigt unten die Beschreibung mit „Lernen (+1)“ und „Auf die Leiste“. Ein Feld der Leiste antippen nimmt die Fähigkeit wieder herunter.
  - Bis deine Bilder da sind, stehen auf den Feldern Anfangsbuchstaben (braun = aktiv, blau = passiv, grün = Grundreihe). Sobald die Bilder da sind, erscheinen sie auch im Kampf auf den Knöpfen. **Für dich:** Prompts in `Spieldesign/GRAFIK_AUFTRAG.md` Teil L, ein Blatt pro Klasse und eins für den Novizen.
  - **So testest du es:**
    1. Mit dem Spielstand-Editor als Bogenschütze mit Stufe 15 in die Welt, Taste K.
    2. „SS“ (Schneller Schuss) antippen, „Lernen (+1)“: Die Stufe auf dem Feld steigt.
    3. Eine Fähigkeit mit „Auf die Leiste“ hinzufügen und in einem Kampf ansehen.

- **Neu (10.11.): A7 Figuren richten** (Alpha-Punkte 1, 2, 12, 19–22, 25):
  - **Novize m1 und Novizin w1:** Schräg von vorne schaut der Kopf jetzt in dieselbe Richtung wie der Körper, im Stehen und Laufen. Die Ursache: Das Spiel hat alle sechs wählbaren Köpfe gespiegelt, gezeichnet sind aber nur m2, m3, w2 und w3 nach links. Jetzt werden genau die Köpfe gespiegelt, die nach links schauen (dazu a_m1, k_w1 und Borko).
  - **Broms Helm** ist größer, sitzt tiefer auf der Stirn, und das Innere des Helms ist ausgeschnitten, damit sein Gesicht durchschaut.
  - **Für dich, Bilder (Teil K in `Spieldesign/GRAFIK_AUFTRAG.md`):** K1 Köpfe von vorne für die Frauen (Layla, Nadia, Hanne und die anderen schauen stärker zur Seite als ihr Körper, das geht nur mit neuen Köpfen), K2 die Zielscheiben für Fenns Prüfung, K3 Bilder für alle 60 Monster-Beuten (fünf Blätter, die Glutoase mit Echsenschuppe und Sonnenmähne zuerst). Das Zuschneiden ist vorbereitet.
  - **So testest du es:**
    1. Neue Figur mit Kopf m1 oder w1 erstellen und in Kreuzweg schräg nach vorne laufen: Kopf und Körper schauen gleich.
    2. Zu Torwache Brom am Südosttor: Der Helm sitzt auf dem Kopf, das Gesicht ist frei.
    3. Im Editor unter „Bewegungen in der Welt“ Novizin w2 ansehen: schaut weiter richtig.

- **Neu (09.11.): A6 Kampf-Anzeige** (Alpha-Punkte 6, 7, 11, 43):
  - **Schild der Monster (6):** Hat ein Gegner (oder jemand aus der Gruppe) einen Schild, liegt eine hellblaue Leiste direkt über seiner Lebensleiste, und oben auf dem Namensschild sitzt ein Schild-Abzeichen mit der Zahl.
  - **Ziele unten (43):** Nach dem Antippen einer Fähigkeit stehen alle möglichen Ziele unten als Knöpfe mit Nummer, Leben, Schild und Element („1 · Wiesenhoppler“ …). „Zurück“ liegt immer auf der 6 (auch bei Auswahl-Menüs wie Rüstung oder Ware). Antippen der Figur geht weiterhin.
  - **Stufen-Klang (11):** kurze Fanfare beim Stufenaufstieg, in der Welt und auf der Kampf-Auswertung (selbst erzeugt wie die anderen Geräusche).
  - **Auftragsbelohnung (7):** Beim Abgeben erscheint eine Karte „Auftrag abgeschlossen“ mit dem Titel und darunter Geld, Erfahrung und Gegenstände mit ihren Bildern. Sie verschwindet nach ein paar Sekunden oder beim Antippen.
  - **So testest du es:**
    1. Gegen ein Monster kämpfen, „Hieb“: Unten stehen die Ziele mit Nummern, „6 · Zurück“.
    2. Ein Monster, das sich schützt (z. B. Knollenkäfer „Einrollen“): Schild-Leiste und Abzeichen.
    3. Einen Auftrag abgeben: Belohnungskarte.
    4. Eine Stufe aufsteigen: Fanfare.

- **Neu (09.11.): A5 Glutoase** (Alpha-Punkte 23, 31, 33, 34):
  - **Weiter zum nächsten Auftrag (23):** Ist kein Auftrag der Geschichte offen und auf deiner Karte hat niemand ein „!“, zeigt der Wegweiser jetzt zum nächstgelegenen Auftraggeber auf einer anderen Karte. Beispiel Sternensängerin: Nach dem Lernen bei Xavina in der Palmenrast führt er zu Nadia in die Glutoase (bisher zeigte er nichts).
  - **Mira im Bett (31):** Mira liegt jetzt auf dem Bett im Krankenzelt (das Bett war im Zelt-Bild schon gemalt). Ansprechen kannst du sie vom Zelteingang aus.
  - **Lava und Weg (33, 34):** In der Vulkanschmiede ist die dunkle Leere um die Steinwege jetzt glühende, langsam wabernde Lava mit hellen Glutadern, an den Wegrändern leuchten Glut-Lichter. Dadurch sieht man die Lava sofort und die Wege heben sich klar ab.
  - **So testest du es:**
    1. Spielstand-Editor: Sternensängerin, Punkt „Beim Lehrmeister lernen“; bei Xavina lernen: Der Wegweiser führt in die Glutoase zu Nadia.
    2. „Miras Lied“: Mira liegt im Zelt auf dem Bett.
    3. „Die Ketten unter dem Berg“: In der Vulkanschmiede Lava und Wege ansehen.

- **Neu (09.11.): A4b Mira und Ren** (Alpha-Punkte 13, 14):
  - **Mira (13):** Beim „leisen Singen“ kommt Mira jetzt nach einer Sekunde von oben vom Marktplatz zu dir (vorher lief sie von ihrem Platz am Tor einen Umweg von fast neun Sekunden).
  - **Rettung in der Sternenfall-Nacht (14):** Ren greift jetzt im Kampf selbst ein, als Szene: Sie rennt von rechts herein („Weg da!“), wirft drei Kunai auf den Sternenfresser, der verblasst, dann „Steh auf, Novize. Das war knapp.“ Gewinnt ihr, zieht sie den Splitter aus dem Gegner zu sich („Den Splitter nehme ich aber mit.“). Danach läuft sie davon, dann kommt die Auswertung.
  - **Ren mit eigenen Bildern:** Deine Blätter `haupt_ren_kampf_a/b`, `haupt_ren_welt` und `haupt_ren_portraets` sind eingebaut (Kampf, Welt, Porträts). In Kreuzweg ist Ren nicht mehr die alte Elfe.
  - **So testest du es:**
    1. Den Korb bei der Wache abgeben: Mira kommt gleich von oben.
    2. Nacht des Sternenfalls (Spielstand-Editor: Punkt „Das Fest der fünf Wege“): Kampf verlieren oder gewinnen, Ren greift ein.
    3. Nach dem Kampf in der Stadt: Ren steht mit eigener Figur da.

- **Neu (09.11.): A4a Ye's Erklärungen und das Abzeichen** (Alpha-Punkte 5, 10):
  - **Erklärungen vor dem Kampf (5):** In Ye's Grundausbildung kommen die Erklärungen einer Lektion jetzt gleich zu Beginn, bevor sich jemand bewegt (bisher erst bei deinem Zug oder kurz vor dem ersten Angriff). In der Paradeschule sagt Ye nach den zwei vorgeführten Paraden in einem eigenen Fenster: „Jetzt du – versuch zweimal, PERFEKT zu parieren“, die Leiste zeigt „Jetzt du: Versuch, perfekt zu parieren! (Versuch 1 von 2)“.
  - **Abzeichen (10):** Nach einer Probestunde bei Nalia (Glutoase) oder Aske (Grünwacht) geht es zurück in die Stadt statt in die Klassenliste. Beim ersten Mal überreicht der Gesandte das **Probestunden-Abzeichen** (in der Tasche) und sagt, dass du es der Schreiberin zeigen sollst; sprichst du ihn wieder an, kannst du weitere Klassen ausprobieren. Texte sind Platzhalter.
  - **So testest du es:**
    1. Ye's Grundausbildung: Zu Beginn jeder Lektion kommt erst Ye's Erklärung.
    2. Lektion 2 (Parieren): Nach den zwei vorgeführten Paraden kommt „Jetzt du …“.
    3. Bei Nalia eine Probestunde machen: Danach stehst du in der Stadt, sie gibt dir das Abzeichen.
    4. Nalia nochmal ansprechen: wieder „Zeig mir eure Klassen“.

- **Neu (09.11.): A3 Klassen der Demo** (Alpha-Punkte 9, 15):
  - **Klassenwahl:** Die sechs Klassen aus Arkanum, Messinghafen und von den Nebelinseln stehen weiter in der Liste, aber blasser und mit „später“. Beim Antippen siehst du alles über sie, aber „Probestunde“ und „Diese Klasse wählen“ sind gesperrt, mit dem Hinweis, dass es in der Demo die Klassen aus Grünwacht und der Glutoase gibt.
  - **Lehrmeister (deine Änderung):** Diese Klassen haben in der Welt keine eigenen Lehrmeister. Ihre „Lehrmeister“ sind die Gesandten in Kreuzweg. Ilwen (Arkanum), Pim (Messinghafen) und Mei (Nebelinseln) bleiben stehen; bei „Zeig mir eure Klassen“ sagen sie jetzt, dass ihre Wege noch verschlossen sind (Platzhalter-Texte). Die Gesandten von Grünwacht und der Glutoase zeigen ihre Klassen wie bisher.
  - **So testest du es:**
    1. Bei Ye die Klassenwahl öffnen: Kunoichi antippen, beide Knöpfe gesperrt.
    2. Mit Ilwen, Pim oder Mei reden, „Zeig mir eure Klassen“: Sie bieten noch nichts an.
    3. Mit Nalia (Glutoase) reden: Ihre drei Klassen und die Probestunde gehen wie bisher.

- **Neu (09.11.): A2b Fleck, gemeinsamer Kampf, Gruppenfenster** (Alpha-Punkte 4, 8, 16):
  - **Weißer Fleck (4):** Das war das Silberkraut, aber nicht wegen des Online-Spiels: Im Browser (einfache Grafik) wurde sein Bild in jedem Bild neu geladen und sofort wieder vergessen, die Grafik zeigte dann ein weißes Viereck. Jetzt bleibt es geladen (betrifft auch das Wiesenkraut).
  - **Gemeinsamer Kampf (16):** Mitspieler mit Klasse kämpften als allgemeine Klassenfigur (andere Größe, anderer Stil). Jetzt kämpft jeder mit seiner eigenen Figur in Klassenkleidung, wie allein, und hat seine Tränke am Gürtel.
  - **Gruppenfenster (8):** halb durchsichtig, mit „–“ einklappbar (dann nur die Namen), „+“ klappt es wieder auf. „Gruppe verlassen“ ist jetzt ein kleiner Knopf.
  - **So testest du es:**
    1. Im Browser (Demo) in Kreuzweg ein Silberkraut ansehen: Pflanze statt weißem Fleck.
    2. Online zu zweit eine Gruppe bilden: Fenster mit „–“ einklappen, mit „+“ wieder auf.
    3. Zu zweit mit gelernter Klasse gemeinsam kämpfen: Beide in eigener Figur und Klassenkleidung.

- **Neu (09.11.): A2a Offline und Online** (Alpha-Punkte 3, 24, 48, 49):
  - **Startmenü:** nur noch „Offline spielen“ und „Online spielen“ (in der Werkstatt dazu „Editor“). Feedback gibt es im Spiel oben rechts, die **Dankesliste** steht jetzt im Abspann am Ende der Demo.
  - **Online = dasselbe Spiel:** Du spielst online mit deiner eigenen Figur und deinem Spielstand weiter. Wer noch keine Figur hat, erstellt sie zuerst („Figur erstellen“), danach geht es zurück zu „Online spielen“. Die alte Auswahl (Vega, Elfen, Ritter …) ist weg.
  - **Alte Modelle online behoben:** Der Server hat jede eigene Figur durch eine alte Elfe ersetzt. Darum habt ihr euch als alte Modelle gesehen und es gab online keine Klassenkleidung (dein Klingentänzer als Novize). Jetzt kommt jeder mit seiner Figur an, und nach dem Lernen der Klasse trägt man auch online die Klassenkleidung.
  - **So testest du es:**
    1. Spiel starten: nur „Offline spielen“ und „Online spielen“.
    2. „Online spielen“ → „Online spielen (übers Internet)“ mit zwei Geräten: Ihr seht euch mit euren eigenen Figuren.
    3. Online mit einer Figur, die schon eine Klasse gelernt hat: Der andere sieht dich in Klassenkleidung.
    4. Demo zu Ende spielen (oder im Spielstand-Editor kurz vor Schluss starten): Die Dankesliste steht im Abspann.

- **Neu (09.11.): S5 Spielstand-Editor** (Editor, „Demo testen“, vierter Knopf): an jede Stelle der Demo springen, dein normaler Spielstand bleibt unberührt.
  - Links **Klasse** (die fünf der Demo; Sternensängerin nur mit Novizin), **Figur**, **Stufe**, **Geld**, **Heil- und Manatränke** und beliebige **weitere Gegenstände** („Dazu“).
  - Rechts die **Punkte der Geschichte** in der Reihenfolge deiner Klasse (Bogenschütze und Zähmer erst Grünwacht, alle anderen erst Glutoase). Beim Antippen schlägt der Editor eine passende Stufe vor.
  - „Spielstand bauen und spielen“: Alle Aufträge davor sind erledigt, der gewählte läuft, und du stehst neben der Figur, bei der es weitergeht (Wegweiser zeigt hin). Die Nacht des Sternenfalls beginnt nach dem Kampf (bei Ren), die Dungeons am Eingang.
  - Nebenbei: Bei „Die Ketten unter dem Berg“ und „Der Splitter im Urbaum“ zeigt der Wegweiser jetzt auch im Spiel zum Eingang des Dungeons.
  - Das Editor-Menü hat jetzt zwei Reihen Werkzeuge, damit nichts übereinanderliegt.
  - **So testest du es:**
    1. Werkstatt → Editor → „Spielstand-Editor“.
    2. Klasse Klingentänzerin, Punkt „Der Tanz mit der Pause“, „Spielstand bauen und spielen“: Du stehst in der Glutoase bei Samira.
    3. Bogenschütze, Punkt „Das leere Grab“: Du bist in Grünwacht, Stufe passend vorgeschlagen.
    4. Ein paar Gegenstände mit „Dazu“ hinzufügen und in der Tasche nachsehen.

- **Neu (09.11.): S4b Hinzufügen im Stadt-Editor:** Oben der Knopf „Hinzufügen“ öffnet rechts ein Fenster.
  - **Teile:** alle Teile aus dem Baukasten als Bilder, mit Filter (Kreuzweg, Grünwacht, Glutoase, Vulkanschmiede) und Suche. Antippen setzt das Teil in die Bildmitte und wählt es, dann verschieben, drehen usw.
  - **Figuren:** Körper und Kopf wählen (mit Vorschau), Name eingeben, „immer da“, „nur tags“ oder „nur nachts“, dann „Figur hinzufügen“. Neue Figuren sagen vorerst einen allgemeinen Satz, eigene Sätze schreibe ich ihnen später.
  - **Löschen** geht jetzt auch für Figuren, aber nur für Volk und neue Figuren. Figuren mit Aufträgen (Ye, Ysolde …) bleiben geschützt.
  - Alles lässt sich rückgängig machen und wird mit gespeichert.
  - Nebenbei behoben: In Kreuzweg wären Plätze von Figuren, die in der Datei über mehrere Zeilen stehen, beim Speichern nicht übernommen worden.
  - **So testest du es:**
    1. Stadt-Editor → Kreuzweg → „Hinzufügen“ → „Teile“: einen Baum suchen („baum“) und antippen, dann an seinen Platz ziehen.
    2. „Figuren“: einen Körper und Kopf wählen, „Nur nachts“, „Figur hinzufügen“; mit „Tags/Nachts“ prüfen.
    3. Eine Bürgerin antippen und „Löschen“; dann Ye antippen und „Löschen“: Ye bleibt.
    4. „Speichern“ und im Spiel nachsehen (am PC in Godot).

- **Neu (09.11.): Drehen im Stadt-Editor** (dein Wunsch): Knopf „Drehen“ neben „Spiegeln“.
  - **Flache Teile** (Gras, Blumen, Lichtung, Steppengras, Karawanenspur …) drehen sich frei in 45°-Schritten auf dem Boden.
  - **Stehende Teile** (Häuser, Stände) und Brücken (wegen der Geländer): reihum vorne → quer → von hinten → von hinten quer. Die Ansichten von hinten brauchen eigene Bilder: Prompts in `GRAFIK_AUFTRAG.md` Teil J (G1 bis G4, je Stadt ein Blatt). Bis sie da sind, wechselt „Drehen“ nur zwischen vorne und quer.
  - **Online speichern** (für Katie und fürs Handy) steht als S4c „erst besprechen“ in den Bauaufträgen.
  - **So testest du es:**
    1. Stadt-Editor → „Aschensteppe“ oder „Glutoase“, Steppengras oder Karawanenspur antippen, mehrmals „Drehen“.
    2. Ein Haus antippen und „Drehen“: Es steht quer, nochmal: wieder vorne.

- **Neu (09.11.): S4a Stadt-Editor** (Editor, vierter Knopf): Jede Karte aus dem Baukasten (Kreuzweg, Wipfelheim, Glutoase, Wege und Höhlen) mit allen Teilen und Figuren.
  - **Antippen** wählt ein Teil oder eine Figur (gelber Rahmen), **Ziehen** verschiebt es, die vier **Pfeilknöpfe** ↖ ↗ ↙ ↘ schieben Feld für Feld (fürs Handy). Leere Stelle ziehen bewegt die Karte, − + zoomen.
  - Teile **spiegeln** und **löschen**, **Rückgängig** (auch Strg+Z). „Tags/Nachts“ zeigt und verschiebt die Figuren an ihrem Platz bei Tag oder bei Nacht.
  - **Speichern:** am PC im Godot-Editor direkt in die Kartendaten. Im Browser (Werkstatt) lädt es eine Datei „stadt_<ort>.json“ herunter: die schickst du mir, ich übernehme sie mit einem Befehl.
  - Hinzufügen neuer Teile und Figuren kommt mit S4b.
  - **So testest du es:**
    1. Werkstatt → Editor → „Stadt-Editor“, oben „Kreuzweg“.
    2. Einen Marktstand antippen und mit den Pfeilknöpfen zwei Felder verschieben, dann „Rückgängig“.
    3. Auf „Nachts“ stellen und eine Figur an einen anderen Platz ziehen.
    4. „Speichern“: am PC in Godot danach die Demo starten und schauen, ob es dort steht; im Browser kommt eine Datei.

- **Neu (09.11.): S3b Bewegungen in der Welt** (Editor, dritter Knopf): Die gewählte Figur steht viermal nebeneinander: nach links, nach rechts, schräg von vorne und schräg von hinten. Unter jeder steht, welche Bilder gerade laufen und wie viele es sind.
  - **Figur:** Novizen, Klassen-Körper (je mit jedem wählbaren Kopf), Baukasten-Körper (mit den Volks-Köpfen) oder eine der 69 Figuren aus der Welt (Ye, Mira, Hatta …).
  - **Bewegung:** Stehen, Laufen, Liegen, Sitzen. **Tempo:** normal, langsam, sehr langsam oder „Bild für Bild“ mit ◀ ▶ (auch Pfeiltasten).
  - Gut zu wissen: Im Spiel nutzen Figuren mit Seiten-Bildern (Novizen, Klassen) beim Laufen nur die Seiten-Bilder, die Bilder von vorne und hinten bisher nur der Baukasten.
  - **So testest du es:**
    1. Werkstatt → Editor → „Bewegungen in der Welt“.
    2. „Novizen“, Kopf m1, „Laufen“, dann „Bild für Bild“ und mit ▶ durchblättern: Sitzen Kopf und Schwert in jedem Bild?
    3. „Figuren aus der Welt“ → z. B. Ye wählen und „sehr langsam“ laufen lassen.
    4. „Baukasten-Körper“ mit verschiedenen Köpfen ansehen.

- **Neu (09.11.): A1b Blocker in Kampf und Menüs** (Alpha-Punkte 28, 29, 35, 36, 46):
  - **Menüs anklicken (28, 29):** Tasche, Kartenalbum, Fähigkeiten, Werte und Auftragsbuch wurden in jedem Bild neu aufgebaut. Ein Klick traf so nie denselben Knopf beim Drücken und Loslassen. Jetzt baut sich ein Fenster nur neu auf, wenn sich etwas ändert: Seiten im Album wechseln, Fähigkeiten anklicken usw. geht wieder.
  - **Heiltrank (35):** Tränke am Gürtel heilten nur beim Novizen, bei allen Klassen passierte nichts. Jetzt heilen Heil- und Manatrank bei jeder Klasse.
  - **Klingenschritt (36):** Die schwebenden Klingen trafen nur nach, wenn man Klingenkranz gelernt hatte. Jetzt treffen sie immer nach (wie der Knopf sagt), Klingenkranz macht sie je Stufe 10 % stärker.
  - **Ortsname (46):** Die kleine Meldung „– Kreuzweg –“ beim Betreten ist weg, nur der große Name bleibt.
  - **So testest du es:**
    1. L drücken und im Kartenalbum auf eine andere Seite klicken, dann K drücken und eine Fähigkeit anklicken.
    2. Als Klingentänzerin (oder andere Klasse) im Kampf verletzt einen Heiltrank vom Gürtel trinken: Das Leben steigt.
    3. Mit Klingen über dir einen Klingenschritt machen: Die Klingen fliegen hinterher und treffen.
    4. Durch ein Tor gehen: nur noch der große Ortsname.

- **Neu (09.11.): A1a Blocker beim Weiterkommen** (Alpha-Punkte 24, 30, 32, 40):
  - **Seilaufzug (40):** Der Wegweiser zeigt jetzt den ganzen Weg bis Wipfelheim, auch im Wald auf den Seilaufzug (bisher hörte er hinter dem Westtor auf). Den Aufzug kann man jetzt auch auf seinem Bild antippen, nicht nur auf dem kleinen Feld davor.
  - **Tanz (32):** „Der Tanz mit der Pause“ geht sofort, man muss nicht mehr bis nachts warten.
  - **Kochende Brunnen (30):** Der Wegweiser zeigt erst zur Wasserstelle im Nordwesten, dann zur dampfenden im Nordosten der Palmenrast.
  - **Sternensängerin nur für Frauen (24, dein Beschluss):** Ist die eigene Figur männlich, sind bei der Klassenwahl „Diese Klasse wählen“ und „Probestunde“ der Sternensängerin gesperrt, mit Hinweis. Dass dein Klingentänzer als Novize herumlief, kam vermutlich vom Online-Spiel (alte Figuren), das kommt mit A2.
  - **So testest du es:**
    1. Nach dem Ende der Glutoase am Westtor mit der Wache reden und dem Wegweiser folgen: Er führt bis zum Seilaufzug im Wald, Antippen bringt einen nach Wipfelheim.
    2. Bei Samira „Der Tanz mit der Pause“ tagsüber annehmen und gleich tanzen.
    3. „Kochende Brunnen“ annehmen: Der Wegweiser zeigt in der Palmenrast zu den Wasserstellen.
    4. Mit einer männlichen Figur bei Ye die Klassenwahl öffnen: Die Sternensängerin ist gesperrt.

- **Neu (04.11.): D25b Körper von Rüstungsschmied und Sternensängerin** (2.11): Deine Blätter sind eingebaut: Rüstungsschmied (m) und Rüstungsschmiedin (w) in Rüstung mit Lederschürze und rotem Halstuch, die Sternensängerin (w) im hellen Gewand mit dunkelblauem Schal. Je mit Stehen, Laufen, Abwehr, Treffer, Angriff, Fallen, Sieg und Fähigkeit im Kampf, in der Welt schräg von vorne und hinten. Wer die Klasse gelernt hat, trägt sie mit seinem eigenen Kopf, auch in der Probestunde. Ausgebessert: die gelben Funken im Treffer-Bild des Schmieds und das rote Halstuch in einem Siegesbild der Sängerin. Noch nicht drin: ein männlicher Sternensänger (der kämpft weiter in der Klassenfigur).
  - **So testest du es:**
    1. Kampf-Sandbox oder Probestunde Rüstungsschmied: die eigene Figur in Rüstung.
    2. Probestunde Sternensängerin mit einer weiblichen Figur: die eigene Figur im Sternengewand.
    3. Nach der Klassenwahl in der Glutoase: In der Welt läuft man in der neuen Kleidung herum.

- **Neu (05.11.): E3b, E3c, E3e, E3f, E3g aus deiner Test-Liste:**
  - **Kopfrichtung (E3b):** Die sechs wählbaren Köpfe (m1 bis w3) und v_w3 waren schräg von vorne nach links gezeichnet, die Körper schauen nach rechts. Sie werden in dieser Ansicht jetzt gespiegelt, alle Figuren schauen in dieselbe Richtung.
  - **Ortsnamen (E3c):** Beim Betreten eines Gebiets erscheint der Name groß in der Bildmitte, in Gold mit dunklem Rand, in der freien Schrift Cinzel (Quelle in CREDITS.md), und blendet nach gut zwei Sekunden aus.
  - **Klingentänzerin (E3e):** Die schwebenden Klingen ihres Klingenkranzes sind jetzt ihre Krummklingen aus deinem Waffen-Blatt statt der alten gezeichneten Schwerter.
  - **Kräuter (E3f):** Silberkraut und Wiesenkraut haben deine neuen Bilder und wiegen sich leicht im Wind.
  - **Novizen laufen (E3g):** Deine neuen Welt-Blätter sind eingebaut: 8 statt 5 Bilder Laufen je Richtung. Das Schwert setzt das Spiel selbst ein (Richtung aus den alten Bildern, Griff am Gold); in ein, zwei Laufbildern sitzt es vielleicht noch nicht ganz richtig, bitte beim Testen darauf achten.
  - **So testest du es:**
    1. Mit einem eigenen Kopf (z. B. m1) und mit Tessa oder Gorm herumlaufen: Köpfe und Körper schauen gleich.
    2. Von Kreuzweg auf den Weg nach Grünwacht gehen: Der Ortsname erscheint groß.
    3. Als Novize laufen: flüssigere Schritte, das Schwert in der Hand.

- **Neu (05.11.): E3d Kampf-Hintergründe für jedes Gebiet:** Elf neue Hintergründe, wie bisher vom Spiel gezeichnet:
  - **Kreuzwegfelder** (Ye's Lektionen, Gruppenkampf, Probestunden): Felder am Hang, Windmühle, Zaun, Vogelscheuche, Kreuzweg in der Ferne.
  - **Grünwacht:** Weg nach Grünwacht jetzt ein lichter Waldweg (der Waldboden bleibt dichter Wald), **Tiefwurzel** mit Wurzelbögen, Nebel und lila Splittern, **Wipfelheim** (Fenns Prüfung, Kobalts Kämpfe) auf einer Holzplattform mit Hängebrücke und Laternen.
  - **Glutoase:** **Aschensteppe** im Norden Grasland mit Tafelbergen, im Süden Dünen mit Ruine und Kakteen; **Palmenrast** mit Oasen-Teich und Palmen (auch die dampfende Quelle); **Sternendüne** für Xavinas Prüfung; **Stadt Glutoase** mit Terrassen und Sonnensegeln (Samira); **Hadraks Schmiede** mit Esse und Amboss (Brakkus, Kael); **Glutgrat** mit rauchendem Vulkan und Glutrissen.
  - **Nachts** (nach der Uhr) sind Kämpfe unter freiem Himmel jetzt auch dunkel, mit Mond und Sternen, die Figuren bläulich. Höhlen, Schmieden und die Vulkanschmiede bleiben wie sie sind.
  - **So testest du es:**
    1. Auf dem Weg nach Grünwacht, in der Tiefwurzel, in der Aschensteppe (oben und ganz im Süden), in der Palmenrast und auf dem Glutgrat je ein Monster angreifen: Jeder Ort hat sein eigenes Bild.
    2. Ye's Lektion oder eine Probestunde: Kampf auf den Feldern vor Kreuzweg.
    3. Kobalt in Wipfelheim oder Kael in Hadraks Schmiede herausfordern.
    4. Mit dem Testknopf in der Tasche die Uhr auf Nacht stellen und ein Monster draußen angreifen: Der Kampf ist dunkel, mit Mond.

- **Neu (06.11.): Gemalte Kampf-Hintergründe von ChatGPT (Teil F):** Alle 15 Bilder sind eingebaut, dazu die Ankerkammer (V3) für die Hammerbrüder und den Kettenschmied. Die übrigen Kämpfe in der Vulkanschmiede zeigen die Schmiedehallen. Die Bilder sind ein Stück nach oben geschoben, damit die Kämpfer auf dem Boden stehen. Nachts werden sie draußen dunkler. Die gezeichneten Hintergründe bleiben nur noch als Ersatz (Gewölbe in der Kampf-Sandbox).
  - **So testest du es:**
    1. Ye's Lektion: Kampf vor Windmühle, Feldern und Stadtmauer.
    2. Je ein Monster auf dem Weg nach Grünwacht, im Waldboden, in der Tiefwurzel, in der Aschensteppe (Norden und Süden), in der Palmenrast und auf dem Glutgrat angreifen: überall das gemalte Bild.
    3. Hammerbrüder oder Kettenschmied: Kampf in der Ankerkammer mit den drei Ankern.
    4. Stehen die Figuren überall gut auf dem Boden? Sonst sag Bescheid, dann schiebe ich die Bilder anders.

- **Neu (10.11.): E3h3b Ebenen in der Glutoase** (dein Wunsch: zur Schmiede immer höher):
  - Die Stadt hat jetzt drei echte Höhen: unten die Oase, eine Stufe höher das Schmiedeviertel, ganz oben Hadraks Schmiede. Boden, Häuser und Figuren der oberen Stufen liegen sichtbar höher, unter jeder Kante sieht man eine Lehm- und Felswand, an der rechten Seite fällt der Berg ab.
  - Auf den Treppen steigt die Figur gleichmäßig hinauf. Antippen zum Laufen trifft auf jeder Stufe das richtige Feld.
  - Der Stadt-Editor zeigt die Glutoase genauso mit Ebenen.
  - Die anderen Städte bleiben flach. Ebenen kann jetzt jede Karte bekommen (Angabe „hoehen“ in den Kartendaten).
  - Noch nicht: Die Felswände sind vom Spiel gemalt (Flächen mit Fugen), ein gemaltes Felswand-Bild gibt es noch nicht.
  - **So testest du es:**
    1. In die Glutoase: Von der Oase aus sieht man die Stadt nach hinten ansteigen.
    2. Die Treppe hinauf ins Schmiedeviertel und weiter zu Hadrak: Die Figur steigt sichtbar.
    3. Auf der oberen Stufe irgendwo hintippen: Die Figur läuft genau dorthin.
    4. Editor → Stadt-Editor → Glutoase: dieselben Ebenen, Teile lassen sich wie gewohnt verschieben.

- **Neu (10.11.): E3h3a Glutoase umgedreht** (erster Teil deines Wunschs mit den Ebenen):
  - Die Oase mit dem Tor zur Aschensteppe liegt jetzt vorne (unten im Bild), darüber das Schmiedeviertel, ganz hinten oben Hadraks Schmiede am Krater. Die Terrassenmauern zeigen jetzt zu dir, so wirkt jede Stufe höher als die davor. Echte Höhen (die Stufen auch höher gezeichnet) kommen mit E3h3b.
  - Alle Wege bleiben: Treppen, Lastenaufzug, Bergpfad zum Glutgrat, Osttor zur Palmenrast, Eingang zur Vulkanschmiede (jetzt hinter Hadraks Schmiede, tiefer im Berg).
  - Figuren stehen wieder vor ihren Häusern (Layla, Rashid, Tarek, die Basarleute, Mira am Krankenzelt, Brakkus, die Schmiede). Hadrak empfängt einen oben an der Treppe, Kael wartet daneben. Die Bank steht etwas abseits vom Gasthaus, ein Gast sitzt unter dem Sonnensegel.
  - **So testest du es:**
    1. Aus der Aschensteppe in die Glutoase: Du kommst unten in der Oase an, die Stadt steigt nach hinten an.
    2. Über die zwei Treppen hinauf zu Hadrak, mit dem Lastenaufzug wieder hinunter.
    3. Nachts: Hadrak sitzt beim Gasthaus, die Tänzer sind am Tanzplatz.

- **Neu (10.11.): E3h2 Wipfelheim umgebaut** (grob, Feinschliff im Stadt-Editor):
  - **Bäume:** Kein Baum steht mehr direkt vor einer Plattform und verdeckt Häuser, Stände oder Figuren (z. B. der Baum vor Salbeis Stand und der Bank). Im Wald drumherum bleiben sie dicht.
  - **Figuren:** Ein Gast steht jetzt an der Ecke des Gasthauses statt am Eingang, eine Sammlerin ist vom Hauptplatz zu Esches Labor gegangen.
  - Wipfelheim war deutlich weniger voll als Kreuzweg, darum ist der Umbau klein. Alle Figuren stehen mindestens drei Felder auseinander (das prüft eine Prüfung).
  - **So testest du es:**
    1. Mit dem Seilaufzug nach Wipfelheim: Der Hauptplatz mit Halle, Bank und Salbeis Stand ist frei zu sehen.
    2. Zum Gasthaus: Kael, Borko, Oma Hagebutte und die Gäste stehen einzeln.
    3. Was dir noch zu eng ist, im Stadt-Editor verschieben.

- **Neu (10.11.): E3h1 Kreuzweg umgebaut** (grob, den Feinschliff machst du im Stadt-Editor):
  - **Marktplatz freier:** Die beiden Marktstände mit Marktfrau Rosa und Gemüsehändler Jost stehen jetzt in einer Marktgasse im Nordosten, gleich neben Bingo und Hatta. Auf dem Platz bleiben Statue, Brunnen, Bühne und Splitterkreis.
  - **Kinder:** Pip und Lotte spielen jetzt am Brunnen statt mitten auf dem Platz.
  - **Gesandte:** Die Pavillons von Magistra Ilwen und Schreindienerin Mei stehen weiter auseinander und nicht mehr an der Schmiede.
  - **Gilde:** Tessa und Gorm stehen an den Übungspuppen, Lene am Auftragsbrett, Ye bleibt am Eingang. Eine Tanne, die Gorm verdeckte, steht jetzt weiter hinten.
  - Ein paar Bäume und Büsche beim neuen Markt sind verteilt, damit die Stände Luft haben.
  - **So testest du es:**
    1. Kreuzweg tagsüber: Der Marktplatz hat Platz zum Laufen, die Marktgasse liegt am Weg zu Bingo.
    2. Nachts: Die Stände in der Marktgasse sind zu, Rosa und Jost sind weg.
    3. An der Gilde: Ye, Lene, Tessa und Gorm stehen einzeln und sind gut zu sehen.
    4. Im Stadt-Editor kannst du alles weiter verschieben.

- **Neu (08.11.): S3a Bewegungen & Effekte** (Editor, zweiter Knopf): ein Kampf, unten eine Leiste mit vier Spalten.
  - **Figur:** Klasse des Helden, Aussehen (Standard, deine eigene Figur, Vega, Kofi, Kael, Ye) und das Monster gegenüber. Tempo: normal, langsam, sehr langsam.
  - **Bewegungen:** Stehen, Laufen, Angriff, Getroffen, Abwehr, Wirken, Sieg, Fallen, umschaltbar für den Helden oder das Monster.
  - **Fähigkeiten:** jede Fähigkeit der Klasse als Knopf. Sie wird wirklich ausgeführt (mit Bewegung, Effekt und Zahlen), sobald der Held am Zug ist. Der Held hat immer volles Leben, Mana und Ult, keine Abklingzeiten; das Monster hat sehr viel Leben. Roboter und Zähmer-Monster spielt der Computer.
  - **Effekte:** alle 71 gezeichneten Abläufe und alle 34 gemalten Bildfolgen (z. B. deine neuen aus D9h) einzeln abspielen.
  - Die Figuren-Probe heißt im Editor jetzt „Figuren-Teile“ (Körper, Kopf, Hut, Farben). Die Bewegungen in der Welt kommen mit S3b.
  - **So testest du es:**
    1. Werkstatt → Editor → „Bewegungen & Effekte“.
    2. Klasse Klingentänzerin wählen, warten bis „Du“ am Zug ist, „Klingensturm“ drücken.
    3. Tempo auf „sehr langsam“, „Für: Monster“, „Angriff“ drücken.
    4. Unter Effekte eine Bildfolge wählen und „Bildfolge abspielen“.

- **Neu (08.11.): S2 Kampf-Editor** (im Editor ganz links, also in deiner Werkstatt und am PC):
  - **Gegner:** bis zu vier Monster frei wählen (alle Monster des Spiels, mit Element) und ihre Stufe, oder einen **Kampf aus dem Spiel** (Lektionen, Rivalen, Bosse der Pilzhöhle und Vulkanschmiede mit ihren Regeln). Bosse, die man frei wählt, bringen die Regeln ihres Dungeons mit.
  - **Deine Gruppe:** bis zu vier Helden mit Klasse und Stufe, Heiltränke, und ob der Computer die Mitstreiter steuert.
  - **Ort und Zeit:** jeder Kampf-Hintergrund (oder „wie im Kampf“), Tag oder Nacht.
  - **Kämpfen!** startet den Kampf, danach kommst du zurück in den Editor, deine Auswahl bleibt.
  - **Probe-Lauf:** 100 Kämpfe laufen in einer Sekunde von selbst und zeigen, wie oft die Gruppe gewinnt, wie viele Züge es braucht und wie viel Leben übrig bleibt. Der Computer spielt alle Helden und pariert wie ein durchschnittlicher Spieler.
  - Noch nicht: verschiedene Stufen je Monster (eine Stufe gilt für alle), Ausrüstung und Fähigkeiten-Baum der Helden (alle Fähigkeiten, Grundausrüstung). Ye's Lernkämpfe und der Sternenfresser sind für Novizen gebaut, mit Klassen-Helden gewinnt man sie kaum.
  - **So testest du es:**
    1. Werkstatt öffnen → Editor → Kampf-Editor.
    2. Zwei Monster, deine Gruppe und einen Ort wählen, „Probe-Lauf“ drücken: Unten steht, wie oft man gewinnt.
    3. „Kämpfen!“: Der Kampf läuft am gewählten Ort, danach bist du wieder im Editor.
    4. „Kampf aus dem Spiel“ → „Rivalenkampf: Kael“ mit einer Klingentänzerin Stufe 15 ausprobieren.

- **Neu (07.11.): S1b Ablauf der Demo wie im fertigen Spiel:** Die Glutoase ist das erste Gebiet der Geschichte, Grünwacht das zweite.
  - **Bogenschütze und Zähmer:** Weg nach Grünwacht, Klasse bei Fenn bzw. Tilda und Esche, dann der neue Auftrag „Bericht bei Ysolde“. Ysolde schickt einen in die Glutoase (Hadrak ruft nach Novizen). Dort Teil 1 der Geschichte mit der Vulkanschmiede. Danach schickt Hadrak einen mit „Zurück nach Grünwacht“ heim, Ysolde begrüßt einen und Teil 2 beginnt (Leuchtende Tiere bis Pilzhöhle). Ende der Demo nach „Die Wahrheit über Rowan“.
  - **Rüstungsschmied, Klingentänzerin, Sternensängerin und alle Klassen aus noch nicht gebauten Regionen:** gleich in die Glutoase, danach nach Grünwacht. Die Geschichte von Grünwacht beginnt immer erst nach dem Ende der Glutoase.
  - Die Torwachen schicken einen beim zweiten Mal ohne ein neues „Ende von Akt 1“ los. Das Ende der Glutoase zeigt „Deine Reise geht weiter nach Grünwacht“, erst am Ende von Grünwacht kommen „Ende der Demo“ und der Tester-Code.
  - **Von dir zu entscheiden:**
    1. **Kael (erledigt 07.11.):** Der Auftrag heißt jetzt „Kael in Wipfelheim“, Ysolde und Kael wissen, dass man sich aus der Glutoase kennt (Platzhalter).
    2. **Stufen:** Grünwacht wird in der Balancing-Runde E4 auf 20–25 gehoben (Marco, 07.11.).
    3. **Platzhalter-Gespräche:** Alle 94 stehen als Liste im Brainstorm-Doc ganz oben, für spätere Brainstorming-Sitzungen. Bis dahin gelten sie als in Ordnung (Marco, 07.11.).
  - **So testest du es:**
    1. Neu beginnen, Bogenschütze wählen: nach Fenns Prüfung zu Ysolde, sie schickt dich in die Glutoase.
    2. Neu beginnen, Klingentänzerin wählen: Ye schickt dich gleich in die Glutoase; nach dem Ende der Glutoase geht es nach Grünwacht.
    3. In Grünwacht spricht Ysolde erst über die leuchtenden Tiere, wenn die Glutoase geschafft ist.
    4. Am Ende von Grünwacht: Ende der Demo mit Tester-Code.

- **Neu (06.11.): S1 Demo und Editor getrennt, Tester-Spitzname, Feedback, Tester-Code:**
  - **Zwei Fassungen im Web:** die Demo unter https://cazex-studio.github.io/MiniKampf/spiel/ (ohne Editor und ohne Testknöpfe) und deine Werkstatt unter https://cazex-studio.github.io/MiniKampf/werkstatt-glutfunke/ (mit Editor und Testknöpfen, nirgends verlinkt). Am PC in Godot ist wie bisher alles da.
  - **Startseite:** Knopf „Demo testen“, Abschnitt „So testest du“ (Spitzname, Feedback, Tester-Code, Browser), Versionsnummer, „Alle Rechte vorbehalten“ (auch als `LICENSE.md` im Repo).
  - **Spitzname:** Vor dem ersten Spielen fragt die Demo nach einem Spitznamen, danach ist er fest. Dazu bekommt jeder Tester eine Nummer (z. B. T-XGFDJ6). Beides bleibt im Browser, auch bei „Neu beginnen“, und steht unten rechts im Menü mit der Version.
  - **Feedback:** In der Welt oben rechts ein Knopf „Feedback“, im Menü „Danke & Feedback“ mit der Dankesliste (`data/dankesliste.json`, noch leer). Der Knopf öffnet dein Formular mit Spitzname, Nummer, Version und Ort schon ausgefüllt. **Das Formular fehlt noch** (deine Aufgabe, siehe unten), bis dahin sagt der Knopf, dass es bald kommt.
  - **Tester-Code:** Die Demo endet erst nach **beiden** Regionen (Marco, 06.11.): Am Ende der ersten Region startet der Weg in die andere (zurück über Kreuzweg, die Torwache schickt einen ohne zweites „Ende von Akt 1“ los). Am Ende der zweiten Region steht „Das ist das Ende der Demo“, und das Spiel zeigt den Code (z. B. AST-KWG2-V3RG) und den Knopf „Abschluss melden“ als einzigen Knopf; erst danach kommen „Zurück“ und „Zum Menü“ (wer schon gemeldet hat, sieht gleich alle). Jeder Tester bekommt genau einen Code.
  - Der kurze Hilfetext oben links in der Welt heißt jetzt „Weiter: F“, damit er nicht unter die Knöpfe läuft.
  - **So testest du es:**
    1. Startseite öffnen: Knopf „Demo testen“, darunter „So testest du“ und die Version.
    2. In der Demo: „Kreuzweg-Demo“ drücken, Spitzname eingeben. Im Menü steht kein Editor, unten rechts Version und dein Spitzname.
    3. Die Werkstatt-Adresse öffnen: Dort ist der Editor im Menü, und in der Tasche gibt es die Testknöpfe.
    4. In der Welt oben rechts „Feedback“ drücken (bis das Formular verbunden ist, kommt ein Hinweis).
    5. Erste Region zu Ende spielen: Der Abspann schickt dich in die andere Region, noch ohne Code. Nach der zweiten Region: Ende der Demo, nur „Abschluss melden“, danach „Zurück“ und „Zum Menü“.
    4. In Kreuzweg ein Silberkraut ansehen, als Klingentänzerin Klingen sammeln.

- **Neu (05.11.): E3a und E3i Wegweiser und Abschied ohne Versetzen:** Nach dem Abschied von Ye wird man nicht mehr versetzt. Ye sagt: „Geh zur Torwache, sie kennt den Weg in deine Region.“ Am Westtor (Grünwacht) und am Südtor (Glutoase) steht jetzt je eine Torwache; der Wegweiser führt zu ihr. Sie nennt den Weg, „Losgehen.“ zeigt das Ende von Akt 1 (bei Glutoase-Klassen jetzt mit Südstraße und „Weiter in die Glutoase“), danach läuft man selbst durchs Tor. Auf dem Weg zeigt der Wegweiser weiter bis Wipfelheim bzw. bis zur Glutoase und zum Oberhaupt, danach zum Lehrmeister.
  - **So testest du es:**
    1. Klasse wählen, von Ye verabschieden: Man bleibt in Kreuzweg, der Wegweiser zeigt zur Torwache.
    2. Torwache ansprechen, „Losgehen.“: Ende von Akt 1, dann selbst durchs Tor laufen.
    3. Als Klingentänzerin: Der Wegweiser führt durch die Aschensteppe bis zu Hadrak und dann zu Samira.

- **Neu (04.11.): E1 Deine Entscheidungen eingebaut:** Die Sporenkönigin nutzt jetzt auch in der Welt ihre Mechanik (pro Kampf Sporenblüte oder Zwillinge, wie in der Sandbox). Damit es allein schaffbar bleibt, hat sie weniger Leben (2,0 statt 3,8): im Schnitt 77 % Siege. Nebenbei behoben: Töteten die Giftwolken die letzten Helden, wollte sie noch angreifen und hängte. Für die Lichter in Kreuzweg gibt es Vergleichsbilder (echte Lichter oben, Leuchtflecken unten); ohne deine Zusage bleibt es bei den echten Lichtern.
  - **So testest du es:**
    1. In der Pilzhöhle die Sporenkönigin angreifen: Unten im Protokoll steht die Mechanik des Kampfs.
    2. Bei Sporenblüte: ab drei Giftwolken „Giftwolke vertreiben“ nutzen.
    3. Bei Zwillingen: beide Sporenknospen in derselben Runde besiegen.

- **Offene Punkte für dich (gesammelt 04.11., D36):** Alles, was im Moment auf deine Entscheidung, deine Bilder oder das Balancing wartet.
  - **Balancing (am Ende, Marcos Hinweis 04.11.: stärkere Monster dürfen bleiben):** Kael in der Glutoase (73 %, der Rüstungsschmied schafft ihn selten), Glasskorpion-Gruppen in der Palmenrast (um 50–60 %), die Gruppen der Vulkanschmiede allein (51–100 %), Ritualist und Zwielicht allgemein schwächer allein. Die Sporenkönigin nutzt in der Welt ihre Mechanik (Giftwolken oder Zwillinge) nicht; mit Mechanik gewinnt man allein nur 36 %: Soll sie sie bekommen?
  - **Entscheidungen (Marcos Antworten 04.11., E1):** Sporenkönigin bekommt ihre Mechanik in der Welt (eingebaut). Glutgeist „trifft die vordere Reihe“ passt. Namen Hammer-Bruder, Zangen-Bruder, Kettenbrecher und Kettenglut-Set bleiben erst einmal. Kobalt nutzt vorerst den Zähmer-Körper, bekommt später einen eigenen (steht unter „Später“). **Noch offen:** Lichter in Kreuzweg durch Leuchtflecken ersetzen? Vergleichsbilder hast du; ohne Zusage bleiben die echten Lichter. Die Sternensängerin gibt es vorerst nur weiblich.
  - **Texte:** Alle Dialoge sind Platzhalter, die Hauptfiguren schreibst du selbst (Anleitung in `data/LIESMICH.md`).
  - **Noch nicht drin:** Set-Boni, Waffen nur für die eigene Klasse, zufällige Bonus-Werte bei Beute.

- **Neu (04.11.): D36 Web-Version und Demo-Seite** (neu): **Kleiner:** Die gemalten Bilder (Figuren, Porträts, Figurteile, Baukasten-Objekte) werden jetzt verlustbehaftet gespeichert statt verlustfrei (`tools/web_bilder.py`, läuft auch automatisch beim Web-Export). Im Spiel sehen sie gleich aus und sind genauso groß, aber das Spielpaket ist 73 MB statt rund 250 MB. Pixel-Grafik, Oberfläche, Bodenkacheln und kleine Bilder bleiben, wie sie sind. **Ladezeit:** Beim ersten Start lädt der Browser jetzt etwa 80 MB (Spiel und Godot), mit guter Leitung rund 10 bis 20 Sekunden, am Handy im Mobilfunk deutlich länger. **Demo-Seite:** https://cazex-studio.github.io/MiniKampf/ zeigt jetzt eine Startseite „Asterfall – Demo“ mit vier Bildern aus dem Spiel, was in der Demo steckt, der Steuerung am PC und am Handy und einem großen Knopf „Spielen“. Das Spiel selbst liegt unter https://cazex-studio.github.io/MiniKampf/spiel/ (dein Spielstand bleibt erhalten). Die Texte der Seite sind Platzhalter (`web/index.html`). **Offene Punkte:** gesammelt im Abschnitt darüber.
  - **So testest du es:**
    1. https://cazex-studio.github.io/MiniKampf/ öffnen (PC und Handy): Startseite ansehen.
    2. „Spielen“ drücken: Das Spiel lädt, der alte Spielstand ist noch da.
    3. Ein paar Figuren und Kämpfe ansehen: Sehen die Bilder so gut aus wie vorher?

- **Neu (04.11.): D35 Ende der Glutoase: Miras Splitter** (2.10, design.md): Die Geschichte der Glutoase ist zu Ende gebaut. Nach dem Sieg über Kael schickt Hadrak einen los: „Ketten. Unten. … Geh.“ (Auftrag „Die Ketten unter dem Berg“). **Belohnung der Vulkanschmiede:** Wo der Kettenschmied zerfiel, glüht ein Splitter in der Schlacke. Beim ersten Abschluss gibt es einen Sternensplitter und die einzigartige Klinge **Kettenbrecher** (episch). Bei jedem weiteren Lauf gibt es einen Sternensplitter und das nächste Teil des **Kettenglut-Sets** (Helm, Panzer, Stiefel, selten; einen Set-Bonus gibt es noch nicht). Zurück bei Hadrak: „Die Anker. … Halten? Gut.“ Dann: „Mira. … Schlimmer.“ **Miras Splitter:** Mira bittet dich zu entscheiden: „Den Splitter herausnehmen.“ oder „Den Splitter bei ihr lassen.“ (die Knöpfe nennen keine Folgen). Nimmst du ihn, ist sie gesund und steht wieder, aber es ist „so still“, und du bekommst den Splitter. Lässt du ihn, bleibt sie krank, hört aber den sechsten Ton fast: „Er klingt wie … ein Name.“ Zuletzt dankt Hadrak, und es kommt der **Rückblick „Ende der Glutoase“** (wie bei Grünwacht: was du entschieden hast, dann zurück in die Glutoase). Alle Texte sind Platzhalter.
  - **So testest du es:**
    1. Nach Kael mit Hadrak reden, durch die Vulkanschmiede bis zum Kettenschmied.
    2. In der Ankerkammer den glühenden Splitter aufheben (Kettenbrecher in der Tasche), dann zu Hadrak.
    3. Bei Mira am Krankenzelt entscheiden.
    4. Zu Hadrak: Der Rückblick „Ende der Glutoase“ erscheint.

- **Neu (04.11.): D34 Vulkanschmiede Teil 3: der Kettenschmied** (2.9, design.md Sitzung 24): Endboss in der Mitte der Ankerkammer, erst nach den Hammerbrüdern. Ein Wesen aus Schlacke und Glut, Tessa und Gorm kämpfen mit. **Phase 1:** Lavaflut: Bei jedem seiner Züge reißt er an einer Ankerkette, ein Anker wackelt (steht beim Kettenschmied: „Anker: fest, WACKELT, fest“). Wer „Anker festhämmern“ wählt (jede Klasse, kostet den Zug), hält ihn; sonst reißt er beim nächsten Zug aus. Sind alle drei lose, flutet die Lava die Kammer. Gefesselt: Jeder dritte Zug kettet er zwei Helden aneinander, sie teilen jeden Schaden, ein Dritter kann „Kette zerschlagen“. Der Lava-Takt läuft weiter. **Phase 2 „Entfesselt“:** Die Ketten reißen, der Lava-Takt endet, stattdessen steigt die Lava alle drei seiner Züge um eine Stufe (Schaden für alle); auf Stufe 6 schmilzt alles. Am Rand steht das Kühlbecken: Wer es angreift, wird nass (rutscht auf der Zugleiste zurück, zwei seiner Züge lang). Sein Panzer hält ein Viertel des Schadens ab; ein nasser Held mit einem harten Treffer sprengt ein Stück ab (3 Stücke). Die glühende Kette lässt sich erst zerschlagen, wenn beide Gefesselten nass sind. Allein mit Tessa und Gorm gewinnt man im Schnitt 76 % der Kämpfe. Die Belohnung (Sternensplitter, Set, Unique-Waffe) und das Ende kommen mit D35.
  - **So testest du es:**
    1. Nach den Hammerbrüdern in die Ankerkammer und den Kettenschmied ansprechen.
    2. Wackelt ein Anker, „Anker festhämmern“ wählen; einmal absichtlich nicht, um zu sehen, wie er ausreißt.
    3. Wenn zwei gefesselt sind, mit dem Dritten „Kette zerschlagen“.
    4. In Phase 2 ins Kühlbecken schlagen und dann den Kettenschmied hart treffen.

- **Neu (04.11.): D33 Vulkanschmiede Teil 2: die Hammerbrüder** (2.8, design.md Sitzung 24): Auf der unteren Plattform der Kettengänge stehen zwei riesige Ambossknechte aus Hadraks Schmiede, der Hammer-Bruder und der Zangen-Bruder (dein Bildblatt zeigt beide zusammen, ein Werkzeug schneidet es in zwei Figuren). Zwischenboss mit Tessa und Gorm an deiner Seite, der Lava-Takt läuft weiter. Pro Kampf zufällig eine Mechanik: **Doppelschlag** (beide holen aus, zwei Züge vorher angekündigt; schlagen sie gemeinsam zu, fällt die ganze Gruppe. Jede Klasse hat dann die Aktion „Bruder stören“, ein gestörter Bruder reicht) oder **Gleichschritt** (liegt einer im Leben deutlich vorn, wird der schwächere rasend und schlägt viel härter; gleichmäßig schwächen beruhigt ihn; fällt einer, während der andere noch viel Leben hat, tobt der andere). Nach dem Sieg sind sie für diesen Durchgang weg. Allein (mit Tessa und Gorm) gewinnt man im Schnitt 84 % der Kämpfe. Die Namen „Hammer-Bruder“ und „Zangen-Bruder“ sind Platzhalter. Nebenbei behoben: Wer festgehalten wurde und sonst nichts tun konnte (z. B. Quartiermeister ohne Gold), blieb im Kampf hängen; jetzt kann er dann abwarten. **Für das Balancing:** Die Sporenkönigin nutzt in der Welt ihre Mechanik (Giftwolken oder Zwillinge) gar nicht, nur im Übungskampf. Mit Mechanik gewinnt man allein nur gut ein Drittel; ich habe es so gelassen.
  - **So testest du es:**
    1. In der Vulkanschmiede über die Kettenbrücke zur unteren Plattform, die Brüder ansprechen und angreifen.
    2. Unten im Kampfprotokoll steht, welche Mechanik heute gilt.
    3. Doppelschlag: Wenn beide ausholen, „Bruder stören“ wählen.
    4. Gleichschritt: einen Bruder stark schwächen und zusehen, wie der andere rasend wird.

- **Neu (04.11.): D32 Vulkanschmiede der Ketten, Teil 1** (2.7, design.md Sitzung 24): Der erste große Dungeon. Nach dem Sieg über Kael lassen sich die Ketten am glühenden Gang hinter Hadraks Schmiede beiseiteschieben, vorher bleibt er zu. Unten drei Abschnitte: die **Schmiedehallen** (verlassene Essen, Eisenwände, Ambosse, Kühlbecken), die **Kettengänge** (Kettenbrücken über dem dunklen Abgrund mit zwei Plattformen und Kettenwinden) und die **Ankerkammer** mit drei großen Ankern (dort kommen später Hammerbrüder und Kettenschmied hin). Fünf eigene Monster nach Steckbrief, Stufe 15–20: Schlackenkriecher, Glutgeist, Ambossknecht, Aschefalter, Magmaschnecke, dazu selten der Messingwächter (Hadraks Probe-Automat). Alle mit Beute, Material und Sammelkarte. Neuer Kampf-Hintergrund: Schmiedehalle mit Lavafluss, glühenden Essen und hängenden Ketten. **Lava-Takt:** In jedem Kampf dort steigt die Lava alle 4 Runden, abwechselnd vorne und hinten, zwei Runden vorher angekündigt (Schriftzug und pulsierendes Glühen unter der Reihe). Wer dann noch dort steht, verliert 15 % Leben; Reihe wechseln (ein Zug) rettet. Die Monster spielen mit: Der Schlackenpanzer hält in der Lava-Runde doppelt, die Magmaschnecke heilt nur bei Lava, der Glutgeist explodiert beim Tod („Letzte Glut“). **Deine Entscheidung:** „trifft seine Reihe“ habe ich als „trifft die vordere Reihe der Helden“ gebaut; sag Bescheid, wenn du es anders meinst. Allein sind die Gruppen schwer (51–100 % Siege), der Dungeon ist für Gruppen gedacht. Nebenbei: Die Test-KI des Rüstungsschmieds nimmt sein Meisterstück nicht mehr, solange noch ein Schild hält.
  - **So testest du es:**
    1. Nach dem Kampf gegen Kael ganz oben hinter Hadraks Schmiede den Gang benutzen und hinabsteigen.
    2. Durch die Schmiedehallen, über die Kettenbrücken bis in die Ankerkammer laufen.
    3. Einen Kampf beginnen und auf die Lava achten: bei der Warnung die Reihe wechseln.
    4. Einen Glutgeist besiegen und schauen, wen die Explosion trifft.

- **Neu (04.11.): D30 Glutgrat über den Bergpfad** (2.6, mit D31): Der Bergpfad am Ostrand des Schmiedeviertels führt jetzt hinauf auf den Glutgrat, das Wilde Land der Glutoase (Stufe 15–20, frei leveln). Ein Serpentinenpfad zieht sich zwischen erkalteter Lava, glühenden Lavarinnen, Felsgraten, heißen Quellen und Obsidian bis zum Kraterrand. Tags leben dort Schlackenbock, Glutsalamander, Rauchgeier und Geysirkrabbe, nachts Glutfledermaus und Obsidiangolem; oben am Krater kreist selten die Gewitterwyvern (Brocken). Alle sieben haben Beute, Materialien und Sammelkarten (Seite Glutoase). Damit stehen die Monster nach Regelblatt in allen drei Gebieten der Glutoase (D31 erledigt). Unten am Pfad geht es zurück in die Stadt.
  - **So testest du es:**
    1. Im Schmiedeviertel ganz nach Osten zum Schild „Bergpfad zum Glutgrat“ und ihn benutzen.
    2. Den Pfad hinauf bis zum Kraterrand laufen und Monster ansehen (Stufe 15–20).
    3. Nachts (Uhr +3 h) wiederkommen: andere Monster.
    4. Unten am Pfad zurück in die Stadt.

- **Neu (04.11.): D29 Geschichte der Glutoase, Teil 2** (2.5, design.md): **Der Tanz mit der Pause:** Nach Miras Lied lädt Samira zum Fest ein. Nachts tanzt man auf dem Tanzplatz ihre fünf Schritte (warm nach vorn, leicht zur Seite, langsam drehen, klatschen, Arme zu den Sternen; ein falscher Schritt, und Samira fängt noch mal an). Dann die Pause: Wer weitertanzt, wird ermahnt; wer stillhält und lauscht, hört für einen Herzschlag den sechsten Ton. Da taucht Kael auf und provoziert Hadrak. **Rivalenkampf:** Kael wartet oben in Hadraks Schmiede, mit deinen Kampfbildern (Klingenschritt, Ausfallschritt auf die hintere Reihe, Klingenwirbel auf alle). Danach dankt Hadrak in zwei Worten. Wer Brakkus bei den kochenden Brunnen geholfen hat (Hadraks Vertrauen), hört nachts vor dem Gasthaus den betrunkenen Hadrak: „Wir waren sechs. Nicht fünf. … Wir sind gerannt.“ Texte sind Platzhalter. Kael ist allein im Schnitt in 3 von 4 Kämpfen zu schlagen, für den Rüstungsschmied ist er schwer (beim Balancing ansehen).
  - **So testest du es:**
    1. Nach Miras Lied mit Samira reden, nachts (Uhr +3 h) wieder auf den Tanzplatz.
    2. Die fünf Schritte tanzen, in der Pause stillhalten.
    3. Zu Hadraks Schmiede hinauf und gegen Kael kämpfen, dann mit Hadrak reden.
    4. Nachts vor dem Gasthaus noch einmal mit Hadrak reden.

- **Neu (04.11.): D28 Geschichte der Glutoase, Teil 1** (2.4, design.md): Zwei Aufträge, nachdem man bei Hadrak angekommen ist. **Kochende Brunnen:** Nadia am großen Brunnen bittet, die beiden Wasserstellen in der Palmenrast zu prüfen. Im Nordwesten ist das Wasser warm wie Tee, im Nordosten dampft und blubbert es, und aus dem Dampf kommen zwei Feuerechsen und eine Oasenkröte (Kampf mit der eigenen Klasse). Brakkus ahnt danach: Hadraks alte Ketten unter dem Berg geben nach. **Miras Lied:** Mira summt im Fieber eine Melodie aus den Splittern. Man schreibt sie mit ihr Ton für Ton auf, indem man beschreibt, wie es klingt (Glut, Blatt, Nebel, Funke, Stern; bei einem falschen Ton summt sie noch einmal). Dann kommt eine Pause: Ein sechster Ton fehlt. Belohnung: Miras Notenblatt. Texte sind Platzhalter.
  - **So testest du es:**
    1. Als Glutoase-Klasse nach Hadrak bei Nadia am Brunnen „Kochende Brunnen“ annehmen.
    2. Durchs Osttor in die Palmenrast: erst die Wasserstelle im Nordwesten, dann die im Nordosten (Kampf).
    3. Zu Brakkus ins Schmiedeviertel, dann zurück zu Nadia.
    4. Bei Mira am Krankenzelt die fünf Töne aufschreiben; das Notenblatt liegt danach in der Tasche.

- **Neu (04.11.): D27 Glutoase-Figuren nach Steckbrief** (2.13, NPC.md): Die Stadt ist belebt. Brunnenhüterin Nadia (mit Wasserkrug, „Das Wasser fiebert wie ein Kind.“), Karawanenführer Zaid am Karawanenplatz (prahlt mit siebzig Kamelen, nachts erzählt er am Feuer), Bankhüter Rashid in der Bank (Kopftuch, Schlüssel, Zeichen Truhe), Händler Tarek vor seinem Laden (Schärpe, Klinge am Gürtel; verkauft Grundwaffen, Tränke und Grundmaterialien), Wirtin Layla vor der Glutstube (Schürze, Tablett, nachts schenkt sie Hadrak nach) und Mira, die krank vor dem Krankenzelt liegt. Alle mit Porträts. Dazu das Volk: drei Schmiede im Schmiedeviertel, Basarleute (nur tags), Karawanenleute, der Aufzugwärter („Festhalten, es ruckelt.“), nachts zwei Tänzer auf dem Tanzplatz neben Samira und Gäste vor dem Gasthaus. Am Rastplatz der Aschensteppe steht jetzt der Rastplatz-Händler (Tränke und Grundmaterialien, an jedem Rastplatz gleich). Nebenbei: Breite, flache Bilder (Mira liegend) werden jetzt richtig klein gezeichnet. Noch nicht drin: Zaids Reiseumhang, die Aufträge der Figuren (kommen mit der Geschichte der Glutoase).
  - **So testest du es:**
    1. In der Oase alle ansprechen: Nadia am Brunnen, Zaid, Rashid (Bank), Tarek (Laden), Layla, Mira am Krankenzelt.
    2. Nachts (Uhr +3 h): Tänzer auf dem Tanzplatz, Hadrak und Gäste vor dem Gasthaus, Basar leer.
    3. Am Rastplatz der Aschensteppe beim Rastplatz-Händler einkaufen.

- **Neu (04.11.): D26 Klassen lernen in der Glutoase** (2.3): Wer Rüstungsschmied, Klingentänzerin oder Sternensängerin wählt, reist nach dem Abschied von Ye nicht mehr nach Grünwacht, sondern durch das Südtor in die Aschensteppe (Auftrag „Der Weg in die Glutoase“). Oben in seiner Schmiede begrüßt einen Hadrak Glutherz, mit deinen Bildern und Porträts (fast nur Einwortsätze; nachts steht er vor dem Gasthaus). Danach lernt man die Klasse mit einer kleinen Prüfung als Lernkampf: bei Essenmeister Brakkus vor seiner Werkstatt im Schmiedeviertel (die Rüstung muss halten), bei Tanzmeisterin Samira auf dem Tanzplatz (Schrittfolge im Takt) oder bei der Hohen Sängerin Xavina auf der Sternendüne in der Palmenrast (dort ist es beim Lernen immer Nacht). Erst danach kämpft man mit der Klasse. Die anderen Klassen reisen wie bisher nach Grünwacht. Noch nicht drin: Rüstungsschmied und Sternensängerin haben noch keinen eigenen Körper (D25b), die übrigen Figuren der Stadt (D27), Hadraks lange Sätze, wenn er betrunken ist.
  - **So testest du es:**
    1. Neues Spiel bis zur Klassenwahl, Klingentänzerin wählen, von Ye verabschieden: Ankunft in der Aschensteppe.
    2. Bis in die Glutoase laufen und ganz oben Hadrak ansprechen.
    3. Auf dem Tanzplatz Samiras Prüfung tanzen, danach erneut mit ihr reden: jetzt Klingentänzerin.
    4. Mit einem zweiten Spielstand Sternensängerin: Xavina auf der Sternendüne in der Palmenrast.

- **Neu (04.11.): D25a Körper der Klingentänzerin** (2.11): Deine Blätter für Klingentänzer (m) und Klingentänzerin (w) sind eingebaut: Tanzkleidung in Orange und Gold mit Schärpe und wehenden Tüchern, im Kampf mit Drehung, Abwehr, Fähigkeit und Sieg, in der Welt schräg von vorne und hinten. Wer die Klasse gelernt hat, trägt sie mit seinem eigenen Kopf, und in der Probestunde spielt man die Klingentänzerin mit der eigenen Figur in Tanzkleidung. Noch nicht drin: Rüstungsschmied und Sternensängerin (D25b, dafür fehlen noch die Blätter).
  - **So testest du es:**
    1. Kampf-Sandbox oder Probestunde Klingentänzerin: die eigene Figur in Tanzkleidung, Drehung beim Angriff.
    2. Nach der Klassenwahl Klingentänzerin: In der Welt läuft man in Tanzkleidung herum.

- **Neu (04.11.): D24 Stadt Glutoase als Terrassenstadt** (2.2, design.md, beschlossen 29.10.): Am Südende der Aschensteppe liegt jetzt die Glutoase, eine Stadt in drei Stufen am Vulkanhang. **Unten die Oase**: Karawanenplatz, großer Brunnen mit Oasengras und Palmen, Tanzplatz mit Laternen, Basar, Tareks Laden, Bank, Gasthaus „Glutstube“ mit Lagerfeuer, Krankenzelt, Wegelaterne und das (noch verriegelte) Tor zum Dürrewald; durch das Osttor geht es in die Palmenrast. **In der Mitte das Schmiedeviertel**: Werkstätten der Schmiedeclans, Brakkus' Werkstatt, die Schmiede-Werkstatt, Essen, Ambosse und der (noch verschüttete) Bergpfad zum Glutgrat. **Oben Hadraks Schmiede** mit dem Kettenamboss, Lavarinnen und dem (noch verschlossenen) Eingang zur Vulkanschmiede. Zwischen den Stufen Lehmmauern mit Treppen in der Mitte, dazu der Lastenaufzug als Abkürzung von der Oase hinauf zu Hadraks Schmiede. Noch nicht drin: die Figuren (D27), eigene Stadt-Musik der Glutoase, Glutgrat, Dürrewald und Vulkanschmiede.
  - **So testest du es:**
    1. Die Aschensteppe ganz nach Süden: Ankunft in der Oase der Glutoase.
    2. Über die Treppen hinauf ins Schmiedeviertel und weiter zu Hadraks Schmiede.
    3. Unten neben dem Krankenzelt den Lastenaufzug benutzen.
    4. Durch das Osttor der Oase in die Palmenrast.

- **Neu (04.11.): D23b Palmenrast** (2.1): Am Südende der Aschensteppe geht es in die Palmenrast, das Heimat-Gebiet der Glutoase: Wüste mit einem Oasenteich voller Palmen in der Mitte, Wasserstellen, Dünen, einer Ruine und im Südosten Xavinas Sternendüne mit ihrem Zelt. Monster nach Steckbrief (Stufe 12–19): Feuerechse (Feueratem auf die vordere Reihe), Oasenkröte (Quellregen heilt alle), Glasskorpion (lähmt, Glaspanzer), Sandwurm (taucht an der hinteren Reihe auf, hält fest), nachts Staubgeist und Mondschakal (ruft einen zweiten), selten der Stachelflitzer (flink, saust nach drei Runden davon, bringt immer seine Karte). Sieben neue Materialien und Karten für die Glutoase-Seite. Noch nicht drin: die Stadt Glutoase dazwischen (D24, bis dahin führt die Steppe direkt in die Palmenrast), Xavina auf der Sternendüne, Glutgrat.
  - **So testest du es:**
    1. Die Aschensteppe ganz nach Süden durchqueren: Palmenrast.
    2. Um den Oasenteich laufen, im Südosten die Sternendüne ansehen.
    3. Gegen Glasskorpion und Sandwurm kämpfen, im Osten den Stachelflitzer suchen.

- **Neu (04.11.): D23a Aschensteppe mit dem Rastplatz der Karawanen** (2.1): Durch das Südtor von Kreuzweg (nach der Klassenwahl offen, wie der Weg nach Grünwacht) geht es in die Aschensteppe, die Straße zur Glutoase: oben Grasland mit Steppengras und Felsen, nach Süden immer mehr Sand mit Dünen, Kakteen, einer Ruine und einer Wasserstelle. In der Mitte liegt der Rastplatz der Karawanen mit Lagerfeuer, Zelt, Sonnensegel, Wagen und der ersten Wegelaterne der Straße: Dort greifen keine Monster an. Monster nach Steckbrief (Stufe 9–12): Steppenroller, Steppenhyäne, Kaktusling, Funkenechse, nachts Aschefuchs und Schattenskarabäus, selten der Sonnenlöwe ganz im Süden. Sieben neue Materialien und eine neue Album-Seite „Glutoase“ (noch ohne Belohnung, das entscheidest du). Noch nicht drin: der Rastplatz-Händler (D27), die Palmenrast im Süden (D23b), eigene Musik und ein eigener Kampf-Hintergrund für die Steppe (bis dahin Wald-Musik und Wiese).
  - **So testest du es:**
    1. Nach der Klassenwahl in Kreuzweg über die Brücke nach Süden aus der Karte laufen.
    2. Bis zum Rastplatz in der Mitte gehen: Lagerfeuer, Zelt, Wegelaterne ansprechen; dort greift nichts an.
    3. Gegen Steppenhyäne und Funkenechse kämpfen, ganz im Süden den Sonnenlöwen suchen.
    4. Nachts (Uhr +3 h): Aschefuchs und Schattenskarabäus.

- **Neu (04.11.): Tiefwurzel als eigenes Gebiet** (Marcos Wunsch): Tiefwurzel ist jetzt eine eigene Karte südlich vom Waldboden. Im Süden des Waldbodens führt ein Pfad zwischen Wurzeln („Nach Tiefwurzel“) hinunter in einen dunklen Wald mit verdorrten Bäumen, großen Wurzeln, Splitterkristallen und Nebel am Boden. Dort leben die Tiefwurzel-Monster (Stufe 20), der Waldboden ist nur noch der Wachtwald. Über den „Pfad nach oben“ geht es zurück. Werkzeug: `tools/gruenwacht_karten.py tiefwurzel`.
  - **So testest du es:**
    1. Im Waldboden ganz nach Süden zum Pfad „Nach Tiefwurzel“ laufen.
    2. In Tiefwurzel gegen Moosgolem und Rankenschlinger kämpfen, nachts Splitterwolf und Moderfalter suchen.
    3. Über den Pfad im Norden zurück in den Waldboden.

- **Neu (04.11.): D22c Pilzhöhle nach Steckbrief** (1.11, MONSTER.md): Die Monster der Pilzhöhle kämpfen jetzt nach ihrem Steckbrief, als Dungeon-Monster 10 % stärker: Leuchtmotte (Blendflügel, Lichtfraß blendet, heilt andere), Wurzelkriecher (Wurzelgriff hält fest, kommt durch den Boden an die hintere Reihe, Rindenpanzer), Sporenwolf (Rudelbiss wird mit jedem weiteren Sporenwolf stärker, Sporenwolke vergiftet die vordere Reihe, Hetzjagd aufs schwächste Ziel), Glimmerkäfer (lädt sich auf, dann trifft die Entladung zwei Ziele). Neu und selten: der Schatzpilzling ganz im Südwesten der Höhle, sehr flink und schwer zu treffen, er läuft nach drei Zügen weg, bringt aber immer seine Karte und eine Goldspore. Die Bosse zeigen ihre besonderen Bewegungen bei ihren großen Angriffen: Sporenkönigin bei Giftsporen, Sporenknospe beim Heilen, Wurzelmutter bei Wurzelzug und Verschlingen, Vorbote bei Schattenwelle und Lichtfraß. Noch nicht drin: Ein weggelaufener Schatzpilzling zählt noch als Sieg (ohne Extra-Gold), der Glimmerpanzer zahlt Treffer noch nicht zurück (dafür bräuchte es einen neuen Effekt).
  - **So testest du es:**
    1. In der Pilzhöhle gegen zwei Sporenwölfe kämpfen: Zu zweit beißen sie härter.
    2. Glimmerkäfer beobachten: erst „Lädt sich auf!“, dann die Entladung auf zwei.
    3. Im Südwesten der Höhle den Schatzpilzling suchen und schnell sein.
    4. Sporenkönigin und Wurzelmutter: auf ihre besonderen Bewegungen achten.

- **Neu (04.11.): D22b Wachtwald und Tiefwurzel** (1.11, MONSTER.md): Im Wald unter Wipfelheim (Waldboden) kämpfen jetzt alle Monster nach Steckbrief. Oben im Norden der **Wachtwald** (Stufe 12–19): Windfalke (zwei schnelle Krallenstöße, Aufwind), Rindenbär (Prankenhieb, Borkenhaut), Steinkröte (trifft die hintere Reihe, Steinhaut), Sporenling (Gift, Sporenregen heilt die anderen), nachts Nachtuhu und Funkenmarder, selten der Wipfelluchs. Moosling, Glutwelpe und Bachotter laufen sehr selten wild herum (mit ihren 2 Fähigkeiten, immer mit Karte). In **Tiefwurzel** (Stufe 20, seit dem Nachtrag eine eigene Karte südlich vom Waldboden): Donnerhirsch, Sumpfschnapper, Moosgolem, Rankenschlinger, nachts Splitterwolf (ruft einen zweiten) und Moderfalter (Schattenmale), selten der Splitterbär. Sieben neue Materialien für Hatta, sieben neue Karten im Grünwacht-Album. Noch nicht drin: Stufen über 20 (die Demo endet bei 20, laut Steckbrief wären es 20–25); Nachtruf und Luchsblick sind vereinfacht (Schutz für alle bzw. starker Hieb aufs schwächste Ziel), weil es „stärker machen“ und „sicher kritisch“ in der Effekt-Liste noch nicht gibt.
  - **So testest du es:**
    1. Im Wald oben gegen Windfalke und Steinkröte kämpfen, im Nordwesten selten den Wipfelluchs suchen.
    2. Nach Tiefwurzel: Donnerhirsch lähmt, Sumpfschnapper hält fest.
    3. Nachts (Uhr +3 h) im Süden: Splitterwolf ruft Hilfe, Moderfalter setzt Schattenmale.

- **Neu (04.11.): D22a Monster nach Regelblatt, Teil 1** (1.11, MONSTER.md): Monster werden jetzt aus ihrem Steckbrief gebaut (`data/monster.json`): Leben, Angriff, Tempo und Abwehr kommen aus einer Tabelle nach Rolle (Tank, Verteidiger, Angreifer, Helfer) und wachsen mit der Stufe; Nacht-Monster sind 15 % stärker, seltene Brocken haben 50 % mehr Leben. Jede Fähigkeit nutzt die Effekt-Bausteine: Monster schützen sich (Zusammenziehen, Panzer hoch), heilen andere (Samenflug, Lichtfunke), rufen Hilfe (Heulen, Schleimruf, einmal pro Kampf), treffen mehrmals (Doppelsprung, Scherenschnapp), halten fest, lähmen, vergiften oder lassen verfehlen. Die besondere Fähigkeit jeder Art zeigt ihre eigene Bewegung. Auf dem Weg nach Grünwacht (Hirschtal, Stufe 9–12, der obere Teil der Steckbrief-Stufen, weil man mit etwa Stufe 10 aus Kreuzweg kommt) leben jetzt Dornenranke, Bachkrebs, Borstenkeiler und Zankelster, nachts Heulwolf und Irrlicht, dazu selten der Kronhirsch: Er kommt erst nach einer langen Weile wieder und bringt immer seine Karte. Neue Materialien für Hatta und fünf neue Karten im Grünwacht-Album. Ye's Lektionen nutzen die Kreuzwegfelder-Monster nach Steckbrief auf ihrer kleinsten Stufe. Noch nicht drin: ein Gebiet „Kreuzwegfelder“ zum Herumlaufen, Glutstacheln zahlen Nahkampf nicht zurück, die Elster stiehlt noch kein Geld, Wachtwald, Tiefwurzel und Pilzhöhle (D22b, D22c).
  - **So testest du es:**
    1. Weg nach Grünwacht: gegen Dornenranke (hält fest), Bachkrebs (zwei Kniffe, Panzer) und Zankelster (trifft hinten) kämpfen.
    2. Nachts (Uhr +3 h): Heulwolf ruft einen zweiten Wolf, das Irrlicht heilt ihn.
    3. Den Kronhirsch ganz im Westen des Wegs suchen: zäh, Karte gibt es immer.
    4. Bei Ye die Lektionen spielen: Tauschleim zieht sich zusammen, Löwenzahnling heilt.

- **Neu (04.11.): D21b Volk in Grünwacht** (1.10, NPC.md): In Wipfelheim sind jetzt Leute unterwegs, alle aus dem Baukasten, jeder mit einem Satz in Grünwacht-Art: zwei Jäger mit grüner Kapuze (Jäger bei Fenns Schießplatz, Jägerin bei Tildas Stall) erzählen von veränderten Tieren, zwei Sammlerinnen mit Korb reden über Pilze und Kräuter (nur tags), zwei Kinder an der Nordbrücke spielen Jäger und Hirsch (nur tags), und vor dem Gasthaus erzählen Gäste Gerüchte über die Pilzhöhle (zwei davon nur nachts). Noch nicht drin: Das Volk läuft keine Runden.
  - **So testest du es:**
    1. Tagsüber durch Wipfelheim: Jäger, Sammlerinnen und die Kinder an der Nordbrücke ansprechen.
    2. Mit „Uhr +3 h“ auf Nacht: Sammlerinnen und Kinder sind weg, vor dem Gasthaus stehen drei Gäste.

- **Neu (04.11.): D21 Grünwacht-Figuren nach Steckbrief** (1.10, NPC.md): Ysolde, Fenn, Tilda, Esche und Kael laufen mit deinen eigenen Bildern, Salbei (Kräuterbündel, Korb), Tamm (Hut mit Moos), Oma Hagebutte (Kartenstapel) und Kobalt (Zähmer-Körper, auch im Kampf) tragen ihre eigenen Köpfe. Neu ist Wirt Borko mit Kochmütze und Schöpfkelle vor dem Baumhaus-Gasthaus (brummig, großzügig; Kochen kommt später). Alle haben ihr Porträt im Gespräch. Nachts steht Ysolde allein am Südostrand des Dorfs („Nachts hat der Wald andere Augen.“), Fenn am Rand der Mittelplattform, Oma Hagebutte beim Gasthaus, Kobalt ist nicht zu sehen. Noch nicht drin: das leere Grab von Rowan (Ysolde steht bis dahin am Rand), Hagebuttes Strickjacke, Kael im Kampf mit eigenen Bildern, das Volk (D21b).
  - **So testest du es:**
    1. In Wipfelheim alle ansprechen: eigene Bilder und Porträts.
    2. Borko vor dem Gasthaus ansprechen.
    3. Mit „Uhr +3 h“ auf Nacht: Ysolde am Südrand ansprechen, Kobalt ist weg.

- **Neu (04.11.): D20d Kreuzweg bei Tag und Nacht** (1.9, NPC.md): Die Figuren stehen nach der Uhr an ihren Plätzen. Nachts ist Ye (am Tor) in der Gilde und hat „Nachtschicht“, Marv sitzt im Wegrast, Tessa und Gorm (neu in der Stadt, mit je einem Satz für Tag und Nacht) übernachten dort auch, und drei Gäste machen den Wegrast voll. Edmar, Quill, Pip und Lotte sind nachts zu Hause (am Festabend sind sie da). Neu ist das Volk aus dem Baukasten: Marktfrau Rosa und Gemüsehändler Jost an den Marktständen, vier Bürger auf dem Platz (nachts nur der alte Bürger), dazu die drei Torwachen jetzt mit Wachen-Körper. Jeder sagt einen Satz. Nachts sind die beiden Marktstände zu (mit deinen Bildern: Vorhang herunter, Kisten zu); Bingo, Hatta, Bank, Gilde und Wegrast bleiben offen. Noch nicht drin: Das Volk läuft noch keine kleinen Runden, und die Halstücher zum Fest fehlen.
  - **So testest du es:**
    1. Tagsüber über den Marktplatz: Rosa und Jost an den Ständen, Bürger ansprechen.
    2. Mit dem Test-Knopf „Uhr +3 h“ auf Nacht stellen: Stände zu, Kinder, Quill und Edmar weg.
    3. Nachts zum Wegrast: Hanne, Marv, Tessa, Gorm und die Gäste.
    4. Nach der Grundausbildung nachts Ye vor der Gilde ansprechen: „Nachtschicht …“.

- **Neu (04.11.): D20c2 Tessa, Gorm und das Zubehör** (1.9): Tessa (blonder hoher Zopf) und Gorm (dunkle Locken, runde Wangen) kämpfen jetzt mit ihren eigenen Köpfen auf den Novizen-Körpern, in der Gruppen-Lektion und in der Lektion „Deckung geben“. Bei „Figur erstellen“ kann man ihre Köpfe nicht wählen. Das Zubehör aus deinen Blättern sitzt an den Figuren: Hanne mit Schürze und Kochlöffel, Ilse mit Schlüsselbund, Edmar mit Amtskette, Quill mit Meißel und Pip mit Holzschwert am Gürtel, Brom mit seinem alten Helm, Lotte mit der Papierkrone. Mira kann liegen (für das Krankenzelt in der Glutoase, kommt mit D24). Noch nicht drin: Ilses Ärmelschoner (dafür bräuchten die Körper Armpunkte) und Edmars Festschärpen (kommen mit dem Fest).
  - **So testest du es:**
    1. Auf dem Marktplatz: Pip mit Holzschwert, Lotte mit Krone, Quill mit Meißel, Edmar mit Amtskette.
    2. Hanne im Wegrast (Schürze, Kochlöffel) und Brom am Südost-Tor (Helm) ansehen, auch von hinten.
    3. Bei Ye die Lektion „Deckung geben“ (ab Stufe 8): Tessa und Gorm mit ihren neuen Köpfen im Kampf.

- **Neu (04.11.): D20c Kreuzweg-Figuren nach Steckbrief** (1.9): Lene, Hanne, Ilse, Edmar, Brom, Quill, Pip und Lotte tragen jetzt ihre eigenen Köpfe aus deinen Blättern auf den Baukasten-Körpern (Lene Gelehrte, Hanne Frau, Ilse alter Mensch, Edmar Mann, Brom Wache, Quill Handwerker, Pip und Lotte Kind). Bingo, Marv (auch in Wipfelheim) und Mira laufen mit ihren eigenen Bildern herum. Alle elf haben im Gespräch ihr Porträt mit passender Stimmung (z. B. Quill traurig bei der sechsten Zeile, Lotte wütend beim Holzschwert-Angriff); fehlt eine Stimmung, nimmt das Spiel die nächstbeste. Lene sagt jetzt „der Mann mit dem Regenschirm“ statt „mit dem blauen Hut“. Noch nicht drin (D20c2): Tessa und Gorm, das Zubehör (Schürze, Helm, Krone …), Mira krank im Bett (Bilder liegen bereit).
  - **So testest du es:**
    1. Neues Spiel: Lene vor der Gilde ansprechen, Porträt über dem Gesprächsfenster.
    2. Auf dem Marktplatz: Quill, Pip, Lotte und Edmar auf der Bühne mit ihren neuen Köpfen, alle ansprechen.
    3. Bingo, Marv und Mira besuchen und um sie herumlaufen (auch von hinten ansehen).
    4. Hanne im Wegrast und Brom am alten Südost-Tor ansprechen.

- **Neu (04.11.): D20b Ye mit Regenschirm** (1.9): Ausbilder Ye läuft in der Welt jetzt mit deinen Bildern herum (abgetragener Mantel, roter Schal, Regenschirm), vor der Gilde und am Stadttor. Wenn Ye spricht, steht sein gemaltes Porträt über dem Gesprächsfenster, je nach Stimmung ruhig, lächelnd, traurig, überrascht oder wütend. „Schild hoch, Schild runter“ ist überall ersetzt: „Nicht nachdenken. Deine Hände wissen es vor dir.“ (auch der Erfolg heißt jetzt „Deine Hände wissen es“). In der Paradeschule spannt Ye den Schirm auf und kommentiert deine Übungsversuche („Zu langsam. Noch mal.“, selten „Nicht schlecht. Für einen Anfänger.“), beim ersten Übungsversuch ist sein Schirm kurz ein Schwert. Neu bei Ye am Tor: nachts „Nachtschicht …“, die Frage nach Marv und vor der Klassenwahl „Welche Klasse ist die beste?“. Seit deinem Kampf-Blatt kämpft Ye auch im Kampf mit eigenen Bildern: Er sticht mit dem geschlossenen Schirm zu („Schirmstoß“), dazu Getroffen und Parade mit offenem Schirm. Ye steht vor der Gilde etwas hinter einem Baum, das ordnet D20d.
  - **So testest du es:**
    1. Neues Spiel, bei Ye vor der Gilde melden: Porträt über dem Gesprächsfenster, Antwort „Wann lerne ich kämpfen?“.
    2. Am Stadttor die Grundausbildung, Lektion 2: Ye kommentiert die beiden Übungsversuche, einmal wird der Schirm kurz zum Schwert.
    3. Nach der Grundausbildung Ye am Tor nachts ansprechen (Test-Knopf „Uhr +3 h“): „Nachtschicht …“.
    4. Vor der Klassenwahl bei Ye „Welche Klasse ist die beste?“ wählen.

- **Neu (03.11.): D20a Hutmacher Hatta, Hüte und Zeichen** (1.9, D20 ist in vier Schritte geteilt): Hutmacher Hatta steht mit seinem Laden rechts neben Bingos Stand, Händler-Körper mit deinem Hatta-Kopf und dem riesigen verrückten Zylinder. Er tauscht Monster-Beute und etwas Bronze gegen die acht Hüte der Regionen (Filzhut mit Feder, Grüne Kapuze, Stoffmütze, Kochmütze, Wachhelm, Gelehrtenhut, Schmiedekappe, Kopftuch); ein eingetauschter Hut ist danach unter Werte → Aussehen wählbar. Dafür lassen Monster jetzt Beute fallen (etwa 7 von 10 Siegen, z. B. Falkenfeder vom Windfalken, Wolfspelz vom Heulwolf, Leuchtschuppen aus der Pilzhöhle). Über den Diensten schweben Zeichen: Münze über Bingo und Salbei, Truhe über den Banken, Hut über Hatta, Laterne über der neuen Wegelaterne am Brunnen (Schnellreise kommt später). Noch nicht drin: Hattas Maßband und seine Porträts; die Tauschpreise sind vorläufig. Das Hut-Zeichen über Hatta ist vor dem großen Hut-Schild seines Ladens schwer zu sehen.
  - **So testest du es:**
    1. In Kreuzweg rechts neben Bingo: Hattas Laden, Hatta mit Zylinder und Hut-Zeichen.
    2. In Grünwacht ein paar Windfalken besiegen: Falkenfedern in der Tasche.
    3. Zu Hatta, „Zeig mir deine Hüte“: Filzhut eintauschen, dann unter Werte → Aussehen aufsetzen.
    4. Zeichen über Bingo, der Bank und der Wegelaterne am Brunnen ansehen.

- **Neu (03.11.): D19 Figuren-Baukasten** (NPC.md): Deine acht Grundkörper (Mann, Frau, Kind, alter Mensch, Wache, Händler, Handwerker, Gelehrter) und die zwölf Volks-Köpfe (sechs Erwachsene, vier Alte, zwei Kinder) sind eingebaut. Jeder Kopf passt auf jeden Körper; alle Köpfe sind gleich groß, das Kind bleibt kleiner. Die Körper laufen in der Welt schräg von vorne und von hinten. Eine Figur aus dem Baukasten heißt z. B. „grund_frau+v_w1“, so lassen sich Volk und Nebenfiguren mit D20 und D21 aufstellen. Noch nicht: Umfärben nach den Farben der Region; die Hüte der Regionen und die Zeichen über Diensten kommen mit D20.
  - **So testest du es:**
    1. Im Startmenü das Baukasten-Testfeld öffnen: Auf dem Platz nördlich vom Start stehen die acht Figuren in einer Reihe.
    2. Darauf achten, ob Köpfe und Körper zusammenpassen (Größe, Hals), und ob das Kind kleiner ist.
    3. Um sie herumlaufen: Sie wippen im Stehen.

- **Neu (03.11.): D18b Klassenwaffen an der Hand**: Der Bogenschütze hält deinen Langbogen, der Zähmer die Schleuder (aus `klassen_waffen.png` und `klassen_bogen_gespannt.png`). Beim Schuss und bei der Konzentration hält der Bogenschütze den gespannten Bogen mit Pfeil. Beim Fallen, beim Sieg, beim Getroffen-Werden und (Bogenschütze) beim Ausweichen ist keine Waffe zu sehen. Die Klassenwaffen lassen sich nicht im Aussehen austauschen; das Waffen-Aussehen gilt weiter für den Novizen.
  - **So testest du es:**
    1. Als Bogenschütze durch Wipfelheim laufen: Der Bogen ist in der Hand, von vorne, hinten und der Seite.
    2. Im Kampf schießen: Der Bogen wird gespannt, mit Pfeil.
    3. Als Zähmer: Die Schleuder in der Hand, beim Wurf hoch über dem Kopf.

- **Neu (03.11.): D18 Körper für Bogenschütze und Monster-Zähmer** (1.8, Projekt 11 Schritt 4): Marcos Körper-Blätter sind eingebaut, je männlich und weiblich (alle Bewegungen: Stehen, Laufen, Getroffen, Ausweichen bzw. Anfeuern, Schuss bzw. Wurf, Fallen, Sieg, Konzentration bzw. Befehl, dazu die Welt-Ansichten von vorne und hinten). Hat man die Klasse gelernt (Fenns Prüfung bzw. Esches Monster), trägt die eigene Figur die Klassenkleidung, in der Welt und im Kampf; Kopf, Name und Aussehen (Hut, Umhang, Farben) bleiben. Bogen und Schleuder kamen mit D18b.
  - **So testest du es:**
    1. Als Bogenschütze bei Fenn die Prüfung bestehen: Danach trägt deine Figur grüne Waldläufer-Kleidung, der Kopf bleibt.
    2. Als Zähmer bei Esche das erste Monster wählen: Danach die Zähmer-Kleidung.
    3. Einen Kampf in der Wildnis: Auch dort steht deine eigene Figur in Klassenkleidung.
    4. Ein Hut aus „Aussehen“ bleibt nach dem Wechsel auf dem Kopf.

- **Neu (03.11.): D17 Kartenalbum, Teil 3** (1.6, Projekt 8 Schritt 7–9): Eine volle Seite im Album bringt einen Titel („Kenner von Kreuzweg“, „Kenner von Grünwacht“) und eine Kopfbedeckung der Region (Sternenreif bzw. Geweih-Band), die es nur so gibt. Der Titel steht unter deinem Namen in der Welt, unter „Werte (C)“ und im Album, die Kopfbedeckung lässt sich unter Werte → Aussehen wählen. Ist das ganze Album voll, gibt es den Sternen-Kartenrücken: Deine Karten am Spieltisch haben dann einen goldenen Rand. Marv in Kreuzweg spricht neue Karten an („Ooooh! Ist das … ein Windfalke?!“). Karten lassen sich im Album bis +10 verbessern: Es kostet eine doppelte Karte und etwas Bronze, bis +4 klappt es immer, ab +5 nur mit Glück (80 % bis 30 %); jede Stufe macht den Besitzeffekt größer. Ein Testknopf im Album füllt die gerade offene Seite. Sternenreif und Geweih-Band sind Marcos Bilder (03.11., `tools/vorlagen/hut_*.png`); der hintere Teil des Bands liegt hinter dem Kopf.
  - **So testest du es:**
    1. Album (L), Testknopf „Seite füllen“ auf Grünwacht: Meldung, Titel unter deinem Namen, unter Werte → Aussehen das Geweih-Band.
    2. Auch Kreuzweg füllen: Am Spieltisch haben deine Karten jetzt einen goldenen Rand.
    3. Eine neue Karte aktivieren und in Kreuzweg zu Marv: Er spricht sie an.
    4. Im Album eine doppelte Karte antippen und verbessern: „+1“ am Namen, der Bonus steigt. Ab +5 klappt es manchmal nicht.

- **Neu (03.11.): D16 Kartenalbum, Teil 2** (1.6, Projekt 8 Schritt 4–6): Jede Karte im Album gibt einen kleinen dauerhaften Bonus, der zum Monster passt (z. B. Rindenbär +3 Leben, Windfalke +1 Tempo, Irrlicht +3 Mana, Glutwelpe +1 Angriff). Doppelte zählen nicht mehrfach. Der Bonus wirkt im Kampf und steht im Album („Alle Karten zusammen“) und unter „Werte (C)“. Im Album legt „Ins Deck“ bis zu 5 Karten fest, mit denen du bei Kreuzweg-Karten antrittst (blau umrandet); fehlen welche, füllt das Spiel mit deinen stärksten auf. Bingo kauft doppelte Karten für ein paar Bronze, die letzte Karte jeder Sorte bleibt im Album. Bingos lange Warenliste lässt sich jetzt rollen. Die Bonus-Zahlen sind vorläufig.
  - **So testest du es:**
    1. Werte (C) ansehen, dann eine neue Karte aktivieren: Leben, Mana, Angriff oder Tempo steigen, darunter steht „Karten im Album“.
    2. Im Album eine Karte antippen und „Ins Deck“: Sie ist blau umrandet. Gegen Marv oder Oma spielen: Diese Karten sind auf der Hand.
    3. Mit einer doppelten Karte zu Bingo, ganz unten „Doppelte Karten verkaufen“: Das Geld steigt, die letzte bleibt.

- **Neu (03.11.): D15 Kartenalbum, Teil 1** (1.6, Projekt 8 Schritt 1–3): Das Kartenalbum öffnet sich mit **L** oder dem lila Knopf oben (K war schon mit den Fähigkeiten belegt). Je Region eine Seite (Kreuzweg 7 Plätze, Grünwacht 18 Plätze samt Pilzhöhle und Nacht-Monstern) mit Zähler wie „Grünwacht: 6 / 18“. Gesammelte Karten zeigen das Monster und die Anzahl, fehlende nur einen dunklen Umriss. Eine angetippte Karte zeigt Element und Schwächen. Gefundene Karten liegen erst als „Unbekannte Monsterkarte“ in der Tasche (bei voller Tasche im Beute-Fenster), mit „Aktivieren“ dreht sie sich um und kommt ins Album. Die Kartenzeile unten in der Tasche ist weg. Karten von Oma Hagebutte, Marv und die Startkarten kommen wie bisher gleich ins Album.
  - **So testest du es:**
    1. Mit L das Album öffnen und zwischen Kreuzweg und Grünwacht wechseln: Zähler, Bilder und dunkle Umrisse.
    2. Eine Karte antippen: Element und Schwächen stehen unten, bei fehlenden Karten nur ein Hinweis.
    3. Mit Sternentafel Monster besiegen, bis eine Karte kommt: In der Tasche liegt eine „Unbekannte Monsterkarte“.
    4. Dort „Aktivieren“: Die Karte dreht sich um, danach steht sie im Album.

- **Neu (03.11.): D14 Tag und Nacht** (1.5, Projekt 7): Das Licht richtet sich nach deiner Uhrzeit. Ab 19 Uhr wird es warm und langsam dunkel, von 21 bis 6 Uhr ist Nacht (bläulich, dunkler), ab 6 Uhr wird es wieder hell. Nachts leuchten Feuer, Laternen und Fenster stärker. Oben links steht die Uhrzeit. Die Fest-Nacht bleibt immer Nacht, die Pilzhöhle kennt keine Tageszeit. Nachts stehen in der Wildnis andere Monster: auf dem Weg nach Grünwacht Heulwolf und Irrlicht, im Wald Nachtuhu und Funkenmarder (etwas stärker, mit ihren fertigen Bildern). Beim Zusammenspielen gilt für die Monster die Uhr des Servers, damit alle dieselben sehen. Noch nicht drin: Kämpfe sehen nachts noch aus wie tags, nachts geschlossene Stände und andere Figuren (D20).
  - **So testest du es:**
    1. Tasche öffnen (I), Testknopf „Uhr +3 h“ drücken, bis oben links ein Abend steht: Die Welt wird langsam wärmer und dunkler.
    2. Weiter bis Nacht (nach 21 Uhr): Alles bläulich, Feuer und Laternen leuchten stärker.
    3. Nachts auf dem Weg nach Grünwacht: Statt Windfalken und Kröten stehen Heulwölfe und Irrlichter da.
    4. Nachts in den Wald: Nachtuhu und Funkenmarder. Uhr weiter bis zum Morgen: Die gewohnten Monster sind zurück.

- **Neu (03.11.): D13 Händler** (1.4, Projekt 6): Kräuterhändlerin Salbei steht mit ihrem Stand und Kräuterkisten auf dem Hauptplatz von Wipfelheim, gleich neben der Bank. Sie verkauft Heiltränke, Manatränke, die Grundmaterialien Garn, Öl und Leder und als eigene Ware Waldpilze (für das Kochen später). Bingo in Kreuzweg verkauft jetzt auch Garn, Öl und Leder. Ohne genug Geld klappt der Kauf nicht. Die Bilder der neuen Waren sind von Marco (03.11., `tools/vorlagen/gegenstaende_3.png`). Noch Platzhalter: Salbeis Figur (kommt mit D21) und ihre Texte.
  - **So testest du es:**
    1. In Wipfelheim zum Hauptplatz neben der Bank: Dort steht Salbeis Stand.
    2. Salbei ansprechen, „Zeig mir deine Waren“: Tränke, Garn, Öl, Leder und Waldpilze.
    3. Etwas kaufen: Das Geld sinkt, die Ware liegt in der Tasche (I).
    4. Mit zu wenig Geld kaufen: Es klappt nicht.

- **Neu (03.11.): D12 Gemeinsame Trank-Wartezeit** (1.3, Projekt 5 Schritt 3): Nach einem Trank (Heil- oder Manatrank) sind alle Tränke 3 Runden gesperrt. Im Kampfmenü steht die Wartezeit bei „Gegenstände“ in Klammern, auf den Trank-Knöpfen steht „Trank-Wartezeit: bereit in …“. Der erste Trank im Zug bleibt gratis. Dabei behoben: Bisher hatte nur der Novize Tränke im Kampf, jetzt hat jede Klasse ihre Tränke vom Gürtel dabei (nicht in der Probestunde mit fremder Klasse).
  - **So testest du es:**
    1. Mit einer Klasse (z. B. Bogenschütze) in der Wildnis kämpfen: Unter „Gegenstände“ stehen deine Tränke.
    2. Einen Heiltrank trinken: Du bist noch dran, aber alle Tränke sind jetzt gesperrt.
    3. Bei „Gegenstände“ steht eine Zahl, die jede Runde kleiner wird.
    4. Nach 3 Runden ist wieder ein Trank möglich.

- **Neu (02.11.): Schneller (Leistung)**: Kreuzweg und Grünwacht sollen flüssiger laufen, besonders im Browser.
  - Der Boden aus dem Baukasten war ein einziges Riesenbild der ganzen Karte, das in jedem Bild komplett gezeichnet wurde (und von jedem Licht noch einmal). Jetzt ist er in Kacheln geteilt, gezeichnet wird nur, was zu sehen ist. Gemessen mit Software-Grafik: 95 → 41 ms pro Bild, das Aussehen ist gleich (Bildvergleich).
  - Zeichen (! und ?), Wegweiser und Ziel werden fünfmal pro Sekunde und nach jedem Fortschritt bestimmt statt in jedem Bild, jede Figur prüft nur noch ihre eigenen Aufträge. Stillstehende Figuren werden nicht jedes Bild neu einsortiert. Spiel-Logik in Kreuzweg: 4,1 → 1,2 ms pro Bild.
  - Prüfungen: `bash tools/alle_tests.sh` startet alle gleichzeitig, 43 Sekunden statt rund 10 Minuten.
  - **Noch offen, deine Entscheidung:** Die 42 Lichter in Kreuzweg kosten etwa ein Drittel der Zeichenzeit. Sie ließen sich durch einfache leuchtende Flecken ersetzen (viel schneller, sieht aber anders aus: eher Schein als beleuchteter Boden).
  - **So testest du es:**
    1. Im Browser (https://cazex-studio.github.io/MiniKampf/) durch Kreuzweg laufen: Fühlt es sich flüssiger an?
    2. In Wipfelheim und im Waldboden laufen: ebenfalls flüssig?
    3. Sieht der Boden aus wie vorher (keine Lücken, Übergänge zwischen Gras und Weg weich)?

- **Neu (02.11.): D11 Zähmer lernt bei Tilda** (1.2, Projekt 12 Schritt 1): Nach der Klassenwahl und dem Gespräch mit Ysolde führt der Wegweiser jetzt zu Rudelmeisterin Tilda. Sie erklärt, wie ein Zähmer kämpft und zähmt, und schickt dich zu Professor Esche. Dort wählst du das erste Monster, ab dann kämpfst du als Zähmer. Danach geht es wie bisher weiter: Kobalt, zurück zu Esche, Tildas Unterricht im Wald. Wer zuerst zu Esche geht, wird zu Tilda geschickt. Punkte neu verteilen geht jetzt bei Tilda. Dazu behoben: Esche zeigte dem Zähmer zu früh das blaue „!“ für den Bienenstock. Die Texte von Tilda und Esche sind Platzhalter.
  - **So testest du es:**
    1. Neu beginnen, Monster-Zähmer wählen und bis zu Ysolde spielen.
    2. Dem Wegweiser zu Tilda folgen: Sie erklärt das Zähmen und schickt dich zu Esche.
    3. Bei Esche ein Monster wählen, dann gegen Kobalt kämpfen: Du kämpfst als Zähmer.
    4. Zum Gegentest bei einem neuen Zähmer zuerst zu Esche gehen: Er schickt dich zu Tilda.

- **Neu (02.11.): D10 Liste aus dem Playtest 25.10.** (1.1): Claude hat jeden Punkt deiner Liste im Spiel nachgeprüft. Alles war schon gebaut (25. und 26.10.), es fehlte nur der Beweis für den Silberhirsch in der Gruppe. Dafür gibt es jetzt eine automatische Prüfung.
  - Fertig: Wegweiser für Nebenaufträge mit 1, 2, 3 · Auftragsbuch mit Reitern Offen, Abgeschlossen, Erfolge · Ye beantwortet die Laternen-Frage wieder · Silberhirsch frei sichtbar · Silberhirsch auch in der Gruppe (jeder Bogenschütze spricht ihn für sich an) · Pilzhöhle immer sichtbar, hinein erst mit Auftrag · Aufträge macht jeder für sich, gemeinsame Szenen nur im Dungeon · Kämpfe gegen Tiere, Bienen, Bosse und den Sternenfresser mit der Gruppe · im Dungeon nur die eigene Gruppe, besiegte Monster bleiben weg, die Gruppe entscheidet am Ende gemeinsam · Kobalt steht hinter seinem Monster und schießt mit der Schleuder · Kobalts Revanche erst nach dem Dungeon und mit einem Monster · Zähmer: ein Monster kämpft, zwei unterstützen sichtbar · Rudel-Fenster (R) zum Auswählen · Monster-Stall bei Tilda · Abwarten für alle · Passive und Reaktion als Kästchen im Kampf · Parier-Übung bei Ye · Tasche mit Kästchen und Ziehen · Klasse erst beim Lehrmeister · Kael auf der Westplattform · Grünwacht größer.
  - Fehlt: nichts.
  - **So testest du es:**
    1. Zu zweit als Bogenschützen Fenns Prüfung machen und gemeinsam zum Silberhirsch gehen: Jeder kann ihn ansprechen.
    2. Als Zähmer nach dem Dungeon zu Kobalt: Die Revanche ist gegen ein Monster.
    3. Sonst die Testpunkte unter „Playtest 25.10. Teil 1“ weiter unten.

- **Neu (06.11.): D9h Gemalte Effekte** (K.6): Alle 31 Effekte von ChatGPT sind im Spiel. Pfeile, Klingen, Sterne, Kometen und Futter fliegen als Bilder. Netz, Fadenkreuz, Pfeilhagel, Schild-Kuppel, Lichtstrahl, Schallwellen, Amboss mit Rissen, Dampf, Glut, Goldregen, Noten, Mond, Sichel und Wirbel sind gemalt. Jeder Treffer zeigt die neuen Funken, jede Heilung die grünen Heil-Funken. Noch gezeichnet: das Glühen der Figuren, Ringe, Zeichen über den Köpfen und Lichtblitze.
  - **So testest du es:**
    1. Kampf-Sandbox als Bogenschütze: Schnellschuss, Netzpfeil, Pfeilhagel und Schwachstelle: Pfeil, Netz, Pfeilregen und Fadenkreuz sind gemalt.
    2. Als Rüstungsschmied: Amboss aufstellen und Härten: Amboss mit Rissen und Staub, dann Dampf.
    3. Als Klingentänzerin: Klingenschritt, Wirbel und Fächerschnitt: X-Schnitt, Wirbelkreis, Sichel.
    4. Als Sternensängerin: Mondwiegenlied, Kometenlied und Polarstern: Noten, Mond, Komet und Lichtstrahl.
    5. Sag, ob dir ein Effekt zu groß, zu klein oder zu schnell ist.

- **Probe gemalter Effekt (02.11.)** (D9h): Der normale Treffer im Nahkampf und der Doppelschlag zeigen jetzt deinen Schwerthieb von ChatGPT statt der gezeichneten Form, als kurze Bildfolge.
  - **So testest du es:**
    1. Kampf-Sandbox: ein paar Nahkampf-Angriffe ausführen und auf den Hieb am Ziel achten.
    2. Sag, ob Größe, Tempo und Stil passen.

- **Neu (02.11.): D9g Eigene Bewegungen der Sternensängerin** (K.6): Sternenfunke fliegt im Bogen. Mondwiegenlied, Polarstern, Kometenlied und Mondschild haben eigene Abläufe und Zeichen bei den Verbündeten. Sternschnuppenregen fällt einzeln von oben mit fallender Tonhöhe. Lied der Rückkehr lässt einen Stern sinken, der Gefallene steht auf. Dissonanz trifft mit roten Ringen, der Gegner zappelt. Himmelszelt: Sternenlicht fällt auf alle. Die Effekte sind Platzhalter, die Bilder sollen von ChatGPT kommen (D9h). Noch nicht drin: Sternbilder über ihr, bleibende Monde und Sterne, echte Melodien.
  - **So testest du es:**
    1. Kampf-Sandbox mit der Sängerin: Sternenfunke, Mondwiegenlied und Kometenlied auslösen.
    2. Resonanz sammeln, dann Sternschnuppenregen: Die Schnuppen fallen einzeln.
    3. Ult laden und auslösen: Film, dann Sternenlicht auf alle.

- **Neu (02.11.): D9f Eigene Bewegungen der Klingentänzerin** (K.6): Klingenschritt lässt ein Nachbild stehen und schneidet über Kreuz. Eine neue Klinge glitzert kurz. Wirbel zeigt einen Kreis aus Schnitten und Sand. Ausfallschritt und Sturmschritte lassen Nachbilder zurück, Sturmschritte mit schnellen Trommelschlägen. Fächerschnitt: Eine breite Lichtsichel fegt über die Gegner. Partnertanz: Eine Klinge fliegt glitzernd zum Partner. Klingenkäfig: Drei Klingen kreisen um den Gegner. Klingensturm schickt die Klingen einzeln los, bei fünf mit großem Abschluss. Ult: Klingenschwarm mit Nachbildern, zum Schluss der Klingensturm. Noch nicht drin: Käfig bleibt nicht zwei Runden sichtbar, Trommel-Zeichen, goldene Klingen bei fünf.
  - **So testest du es:**
    1. Kampf-Sandbox mit der Klingentänzerin: Klingenschritt, Wirbel und Ausfallschritt nacheinander.
    2. Klingen sammeln und Klingensturm mit fünf Klingen auslösen: großer Abschluss.
    3. Ult laden und auslösen: Film, Schwarm, Klingensturm.

- **Neu (02.11.): D9e Eigene Bewegungen des Rüstungsschmieds** (K.6): Hammerschlag mit Funkenregen und rotem Pfeil über dem Gegner. Rüstung wechseln mit kurzem Schmiede-Moment. Amboss aufstellen: Ein Amboss fällt in den Boden, Staub, Wackeln, rote Pfeile über allen Gegnern. Rüstung verstärken: zweimal Klopfen, Kuppel beim Verbündeten. Abfangen: Lichtband zwischen beiden. Härten: Die Rüstung glüht weiß und kühlt ab. Glühende Rüstung: orange Glut, Angreifer werden angesengt. Funkenflug nach perfekter Parade. Ambossschlag: Sprung, große Schockwelle, Wackeln, Sterne über Betäubten. Gemeinsame Härte: Splitter fliegen zu allen. Meisterstück: drei Schläge, dann goldener Funkenregen. Noch nicht drin: Risse im Boden, eigene Rüstungsbilder, Glanz je Härte-Stufe, der Amboss ist vorerst nur gezeichnet.
  - **So testest du es:**
    1. Kampf-Sandbox mit dem Schmied: Hammerschlag, Rüstung wechseln und Amboss aufstellen auslösen.
    2. Rüstung verstärken und Abfangen auf einen Verbündeten: Kuppel und Lichtband erscheinen dort.
    3. Glühende Rüstung, dann dich treffen lassen: Der Angreifer wird angesengt.
    4. Ult laden und auslösen: Film, drei Schläge, goldener Funkenregen.

- **Neu (02.11.): D9d Eigene Bewegungen des Monster-Zähmers** (K.6): Wechsel: zwei Pfiffe, das neue Monster springt ein, Lichtbogen und Staub (mit Großem Auftritt mehr Staub und eine Kuppel). Anfeuern: Klatschen, das Monster stampft mit roten Funken. Pflege: Der Zähmer geht in die Knie. Lockfutter fliegt im Bogen, darüber erscheint ein Fragezeichen. Beim Gemeinsamen Angriff stürmt das Monster nun wirklich vor, am Ende ein Lichtblitz. Wachstumsschub macht das Monster sichtbar größer, bis er endet. Einschüchtern zeigt Schallwellen, die Gegner zucken zurück, blaue Pfeile über ihnen. Zweites Leben: Lichtfunken, das Monster steht auf. Rudelruf endet mit Staubwolke und kurzem Anhalten. Noch nicht drin: Rufe der Monster, Kameraschwenk im Ult-Film, Zeichen der passiven Fähigkeiten.
  - **So testest du es:**
    1. Kampf-Sandbox mit dem Zähmer: Schleuder, Wechsel, Anfeuern, Pflege und Lockfutter auslösen.
    2. Wachstumsschub: Das Monster bleibt groß und schrumpft nach drei Runden wieder.
    3. Einschüchtern mit mehreren Gegnern: Alle zucken zurück.
    4. Ult laden und auslösen: Film, die Monster greifen an, dann die Staubwolke.

- **Neu (02.11.): D9c Eigene Bewegungen des Bogenschützen** (K.6): Statt der runden Kugel fliegen jetzt dünne Pfeilspuren. Schneller Schuss, Aufgeladener Schuss mit Rückstoß und Staub, Pfeilhagel mit Schatten am Boden, Netzpfeil mit Bogen in der Luft und zappelndem Gegner, Schnellfeuer wird heller und schneller, Durchschlag lässt eine Schneise stehen, Schwachstelle zeigt ein rotes Fadenkreuz, Elementpfeil hat die Farbe des Elements. Beim Jägerpfeil läuft der Geist des Silberhirschs mit, der Einschlag wirbelt grüne Funken. Noch nicht drin: Zeichen der passiven Fähigkeiten, das Netz reißt nicht sichtbar, das Fadenkreuz bleibt nicht drei Runden stehen.
  - **So testest du es:**
    1. Kampf-Sandbox mit dem Bogenschützen: alle Fähigkeiten einmal auslösen.
    2. Pfeilhagel mit mehreren Gegnern: erst der Schatten, dann der Pfeil.
    3. Ult laden und auslösen: Film, dann Hirschgeist und großer Einschlag.

- **Neu (02.11.): D9b Eigene Bewegungen des Novizen** (K.6): Schildstoß hat zwei schnelle Schritte, einen dumpfen Stoß, und das Ziel taumelt zurück. Doppelschlag schlägt von links und rechts mit kleinem Hüpfer und zwei Klirren. Erste Hilfe: Der Novize geht kurz in die Knie, grüne Funken und ein Pflaster steigen auf. Deckung geben zeigt einen Sprung und eine Schild-Kuppel, beim Abfangen sprüht ein Funke. Sternenmut leuchtet lila, klingt hell und endet in einem großen lila Hieb. Noch ohne eigene Bilder: Knien und Schild sind nur angedeutet.
  - **So testest du es:**
    1. Kampf mit dem Novizen: Schildstoß und Doppelschlag ausprobieren, jede Fähigkeit sieht anders aus.
    2. Erste Hilfe auf dich und auf einen Verbündeten wirken: Das Pflaster erscheint beim Ziel.
    3. Deckung geben: Kuppel über dem Verbündeten, beim nächsten Treffer der Funke am Novizen.
    4. In der Festnacht Sternenmut auslösen: erst der Film, dann der lila Hieb.

- **Neu (02.11.): D9a Filmische Ult** (K.6): Löst jemand seine Ult aus, dunkelt das Bild ab, Kino-Streifen fahren herein, die Kamera rückt an die Figur, Bild und Name der Ult gleiten ins Bild. Das dauert 3,4 Sekunden. Im Hauptmenü stellt der Knopf „Ult: filmisch“ auf „Ult: kurz“ (1 Sekunde), jede Klasse zeigt ihre Ult beim ersten Mal trotzdem ganz. Jede Demo-Klasse hat einen eigenen Hintergrund (Lichtstrahl, Mond, Ringe, Esse, Feuer, Sternenhimmel), die Effekte aus den Steckbriefen folgen mit D9b bis D9g. D9 ist dafür in Schritte geteilt.
  - **So testest du es:**
    1. Kampf-Sandbox: Ult laden und auslösen, der Film läuft, danach geht der Kampf normal weiter.
    2. Alle sechs Demo-Klassen durchprobieren: Jede hat ihren Hintergrund.
    3. Im Hauptmenü „Ult: kurz“ wählen, eine schon gesehene Ult läuft jetzt in etwa einer Sekunde.

- **Neu (02.11.): D2b Kurzschwert als eigenes Teil** (Projekt 13, Schritt 3): Die Novizen zeigen jetzt deine Bilder ohne Klinge, das Schwert kommt als eigenes Teil dazu und sitzt in jedem Bild am Griff. Auch Wanderhut und Reiseumhang sind jetzt deine Bilder statt der Platzhalter, der Umhang weht im Laufen. Unter „Aussehen“ gibt es neu den Platz „Waffe“: Eigene oder Krummklinge (die Werte bleiben gleich). Beim Wirken (Hand auf der Brust) ist kein Schwert zu sehen.
  - **So testest du es:**
    1. Editor → „Figuren-Animationen“, Novizen-Körper wählen und alle Bewegungen durchklicken: Das Schwert bleibt in der Hand.
    2. „Hut“ und „Rücken“ drücken: Hut sitzt auf dem Kopf, der Umhang hängt hinten und weht beim Laufen.
    3. „Waffe“ drücken: Statt des Kurzschwerts erscheint die Krummklinge.
    4. Im Spiel eine Figur aus „Figur erstellen“ laufen und kämpfen lassen, dann im Werte-Fenster (C) unter „Aussehen“ Hut, Rücken, Farben und Waffe wechseln.

- **Neu (02.11.): D8g Baum der Sternensängerin** (Projekt 14, K.5, Steckbriefe Sitzung 28): Die Lieder sind jetzt wie in den Steckbriefen. **Sternenfunke** (normaler Angriff, +1 Kometen-Sternbild), **Mondwiegenlied** (heilt die ganze Gruppe 3 Runden lang, +1 Mond-Sternbild), **Sternenglanz** (passiv: volles Sternbild macht das passende Lied stärker oder für alle), **Polarstern** (verbraucht Mond-Resonanz, Abwehr+ hält dafür länger), **Kometenlied** (verbraucht Kometen-Resonanz, Angriff+ für alle, je mehr Resonanz, desto länger; macht keinen Schaden mehr), **Nachhall** (passiv, Lieder eine Runde länger), **Mondschild** (Mond-Resonanz als Schild für alle), **Sternschnuppenregen** (Kometen-Resonanz als Sternschnuppen, gleichmäßig auf alle Gegner; heilt nicht mehr), **Langsames Verblassen** (passiv), **Lied der Rückkehr** (holt einen Gefallenen zurück, einmal pro Kampf), **Dissonanz** (Gegner rutscht zurück und macht weniger Schaden). Ult **Himmelszelt**: Heilung und Stärkung für alle, je mehr Resonanz, desto stärker, danach sind beide Sternbilder leer.
  - **Abweichungen, die du wissen solltest:** Das Himmelszelt trifft wie bisher auch alle Gegner mit Sternenkraft (im Steckbrief nur Heilung und Stärkung). Der Sternenfunke macht 14 statt 11 Schaden. Beim **Urbaum** in der Pilzhöhle hat die Gruppe jetzt **5 statt 4 Züge**, bevor er verschlingt: Nach den neuen Bäumen gewannen die Klassen dort allein nur noch 53 % (Prüfung verlangt 55 %), jetzt 60 %. Bogenschütze und Zähmer schaffen ihn weiter gut.
  - Die Sternensängerin ist eine Klasse der Glutoase, zum Ausprobieren in der Kampf-Sandbox. Zahlen vorläufig.
  - **So testest du es:**
    1. Kampf-Sandbox mit der Sternensängerin: Mondwiegenlied, unter allen steht „Wiegenlied“, sie heilen jede Runde ein bisschen.
    2. Ein paar Sternenfunken (Kometen-Sternbild füllt sich), dann Kometenlied: Alle bekommen „Angr+“, das Sternbild ist leer.
    3. Mond-Sternbild füllen, dann Mondschild: Alle bekommen einen Schild.
    4. Ult Himmelszelt: alle geheilt und gestärkt, beide Sternbilder leer.

- **Neu (02.11.): D8f Baum der Klingentänzerin** (Projekt 14, K.5, Steckbriefe Sitzung 28): Reihe 1: **Klingenschritt** (normaler Angriff), **Klingensturm**, **Klingenkranz** (passiv, die schwebenden Klingen treffen nach). Reihe 2: **Wirbel**, **Ausfallschritt** (jetzt nach Steckbrief: der nächste Angriff auf sie verfehlt eher, plus eine Klinge), **Rhythmus** (passiv, nach einer Tanzfolge früher dran). Reihe 3: **Sturmschritte** (3 bis 5 Sprünge auf zufällige Gegner), **Fächerschnitt** (2 Klingen, trifft alle hart), **Festhalten** (passiv). Reihe 4: **Partnertanz** (ein Verbündeter bekommt eine Klinge und greift stärker an), **Klingenkäfig** (3 Klingen, wer angreift, wird geschnitten und kann die Reihe nicht wechseln). Ult **Tanz der tausend Klingen** endet jetzt mit dem Klingensturm.
  - Mit Baum verliert sie bei jedem Treffer eine schwebende Klinge, „Festhalten“ hält sie manchmal (Steckbrief). In der Kampf-Sandbox ohne Baum verliert sie keine.
  - Die Klingentänzerin ist eine Klasse der Glutoase, zum Ausprobieren in der Kampf-Sandbox. Zahlen vorläufig.
  - **So testest du es:**
    1. Kampf-Sandbox mit der Klingentänzerin: Klingen sammeln, dann Fächerschnitt (2 Klingen) und Klingenkäfig (3 Klingen).
    2. Einen Gegner im Käfig angreifen lassen: Er wird geschnitten, unter ihm steht „Klingenkäfig“.
    3. Mit einem Verbündeten Partnertanz: Unter ihm steht „Angr+“.
    4. Ult auslösen: drei Wellen auf alle, zum Schluss fliegen alle Klingen als Klingensturm.

- **Neu (02.11.): D8e Baum des Rüstungsschmieds** (Projekt 14, K.5, Steckbriefe Sitzung 28): Grundreihe Parieren und der feste Knopf **Rüstung wechseln**. Reihe 1: **Hammerschlag** (normaler Angriff, jetzt mit Bedrohung), **Rüstung verstärken** (Verbündeter 2 Runden Abwehr+ und Schild), **Gehärtet** (passiv, Grenze 1 + Stufe). Reihe 2: **Amboss aufstellen**, **Abfangen** (fängt den nächsten Treffer gegen einen Verbündeten ab, auch hinten), **Meisterhand** (passiv, Rüstung wechseln schneller). Reihe 3: **Härten** (sofort zwei Stufen), **Glühende Rüstung** (wer ihn im Nahkampf trifft, verbrennt sich), **Funkenflug** (passiv, Funken nach perfekter Parade). Reihe 4: **Ambossschlag** (alle Gegner, betäubt, Bosse nicht), **Gemeinsame Härte** (gibt die Härte als Schutz an die Gruppe, geht nicht allein). Ult **Meisterstück**: 3 Runden Meisterrüstung, die gegen alles passt, dazu ein Schild von 40 (der Schild ist eine Ergänzung, damit der Schmied allein nicht zu schwach wird).
  - Der Schmied ist eine Klasse der Glutoase, in Kreuzweg und Grünwacht spielt man ihn nur in der Probestunde und in der Kampf-Sandbox. Zahlen vorläufig.
  - **So testest du es:**
    1. Kampf-Sandbox mit dem Rüstungsschmied: Hammerschlag, danach greifen die Gegner eher ihn an.
    2. Glühende Rüstung zünden und warten: Wer ihn im Nahkampf trifft, brennt.
    3. Mit einer zweiten Klasse im Team: Abfangen auf sie, dann Gemeinsame Härte (vorher mit Härten Stufen sammeln).
    4. Ult Meisterstück: 3 Runden steht „Meisterrüstung“ unter ihm, jeder Treffer zählt als passende Rüstung.

- **Neu (02.11.): D8d Baum des Monster-Zähmers** (Projekt 14, K.5, Steckbriefe Sitzung 28): Grundreihe **Zähmen** (fester Knopf), normaler Angriff **Schleuder**. Reihe 1: **Wechsel** (das neue Monster greift beim Auftritt gleich an), **Anfeuern**, **Band** (passiv: jedes Monster wird mit jedem gewonnenen Kampf im Rudel etwas stärker, höchstens 30 %). Reihe 2: **Pflege**, **Lockfutter** (wilder Gegner ist 2 Runden abgelenkt, greift seltener an und lässt sich leichter zähmen), **Rudelinstinkt** (passiv: Unterstützer helfen früher und stärker). Reihe 3: **Gemeinsamer Angriff** (Stab und Monster, 2 bis 4 Treffer), **Wachstumsschub** (Monster 3 Runden größer), **Großer Auftritt** (passiv). Reihe 4: **Einschüchtern** (alle Gegner 2 Runden schwächer), **Zweites Leben** (besiegtes Monster zurück, einmal pro Kampf). Ult **Rudelruf**. **Befehl** gibt es laut Steckbrief nicht mehr, das Monster hat seinen eigenen Zug.
  - **Zum Feinschliff:** Der erste Rivalenkampf gegen Kobalt ist mit dem Moosling deutlich schwerer geworden (in der Prüfung 2 von 16 Siegen statt 8 von 16), mit Glutwelpe und Bachotter bleibt er machbar. Verlieren ist dort erlaubt, für den Testtag Kampfgefühl (T2) vormerken.
  - Wie beim Bogenschützen hat ein Zähmer in der Wildnis nur, was er gelernt und auf die Leiste gelegt hat. Reihe 3 und 4 gibt es in der Demo noch nicht (Klassenstufe 20 und 30), zum Ausprobieren in der Kampf-Sandbox. Zahlen vorläufig.
  - **So testest du es:**
    1. Als Zähmer nach Tildas Unterricht K drücken und Wechsel, Anfeuern und Band lernen.
    2. Im Kampf wechseln: Das neue Monster greift beim Auftritt gleich an.
    3. Ab Klassenstufe 10 Lockfutter auf ein wildes Monster werfen: Unter ihm steht „Abgelenkt“, es frisst manchmal statt anzugreifen.
    4. In der Kampf-Sandbox mit dem Zähmer Wachstumsschub, Einschüchtern und Zweites Leben ausprobieren.

- **Neu (02.11.): D8c Baum des Bogenschützen komplett** (Projekt 14, K.5, Steckbriefe Sitzung 27): Alle Fähigkeiten im Baum lassen sich jetzt lernen. **Adlerauge** (passiv, aus der hinteren Reihe öfter kritisch, „Adlerauge!“ blitzt auf), **Durchschlag** (durchbohrt das Ziel und trifft einen zweiten Gegner), **Jagdinstinkt** (passiv, nach einem perfekten Ausweichen ist der nächste Schuss sicher kritisch), **Schwachstelle markieren** (3 Runden nehmen alle Treffer auf das Ziel mehr Schaden) und **Elementpfeil** (Feuer-, Gift-, Blitz- oder Frostpfeil aus der Tasche, mit Brennen, Gift, Lähmen oder Zugleiste). **Schnellfeuer** schießt jetzt wie im Steckbrief viele kleine Pfeile auf ein Ziel (3 bis 6).
  - Die besonderen Pfeile verkauft vorerst Bingo (15 Bronze), bis die Händler kommen (D13). Verschossene Pfeile fehlen danach in der Tasche. Zahlen vorläufig.
  - **So testest du es:**
    1. Als Bogenschütze mit K Punkte in Reihe 2 setzen (ab Klassenstufe 10). Reihe 3 und 4 (Klassenstufe 20 und 30) erreicht man in der Demo noch nicht: Durchschlag und Schwachstelle markieren gibt es zum Ausprobieren in der Kampf-Sandbox, dort hat der Bogenschütze alles außer dem Elementpfeil.
    2. Bei Bingo Feuerpfeile kaufen, im Kampf „Elementpfeil“ wählen: Das Ziel brennt, ein Pfeil weniger in der Tasche.
    3. Schwachstelle markieren, dann angreifen: Unter dem Gegner steht „Verwundbar“, alle treffen härter.
    4. Mit Jagdinstinkt perfekt ausweichen: „Jagdinstinkt!“ erscheint, der nächste Schuss ist kritisch.

- **Neu (02.11.): D8b Ye's Lektionen nach und nach** (Projekt 14, K.5): Die Grundausbildung hat jetzt drei Lektionen (Zugleiste mit **Schildstoß**, Parieren, zwei Reihen). Danach bietet Ye am Tor neue Lektionen an, sobald du stark genug bist: **Doppelschlag** ab Stufe 4, **Erste Hilfe** ab Stufe 6, **Deckung geben** ab Stufe 8 (mit Tessa und Gorm). Jede ist ein kurzer Nebenauftrag mit einem Übungskampf und Ye's Spruch aus dem Steckbrief. Im Kampf hat der Novize nur, was er schon gelernt hat, Tessa und Gorm können alles. Alte Spielstände mit Grundausbildung kennen schon alles außer Deckung geben (ab Stufe 8 auch das).
  - Weil man Erste Hilfe jetzt erst ab Stufe 6 hat, ist der erste Gruppenkampf etwas härter. Tessa und Gorm heilen dort, der Hinweis sagt das.
  - **So testest du es:**
    1. Neues Spiel bis zur Grundausbildung: drei Lektionen, Ye sagt am Ende „Mehr bringe ich dir bei, wenn du stärker bist.“
    2. Im ersten Gruppenkampf hast du Hieb und Schildstoß (noch keinen Doppelschlag).
    3. Ab Stufe 4 hat Ye am Tor ein „!“: die Lektion Doppelschlag spielen. Danach gibt es ihn in jedem Kampf.
    4. Ab Stufe 6 und 8 genauso mit Erste Hilfe und Deckung geben.

- **Neu (02.11.): D8a Fähigkeiten des Novizen** (Projekt 14, K.5, Steckbriefe Sitzung 28): Der normale Angriff heißt jetzt **Hieb**. Neu sind **Schildstoß** (wenig Schaden, der Gegner rutscht auf der Zugleiste nach hinten), **Doppelschlag** (zwei Hiebe, 10 Mana, ersetzt den Kraftschlag), **Erste Hilfe** (heilt dich oder einen Verbündeten) und **Deckung geben** (springt nach vorne und fängt bis zum eigenen nächsten Zug einen Treffer für einen Verbündeten ab). In der Festnacht bekommt der Novize seine kleine Ult **Sternenmut**: Ye ruft „Jetzt! Du hast es gefühlt, oder?“, jede perfekte Parade lädt sie, danach bleibt sie.
  - Erste Hilfe heilt dich oder einen Verbündeten (Marco, 02.11.). Nur mit sich selbst wäre der Urbaum mit den Novizen-Begleitern zu schwer.
  - Die Novizen-Begleiter nehmen „Deckung geben“ nicht und den schwachen Schildstoß nur selten, damit sie gut mitkämpfen. Schildstoß macht 8, der Doppelschlag zweimal 12 Schaden (vorläufig).
  - Die Texte von Ye in der Grundausbildung sind angepasst (auch die alte Erklärung, dass Mana von selbst zurückkommt).
  - Noch nicht drin: Die vier Fähigkeiten lernt man noch alle in der Grundausbildung, nicht verteilt auf Stufe 2, 4, 6 und 8 (D8b). Eigene Bewegungen und Klänge kommen mit D9.
  - **So testest du es:**
    1. Neues Spiel, Grundausbildung bei Ye: In Lektion 1 gibt es Hieb und Schildstoß, der Gegner rutscht auf der Zugleiste nach hinten.
    2. Lektion 2: Doppelschlag trifft zweimal, Erste Hilfe heilt dich.
    3. Beim Überfall mit Tessa und Gorm: Deckung geben auf einen der beiden, der nächste Treffer auf ihn geht auf dich.
    4. In der Festnacht gegen den Sternenfresser: Perfekte Paraden laden die Ult, dann „ULT: Sternenmut“ drücken.

- **Neu (02.11.): D7 Effekt-Liste** (Projekt 14, K.4): Neun feste Bausteine für Klassen und Monster: **Brennen** und **Gift** (Schaden zu Beginn jedes Zuges, Gift stapelt bis 3), **Lähmen** (nächster Zug fällt aus), **Festhalten** (keine Reihe wechseln, nicht abwarten), **Verfehlen** (nächster Angriff geht daneben), **Zugleiste schieben**, **Heilen**, **Schutz** (Schild) und **Schattenmale** (stapeln bis 5). Jeder Effekt hat eine feste Farbe, denselben Text unter der Figur und dasselbe Leuchten, egal wer ihn auslöst. Monster-Angriffe können einen Effekt mitbringen, perfekt pariert trifft er nicht.
  - Die Klassen und Monster benutzen die Bausteine noch nicht, das kommt mit D8 (Klassen) und D22 (Monster). Bis dahin probiert man sie in der Kampf-Sandbox aus. Die Zahlen sind vorläufig.
  - **So testest du es:**
    1. Editor → Kampf-Sandbox, unten „Effekt-Probe: aus“ antippen, dann steht dort „an“.
    2. Kampf starten. Unter „Fähigkeiten“ gibt es „Effekt auslösen“ mit allen neun Effekten.
    3. Jeden Effekt einmal auf einen Gegner oder Verbündeten legen: Unter der Figur steht der Zustand (zum Beispiel „Brennt“, „Gift 2“, „Gelähmt“), im Protokoll in seiner Farbe.
    4. Ein paar Züge warten: Brennen, Gift und Schattenmale machen zu Beginn des Zuges Schaden, ein gelähmter Gegner setzt aus.

- **Neu (02.11.): D6b Feste Leiste mit 6 Plätzen** (Projekt 14, K.3): Im Fähigkeiten-Fenster (K) steht oben die Leiste mit sechs Plätzen. Was du neu lernst, kommt von selbst auf den ersten freien Platz. „Herunter“ oder ein Klick auf den Platz nimmt es wieder ab, „Auf die Leiste“ legt es zurück. Im Kampf gibt es genau die Fähigkeiten auf der Leiste, dazu immer den normalen Angriff, Abwarten, die Gürtel-Gegenstände und die Ult. Die Leiste wird gespeichert, Neuverteilen leert sie.
  - Die 6 Plätze kommen zusätzlich zu Angriff, Abwarten, Gürtel und Ult (Marco, 02.11.).
  - Gilt vorerst nur für den Bogenschützen, weil nur er schon einen Baum hat.
  - **So testest du es:**
    1. Als Bogenschütze K drücken, zwei Fähigkeiten lernen: Sie stehen auf Platz 1 und 2.
    2. Bei einer „Herunter“ drücken und kämpfen: Diese Fähigkeit fehlt im Kampf, Angriff, Abwarten und Ult sind da.
    3. Wieder „Auf die Leiste“ drücken: Im nächsten Kampf ist sie wieder da.

- **Neu (02.11.): D6a Fähigkeiten-Baum** (Projekt 14, K.3): Nach dem Lernen der Klasse wächst die **Klassenstufe** mit der Erfahrung (gleiche Tabelle wie die Charakterstufe), jede Klassenstufe gibt einen Punkt. Mit **K** (oder dem Rollen-Knopf oben) öffnet sich das Fähigkeiten-Fenster: Grundreihe, vier Reihen (frei ab Klassenstufe 1, 10, 20, 30), Voraussetzungen wie „braucht Schneller Schuss 3“, ein „+“ zum Lernen. Jede Stufe über 1 gibt 10 % mehr Schaden oder Heilung. **Neu verteilen** geht nur beim eigenen Lehrmeister, das erste Mal kostenlos, danach 100 Bronze je Klassenstufe.
  - Der erste Baum ist der des **Bogenschützen** (aus design.md). Fähigkeiten, die es im Kampf noch nicht gibt (Adlerauge, Durchschlag, Jagdinstinkt, Schwachstelle markieren, Elementpfeil), stehen mit „Kommt bald“ im Baum, sie kommen mit D8. Alle anderen Klassen kämpfen weiter mit allen Fähigkeiten, bis ihr Baum da ist.
  - **Wichtig:** Ein Bogenschütze hat im Kampf in der Wildnis jetzt nur noch, was er gelernt hat (dazu immer den normalen Angriff und die Ult). Fenns Prüfung zeigt weiter alles. Alte Spielstände bekommen ihre Klassen-Erfahrung ab Stufe 10 geschätzt.
  - Alle Zahlen sind vorläufig.
  - **So testest du es:**
    1. Als Bogenschütze nach Fenns Prüfung K drücken: Klassenstufe und freie Punkte stehen oben.
    2. Mit „+“ den Aufgeladenen Schuss lernen. Netzpfeil zeigt „Ab Klassenstufe 10“.
    3. In der Wildnis kämpfen: Es gibt nur Schneller Schuss, Bogen spannen, Abwarten, Reihe wechseln und die Ult.
    4. Bei Fenn „Neu verteilen“ drücken (kostenlos), weit weg von Fenn geht es nicht.

- **Neu (02.11.): D5b Hinsetzen und Lagerfeuer** (Projekt 14, K.2): Nach Kämpfen in der Wildnis (ab Grünwacht, mit der eigenen Klasse) bleibt das übrige Mana erhalten, und der nächste Kampf beginnt damit. Wer verliert, steht mit leerem Mana auf. Mit **X** (oder dem Sanduhr-Knopf oben rechts) setzt du dich hin, dann füllt sich das Mana (in etwa 20 Sekunden). **Am Lagerfeuer** geht es dreimal so schnell, zum Beispiel am Rastplatz auf dem Weg nach Grünwacht. Wer losläuft, steht wieder auf. Ist das Mana nicht voll, steht es oben neben der Erfahrung. Lektionen und Geschichtskämpfe in Kreuzweg beginnen weiter mit vollem Mana.
  - Eigene Bilder zum Sitzen gibt es noch nicht, die Figur wird so lange etwas gestaucht gezeigt.
  - **So testest du es:**
    1. Auf dem Weg nach Grünwacht gegen ein Monster kämpfen und dabei Mana verbrauchen.
    2. Nach dem Kampf steht oben „Mana … / …“. Der nächste Kampf beginnt mit diesem Mana.
    3. X drücken: Die Figur setzt sich, das Mana steigt langsam. Loslaufen lässt sie aufstehen.
    4. Am Lagerfeuer des Rastplatzes X drücken: Das Mana füllt sich deutlich schneller.

- **Neu (02.11.): D5a Mana nur durch Handeln** (Projekt 14, K.2): Im Kampf füllt sich Mana nicht mehr von selbst. Es gibt Mana zurück für einen normalen Angriff (etwas), eine perfekte Parade oder ein perfektes Ausweichen (mehr, mit „+Mana“ über der Figur) und für Abwarten (etwas). Neu ist der **Manatrank** für den Gürtel, Bingo verkauft ihn für 25 Bronze. **Abklingzeiten** haben nur noch die stärksten Fähigkeiten (bisher 3 Züge und mehr), die anderen begrenzt das Mana. Der Kraftschlag des Novizen geht also so oft, wie das Mana reicht.
  - Ein Probekampf in der Prüfung (Gruppenkampf auf den Kreuzwegfeldern, ohne Trank) dauert im Schnitt 3,5 Runden, das Ziel sind 3 bis 5. Alle Zahlen sind vorläufig.
  - Noch nicht drin: Hinsetzen und Lagerfeuer (D5b). Bis dahin startet jeder Kampf weiter mit vollem Mana.
  - **So testest du es:**
    1. Einen Kampf beginnen und zweimal Kraftschlag nehmen: Das Mana sinkt und kommt zu Beginn des nächsten Zuges nicht von selbst zurück.
    2. Einen normalen Schlag machen: Das Mana steigt ein bisschen.
    3. Einen Angriff perfekt parieren: Über der Figur steht „+Mana“, und die blaue Leiste wächst deutlich.
    4. Bei Bingo einen Manatrank kaufen, an den Gürtel hängen und im Kampf trinken (gratis, du bist danach noch dran).

- **Neu (02.11.): D4 Werte für Waffen und Rüstung** (Projekt 14, K.1): Es gibt jetzt Ausrüstung auf sechs Plätzen (Waffe, Kopf, Körper, Schuhe, zweimal Schmuck). Jeder startet mit Kurzschwert, Stoffkappe, Lederweste und Lederstiefeln. Damit kämpft man genauso wie bisher, etwa ein Drittel der Kraft kommt aus der Ausrüstung.
  - **Waffenkraft** macht mehr Schaden und Heilung. **Verteidigung** senkt Schaden im Nah- und Fernkampf, **Widerstand** senkt Magie-Schaden. Platte hat mehr Verteidigung, Stoff mehr Widerstand, Schmuck gibt nur Bonus-Werte.
  - **Waffen-Tempo:** Schnelle Waffen geben 2 Tempo, schwere kosten 2, dann ist man auf der Zugleiste später dran.
  - **Seltenheit:** Der Name hat die Farbe der Seltenheit, ungewöhnliche Teile haben einen Bonus-Wert (zum Beispiel Leben +5).
  - **Zum Ausprobieren verkauft Bingo** Breitschwert (schwer), Flinken Dolch (schnell), Kettenhemd (Platte), Wollrobe (Stoff) und Glückskette (Schmuck), bis die Händler mit D13 kommen.
  - Alle Zahlen sind vorläufig, der Feinschliff kommt am Ende. Noch nicht drin: Waffen nur für die eigene Klasse, Sonderwerte ab „Selten“, zufällige Bonus-Werte bei Beute.
  - **So testest du es:**
    1. C drücken: Unter „Ausrüstung“ stehen die vier Grundteile mit ihren Werten.
    2. Bei Bingo das Breitschwert kaufen, in der Tasche (I) anklicken: Grüne Pfeile zeigen mehr Waffenkraft und Leben, ein roter Pfeil weniger Tempo.
    3. „Anlegen“ drücken: Das Kurzschwert liegt jetzt in der Tasche, das Breitschwert steht unter „Ausrüstung“.
    4. In einen Kampf gehen: Mit dem Breitschwert triffst du härter, kommst auf der Zugleiste aber später dran. Mit dem Flinken Dolch ist es umgekehrt.
    5. Wollrobe und Kettenhemd vergleichen: Die Robe schützt besser gegen Magie, das Kettenhemd besser gegen Schläge.

- **Neu (02.11.): D3c Aussehen-Plätze** (Projekt 13, Schritt 6): Im Werte-Fenster (Taste C) steht jetzt „Aussehen“ mit drei Knöpfen für Hut, Rücken und Farben. Das ist nur Aussehen, die Werte bleiben gleich. Das Aussehen wird im Spielstand gespeichert, und Mitspieler sehen es auch. Es geht nur mit einer Figur aus „Figur erstellen“. Das Waffen-Aussehen kommt mit D2b.
  - **So testest du es:**
    1. Neues Spiel, in „Figur erstellen“ eine Figur bauen.
    2. C drücken und unter „Aussehen“ auf „Hut: keins“ klicken: Die Figur trägt den Wanderhut, auch im Bild oben im Fenster.
    3. „Rücken“ und „Farben“ durchklicken. Angriff, Tempo, Leben und Mana bleiben gleich.
    4. Spiel schließen und wieder starten: Hut, Umhang und Farben sind noch da.
    5. In einen Kampf gehen: Die Figur kämpft mit Hut und Umhang.

- **Neu (02.11.): D3b Umfärben** (Projekt 13, Schritt 5): Das Spiel tauscht die festen Farbtöne gegen eine andere Farbpalette. Zur Probe gibt es „Glutrot und Schwarz“ (Set der Vulkanschmiede) und „Waldgrün und Erdbraun“. Weil es noch keinen Klassen-Körper nach den neuen Regeln gibt, färben sich vorerst nur Hut und Umhang. Novizen werden nicht umgefärbt.
  - **So testest du es:**
    1. Editor → „Figuren-Animationen“, den Novizen-Körper wählen, Hut und Umhang anlegen.
    2. „Farben: Grundfarben“ drücken, dann werden Hut und Umhang schwarz und glutrot. Noch einmal drücken für Waldgrün.
    3. Darauf achten, dass der Novize selbst (Weste, Hemd, Schild) gleich bleibt und die Ränder sauber sind.

- **Neu (02.11.): D3a Hut und Umhang als Schichten** (Projekt 13, Schritt 4): Der Hut sitzt auf dem Kopf und neigt sich mit ihm, der Umhang hängt hinter dem Körper. Von hinten liegt der Umhang über dem Rücken, beim Liegen nach dem Fallen ist er nicht zu sehen. Hut und Umhang sind vorerst **einfach gezeichnete Platzhalter** (brauner Wanderhut, dunkelroter Umhang). Sobald deine Blätter „Probe-Hut“ und „Probe-Umhang“ da sind, tausche ich sie aus.
  - **So testest du es:**
    1. Editor → „Figuren-Animationen“, mit „Körper“ den Novizen-Körper wählen.
    2. „Hut: keiner“ drücken, dann trägt die Figur den Wanderhut. „Rücken: keiner“ drücken, dann kommt der Umhang dazu.
    3. Alle Bewegungen durchklicken (Angriff, Parade, Fallen, Sieg): Der Hut bleibt auf dem Kopf, der Umhang hinter dem Rücken.
    4. Die Ansicht von hinten (ganzer Umhang) gibt es im Spiel erst, wenn die Figuren in der Stadt in vier Richtungen laufen. Claude hat sie mit Fotos aller Bewegungen geprüft.

- **Neu (02.11.): D2a Regeln und Bilder geprüft** (Projekt 13, Schritt 1 und 2):
  - Vorschlag für den Zusatz „FIGUREN“ zum Stil-Block: Körper ohne Waffe, Köpfe ohne Hut, Rücken frei, wenige klare Farbflächen, keine Effekte im Bild (`LOOK.md`, Abschnitt 9a). **Von Marco zu entscheiden:** Ja zum Wortlaut, dann kommt er in den Stil-Block.
  - Liste, was neu gezeichnet werden muss (`LOOK.md`, Abschnitt 12): Alle Novizen-Bilder passen zur Palette, haben aber Schwert und Klinge eingemalt. Es fehlen fünf Blätter ohne Klinge (männlich Blatt 2 und 3, weiblich Blatt 1 bis 3). Funken, Schwungbögen und Kopfreste entfernt Claude beim Zuschneiden. Kofi wird nicht neu gezeichnet, er bekommt den Novizen-Körper.
  - Marcos Bilder liegen als `Figuren.rar` (57 MB) in Google Drive. Das ist zu groß zum Holen aus der Cloud: Die Bilder einzeln hochladen oder im Chat anhängen.
  - **So testest du es:**
    1. `LOOK.md` öffnen, Abschnitt 9a lesen: Sind die Regeln verständlich und so gewollt?
    2. Abschnitt 12 lesen: Passt die Liste zu dem, was du in den Bildern siehst?
    3. Im Spiel ändert sich noch nichts.

- **Neu (01.11.): D1 Bildaufträge für die Figuren:** 113 Prompts in `Spieldesign/GRAFIK_AUFTRAG.md` Teil D und auf der Seite „Asterfall Bildaufträge“: Probe am Novizen, fünf Klassen, Baukasten, 21 Nebenfiguren und 19 Hauptfiguren. Die Haupt- und Nebenfiguren waren noch nicht eingeplant: Sie sind im Spiel bisher Platzhalter.
  - Geändert nach Marcos erstem Versuch: Beim Novizen bleibt der Griff in der Hand, nur die Klinge geht weg. Körper-Prompts nennen keine Waffe und keine Klasse mehr. Marcos Blatt liegt als `tools/vorlagen/novize_m_kampf_a_ohne_klinge.png` bereit (gelbe Funken entfernt Claude in D2).
  - Geliefert (02.11.): 38 Blätter liegen unter `tools/vorlagen/` (Novize ohne Klinge, Kurzschwert, Probe-Hut, Probe-Umhang, Waffen und Rückenteile der Klassen, Körper der fünf Klassen). Es fehlt die Klingentänzerin Blatt 1 (`klingentaenzer_w_blatt1.png`). Noch nicht geliefert: Figuren 3 bis 5 (Grundkörper, Köpfe, Neben- und Hauptfiguren).
  - Beim Einbauen von Claude zu beheben: gelbe Funken bei `schmied_m_blatt1` und `klingentaenzer_m_blatt1`, grüne Stellen auf dem Rücken bei `zaehmer_w_welt`, rotes Halstuch in einem Bild bei `saengerin_w_blatt2`, blasse Farben bei `bogen_m_welt`, je ein Bild zu viel in Reihe 3 bei `bogen_m_blatt2` und `bogen_w_blatt2`.
  - **Von Marco zu entscheiden:** Kobalt nutzt in den Prompts den Körper des Zähmers. Die Sternensängerin gibt es vorerst nur weiblich (Marco, 01.11.).
  - **So testest du es:** Die Seite öffnen, bei „Figuren: Probe“ einen Prompt kopieren und das Bild erzeugen.

- **Neu (01.11.): Alle Bilder von Grünwacht und Glutoase zugeschnitten:** 18 Monster-Familien mit 30 Arten, 7 Boss-Blätter (Pilzhöhle und
  Vulkanschmiede), 111 Baukasten-Teile (`gw_`, `go_`, `vs_`) und 11 neue Böden. Rindenbär, Steinkröte, Sporenling, Splitterbär, Leuchtmotte,
  Wurzelkriecher, Sporenkönigin, Sporenknospe, Wurzelmutter und Der Vorbote zeigen im Kampf jetzt die neuen Bilder. Die übrigen Monster haben Bilder,
  stehen aber noch in keinem Kampf. Die Karten der Glutoase sind noch nicht umgebaut, der Kampf-Hintergrund der
  Vulkanschmiede liegt als Vorlage bereit (`tools/vorlagen/schmiede_v3.png`). Die besonderen Bewegungen der Pilzhöhlen-Bosse sind noch nicht an ihre Angriffe gekoppelt.
  - **So testest du es:** Grünwacht bis zum Wald spielen, Rindenbär oder Steinkröte haben neue Bilder; in der Kampf-Sandbox „Pilzhöhle: nur Bosse“ wählen.
- **Neu (01.11.): Grünwacht aus dem Baukasten** (Projekt 9, Schritt 6): Weg nach Grünwacht, Waldboden, Wipfelheim und Pilzhöhle
  stehen jetzt aus den gemalten Teilen. Figuren, Monster, Orte, Aufträge und Wege bleiben auf ihren Feldern. Werkzeug: `tools/gruenwacht_karten.py`.
  - Geändert gegenüber vorher: Der Koch-Stand steht vor dem Gasthaus (Feld 12,22), die Bank östlich von Bankhüter Tamm, Dornfeders Halle ein Feld weiter westlich und schmaler, dafür tiefer.
  - Dornfeders Halle hat ihr eigenes Bild (Marcos Blatt `tools/vorlagen/gruenwacht_halle.png`).
  - **So testest du es:**
    1. Von Kreuzweg nach Westen über den Weg nach Grünwacht bis Wipfelheim gehen.
    2. In Wipfelheim Gasthaus, Halle, Bank, Labor und Stall ansehen und hinter Häuser laufen (sie werden durchsichtig).
    3. Mit dem Seilaufzug hinunter in den Waldboden: Rowans Grab, Bienenstock und Urbaum finden.
    4. In die Pilzhöhle gehen und bis zur Sporenkönigin laufen.
- **Neu (01.11.): Kreuzweg aus dem Baukasten** (Projekt 9, Schritt 5): Die echte Stadt steht jetzt aus den Baukasten-Teilen
  (`data/kreuzweg_karte.json`), alle Figuren, Aufträge und Orte sind umgezogen (`data/kreuzweg.json`). Figuren werden wie
  im Testfeld gezeichnet (80 %), Häuser werden nur durchsichtig, wenn die eigene Figur wirklich dahinter steht. Das Tor nach
  Die Tore folgen dem Kreis der Städte: Süden Glutoase, Westen Grünwacht, Nordwesten Nebelinseln, Norden Arkanum, Osten Messinghafen, Südosten das sechste Tor mit Brom und Mira (Südost-Weg hinter der Schmiede). Nur Glutoase und Grünwacht führen schon hinaus. An den Toren nach Nebelinseln, Arkanum und Messinghafen hält eine Torwache einen auf, die Tore sind zu.
  Die Bank und die Schmiede sind neu hingestellt, dazu Festbühne und Übungsplatz neben der Gilde.
  **So testest du es (in der Demo):** 1. Neues Spiel: Ankunft an der Brücke, Weg zur Gilde. 2. Hinter ein Haus laufen.
  3. Marktplatz, Bingos Stand, Bank und Gesandten-Hof besuchen. 4. In der Festnacht: Lichter und Krater ansehen.
  5. Durch die Weststraße nach Grünwacht und zurück.

- **Neu (01.11.): Demo-Start: Monster auf den Kreuzwegfeldern** (Marcos Entscheidung: Kobolde bleiben im Spiel, bekommen
  aber später einen anderen Platz): Ye's Lektionen, der Überfall auf die Übungswiese und die Probestunden nutzen jetzt
  Tauschleim, Wiesenhoppler, Knollenkäfer und Löwenzahnling. Die Texte sagen „Monster“ statt „Kobolde“. Die Werte sind
  die der Kobolde; die Tabelle nach Rolle und die volle Fähigkeiten-Liste kommen noch. **So testest du es (in der Demo):**
  1. Neues Spiel, Grundausbildung bei Ye. 2. Überfall mit Tessa und Gorm spielen. 3. Eine Probestunde spielen.

- **Neu (01.11.): Hirschtal-Monster und Startbildschirm:** Sieben weitere Familien (Wildschwein, Ranke, Krabbe, Vogel, Wolf,
  Geist, Hirsch) und 19 Arten liegen als Bilder in `assets/figuren/`, dazu die Vögel- und Wölfe-Arten für Wachtwald,
  Tiefwurzel und Pilzhöhle. Sie kämpfen noch nicht mit. Ausnahme: Windfalke, Sporenwolf und Donnerhirsch waren schon in
  Kämpfen und haben jetzt ihr echtes Bild statt des Platzhalters. Das Spiel startet mit dem neuen Logo; nach Taste oder Klick
  rückt es nach oben und das Menü erscheint. **So testest du es (in der Demo):** 1. Spiel starten, Logo ansehen.
  2. Taste drücken, das Menü blendet ein. 3. Vom Abspann zurück ins Menü: Der Titel kommt nicht noch einmal.
- **Neu (01.11.): Kreuzweg-Monster, Rastplatz und Hirschtal:** Die sechs Familien (Schleim, Hase, Käfer, Blütenwesen,
  Schwarm, Igel) und elf Arten liegen als fertige Bilder in `assets/figuren/` (Werkzeug `tools/familien_bilder.py`,
  Schattenskarabäus aus dem nachbestellten Blatt). Sie sind im Spiel bekannt, kämpfen aber noch nicht mit: Die Kobolde
  bleiben, bis MONSTER.md Teil 4 entschieden ist. Ausnahme: Der Glimmerkäfer der Pilzhöhle hat jetzt sein echtes Bild statt
  des Platzhalters. Rastplatz (R1) und Hirschtal (Z2) stehen als 11 neue Teile im Baukasten, zu sehen auf dem neuen
  Wiesenstück im Süden des Testfelds. **So testest du es (in der Demo):** 1. Im Testfeld nach Süden laufen.
  2. Lagerfeuer, Zelt, Bank und Stand ansehen. 3. Jägerhütte und Waldrand ansehen, bei Nacht leuchten Laterne und Glut.
  4. Über Holzbrücke und Bachsteine gehen. 5. In der Pilzhöhle den Glimmerkäfer ansehen.
- **Neu (01.11.): Kreuzweg-Bilder eingebaut:** Die Blätter K1–K5, K7, K8, Z1a und Z1b plus die neuen geraden
  Mauerstücke (K1b) sind von Marco abgenommen und stehen im Baukasten: 28 Teile und die Blumenwiese. Im Testfeld
  stehen sie südlich der bisherigen Fläche. Die echte Stadt Kreuzweg kommt erst mit Projekt 9, Schritt 5.
  **So testest du es:** Startmenü → „Baukasten-Testfeld“, dann die Straße ganz nach Süden laufen.
  1. Links die Mauerteile, die Festbühne, die Festlaternen, den Trainingsplatz und die Banner ansehen.
  2. Rechts die fünf neuen Häuser und das Wachhäuschen ansehen, auch mal hinter ein Haus laufen.
  3. Mit **G** das Raster einschalten: Steht jedes Teil sauber auf seinen Feldern?
  4. Mit **N** auf Nacht schalten: Leuchten die Laternen an den Häusern an der richtigen Stelle?
  5. Durch das Seitentor gehen und im Südosten über den Steg laufen.

- **Neu (01.11.): Fahrplan zur Demo, Phase 0** (Brainstorm-Doc „Fahrplan zur Demo“): design.md ist auf Stand
  (Schritt 0.1). Die drei Regel-Dateien **LOOK.md**, **MONSTER.md** und **NPC.md** sind angelegt, dazu die
  Bild-Prüfung (Projekt 13, Schritt 0). Referenzbilder Vega, Gilde und Moosling von Marco abgenommen, der Stil bleibt
  wie jetzt. Schritt 0.3: Alle Bildaufträge der Demo stehen in `Spieldesign/GRAFIK_AUFTRAG.md`, Teil C. **Phase 0 ist
  damit fertig.** Als Nächstes Phase 1 (Aussehen): Projekt 13, Schritte 1 bis 3.

- **Neu (25.10.): Playtest-Rückmeldungen Teil 1 eingebaut** (Liste im Brainstorm-Doc unter „Testtag-Notizen“):
  Fehler (Ye-Laternen, Silberhirsch, Pilzhöhle), Parier-Tutorial, Abwarten für alle, Aufträge allein und Dungeon nur für die Gruppe,
  Nebenauftrag-Wegweiser 1-2-3, Auftragsbuch-Reiter, Monster-Stall und Rudel-Fenster, Kobalt hinter seinem Monster,
  Passive und Reaktion als Kästchen im Kampf. **Neu (26.10.):** Tasche mit Kästchen und Ziehen (Projekt 0, Schritt 1), Klasse erst beim Lehrmeister (Schritt 2),
  Kael auf der Westplattform (Schritt 3), größeres Grünwacht (Schritt 4). **Projekt 0 ist damit fertig.**

- **Neu (22.10.): Marcos Rückmeldungen zur ersten Stadt eingebaut** – Einzelheiten unter „Fertig in Runde 2“ →
  „Rückmeldungen vom 22.10.“, Test-Liste ganz oben unter „Was du testen kannst“.

- **Kampf-Sandbox** (Lernprojekt 2): alle 11 Klassen, Element-Sechseck, Duette, Zähmen, Test-Dungeon Pilzhöhle
  mit Urbaum-Entscheidung, Kampfauswertung. Der Kampf ist in Regeln (`battle_state.gd`) und Anzeige (`combat.gd`) getrennt.
- **Kreuzweg-Demo** (Lernprojekt 3): Die **erste Stunde ist komplett spielbar**, von der Ankunft bis zum Abspann
  (alle 9 Schritte aus `KREUZWEG_PLAN.md`). Steuerung per Tasten, Steuerknopf oder Antippen, Speichern, Musik mit Lautstärke-Regler.
- **Zusammen spielen** (Lernprojekt 4, Plan in `ZUSAMMEN_PLAN.md`): **alle 8 Schritte eingebaut**, Marco testet.
  Bis zu 4 Spieler übers Internet (Online-Server bei Render, Frankfurt): zusammen laufen, Chat, Gruppen, Geschichte
  gemeinsam mit Abstimmung, gemeinsamer Kampf, Nacht des Sternenfalls zusammen, Wiederverbinden nach einem Abbruch.
- **Bauaufträge** (`BAUAUFTRAEGE.md`): Projekt 1 Schritt 1, 3 und 4 (Licht in Welt, Kampf und Pilzhöhle) fertig (22.10.), Schritt 2 (Pixel-Paket) zurückgestellt. Projekt 2 „Kampfgefühl“ (Parieren, harte Treffer, Schadenszahlen) fertig (22.10.). Projekt 0 (Playtest 25.10.) fertig (26.10.). Projekt 3 „Geld“ fertig (27.10.: Bronze, Silber, Gold und knappe Beträge; am 28.10. in main übernommen). Projekt 4 Schritt 1 (Tasche mit 30 Plätzen) und „Wegwerfen und Beute-Fenster“ fertig (27.10., am 28.10. übernommen). Projekt 9 „Kreuzweg im Baukasten“: Schritt 1–4 fertig (27.10.). Projekt 10 „Oberfläche nach Marcos UI-Entwurf“ fertig (27.10.). Projekt 4 „Tasche und Bank“ fertig (28.10.). Projekt 5 Schritt 1 und 2 (Gürtel, ein Trank pro Zug gratis) fertig (28.10.). Projekt 11 Schritt 1 (Probe mit Kofi: Kopf und Körper getrennt) und Schritt 2a (Kofis Kopf-Blatt) fertig (28.10.), Schritt 2b in Arbeit (Kopfwechsel, 1 von 5 Köpfen). Schritt 3 fertig (beide Novizen-Körper, Kopf neigt sich mit). Schritt 5 „Figur erstellen“ fertig (28.10.). Schritt 2b fertig: alle sechs Novizen-Köpfe (28.10.). Nächster Schritt: Projekt 5 Schritt 3 „Gemeinsame Trank-Wartezeit“.
- **Als Nächstes:** Marcos Rückmeldungen zur ersten Stunde am Stück: Teil 1 fertig (Schritt 18: Grundwerte, langer Lernkampf, schwerere Kämpfe); Schritt 19: Kampf-Geräusche, Schritt 20: größere Stadt mit Ständen und Gesandten-Bildschirm. Alle Punkte aus dem Test sind eingebaut. Außerdem Schritt 1 von
  „Zusammen spielen“ testen. Marcos Entscheidungen vom 20.10. stehen in `ZUSAMMEN_PLAN.md`. Schritt 2
  (Online-Server) ist vorbereitet: Marco legt nach `SERVER_ANLEITUNG.md` ein kostenloses Konto bei Render an.
- **Lernprojekt 5 „Grünwacht“:** Plan steht in `GRUENWACHT_PLAN.md` (11 Schritte: Reise nach Wipfelheim, eigene Klasse
  in der Welt, Fenns Prüfung, Professor Esche und Kobalt, Ysoldes Geschichte, Pilzhöhle als echter Dungeon,
  Kreuzweg-Karten mit Sternentafel, Nebenaufträge, Feinschliff). Marcos Entscheidungen vom 21.10. stehen im Plan
  (alle Klassen dürfen hin, gleicher Spielstand, Weg Stufe 10–15 und Grünwacht 15–20, Sternentafel bei Bingo in Kreuzweg,
  Koch-Stand als Platzhalter, Ruf sichtbar). **Schritt 1 eingebaut (21.10.):** Nach „Leb wohl, Ye.“ geht es weiter
  über den Weg nach Grünwacht, durch den Wald und mit dem Seilaufzug hinauf nach Wipfelheim (siehe „Fertig in
  Lernprojekt 5“ und „Was du testen kannst“). **Schritt 2 eingebaut:** Monster auf dem Weg (Stufe 10–15) und dem
  Waldboden (15–20), Kämpfe mit der eigenen Klasse, Stufen bis 20. **Schritt 3 eingebaut:** Fenns Prüfung der drei
  Ziele für Bogenschützen. **Schritt 4 eingebaut:** Professor Esche, Rivale Kobalt und Tildas Unterricht für Zähmer.
  **Schritt 5 eingebaut:** Leuchtende Tiere (Jäger oder Zähmer, Ruf) und Kael. **Schritt 6 eingebaut:** Rowans leeres
  Grab mit der ersten Erinnerungs-Szene. **Schritt 7 eingebaut:** die Pilzhöhle unter dem Urbaum als echter Dungeon.
  **Schritt 8 eingebaut:** Ende der Region (Ysolde und Kael, Wahrheit oder Geheimnis, Abspann „Ende von Grünwacht“).
  **Schritt 9 eingebaut:** Kreuzweg-Karten mit Sternentafel, Marv und Oma Hagebutte. **Schritt 10 eingebaut:** Nebenaufträge
  (Kobalts Revanche, Omas Herausforderung, der verrückte Bienenstock). **Schritt 11 eingebaut:** Feinschliff
  (Grünwacht-Musik, automatischer Durchlauf der ganzen Region, Erfahrung abgestimmt). **Alle 11 Schritte sind gebaut.**
  Jetzt testet Marco alles zusammen.
- **Neu (21.10.): Figuren und Nebenaufträge aus Sitzung 21** in Kreuzweg: Wirtin Hanne mit Gasthaus Wegrast, Vogt Edmar,
  Steinmetz Quill, die Kinder Pip und Lotte, die Wache heißt jetzt Brom. Fünf Nebenaufträge mit **blauem „!“ und „?“**
  (Hauptaufträge bleiben gelb). Siehe „Schritt 21“ unten, Test-Liste unter „Was du testen kannst“.
- **Platzhalter:** Alle Texte der Hauptfiguren (Ye, Mira, Ren, Marv, Lene, Bingo, Gesandte …) stehen in `data/dialoge.json`
  und werden von Marco noch geschrieben (Anleitung in `data/LIESMICH.md`).
- Selbst gewählte Zahlen und Passiven: Abschnitt „Vorläufige Werte (Feinschliff am Ende)“ unten.
- Web-Version: **https://cazex-studio.github.io/MiniKampf/** (wird nach jedem Push automatisch neu gebaut).

## Bauaufträge (Liste in `BAUAUFTRAEGE.md`)

- **Projekt 13, Schritt 0: Im Stil bleiben** (01.11., Fahrplan zur Demo Schritt 0.2):
  - **LOOK.md** ist die einzige Quelle für den Look: die sechs Regeln, Grundstil, Blickwinkel, Licht von links oben,
    Schattenstufen, Größen in Pixeln (an den Bildern im Spiel gemessen), Farben, Umriss, Variante C, der feste
    Stil-Block (wörtlich aus GRAFIK_AUFTRAG.md) und eine erste Bestandsaufnahme der Bilder im Spiel.
  - **Farbpalette** `data/look_palette.json`: 64 Farben aus den Referenzbildern plus je fünf Stufen für jedes Element,
    jede Region, Haut und Metall.
  - **Werkzeug** `tools/look_pruefen.py`: `pruefen` (Hintergrund, Farben, Umriss, Größe), `nachbearbeiten` (immer
    gleich: Hintergrund, Zuschnitt, Größe, fremde Farben auf die Palette), `vergleich` (neues Bild neben den
    Referenzbildern in Spielgröße, hell und dunkel), `palette` (Palette neu aus den Referenzbildern).
  - **Referenzbilder** (von Marco am 01.11. abgenommen): Vega für Figuren, die Abenteurergilde für Gebäude, der
    Moosling für Monster. Marco hat außerdem entschieden: Der Stil bleibt so wie jetzt (keine grobe Pixel-Art).
  - Dazu **MONSTER.md** (Monster-Regelblatt mit allen Steckbriefen und Familien der Demo) und **NPC.md**
    (NPC-Regelblatt mit allen Steckbriefen für Kreuzweg, Grünwacht und Glutoase). Beide melden am Ende, was im Spiel
    noch anders ist (z. B. die Kobolde auf den Kreuzwegfeldern, der alte Spruch von Ye).
  - **So testest du es:** LOOK.md lesen. Dann im Ordner MiniKampf in der Eingabeaufforderung
    `python tools/look_pruefen.py pruefen assets/figuren/kofi_idle_anim_f0.png` (passt) und
    `python tools/look_pruefen.py pruefen assets/figuren/sternenfresser_idle_anim_f0.png` (meldet fremde Farben).
    `python tools/look_pruefen.py vergleich assets/baukasten/objekte/wegrast.png` legt das Vergleichsbild nach
    `tools/vergleich/`. Oder einfach Claude Code bitten: „Prüf dieses Bild gegen LOOK.md.“

- **Projekt 11, Schritt 2b: alle sechs Novizen-Köpfe** (28.10., Blätter `tools/vorlagen/m2_kopf.png`, `m3_kopf.png`, `w2_kopf.png`, `w3_kopf.png`):
  - Neu: Novize m2 (schwarze Haare), Novize m3 (hellbraune Haare), Novizin w2 (schwarzer Zopf), Novizin w3 (lockiger Zopf).
    Zusammen mit m1 und w1 gibt es jetzt je Geschlecht drei Köpfe. Alle sitzen sauber auf beiden Körpern, auch beim
    Angriff, Fallen und von hinten.
  - **So testest du es:** Editor → „Akt Kreuzweg“ → bei „Männlich“ und „Weiblich“ mit ◀ ▶ durch die drei Köpfe blättern.

- **Figur erstellen nach Marcos Rückmeldung** (28.10.):
  - Man wählt **männlich oder weiblich**, daraus folgt der Körper, und es gibt nur Köpfe dieses Geschlechts.
  - Die Köpfe sind **namenlos**: „Novize m1“ (der Kopf aus Kofis Blatt) und „Novizin w1“ (der rote Zopf, vorher „Mira“).
    Weitere Köpfe heißen m2, m3 … und w2, w3 … und erscheinen von selbst bei „Figur erstellen“. Damit gibt es auch keine
    zweite Mira mehr. Im Editor heißt die Kofi-Figur jetzt „Novize m1“.
  - **So testest du es:** Editor → „Akt Kreuzweg“: „Männlich“ zeigt Novize m1, „Weiblich“ Novizin w1.

- **Projekt 11, Schritt 5: Figur erstellen** (28.10.):
  - Neuer Bildschirm vor einem neuen Spiel: **Körper** (männlich/weiblich), **Kopf** (mit ◀ ▶ blättern, jetzt Kofi und Mira)
    und **Name**. Links laufen vier Vorschauen mit: in der Welt, Laufen, im Kampf, Angriff.
  - Die Figur wird im Spielstand gespeichert (als „Körper+Kopf“, z. B. `novize_w+mira`), über ihr steht ihr Name.
    Im Kampf und in der Zugleiste ist es dieselbe Figur. Ältere Spielstände ohne Figur spielen weiter wie bisher.
  - Jeder Kopf passt auf jeden Körper. Soll es wie bei Ragnarok feste Köpfe je Geschlecht geben, ist das schnell umgestellt.
  - **So testest du es:** Menü → „Kreuzweg-Demo“ (nur wenn es noch keinen Spielstand gibt, sonst oben „Neu beginnen“)
    oder Editor → „Akt Kreuzweg“: Figur zusammenstellen, Namen eingeben, „Los geht's“. Du läufst mit ihr durch Kreuzweg.
    „Neu beginnen“ führt jetzt auch zurück zu „Figur erstellen“.

- **Projekt 11, Schritt 3 (Teil 5): Blatt 3 weiblich (Welt)** (28.10., Blatt `tools/vorlagen/novize_w_welt.png`):
  - Stehen (6 Bilder) und Laufen (5 Bilder) schräg von vorne und von hinten. **Beide Novizen-Körper sind damit komplett.**
  - **Einfärben entfällt** (Marcos Entscheidung 28.10.): alle Novizen sehen gleich aus, unterscheiden tun sie sich am Kopf.
    Färbemittel wie in Ragnarok stehen als Idee im Ideen-Parkplatz. **Schritt 3 ist damit fertig.**

- **Projekt 11, Schritt 3 (Teil 4): Blatt 2 weiblich** (28.10., Blatt `tools/vorlagen/novize_w_kampf_b.png`):
  - Angriff, Fallen, Sieg und Fähigkeit (3 Bilder) für die Novizin. Im letzten Fall-Bild ist das Oval halb hinter dem
    Schild versteckt; ist die Messung so unsicher, legt das Werkzeug den Kopf bei einer liegenden Figur jetzt flach hin.
  - **So testest du es:** Editor → „Figuren-Animationen“ → „Körper: Novizin (w)“, dann Angriff, Fallen, Sieg, Fähigkeit.

- **Projekt 11, Schritt 3 (Teil 3): Blatt 3 männlich (Welt)** (28.10., Blatt `tools/vorlagen/novize_m_welt.png`):
  - Stehen und Laufen schräg von vorne und von hinten, je 5 Bilder (so kam das Blatt). Der männliche Körper ist damit komplett.
  - **So testest du es:** Editor → „Figuren-Animationen“ → „Körper: Novize (m)“: alles ist da. In der Welt selbst kann man
    den Novizen-Körper noch nicht spielen; das kommt mit „Figur erstellen“ (Schritt 5).

- **Projekt 11, Schritt 3 (Teil 2): Blatt 2 männlich, Kopf neigt sich mit** (28.10., Blatt `tools/vorlagen/novize_m_kampf_b.png`):
  - Angriff (6 Bilder), Fallen (6), Sieg (4) und Fähigkeit wirken (3 statt 4, so kam das Blatt) sind eingebaut.
  - **Der Kopf neigt sich jetzt mit:** Das Werkzeug liest an den länglichen grünen Ovalen ab, wie schräg der Kopf ist
    (beim Ausholen nach vorne, beim Zurückfallen nach hinten, im Liegen fast waagerecht), und das Spiel dreht den
    gewählten Kopf genauso um den Hals. Gemessen wird nur am freien Rand des Ovals, weil das Halstuch unten etwas verdeckt.
    Blatt 1 hat noch runde Kreise, dort bleibt der Kopf gerade.
  - Blatt 2 war etwas größer gezeichnet als Blatt 1: Das Werkzeug gleicht das an (gemessen vom Oval bis zu den Füßen).
  - Körper-Bilder bekommen oben und seitlich etwas Platz, damit ein großer oder geneigter Kopf nicht abgeschnitten wird.
  - **So testest du es:** Editor → „Figuren-Animationen“ → „Körper: Novize (m)“, dann Angriff, Fallen, Sieg und Fähigkeit
    drücken, mit „Kopf: …“ zwischen Kofi und Mira wechseln. Am besten mit Zeitlupe.

- **Projekt 11, Schritt 3 (Teil 1): Novizen-Körper, erstes Blatt** (28.10., Blätter `tools/vorlagen/novize_m_kampf_a.png` und `novize_w_kampf_a.png`):
  - Marcos erste Körper-Blätter (männlich und weiblich, Kampf: Stehen, Laufen, Getroffen, Parade) sind eingebaut, mit grünem Oval statt Kopf.
    Das neue Werkzeug `tools/koerper_blatt.py` schneidet die Bilder aus, nimmt das grüne Oval heraus und merkt sich den
    Halspunkt (knapp unter der Stelle, wo das Oval im Halstuch verschwindet). Das Spiel setzt dort den gewählten Kopf ein.
  - Kofis und Miras Kopf passen ohne Nacharbeit, ohne Reste vom alten Kopf. Hände sind in Handschuhen, also passt jede Hautfarbe.
  - Noch offen: Blatt 2 (Angriff, Fallen, Sieg, Fähigkeit) und 3 (Welt) für beide Körper, das Einfärben von
    Halstuch und Schildrand (jetzt grau) und das Schrägstellen des Kopfes. Fehlende Bewegungen zeigen solange „Stehen“.
  - **So testest du es:** Editor → „Figuren-Animationen“ → Knopf „Körper: …“ auf „Novize (m)“ oder „Novizin (w)“. Mit „Kopf: …“ zwischen
    Kofi und Mira wechseln. Stehen, Laufen, Getroffen und Parade gehen schon.

- **Projekt 11, Schritt 2b (Teil 1): Kopf wechseln, zweiter Kopf: Mira** (Name von Marco, 28.10.) (28.10., Blatt `tools/vorlagen/mira_kopf.png`):
  - Jeder Kopf hat jetzt einen **Halspunkt** (unterste Stelle des Halses), und das Spiel setzt ihn genau auf den Hals des
    Körpers. Deshalb passt auch ein Kopf mit Zopf oder langen Haaren auf Kofis Körper. Weitere Köpfe werden genauso groß
    verkleinert wie Kofis Kopf.
  - Beim Zerlegen blieben vorher Reste von Kofis Gesicht am Körper (Hautglanz wurde wieder für das gelbe Halstuch gehalten).
    Bei Kofis eigenem Kopf sah man das nicht, beim roten Kopf schon. Jetzt gilt nur noch das große Tuchstück als Halstuch.
  - **Noch nicht schön:** An ein, zwei Bildern (Getroffen, Fähigkeit) schauen dunkle Locken von Kofi hinter dem neuen Kopf
    hervor, und Hände und Arme bleiben in Kofis Hautfarbe. Beides verschwindet mit dem Novizen-Körper ohne Kopf (Schritt 3).
  - **So testest du es:** Editor → „Figur: Kofi“ → „Figuren-Animationen“ → Knopf „Bilder: …“ auf „neuer Kopf“. Darunter
    erscheint „Kopf: Kofi“: draufdrücken, dann trägt Kofis Körper den roten Zopf-Kopf. Alle Bewegungen durchprobieren.

- **Projekt 11, Schritt 2a: Kofis Kopf-Blatt** (28.10., Blatt `tools/vorlagen/kofi_kopf.png`):
  - Die elf Köpfe aus Marcos Blatt (seitlich 5 Gesichter, schräg vorne 4, schräg hinten 2) sind ausgeschnitten und auf
    Spielgröße gebracht (`assets/teile/koepfe/`). Das Werkzeug `tools/kopf_koerper.py` sucht jetzt in jedem Bild,
    wo der Kopf sitzt, indem es den neuen Kopf darüberlegt. Das ist viel genauer als vorher (die alte Halserkennung
    hatte Hautglanz für das gelbe Halstuch gehalten und den Kopf oft nur an den Haaren abgeschnitten).
  - **Gesicht passend zur Bewegung:** Schmerz beim Getroffen-Werden und am Anfang des Fallens, entschlossen bei Angriff
    und Parade, Freude beim Sieg, Augen zu bei „Fähigkeit wirken“ und am Ende des Fallens. Sieg und Fähigkeit nehmen den
    Kopf „schräg vorne“, weil Kofi dort zum Betrachter schaut.
  - Erst kommt der Kopf, dann der Körper darüber: Halstuch und Schwert liegen vor dem Kopf, der Halsansatz verschwindet im Tuch.
  - **Grenzen dieser Probe:** Der neue Kopf ist immer gerade, auch wenn Kofi sich vorbeugt (z. B. beim Fallen oder bei der
    Fähigkeit). An zwei, drei Stellen schaut noch ein Rest der alten Haare hervor. Die zwei liegenden Bilder bleiben ganz.
    Bei den neuen Körpern ohne Kopf (Schritt 3) fällt das alles weg.
  - **So testest du es:** Editor → „Figur: Kofi“ → „Figuren-Animationen“ → Knopf „Bilder: …“ bis „neuer Kopf“ drücken.
    Dann alle Knöpfe durchprobieren (Getroffen, Angriff, Sieg, Fähigkeit, Fallen), am besten mit Zeitlupe.
    Die Einstellung gilt bis zum Neustart auch in der Demo.

- **Projekt 11, Schritt 1: Probe mit Kofi – Kopf und Körper getrennt** (28.10.):
  - Kofis 49 Bilder sind in **Körper** und **Kopf** zerlegt (`assets/teile/`), mit einem Ankerpunkt am Hals
    (`data/figurteile.json`). Das Spiel setzt sie wieder zusammen. Werkzeug: `tools/kopf_koerper.py`.
  - 46 Bilder ließen sich sauber trennen. **Ganz geblieben** sind die zwei liegenden Bilder beim Fallen und das erste
    Parade-Bild (Kopf hinter dem Schild): Dort sieht man das fertige Bild, auch mit anderem Kopf. Bei den neuen Körper-Blättern
    (Schritt 3) bestellen wir den Kopf von Anfang an getrennt, dann gibt es das Problem nicht mehr.
  - **Ergebnis der Probe:** Zusammengesetzt sieht Kofi genau aus wie vorher (Test prüft jedes Bild). Mit „Standardkopf“
    (immer derselbe Kopf je Blickrichtung) wirkt er beim Laufen und Kämpfen etwas steifer, weil der Kopf nicht mehr
    mitwackelt und kein Gesicht mehr zieht – genau dafür gibt es in Schritt 2 eigene Kopf-Blätter mit Gesichtern.
  - **So testest du es:** Editor → „Figur: Kofi“ → „Figuren-Animationen“: Der neue Knopf „Bilder: ganz / aus Teilen /
    Standardkopf“ schaltet um. „Aus Teilen“ muss genauso aussehen wie „ganz“. („Standardkopf“ ist seit Schritt 2a
    „neuer Kopf“.) Die Einstellung gilt bis zum Neustart auch in der Demo (Akt Kreuzweg).

- **Kofi, der erste Novize** (28.10., Marcos drei Bildblätter):
  - Kofi ist eingebaut wie Vega: Welt in vier Richtungen, Kampf mit Stehen, Laufen, Getroffen, Parade mit Schild,
    Schwerthieb (Nahkampf), Fallen, Sieg und neu „Fähigkeit wirken“ (Hand auf die Brust bei Erster Hilfe).
    Werkzeug für alle spielbaren Figuren: `tools/figur_bilder.py`.
  - **Figur wählen:** Im Editor unten links „Figur: Vega / Kofi (wechseln)“. Die gewählte Figur spielt man allein in der
    Demo, im Baukasten-Testfeld und bei „Figuren-Animationen“; die andere läuft als **Begleiter** mit (statt des alten
    Testgefährten). Beim Zusammenspielen ist Kofi als Figur wählbar.
  - **So testest du es:** Editor → „Figur: Kofi“ → „Figuren-Animationen“: alle Knöpfe durchprobieren. Dann „Akt Kreuzweg“:
    Du spielst Kofi, Vega läuft neben dir.
- **Beschluss: Figuren wie bei Ragnarok** (Kopf und Körper getrennt) ist als **Projekt 11** geplant (6 Schritte, Probe mit Kofi zuerst).

- **Projekt 5, Schritt 2: Ein Gürtel-Gegenstand pro Zug gratis** (28.10.):
  - Im Kampf ist der **erste Trank im eigenen Zug gratis**: Danach ist man noch einmal dran („Gratis – noch dran!“).
    Ein zweiter Trank im selben Zug beendet den Zug. Der Knopf zeigt „Gürtel: gratis, du bist noch dran“ bzw. „kostet den Zug“.
  - **Der Gürtel ist jetzt die Grenze:** In den Kampf kommen nur die Tränke vom Gürtel, nicht mehr die aus der Tasche.
  - Damit niemand ohne Tränke dasteht: Neue Tränke (Belohnungen, Kauf bei Bingo) hängen sich von selbst an den Gürtel,
    solange dort Platz ist. Alte Spielstände bekommen ihre Tränke beim Laden an den Gürtel.
  - Verkaufen bei Bingo geht auch mit Tränken am Gürtel. Neue Prüfung `tests/guertel_kampf_test.gd`.
  - **So testest du es:** Einen Kampf beginnen, „Heiltrank“ wählen: Du bist gleich noch einmal dran und kannst angreifen.
    Trinkst du stattdessen einen zweiten Trank, ist danach der Gegner dran.

- **Projekt 5, Schritt 1: Vier Gürtelplätze** (28.10.):
  - In der Tasche (I) hängt unten der **Gürtel** mit vier Plätzen (dein gemalter Gürtel, leere Plätze als blasse Lederschlaufe).
  - Trank in der Tasche anklicken, dann „An den Gürtel“: Bis zu 5 Stück kommen auf einen Platz, ein angefangener Platz
    wird zuerst aufgefüllt. Was am Gürtel hängt, macht in der Tasche Platz frei. Klick auf einen Gürtelplatz legt ihn zurück.
  - Nur Gegenstände mit `"guertel": true` in `data/gegenstaende.json` (bisher der Heiltrank). Befüllen geht nur in der
    Welt, nicht im Kampf und nicht mitten im Gespräch.
  - Im Kampf zählen vorerst Gürtel und Tasche zusammen, verbraucht wird zuerst vom Gürtel. Schritt 2 macht den Gürtel zur Grenze.
  - Wird gespeichert und beim Zusammenspielen mitgeschickt. Neue Prüfung `tests/guertel_test.gd`.
  - **So testest du es:** Tasche öffnen, Heiltrank anklicken, „An den Gürtel“: 3 Tränke hängen am Gürtel, die Tasche hat
    einen Platz mehr frei. Einen Kampf mit Trank spielen: danach fehlt der Trank am Gürtel.

- **Münzen, Tränke und Gürtel als Bilder** (28.10., Marcos zweites Symbol-Blatt):
  - Ausgeschnitten mit `tools/gegenstand_bilder.py` nach `assets/gegenstaende/`: Gold-, Silber- und Bronzemünze,
    Münzstapel, großer Heiltrank, Manatrank, großer Manatrank, Elixier, Gürtel, leerer Gürtelplatz.
  - **Geld mit Münzen:** Die Tasche zeigt das Geld jetzt als „1 (Gold) 23 (Silber) 45 (Bronze)“ mit den gemalten Münzen,
    ebenso die Belohnung im Auftragsbuch. Überall, wo vorher die einzelne Münze aus dem UI-Set war (Meldungen, Laden-Knöpfe),
    steht jetzt der Münzstapel.
  - Die Tränke und der Gürtel liegen bereit für Projekt 5 (Gürtel und Tränke).
  - **So testest du es:** Tasche öffnen (I) und „Test +99 Silber“ drücken: Unten links springen die Münzen um.

- **Projekt 4, Schritt 3: Bankplätze gegen Gold erweitern** (28.10.):
  - Im Bankfenster steht oben „Bank erweitern: +10 Plätze“ mit Preis. Die Preise steigen: 50 Silber, 1 Gold, 2 Gold,
    4 Gold. Danach ist die Bank mit 60 Plätzen voll ausgebaut. Preise und Plätze stehen in `data/laeden.json` („bank“).
  - Bei zu wenig Geld kommt eine Meldung und nichts passiert. Die gekauften Plätze werden gespeichert und gelten an jeder Bankstelle.
  - **So testest du es:** In der Tasche zweimal „Test +99 Silber“ drücken, zu Bankhüterin Ilse gehen, „Bank erweitern“
    kaufen: Das Geld sinkt um 50 Silber, „In der Bank“ zeigt 30 statt 20 Plätze.

- **Gemalte Gegenstands-Symbole** (28.10., Marcos Bildblatt):
  - 17 Symbole (Heiltrank, Silberkraut, Wiesenkraut, Wildfleisch, Honigwabe, Sternensplitter, Schleuder, Bürste,
    Essenskorb, Festschüssel, fünf Festlaternen, Sternentafel, verdeckte Monsterkarte) liegen in `assets/gegenstaende/`,
    ausgeschnitten mit `tools/gegenstand_bilder.py`.
  - Zu sehen in der Tasche, im Infofenster beim Darüberfahren, im Laden und in der Bank (neben jeder Zeile).
    Gegenstände ohne Bild (Testkiesel, Testrüstung) werden weiter gezeichnet.
  - Die Festlaterne zeigt vorerst die glutrote Laterne; die anderen vier Farben liegen bereit. Die Monsterkarte wartet aufs Kartenalbum.
  - **So testest du es:** Tasche öffnen (I): Alle Gegenstände haben ihr gemaltes Bild. Bei Bingo und an der Bank stehen die Bilder neben den Zeilen.

- **Projekt 4, Schritt 2: Bank, die überall dasselbe enthält** (28.10.):
  - Zwei Bankstellen: **Bankhüterin Ilse** in Kreuzweg (rechts neben Lene an der Gilde) und **Bankhüter Tamm** in
    Wipfelheim (rechts neben Ysolde). Beide öffnen dieselbe Bank (wie die Kafra in Ragnarok).
  - Bankfenster: oben die Tasche mit „Einlagern“, unten die Bank mit „Abholen“, jeweils der ganze Stapel.
    Die Bank hat 20 Plätze (eine Sorte pro Platz, wie in der Tasche). Volle Bank oder volle Tasche: Meldung, nichts geht verloren.
  - Die Bank wird mit dem Spielstand gespeichert und beim Zusammenspielen mitgeschickt.
  - Texte der Bankhüter sind Platzhalter (`data/dialoge.json`, „bank“). Neue Prüfung `tests/bank_test.gd`.
  - **So testest du es:** In Kreuzweg mit Ilse reden, „Meine Bank öffnen“, einen Heiltrank einlagern. In Wipfelheim
    (Editor → „Akt Grünwacht“) bei Tamm nachsehen: Der Heiltrank liegt dort. Abholen, er ist wieder in der Tasche.

- **Start-Monster Moosling, Glutwelpe und Bachotter** (28.10., Marcos Bildblätter):
  - Eingebaut für den Zähmer (eigenes Team und Bank), für Kobalts Monster (etwas größer und dunkler) und die wilden
    Varianten in Grünwacht. Jedes hat Stehen, zwei Angriffe, Getroffen, Fallen und Freude nach dem Sieg.
  - Moosling: Rankenschlag und Dornenpeitsche. Glutwelpe: Glutbiss (aus dem gemeinsamen Blatt, wie gewünscht) und
    Funkenregen. Bachotter: Wasserstrahl und Welle, Fallen aus dem gemeinsamen Blatt mit dem Einzelbild als drittem Bild.
  - Der pinke Hintergrund und die Schatten unter den Füßen werden entfernt. Bilder, die sich berühren, schneidet
    `tools/monster_bilder.py` jetzt mit festen Ausschnitten.
  - Nur Vega greift als Heldin aus der Ferne an; die Monster des Zähmers stürmen beim Angriff vor.
  - **So testest du es:** Editor → „Akt Grünwacht – Als Monster-Zähmer“, bei Professor Esche ein Monster holen und gegen
    Kobalt kämpfen.

- **Marcos Entscheidungen vom 28.10. eingebaut:**
  - **Tessa und Gorm statt Ida, Bo und Tom:** Die beiden Mitschüler helfen im ersten Gruppenkampf, in den Probestunden,
    in der Nacht des Sternenfalls und in der Pilzhöhle. Die Gruppe ist allein jetzt drei statt vier stark
    (beim Zusammenspielen füllen sie bis höchstens drei auf). Platzhalter-Figuren, bis es eigene Bilder gibt.
  - **Neuer Nebenauftrag „Essen für Brom“ (Festnacht):** In der Festnacht hat Wirtin Hanne ein blaues „!“. Sie gibt dir
    eine Festschüssel für Brom am alten Südost-Tor. Er erzählt, dass das Summen heute wie ein Lied mit fünf Tönen klingt.
    Belohnung: 10 Gold, 60 Erfahrung.
  - **Kieselkobold:** Marcos zweiter Kobold ist jetzt ein eigenes Monster (Erde, flinker, Kieselwurf und Knüppelhieb)
    und kämpft im ersten Gruppenkampf mit.
  - Kreuzweg rund mit sechs Toren und die Schriftrolle „Licht im Dunkeln“ stehen in design.md und warten auf ihren Bauauftrag.
  - **So testest du es:** Editor → „Akt Kreuzweg“. Im ersten Gruppenkampf kämpfen Tessa und Gorm mit dir gegen
    Wiesenkobold, Kieselkobold, Rüpelkobold und Feldschleim. In der Festnacht zuerst zu Hanne, dann zu Brom.

- **UI-Set Teil 3: drittes Bildblatt eingebaut** (27.10., Projekt 10, Schritt 4):
  - **Kampf:** Jede Fähigkeit hat ein Symbol (Hieb, Stich, Wirbel, Heilen, Schild, Bogen, Magie, Pfote, Werkzeug,
    Sanduhr, Reihe wechseln, Ult). Gegner zeigen ihr Element als Symbol neben dem Namen. Im Kampfmenü:
    Sanduhr bei „Verteidigen“, laufende Figur bei „Fliehen“.
  - **Auftragsbuch:** rotes Bändchen mit „!“ für Hauptaufträge, mit Schriftrolle für Nebenaufträge.
  - **Werte:** Bilderrahmen um deine Figur, **Ruf als Leiste mit grünen Feldern** (wenige = abgelehnt, halb = neutral, viele = geschätzt).
  - **Trennlinie** mit Diamant unter den Fenstertiteln, **goldene Bildlaufleiste** überall.
  - **Dialog:** goldenes Weiter-Dreieck am „Weiter“-Knopf. **Chat-Sprechblasen** sind jetzt Pergament mit Spitze.
  - Bereit, aber noch nicht benutzt: Symbole für Helm, Rüstung, Kräuter, Schriftrolle, Paket, „mehr“ (für Reiter in der Tasche, sobald Gegenstände eine Art haben).
  - **So testest du es:**
    1. Einen Kampf beginnen: Die Fähigkeiten haben Symbole, der Gegner hat sein Element-Symbol neben dem Namen.
    2. J drücken: Vor den Aufträgen hängen rote Bändchen („!“ oder Schriftrolle).
    3. Als Bogenschütze oder Zähmer C drücken: Bilderrahmen um deine Figur und Ruf-Leisten mit grünen Feldern.
    4. Mit jemandem reden: Am „Weiter“-Knopf ist ein goldenes Dreieck.
    5. Beim Zusammenspielen etwas in den Chat schreiben: Die Sprechblase ist aus Pergament.

- **Oberfläche nach Marcos UI-Entwurf** (27.10., Projekt 10, Schritte 1–3):
  - **Kampf:** Zugleiste im Rahmen mit Bildern in Goldfeldern (wer dran ist, leuchtet). Namensschilder mit Goldrahmen,
    Leben und Mana mit den Füllungen aus dem Set. Neues **Kampfmenü** links: „Angriff“ wählt gleich den Grundangriff,
    „Fähigkeiten“ zeigt alles wie bisher, „Gegenstände“ nur Tränke, „Verteidigen“ = Abwarten, „Fliehen“ = Aufgeben.
  - **Sieg-Fenster** mit Banner, großem „SIEG!“, Belohnung mit Symbolen und goldenem „Zurück“-Knopf.
  - **Infofenster** beim Darüberfahren über einem Gegenstand (Bild, Name, Beschreibung, Wert).
  - **Auftragsbuch:** Liste links („!“ läuft, „?“ erfüllt), rechts der gewählte Auftrag mit Häkchen bei erledigten Zielen und Belohnung.
  - **Werte:** Bild deiner Figur im Goldrahmen, daneben Erfahrung, Leben und Mana als Leisten.
  - **Tasche:** unten Gold und belegte Plätze (z. B. 4 / 30).
  - **Schnellleiste** oben rechts mit Symbolen (Aufträge, Werte, Tasche, Menü); der Name steht beim Darüberfahren.
  - Goldene und rote Knöpfe (z. B. „Ja“ und „Noch nicht“ bei der Klassenwahl).
  - Noch offen (Schritt 4): Teile, die der Art Designer gerade zeichnet (Element-Symbole, Ruf-Leiste, Bildlaufleiste …).
  - **So testest du es:**
    1. Einen Kampf beginnen: oben die Zugleiste mit Bildern, unten links das Kampfmenü. „Angriff“ antippen, dann den Gegner.
    2. „Gegenstände“ antippen: nur der Heiltrank steht da. „Verteidigen“: deine Figur wartet ab.
    3. Den Kampf gewinnen: Sieg-Fenster mit Banner, Belohnung mit Münze und Kristall, goldener Knopf.
    4. J drücken: Aufträge links, Einzelheiten rechts. C drücken: dein Bild mit Leisten. I drücken: Gold und Plätze unten.
    5. In der Tasche mit der Maus über einen Gegenstand fahren: das Infofenster erscheint.

- **UI-Set Teil 2: Symbole, Banner und Meldungs-Rahmen** (27.10.):
  - **Meldungen** oben in der Mitte haben jetzt Rahmen mit Ranken und ein Symbol: Gold = goldener Rahmen mit Münze,
    Gegenstände = grün mit Tasche, Erfahrung, Stufe und Erfolge = lila mit Kristall, neuer Auftrag = „!“, Auftrag
    erfüllt = „?“, abgegeben = Häkchen, Kampf gewonnen = Schwert. Orts- und andere Texte bleiben einfache Zeilen.
  - **Banner:** Tasche, Auftragsbuch, Werte und Laden haben das rote Banner oben links am Titel.
  - **Auftragsbuch:** Die Reiter (Offen, Abgeschlossen, Erfolge) sind die neuen Reiter, der aktive ist rot.
    Hauptaufträge haben ein rotes „!“ bzw. ein lila „?“ vor dem Namen.
  - **Münze:** neben „Gold“ in der Tasche und auf den Kaufen- und Verkaufen-Knöpfen im Laden.
  - **Werte nach der Klassenwahl:** Symbole vor Leben (Trank), Mana (Wirbel), Tempo (Pfeil) und Stärke (Schwert).
  - Bausteine liegen in `scripts/ui_stil.gd`, Fototest: `tests/ui_auto.tscn`.
  - **So testest du es:**
    1. „Neu beginnen“ und mit Lene sprechen: Der neue Auftrag erscheint als Meldung mit goldenem Rahmen und rotem „!“.
    2. Einen Kampf gewinnen: Gold (Münze), Erfahrung (lila Kristall) und „Geschafft“ (grün, Schwert) erscheinen mit Rahmen.
    3. Mit J das Auftragsbuch öffnen: Banner oben links, rote Reiter, „!“ vor dem Auftrag.
    4. Mit I die Tasche öffnen: Münze vor „Gold“.
    5. Bei Bingo den Laden öffnen: Banner am Titel, Münzen auf den Knöpfen.

- **Asterfall-UI-Set eingebaut** (27.10., Marcos zwei Bildblätter):
  - Fenster, Knöpfe (normal, darüber, gedrückt, gesperrt), Balken, Häkchen, Eingabefelder, Reiter und der
    Lautstärke-Regler haben jetzt überall den neuen Look: dunkelblau mit Goldrand. Das gilt für das ganze Spiel
    (Einstellung im Projekt, Datei `assets/ui/asterfall_theme.tres`).
  - Die Kästchen in der Tasche sind die neuen Felder, das ausgewählte leuchtet golden.
  - Werkzeug: `tools/ui_zuschneiden.gd` schneidet die Teile aus `tools/vorlagen/ui/` aus, entfernt das Magenta und
    verkleinert sie. Ergebnis in `assets/ui/`. Schon bereit, aber noch nicht benutzt: 12 Symbole (`symbol_*.png`),
    Banner, Ranke, Pergament, rote und goldene Knöpfe, Meldungs-Rahmen in Grün, Gold und Lila.
  - Bunte Kästchen, die etwas bedeuten (Zugleiste, Karten, Klassen-Karten), sind absichtlich so geblieben.
  - **So testest du es:**
    1. Spiel starten: Die drei großen Knöpfe im Startmenü und „Musik“ haben Goldrahmen, der Lautstärke-Regler einen Gold-Diamanten.
    2. Mit der Maus über einen Knopf fahren: Er leuchtet golden. Draufklicken: Er wird kurz dunkler.
    3. In der Kreuzweg-Demo mit I die Tasche öffnen: Fenster mit Goldecken, Kästchen mit Goldrand, das angeklickte leuchtet.
    4. Einen Kampf beginnen: Die untere Leiste ist ein Goldrahmen-Fenster, die Fähigkeiten sind Goldrahmen-Knöpfe.
    5. Aufträge (J) und Werte (C) öffnen: Auch diese Fenster haben den neuen Rahmen.

- **Erste eigene Monster** (27.10., Marcos Bildblätter):
  - **Feldschleim, Wiesenkobold, Rüpelkobold und Der Sternenfresser** sind eingebaut und ersetzen die alten Platzhalter.
    Werkzeug: `tools/monster_bilder.py` (stellt das Karomuster frei, erkennt die Reihen, richtet an den Füßen aus).
  - Jedes Monster hat Stehen, Angriff, Getroffen und Fallen. Der Wiesenkobold wirft beim **Steinwurf** wirklich,
    der Sternenfresser hat eigene Bilder für **Leuchtender Biss** und **Splitterregen** und zerfließt am Ende zu einer
    Pfütze mit dem Splitter.
  - Größen: Schleim klein, Kobold etwa zwei Drittel von Vega, Rüpelkobold etwas größer als Vega, Sternenfresser riesig.
  - Monster stürmen beim Nahkampf wie bisher vor, das Treffer-Bild kommt genau beim Aufprall (wichtig fürs Parieren).
  - Marcos zweiter Wiesenkobold (`tools/vorlagen/wiesenkobold_b.png`) ist aufbewahrt, aber nicht eingebaut.
  - **So testest du es:** Editor → „Akt Kreuzweg“ und bis zum ersten Gruppenkampf spielen (Kobolde und Schleim),
    oder die Nacht des Sternenfalls (Sternenfresser).

- **Projekt 9, Schritt 3: Übergänge zwischen den Böden** (27.10.):
  - Die Bodenkacheln hatten einen dunklen Rand, dadurch sah alles kariert aus. Der Rand ist jetzt abgeschnitten.
  - Wo zwei Böden aneinanderstoßen, ragt der „stärkere“ mit einem ausgefransten, weichen Rand ins Nachbarfeld:
    Gras wächst über Erde, Pflaster und Platz, Erde über Pflaster, Pflaster über den Marktplatz. Auch an Ecken.
  - Am Bach gibt es ein Ufer: Gras ragt ins Wasser, darunter liegt ein dunkler Schatten.
  - Das Spiel macht die Übergänge selbst aus den vorhandenen Bodenbildern, es braucht keine neuen Bilder.
  - **So testest du es:** Editor → Baukasten-Testfeld: an den Straßenrändern, am Marktplatz und am Bach entlanglaufen.

- **Neues Startmenü mit Editor** (27.10., Marcos Wunsch):
  - Das Startmenü hat jetzt drei Kacheln: **Kreuzweg-Demo**, **Zusammen spielen** und **Editor**.
  - Im **Editor** liegen die Werkzeuge zum schnellen Testen: **Baukasten-Testfeld** (die neue Karte, vorerst nur hier),
    **Vega-Animationen** (kleiner Testkampf: Knöpfe für Stehen, Laufen, Getroffen, Parade, Angriff, Fallen, Sieg,
    dazu Zeitlupe) und die **Kampf-Sandbox**.
  - **Demo testen ab einem Akt:** „Akt Kreuzweg“ (von vorne als Novize) und „Akt Grünwacht“ (als Bogenschütze oder
    Monster-Zähmer, Stufe 10, auf dem Weg nach Grünwacht). Diese Tests haben einen **eigenen Spielstand**
    (`spielstand_editor.json`), dein normaler Spielstand bleibt unberührt. Zurück im Menü gilt wieder der normale.
  - **So testest du es:** Startmenü → Editor → „Akt Grünwacht – Als Monster-Zähmer“: Du stehst auf dem Weg nach
    Grünwacht. Danach im Menü „Kreuzweg-Demo“: Dein alter Spielstand ist noch da.

- **Vega überall fein gezeichnet** (27.10., Marcos neue Kampfbilder):
  - Marcos zwei Kampf-Blätter sind zerlegt (`tools/vega_kampfbilder.py`): Stehen, Laufen, Getroffen, Parade mit
    blauem Sternenbogen, Angriff mit Sternen-Geschoss im 4. Bild, Fallen (sie stürzt nach vorne und bleibt liegen) und Sieg.
    Gleiche Bildzahl wie vorher, damit Geschoss, Parade und Treffer zeitlich weiter passen.
  - Alle Vega-Bilder liegen jetzt in dreifacher Auflösung vor und werden weich verkleinert, im Kampf, in der Zugleiste,
    in der Kreuzweg-Demo, beim Zusammenspielen und im Testfeld. Größe wie vorher, nur sauberer.
  - Der leuchtende Umriss (Ziel wählen, Fähigkeit) ist bei den feinen Bildern gleich dick wie vorher.
  - **So testest du es:** In der Kreuzweg-Demo einen Kampf spielen: Vega steht sauber gezeichnet da, holt mit dem Stab
    aus und schießt den Stern, bei einer Parade erscheint der blaue Bogen, nach dem Sieg jubelt sie.

- **Projekt 9, Schritt 4: Vega läuft in vier Richtungen** (27.10., nur im Baukasten-Testfeld):
  - Marcos Blatt mit 24 Bildern ist zerlegt (`tools/vega_laufbilder.py`): Stehen und Laufen schräg nach vorne
    und schräg nach hinten, jeweils 6 Bilder, an den Füßen ausgerichtet und so groß wie die bisherigen Vega-Bilder.
  - **Feiner dargestellt (Marcos Wunsch):** Die Laufbilder liegen in dreifacher Auflösung vor und werden weich
    verkleinert wie Häuser und Bäume, statt grob vergrößert. Dadurch sieht Vega aus wie auf Marcos Bildern.
  - Läuft Vega auf dem Bildschirm nach unten, sieht man ihr Gesicht, nach oben ihren Rücken. Nach links werden die
    Bilder gespiegelt. Bleibt sie stehen, schaut sie weiter in die letzte Richtung.
  - Die Brücke liegt jetzt genau auf den Feldern, über die man läuft.
  - In der Kreuzweg-Demo und beim Zusammenspielen läuft Vega noch wie bisher seitlich (kommt, wenn Kreuzweg auf den Baukasten umzieht).
  - **So testest du es:** Im Baukasten-Testfeld mit den Pfeiltasten in alle vier Richtungen laufen und stehen bleiben.

- **Baukasten-Testfeld weiter** (27.10., Marcos Rückmeldung „zu gequetscht“):
  - Die Karte ist jetzt **64 × 64 Felder** statt 46 × 46. Der Marktplatz ist größer (24 × 24), um Splitterkreis und
    Krater bleibt ein **freier Ring** von drei bis vier Feldern, nur vier Feuerschalen stehen an den Ecken.
  - Gebäude, Stände und Pavillons stehen mit Abstand zueinander, Bäume und Büsche halten zwei Felder Abstand zu Straßen,
    Häusern und zueinander.
  - **So testest du es:** Im Baukasten-Testfeld über den Marktplatz laufen und mit K die Geschichte umschalten:
    Rund um den Krater ist Platz für eine Gruppe.

- **Baukasten: Splitterkreis und Krater** (27.10.):
  - Marcos achtes Blatt ist eingesetzt: Splitterkreis (ersetzt den Platzhalter), frischer Krater, umzäunter Krater
    und der gefallene Sternsplitter. Der rote Schimmer am Rand der KI-Bilder ist entfernt.
  - Neu: **Stand der Geschichte** im Testfeld. Taste **K** (oder Knopf „Geschichte“) schaltet um:
    „vor dem Fest“ (Splitterkreis) → „Nacht des Sternenfalls“ (frischer Krater mit leuchtenden Splittern, immer Nacht)
    → „Wochen danach“ (umzäunter Krater, man kann nicht hinein). So zeigt die Welt später den Fortschritt der Geschichte.
  - **So testest du es:** Im Baukasten-Testfeld zum Marktplatz laufen und K drücken: Der Kreis wird zum Krater,
    dann zum umzäunten Krater, dann wieder zum Kreis.

- **Projekt 9, Schritt 2: Echte Bilder im Baukasten** (27.10.):
  - Marcos sieben Bildblätter (Boden, Gebäude, Markt, Besonderes, Pavillons, Kleinkram, Pflanzen) sind zerlegt:
    **44 Teile**, freigestellt (auch das mitgemalte Karomuster), auf Spielgröße verkleinert, jedes mit Grundfläche und Fußpunkt.
    Werkzeug: `tools/baukasten_zuschneiden.py`, die Original-Blätter liegen in `tools/vorlagen/`.
  - **Das Testfeld ist neu aufgebaut, angelehnt an Kreuzweg aus design.md:** Marktplatz mit Brunnen, Statue der Fünf,
    Splitterkreis, Marktständen und Bingos Stand, Abenteurergilde mit Auftragsbrett, Gasthaus Wegrast, Wohnhäuser,
    Gesandten-Hof mit den fünf Pavillons, Torbogen mit Mauer im Norden, das zugewucherte **sechste Tor** am Ende des
    Weges nach links, Bach mit Brücke im Süden, Bäume, Büsche, Blumen.
  - Laternen, Feuerschalen und die Laternen an Gilde, Wegrast, Bingos Stand und einem Wohnhaus leuchten nachts.
  - Neu: **+ / −** (oder Knöpfe „Figur +“/„Figur −“) ändert die Größe von Vega (50–100 %, Start 70 %), damit du den Maßstab ausprobieren kannst.
  - **So testest du es:** Startmenü → „Baukasten-Testfeld“. Über den Platz zur Gilde, zum sechsten Tor (links) und durch
    den Torbogen (oben) laufen, über die Brücke (unten) gehen, N für Tag/Nacht, + / − für die Figurgröße. Sag mir, welche
    Größe passt und ob dir etwas zu groß oder zu klein vorkommt.

- **Projekt 9, Schritt 1: Baukasten-Testfeld** (27.10.):
  - Neu im Startmenü: **„Baukasten-Testfeld“**. Ein kleiner Marktplatz in Rautenansicht, diesmal nicht im Code gezeichnet,
    sondern aus **Einzelbildern** zusammengesetzt: 8 Bodenbilder und 21 Gegenstände (Häuser, Marktstände, Statue der Fünf,
    Torbogen, Brücke, Laternen, Fackelschalen, Banner, Bäume, Tannen, Büsche, Blumen, Bank, Fass, Kiste, Zaun, Mauer,
    Wegweiser, Splitterkreis). Die Bilder sind Platzhalter von Claude und werden später durch echte Bilder mit gleichem
    Namen ersetzt.
  - Welche Teile es gibt und wo sie stehen, steht in `data/baukasten_teile.json` und `data/baukasten_testfeld.json`.
    Die Regeln für neue Bilder (Größe, Fußpunkt, Tageslicht) stehen in `data/BAUKASTEN.md`.
  - Laufen mit Tasten oder Klicken/Antippen (der Weg führt um Hindernisse und über die Brücke). Steht man hinter
    einem Haus oder Baum, wird es halb durchsichtig. Nachts leuchten Laternen, Fackeln und der Splitterkreis.
  - Prüf-Werkzeug `tests/baukasten_auto.tscn` macht Bildschirmfotos (Nacht, Tag, Raster, hinter dem Haus, Torbogen, Brücke).
  - **So testest du es:** Startmenü → „Baukasten-Testfeld“. Herumlaufen und hinter das große Haus links gehen,
    über die Brücke unten laufen, **N** für Tag/Nacht, **G** für das Raster (rot = gesperrt, gelb = Grundfläche).
    Achte darauf, ob dir die Größen passen (Vega ist im Vergleich zu den Häusern noch recht groß).
- **Projekt 4, Schritt 1b – Wegwerfen und Beute-Fenster** (27.10., fertig, Marcos Wunsch):
  - **Wegwerfen:** In der Tasche einen Gegenstand anklicken, dann „[Wegwerfen]“. Es kommt die Frage „Wirklich 3 ×
    Heiltrank wegwerfen? Das ist dann weg.“ mit „Ja, wegwerfen“ und „Nein“. Weggeworfen wird das ganze Kästchen.
  - **Nicht wegwerfen** lassen sich Gegenstände der Geschichte (alles ohne Preis, z. B. Bürste, Schleuder,
    Sternensplitter) und was ein laufender Auftrag noch braucht (z. B. Silberkraut für „Die Stadt kennenlernen“).
    Dort gibt es den Knopf gar nicht. So kann kein Auftrag hängen bleiben.
  - **Beute-Fenster:** Passt Beute nach einem Sieg nicht mehr in die Tasche, geht sie nicht verloren. Rechts neben
    der Tasche erscheint das Fenster „Beute“ mit dem Fund und „Nehmen“ (grau, solange kein Platz ist), dazu
    „Tasche öffnen“ und „Liegen lassen“. Die Beute wartet, bis man sie nimmt oder liegen lässt, auch über Speichern
    und Laden hinweg.
  - Was in die Tasche passt, kommt wie bisher direkt hinein. Gegenstände aus Aufträgen kommen immer hinein.
  - **Noch offen:** Monster lassen bisher keine Gegenstände fallen (nur Geld und Monsterkarten). Das Beute-Fenster
    ist dafür vorbereitet. Was Monster fallen lassen, kommt mit der Ausrüstung später. Zum Ausprobieren gibt es den
    Testknopf „[Test: Beute]“, der eine Testrüstung als Beute gibt.
  - Beschluss steht in design.md (Geld, Tasche und Bank).
  - **So testest du es:** Spiel in Godot starten, mit I die Tasche öffnen, „Test: Tasche füllen“ und dann „Test:
    Beute“ anklicken. Rechts erscheint das Beute-Fenster mit der Testrüstung, „Nehmen“ ist grau. Einen Testkiesel
    anklicken, „Wegwerfen“ und „Ja, wegwerfen“ wählen. Jetzt „Nehmen“: die Rüstung liegt in der Tasche.

- **Projekt 4, Schritt 1 – Tasche mit 30 Plätzen** (27.10., fertig):
  - Die Tasche hat **30 Plätze**. Jede Sorte Gegenstand braucht einen Platz, mehr vom Gleichen liegt im selben
    Kästchen (5 Kräuter = 1 Platz). Unter dem Geld steht „Plätze: 12 / 30“, bei voller Tasche in Rot.
  - **Bei voller Tasche:** Sammeln (z. B. Kräuter) und Kaufen gehen nicht. Es erscheint „Tasche voll! Für … ist kein
    Platz. Verkauf etwas bei Bingo, um Platz zu machen.“ Der Sammelpunkt bleibt da, man kann später wiederkommen,
    beim Kauf wird kein Geld abgezogen.
  - **Geschenke aus Aufträgen und Gesprächen kommen trotzdem hinein** (in ein Extra-Kästchen, dazu der Hinweis
    „Deine Tasche ist übervoll!“), damit die Geschichte nie hängen bleibt. Wird ein Platz frei, rückt der Gegenstand nach.
  - **Testknopf** in der Tasche: „[Test: Tasche füllen]“ füllt alle freien Plätze mit grauen Testkieseln (nur beim
    Ausprobieren im Godot-Editor). Bingo kauft jeden Kiesel für 1 Bronze, so wird die Tasche wieder leer.
  - Wegwerfen gibt es noch nicht (Platz macht man vorerst durch Verkaufen). Mehr Plätze kommen später durch Taschen
    vom Schneider (Abschnitt „Später“).
  - **So testest du es:** Spiel in Godot starten, mit I die Tasche öffnen, „Test: Tasche füllen“ anklicken: alle
    30 Plätze sind belegt. Ein Kraut in Kreuzweg aufheben: „Tasche voll!“ erscheint. Bei Bingo einen Heiltrank kaufen
    wollen: geht nicht, das Geld bleibt. Einen Testkiesel verkaufen, dann klappt es wieder.

- **Projekt 3, Schritt 2 – Monster lassen wenig Geld fallen** (27.10., fertig):
  - **Richtwert:** Ein Monster bringt ein paar Bronze, ein Auftrag ein paar Silber, und ein Heiltrank kostet etwa so
    viel wie 6 bis 8 Monster.
  - **Monster in der Wildnis:** jedes Monster 1 Bronze, dazu 1 Bronze je 5 Stufen. Auf dem Weg nach Grünwacht
    (Stufe 10–14) sind das 3 Bronze, im Wald (15–19) 4 Bronze, auf Stufe 20 5 Bronze. Zwei Monster geben das Doppelte.
    Vorher waren es 2 × Stufe (z. B. 30 statt jetzt 4). Einstellbar in `scripts/welt/game_data.gd` (`WILD_BRONZE`,
    `WILD_LEVELS_PER_BRONZE`).
  - **Aufträge zehnmal so viel wie vorher:** z. B. „Die Stadt kennenlernen“ 2 Silber 50 Bronze, „Der Weg nach
    Grünwacht“ 5 Silber, „Der Splitter im Urbaum“ 15 Silber.
  - **Preise:** Heiltrank 25 Bronze (Bingo kauft ihn für 12 Bronze zurück). Sternentafel 5 Gold in Akt 1
    (absichtlich unbezahlbar), für Heimkehrer 60 Silber. Bingos Sätze sind angepasst. Kräuter und Honigwaben
    verkaufen sich weiter für ein paar Bronze.
  - **Kreuzweg-Karten:** Sieg gegen Marv 10 Bronze, gegen Oma Hagebutte 20 Bronze (gibt es bei jedem Sieg, darum klein).
  - **Was man insgesamt hat** (nachgerechnet mit dem Durchlauf-Test, nur Hauptaufträge): am Ende von Kreuzweg etwa
    19 Silber, am Ende von Grünwacht etwa 60 bis 70 Silber. Mit den Nebenaufträgen reicht es also für die Sternentafel.
  - **So testest du es:** Auf dem Weg nach Grünwacht ein Monster besiegen: Auf dem Sieg-Bildschirm steht z. B.
    „+3 Bronze“, oben links steigt das Geld um genau so viel. Einen Auftrag abgeben: es gibt ein paar Silber.
    Bei Bingo kostet der Heiltrank 25 Bronze.

- **Projekt 3, Schritt 1 – Geld als Bronze, Silber und Gold** (27.10., fertig):
  - Geld ist weiter **eine einzige Zahl** (in Bronze) und wird überall als Münzen angezeigt: 100 Bronze = 1 Silber,
    100 Silber = 1 Gold, z. B. „1 Gold 23 Silber 45 Bronze“. Leere Münzen werden weggelassen („1 Silber“ statt „0 Gold 1 Silber 0 Bronze“).
  - Zu sehen oben links neben Stufe und Erfahrung, in der Tasche (farbig: Gold gelb, Silber grau, Bronze kupfer), im
    Laden (Preise und eigenes Geld), in den kurzen Meldungen („+25 Bronze“) und auf dem Sieg-Bildschirm.
  - **Die Münznamen stehen nur an einer Stelle:** `data/texte.json` unter `"muenzen"`. Wer sie umbenennen will, ändert nur dort.
  - **Alle bisherigen Beträge zählen jetzt als Bronze** (z. B. Auftrags-Belohnung 25 → 25 Bronze, Heiltrank 15 Bronze,
    Sternentafel 50 Silber bzw. 6 Silber für Heimkehrer; Bingos Sätze sind angepasst). Geld ist damit knapp. Die
    Beträge stimmen wir in Schritt 2 ab. Alte Spielstände funktionieren weiter.
  - **Testknöpfe** in der Tasche: „[Test: +75 Bronze]“ und „[Test: +99 Silber]“. Sie erscheinen nur beim Ausprobieren
    im Godot-Editor, nicht im fertigen Spiel. Die Münzrechnung prüft `tests/geld_test.gd`.
  - **So testest du es:** Spiel in Godot starten, mit I die Tasche öffnen. Zweimal „+75 Bronze“ anklicken: aus
    75 Bronze wird 1 Silber 50 Bronze. Dann „+99 Silber“: es springt auf Gold. Oben links steht derselbe Betrag.
    Bei Bingo einen Heiltrank kaufen: der Preis steht als „15 Bronze“ da und das Geld sinkt richtig.

- **Vegas Animationen, zweite Runde** (27.10., Marcos Test im Browser):
  - **Kein Schuss mehr beim Blocken:** Nach einer perfekten Parade gab es einen kleinen „Hüpfer“, der bei Vega die
    Schuss-Animation abspielte. Jetzt bleibt die Parier-Pose stehen. Bei Zaubern (z. B. Erste Hilfe) hebt sie nur den
    Stab (die ersten drei Angriffs-Bilder, ohne Geschoss).
  - **Langsamer:** Angriff etwa 1,1 Sekunden (Ausholen in drei Bildern, Geschoss, Ausschwingen), Parade etwa
    0,7 Sekunden, Jubeln und Fallen gemächlicher.
  - **Siegespose länger und sichtbar:** 2,4 Sekunden Jubeln, dann blendet die Auswertung sanft und halb durchsichtig
    ein. Die Tabelle steht weiter unten, die Gruppe jubelt oben sichtbar weiter.
  - Neues Prüf-Werkzeug `tests/vega_ablauf_auto.tscn`: spielt einen echten Kampf mit Vega und schreibt mit, welche
    Animation sie wann zeigt.
  - **Hinweis zum Browser:** GitHub hält die Seite bis zu 10 Minuten im Zwischenspeicher. Wenn etwas „wie vorher“
    aussieht: Seite mit Strg+F5 (am Handy: Tab schließen und neu öffnen) laden.

- **Kampfende und Vegas Animationen nachgebessert** (27.10., Marcos Rückmeldung):
  - **Siegespose nach jedem gewonnenen Kampf:** Die Helden freuen sich 1,4 Sekunden (zwei Runden Jubeln), erst dann
    kommt die Auswertung. Die Dauer steht in `combat.gd` unter `VICTORY_POSE`.
  - **Belohnung auf dem Sieg-Bildschirm:** Unter „SIEG!“ steht jetzt z. B. „Belohnung: +120 Erfahrung · +20 Gold ·
    Karte: Moosling · Stufe 11 erreicht!“. Nach dem Kampf meldet die Welt das nicht noch einmal. Beim Zusammenspielen
    stehen Erfahrung und Gold auch dort; eine Monsterkarte würfelt dort weiter der Server und meldet sie nach dem Kampf.
  - **Parade sichtbar:** Vega hebt den Schild-Bogen genau beim Tastendruck, und der Treffer danach verdeckt die Pose
    nicht mehr (vorher sah man nur das kurze Zurückzucken).
  - **Fernangriff statt Rammen:** Vega bleibt an ihrem Platz, macht einen kleinen Schritt, holt in drei Bildern aus,
    lässt das Sternen-Geschoss los, das zum Gegner fliegt, und schwingt danach aus. Alle 6 Bilder sind zu sehen.
  - **So testest du es:** Einen Kampf gewinnen: Vega jubelt kurz, dann steht die Belohnung oben. Eine Parade schaffen:
    der blaue Bogen ist zu sehen. „Schlag“ benutzen: Sie greift aus der Ferne mit dem Geschoss an.

- **Vega: Kampf-Animationen** (26.10.):
  - Aus Marcos zweitem Bildblatt: **Angriff** (6 Bilder, mit blauem Sternen-Geschoss), **Fallen** (6 Bilder),
    **Parieren** (4 Bilder, mit blauem Schild-Bogen) und **Sieg** (4 Bilder, Jubeln). Getroffen gab es schon.
  - Wann was läuft: Angriff bei jedem Schlag und beim Wirken einer Fähigkeit (das Geschoss erscheint genau beim
    Aufprall), Parieren bei jeder gelungenen Parade (normal oder perfekt), Fallen, wenn ihr Leben auf 0 sinkt
    (sie bleibt liegen), Sieg nach einem gewonnenen Kampf, bis der Sieg-Bildschirm kommt.
  - Figuren ohne diese Bilder (alle anderen) verhalten sich wie bisher.
  - **So testest du es:** In der Kreuzweg-Demo einen Kampf beginnen: Schlagen, eine Parade schaffen, den Kampf
    gewinnen (Vega jubelt). Zum Fallen: einen Kampf verlieren.

- **Erste eigene Figur: Vega** (26.10.):
  - Marcos Bildblatt (4 × Stehen, 4 × Laufen, 1 × Getroffen) ist in Einzelbilder zerlegt, auf 47 × 44 Pixel
    verkleinert (gemeinsame Fußlinie, damit nichts hüpft), mit gemeinsamer Farbpalette und ohne rote Ränder.
    Die Bilder liegen in `assets/figuren/` (`vega_idle_anim_f0.png` usw.).
  - Vega ist jetzt **deine Spielfigur**: beim Alleinspielen in der Welt und im Kampf, solange du Novize bist
    (danach zeigt der Kampf wie bisher die Figur der Klasse). Beim Zusammenspielen ist sie die erste wählbare Figur.
  - In der Welt wird sie 2-fach, im Kampf 3-fach vergrößert (die alten Figuren 3- und 4-fach, weil sie kleiner gezeichnet sind).
  - Neue Figuren gehen genauso: Bilder mit demselben Namensmuster in `assets/figuren/` legen, das Spiel findet sie selbst.
  - **Beschluss (27.10.):** Vega wird später das Aussehen der **Sternensängerin** (vielleicht danach eine Figur der
    Geschichte). Vorerst bleibt sie die Spielfigur als Novize, damit du ihre Animationen testen kannst.
  - **So testest du es:** Spiel starten: Du läufst als Vega durch Kreuzweg. Einen Kampf bei Ye beginnen: Vega steht
    rechts und schaut zum Gegner, beim Treffer kneift sie die Augen zu.

- **Projekt 0, Schritt 4 – Grünwacht größer** (26.10., fertig):
  - **Weg nach Grünwacht, Waldboden und Wipfelheim sind um die Hälfte größer** (Faktor 1,5 in beide Richtungen):
    Weg 60 × 20 statt 40 × 13 Felder, Waldboden 45 × 39 statt 30 × 26, Wipfelheim 48 × 42 statt 32 × 28.
  - Plattformen, Brücken und Wege sind breiter. Bäume, Büsche, Pilze, Steine und Zielscheiben bleiben einzeln und
    **rücken auseinander**, statt größer zu werden. Häuser behalten ihre Größe, stehen aber weiter auseinander.
  - Figuren, Monster, Orte (Seilaufzug, Grab, Hirsch, Bienenstock, Höhleneingang), Ausgänge und Wegweiser sind
    mitgewandert. Wie nah man einer Figur kommen muss, bis sie auf einen zuläuft (Kael, Kobalt, Marv), ist mitgewachsen.
  - Die Pilzhöhle ist gleich geblieben (ist ein Dungeon und war nicht zu eng).
  - Wer schon in Grünwacht gespeichert hat, steht nach dem Laden an derselben Stelle der größeren Karte.
  - Ist es zu groß oder noch zu klein: Bescheid sagen, dann passe ich die Karten nach.
  - **So testest du es:** Von Kreuzweg über den Weg nach Grünwacht, durch den Wald und mit dem Seilaufzug nach
    Wipfelheim laufen: Es fühlt sich weiter an, nichts klemmt, keine Figur steht zu dicht an einer anderen.

- **Projekt 0, Schritt 3 – Kael kommt auf einer anderen Plattform dazu** (26.10., fertig):
  - Kael steht nicht mehr neben Ysolde. Nach den leuchtenden Tieren sagt Ysolde: Auf der **Westplattform beim
    Seilaufzug** treibt sich ein Fremder herum. Neuer kleiner Auftrag **„Ein Fremder in Wipfelheim“**, der Wegweiser
    zeigt hinüber.
  - Kommt man auf der Westplattform in seine Nähe, **läuft Kael auf einen zu** und spricht einen an. Danach geht es
    weiter wie bisher (das leere Grab). Kael bleibt danach auf der Westplattform stehen.
  - Ältere Spielstände (Tiere schon erledigt, Kael noch nicht getroffen) bekommen den Auftrag bei Ysolde („!“).
  - **So testest du es:** Grünwacht bis nach den leuchtenden Tieren spielen und bei Ysolde abgeben. Dem Wegweiser
    über die Brücke zur Westplattform folgen: Kael läuft auf dich zu.

- **Projekt 0, Schritt 2 – Klasse erst beim Lehrmeister lernen** (26.10., fertig):
  - Bei Ye wählt man nur noch seinen Weg. Bogenschützen und Zähmer bekommen beim Abschied den Auftrag
    **„Beim Lehrmeister lernen“** und kämpfen **bis dahin als Novize** (auch gegen die Monster auf dem Weg).
  - Nach dem Gespräch mit Ysolde zeigt der Wegweiser zum Lehrmeister:
    **Bogenschütze → Pfadmeister Fenn.** Wer die Prüfung der drei Ziele besteht, ist Bogenschütze.
    (Die Scheiben-Lektionen selbst schießt man schon mit dem Bogen, das ist ja der Unterricht.)
    **Zähmer → Professor Esche.** Mit dem ersten Monster ist man Zähmer (sonst ginge Tildas Zähm-Unterricht nicht).
  - Unter **Werte (C)** steht bis dahin: „Du hast den Weg … gewählt, kämpfst aber noch als Novize.“
  - Die **anderen Klassen** kämpfen wie bisher gleich nach der Wahl mit ihrer Klasse, weil ihre Region und ihr
    Lehrmeister noch fehlen (Beschluss vom 21.10.). Kommt ihre Region dazu, reicht in `data/klassen.json` ein Eintrag
    `lernen_bei`.
  - Alte Spielstände: Wer schon in Grünwacht ist und die Klasse noch nicht beim Lehrmeister gelernt hat, kämpft
    jetzt ebenfalls als Novize, bis Fenn bzw. Esche erledigt sind.
  - **So testest du es:** „Neu beginnen“, bis zur Klassenwahl spielen und Bogenschütze (oder Zähmer) wählen. Auf dem
    Weg nach Grünwacht kämpft man als Novize (Schlag, Kraftschlag, Erste Hilfe). In Wipfelheim erst zu Ysolde, dann
    führt der Wegweiser zu Fenn (bzw. Esche). Nach der Prüfung (bzw. dem ersten Monster) kämpft man mit der Klasse.

- **Projekt 0, Schritt 1 – Tasche wie in klassischen Spielen** (26.10., fertig):
  - Die Tasche (I) zeigt jetzt **30 Kästchen** (3 Reihen à 10). In jedem liegt ein Gegenstand mit **kleinem Bild**
    und **Anzahl** unten rechts (z. B. „3“ bei drei Heiltränken).
  - Gegenstände lassen sich per **Ziehen und Ablegen** verschieben, mit der Maus oder am Handy mit dem Finger.
    Auf ein belegtes Kästchen gezogen, tauschen die beiden die Plätze. Die Reihenfolge wird im Spielstand gemerkt
    (auch zusammen online). Neue Gegenstände kommen ins erste freie Kästchen.
  - **Klick auf ein Kästchen** zeigt unten Name, Anzahl und Beschreibung, bei der Bürste auch „Benutzen“.
  - Die Bilder sind gezeichnete Platzhalter (Trank, Kraut, Splitter, Wabe, Schleuder, Korb, Bürste, Laterne, Fleisch,
    Sternentafel), festgelegt in `data/gegenstaende.json` unter `bild`. Mehr als 30 Gegenstände passen trotzdem hinein
    (dann kommen Kästchen dazu); die feste Grenze mit Hinweis „Tasche voll“ kommt mit Projekt 4.
  - **So testest du es:** Mit I die Tasche öffnen, einen Gegenstand in ein anderes Kästchen ziehen, Tasche schließen
    und wieder öffnen: Er liegt noch dort. Auch nach Speichern und neu Laden. Einen Gegenstand anklicken: Unten
    steht, was er ist.

- **Projekt 1, Schritt 1 – Licht wie bei Octopath Traveler** (22.10., fertig):
  - Lichtquellen werfen jetzt einen **weichen, flackernden Lichtschein** auf Boden, Häuser und Figuren:
    Laternen, Fackeln, Lagerfeuer, die Glut in der Schmiede, Leuchtpilze, Sternensplitter (Herz des Urbaums,
    Rowans Grab, Splitter-Bär, Krater nach dem Sternenfall), der Silberhirsch und die leuchtenden Kräuter.
    Nachts beim Fest leuchten die fünf Festlaternen in ihren Farben auf den Marktplatz.
  - **Kreuzweg** ist tagsüber leicht abgedunkelt, damit das Licht wirkt. Neu: fünf **Straßenlaternen** an den Ecken
    des Marktplatzes, vor Bingos Laden und am Gasthaus, eine **Fackel** bei der Torwache, und aus der Tür der
    **Schmiede** leuchtet die Glut der Esse.
  - **Pilzhöhle** ist dunkler als vorher; sechs **Wandfackeln** (am Eingang, zwischen den Hallen und bei der
    Wurzelmutter) und die Leuchtpilze geben Licht.
  - Alle Lichtarten (Farbe, Größe, Stärke, Flackern) stehen an einer Stelle: `scripts/welt/licht.gd`.
    Laternen und Fackeln in Kreuzweg stehen in `data/kreuzweg.json` unter `lichter`, Wandfackeln in den Karten
    als Zeichen `F` (`data/karten.json`).
  - Noch ohne Licht: der Kampfbildschirm (auch der Kampf in der Pilzhöhle).
  - **So testest du es:** Durch Kreuzweg laufen: Die Laternen am Marktplatz und die Fackel bei der Wache werfen
    einen warmen Schein, aus der Schmiede glüht es. Am Fest-Abend leuchten die Festlaternen bunt. Dann in die
    Pilzhöhle: Fackeln und Pilze werfen Licht in die dunkle Höhle, das Herz des Urbaums glüht lila.

- **Projekt 1, Schritt 2 – Pixel-Paket** (zurückgestellt): Flare gefällt dir nicht, gewünscht ist Pixel-Grafik wie bei
  Octopath. Du schaust dich um (selbst zeichnen, KI als Vorlage oder Pixel-Künstler); das Thema hängt an der Look-Bibel
  (Abendthema 12 im Brainstorm-Doc).

- **Projekt 1, Schritt 3 – Licht im Kampf** (22.10., fertig):
  - Die Figuren bekommen das **Licht des Ortes** ab: in Höhle und Gewölbe dunkler und leicht lila, nachts bläulich,
    im Wald grünlich, auf der Wiese am Tag hell (`Backdrop.FIGHTER_LIGHT`).
  - **Feuer-, Blitz-, Licht- und Splitter-Treffer leuchten auf**: Ein großer, weicher Schein in der Farbe des Elements
    taucht das Feld kurz in sein Licht (wie die Zauber bei Octopath).
  - Die **Pilzhöhle hat im Kampf einen eigenen Hintergrund**: Felswand, Wurzeln des Urbaums von der Decke, leuchtende
    Riesenpilze, drei Wandfackeln und lila Sporen in der Luft (vorher das Gewölbe mit Lava-Brunnen). Gilt für
    Sporenkönigin, Wurzelmutter/Vorbote, die Monster der Höhle und die Pilzhöhle in der Kampf-Sandbox.
  - Schon vorher da: Fackeln im Gewölbe, eigener Hintergrund für die Fest-Nacht auf dem Marktplatz.
  - **So testest du es:** Einen Kampf vor dem Stadttor, einen in der Pilzhöhle und den Sternenfresser in der Fest-Nacht
    spielen: Jeder Kampf sieht aus wie sein Ort. Ein Feuerangriff (z. B. vom Glutwelpen) taucht das Feld kurz in
    oranges Licht.

- **Projekt 1, Schritt 4 – Licht als Mechanik in der Pilzhöhle** (22.10., fertig):
  - Beim **Vorboten** ist die Dunkelheit keine gleichmäßige graue Schicht mehr: Das Feld wird dunkel, nur um
    Lichtquellen bleiben **runde Lichtkreise** hell. Je dunkler es wird („Lichtfraß“), desto **kleiner werden die Kreise**.
  - **„Laterne entzünden“** stellt eine echte Laterne zwischen Gegner und Helden aufs Feld (bis zu vier, danach brennt
    die älteste neu), mit eigenem Lichtkreis. Ist der Vorbote besiegt, verlöschen die Laternen langsam.
  - **„Das letzte Licht“:** Wer das Splitterlicht hält, **leuchtet lila** und steht in einem eigenen Lichtkreis. Beim
    Weiterreichen wandert das Licht sichtbar zur nächsten Figur. So sieht man immer, wer sicher ist.
  - Die Regeln sind gleich geblieben, nur die Anzeige ist neu.
  - **So testest du es:** In der Pilzhöhle bis zum Vorboten kommen (oder in der Kampf-Sandbox „Pilzhöhle: nur Bosse“).
    Eine Laterne entzünden und das Splitterlicht weiterreichen: Man sieht, wo Licht ist und wer sicher ist. Wartet man,
    werden die Lichtkreise kleiner.

- **Projekt 2, Schritt 1 – Parieren mit Klang und Funken** (22.10., fertig):
  - **Neuer Parade-Klang:** knackiger Anschlag und Metall-Obertöne. Die **perfekte Parade** klingt heller, mit einem
    klaren hohen Glockenton und dem Dreiklang nach oben.
  - **Normale Parade:** kurzer Funkenblitz, wo die Klingen aufeinandertreffen.
  - **Perfekte Parade:** heller Funkenregen, ein kurzer weißer Blitz über das Bild und ein **Moment Zeitlupe**
    (knapp eine halbe Sekunde läuft alles langsamer).
  - Die Klänge sind **selbst erzeugt** (`tools/sounds_erzeugen.gd`): Die Seiten mit freien Klang-Paketen (Kenney,
    OpenGameArt) sind aus der Cloud-Umgebung gesperrt. Am PC kann man später z. B. „Impact Sounds“ von Kenney (CC0)
    nehmen und die Dateien in `assets/sfx/` ersetzen.
  - **So testest du es:** Im Kampf einmal normal und einmal perfekt parieren: Normal klirrt es mit Funken, perfekt
    blitzt es hell, klingt höher und läuft kurz in Zeitlupe.

- **Projekt 2, Schritt 2 – Harte Treffer** (22.10., fertig):
  - Ein **harter Treffer** (kritisch oder mindestens ein Viertel des Lebens auf einmal) lässt das Bild für einen
    Augenblick **anhalten**, danach **wackeln** Feld und Hintergrund kurz (bei kritischen Treffern stärker).
    Die Leisten oben und unten wackeln nicht mit, damit man alles lesen kann.
  - **So testest du es:** Einen starken Angriff ausführen (z. B. eine Ult) und einen Boss-Schlag einstecken: Das Bild
    stockt kurz und wackelt.

- **Projekt 2, Schritt 3 – Schadenszahlen** (22.10., fertig):
  - **Kritische Treffer** erscheinen groß, golden-orange mit dickem Rand und ploppen auf.
  - Alle Schadenszahlen ploppen kurz auf (erst größer, dann normal).
  - **Mehrere Treffer** an derselben Figur kurz hintereinander erscheinen **einzeln nacheinander**, leicht versetzt
    (erst Mitte, dann rechts, links …), statt übereinander. Welche Fähigkeiten mehrfach treffen, kommt aus Abendthema 13.
  - **So testest du es:** Mit dem Bogenschützen „Schnellfeuer“ oder der Klingentänzerin „Tanz der 1000 Klingen“
    angreifen und auf einen kritischen Treffer achten.

## Aufgaben Lernprojekt 5 „Grünwacht“ (Fahrplan in `GRUENWACHT_PLAN.md`)

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 0 | Plan schreiben | erledigt |
| – | Entscheidungen: alle Klassen, gleicher Spielstand, Stufen nach Reihenfolge, Sternentafel bei Bingo, Koch-Stand als Platzhalter, Ruf sichtbar | entschieden 21.10. |
| 1 | Die Reise und Wipfelheim (mehrere Karten, Weg von Kreuzweg, Koch-Stand) | eingebaut, Marco testet am Schluss |
| 2 | Die eigene Klasse in der Welt, Monster der Region | eingebaut, Marco testet am Schluss |
| 3 | Einstieg Bogenschütze: Fenns Prüfung der drei Ziele | eingebaut, Marco testet am Schluss |
| 4 | Einstieg Zähmer: Professor Esche und Kobalt | eingebaut, Marco testet am Schluss |
| 5 | Geschichte 1 und 2: veränderte Tiere (Jäger oder Zähmer, Ruf), Kael | eingebaut, Marco testet am Schluss |
| 6 | Geschichte 3: Rowans leeres Grab (Erinnerungs-Szene) | eingebaut, Marco testet am Schluss |
| 7 | Dungeon Pilzhöhle unter dem Urbaum | eingebaut, Marco testet am Schluss |
| 8 | Ende der Region: Ysolde und Kael, Abstimmung | eingebaut, Marco testet am Schluss |
| 9 | Kreuzweg-Karten mit Sternentafel, Marv, Oma Hagebutte | eingebaut, Marco testet am Schluss |
| 10 | Nebenaufträge (Kobalt, Oma Hagebutte, Bienenstock) | eingebaut, Marco testet am Schluss |
| 11 | Feinschliff (Musik, Durchlauf, Stufen) | eingebaut, Marco testet am Schluss |

## Fertig in Lernprojekt 5

- **Schritt 1 – Die Reise und Wipfelheim** (21.10.):
  - **Neuer Baustein „mehrere Karten“:** Die Welt besteht jetzt aus mehreren Karten, jeder Spieler steht auf einer.
    Kreuzweg bleibt wie bisher. Die neuen Karten stehen in **`data/karten.json`** als Bild aus Zeichen
    (`~` Baumkronen, `#` Plattform, `-` Hängebrücke, `,` Waldboden, `=` Weg, `t` Baum, `R` Riesenbaum …).
    Du kannst sie dort selbst ändern, Anleitung in `data/LIESMICH.md`.
  - **Drei neue Karten:**
    - **Der Weg nach Grünwacht:** Straße von Kreuzweg nach Westen, erst Wiese mit Blumen, dann immer mehr Wald,
      in der Mitte ein Rastplatz mit Lagerfeuer, Wegweiser an beiden Enden.
    - **Waldboden unter Wipfelheim:** dunkler Wald mit Riesenbäumen und Pilzen, ein Pfad führt zur Lichtung mit dem
      **Seilaufzug**. (Hier kommen in Schritt 2 die Monster hin, später der Eingang zur Pilzhöhle.)
    - **Wipfelheim:** fünf Plattformen in den Baumkronen, verbunden durch Hängebrücken: Ankunft mit Seilaufzug und
      **Koch-Stand** (Platzhalter: „Hier wird bald gekocht.“), in der Mitte **Dornfeders Halle** mit Ysolde, im Norden
      **Fenns Schießstand** mit Zielscheiben, im Osten **Tildas Rudelhof**, im Süden **Esches Labor**.
      **Marv** steht auf der Brücke zu Tilda und spricht dich an.
  - **So kommt man hin:** Nach „Leb wohl, Ye.“ kommt der Abspann, jetzt **„Ende von Akt 1“** mit dem Knopf
    **„Weiter nach Grünwacht“**. Danach stehst du auf dem Weg (derselbe Spielstand). Läufst du an den Rand,
    kommst du auf die nächste Karte: Weg ↔ Kreuzweg (Weststraße, erst nach der Klassenwahl) und Weg ↔ Waldboden.
    Den Seilaufzug benutzt du wie eine Figur (antippen oder E / Leertaste).
  - **Auftrag „Der Weg nach Grünwacht“:** nach Wipfelheim reisen, mit Ysolde reden (50 Gold, 100 Erfahrung).
    Ysolde fragt je nach Klasse anders weiter: Bogenschützen nach Fenn, Zähmer nach Esche, alle anderen hören,
    dass ihr Lehrmeister weit weg ist (Entscheidung 21.10.: alle Klassen dürfen nach Grünwacht).
    Wer die erste Stunde schon vorher beendet hatte, bekommt den Auftrag nachträglich bei Ye am Tor (gelbes „!“).
  - **Zusammen spielen:** Der Server kennt alle Karten. Man sieht nur Mitspieler auf derselben Karte, gemeinsame Szenen
    gibt es nur auf derselben Karte, die Gruppe bleibt über Kartenwechsel bestehen. Beim Beitreten kommt man dort an,
    wo man zuletzt war.
  - **Platzhalter:** alle Texte von Ysolde, Fenn, Tilda, Esche, Marv und Ye (neu: „noch da“, „Westen“) in `data/dialoge.json`.
    Musik: vorerst die Stadt-Musik (eigene Grünwacht-Musik kommt in Schritt 11).
  - **Tests:** `tests/gruenwacht_test.gd` (Karten erreichbar, ganze Reise bis Ysolde, alter Spielstand, Klassen,
    Karten getrennt, Speichern) und `tests/netz_gruenwacht_test.gd` (Server und Mitspieler: Weg → Waldboden →
    Wipfelheim → neu betreten). Alle bisherigen Tests laufen unverändert. Bildschirmfotos: `tests/gruenwacht_auto.tscn`.

- **Schritt 2 – Die eigene Klasse in der Welt** (21.10.):
  - **Monster in der Wildnis:** Auf dem Weg nach Grünwacht stehen 8 Monstergruppen (Stufe 10 bei Kreuzweg bis 15 am
    Waldrand), auf dem Waldboden 10 (Stufe 15–20). Die Monster aus design.md: **Rindenbär** (Pflanze, zäh),
    **Windfalke** (Wind, schnell), **Donnerhirsch** (Blitz, stark), **Steinkröte** (Erde, hart), **Sporenling**
    (Pflanze, Giftsporen auf alle) und selten **wilde Mooslinge, Glutwelpen und Bachotter**.
  - Über jedem Monster steht Name und Stufe (bei Gruppen „+1“, „+2“). **Farbe des Namens:** grau = leicht,
    weiß = passend, orange = schwer, rot = sehr schwer (im Vergleich zu deiner Stufe).
  - **Kampf:** hineinlaufen oder antippen. Du kämpfst jetzt **mit deiner gewählten Klasse** (vorher nur in den
    Probestunden). Gruppenmitglieder in der Nähe kämpfen mit, jeder mit seiner Klasse. Neuer Kampf-Hintergrund **Wald**.
  - **Nach dem Kampf:** Sieg = Erfahrung (12 × Stufe je Monster) und etwas Gold, das Monster ist für dich eine Minute
    weg. Niederlage = du wachst am Anfang der Karte wieder auf.
  - **Stufen bis 20** (Kreuzweg 1–10, Weg 10–15, Grünwacht 15–20, Entscheidung 21.10.). Mit jeder Stufe: Leben +10,
    Mana +4, Stärke +5 % (Schaden und Heilung, auch für Roboter und Monster des Zähmers). Monster: pro Stufe
    9 % mehr Leben und 6 % mehr Schaden.
  - **Werte (C):** zeigt nach der Klassenwahl die Werte deiner Klasse (Leben, Mana, Tempo, Stärke).
  - **Test `tests/wildnis_test.gd`:** Der Computer spielt jede Klasse allein gegen jedes Monster (auf dessen Stufe,
    mit durchschnittlichen Paraden). Einzelne Monster schafft jede Klasse fast immer, Zweiergruppen meist,
    Dreiergruppen sind schwer. Allein am stärksten: Tank, Mechaniker, Sternensängerin; am schwächsten der
    **Ritualist** (etwa 60 %, er hat nur einen Angriff).
  - **Behoben:** Die alten Foto-Programme (`welt_auto`, `fest_auto`, `gesandte_auto`, `marv_auto`, `weg_auto`) liefen
    seit Lernprojekt 4 nicht mehr (alter Name `LOCAL_ID`).

- **Schritt 3 – Fenns Prüfung der drei Ziele** (21.10., nur für Bogenschützen):
  - Nach dem Gespräch mit Ysolde hat **Fenn** (Schießstand im Norden von Wipfelheim) ein „!“, aber nur für
    Bogenschützen (neu: Aufträge können nur für bestimmte Klassen gelten).
  - **Erstes Ziel:** drei stehende Strohscheiben. Fenn erklärt die hintere Reihe und die „Ruhige Hand“ (mehr kritische
    Treffer von hinten). Erlaubt: Schneller Schuss, Reihe wechseln.
  - **Zweites Ziel:** zwei laufende Scheiben. Ein schneller Schuss streift nur (30 %), erst **Bogen spannen**, dann
    schießen (aufgeladener Schuss, lädt die Ult). Beides ist ein Lernkampf mit zwei Lektionen wie die Grundausbildung.
  - **Drittes Ziel:** Der **Silberhirsch** steht auf einer kleinen Lichtung im Westen des Waldbodens (erscheint erst
    jetzt). Er sieht dich an. Auswahl: „Den Bogen spannen und schießen.“ oder „Den Bogen sinken lassen.“ (ohne
    Hinweis auf die Folgen).
  - **Fenns Urteil:** Verschont → „Ein Jäger weiß, wann er nicht schießt. … Du bist jetzt Bogenschütze.“ und der Erfolg
    **„Ein Jäger weiß, wann er nicht schießt“**. Geschossen → bestanden, aber „Das war nicht die Prüfung.“ (design.md).
    Belohnung: 500 Erfahrung, 60 Gold.
  - **Neu beim Laufen:** Wer irgendwohin tippt, läuft um Monster herum statt mitten hindurch (nur wer ein Monster
    antippt, läuft hin).
  - **Platzhalter:** alle Texte von Fenn und vom Silberhirsch, die Bilder der Scheiben (Strohpuppen).
  - **Tests:** Prüfung mit beiden Entscheidungen im Grünwacht-Test, der Scheibenkampf im Lernkampf-Test (30 von 30).

- **Schritt 4 – Professor Esche, Kobalt und Tilda** (21.10., nur für Zähmer):
  - **Esche** (vor seinem Labor im Süden von Wipfelheim) hat nach Ysolde ein „!“: Er erklärt das Element-Dreieck
    (Feuer schlägt Pflanze, Pflanze schlägt Wasser, Wasser schlägt Feuer) und du wählst **Moosling, Glutwelpe oder
    Bachotter**. Dazu gibt es die **Schleuder**.
  - **Eigenes Rudel:** Ab jetzt kämpft dein Zähmer mit **seinen** Monstern statt mit allen dreien (vorher, auf dem Weg,
    noch wie in der Probestunde mit allen drei). Das Rudel steht unter „Werte (C)“.
  - **Kobalt**, Esches Neffe, kommt sofort angelaufen, nimmt das Monster, das deins schlägt, und fordert dich heraus.
    Sieg = Erfolg **„Rivale besiegt“**, Niederlage ist kein Spielende (Kobalt: „Hab ich doch gesagt!“). Er hat Stufe 16
    und viel Leben: In der Simulation gewinnt man mit Moosling etwa jedes zweite Mal, mit Glutwelpe und Bachotter
    meistens.
  - **Tilda** bringt danach das Zähmen bei: ein Monster in der Wildnis unter halbes Leben bringen, dann „Zähmen“.
    **Gezähmte Monster bleiben jetzt im Rudel** (höchstens 5), auch nach dem Kampf und im Spielstand.
    Danach: „Du bist jetzt Zähmer, Kleines.“
  - **Platzhalter:** alle Texte von Esche, Kobalt und Tilda, die Bilder von Kobalts Monstern.
  - **Tests:** Esche → Kobalt (Sieg und Niederlage) → Tilda im Grünwacht-Test, Kobalt und Zähmer mit eigenem Rudel
    im Wildnis-Test.

- **Schritt 5 – Leuchtende Tiere und Kael** (21.10., für alle Klassen):
  - **Ysolde** hat nach der Ankunft ein neues „!“: Im Wald sind Tiere mit Splittern im Fell, sie werden wild,
    sie lässt sie jagen. **Tilda** (Rudelhof) sieht das anders: Splitter herausziehen, dann werden sie wieder sie selbst.
  - Danach steht im Nordosten des Waldbodens ein **Splitter-Rindenbär** (Sternenkraft). Deine **persönliche Entscheidung**:
    „Ihn jagen, wie Ysolde es will.“ oder „Ihn bändigen und die Splitter herausziehen, wie Tilda es will.“
    Beides ist ein Kampf (Stufe 17, viel Leben). Verliert man, kann man es wieder versuchen, ohne neu zu entscheiden.
  - **Neuer Baustein Ruf** (Entscheidung 21.10.: sichtbar): Jäger +15 und Zähmer -10 bzw. umgekehrt. Unter
    **„Werte (C)“** steht der Ruf als Leiste aus 10 Kästchen: rot = misstrauisch, grau = neutral, grün = geschätzt.
  - **Ysolde** reagiert auf deine Wahl („Ein Tier weniger, das leidet.“ oder „Hoffentlich weiß Tilda, was sie tut.“).
  - Danach steht **Kael** vor Dornfeders Halle und spricht dich an: Er will, dass Ysolde gesteht. „Frag sie nach
    ihrem Bruder. Rowan. … Sein Grab liegt unten im Wald. Es ist leer.“ Ysolde danach: „Hör nicht auf ihn.“
  - **Platzhalter:** alle Texte (Ysolde, Tilda, Kael, das Tier), die Bilder von Kael und dem Bären.
  - **Tests:** Geschichte mit beiden Entscheidungen im Grünwacht-Test, der Bär mit jeder Klasse im Wildnis-Test (86 %).

- **Schritt 6 – Rowans leeres Grab** (21.10.):
  - Kael gibt nach seinem Auftritt den Auftrag **„Das leere Grab“**. Das Grab steht im **Nordwesten des Waldbodens**:
    „Rowan Dornfeder. Gefallen am sechsten Weg.“ Die Erde ist eingesunken, das Grab ist leer, ein Splitter leuchtet.
  - **Neuer Baustein Erinnerungs-Szene** („Den Splitter berühren.“): ein eigener Bildschirm in blassen Farben, kein
    Kampf. Nacht am sechsten Weg, Menschen fliehen, Ysolde ruft „Bleibt stehen!“ und schießt, Rowan dreht sich zu ihr
    um: „Ysolde …“. Weiter mit Tippen, E oder Leertaste. Danach zurück zum Grab.
  - Erinnerungen stehen in **`data/erinnerungen.json`** (Figuren, Text, wer wohin läuft, wer sich umdreht, Pfeile).
    Du kannst dort eigene Erinnerungen dazuschreiben.
  - **Kael** danach: „Sie hat auf ihren eigenen Bruder geschossen.“ Er erzählt vom **großen Splitter unter dem Urbaum**
    (führt zur Pilzhöhle, Schritt 7).
  - **Platzhalter:** alle Texte (Grab, Erinnerung, Kael), das Bild des Grabsteins.
  - **Tests:** Grab und Kael im Grünwacht-Test, neuer Test `tests/erinnerung_test.gd` (alle Schritte der Erinnerung).

- **Schritt 7 – Pilzhöhle unter dem Urbaum** (21.10.):
  - Nach dem Grab gibt Kael den Auftrag **„Der Splitter im Urbaum“**. Der **Eingang** liegt zwischen den Wurzeln eines
    Riesenbaums im Süden des Waldbodens (erst mit dem Auftrag offen).
  - **Neue Höhlen-Karte** mit Höhlenboden, Fels, leuchtenden Riesenpilzen und Wurzeln: Eingangshalle, ein Gang mit
    Seitenhöhle, die Kammer der **Sporenkönigin** (Zwischenboss) und ganz im Westen die Kammer der **Wurzelmutter**
    (Endboss, mit dem **Vorboten** als zweiter Phase). Unterwegs vier Gruppen Dungeon-Monster (Sporenwölfe,
    Leuchtmotten, Wurzelkriecher, Glimmerkäfer, Stufe 18–19).
  - Alle Mechaniken wie in der Sandbox (Sporenblüte, Zwillingsknoten, Verschlingen, Lichtfraß, Das letzte Licht).
    Die Bosse stehen als große Figuren in ihren Kammern. **Ida, Bo und Tom** kämpfen mit, wenn Plätze frei sind
    (allein also zu viert, zu zweit mit zwei von ihnen). Wer verliert, wacht am Eingang der Höhle auf.
  - **Am Herz des Urbaums** (erscheint nach der Wurzelmutter): „Den Baum fällen und den großen Splitter mitnehmen.“ oder
    „Den Splitter vorsichtig herausschneiden und den Baum retten.“ (ohne Folgen zu verraten, in der Gruppe wird
    abgestimmt). **Nur beim ersten Abschluss**, danach gilt die Wahl automatisch. Retten bringt Ruf bei den Zähmern.
    Belohnung bei jedem Abschluss: ein **Sternensplitter**.
  - **Läufe:** Wer die Höhle von außen betritt, beginnt einen neuen Lauf (die Bosse sind wieder da).
  - **Ysolde** spürt danach, was mit dem Urbaum geschah, und nimmt den Auftrag ab.
  - **Schwierigkeit** (Computer-Spieler mit drei Novizen, Stufe 19–20): Sporenkönigin 86 %, Wurzelmutter 70 %.
    Damit es allein schaffbar ist, kommt „Verschlingen“ in der Welt erst nach 4 statt 3 Zügen, und die Bosse haben
    weniger Leben als ihre Stufe vermuten lässt (vorläufig, Feinschliff am Ende). Splitter-Knoten und Zielscheiben
    wachsen nicht mehr mit der Stufe (sie gehören zur Mechanik).
  - **Platzhalter:** alle Texte, die Höhle als Karte.
  - **Tests:** zwei Läufe mit beiden Entscheidungen im Grünwacht-Test, die Bosse mit jeder Klasse im Wildnis-Test.

- **Schritt 8 – Ende der Region** (21.10.):
  - Nach dem Urbaum hat **Kael** ein „!“: „Jetzt. Vor ihrer Halle. Vor allen.“ (Auftrag „Die Wahrheit über Rowan“).
  - Bei **Ysolde** kommt die **Konfrontation**: Kael stellt sie, Ysolde erzählt ein Stück („Ich hatte Befehl. Niemand
    verlässt diesen Ort.“). Dann die **Abstimmung** (in der Gruppe alle): „Die Wahrheit vor ganz Wipfelheim aussprechen.“
    oder „Das Geheimnis bewahren.“ Danach: **„Rowan … er könnte noch leben.“** Kael ist anschließend fort.
  - **Abspann „Ende von Grünwacht“** mit Rückblick auf deine Entscheidungen (Silberhirsch, Kobalt, Splitter-Bär,
    Urbaum, Wahrheit) und dem Knopf „Zurück nach Wipfelheim“ (Grünwacht bleibt spielbar).
  - **Wipfelheim und der Wald verändern sich:** Urbaum gerettet = Blüten auf Plattformen und Waldboden,
    gefällt = welkes Laub.
  - **Platzhalter:** alle Texte.
  - **Tests:** Konfrontation mit beiden Entscheidungen im Grünwacht-Test, neuer Test `tests/abspann_test.gd`.

- **Schritt 9 – Kreuzweg-Karten** (21.10.):
  - **Das Mini-Spiel** (design.md, angelehnt an Triple Triad): 3×3-Feld auf der Sternentafel, je 5 Karten mit vier
    Zahlen (oben, rechts, unten, links). Ist deine Zahl höher als die der angrenzenden gegnerischen Karte, gehört sie
    dir. Wer am Ende mehr Karten hat (Feld und Hand), gewinnt. Wer anfängt, wird ausgelost.
  - **Spieltisch:** eigener Bildschirm. Links deine Karten (blau), rechts die des Gegners (rot), erst Karte antippen
    (Gold), dann ein Feld. Gerade umgedrehte Karten haben einen weißen Rand. Gespielt wird mit deinen 5 stärksten Karten.
  - **Sternentafel:** In Akt 1 kostet sie bei Bingo weiter 5000 Gold (zu teuer, wie geplant). Nach der Rückkehr aus
    Grünwacht hat Bingo einen **Heimkehrer-Preis von 600 Gold**. Mit der Tafel kommen **7 Startkarten**.
  - **Monsterkarten:** Wer eine Sternentafel hat, bekommt nach Siegen in der Wildnis manchmal (20 %) eine Karte eines
    der besiegten Monster. 21 Karten gibt es bisher (Kreuzweg, Grünwacht, Pilzhöhle). Die Sammlung steht in der Tasche (I).
  - **Marv:** Nebenauftrag „Marvs Partie“ (blau). Mit der Tafel spielt er **genau einmal** mit dir (Erfolg „Marv hatte
    Zeit“), danach: „Sorry, ich muss gerade Eichhörnchen zählen.“ (design.md). Er legt seine Karten wild durcheinander.
  - **Oma Hagebutte** (Wipfelheim, an der Ankunft): erste richtige Gegnerin, spielt schlau. Sieg = 40 Gold, beim ersten
    Sieg eine **Moosling-Karte**. Revanche jederzeit.
  - **Schwierigkeit** (Computer gegen Computer): gegen Marv mit Startkarten 92 % Siege, gegen Oma mit Startkarten 7 %,
    mit guten Grünwacht-Karten 40 % (ein Mensch, der mitdenkt, gewinnt öfter). Kartenwerte vorläufig.
  - **Neu für Aufträge:** Ziel „besitzen“ (einen Gegenstand haben, ohne dass er abgegeben wird), Bedingung „hat“.
  - **Tests:** neuer Test `tests/kartenspiel_test.gd` (Regeln, Gegner, Bingo, Marv, Oma, Beute, Spieltisch).

- **Schritt 10 – Nebenaufträge in Grünwacht** (21.10., alle mit blauem „!“ und „?“):
  - **Kobalts Revanche** (nur Zähmer, nach Tildas Unterricht): Kobalt hat jetzt **zwei Monster** (wieder das
    Gegenstück zu deinem Start-Monster plus ein zweites). Sieg oder Niederlage, beides schließt den Auftrag ab.
    Mit drei eigenen Monstern gewinnt man gut die Hälfte der Kämpfe (vorläufig).
  - **Oma Hagebuttes Herausforderung:** Wer eine Sternentafel hat, bekommt von ihr den Auftrag, sie einmal zu schlagen.
    Belohnung 60 Gold und Erfahrung (dazu wie bisher die Moosling-Karte beim ersten Sieg).
  - **Der verrückte Bienenstock** (alle Klassen, Auftrag bei Professor Esche): Ganz im Südosten des Waldbodens hängt ein
    Bienenstock, der immer dasselbe Lied summt. **Näher herangehen** = Kampf gegen zwei wilde Bienenschwärme.
    **Stehen bleiben und zuhören** = fünf Töne und eine Pause, als ob ein sechster fehlt (wie das Lied der sechs Wege).
    Esche erzählt danach von einer **Bienenhüterin** weit weg (Hinweis auf die spätere Klasse). Belohnung: zwei
    Honigwaben (für den Beruf Kochen, kommt später).
  - **Platzhalter:** alle Texte.
  - **Tests:** im Grünwacht-Test (Revanche, Bienenstock auf beiden Wegen), im Kartenspiel-Test (Omas Auftrag), im
    Wildnis-Test (Bienenschwarm und Revanche sind schaffbar).

- **Schritt 11 – Feinschliff Grünwacht** (21.10.):
  - **Eigene Platzhalter-Musik:** „Wald“ (Holzflöte über Harfe, ab und zu Vogelrufe) auf dem Weg, dem Waldboden und in
    Wipfelheim. Wurde der Urbaum gefällt, läuft dort „Welker Wald“ (dieselbe Stimmung in Moll, langsamer, ohne
    Vögel). In der Pilzhöhle „Wald bei Nacht“ (langsame Harfe, tiefe Flöte, Tropfen). Selbst erzeugt wie die anderen
    Stücke, mit `tools/musik_erzeugen.gd`.
  - **Automatischer Durchlauf** `tests/durchlauf_gruenwacht_test.gd`: Ein Computer-Spieler startet beim Abschied von
    Ye (Stufe 10, wie am Ende von Akt 1), reist über den Weg nach Wipfelheim, folgt den Zeichen auf allen Karten,
    erledigt die Aufträge, kämpft wirklich (auch gegen Monster, wenn ein Kampf zu schwer war) und spielt bis zum
    Abspann „Ende von Grünwacht“. Einmal als Bogenschütze, als Zähmer und als Klingentänzerin (Glutoase).
  - **Ergebnis des Durchlaufs** (geschätzte Spielzeit nur für die Hauptgeschichte, ohne Nebenaufträge und Lesen):
    Bogenschütze 16 Minuten, Stufe 19 am Ende. Zähmer 51 Minuten, Stufe 20 (er muss vor der Sporenkönigin
    mehrmals Monster bekämpfen). Klingentänzerin 15 Minuten, Stufe 18.
  - **Erfahrung abgestimmt:** Ohne Nebenaufträge war man am Ende erst Stufe 17 (Grünwacht soll 15–20 sein). Jetzt gibt
    es mehr Erfahrung für die Hauptaufträge (Leuchtende Tiere 900, Das leere Grab 800, Der Urbaum 1600, Die Wahrheit
    1200) und den Splitter-Rindenbär (600). Mit Nebenaufträgen erreicht man Stufe 20.
  - **Die Stufe zählt mehr** (deine Entscheidung vom 21.10.): Ist ein Gegner höher als du, machst du pro Stufe 6 %
    weniger Schaden und Heilung und er trifft 8 % härter. Bist du höher, ist es umgekehrt (höchstens 5 Stufen zählen).
    Bei gleicher Stufe ändert sich nichts. Beispiel: Den Splitter-Rindenbär (Stufe 17) schafft man mit Stufe 17 in
    89 % der Kämpfe, mit Stufe 12 nur noch in 32 %. Kobalts erster Kampf hat jetzt Stufe 12 (so trifft man ihn) und
    dafür mehr Leben, er ist also ungefähr so schwer wie vorher.
  - **Durchlauf danach:** Man muss vor der Pilzhöhle auf Stufe 17–18 kommen, vorher verliert man gegen die
    Sporenkönigin. Geschätzte Spielzeit jetzt: Bogenschütze 76 Minuten, Klingentänzerin etwa 4 Stunden, Zähmer etwa
    4,5 Stunden (der Computer-Spieler kämpft nicht sehr geschickt gegen Monster, echte Spieler sind schneller).
    Am Ende sind alle Stufe 20.

## Aufgaben Lernprojekt 4 „Zusammen spielen“ (Fahrplan in `ZUSAMMEN_PLAN.md`)

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 0 | Plan schreiben | erledigt |
| 1 | Zusammen in Kreuzweg laufen (Gastgeber, Beitreten, alle sehen sich) | eingebaut, Marco testet |
| – | Entscheidungen: kostenloser Server, Story gemeinsam mit Abstimmung, Chat mit Schnellsätzen, ein Spielstand | entschieden 20.10., Spielstand eingebaut |
| 2 | Online-Server im Internet (kostenlos bei Render) | vorbereitet, Marco legt das Konto an |
| 3 | Chat mit freiem Text und Sprechblase | eingebaut, Marco testet |
| 4 | Gruppe bilden (einladen, Gruppenfenster, Gruppenführer) | eingebaut, Marco testet |
| 5 | Geschichte gemeinsam erleben (Abstimmung) | eingebaut, Marco testet |
| 6 | Gemeinsamer Kampf | eingebaut, Marco testet |
| 7 | Nacht des Sternenfalls zusammen | eingebaut, Marco testet |
| 8 | Feinschliff (Wiederverbinden, Test mit 4 Spielern, Durchlauf zu zweit) | eingebaut, Marco testet |

## Fertig in Lernprojekt 4

- **Schritt 1 – Zusammen in Kreuzweg laufen:**
  - Im Menü gibt es den neuen Knopf **„Zusammen spielen“**. Dort wählst du **Name** und **Figur** (8 Pixel-Figuren)
    und tippst auf **„Gastgeber werden“** (nur PC-Version) oder **„Beitreten“** (mit der Adresse des Gastgebers).
    Name, Figur und Adresse werden gemerkt.
  - In Kreuzweg sehen sich **bis zu 4 Spieler** gegenseitig laufen, mit Namen über dem Kopf (dein eigener grün).
    Oben links steht „Zusammen: 2 Spieler“, beim Gastgeber dazu die **Adresse für Mitspieler** im eigenen WLAN.
  - **Wie es funktioniert:** Nur der Gastgeber hat die echte Stadt. Mitspieler schicken ihre Befehle (laufen, reden,
    Antwort wählen, kaufen …) und bekommen zurück, wo alle stehen, und ihren eigenen Fortschritt. Das klappt, weil die
    Stadt seit Lernprojekt 3 nur über Befehle gesteuert wird – an den Regeln der Stadt musste nichts geändert werden.
  - Noch spielt **jeder seine eigene Geschichte** (Aufträge, Gespräche, Nacht beim Fest …). Gemeinsam mit Abstimmung
    kommt in Schritt 5.
  - **Spielstand (nach deiner Entscheidung):** Beim Zusammenspielen gilt **derselbe Spielstand wie allein**, ein Charakter
    für alles. Läuft auf demselben PC schon ein anderes Fenster mit diesem Spielstand, bekommt das zweite Fenster
    automatisch einen eigenen (`spielstand_fenster_<Name>`), damit sich die beiden beim Testen nicht überschreiben.
    Die automatischen Tests benutzen eigene Test-Spielstände und fassen deinen nie an.
  - **Kämpfe sind noch allein:** Wer kämpft, verschwindet kurz aus der Stadt und kommt danach zurück.
    Der gemeinsame Kampf ist Schritt 5.
  - **„Menü“** beendet das Zusammenspielen (beim Gastgeber für alle). Reißt die Verbindung ab, landest du wieder auf
    „Zusammen spielen“ mit einem Hinweis; dein Fortschritt ist gespeichert.
  - **Server ohne Grafik** für später: `Godot --headless --path . -- --server` (gleiches Spiel, keine eigene Figur).
  - **Grenzen bisher:** Am Handy und im Browser geht nur „Beitreten“, und zwar erst richtig mit einem Server im Internet
    (Schritt 2), weil Browser aus Sicherheitsgründen nur sichere Verbindungen erlauben. Ausnahme: Browser und Gastgeber
    auf demselben PC (`localhost`). Die eigene Figur reagiert minimal verzögert (im WLAN kaum spürbar), das glätte ich in Schritt 7.
  - **Tests:** `tests/netz_test.gd` startet ein zweites Programm als Mitspieler: Beitreten, Name und Figur, Laufen,
    Einleitung vom Gastgeber, Verlassen, dazu der Spielstand für ein zweites Fenster – alles richtig (14 Prüfungen). `tests/netz_stadt_test.gd` öffnet die echte
    Stadt gegen einen Server ohne Grafik, inklusive „Neu beginnen“ und „Menü“: alles richtig (13 Prüfungen).
    Alle bisherigen Tests (Welt, Klassenwahl, Übergang, Lektionen, Elemente, Durchlauf der ersten Stunde) laufen unverändert.

- **Schritt 2 – Online-Server (vorbereitet):**
  - Auf „Zusammen spielen“ gibt es den neuen Knopf **„Online-Server (übers Internet)“**. Er verbindet mit dem Server
    bei Render (`wss://asterfall-server.onrender.com`, sichere Verbindung, geht im Browser und am Handy).
  - Der Server ist dasselbe Spiel ohne Grafik. Bauplan für Render: `render.yaml` und `server/Dockerfile`. Den Port
    gibt der Anbieter vor.
  - **Der kostenlose Server schläft**, wenn 15 Minuten niemand spielt, und braucht dann bis zu einer Minute zum Aufwachen.
    Das Spiel wartet deshalb bis zu zwei Minuten und sagt das auch an. Verbundene Mitspieler melden sich alle 30 Sekunden
    kurz, damit er nicht mitten im Spiel einschläft.
  - **Geprüft:** Das Server-Paket hier nachgebaut (gleiches Spiel, Port 10000 wie bei Render) und einen Mitspieler
    verbunden: Beitreten, Laufen, Einleitung, alles richtig. Den Download-Teil des Bauplans (Godot holen) konnte ich hier
    nicht ausprobieren, weil diese Umgebung keine Pakete aus dem Internet laden darf; das zeigt sich beim ersten Bau bei
    Render. Alle bisherigen Tests laufen weiter.
  - **Läuft** (Marco, 20.10.): Verbinden klappt, aber man hing öfter. Darum nachgebessert:
    - **Standort Frankfurt** statt Oregon (USA) im Bauplan. Dafür muss der Dienst einmal neu angelegt werden
      (Anleitung unten in `SERVER_ANLEITUNG.md`).
    - **Eigene Figur läuft sofort** los, ohne auf den Server zu warten. Der Server rechnet dasselbe und zieht die Figur
      nur zurück, wenn sie stark abweicht.
    - **Mitspieler laufen gleichmäßig:** Sie werden 0,2 Sekunden verzögert gezeigt, dafür ohne Ruckeln. Bleiben Nachrichten
      kurz aus, laufen sie noch bis zu 0,6 Sekunden in ihrer Richtung weiter.
    - **Server rechnet sparsamer** (höchstens 30-mal pro Sekunde), weil der kostenlose Tarif wenig Rechenleistung hat.
    - **Gemessen** mit künstlich schlechter Verbindung (alle 2 Sekunden 0,35 Sekunden Aussetzer): Sprünge der Mitspieler
      von 69 auf 3, Stillstand-Bilder ungefähr halbiert. Alle Tests laufen.

- **Schritt 3 – Chat:**
  - Beim Zusammenspielen gibt es oben links den Knopf **„Chat (Enter)“**. Am PC öffnet **Enter** die Eingabe, Enter
    schickt ab, **Esc** bricht ab. Am Handy den Knopf antippen, dann erscheint die Tastatur.
  - Die Nachricht geht an **alle in Kreuzweg**: Sie steht links unter dem Knopf (die letzten 6, ältere blenden nach
    20 Sekunden aus) und als **Sprechblase** über dem Kopf des Schreibers (6 Sekunden).
  - Hinweise vom Spiel im Chat: „Mira ist in Kreuzweg.“ und „… hat das Spiel verlassen.“ (nicht nach jedem Kampf neu).
  - Während man tippt, läuft die Figur nicht (WASD sind dann Buchstaben).
  - Schutz: höchstens 120 Zeichen, keine Zeilenumbrüche, höchstens eine Nachricht alle 0,6 Sekunden pro Spieler.
    Wer gerade kämpft, kann nicht schreiben, sieht nach dem Kampf aber, was geschrieben wurde.
  - Schnellsätze und Emotes kommen später (Vorschläge in design.md im Ideen-Parkplatz).
  - **Tests:** Gastgeber und Mitspieler schreiben sich, zu schnelle Nachricht wird verworfen, Hinweise beim Kommen und
    Gehen, Chat in der echten Stadt mit Sprechblase – alles richtig. Alle bisherigen Tests laufen weiter.

- **Schritt 4 – Gruppe bilden:**
  - **Mitspieler antippen** (oder anklicken) öffnet ein kleines Menü: **„In Gruppe einladen“**. Als Gruppenführer
    stehen bei Mitgliedern **„Führung übergeben“** und **„Aus Gruppe nehmen“**.
  - Der Eingeladene bekommt ein Fenster „Marco lädt dich in die Gruppe ein.“ mit **Annehmen** und **Ablehnen**.
    Die Einladung gilt 60 Sekunden.
  - **Gruppenfenster** rechts oben: alle Mitglieder mit Stufe und Leben, ★ = Gruppenführer, „kämpft gerade“ bei
    jemandem, der gerade einen Kampf spielt. Knopf **„Gruppe verlassen“**. Gruppenmitglieder haben in der Stadt
    einen **hellblauen Namen**.
  - **Regeln:** höchstens 4 Spieler. Nur der Gruppenführer lädt ein. Wer die Gruppe gründet (die erste Einladung wird
    angenommen), führt sie. Geht der Gruppenführer, führt der Nächste. Wer allein übrig bleibt, ist nicht mehr in einer
    Gruppe. Wer kämpft, bleibt in der Gruppe; wer das Spiel verlässt, ist raus.
  - Die Leben-Leiste ist in der Stadt immer voll (Kämpfe heilen ganz). Im gemeinsamen Kampf (Schritt 6) zeigt sie
    das echte Leben.
  - Die Regeln stehen in einem eigenen Baustein ohne Grafik (`scripts/netz/gruppen.gd`), darauf bauen später die
    gemeinsame Geschichte (Abstimmung, Gruppenführer bei Gleichstand) und der gemeinsame Kampf auf.
  - **Tests:** `tests/gruppen_test.gd` prüft alle Regeln (20 Prüfungen), der Netz-Test eine echte Einladung zwischen
    zwei Programmen – alles richtig. Alle bisherigen Tests laufen weiter.

- **Schritt 5 – Geschichte gemeinsam erleben:**
  - Spricht jemand aus einer Gruppe eine Figur an, werden **Gruppenmitglieder in der Nähe** (8 Felder, nach deiner
    Entscheidung) in das Gespräch geholt: „Gemeinsame Szene: Marco spricht mit Schreiberin Lene.“ Alle sehen denselben Text.
  - **Wer spricht, blättert weiter.** Bei Antworten **stimmen alle ab**, die in der Geschichte an derselben Stelle sind.
    Man sieht, wie viele Stimmen jede Antwort hat (✔ = eigene Stimme), wie viele noch fehlen und die Restzeit.
    Haben alle gewählt, gilt die Mehrheit; **bei Gleichstand entscheidet der Gruppenführer** (hat er nicht mitgestimmt:
    wer spricht). Nach **30 Sekunden** zählen die abgegebenen Stimmen.
  - **Wer an einer anderen Stelle der Geschichte ist** (z. B. die Szene schon erlebt hat), **schaut zu**: Er sieht alles,
    kann aber nicht abstimmen und bekommt keine Belohnung. Seine eigene frühere Wahl bleibt.
  - Belohnungen, Aufträge und Gemerktes gelten für alle, die abgestimmt haben.
  - **„Szene verlassen“** holt einen aus der Szene. Geht der Sprecher (Knopf, Kampf, Spiel verlassen), spricht der Nächste
    weiter. Ist niemand mehr da, der abstimmen darf, ist die Szene vorbei.
  - Allein (ohne Gruppe oder ohne Mitglieder in der Nähe) läuft jedes Gespräch wie bisher.
  - Noch vorläufig: Ein Kampf aus einem Gespräch (z. B. Lektion bei Ye) startet bei jedem einzeln. Gemeinsam kämpfen
    kommt in Schritt 6.
  - **Tests:** `tests/szene_test.gd` (Mitholen, Abstimmen, Zuschauen, Gleichstand, Weiterblättern, Verlassen, Zeit,
    Belohnungen – 23 Prüfungen) und im Netz-Test eine echte gemeinsame Szene mit Lene zwischen zwei Programmen –
    alles richtig. Alle bisherigen Tests laufen weiter.

- **Schritt 6 – Gemeinsamer Kampf:**
  - Beginnt in einer **gemeinsamen Szene ein Kampf** (z. B. „Wir schaffen das!“ bei Ye für den Gruppenkampf), kämpfen
    **alle zusammen, die mit abgestimmt haben** (nach deiner Entscheidung). Wer nur zugeschaut hat, bleibt in der Stadt.
  - **Jeder steuert seine eigene Figur.** Die Spieler stehen vorne, **freie Plätze füllen die Novizen-Mitstreiter**
    (z. B. zwei Spieler + Ida und Bo beim Gruppenkampf). Im Kampf sieht jeder aus wie seine Figur in der Stadt.
  - **25 Sekunden pro Zug** (die Uhr steht oben beim eigenen Zug), danach kommt automatisch ein **Standardangriff**.
    Bei den anderen steht „Mira ist am Zug …“.
  - **Parieren** misst jedes Gerät selbst (die Verbindung verdirbt das Timing nicht), die anderen sehen das Ergebnis.
  - **Aufgeben** bringt einen zurück in die Stadt (als Niederlage); die anderen kämpfen weiter, für die Figur entscheidet
    ab dann der Server (Standardangriff). Genauso, wenn jemand die Verbindung verliert.
  - Gemeinsam gibt es kein „Nochmal versuchen“ (dafür müssten alle zustimmen). Jeder bekommt danach sein Ergebnis
    (Erfahrung, Aufträge, getrunkene Heiltränke) wie bisher.
  - **Wie es funktioniert:** Die Kampfregeln ergeben bei gleichem Startwert und gleichen Entscheidungen immer genau denselben
    Kampf (das hatten wir in Runde 2 so gebaut). Deshalb rechnet **jedes Gerät den Kampf selbst**, und übers Netz gehen nur
    die **Entscheidungen** (Fähigkeit und Ziel, wie gut pariert wurde). Der Server rechnet unsichtbar mit, prüft jede
    Entscheidung und springt ein, wenn jemand weg ist (`scripts/netz/gemeinsamer_kampf.gd`).
  - **Platzhalter:** Die Texte des Gruppenkampfs sprechen noch von „Ida, Bo und Tom kämpfen mit dir“, auch wenn Mitspieler dabei sind.
  - Noch nicht gemeinsam: der Sternenfresser mit Ren (das ist Schritt 7).
  - **Tests:** `tests/gruppenkampf_test.gd`: Server und zwei Mitspieler rechnen drei Kämpfe (normal, einer gibt auf,
    ungültige Entscheidungen) – jedes Mal **genau gleich** (Sieger, Züge, Leben aller Figuren, Kampf-Log).
    `tests/netz_gruppenkampf_test.gd`: zwei echte Programme mit echter Kampf-Anzeige kämpfen den Gruppenkampf zusammen –
    gleiches Ergebnis auf beiden, danach zurück in der Stadt. Szenen-Test: Kampf aus einer Szene wird zum Gruppenkampf.
    Alle bisherigen Tests laufen weiter.

- **Schritt 7 – Nacht des Sternenfalls zusammen:**
  - **Marv spricht die Gruppe gemeinsam an:** Kommt jemand auf dem Fest in Marvs Nähe, werden Gruppenmitglieder in der Nähe
    mit in die Szene geholt (wie bei Schritt 5). Danach spricht Marv niemanden aus der Gruppe noch einmal an.
  - **Den Sternenfall sehen alle in der Stadt** (greller Lichtblitz, Wackeln), auch wer gar nicht auf dem Fest ist –
    so steht es in design.md. Er kommt nur einmal, auch wenn mehrere ihn auslösen.
  - **Sternenfresser für die Gruppe:** Alle, die bei Ye „Los!“ mit abgestimmt haben, kämpfen zusammen (Schritt 6).
    Er **passt sich der Gruppengröße an**: je weiterem Spieler 25 % mehr Leben (allein 240, zu zweit 300, zu viert 420).
    In `data/kaempfe.json` als `"gruppe_staerke": 0.25` einstellbar (vorläufig, Feinschliff am Ende).
  - **Ren kommt erst, wenn alle zurück sind:** Wer zuerst aus dem Kampf kommt (oder aufgegeben hat), wartet. Sind alle
    wieder in der Stadt, spricht Ren die Gruppe **gemeinsam** an. Wer aufgegeben hat, hat „verloren“ und schaut bei Ren zu,
    wenn die anderen gewonnen haben. Wer das Spiel verlässt, auf den wird nicht gewartet.
  - Allein läuft die Nacht wie bisher.
  - **Platzhalter:** Ye ruft „Ida, Bo, Tom – und du!“, auch wenn Mitspieler dabei sind.
  - **Tests:** Szenen-Test mit der ganzen Nacht (Marv holt beide, Sternenfall für alle einmal, gemeinsamer Boss, Ren wartet
    und kommt dann für beide, beide haben den Erfolg) und dem stärkeren Sternenfresser. Der Sternenfresser lief auch als
    echter Gruppenkampf zwischen zwei Programmen (gleiches Ergebnis auf beiden). Alle bisherigen Tests laufen weiter.

- **Schritt 8 – Feinschliff:**
  - **Wiederverbinden:** Reißt die Verbindung in der Stadt ab (Funkloch, Server startet neu), steht in der Mitte
    „Verbindung weg – verbinde neu (Versuch 1 von 3) …“. Das Spiel versucht es bis zu dreimal von selbst und holt dich
    danach mit deinem gespeicherten Fortschritt zurück in die Stadt. Erst wenn alle drei Versuche scheitern, geht es
    zurück zu „Zusammen spielen“ mit einem Hinweis.
  - **Gruppe bleibt:** Kommst du innerhalb von 3 Minuten zurück, bist du wieder in deiner alten Gruppe
    („Mira ist wieder da.“). War die Gruppe zu zweit (sie löst sich dann auf), wird sie neu gebildet.
  - Im Gruppenkampf geht das Wiederverbinden nicht (der Kampf läuft weiter, der Server übernimmt deine Figur); dann zurück
    zu „Zusammen spielen“, der Fortschritt ist gespeichert.
  - **Test mit 4 Spielern:** Gastgeber + drei Mitspieler-Programme treten bei, bilden eine Gruppe, grüßen im Chat und
    kämpfen den Gruppenkampf zu viert (keine Mitstreiter mehr nötig) – alle vier haben genau dasselbe Ergebnis.
  - **Durchlauf zu zweit:** Zwei Computer-Spieler in einer Gruppe spielen die ganze erste Stunde bis zum Abspann – mit
    gemeinsamen Szenen (Ye, Marv, Bingo, Lene, Marv auf dem Fest, Ren …), uneinigen Abstimmungen, Gruppenkämpfen
    (Grundausbildung, Gruppenkampf, Sternenfresser) und Ren, die auf beide wartet. Mit sieben Startwerten ohne Hänger.
    Beobachtung: Ist einer in der Geschichte schon weiter, schaut er bei Marv nur zu, und jeder kämpft den Sternenfresser
    für sich – so ist es gewollt.
  - **Tests:** `tests/netz_wiederverbinden_test.gd`, `tests/netz_gruppenkampf_test.gd` (jetzt zu viert),
    `tests/durchlauf_zu_zweit_test.gd` – alles richtig. Alle bisherigen Tests laufen weiter.

## Lernprojekt 4 auf einen Blick

| Was | Wie |
|-----|-----|
| Beitreten | Menü → „Zusammen spielen“ → „Online-Server“ (Browser, Handy, PC) oder Gastgeber/Beitreten im eigenen WLAN |
| Spielstand | derselbe wie allein (zweites Fenster auf demselben PC: eigener) |
| Chat | Enter bzw. Knopf „Chat“, Sprechblase über dem Kopf |
| Gruppe | Mitspieler antippen → einladen, bis 4, ★ = Gruppenführer |
| Geschichte | Gruppenmitglieder in der Nähe erleben Gespräche mit und stimmen ab (Gleichstand: Gruppenführer) |
| Kampf | Kampf aus einer gemeinsamen Szene = Gruppenkampf, 25 s pro Zug, freie Plätze: Novizen |
| Sternenfall | für alle sichtbar, Boss passt sich der Gruppe an, Ren für alle gemeinsam |
| Abbruch | automatisch neu verbinden, Gruppe bleibt |

## Aufgaben dieser Runde (Runde 2)

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 1 | Sternensängerin heißt jetzt „Vega“ | erledigt |
| 2 | Schnellfeuer, Polarstern, Zähmen, Entscheidung nach der Pilzhöhle | erledigt |
| 3 | Kunoichi-Ult lädt nur durch Siegel-Kombinationen | erledigt |
| 4 | Elemente absichern (unbekanntes Element = normaler Schaden) | erledigt |
| 5 | Selbst gewählte Werte als „vorläufig“ markieren | erledigt |
| 6 | Kampf in Regeln und Anzeige trennen | erledigt |
| 7 | Steuerung in der Welt: Tasten (PC), Steuerknopf und Aktions-Knopf (Handy) | erledigt |
| 8 | Kreuzweg-Demo Schritt 1: Bausteine (siehe KREUZWEG_PLAN.md) | erledigt |
| 9 | Kreuzweg-Demo Schritt 2: Ankunft (Gilde, Ye, erster Auftrag) | erledigt |
| 10 | Kreuzweg-Demo Schritt 3: Grundausbildung (Lektionen, erster Gruppenkampf) | erledigt |
| 11 | Kreuzweg-Demo Schritt 4: Marv und Bingos Laden | erledigt |
| 12 | Kreuzweg-Demo Schritt 5: Gesandte der fünf Regionen mit Probestunden | erledigt |
| 13 | Kreuzweg-Demo Schritt 6: Der zugewachsene Weg (Wache Holm, Mira) | erledigt |
| 14 | Kreuzweg-Demo Schritt 7: Nacht des Sternenfalls (Fest, Sternenfresser, Ren) | erledigt |
| 15 | Parieren/Ausweichen mit normaler Zone und Perfekt-Zone | erledigt |
| 16 | Kreuzweg-Demo Schritt 8: Klassenwahl und Abreise | erledigt |
| 17 | Kreuzweg-Demo Schritt 9: Feinschliff (Musik, Hintergründe, Namen, Durchlauf-Test) | eingebaut, Marco testet am Stück |
| 21 | Kreuzweg nach Sitzung 21: neue Figuren und Nebenaufträge (blaues Zeichen) | eingebaut, Marco testet |

## Aufgaben der Runde 1

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 1 | Kampf-Sandbox prüfen und fertigstellen | erledigt |
| 2 | Pilzhöhle als spielbarer Test-Dungeon | erledigt |
| 3 | Gerüst für die Kreuzweg-Demo (Lernprojekt 3) | erledigt |
| 4 | Web-Export aktualisieren | erledigt |

## Fertig in Runde 2

- **Rückmeldungen vom 22.10.:**
  - **Kein Zurückspringen mehr:** Allein lief die Figur nach dem Anhalten zwischen zwei Feldern beim nächsten Klick erst
    ein Stück zurück. Jetzt geht es direkt weiter. Beim Zusammenspielen bestimmt der Mitspieler seine Figur selbst und
    meldet ihren Platz an den Gastgeber; solange sie läuft, wird sie nie mehr zurückgezogen.
  - **NPCs kommen angelaufen:** Wer dich von selbst anspricht (Marv, Mira, Ren, Marv auf dem Fest und beim Abschied …),
    taucht ein Stück entfernt auf, läuft zu dir (du wartest kurz), redet und geht danach an seinen Platz.
  - **Gespräche:** Mit **F** geht der Text weiter, **F gedrückt halten** blättert schnell durch (hält bei Antworten an).
    Antworten, die die **Hauptgeschichte** weiterbringen, tragen das gelbe **!** (neuer Auftrag) oder **?** (weiter/abgeben).
    Antworten für Nebenaufträge bekommen kein Zeichen.
  - **Wegweiser:** Ein gelber Pfeil und Ring zeigen, wohin du für die Hauptgeschichte musst (NPC, Kräuter …). Ist das
    Ziel nicht im Bild, zeigt ein Pfeil am Bildrand die Richtung mit Entfernung. Liegt es auf einer anderen Karte,
    zeigt er zum Ausgang dorthin.
  - **Nichts mehr versteckt:** Namen, Sprechblasen und ! / ? liegen über Häusern und Bäumen. Häuser, Bäume, Stände und
    Riesenbäume werden durchsichtig, wenn jemand dahinter steht.
  - **Monster laufen herum:** Die Monster in der Wildnis laufen um ihren Platz herum und folgen dir, wenn du nah kommst.
    Berühren (oder sie dich) = Kampf. Nach einem Kampf hast du 3 Sekunden Ruhe, damit nicht sofort der nächste beginnt.
  - **Erster Gruppenkampf:** nur noch eine Welle.
  - **Kritische Treffer:** dicke gelbe Zahl auf einem roten Stern (wie in Ragnarok).
  - **Klingentänzerin:** Klingenschritt 9 statt 12, Ausfallschritt 13 statt 17, dafür trifft danach **jede schwebende
    Klinge (bis 5) noch einmal** (je 2 Schaden). Die Klingen sieht man als kleine Schwerter um Zara kreisen.
    Der alte Bonus (+5 % je Klinge) ist weg.
  - **Sternenfresser:** Ohne perfekte Parade fällt man sofort, normal pariert kostet es 90 % des Lebens.
  - **Tests:** Welt-Test um Marv/Mira/Ren-Herbeilaufen, Zeichen an Antworten, Wegweiser, laufende Monster und
    „kein Zurücklaufen“ erweitert.

- **Schritt 1 – Name:** Die Sternensängerin heißt jetzt überall **Vega** (Lyra ist Kaels Schwester).

- **Schritt 2 – Fehlende Fähigkeiten und Entscheidung:**
  - **Schnellfeuer** (Bogenschütze): 3 schnelle Pfeile à 7 auf zufällige Gegner, 12 Mana. Kritische Treffer laden wie immer die Ult.
  - **Polarstern** (Sternensängerin): Ein Verbündeter bekommt Abwehr+ und ist früher dran, +1 Schutz-Sternbild, 10 Mana.
    Mit vollem Schutz-Sternbild (Sternenglanz) wirkt er auf die ganze Gruppe.
  - **Zähmen** (Monster-Zähmer): Ein Monster unter 50 % Leben kann gefangen werden. Je schwächer, desto sicherer
    (bei 50 % halbe Chance). Es kommt mit halbem Leben auf die Bank und kann per „Wechsel“ kämpfen, mit seinem
    eigenen Angriff und „Beschützen“. Zähmbar sind alle normalen Monster, auch die der Pilzhöhle (nicht Bosse,
    Sporenknospen und Knoten). Höchstens 5 Monster.
  - **Entscheidung nach der Pilzhöhle:** Nach dem Sieg über den Vorboten zwei Knöpfe: „Baum fällen, großen Splitter
    mitnehmen“ oder „Splitter herausschneiden, Baum retten“. Das Ergebnis steht im Log und in der Auswertung.
  - Neu: **automatische Testkämpfe** (Ordner `tests`): 75 Kämpfe, alle Klassen, alle Gegner, der Computer spielt.
    Alle laufen ohne Fehler durch, Zähmen, Polarstern und die Entscheidung kommen darin vor.

- **Schritt 3 – Kunoichi-Ult:** lädt jetzt nur noch durch ausgelöste Siegel-Kombinationen (+35 je Kombination,
  also nach drei Kombinationen voll). Ein einzelnes gelöstes Siegel lädt nichts mehr.

- **Schritt 4 – Elemente absichern:** Ein unbekanntes Element (z. B. Tippfehler oder ein neues Element ohne Eintrag)
  macht jetzt normalen Schaden, statt das Spiel abstürzen zu lassen. Dazu ein kleiner automatischer Test (10 von 10 richtig).
  Im Spiel ändert sich dadurch nichts Sichtbares.

- **Schritt 5 – Vorläufige Werte:** Die selbst gewählten Passiven und alle Pilzhöhlen-Zahlen stehen jetzt gesammelt
  im Abschnitt „Vorläufige Werte (Feinschliff am Ende)“.

- **Schritt 6 – Kampf in Regeln und Anzeige getrennt:**
  - **Regeln** (`battle_state.gd`): ein Kampf-Zustand ganz ohne Grafik. Er nimmt Befehle an („Vega benutzt
    Polarstern auf Wren“, „Reaktion getroffen: ja“) und meldet Ereignisse („Treffer 12 auf Sporenwolf“,
    „Geschoss von Wren zum Dornling“, Log-Zeilen). Er wartet nie auf Animationen und hat seinen eigenen Zufall.
  - **Anzeige** (`combat.gd`): spielt diese Ereignisse der Reihe nach ab (Figuren, Treffer, Leisten, Log, Ring)
    und gibt deine Eingaben als Befehle zurück. Die Lebensleiste sinkt erst, wenn der Treffer zu sehen ist.
  - **Warum:** Für gemeinsame Kämpfe kann der Kampf-Zustand später auf einem Server laufen; jeder Spieler hat nur
    die Anzeige. Ein Computer-Spieler kann denselben Kampf ohne Grafik in Sekunden durchspielen.
  - **Geprüft:** 75 automatische Kämpfe (5 Teams, alle 11 Klassen, alle 5 Gegner, je 3 feste Zufallswerte)
    vor und nach dem Umbau. Ergebnis: **Zug für Zug identisch** (Leben, Mana, Ult, Zugleiste, jede Log-Zeile und
    jede Schadenszahl, rund 90.000 Zeilen). Für den Vergleich habe ich im alten Stand nur die Zufallsquelle
    ausgetauscht, sonst nichts. Dazu ein Probelauf mit echter Anzeige, in dem der Computer spielt
    (`tests/anzeige_auto.tscn`), und alle Szenen starten ohne Fehlermeldung.

- **Schritt 7 – Steuerung in der Welt** (Kreuzweg-Demo, auch in design.md unter „Steuerung“ eingetragen):
  - **PC:** WASD oder Pfeiltasten = laufen, E oder Leertaste = reden bzw. Gespräch weiterblättern. Klicken zum Hinlaufen bleibt.
  - **Handy:** Steuerknopf unten links – er erscheint dort, wo der Daumen aufsetzt (kurz antippen ohne Ziehen = hinlaufen).
    Aktions-Knopf „Reden“ unten rechts. Antippen zum Hinlaufen bleibt. Beides erscheint nur auf Geräten mit Touchscreen.
  - Häuser, Bäume und NPCs halten dich auf, du rutschst an ihnen entlang.
  - Wie bisher alles über Befehle an die Welt („steuern“, „benutzen“), damit später Mitspieler dazukommen können.
  - Der Kampf bleibt rundenbasiert mit Antippen. Automatischer Test `tests/welt_test.gd`: alles richtig.

- **Schritt 8 – Kreuzweg-Demo, Bausteine** (Schritt 1 aus `KREUZWEG_PLAN.md`):
  - **Gespräche mit Antworten:** Ye stellt Fragen, du wählst eine Antwort (antippen oder Taste 1–4).
    Je nach Antwort und Fortschritt sagt er etwas anderes.
  - **Auftragsbuch** (Knopf „Aufträge“ oder J): zeigt laufende, erfüllte und abgeschlossene Aufträge mit Fortschritt.
  - **Gold und Tasche** (Knopf „Tasche“ oder I), **Erfahrung und Stufen 1–10** oben links.
  - **Speichern:** automatisch bei jedem Fortschritt und beim Verlassen. „Neu beginnen“ löscht den Spielstand.
  - **Probe-Auftrag „Kräuter für Ye“:** nur zum Ausprobieren der Bausteine (der echte erste Auftrag kommt in Schritt 2).
    Drei leuchtende Silberkräuter einsammeln (antippen oder E daneben), bei Ye abgeben:
    30 Gold, 120 Erfahrung (= Stufe 2) und ein Heiltrank.
  - **Alles in Datendateien** (`data/`): Dialoge, Aufträge, Gegenstände, Stufen, Meldungen und die NPCs der Stadt.
    Anleitung zum Ändern: `data/LIESMICH.md`.
  - **Mehrspieler-tauglich:** Jeder Spieler hat seinen eigenen Fortschritt, alles läuft über Befehle an die Welt
    („rede mit Ye“, „wähle Antwort 2“, „sammle Punkt 1“). Jeder sieht nur die Kräuter, die er selbst noch nicht hat.
  - **Platzhalter:** Ye's Texte sind Platzhalter – **Marco schreibt die Dialoge der Hauptfiguren noch.**
  - Automatischer Test `tests/welt_test.gd` (Gespräch, Auftrag, Belohnung, Stufen, Speichern): alles richtig.

- **Nachbesserung nach deinem Test:**
  - Das dritte Silberkraut lag hinter der Schmiede versteckt. Es liegt jetzt frei sichtbar auf dem Marktplatz.
  - **Splitter sind Dungeon-Belohnungen** (auch in design.md eingetragen): Nach der Pilzhöhle behält die Gruppe den
    Splitter in beiden Fällen. In der Auswertung steht „Belohnung: Sternensplitter“. Der Sternensplitter steht schon
    als Gegenstand in `data/gegenstaende.json`, damit er später in die Tasche kommen kann.
  - Die Knöpfe der Urbaum-Entscheidung verraten nicht mehr, was danach passiert (z. B. besserer Ruf bei den Zähmern).
    Die Folgen stehen erst nach der Wahl im Log. Das gilt ab jetzt für alle Entscheidungen.
  - Die Urbaum-Frage kommt **nur beim ersten Abschluss**. Die Wahl wird im Spielstand gespeichert; bei jedem weiteren
    Sieg in der Pilzhöhle gilt sie automatisch („Wie beim ersten Mal …“). „Neu beginnen“ in der Kreuzweg-Demo löscht
    sie mit. (Im fertigen Spiel ist der erste Abschluss der über den Auftrag.) Auch in design.md eingetragen.

- **Schritt 9 – Kreuzweg-Demo, Ankunft** (Schritt 2 aus `KREUZWEG_PLAN.md`, Stufe 1–2):
  - **Einleitung am Stadttor:** Beim ersten Betreten erzählt ein Erzähler kurz, wo du bist, und schickt dich zur Gilde.
  - **Abenteurergilde:** Die Gildenschreiberin **Lene** vor dem Eingang trägt dich als Novize ein und schickt dich zu Ye.
  - **Ausbilder Ye:** begrüßt dich, beantwortet Fragen (Kämpfen, Laterne) und gibt den **ersten Auftrag
    „Die Stadt kennenlernen“**: drei Silberkräuter sammeln und der **Schmiedin Marta** Bescheid sagen. Abgeben bei Ye
    = 25 Gold, ein Heiltrank und genau **Stufe 2**. Danach kündigt Ye die Grundausbildung am Stadttor an (Schritt 3).
  - **Hilfen zum Zurechtfinden:** „!“ über einem NPC = neuer Auftrag, „?“ = dort etwas erledigen oder abgeben.
    Oben links steht immer das nächste **Ziel** (z. B. „Silberkraut 1 / 3“ oder „Zurück zu Ausbilder Ye“).
  - Wer Ye vor der Anmeldung anspricht, wird freundlich zur Gilde geschickt. Marv kommt wie geplant erst nach dem Tutorial.
  - Der Probe-Auftrag aus Schritt 1 ist durch den echten ersten Auftrag ersetzt. **Alte Spielstände beginnen neu**
    (sie passten nicht mehr zum neuen Ablauf).
  - **Platzhalter:** Alle Texte von Erzähler, Gildenschreiberin, Ye und Schmiedin sind Platzhalter –
    **Marco schreibt die Dialoge der Hauptfiguren noch** (`data/dialoge.json`).
  - Automatischer Test `tests/welt_test.gd` spielt den ganzen Ablauf durch (41 Prüfungen): alles richtig.
  - Namen nach deiner Antwort: Die Gildenschreiberin heißt **Lene**, die Schmiedin **Marta**.

- **Schritt 10 – Kreuzweg-Demo, Grundausbildung** (Schritt 3 aus `KREUZWEG_PLAN.md`, Stufe 2–5):
  - Nach Ye's erstem Auftrag steht er **am Stadttor** (in der Gilde ist er dann nicht mehr).
  - **Vier Lektionen**, jede ein eigener Kampf auf dem Kampfbildschirm, danach geht es zurück in die Stadt:
    1. **Tempo-Leiste** gegen einen Feldschleim (nur „Schlag“),
    2. **Fähigkeiten** (neu: Kraftschlag und Erste Hilfe, Mana und Abklingzeit),
    3. **Parieren** gegen Ye selbst mit Übungsschwert – bestanden nach **zwei perfekten Paraden** („Schild hoch, Schild runter“),
    4. **Zwei Reihen** gegen einen Rüpelkobold (neu: „Nach hinten“).
  - **Erklär-Fenster** („Ye erklärt“) halten den Kampf an, bis du „Verstanden“ antippst. Die Erklärung zum Parieren
    kommt, bevor der erste Schlag losgeht, damit der Ring zum Schlag passt.
  - **Erster Gruppenkampf:** du mit den Novizen **Ida, Bo und Tom** (der Computer steuert sie) gegen vier Kobolde.
  - Du kämpfst als **Novize** (noch keine Klasse, keine Ult): mit jeder Stufe etwas mehr Leben und Mana.
  - Erfahrung gibt es beim **ersten** Sieg jeder Lektion. Verlieren ist nicht schlimm: „Nochmal versuchen“ oder später
    wieder mit Ye reden. „Aufgeben“ oben rechts bringt dich zurück in die Stadt.
  - Am Ende: **Stufe 5**, 75 Gold, 3 Heiltränke. Ye kündigt an, dass in der Stadt bald einiges los ist (Schritt 4: Marv und Bingo).
  - Neue Gegner: Feldschleim, Wiesenkobold, Rüpelkobold (zähmbar wie alle normalen Monster).
  - **Platzhalter:** alle Texte (Ye, Erklärungen, Ida, Bo, Tom); als Hintergrund dient noch das Gewölbe der Sandbox,
    nicht die Wiese vor dem Stadttor.
  - **Tests:** Der Computer hat jede Lektion und den Gruppenkampf je 30-mal gespielt: alles läuft, alles ist für
    Anfänger schaffbar (Zahlen vorläufig). Welt-Test mit der ganzen Grundausbildung und ein Test für den echten Wechsel
    Stadt → Kampf → Stadt: alles richtig. Die 75 Sandbox-Kämpfe laufen unverändert.
  - **Nachbesserung nach deinem Test:**
    - In **Lektion 1 und 2** kann der Novize noch **nicht parieren** (kein Ring). Parieren kommt erst in Lektion 3.
      Ye erklärt dort zusätzlich: Als Novize lernt jeder das Parieren, später hängt es von der Klasse ab
      (manche parieren, manche weichen aus, manche haben keine Reaktion). Auf dem Klassenwahl-Bildschirm (Schritt 8)
      steht das dann bei jeder Klasse.
    - **Zahlentasten am PC:** Vor jedem Knopf im Kampf steht seine Nummer, 1–9 wählen ihn aus (Fähigkeiten, Auswahl,
      „Zurück“). Gilt auch in der Kampf-Sandbox. Am Handy bleiben die Knöpfe ohne Nummer.
    - **Mitstreiter parieren seltener:** Ida, Bo und Tom schaffen eine perfekte Reaktion nur noch in 10 % der Fälle.
    - **Lektion 4:** Die erste Aktion ist „Nach hinten“. Alle anderen Knöpfe sind gesperrt („Erst ‚Nach hinten‘“),
      bis du die Reihe gewechselt hast. Danach ist alles frei. (In `data/kaempfe.json` als `"zuerst": "row"` festgelegt.)

- **Schritt 11 – Kreuzweg-Demo, Marv und Bingos Laden** (Schritt 4 aus `KREUZWEG_PLAN.md`):
  - **Marv** ist erst nach der Grundausbildung in der Stadt (an der Straße zwischen Tor und Marktplatz) und
    **spricht dich von sich aus an**, sobald du vorbeikommst – einmal. Er erzählt begeistert von Kreuzweg-Karten
    und schickt dich zu Bingo. Auftrag „Marvs großer Traum“: bei Bingo nach der Sternentafel fragen, zurück zu Marv.
    Seine Antwort auf 5000 Gold: „Dann spar halt! Ich warte. Ich hab Zeit.“ (der Running Gag beginnt; „Ich hab Zeit“ sagt er nur an dieser einen Stelle).
  - **Handelsherr Bingo** steht vor seinem Laden. **Laden-Fenster:** Heiltrank kaufen (15 Gold), Dinge aus der Tasche
    verkaufen (zur Hälfte des Preises), die **Sternentafel für 5000 Gold** (viel zu teuer: „Zu wenig Gold“).
    Bingo erklärt auf Nachfrage, was die Sternentafel ist.
  - **Heiltränke im Kampf:** Damit sich der Laden lohnt, kann der Novize ab Lektion 4 und im Gruppenkampf Heiltränke
    aus seiner Tasche trinken oder reichen (heilt 35). Getrunkene Tränke fehlen danach in der Tasche, auch bei
    „Nochmal versuchen“.
  - Neue Datendatei `data/laeden.json`. **Platzhalter:** alle Texte von Marv und Bingo, ihr Aussehen.
  - Das Mini-Spiel Kreuzweg-Karten selbst kommt später (laut Plan spielt Marv genau einmal mit).
  - Tests: Welt-Test mit Marv und Bingo (Ansprechen, Kaufen, Verkaufen, zu teuer), Übergangs-Test mit Heiltränken: alles richtig.

- **Schritt 12 – Kreuzweg-Demo, Gesandte der fünf Regionen** (Schritt 5 aus `KREUZWEG_PLAN.md`, Stufe 5–7):
  - **Ye am Tor** steht jetzt links neben der Straße (10,19) und nicht mehr hinter den Bäumen.
  - Nach der Grundausbildung stehen **fünf Gesandte** rund um die Statue der Fünf: Arkanum, Messinghafen, Glutoase,
    Grünwacht und Nebelinseln. Jeder erzählt kurz von seiner Region und bietet **Probestunden** für ihre Klassen an
    (zusammen alle 11 Klassen aus der Sandbox).
  - **Lene** (Schreiberin) vergibt den Auftrag „Die Gesandten der fünf Regionen“: **eine Probestunde ist Pflicht**,
    die anderen sind freiwillig (jede gibt beim ersten Sieg 40 Erfahrung). Abgeben bei Lene: 300 Erfahrung, 50 Gold
    – damit **Stufe 6**, mit allen Probestunden Stufe 7.
  - **Probestunde:** Du spielst die Klasse kurz auf der Übungswiese, **mit Ida und Bo** als Gruppe (sonst sind Tank und
    Support allein kaum spielbar). Die **Ult ist schon zu 60 % voll** – du lädst sie mit der typischen Aktion der Klasse
    auf. Ye erklärt vorher die Klasse (Rolle, Mechanik, Reaktion, Ult) aus den Klassendaten.
  - Gespräche mit vielen Antworten wachsen nach oben, damit sie ins Bild passen. In der Stadt wählen 1–9 Antworten.
  - **Namen der Gesandten** (nach deiner Antwort): Magistra Ilwen (Arkanum), Tüftler Pim (Messinghafen), Feuertänzerin
    Nalia (Glutoase), Fährtenleser Aske (Grünwacht), Schreindienerin Mei (Nebelinseln).
  - **Platzhalter:** alle Texte der Gesandten. Hintergrund im Kampf
    ist noch das Gewölbe.
  - **Tests:** Der Computer hat alle 11 Probestunden je 30-mal gespielt: alle schaffbar (24–43 Züge, alle Figuren
    zusammen). Welt-Test mit Lene, Gesandten und Probestunden: alles richtig.

- **Schritt 13 – Kreuzweg-Demo, Der zugewachsene Weg** (Schritt 6 aus `KREUZWEG_PLAN.md`, Stufe 7–8):
  - Nach den Gesandten bittet **Lene** dich, der Wache am alten Südost-Weg einen **Essenskorb** zu bringen.
  - **Wache Holm** steht am Anfang der zugewachsenen sechsten Straße (hinter der Schmiede). Er freut sich über das
    Essen, aber zum Weg sagt er nur „Befehl der Fünf: Niemand geht da lang“ – und schickt dich weg.
  - Danach hörst du ein leises Singen: **Mira** steht plötzlich da und spricht dich an: **„Hörst du sie auch?“**
    Sie war vor zehn Jahren auch Novize, hustet („Die Lieder werden lauter“) und verabschiedet sich mit einem Hinweis
    auf das **Fest der fünf Wege**. Danach ist sie wieder fort.
  - Belohnung: 200 + 250 Erfahrung = **Stufe 7** (mit allen freiwilligen Probestunden Stufe 8).
  - **Platzhalter:** alle Texte von Lene, Holm und Mira (Mira ist eine Hauptfigur: Marco schreibt ihre Dialoge noch).
  - Der Marktplatz ist inzwischen recht voll (viele Namensschilder dicht beieinander). Das nehme ich mir beim
    Feinschliff (Schritt 9) vor.
  - Test: Welt-Test mit Korb, Wache und Mira: alles richtig.

- **Schritt 14 – Kreuzweg-Demo, Nacht des Sternenfalls** (Schritt 7 aus `KREUZWEG_PLAN.md`, Stufe 8–10):
  - **Aufgeräumt:** Die Gesandten stehen jetzt am Anfang „ihrer“ Straße (Arkanum Norden, Nebelinseln Nordwesten,
    Grünwacht Westen, Messinghafen Osten, Glutoase Süden) statt alle um die Statue. NPCs wippen deutlich ruhiger
    und nicht mehr alle im Gleichtakt.
  - **Fest der fünf Wege:** Lene lädt dich ein („Warum fünf Wege? Es gibt doch sechs Straßen.“ – „Die sechste zählt
    nicht.“). Es wird **Nacht**, auf dem Marktplatz leuchten **fünf Festlaternen** in den Farben der Regionen.
    Die Gesandten sind abgereist.
  - **Marv** spricht dich auf dem Fest an und fragt, ob du die Sternentafel schon hast. Mitten im Satz beginnt der
    **Sternenfall**: greller Lichtblitz, das Bild wackelt, ein Splitter schlägt ein, ein Feldschleim frisst ihn.
  - **Boss „Der Sternenfresser“** (mit Ida, Bo und Tom): Ein **Sternenpanzer** lässt Treffer fast abprallen. Nur eine
    **perfekte Parade** erschüttert ihn für kurze Zeit, dann könnt ihr zuschlagen. Nach **10 Zügen** explodiert
    der Splitter in seinem Bauch. So ist er nur mit mehreren guten Paraden zu schaffen.
    (Computer-Test mit jeder zweiten Parade gelungen: 11 von 30 Siegen – wer gut pariert, schafft es öfter.)
  - **Sieg:** Erfolg **„Schild hoch, Schild runter“** (steht jetzt im Auftragsbuch unter „Erfolge“) – und eine
    Fremde taucht auf, lobt dich und **klaut den Splitter**. **Niederlage:** Alles wird schwarz … dieselbe Fremde
    **rettet die Gruppe**. Ihren Namen nennt sie nicht (Namensschild „???“, sie sagt nur „Niemand. Und du hast mich nie gesehen.“). Im Spiel heißt sie intern weiter Ren.
  - Kein „Nochmal versuchen“ beim Boss: Die Geschichte geht so oder so weiter. Danach: Stufe 8 (Niederlage) bzw. 9 (Sieg).
  - Auf dem Marktplatz bleibt ein **leuchtender Krater**.
  - **Platzhalter:** alle Texte (Lene, Marv, Erzähler, Ye, Ren – Ren ist eine Hauptfigur). Der Kampf spielt noch im Gewölbe.
  - Tests: Welt-Test mit Fest, Sternenfall, Niederlage und Sieg: alles richtig. Sandbox-Kämpfe unverändert.

- **Schritt 15 – Parieren und Ausweichen neu** (überall: Kreuzweg-Demo und Kampf-Sandbox, auch in design.md):
  - Der Balken oben hat jetzt **zwei Zonen**: Die **hellgrüne normale Zone** (etwa eine halbe Sekunde um den Treffer)
    = normal pariert bzw. ausgewichen, **25 % weniger Schaden** („Pariert!“ / „Ausgewichen!“).
    In ihrer Mitte die **schmale grüne Perfekt-Zone** (20 % der Breite, genau wenn der Ring den Kreis erreicht)
    = **PERFEKT**: kein Schaden und die festgelegten Klassen-Effekte (Mana, Klinge, Konter …).
  - Nur **perfekte** Paraden zählen für Lektion 3 und erschüttern den Sternenfresser.
  - Ida, Bo und Tom: 10 % perfekt, 30 % normal.
  - Computer-Test mit einem Spieler, der je 35 % perfekt und normal trifft: Lektionen und Probestunden schaffbar,
    der Sternenfresser in 5 von 30 Fällen (kaum schaffbar, wie geplant).

- **Schritt 16 – Kreuzweg-Demo, Klassenwahl und Abreise** (Schritt 8 aus `KREUZWEG_PLAN.md`):
  - **Morgen danach:** Lene verkündet, dass alle Novizen heute in die Regionen reisen (die Nacht endet,
    die Laternen sind weg, der Krater bleibt). Auftrag „Die Abreise“.
  - **Marv** spricht dich ein letztes Mal an: „Du gehst?! Und unsere Partie Kreuzweg-Karten?“ (ohne „Zeit“, nach deinem Test geändert).
  - **Ye am Tor** öffnet den **Klassenwahl-Bildschirm**: links alle 11 Klassen, rechts Rolle, Region, **Lehrmeister**
    (aus design.md), Mechanik, Reaktion, ein **Fünfeck-Diagramm** (Schaden, Schutz, Heilung, Unterstützung,
    Schwierigkeit), eine **Ult-Vorschau** und die Knöpfe **„Probestunde“** und **„Diese Klasse wählen“**
    (mit Nachfrage). Die Probestunde startet direkt und führt danach zurück zur Klassenwahl.
  - Danach nennt Ye deine Klasse, Region und deinen Lehrmeister („Also Bogenschütze. Dein Weg führt nach Grünwacht,
    zu Pfadmeister Fenn.“). Umentscheiden geht noch. Mit „Leb wohl, Ye.“ kommt der **Abspann** – Ende der Demo.
  - Die **Werte im Diagramm** habe ich selbst geschätzt: **vorläufig, Feinschliff am Ende** (in `data/klassen.json`).
  - Behoben nebenbei: Wurde man mitten im Laufen angesprochen, ging danach das Antippen eines direkt benachbarten NPCs
    manchmal nicht. Und Lene hätte am Morgen sonst noch einmal zum Fest eingeladen.
  - **Platzhalter:** alle Texte (Lene, Marv, Ye, Abspann).
  - Tests: Welt-Test bis zum Abspann, Test des Klassenwahl-Bildschirms (Auswahl, Probestunde, Wahl, Abspann): alles richtig.

- **Schritt 17 – Kreuzweg-Demo, Feinschliff** (Schritt 9 aus `KREUZWEG_PLAN.md`):
  - **Platzhalter-Musik:** vier kleine Retro-Stücke, selbst erzeugt (keine Lizenzfragen): **Stadt**, **Nacht** (Fest,
    Abspann), **Kampf** und **Boss** (sobald ein großer Gegner auftaucht). Sanftes Überblenden beim Wechsel.
    **Taste M** oder der Knopf im Menü schaltet die Musik an und aus (wird gemerkt).
  - **Lautstärke-Regler** (nach deinem Wunsch): im Startmenü unter dem Musik-Knopf und oben links in der Kreuzweg-Demo,
    0–100 % in 5er-Schritten, gilt für alles, was das Spiel abspielt, und wird auf dem Gerät gemerkt.
  - **Kampf vor der Stadt:** Lektionen, Gruppenkampf und Probestunden spielen jetzt auf einer **Wiese vor der
    Stadtmauer von Kreuzweg** (mit Tor, Hügeln, Pollen). Der Sternenfresser kämpft auf dem **Marktplatz bei Nacht**
    (erleuchtete Häuser, die fünf Festlaternen). Sandbox und Pilzhöhle bleiben im Gewölbe.
  - **Marktplatz entzerrt:** NPC-Namen blenden mit der Entfernung aus (nah = voll sichtbar, ab ca. 6 Feldern weg).
    Die Zeichen „!“ und „?“ bleiben immer sichtbar.
  - **Automatischer Durchlauf** (`tests/durchlauf_test.gd`): Ein Computer-Spieler spielt die ganze erste Stunde am
    Stück – mit echten Kämpfen – von der Ankunft bis zum Abspann. Mit fünf verschiedenen Zufallswerten ohne Hänger.
    **Stufenverlauf:** Ankunft 1 → 2, Grundausbildung bis 5, Gesandte 6 (mit allen Probestunden 7), zugewachsener Weg 7,
    Sternenfall 8–9, Abreise 9–10. Passt zum Plan in design.md.
    Der Computer braucht etwa 14 Minuten; wer alles liest, sich umsieht und mehrere Probestunden macht, eher 30–45.
  - **Werte:** Nach dem Durchlauf nichts Großes geändert. Beobachtung: Mit Heiltränken und Stufe 8 schafft der Computer
    den Sternenfresser in der Geschichte öfter (etwa jedes zweite Mal) als ohne Tränke. Dein Eindruck beim Testen
    entscheidet, ob er schwerer werden soll.

- **Schritt 18 – Rückmeldungen aus deinem Test, Teil 1** (Grundwerte, ein langer Lernkampf, Kleinigkeiten):
  - **Die Unbekannte** nennt ihren Namen nicht mehr: „???“ über dem Kopf und im Gespräch („Niemand. Und du hast mich nie gesehen.“).
  - **Marv** sagt „Ich hab Zeit. Ganz viel Zeit.“ nur noch beim ersten Mal. Danach fragt er weiter nach der Sternentafel
    („Ich frag morgen wieder. Und übermorgen.“), auf dem Fest wird er vom Stern unterbrochen, beim Abschied:
    „Aber wehe, du übst da draußen heimlich!“ (Platzhalter.)
  - **Klassenwahl:** keine Zahlen mehr hinter den Werten im Diagramm.
  - **Grundwerte** (neu, Zahlen in `data/stufen.json`, **vorläufig, Feinschliff am Ende**): Leben, Mana, Angriff, Tempo.
    Stufe 1: 45 Leben (vorher 90), 30 Mana, Angriff 20, Tempo 11. Jede Stufe: **Leben +7, Mana +3, Angriff +1**.
    Angriff 20 = normaler Schaden, jeder Punkt mehr = 5 % mehr Schaden **und Heilung** (Stufe 9: 40 % mehr).
    Beim Stufenaufstieg steht, was gewachsen ist. Neues Fenster **„Werte (C)“** in der Stadt erklärt die Grundwerte.
    Ye erklärt sie auch im ersten Kampf. Die sechs Eigenschaften mit freien Punkten (design.md) kommen später mit der Klasse.
  - **Ein langer Lernkampf statt vier einzelner:** „Grundausbildung bei Ye“ hat vier Phasen (Tempo-Leiste → Fähigkeiten →
    Parieren gegen Ye → zwei Reihen). Jede Phase bringt neue Gegner, schaltet neue Fähigkeiten frei und Ye erklärt.
    Dein Leben geht mit in die nächste Phase (ein Viertel wird geheilt). Verlierst du, beginnt „Nochmal versuchen“
    bei der Lektion, in der du verloren hast. 300 Erfahrung beim ersten Sieg.
  - **Schwerer:** Feldschleim, Wiesenkobold und Rüpelkobold schlagen härter, Kobolde haben mehr Leben.
    Der Gruppenkampf hat eine **zweite Welle** (zwei Rüpelkobolde). Messung mit dem Computer-Spieler (pariert die Hälfte):
    Lernkampf 18 von 30 gewonnen, Gruppenkampf 25 von 30, Sternenfresser 8 von 30. Im kompletten Durchlauf hat der
    Computer den Gruppenkampf erst im dritten Versuch geschafft. Probestunden bleiben leicht (zum Ausprobieren).
  - Sandbox unverändert (Vergleich mit 75 Kämpfen: gleich).

- **Schritt 19 – Kampf-Geräusche** (nach deinem Wunsch): Schlag (Luftzug), Wurf/Pfeil/Zauber-Geschoss, Treffer
  (bei kritischen Treffern kräftiger), **Parade** (Klirren), **perfekte Parade** (Klirren mit hellem Dreiklang),
  Ausweichen (Luftzug), Zauber/Fähigkeit (aufsteigender Ton, bei der Ult tiefer) und Heilung (zwei Glockentöne).
  Auch die Paraden von Ida, Bo und Tom sind zu hören. Selbst erzeugt (`tools/sounds_erzeugen.gd`), Platzhalter.
  Der Lautstärke-Regler gilt auch für die Geräusche; Taste M schaltet nur die Musik ab.

- **Schritt 20 – Größere Stadt, Stände, Gesandten-Bildschirm** (Rückmeldungen Teil 3):
  - **Kreuzweg ist viermal so groß** (44 × 44 Felder statt 22 × 22). Runder Marktplatz mit der Statue der Fünf
    (fünf Figuren mit den Farben der Regionen) und einem Brunnen. **Straßen drei Felder breit** mit dunklem Rand,
    damit man sie klar sieht. Zehn zusätzliche Wohnhäuser, Blumen, viel mehr Bäume. Alle Figuren stehen an denselben
    Stellen wie vorher, nur weiter auseinander. Man läuft schneller (5,5 statt 4 Felder pro Sekunde).
  - Nachbesserung nach deinem Test: Das Wohnhaus stand auf dem fünften Weg (Nordwesten) – verschoben. Die Schmiede
    steht jetzt weiter weg von der Wache am sechsten Weg (Marta davor). Zweite Nachbesserung: Schmiede, Wohnhaus und
    ein Haus am Marktplatz verschoben. Jedes Haus hält jetzt mindestens ein Feld Abstand zu Straßen und Marktplatz
    (ein Test prüft das automatisch).
    Nalia (Glutoase) und Aske (Grünwacht) stehen jetzt rechts neben ihrem Stand statt dahinter bzw. davor.
  - **Häuser mit Satteldach** statt Kästen: Fachwerk-Balken, Tür mit Bogen, beleuchtete Fenster, Ziegelreihen, Schornstein.
  - **Stände der Gesandten:** Jeder Gesandte steht am Anfang seiner Straße vor einem kleinen Stand – Tresen,
    gestreiftes Sonnendach mit Bogenkante in der Farbe der Region, Schild mit dem Namen der Region.
    Positionen stehen in `data/kreuzweg.json` unter „staende“.
  - **Gesandten-Bildschirm:** „Zeig mir eure Klassen.“ öffnet denselben Bildschirm wie die Klassenwahl, aber nur
    mit den Klassen der Region (zwei, in der Glutoase drei). Mit Diagramm, Ult-Vorschau und Knopf „Probestunde“;
    „Wählen“ gibt es erst am Tag der Abreise bei Ye. Nach der Probestunde geht es zurück zu diesem Bildschirm.
  - Tests: Welt, Übergang, Klassenwahl (mit Gesandten-Bildschirm), Netz, kompletter Durchlauf: alles richtig.
    Neue Vorführ-Szene `tests/karte_auto.tscn` (Übersicht der Stadt für Bildschirmfotos).

- **Schritt 21 – Neue Figuren und Nebenaufträge** (aus Sitzung 21, „Kreuzweg im Detail“ in design.md):
  - **Nebenaufträge haben ein blaues „!“ und „?“** (Hauptaufträge bleiben gelb). Hat eine Figur beides, gilt das
    gelbe Zeichen der Geschichte. Im Auftragsbuch steht davor **„◆ Nebenauftrag:“** in Blau, die Meldung heißt
    „Neuer Nebenauftrag: …“. Oben bei „Ziel:“ steht immer zuerst die Geschichte; ein Nebenauftrag erscheint dort nur,
    wenn in der Geschichte gerade nichts offen ist, mit „Nebenbei:“ davor.
  - **Neue Figuren:** **Wirtin Hanne** vor dem neuen **Gasthaus „Wegrast“** (an der Weststraße), **Vogt Edmar** am Brunnen,
    **Steinmetz Quill** vor der Statue der Fünf, die Kinder **Pip und Lotte** auf dem Marktplatz (Südwesten).
    **Wache Holm heißt jetzt Torwache Brom** (Name aus Sitzung 21) und sagt „Da geht's nirgendwohin. Befehl ist Befehl.“
  - **Die fünf Nebenaufträge** (jeder bringt nebenbei etwas bei):
    - **Hannes Kater** (Hanne, gleich nach der Anmeldung in der Gilde): Lotte fragen, Kater Brösel in der Gasse neben
      Bingos Laden finden und mit **E / Leertaste / „Reden“** ansprechen. Lernziel: laufen, reden, Aktions-Taste.
    - **Glanz für die Fünf** (Quill, nach Ye's erstem Auftrag): Quill gibt eine **Bürste**. Direkt an der Statue in der
      **Tasche auf „Benutzen“** tippen. Unter dem Moos: die weggemeißelte sechste Zeile („… und der sechs…“).
      Lernziel: Gegenstände benutzen.
    - **Ein Festmahl** (Hanne, nach dem Kater): 3 Wiesenkraut und 2 Wildfleisch auf den Kreuzwegfeldern am Stadtrand
      sammeln. Die Sammelpunkte erscheinen erst mit dem Auftrag. Lernziel: Sammeln.
    - **Fünf Farben** (Edmar, nach dem ersten Gruppenkampf): fünf Festlaternen an die leeren Pfähle rund um den Marktplatz
      hängen (jede in der Farbe ihrer Region, sie leuchten danach auch am Tag). Dann Ye am Tor fragen:
      „Fünf Farben. Schön. … Fehlt nur eine.“ Zurück zu Edmar.
    - **Die Dunkelheit spielen** (Pip, gleich nach der Anmeldung): Du bist die Dunkelheit und verlierst. Danach fragt Lotte:
      „Warum hat die Dunkelheit auf der Statue eigentlich kein Gesicht?“
  - **„Essen für Brom“** aus Sitzung 21 gibt es schon: Das ist der Hauptauftrag „Ein Korb für die Wache“ (Lene schickt dich
    mit dem Essen zu Brom, er erzählt vom Weg, danach kommt Mira). Er bleibt deshalb ein Hauptauftrag mit gelbem Zeichen.
    Siehe offene Fragen.
  - **Noch nicht eingebaut:** die Mitschüler **Tessa und Gorm** (in der Demo heißen die Novizen-Mitstreiter Ida, Bo und Tom;
    siehe offene Fragen) und „Kreuzweg verändert sich mit der Story“ (Akt 2 und 3 gibt es in der Demo noch nicht).
  - **Platzhalter:** alle Texte der neuen Figuren (Stil nach dem Leitfaden „Sprache der Figuren“). Belohnungen (10–20 Gold,
    30–80 Erfahrung, ein Heiltrank beim Festmahl) sind **vorläufig, Feinschliff am Ende**.
  - **Neue Bausteine** (in `data/LIESMICH.md` erklärt): Aufträge mit `"neben": true`, **Orte** zum Benutzen (Kater,
    Laternenpfähle), Gegenstände mit **„Benutzen“** in der Tasche, Sammelpunkte und Ziel-Zeichen mit Bedingung,
    Bedingung „oder“.
  - **Tests:** neuer Teil im Welt-Test (blaues Zeichen, Hauptauftrag geht vor, Kater mit der Aktions-Taste, Bürste weit weg
    und an der Statue, Laternen, Ye erst danach mit „?“). Der Computer-Spieler im **kompletten Durchlauf erledigt jetzt
    auch alle fünf Nebenaufträge** (geschätzte Spielzeit 20–22 statt 18 Minuten). Alle bisherigen Tests laufen weiter,
    auch Netz und Durchlauf zu zweit.
    sie mit. (Im fertigen Spiel ist der erste Abschluss der über den Auftrag.) Auch in design.md eingetragen.

## Fertig in Runde 1

- **Schritt 1 – Kampf-Sandbox:** Alle 11 Klassen, Element-Sechseck, Zähmer mit Monster-Wechsel,
  Mechaniker mit Roboter, sechs Duette und die Kampfauswertung waren schon fertig.
  Angeglichen an design.md: Das Duett **Sternentanz** lässt Zaras Klingen jetzt eine Runde lang
  mit **Sternenkraft** treffen (ignoriert Resistenzen) und gibt +2 Klingen und Resonanz.

- **Schritt 2 – Pilzhöhle:** spielbar in der Sandbox (Auswahl → Gegner „Pilzhöhle“ oder „Pilzhöhle: nur Bosse“).
  Eigene Monster (Leuchtmotte, Wurzelkriecher, Sporenwolf, Glimmerkäfer), Zwischenboss Sporenkönigin
  (pro Kampf zufällig Sporenblüte ODER Sporen-Zwillinge), Wurzelmutter (Rinde heilt, Zwillingsknoten,
  Verschlingen, Wurzelzug) und Vorbote (Dunkelheit, keine Zugleiste, Lichtfraß, Das letzte Licht).
  Alle Mechaniken gehen mit jeder Klasse („Giftwolke vertreiben“, „Laterne entzünden“, „Licht weiterreichen“).
  Automatisch getestet: Wipes, abgewehrtes Verschlingen, Phase 2 und Siege kommen alle vor.

- **Schritt 3 – Kreuzweg-Demo (Gerüst):** Neues Startmenü. Stadt schräg von oben mit Platzhalter-Grafik
  (Marktplatz, Statue der Fünf, Gilde, Bingos Laden, Schmiede, sechs Straßen, die sechste zugewachsen),
  Laufen per Antippen mit Wegsuche um Häuser und Bäume, Ausbilder Ye mit kurzem Gespräch
  (beim zweiten Mal ein anderer Satz), Laterne an der Gildenwand als kleiner Hinweis.
  Spiellogik und Anzeige sind getrennt; ein „Testgefährte“ läuft als zweiter Spieler über dieselben Befehle.

- **Schritt 4 – Web-Export:** Nach jedem Push automatisch neu gebaut und veröffentlicht (alle Läufe erfolgreich).

## Was du testen kannst

Link: **https://cazex-studio.github.io/MiniKampf/** (Handy quer halten). Das Spiel startet jetzt mit einem Menü.

**Neu: Playtest 25.10. Teil 1**
1. Grundausbildung bei Ye, Lektion 3: Hält das Spiel im hellgrünen und dann im grünen Bereich an und erklärt die Paraden? Danach zwei Übungsversuche, ohne dass du angreifst.
2. In jedem Kampf gibt es den Knopf „Abwarten“. Unten rechts stehen Kästchen mit der Passiven deiner Klasse und ob du parieren oder ausweichen kannst.
3. Nimm zwei Nebenaufträge an: Siehst du blaue Wegweiser mit 1 und 2? Hat das Auftragsbuch die Reiter Offen, Abgeschlossen, Erfolge?
4. Zu zweit (Gruppe): Redet jeder in der Stadt für sich? Kämpft die Gruppe beim veränderten Tier zusammen? Im Dungeon seht ihr nur euch.
5. Als Zähmer: Taste R öffnet das Rudel. Mit vollem Gepäck (6) geht ein gezähmtes Monster in den Stall, und das Spiel fragt nach einem Tausch. Kobalt steht im Kampf hinter seinem Monster und schießt mit der Schleuder.

**Neu: Deine Rückmeldungen vom 22.10.** (Kreuzweg-Demo → „Neu beginnen“)
1. Lauf mit WASD, halt zwischendurch an und klick dann irgendwohin: Läuft die Figur direkt los, ohne zurückzuspringen?
2. Halte im Einleitungstext **F** gedrückt: Blättert er schnell durch? Haben bei Lene und Ye die richtigen Antworten ein gelbes ! oder ?
3. Folge dem gelben Pfeil (auch dem am Bildrand): Führt er dich zu Lene, Ye, den Kräutern und später weiter?
4. Nach dem Gruppenkampf (nur noch eine Welle): Kommt Marv angelaufen? In der Wildnis: Laufen die Monster herum,
   und beginnt der Kampf, wenn du eins berührst? Achte auf kritische Treffer (gelbe Zahl auf rotem Stern).
5. Probestunde bei Nalia (Klingentänzerin): Kreisen Schwerter um Zara und treffen sie nach? Beim Sternenfresser:
   Ohne perfekte Parade fällst du sofort.

**Neu: Grünwacht Schritt 11 – Feinschliff** (am besten Grünwacht einmal am Stück spielen)
1. Die Wald-Musik: Passt sie zu Wipfelheim? Hörst du den Unterschied in der Pilzhöhle und nach dem Fällen des Urbaums?
2. Stimmt die Länge? Fühlt sich die Region wie Stufe 15–20 an, oder kommst du zu schnell oder zu langsam voran?

**Neu: Grünwacht Schritt 10 – Nebenaufträge** (blaues Zeichen)
1. Als Zähmer nach dem Dungeon (Pilzhöhle): Will Kobalt eine Revanche? Ist der Kampf gegen sein stärkeres Monster schaffbar?
2. Oma Hagebutte: Gibt sie dir den Auftrag, sobald du eine Sternentafel hast?
3. Der Bienenstock im Südosten des Waldbodens: Findest du ihn? Was ist spannender, Kampf oder Zuhören?

**Neu: Grünwacht Schritt 9 – Kreuzweg-Karten** (nach Grünwacht zurück nach Kreuzweg)
1. Bei Bingo in Kreuzweg: Bekommst du die Sternentafel für 600 Gold?
2. Marv in Wipfelheim: Spielt er einmal mit dir, und hat er danach nur noch Ausreden?
3. Der Spieltisch: Sind die Regeln verständlich? Siehst du gut, welche Karte wem gehört?
4. Oma Hagebutte: Zu schwer, zu leicht? Bekommst du nach Siegen gegen Monster ab und zu Karten?

**Neu: Grünwacht Schritt 8 – Ende der Region** (nach dem Urbaum)
1. Kael und Ysolde vor Dornfeders Halle: Ist die Konfrontation spannend? Fällt die Abstimmung schwer?
2. Der Abspann „Ende von Grünwacht“: Stimmt der Rückblick? Kommst du danach zurück nach Wipfelheim?
3. Blüht Wipfelheim auf (Urbaum gerettet) bzw. liegt welkes Laub (gefällt)?

**Neu: Grünwacht Schritt 7 – Pilzhöhle** (nach Kael, am besten zu zweit oder zu dritt)
1. Findest du den Eingang zwischen den Wurzeln im Süden des Waldbodens? Wirkt die Höhle düster genug?
2. Sporenkönigin und Wurzelmutter: Sind die Mechaniken im Kampf verständlich? Zu schwer, zu leicht?
3. Das Herz des Urbaums: Ist die Entscheidung schwer? Abstimmung in der Gruppe klappt?
4. Geh ein zweites Mal hinein: Sind die Bosse wieder da, und gilt deine erste Entscheidung automatisch?

**Neu: Grünwacht Schritt 6 – Rowans leeres Grab** (nach Kael)
1. Findest du das Grab im Nordwesten des Waldes?
2. Die Erinnerung im Splitter: Wirkt sie? Ist sie zu kurz oder zu lang? (Die Texte schreibst du noch.)
3. Macht Kael danach neugierig auf den Urbaum?

**Neu: Grünwacht Schritt 5 – Leuchtende Tiere und Kael** (jede Klasse, nach dem Gespräch mit Ysolde)
1. Ysolde und Tilda: Werden die beiden Sichtweisen klar?
2. Der Splitter-Rindenbär im Nordosten des Waldes: Ist die Entscheidung spannend? Ist der Kampf zu schwer?
3. „Werte (C)“: Siehst du den Ruf bei Jägern und Zähmern? Ist die Leiste verständlich?
4. Kael: Passt sein Auftritt? Macht er neugierig auf Rowans Grab?

**Neu: Grünwacht Schritt 4 – Esche, Kobalt, Tilda** (als Zähmer, nach dem Gespräch mit Ysolde)
1. Esche: Ist die Wahl der drei Start-Monster klar? Bekommst du die Schleuder?
2. Kobalt: Kommt er gleich angelaufen und nimmt das passende Gegenstück? Ist der Kampf spannend, aber schaffbar?
3. Tilda: Klappt das Zähmen in der Wildnis? Steht das neue Monster danach unter „Werte (C)“ im Rudel und kämpft mit?

**Neu: Grünwacht Schritt 3 – Fenns Prüfung** (als Bogenschütze, nach dem Gespräch mit Ysolde)
1. Hat Fenn ein „!“? Erklärt er die Scheiben gut (hintere Reihe, Bogen spannen)?
2. Findest du den Silberhirsch im Westen des Waldes?
3. Probier beide Entscheidungen aus (vorher speichern geht nicht, also zwei Durchläufe oder zu zweit):
   Passt Fenns Reaktion? Gibt es den Erfolg beim Verschonen?

**Neu: Grünwacht Schritt 2 – Monster und deine Klasse** (nach Schritt 1, auf dem Weg nach Grünwacht)
1. Siehst du die Monster neben dem Weg mit Name und Stufe? Passen die Farben (grau, weiß, orange, rot)?
2. Lauf in eines hinein: Kämpfst du mit deiner Klasse, im Wald-Hintergrund?
3. Nach dem Sieg: Erfahrung und Gold? Ist das Monster eine Minute weg?
4. Steigst du über Stufe 10? Zeigt „Werte (C)“ die Werte deiner Klasse?
5. Sind die Kämpfe zu leicht oder zu schwer? Wie lange dauert es bis Stufe 15?

**Neu: Grünwacht Schritt 1 – die Reise nach Wipfelheim** (Kreuzweg-Demo, mit deinem Spielstand vom Ende der ersten Stunde)
1. Hast du die erste Stunde schon beendet: Steht über Ye am Stadttor ein gelbes „!“? Er gibt dir den Auftrag
   „Der Weg nach Grünwacht“. (Neu gespielt: Nach „Leb wohl, Ye.“ kommt „Ende von Akt 1“ → „Weiter nach Grünwacht“.)
2. Lauf die Weststraße hinaus bis an den Rand: Kommst du auf den Weg nach Grünwacht? Und zurück nach Kreuzweg?
3. Auf dem Weg nach Westen in den Wald, dort zum Seilaufzug auf der Lichtung: Bringt er dich nach Wipfelheim hinauf?
4. In Wipfelheim: Gefallen dir die Plattformen, Brücken und Plätze? Findest du Ysolde, Fenn, Tilda, Esche und den
   Koch-Stand? Spricht Marv dich an der Brücke an?
5. Rede mit Ysolde: Ist der Auftrag erledigt, und fragt sie passend zu deiner Klasse weiter?

**Neu: Figuren und Nebenaufträge aus Sitzung 21** (Kreuzweg-Demo → „Neu beginnen“)
1. Nach der Anmeldung bei Lene: Haben Wirtin Hanne (vor dem Gasthaus Wegrast an der Weststraße) und Pip (Marktplatz)
   ein **blaues „!“**? Ist es gut vom gelben „!“ der Geschichte zu unterscheiden?
2. **Hannes Kater:** Lotte fragen, dann den schwarzen Kater neben Bingos Laden suchen und mit E / „Reden“ ansprechen.
3. **Glanz für die Fünf** bei Quill (vor der Statue): Tasche (I) öffnen, bei der Bürste auf „Benutzen“ tippen –
   erst weit weg (Hinweis), dann direkt an der Statue.
4. **Fünf Farben** bei Edmar (am Brunnen, nach dem ersten Gruppenkampf): Laternen aufhängen, dann zu Ye ans Tor.
5. Auftragsbuch (J): Stehen die Nebenaufträge mit blauem „◆ Nebenauftrag“ da? Ist oben bei „Ziel:“ immer klar,
   was die Geschichte als Nächstes will?

**Neu: Größere Stadt und Gesandten-Stände** (Kreuzweg-Demo → „Neu beginnen“)
1. Lauf einmal durch die Stadt: Ist sie groß genug? Erkennst du die fünf Straßen gut?
2. Gefallen dir die Häuser mit Dach besser als die Kästen von vorher?
3. Wenn die Gesandten da sind: Jeder steht vor einem kleinen Stand an seiner Straße. Sind die Stände klein und hübsch genug?
4. Bei einem Gesandten „Zeig mir eure Klassen.“: Du siehst nur seine Klassen (Glutoase drei, sonst zwei), kannst eine
   Probestunde machen und landest danach wieder dort.
5. Ist das Laufen jetzt zu lang, oder passt es mit dem schnelleren Gehen?

**Neu: Kampf-Geräusche** (irgendein Kampf, Ton an)
1. Greif an: Hörst du einen Luftzug beim Schlag und einen dumpfen Treffer?
2. Parier normal (hellgrünes Feld): Klirren. Perfekt (grüne Mitte): Klirren mit hellem Klang.
3. „Erste Hilfe“: zwei Glockentöne. Eine Fähigkeit der Probestunde: aufsteigender Zauberton.
4. Taste M: Die Musik geht aus, die Geräusche bleiben. Der Lautstärke-Regler macht beides leiser.

**Neu: Grundwerte und langer Lernkampf** (Kreuzweg-Demo → „Neu beginnen“)
1. Oben rechts „Werte (C)“ antippen: Leben 45, Mana 30, Angriff 20, Tempo 11 – mit kurzer Erklärung.
2. Bei Ye am Tor: Die Grundausbildung ist jetzt ein einziger langer Kampf mit vier Lektionen hintereinander.
   Achte darauf, ob Ye zwischendurch gut erklärt, was neu ist.
3. Verlier ruhig mal absichtlich in Lektion 3 oder 4: „Nochmal versuchen“ sollte bei dieser Lektion weitermachen.
4. Fühlen sich die Kämpfe jetzt fordernder an? Besonders der Gruppenkampf mit der zweiten Welle.
5. Die Unbekannte nach dem Sternenfall heißt nur „???“, und Marv sagt „Ganz viel Zeit“ nur beim ersten Mal.

**Neu in Runde 2 – bitte testen** (Kampf-Sandbox)
1. Bogenschütze ins Team nehmen und „Schnellfeuer“ antippen: Drei Pfeile fliegen auf zufällige Gegner.
2. Sternensängerin (heißt jetzt Vega) nehmen, „Polarstern“ auf einen Helden: Er steht danach weiter vorne in der Zugleiste und hat „Abw+“.
3. Monster-Zähmer nehmen, einen Gegner unter die Hälfte seines Lebens bringen, dann „Zähmen“. Klappt es, steht das
   Monster bei „Wechsel“ in der Liste und kämpft für dich.
4. „Pilzhöhle: nur Bosse“ schaffen: Am Ende kommt die Frage, was mit dem Urbaum geschieht (nur beim ersten Mal; zum
   erneuten Testen in der Kreuzweg-Demo „Neu beginnen“ antippen).
5. Kunoichi: Ein einzelnes Siegel lösen lädt die Ult nicht mehr, zwei Siegel auf demselben Gegner lösen (Kombination) schon.
6. Umbau des Kampfes: Spiel einen ganzen Kampf wie gewohnt. Es sollte sich nichts anders anfühlen: Treffer, Zahlen,
   Ring zum Parieren, Wellen und Auswertung wie vorher. Achte darauf, dass die Lebensleiste erst beim Treffer sinkt.

**Neu: Steuerung in der Kreuzweg-Demo** (Menü → „Kreuzweg-Demo“)
1. PC: Mit WASD oder den Pfeiltasten herumlaufen. Läuft die Figur in die richtige Richtung und bleibt an Häusern hängen?
2. PC: Neben Ausbilder Ye stellen und E (oder Leertaste) drücken: Das Gespräch startet, E blättert weiter.
3. Handy (quer): Daumen unten links aufsetzen und ziehen. Der Steuerknopf erscheint unter dem Daumen, die Figur läuft.
4. Handy: Neben Ye „Reden“ unten rechts antippen. Das Gespräch startet.
5. Antippen bzw. Klicken auf den Boden läuft weiterhin dorthin.

**Bausteine der Kreuzweg-Demo:** Gespräche mit Antworten, Auftragsbuch (J), Tasche (I), Stufe oben links, Speichern
(Seite neu laden = Stand bleibt) und „Neu beginnen“ testest du jetzt direkt im Ablauf „Ankunft in Kreuzweg“.

**Neu: Ankunft in Kreuzweg** (Menü → „Kreuzweg-Demo“, vorher einmal „Neu beginnen“)
1. Prüfe, ob der Erzähler die Stadt kurz vorstellt und oben „Ziel: Bei der Gildenschreiberin anmelden“ steht.
2. Zur Gildenschreiberin gehen (das „?“ über ihrem Kopf). Probier beide Antworten aus und lass dich eintragen.
3. Zu Ausbilder Ye gehen (jetzt hat er das „?“). Stell ihm Fragen und nimm danach seinen Auftrag an.
4. Der Schmiedin (südlich der Statue, vor der Schmiede) Bescheid sagen und die drei Kräuter sammeln.
   Prüfe, ob das Ziel oben mitzählt.
5. Bei Ye abgeben: Danach solltest du Stufe 2, 25 Gold und einen Heiltrank haben, und Ye erwähnt die Grundausbildung.

**Neu: Grundausbildung** (Kreuzweg-Demo, nach Ye's erstem Auftrag)
1. Prüfe, ob Ye nach seinem ersten Auftrag am Stadttor (unten, wo du angekommen bist) mit „!“ steht. Sprich ihn an.
2. Lektion 1 und 2 spielen: Erscheinen die Erklär-Fenster, kommt noch KEIN Ring, und geht es danach zurück in die Stadt?
   Am PC: Fähigkeiten mit den Zahlentasten 1, 2, 3 … wählen.
3. Lektion 3: Ye greift an, tippe, wenn der Ring grün wird. Prüfe, ob die Lektion nach zwei Paraden bestanden ist.
4. Lektion 4: Zuerst geht nur „Nach hinten“, die anderen Knöpfe sind gesperrt. Bekommst du hinten weniger Schaden?
5. Gruppenkampf mit Ida, Bo und Tom gewinnen und bei Ye abgeben: Danach solltest du Stufe 5 haben.

**Neu: Marv und Bingo** (Kreuzweg-Demo, nach der Grundausbildung)
1. Vom Stadttor Richtung Marktplatz laufen: Marv sollte dich von selbst ansprechen. Nimm seinen Auftrag an.
2. Zu Handelsherr Bingo (links vor seinem Laden): „Zeig mir deine Waren“. Kauf einen Heiltrank und verkauf etwas.
3. Versuch, die Sternentafel zu kaufen: Es sollte „Zu wenig Gold“ kommen.
4. Bingo nach dem leuchtenden Brett fragen, dann zurück zu Marv und den Auftrag abgeben.
5. Im Gruppenkampf (oder Lektion 4) einen Heiltrank trinken: Danach sollte er in der Tasche fehlen.

**Neu: Gesandte und Probestunden** (Kreuzweg-Demo, nach der Grundausbildung)
1. Am Stadttor nachsehen: Ye steht jetzt links neben der Straße und nicht mehr hinter den Bäumen.
2. Lene hat ein „!“: Sprich mit ihr und nimm den Auftrag an.
3. Geh zu einem der fünf Gesandten rund um die Statue und frag nach der Region. Starte dann eine Probestunde.
4. Prüfe in der Probestunde, ob die Erklärung zur Klasse passt und ob du die Ult (60 % voll) aufladen und benutzen kannst.
5. Danach bei Lene abgeben: Prüfe, ob du jetzt Stufe 6 hast. Probier gern noch weitere Klassen aus.

**Neu: Der zugewachsene Weg** (Kreuzweg-Demo, nach den Gesandten)
1. Prüfe bei einem Gesandten, ob er jetzt einen eigenen Namen hat (z. B. Feuertänzerin Nalia).
2. Lene bittet dich nach den Gesandten um den Essenskorb. Nimm an: Der Korb liegt jetzt in deiner Tasche.
3. Geh zu Wache Holm am Anfang der zugewachsenen Straße hinter der Schmiede, gib ihm den Korb und frag nach dem Weg.
4. Nachdem er dich wegschickt, sollte Mira dich ansprechen: „Hörst du sie auch?“
5. Danach sollte Mira wieder fort sein und du Stufe 7 haben.

**Neu: Nacht des Sternenfalls** (Kreuzweg-Demo, nach Mira)
1. Prüfe, ob die Gesandten jetzt an den fünf Straßen stehen und die NPCs ruhiger stehen.
2. Lene lädt zum Fest ein: Wird es Nacht, und leuchten auf dem Marktplatz fünf Laternen?
3. Geh zum Marktplatz: Marv spricht dich an, dann beginnt der Sternenfall (Lichtblitz) und der Boss-Kampf.
4. Im Kampf: Pariere die Angriffe des Sternenfressers. Erst nach einer perfekten Parade ist er „ERSCHÜTTERT“ und nimmt
   richtig Schaden. Achte auf den Countdown „EXPLOSION in X Zügen“.
5. Danach taucht eine namenlose Fremde auf (Ren; bei Sieg klaut sie den Splitter, bei Niederlage rettet sie euch). Bei Sieg: Auftragsbuch → Erfolge.

**Neu: Parieren mit zwei Zonen** (überall)
1. Lass dich angreifen und tippe früh im hellgrünen Feld: „Pariert!“ (oder „Ausgewichen!“), der Schaden ist kleiner.
2. Tippe genau in die schmale grüne Mitte, wenn der Ring den Kreis erreicht: „PERFEKT!“, kein Schaden, Klassen-Effekt.
3. Lektion 3 bei Ye: Zählen nur die perfekten Paraden?

**Neu: Klassenwahl und Abreise** (Kreuzweg-Demo, nach Ren)
1. Lene ansprechen: Es wird Morgen, die Abreise beginnt. Auf dem Weg zum Tor verabschiedet sich Marv.
2. Bei Ye am Tor die Klassen anzeigen lassen: Passen die Diagramme und die Ult-Vorschau zu den Klassen?
3. Bei einer Klasse auf „Probestunde“ tippen: Danach solltest du wieder auf der Klassenwahl landen.
4. Eine Klasse wählen und bestätigen: Ye sollte Klasse, Region und Lehrmeister nennen.
5. „Leb wohl, Ye.“: Prüfe, ob der Abspann erscheint und „Neu beginnen“ von vorne anfängt.

**Neu: Zusammen spielen, Schritt 1** (am PC in Godot, Anleitung auch in der README)
1. In Godot „Debuggen → Ausführungsinstanzen anpassen…“ öffnen, „Mehrere Instanzen aktivieren“, 2 eintragen, F5.
2. Fenster 1: Menü → „Zusammen spielen“, Name eingeben, Figur mit < > wählen, „Gastgeber werden“.
3. Fenster 2: anderen Namen und andere Figur, Adresse `localhost`, „Beitreten“. Siehst du dich in beiden Fenstern gegenseitig?
4. In einem Fenster laufen (WASD) und mit Lene reden: Läuft die Figur im anderen Fenster mit, und hat jeder seinen eigenen Auftrag?
   Fenster 1 sollte deinen normalen Spielstand haben (wie in der Kreuzweg-Demo), Fenster 2 einen eigenen.
5. Fenster 1 (Gastgeber) → „Menü“: Fenster 2 sollte mit einem Hinweis auf „Zusammen spielen“ zurückkehren.

**Neu: Chat** (Web-Version oder zwei Fenster, „Zusammen spielen“ → Online-Server)
1. Auf zwei Geräten beitreten: Steht im Chat „… ist in Kreuzweg.“?
2. Am PC Enter drücken, etwas schreiben, Enter: Steht es bei beiden im Chat und als Sprechblase über deiner Figur?
3. Am Handy auf „Chat (Enter)“ tippen: Kommt die Tastatur, und ist das Eingabefeld noch zu sehen?
4. Während der Eingabe W, A, S, D tippen: Die Figur sollte stehen bleiben.
5. Ein Gerät schließen: Steht beim anderen „… hat das Spiel verlassen.“?

**Neu: Gruppe bilden** (zwei Geräte, „Zusammen spielen“ → Online-Server)
1. Auf dem einen Gerät den anderen Spieler antippen: Kommt das Menü mit „In Gruppe einladen“?
2. Auf dem anderen Gerät „Annehmen“: Erscheint bei beiden rechts oben das Gruppenfenster, mit ★ beim Einladenden?
3. Sind die Namen der Gruppenmitglieder in der Stadt hellblau?
4. Einer startet einen Kampf (z. B. bei Ye): Steht beim anderen „kämpft gerade“?
5. „Gruppe verlassen“: Verschwindet das Fenster bei beiden (bei zwei Spielern ist die Gruppe dann aufgelöst)?

**Neu: Geschichte gemeinsam** (zwei Geräte, beide „Neu beginnen“, in einer Gruppe)
1. Beide die Einleitung durchklicken und nebeneinander zu Lene gehen. Einer spricht sie an: Ist der andere mit im Gespräch?
2. Bei „Soll ich dich eintragen?“ verschieden wählen: Entscheidet der Gruppenführer (★)?
3. Gleich wählen: Haben danach beide den Auftrag „zu Ye“?
4. Einer ist schon weiter (z. B. schon bei Ye gewesen): Steht bei ihm „Du schaust zu“, und kann er nicht wählen?
5. „Szene verlassen“: Ist man raus, und läuft das Gespräch für den anderen weiter?

**Neu: Gemeinsamer Kampf** (zwei Geräte, in einer Gruppe, beide bis zur Grundausbildung gespielt)
1. Nebeneinander zu Ye ans Tor, einer spricht ihn an, beide wählen beim Gruppenkampf „Wir schaffen das!“.
2. Landen beide im selben Kampf, mit euren Figuren vorne und Ida/Bo als Mitstreiter?
3. Ist beim eigenen Zug oben die Uhr (25 s) zu sehen, und beim anderen „… ist am Zug“?
4. Einmal 25 Sekunden nichts tun: Kommt ein Standardangriff?
5. Einer tippt auf „Aufgeben“: Kämpft der andere weiter?

**Neu: Nacht des Sternenfalls zusammen** (zwei Geräte in einer Gruppe, beide bis zum Fest gespielt)
1. Zusammen zum Marktplatz: Spricht Marv euch beide gemeinsam an?
2. Sehen beide den Sternenfall (Lichtblitz)? Ein drittes Gerät, das nicht auf dem Fest ist, sollte ihn auch sehen.
3. Beide „Los!“: Kämpft ihr zusammen gegen den Sternenfresser? Hat er mehr Leben als allein (300 statt 240)?
4. Einer gibt auf: Wartet er in der Stadt, bis der andere fertig ist, und spricht Ren dann beide zusammen an?

**Neu: Wiederverbinden** (zwei Geräte, Online-Server, in einer Gruppe)
1. Am Handy kurz das WLAN/die mobilen Daten aus- und wieder einschalten: Erscheint „Verbindung weg – verbinde neu …“?
2. Bist du danach wieder in der Stadt, mit deinem Fortschritt?
3. Bist du wieder in der Gruppe (beim anderen: „… ist wieder da.“)?

**Die ganze erste Stunde am Stück** (Kreuzweg-Demo → „Neu beginnen“, Ton an)
1. Spiel einmal von der Ankunft bis zum Abspann durch, ohne Abkürzungen. Notier dir, wo du nicht wusstest, was zu tun ist.
2. Achte auf die Musik: Stadt, Nacht beim Fest, Kampf, Boss beim Sternenfresser. Taste M bzw. Menü-Knopf schaltet sie ab,
   der Regler „Lautstärke“ (Menü und oben links in der Stadt) macht sie leiser oder lauter.
3. Kämpfe vor der Stadt: Wiese mit Stadtmauer im Hintergrund, der Sternenfresser auf dem nächtlichen Marktplatz.
4. Auf dem Marktplatz: Sind die Namen jetzt übersichtlicher (weit entfernte blenden aus)?
5. Gute Fragen dabei: Wie lange hast du gebraucht? War ein Kampf zu leicht oder zu schwer? Welche Stelle war langweilig?



## Vorläufige Werte (Feinschliff am Ende)

Diese Dinge stehen nicht in design.md, ich habe sie selbst gewählt. Sie sind **vorläufig, Feinschliff am Ende**:
Erst wenn alles spielbar ist, werden sie zusammen abgestimmt.

- **Selbst gewählte Passiven:**
  - Mechaniker / Roboter „Wartung“: Solange Fritz lebt, repariert sich der Roboter jeden Zug um 5.
  - Rüstungsschmied: Passende Rüstung fängt 40 % ab, jede Härte (bis 5) noch einmal 6 %.
  - Zwielicht-Wandler: Am Rand der Leiste „überladen“ = 1,6-facher Schaden, aber jeden Zug 8 % Rückstoß.
  - Bank-Boni der Zähmer-Monster: Moosling −15 % Schaden, Glutwelpe +15 % Schaden, Bachotter +5 LP je Zug.
- **Pilzhöhle (alle Zahlen):** Leben und Angriffe der Monster und Bosse, 5 Giftwolken mit je 2 Schaden,
  Sporenknospen heilen 8 %, Verschlingen nach 3 Zügen, Knotenpaar kostet 25 % Leben,
  Dunkelheit in 6 Stufen, Splitterlicht brennt 8, 12, 16 …
- **Neu in Runde 2:** Schnellfeuer (3 × 7), Polarstern (Abwehr+ und 30 % früher dran),
  Zähmen (unter 50 % Leben, Chance = fehlendes Leben, halbes Leben auf der Bank, höchstens 5 Monster).
- **Grünwacht (Schritt 2):** Monster-Werte (Rindenbär, Windfalke, Donnerhirsch, Steinkröte, Sporenling, wilde
  Start-Monster), Stufen-Wachstum (Helden +5 % Stärke, Monster +9 % Leben und +6 % Schaden je Stufe), Erfahrung
  (12 × Stufe je Monster), Geld (seit 27.10.: 1 Bronze + 1 je 5 Stufen pro Monster), eine Minute bis ein Monster wiederkommt, Erfahrungstabelle bis Stufe 20.
- **Stufenabstand:** 6 % weniger Schaden und 8 % härtere Treffer pro Stufe unter dem Gegner, höchstens 5 Stufen.
- **Grünwacht (Schritt 9–11):** Kartenwerte von Kreuzweg-Karten, Kobalts Revanche (zwei Monster, Leben ×1,4),
  Bienenschwarm, Erfahrung der Hauptaufträge (siehe Schritt 11), die drei Wald-Musikstücke.

## Als Nächstes (Vorschläge)

- Deine Rückmeldungen aus dem Test der ersten Stunde am Stück einarbeiten (Schwierigkeit, Länge, unklare Stellen).
- Rückmeldungen zu den neuen Figuren und Nebenaufträgen aus Sitzung 21 (Farbe, Brom, Tessa und Gorm).
- Dialoge der Hauptfiguren: Marco schreibt sie; Platzhalter stehen in `data/dialoge.json`.
- Rückmeldungen zur Pilzhöhle einarbeiten (Schwierigkeit, Zahlen).
- Lernprojekt 4 „Zusammen spielen“ ist gebaut: deine Rückmeldungen aus dem Test mit Freunden einarbeiten.
- Lernprojekt 5 „Grünwacht“: Schritt 1 (Reise nach Wipfelheim) und Schritt 2 (Monster, eigene Klasse, Stufe 20)
  sind eingebaut, ebenso Schritt 3 (Fenns Prüfung), 4 (Esche, Kobalt, Tilda) und 5 (Leuchtende Tiere, Ruf, Kael).
  Schritt 6 (Rowans Grab), 7 (Pilzhöhle), 8 (Ende der Region) und 9 (Kreuzweg-Karten) auch. Schritt 10
  (Nebenaufträge) und 11 (Feinschliff) auch: **Grünwacht ist fertig gebaut.** Als Nächstes testet Marco alles am
  Stück, dann kommen seine Rückmeldungen und die echten Texte.
- Hinten angestellt: Schnellsätze und Emotes (Vorschläge im Ideen-Parkplatz von design.md).

## Offene Fragen an Marco (aufgeräumt 11.11.2026)

### Deine Entscheidungen
- **Feedback-Formular (S1):** Müssen wir noch zusammen erstellen. Sag Bescheid, dann schreibe ich die Fragen und eine Anleitung.
- **Texte:** Die Hauptfiguren schreibst du selbst (`data/LIESMICH.md`). Broms Brief, Lenes Empfehlungsschreiben und die Wache stehen fürs Brainstorming im Google Doc.

### Im Alpha-Test bewerten
- Wipfelheim: Plätze der Leute, und ob Marv dir nachreisen soll.

### Deine Bilder (`Spieldesign/GRAFIK_AUFTRAG.md`, Prompts schicke ich dir auf Nachfrage)
- **Für die Demo:** H (Klassenbilder, A3b), M (Effekte der Dungeons), N (Monster-Geschosse und Abwehr, A10b), O (Innenräume der drei Gasthäuser), P (Dürrewald-Übergänge, A13b), Q (Brief und Empfehlungsschreiben), J (Häuser von hinten), zuletzt I (Sitzen und Laufen, S6).
- **Nach der Demo:** R (Fähigkeiten-Symbole und Körper der sechs späteren Klassen).

### Für die Balancing-Runde E4 gesammelt (kommt später, braucht viele Tests)
- Grünwacht auf Stufe 20–25 heben (man kommt mit etwa 20 aus der Glutoase), Dürrewald mit.
- Kettenschmied allein (schon Phase 1 zu schwer), Zwillinge der Sporenkönigin eher schwer, Kael für den Rüstungsschmied.
- Rüstungsschmied gewinnt selten, Ritualist und Zwielicht allein schwächer, Quartiermeister schwach.
- Glasskorpion-Gruppen in der Palmenrast (50–60 %), Gruppen der Vulkanschmiede allein (51–100 %). Dein Hinweis vom 04.11.: Stärkere Monster dürfen bleiben.

### Nach der Demo
- S4c Stadt-Editor online speichern (für Katie), N1 Server und Konten, N2 Figuren-Bilder auf zwei Drittel (Web-Paket etwa 20 MB kleiner), Monster des Zähmers mit Stufen, Entwicklung und Ei (design.md), Set-Boni, Waffen nur für die eigene Klasse, zufällige Bonus-Werte bei Beute, eigener Körper für Kobalt.

### Erledigt (beim Aufräumen abgehakt)
- Zweimal Mira: Novizen-Köpfe sind namenlos (28.10.).
- Die Stufe zählt mehr (Stufenabstand, 21.10.).
- Heiltränke für alle Klassen: seit A1b (09.11.) heilen sie bei jeder Klasse, jede Klasse hat einen Gürtel.
- Zusammen spielen: alle Entscheidungen getroffen (20.10.).
- Pilzhöhle: Regeln eingebaut, seit A9b2/A9b3 mit Film und Pflicht-Mechanik; Dungeon-Monster haben Karten im Album.
- Sitzung 21: Nebenaufträge blau (nie beanstandet), „Essen für Brom“ ist ein eigener Nebenauftrag, Tessa und Gorm statt Ida, Bo und Tom.
- Plätze in Kreuzweg: mit E3h1 und dem Stadt-Editor neu verteilt.
- „2 Runden“ in der Wildnis: eine Welle und 3 Sekunden Ruhe nach jedem Kampf, seitdem keine Rückmeldung.
- Sporenkönigin mit Mechanik in der Welt, Glutgeist, Namen der Hammerbrüder (E1, 04.11.); Sternensängerin nur weiblich.
- Novizen-Fähigkeiten über die Leiste (A16, so bleibt es), Figuren-Bilder verkleinern nach der Demo (N2).
- Sternenfresser leicht abgeschwächt (11.11., siehe unten).
- Lichter in Kreuzweg: bleiben echte Lichter, keine Leuchtflecken (11.11.).
- Stadt-Editor online speichern (S4c): nach der Demo (11.11.).

## Sternenfresser leicht abgeschwächt (Marco, 11.11.2026)
- Einen ungeblockten Treffer übersteht jeder einmal pro Kampf mit einem Rest Leben („Knapp überlebt!“); erst der zweite ist tödlich. Normal pariert bleibt wie bisher ein Rest Leben.
- Er greift meist (etwa 7 von 10 Einzelangriffen) die Hauptperson an, also echte Spieler statt der Mitstreiter des Computers. So kannst du öfter perfekt parieren und seinen Panzer öffnen.
- Der angekündigte Sternenschlund bleibt streng (nur die perfekte Parade rettet), die Explosion nach 8 Zügen auch.
- Prüfung: `tests/sternenfresser_test.gd`.

**So testest du es**
1. Spiel bis zur Nacht des Sternenfalls und kämpfe gegen den Sternenfresser.
2. Lass einen Treffer absichtlich ohne Parade durch: Du solltest „Knapp überlebt!“ sehen und weiterkämpfen können.
3. Achte darauf, wen er angreift: meistens dich.
4. Pariere perfekt: Der Panzer bekommt Risse, jetzt angreifen.

## A13b Dürrewald: neue Böden und Pflanzen (11.11.2026)
- Vier neue Böden machen den Übergang von der Oase zum Wald weicher: Steppengras, Trockengras, Waldrand und rissige Erde (für den Weg durch die Steppe). Das kräftige Oasengras ist hier weggelassen.
- Neue Teile: dürrer Baum, Steppenbaum (Schirmkrone), erwachender Busch, Grenzstein mit Flamme und Blatt am Weg, versandeter Zaun, umgestürzter Baum mit Moos.
- Im Stadt-Editor sind die Böden und Teile auch einzeln da (Teile beginnen mit „dw_“).

**So testest du es**
1. Reise von der Glutoase durch das Tor in den Dürrewald.
2. Geh den Weg nach Norden: Der Boden sollte von Sand über trockenes Gras bis zum Waldboden fließend übergehen, ohne grelle grüne Flecken.
3. Etwa in der Mitte steht rechts vom Weg der Grenzstein, dort beginnen die ersten Bäume.
4. Schau, ob die Steppenbäume und der Zaun gut auf ihren Feldern stehen.

## Gasthaus Wegrast mit gemalten Innenraum-Teilen (Teil O, IN1 und IN2, 11.11.2026)
- Statt Stadtmauer, Fässern und Holzbänken: Fachwerkwände mit Fenstern und Krugregalen, Eichendielen, roter Teppich, Theke mit Zapfhahn vor Hanne, Fassregal, gemauerter Kamin mit Glut, zwei runde Tische, ein langer Tisch mit Bänken, Treppe, schwarzes Brett, Hocker mit Gemüsekisten.
- Die Teile gibt es auch im Stadt-Editor (beginnen mit „in_wr_“), die Dielen als Boden „Holzdielen“.

**So testest du es**
1. Geh in Kreuzweg ins Gasthaus Wegrast.
2. Schau, ob Hanne hinter der Theke steht und die Gäste nicht in Möbeln stecken (abends auch Marv, Tessa und Gorm).
3. Lauf durch den Raum: Über den Teppich kann man gehen, um Tische und Theke herum.
4. Nachts sollte der Kamin glühen.

## Baumhaus-Gasthaus mit gemalten Innenraum-Teilen (Teil O, IN3 und IN4, 11.11.2026)
- Wurzelwände mit runden Fenstern und Kräuterregal, helle Baumdielen, Mooteppich, Feuerstelle mit Kessel (glüht), Borkos Kochtisch, Kupfertopf, Wurzeltheke, zwei Baumstumpf-Tische, Moosbank, Kräuterständer, Strickleiter.
- Im Stadt-Editor: Teile „in_gw_“, Boden „Baumdielen“.

**So testest du es**
1. Geh in Wipfelheim ins Baumhaus-Gasthaus.
2. Borko steht an seinem Kochtisch, die Gäste stecken nicht in Möbeln.
3. Lauf herum: Über den Mooteppich kann man gehen.

## Glutstube mit gemalten Innenraum-Teilen (Teil O, IN5 und IN6, 11.11.2026)
- Lehmwände mit Nischen, Krügen und Gitterfenster, Tonfliesen, roter Teppich, Lehmtheke vor Layla, Krugregal, Feuergrube mit Braten (glüht), Sitzkreis mit Kissen, Kissenbank, Hadraks Ecke mit Amboss, Laternenständer (leuchten), Palme.
- Damit haben alle drei Gasthäuser gemalte Innenräume (Teil O fertig). Im Stadt-Editor: Teile „in_go_“, Boden „Tonfliesen“.

**So testest du es**
1. Geh in der Glutoase in die Glutstube.
2. Layla steht hinter der Theke, nachts sitzt Hadrak an seinem Amboss.
3. Die Feuergrube und die Laternen leuchten, die Gäste stecken nicht in Möbeln.
