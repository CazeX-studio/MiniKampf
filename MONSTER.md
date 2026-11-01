# MONSTER.md – Regelblatt für alle Monster

> Beschlossen am 30.10.2026 (Sitzung 29, „Monster der Welt“), ergänzt am 01.11.2026 (Sitzung 30, Familien).
> Angelegt am 01.11.2026 als eigene Datei wie `LOOK.md`. Quelle: Brainstorm-Doc „CazeX MMO – Brainstorming“,
> Sitzung 29 und 30. Wo diese Datei und `design.md` (Repo Spieldesign) sich widersprechen, gilt design.md.
> Für das Aussehen gilt zusätzlich `LOOK.md` (Palette, Prüfung, Abnahme per Vergleichsbild).

## Regel für Claude Code

- Ein neues Monster wird **nur mit vollem Steckbrief** gebaut (Teil 2).
- Vor dem Einbau prüft Claude Code es **gegen dieses Regelblatt** (Prüfliste unten) und meldet **jede Abweichung an
  Marco**, statt sie selbst zu entscheiden.

---

## Teil 1: Die Regeln

### 1. Steckbrief

Jedes Monster hat: **Name, Element, Rolle** (Angreifer, Verteidiger, Helfer, Tank), **Stufe, Fähigkeiten** (jede
mit eigener Bewegung und eigenem Effekt), **Beute** (Material, Monsterkarte, selten Ausrüstung), **zähmbar** ja oder
nein, **Tag oder Nacht** (oder Dungeon), **Familie**.

### 2. Wie viele Monster pro Gebiet

- Pro Gebiet **4 Tag-Monster, 2 Nacht-Monster, 1 seltenes.** Dazu bei jeder Art eine **Shiny-Version**, überall gleich
  selten (nur in Sternenfall-Nächten häufiger).
- **Nacht-Monster** (21 bis 6 Uhr nach Server-Zeit) sind eigene Arten, etwas stärker, mit eigener Karte.
- **Dungeons** haben keinen Tag und keine Nacht. Dungeon-Monster gibt es nur dort.
- **Mindestens drei Elemente** pro Gebiet.

### 3. Fähigkeiten

| Art | Anzahl Fähigkeiten |
|---|---|
| Tag-Monster | 2 |
| Nacht-Monster | 3 |
| Seltenes Monster | 4 |
| Dungeon-Monster | 3 |
| Seltenes Monster im Dungeon | 4 |

- Das gilt auch für **gezähmte Monster**: Sie behalten ihre Anzahl und nutzen dieselben Fähigkeiten wie wilde.
- **Ausnahme:** Die drei Start-Monster (Moosling, Glutwelpe, Bachotter) gibt es wild und sehr selten im Wachtwald mit
  ihren 2 Fähigkeiten.
- Jede Fähigkeit nutzt einen **Effekt aus der Effekt-Liste** vom Kampfgefühl (zum Beispiel Brennen, Gift, Lähmen,
  Festhalten, Verfehlen, Zugleiste schieben, Heilen, Schutz, Schattenmale). **Neue Effekte nur mit Marcos Freigabe.**
- **Tag-Monster** haben einen Angriff und eine **Eigenheit**, die zeigt, wie man gegen sie spielt.
- **Lähmen und Festhalten** halten höchstens **eine Runde**. **Herbeirufen** höchstens **einmal pro Kampf**.
- Eine Familie teilt sich die **Grundbewegungen** (Laufen, Treffer, Umfallen). Die **besondere Fähigkeit jeder Art**
  bekommt eine **eigene Bewegung**.

### 4. Elemente

- **Genau ein Element** pro Monster (Feuer, Erde, Pflanze, Blitz, Wasser, Wind, Licht, Schatten, Sternenkraft).
- **Licht** macht direkten Schaden, **Schatten** stapelbaren Schaden über Zeit.
- **Sternenkraft** nur für **Splitter-Monster**; sie ignoriert Resistenzen.
- **Splitter-Monster sind zähmbar, Bosse nicht.**

### 5. Werte nach Rolle und Stufe

| Rolle | Leben | Verteidigung | Angriff | Tempo | Besonders |
|---|---|---|---|---|---|
| Tank | sehr viel | hoch | wenig | langsam | – |
| Verteidiger | mittel | hoch | mittel | mittel | – |
| Angreifer | wenig | niedrig | hoch | schnell | – |
| Helfer | mittel | mittel | wenig | schnell | heilt oder stärkt |

- Alle Werte wachsen mit der Stufe **nach derselben Formel**. Ein Monster der Stufe 15 ist überall gleich stark.
- **Zuschläge:** Nacht-Monster etwa **+15 %**, Dungeon-Monster etwa **+10 %**, seltene „Brocken“ etwa **+50 % Leben**.
- **Ziel:** Ein normaler Kampf gegen eine Tag-Gruppe dauert **3 bis 5 Runden**. Claude Code legt dazu eine Tabelle an
  und prüft sie in der Kampf-Sandbox. Wird bei Bedarf nachgebalanct (Marco, 30.10.).
- Die Tabelle gibt es noch nicht; sie entsteht beim Bau der Monster (Fahrplan Phase 3, Schritt 1.11).

### 6. Aussehen

- **Vier Größen:** klein (Schleim, Käfer, Hase), mittel (Wolf, Echse, Fuchs), groß (Bär, Golem, Sandwurm), Boss
  (deutlich größer als alle anderen). Pixelmaße in `LOOK.md`, Abschnitt 5.
- **Akzentfarbe des Elements** am Körper: Feuer rot-orange, Erde braun, Pflanze grün, Blitz gelb, Wasser blau,
  Wind hell-türkis, Licht gold-weiß, Schatten dunkles Indigo, Sternenkraft lila. Blau in der Anzeige bleibt nur für
  Nebenaufträge, die Akzentfarbe gilt nur am Monster selbst.
- **Feste Merkmale:** Splitter-Monster haben immer **lila Kristalle**. Nacht-Monster haben immer **leuchtende Augen**.
  Seltene Monster haben immer ein **besonderes Merkmal** (Krone, Gold, Leuchten). **Shiny**-Monster sind anders
  gefärbt und funkeln; das macht Claude Code per Umfärben, kein eigenes Bild.
- **Pro Art höchstens ein Zusatzteil** auf dem Grundkörper der Familie.
- Es gelten dieselben Stil-Regeln wie für die Figuren (`LOOK.md`, Palette-Prüfung, Abnahme per Vergleichsbild).

### 7. Familien (ergänzt 01.11.)

- **Jede Familie hat ihren eigenen Grundkörper.** Jede Art darin ist umgefärbt, hat ein kleines Zusatzteil und andere
  Fähigkeiten (Aussehen Variante C).
- In **neuen Gebieten** kommen etwa **5 von 7 Monstern aus vorhandenen Familien** als neue Art.
- Dazu **1 bis 2 neue Familien pro Region**, am besten nur dort; sie dürfen aber woanders auftauchen.
- Bildaufträge: **ein Blatt pro Familie**, zuerst der Grundkörper mit allen Kampfbildern (Stehen, Angreifen,
  Getroffen, Umfallen, dazu die besondere Bewegung jeder Art), dann je Art nur Umfärbung, Zusatzteil und Merkmal.
  Familien mit vielen Arten zuerst. Die Blätter stehen in `Spieldesign/GRAFIK_AUFTRAG.md`.

### 8. Seltene Monster: zwei Arten

- **Flüchter** (Schatzpilzling, Stachelflitzer): kommen immer zuerst dran, sind sehr schwer zu treffen und laufen
  nach drei Runden weg. Sie bringen viel Gold oder Erfahrung.
- **Brocken** (Kronenschleim, Kronhirsch, Wipfelluchs, Splitterbär, Sonnenlöwe, Gewitterwyvern, Messingwächter):
  stark und zäh wie ein kleiner Boss, lassen ein seltenes Material fallen.
- Beide bringen **immer eine besondere Karte.** Nach dem Besiegen dauert es eine Weile, bis das seltene Monster im
  Gebiet wieder auftaucht.
- Für spätere Gebiete dürfen **weitere Arten** seltener Monster dazukommen (Marco, 30.10.). Ideen (nicht beschlossen):
  Verstecker, Wanderer, Geweckte, Gruppen-Seltene.

### 9. Beute (Startwerte, werden im Playtest geprüft)

| Was | Chance |
|---|---|
| Material | fast immer (etwa 7 von 10 Kämpfen) |
| Monsterkarte | Tag-Monster 1 von 30, Nacht- und Dungeon-Monster 1 von 20, seltene Monster immer |
| Ausrüstungsteil | etwa 1 von 50 |
| Shiny | etwa 1 von 500 Begegnungen |

### 10. Sonderregeln

- Am **Rastplatz der Karawanen** in der Aschensteppe greifen **keine Monster** an.
- **Bosse** bekommen eigene Blätter in Boss-Größe und sind nicht zähmbar.

### Prüfliste vor dem Einbau

1. Steckbrief vollständig (alle Punkte aus 1.)?
2. Anzahl Fähigkeiten passt zur Art (Tabelle in 3.)?
3. Jede Fähigkeit nutzt einen Effekt aus der Effekt-Liste? Lähmen/Festhalten höchstens 1 Runde, Herbeirufen 1-mal?
4. Genau ein Element; Sternenkraft nur bei Splitter-Monstern?
5. Werte aus der Formel nach Rolle und Stufe, mit dem richtigen Zuschlag?
6. Aussehen: richtige Größe, Akzentfarbe, Merkmal (Nacht/selten/Splitter), höchstens ein Zusatzteil?
7. Bild mit `tools/look_pruefen.py` geprüft und Vergleichsbild von Marco abgenommen?
8. Beute nach den Startwerten?

---

## Teil 2: Steckbriefe der Demo-Monster (beschlossen 30.10.)

Abkürzungen: **N** = Nacht, **D** = Dungeon, **S** = selten. Bei Familien, die im Steckbrief nicht genannt waren,
steht die Familie aus dem Bildauftrags-Entwurf vom 01.11. (mit „Familie laut Bildauftrag“ markiert).

### Kreuzwegfelder (Stufe 1–8)

Erste Kämpfe und Ye's Lektionen. Alle harmlos, jedes bringt eine Regel bei, alle zähmbar.
Elemente: Wasser, Wind, Erde, Pflanze, nachts Blitz und Feuer.

| Monster | Element, Rolle, Stufe | Familie | Fähigkeiten | Beute |
|---|---|---|---|---|
| Tauschleim | Wasser, Verteidiger, 1–3 | Schleime (Gruß an den Poring aus Ragnarok) | Platsch (hüpft auf das Ziel, kleiner Wasserspritzer); Zusammenziehen (wird flach und hart, mehr Verteidigung) | Schleimklecks |
| Wiesenhoppler | Wind, Angreifer, 2–5 | Hasen | Doppelsprung (zwei schnelle Tritte, zwei Zahlen); Haken schlagen (springt zur Seite, weicht dem nächsten Angriff eher aus). Bringt bei: Tempo und Zugleiste | weiches Fell |
| Knollenkäfer | Erde, Verteidiger, 3–6 | Käfer | Einrollen (rollt sich zur Kugel, viel Verteidigung); Zwicken (senkt kurz die Verteidigung des Ziels). Bringt bei: Feuer und Wind sind stark gegen Erde | Käferpanzer |
| Löwenzahnling | Pflanze, Helfer, 4–7 | Blütenwesen | Samenflug (heilt ein anderes Monster); Pollenwolke (Ziel verfehlt eher). Bringt bei: Helfer zuerst besiegen | Pusteblumensamen |
| Funkenflirr **N** | Blitz, Angreifer, 4–7 | Schwärme (Glühwürmchen) | Schwarmtanz (viele kleine Treffer); Funkenschlag (kann kurz lähmen); Kettenfunke (springt auf einen zweiten Gegner über) | Leuchtstaub |
| Glutigel **N** | Feuer, Verteidiger, 5–8 | Igel | Stachelball (rollt los und rammt); Glutstacheln (wer ihn im Nahkampf trifft, verbrennt sich); Glutnest (vordere Reihe brennt zwei Runden). Bringt bei: aufpassen, wen man im Nahkampf angreift | glühender Stachel |
| Kronenschleim **S** | Wasser, Tank, 8 | Schleime (König der Porings) | Großer Platsch (landet auf der ganzen vorderen Reihe); Schleimruf (ruft einen Tauschleim); Königlicher Befehl (alle Schleime rücken auf der Zugleiste vor); Kronenwurf (Krone als Bumerang, trifft beide Reihen) | Schleimkrone (Kopfbedeckung, nur Aussehen), mehr Erfahrung, besondere Karte |

### Hirschtal (Straße nach Grünwacht, Stufe 5–12)

Waldrand mit Bächen und einer Jägerhütte. Elemente: Erde, Pflanze, Wasser, Wind, nachts Wind und Licht.

| Monster | Element, Rolle, Stufe | Familie | Fähigkeiten | Beute |
|---|---|---|---|---|
| Borstenkeiler | Erde, Tank, 6–10 | Wildschweine | Ansturm (Ziel rutscht auf der Zugleiste nach hinten); Suhlen (mehr Verteidigung, etwas Heilung) | Borsten |
| Dornenranke | Pflanze, Verteidiger, 5–9 | Ranken | Umschlingen (hält ein Ziel eine Runde fest); Dornenpeitsche (lässt kurz bluten) | Dornenzweig |
| Bachkrebs | Wasser, Verteidiger, 6–10 | Krabben | Scherenschnapp (kneift zweimal); Panzer hoch (nächster Treffer schwächer) | Krebsschere |
| Zankelster | Wind, Angreifer, 7–11 | Vögel | Sturzflug (trifft auch die hintere Reihe); Diebischer Schnabel (stiehlt ein paar Bronze, zurück beim Sieg) | schillernde Feder |
| Heulwolf **N** | Wind, Angreifer, 9–12 | Wölfe | Biss; Heulen (ruft einen zweiten Heulwolf, einmal pro Kampf); Rudeljagd (greift das Ziel mit dem wenigsten Leben an, mehr Schaden) | Wolfspelz |
| Irrlicht **N** | Licht, Helfer, 8–12 | Geister | Irreführen (Ziel verfehlt eher); Lichtfunke (heilt ein anderes Monster); Erlöschen (eine Runde nicht zu treffen) | Irrlichtfunke |
| Kronhirsch **S** | Wind, Tank, 12 | Hirsche (Familie laut Bildauftrag) | Geweihstoß (wuchtiger Stoß); Röhren (alle Gegner machen weniger Schaden); Sprung über die Reihe (trifft die hintere Reihe); Waldsegen (heilt sich) | Kronhirsch-Geweih (seltenes Material), besondere Karte |

### Wachtwald (Heimat-Gebiet Grünwacht, Stufe 10–20)

Lichter Wald mit Jägerpfaden unter Wipfelheim. Elemente: Pflanze, Wind, Erde, nachts Schatten und Blitz.

| Monster | Element, Rolle, Stufe | Familie | Fähigkeiten | Beute |
|---|---|---|---|---|
| Rindenbär | Pflanze, Tank, 12–18 | Bären | Prankenhieb (schwerer Schlag); Borkenhaut (mehr Verteidigung, jede Runde etwas Heilung) | Borkenstück |
| Windfalke | Wind, Angreifer, 10–15 | Vögel | Krallenstoß (zwei schnelle Treffer); Aufwind (kommt auf der Zugleiste früher dran) | Falkenfeder |
| Steinkröte | Erde, Verteidiger, 11–16 | Kröten | Zungenschlag (zieht ein Ziel aus der hinteren Reihe nach vorn); Steinhaut (viel Verteidigung) | Krötenstein |
| Sporenling | Pflanze, Helfer, 10–14 | Pilze | Giftsporen (drei Runden vergiftet); Sporenregen (heilt die anderen Monster ein wenig) | Sporenkappe |
| Nachtuhu **N** | Schatten, Helfer, 14–19 | Vögel | Lautloser Flug (eine Runde schwerer zu treffen); Starrblick (Ziel rutscht auf der Zugleiste nach hinten); Nachtruf (alle Monster werden stärker) | Eulenfeder |
| Funkenmarder **N** | Blitz, Angreifer, 15–20 | Marder | Flinker Biss (zwei Treffer); Funkenfell (Nahkampf-Angreifer kann kurz gelähmt werden); Fluchtsprung (springt in die hintere Reihe, weicht eher aus) | knisterndes Fell |
| Wipfelluchs **S** | Wind, Angreifer, 18 | Katzen (Familie laut Bildauftrag) | Ansprung aus dem Wipfel (auf die hintere Reihe); Krallenwirbel (drei schnelle Treffer); Tarnen (eine Runde im Laub verschwunden); Luchsblick (nächster Angriff sicher kritisch) | Luchsohr (seltenes Material), besondere Karte |
| Moosling, Glutwelpe, Bachotter | Pflanze / Feuer / Wasser | Start-Monster | wild und sehr selten, als Ausnahme mit 2 Fähigkeiten (man bekommt sie auch bei Esche) | – |

### Tiefwurzel (Wildes Land Grünwacht, Stufe 20–25)

Dunkler Wald über der Pilzhöhle. Hier zeigen sich die ersten Splitter-Monster (zähmbar).
Elemente: Blitz, Wasser, Erde, Pflanze, nachts Sternenkraft und Schatten.

| Monster | Element, Rolle, Stufe | Familie | Fähigkeiten | Beute |
|---|---|---|---|---|
| Donnerhirsch | Blitz, Angreifer, 20–24 | Hirsche | Blitzgeweih (kann kurz lähmen); Galopp (trampelt über die ganze vordere Reihe) | Donnergeweih-Splitter |
| Sumpfschnapper | Wasser, Tank, 20–23 | Schildkröten | Schnappbiss (hält eine Runde fest); Panzerrückzug (viel Verteidigung) | Schildpatt |
| Moosgolem | Erde, Verteidiger, 21–25 | Golems | Felshieb (schwerer Schlag); Moospolster (heilt sich langsam) | Moosstein |
| Rankenschlinger | Pflanze, Helfer, 20–24 | Ranken (große Schwester der Dornenranke) | Fesselranke (hält ein Ziel fest); Saftheilung (heilt ein anderes Monster) | zäher Rankenstrang |
| Splitterwolf **N** | Sternenkraft, Angreifer, 22–25 | Wölfe (lila Splitter auf dem Rücken) | Sternenbiss (ignoriert Resistenzen); Splitterheulen (ruft einen zweiten Splitterwolf, einmal pro Kampf); Leuchtende Augen (Ziel verfehlt eher) | Splitterstaub |
| Moderfalter **N** | Schatten, Helfer, 21–25 | Falter | Schattenstaub (Schaden über Zeit, stapelbar); Flatterschleier (schwerer zu treffen); Lähmstaub (Ziel rutscht auf der Zugleiste nach hinten) | Falterschuppen |
| Splitterbär **S** | Sternenkraft, Tank, 25 | Bären (Familie laut Bildauftrag) | Splitterkruste (viel Verteidigung); Prankenbeben (trifft die vordere Reihe); Sternenwut (stärker, je weniger Leben); Splitterregen (Kristalle auf alle Gegner) | großer Splitterkristall (seltenes Material), besondere Karte |

### Pilzhöhle (Dungeon Grünwacht, etwa Stufe 25)

Bosse und Licht-Mechanik bleiben, wie sie sind. Elemente: Licht, Erde, Pflanze, Blitz.

| Monster | Element, Rolle | Familie | Fähigkeiten | Beute |
|---|---|---|---|---|
| Leuchtmotte **D** | Licht, Helfer | Falter (laut Bildauftrag) | Blendflügel (Ziel verfehlt eher); Lichtfraß (Lichtkreis um ein Ziel schrumpft); Mottenheilung (heilt ein anderes Monster) | Leuchtschuppen |
| Wurzelkriecher **D** | Erde, Verteidiger | Würmer (laut Bildauftrag) | Wurzelgriff (hält eine Runde fest); Durch den Boden (taucht in der hinteren Reihe der Spieler auf); Rindenpanzer (mehr Verteidigung) | Wurzelknolle |
| Sporenwolf **D** | Pflanze, Angreifer | Wölfe (Pilze im Fell) | Rudelbiss (stärker, je mehr Sporenwölfe im Kampf); Sporenwolke (vergiftet die vordere Reihe); Hetzjagd (greift das Ziel mit dem wenigsten Leben an) | Pilzfell |
| Glimmerkäfer **D** | Blitz, Angreifer | Käfer (frisst Splitterstaub) | Aufladen (nächster Angriff stärker); Entladung (Blitz trifft zwei Ziele); Glimmerpanzer (wer ihn trifft, bekommt einen kleinen Schlag) | Glimmerflügel |
| Schatzpilzling **S D** | Pflanze, Flüchter, 25 | Pilze (laut Bildauftrag) | Flitzen (immer zuerst dran); Verstecken (sehr schwer zu treffen); Schreckwolke (alle kurz verwirrt); Weglaufen (nach drei Runden) | viel Gold, seltenes Material, besondere Karte |

### Aschensteppe (Straße zur Glutoase, Stufe 5–12)

Grasland, das nach Süden zur Wüste wird; am Rastplatz der Karawanen greifen keine Monster an.
Elemente: Erde, Blitz, Wind, Pflanze, nachts Feuer und Schatten, selten Licht.

| Monster | Element, Rolle, Stufe | Familie | Fähigkeiten | Beute |
|---|---|---|---|---|
| Steppenhyäne | Erde, Angreifer, 6–10 | Hyänen | Lachender Biss (mehr Schaden unter halbem Leben); Kichern (andere Monster kommen früher dran) | struppiges Fell |
| Funkenechse | Blitz, Angreifer, 7–11 | Echsen | Funkenzunge (kann kurz lähmen); Sonnenbad (nächster Angriff stärker) | Echsenschuppe |
| Steppenroller | Wind, Verteidiger, 5–9 | Ranken (lebendiger Dornenbusch) | Rollangriff (rollt durch die ganze vordere Reihe); Dornenkleid (Nahkampf-Angreifer piekst sich) | Trockenzweig |
| Kaktusling | Pflanze, Helfer, 6–10 | Blütenwesen | Wasserspeicher (heilt ein anderes Monster); Stachelsalve (trifft die hintere Reihe) | Kaktusblüte |
| Aschefuchs **N** | Feuer, Angreifer, 9–12 | Füchse | Glutbiss (Ziel brennt zwei Runden); Flammenschweif (trifft zwei Ziele); Rauchsprung (eine Runde schwerer zu treffen) | Aschefell |
| Schattenskarabäus **N** | Schatten, Verteidiger, 8–12 | Käfer | Dunkelstich (Schaden über Zeit, stapelbar); Eingraben (viel Verteidigung); Kugelrollen (Ziel rutscht auf der Zugleiste nach hinten) | schwarzer Panzer |
| Sonnenlöwe **S** | Licht, Angreifer, 12 | Katzen (laut Bildauftrag) | Brüllen (alle Gegner machen weniger Schaden); Sonnenmähne (Ziel verfehlt eher); Löwensprung (auf die hintere Reihe); Mittagsglut (trifft alle Gegner) | Sonnenmähne (seltenes Material), besondere Karte |

### Palmenrast (Heimat-Gebiet Glutoase, Stufe 10–20)

Wüste mit Palmen, Dünen und Wasserstellen unter der Terrassenstadt.
Elemente: Erde, Feuer, Blitz, Wasser, nachts Wind und Schatten, selten Pflanze.

| Monster | Element, Rolle, Stufe | Familie | Fähigkeiten | Beute |
|---|---|---|---|---|
| Sandwurm | Erde, Tank, 14–20 | Würmer | Abtauchen (taucht in der hinteren Reihe wieder auf); Sandschlund (hält eine Runde fest, macht Schaden) | Wurmhaut |
| Feuerechse | Feuer, Angreifer, 10–15 | Echsen | Feueratem (trifft die ganze vordere Reihe); Schwanzpeitsche (Ziel rutscht auf der Zugleiste nach hinten) | Feuerschuppe |
| Glasskorpion | Blitz, Angreifer, 12–17 | Skorpione | Blitzstachel (kann kurz lähmen); Glaspanzer (nächster Treffer viel schwächer, dann splittert der Panzer) | Blitzglas |
| Oasenkröte | Wasser, Helfer, 10–14 | Kröten | Quellregen (heilt alle Monster ein wenig); Schlammspucke (Ziel wird langsamer) | Oasenschleim |
| Staubgeist **N** | Wind, Helfer, 15–20 | Geister | Sandsturm (trifft alle, sie verfehlen eher); Wirbelwind (Ziel rutscht auf der Zugleiste nach hinten); Geisterheulen (alle Gegner machen weniger Schaden) | Geisterstaub |
| Mondschakal **N** | Schatten, Angreifer, 16–20 | Wölfe | Schattenbiss (Schaden über Zeit, stapelbar); Mondheulen (ruft einen zweiten Mondschakal, einmal pro Kampf); Lauern (nächster Angriff sicher kritisch) | Schakalfell |
| Stachelflitzer **S** | Pflanze, Flüchter, 18 | Blütenwesen (laut Bildauftrag), eigenes Aussehen: kleiner runder Kaktus mit Blüte auf dem Kopf, flitzt auf Wurzelbeinchen (Anspielung auf Final Fantasy X) | Flitzen (immer zuerst dran); Ausweichen (sehr schwer zu treffen); Tausend Stacheln (immer derselbe feste Schaden); Davonsausen (nach drei Runden) | Stachelflitzer-Blüte, viel Erfahrung, besondere Karte |

### Glutgrat (Wildes Land Glutoase, Stufe 15–20)

Erkaltete Lava, Felsgrate, heiße Quellen; über den freien Bergpfad erreichbar.
Elemente: Erde, Feuer, Wind, Wasser, nachts Feuer und Schatten, selten Blitz.

| Monster | Element, Rolle, Stufe | Familie | Fähigkeiten | Beute |
|---|---|---|---|---|
| Schlackenbock | Erde, Tank, 16–20 | Böcke | Felssprung (auf die hintere Reihe); Steinfell (mehr Verteidigung) | Lavahorn |
| Glutsalamander | Feuer, Angreifer, 15–19 | Echsen | Feuerschwanz (trifft zwei Ziele, sie brennen); Lavabad (heilt sich) | Salamanderhaut |
| Rauchgeier | Wind, Angreifer, 16–20 | Vögel | Rauchschwinge (alle Gegner verfehlen eher); Krallengriff (packt ein Ziel aus der hinteren Reihe, hält eine Runde fest) | Rußfeder |
| Geysirkrabbe | Wasser, Helfer, 15–18 | Krabben | Heiße Quelle (heilt ein anderes Monster); Dampfstoß (vordere Reihe verfehlt eher) | Quellstein |
| Glutfledermaus **N** | Feuer, Angreifer, 17–20 | Fledermäuse | Funkenflug (trifft die hintere Reihe); Hitzeschrei (Ziel kommt später dran); Glutbiss (stiehlt etwas Leben) | Glutflügel |
| Obsidiangolem **N** | Schatten, Tank, 18–20 | Golems | Schattenhieb (Schaden über Zeit, stapelbar); Spiegelglas (wirft einen Teil des Schadens zurück); Erstarren (viel Verteidigung, kommt später dran) | Obsidian |
| Gewitterwyvern **S** | Blitz, Angreifer, 20 | Wyvern | Aschegewitter (Blitze auf alle, können lähmen); Sturzangriff (trifft die hintere Reihe); Donnerschrei (alle Gegner kommen später dran); Aufladen (jede Runde stärker, bis er sich entlädt) | Wyvernschuppe (seltenes Material), besondere Karte |

### Vulkanschmiede der Ketten (Dungeon Glutoase, Stufe 15–20)

Viele Fähigkeiten spielen mit dem Lava-Takt. Mit Wasser und Wind ist man hier stark.
Elemente: Erde, Feuer, Wind, selten Blitz.

| Monster | Element, Rolle | Familie | Fähigkeiten (die erste ist die Eigenheit aus Sitzung 24) | Beute |
|---|---|---|---|---|
| Schlackenkriecher **D** | Erde, Verteidiger | Schnecken (laut Bildauftrag) | Schlackenpanzer (in der Lava-Runde härter); Kriechbiss (Ziel wird langsamer); Schlackenwurf (auf die hintere Reihe) | Schlackenbrocken |
| Glutgeist **D** | Feuer, Angreifer | Geister (laut Bildauftrag) | Letzte Glut (explodiert beim Tod, trifft seine Reihe); Flammenstoß (Ziel brennt); Aufglühen (jede Runde etwas stärker) | Glutkern |
| Ambossknecht **D** | Erde, Tank | Automaten (laut Bildauftrag) | Hammerschlag (langsam und hart); Ambossstand (fängt Treffer für ein anderes Monster ab); Dampf ablassen (vordere Reihe verfehlt eher) | alte Zahnräder |
| Aschefalter **D** | Wind, Helfer | Falter (laut Bildauftrag) | Glutstaub (Brennen hält länger); Aschewirbel (alle Gegner verfehlen eher); Aufwind (ein anderes Monster kommt früher dran) | Ascheschuppen |
| Magmaschnecke **D** | Feuer, Helfer | Schnecken (laut Bildauftrag) | Magmaheilung (heilt andere Monster, solange die Lava oben ist); Lavaspur (vordere Reihe brennt zwei Runden); Ins Haus (viel Verteidigung, setzt eine Runde aus) | Magmaschleim |
| Messingwächter **S D** | Blitz, Tank, 20 | Automaten (laut Bildauftrag), Probe-Automat von Hadrak | Funkenschlag (kann lähmen); Überladung (trifft alle, danach eine Runde Pause); Schutzschild (fängt Treffer für ein anderes Monster ab); Ersatzteile (heilt sich, einmal pro Kampf) | Messingzahnrad (seltenes Material), besondere Karte |

### Bosse der Demo (eigene Blätter, Boss-Größe, nicht zähmbar)

Sternenfresser (Festnacht in Kreuzweg), Sporenkönigin, Wurzelmutter und Vorbote (Pilzhöhle, wie gebaut),
Hammerbrüder (zwei große Ambossknechte), Kettenschmied (Phase 1 und 2). Mechaniken stehen in design.md.

---

## Teil 3: Familien der Demo

31 Familien mit 60 Arten (Stand Bildauftrags-Entwurf 01.11.). Je Art: Element-Akzentfarbe, Zusatzteil, Merkmal.

| Familie | Größe, Grundkörper | Arten |
|---|---|---|
| Schleime | klein, runder weicher Tropfen mit großen Augen | Tauschleim (Tautropfen auf dem Kopf), Kronenschleim S (groß, goldene Krone) |
| Hasen | klein, rund mit langen Ohren | Wiesenhoppler (Kleeblatt am Ohr) |
| Käfer | klein, runder Panzer, kurze Beine | Knollenkäfer (Panzer wie eine Kartoffel), Schattenskarabäus N (schwarzer Panzer, Sandkugel), Glimmerkäfer D (leuchtende Flügeldecken) |
| Blütenwesen | klein, Pflanzenkörper auf Wurzelbeinchen | Löwenzahnling (Pusteblumen-Kopf), Kaktusling (Kaktuskörper mit Blüte), Stachelflitzer S (runder Kaktus mit Blüte) |
| Schwärme | klein, Wolke aus vielen kleinen Tieren | Funkenflirr N (Glühwürmchen) |
| Igel | klein, rund mit Stacheln | Glutigel N (glühende Stachelspitzen) |
| Wildschweine | mittel, kräftig mit Hauern | Borstenkeiler (Schlamm auf dem Rücken) |
| Ranken | mittel, Rankenknäuel mit Blattmaul | Dornenranke (Dornen), Rankenschlinger (größer, lange Fangranken), Steppenroller (trockener Dornenbusch als Kugel) |
| Krabben | klein, Panzer mit zwei Scheren | Bachkrebs (Bachsteine auf dem Panzer), Geysirkrabbe (Dampf aus dem Panzer) |
| Vögel | mittel, Körper mit großen Flügeln | Zankelster (glänzendes Ding im Schnabel), Windfalke (Falkenmaske), Rauchgeier (Rußfedern), Nachtuhu N (große runde Augen) |
| Wölfe | mittel, schlanker Wolf | Heulwolf N (Mähne im Wind), Splitterwolf N (lila Kristalle), Mondschakal N (Mondsichel im Fell), Sporenwolf D (Pilze im Fell) |
| Geister | mittel, schwebende Gestalt ohne Beine | Irrlicht N (kleine Flamme), Staubgeist N (Körper aus Sand), Glutgeist D (Körper aus Glut) |
| Hirsche | groß, Hirsch mit Geweih | Donnerhirsch (Geweih mit Blitzen), Kronhirsch S (riesiges Geweih) |
| Bären | groß, schwerer Bär | Rindenbär (Rinde auf dem Rücken), Splitterbär S (lila Kristalle) |
| Kröten | klein, dicke Kröte | Steinkröte (Steinhaut), Oasenkröte (Seerosenblatt auf dem Kopf) |
| Pilze | klein, Pilz mit Gesicht | Sporenling (Sporenwolke), Schatzpilzling S (Goldmünzen auf dem Hut) |
| Marder | klein, schlanker Marder | Funkenmarder N (knisterndes Fell) |
| Katzen | mittel bis groß, Raubkatze | Wipfelluchs S (Pinselohren), Sonnenlöwe S (leuchtende Mähne) |
| Schildkröten | mittel, hoher Panzer | Sumpfschnapper (Schlamm und Algen) |
| Golems | groß, Körper aus Steinblöcken | Moosgolem (Moos), Obsidiangolem N (schwarzes Glas) |
| Falter | klein, großer Flügel-Körper | Moderfalter N (dunkle Flügel), Leuchtmotte D (leuchtende Flügel), Aschefalter D (aschegraue Flügel mit Glut) |
| Würmer | groß, langer Wurm aus dem Boden | Sandwurm, Wurzelkriecher D (kleiner, mit Rinde) |
| Hyänen | mittel | Steppenhyäne (struppige Mähne) |
| Echsen | mittel, Echse mit Schwanz | Funkenechse, Feuerechse (größer), Glutsalamander (glühende Flecken) |
| Füchse | mittel, buschiger Schwanz | Aschefuchs N (Rauch am Schwanz) |
| Skorpione | mittel | Glasskorpion (durchsichtiger Glaspanzer) |
| Fledermäuse | klein | Glutfledermaus N (glühende Flügelränder) |
| Böcke | mittel, Steinbock | Schlackenbock (Hörner aus Lavastein) |
| Wyvern | groß, Flügel und Schwanz | Gewitterwyvern S (Blitze an den Flügeln) |
| Automaten | mittel bis groß, Schmiede-Automat aus Metall | Ambossknecht D (Amboss als Kopf), Messingwächter S D (Messing mit Funken) |
| Schnecken | klein bis mittel, Schnecke mit Haus | Magmaschnecke D (Haus aus Lava), Schlackenkriecher D (Haus aus Schlacke) |
| Start-Monster | gibt es schon | Moosling, Glutwelpe, Bachotter |

**Spätere Regionen (Vorschlag Claude 01.11., nicht beschlossen):** Die Monster aus Sitzung 21 passen fast alle in
vorhandene Familien: Messinghafen Schrottgolem (Golems), Kesselkrabbe (Krabben), Ölschleim (Schleime), Hafenmöwe
(Vögel); Arkanum Tintenschleim (Schleime), Funkenkonstrukt (Automaten), Schattenfalter (Falter), Lichtgeist
(Geister), Buchgolem (Golems); Nebelinseln Kitsune (Füchse), Kappa (Schildkröten), Tengu (Vögel), Kodama
(Blütenwesen), Raijū (Marder). Neu wäre nur die Funkenspinne (Familie Spinnen). Plätze für Familien mit nur einer
Art: Igel und Hasen auf Wiesen, Hyänen und Skorpione im Dürrewald, Fledermäuse in Höhlen und den Turmruinen, Böcke
an den Schwebsteinhängen, Wyvern bei der Wolkenbahn, Schwärme im Kupfermoor, Wildschweine an der Kirschküste.

---

## Teil 4: Abweichungen zum Spiel (gemeldet an Marco, 01.11.)

Beim Anlegen gegen das Spiel geprüft. Nichts davon ist geändert, Marco entscheidet.

1. **Kreuzwegfelder:** Im Spiel kämpft man dort gegen **Wiesenkobold, Kieselkobold, Rüpelkobold und Feldschleim**
   (Bilder in `assets/figuren/`). Die beschlossenen Steckbriefe nennen Tauschleim, Wiesenhoppler, Knollenkäfer,
   Löwenzahnling usw. Die Kobolde (Beschluss 28.10.) stehen in keinem Steckbrief. **Entschieden (Marco, 01.11.):** Die Kobolde bleiben im Spiel,
   bekommen aber später einen anderen Platz. Auf den Kreuzwegfeldern stehen jetzt die Monster aus den Steckbriefen.
2. **Familien ohne Angabe im Steckbrief:** Bei Kronhirsch, Wipfelluchs, Splitterbär, Leuchtmotte, Wurzelkriecher,
   Schatzpilzling, Sonnenlöwe, Stachelflitzer und den Vulkanschmiede-Monstern stammt die Familie aus dem
   Bildauftrags-Entwurf vom 01.11. (oben markiert). Bitte bestätigen.
3. **Werte-Tabelle** nach Rolle und Stufe fehlt noch (Regel 5); sie entsteht beim Bau der Monster.
4. Die **Pilzhöhlen-Monster** und viele Gegner im Spiel nutzen noch Platzhalter-Bilder aus einem fremden Paket
   (`assets/0x72_dungeontileset_ii`), sie bekommen ihre Bilder über die Familien-Blätter.
