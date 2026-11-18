"""Prompts für die sechs Welt-Blätter der Hauptfiguren (GRAFIK_AUFTRAG.md Teil U2b, wie bei Kael 16.11.2026).

Je Figur ein ChatGPT-Chat, Reihenfolge: Gehen schräg von vorne (erstes Blatt), von vorne, von der Seite, schräg von
hinten, von hinten, dann Stehen und Sitzen. Anhänge je Nachricht: haupt_<figur>_welt.png (tools/referenz/teil_u/)
und die Posen-Vorlage posen_<m|w>_gehen_<richtung>.png bzw. posen_<m|w>_stehen_sitzen.png.
Ergebnis: tools/referenz/teil_u/hauptfiguren_prompts.json ({figur: {g, blaetter: [[blatt, prompt], …]}}).
Aufruf: python3 tools/hauptfiguren_prompts.py [figur …]
"""
import json
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
ZIEL = WURZEL / "tools" / "referenz" / "teil_u" / "hauptfiguren_prompts.json"

## Figur -> Name, Geschlecht (Posen-Vorlage), Aussehen, was in der Welt mit Waffe/Gegenstand passiert, Rücken
FIGUREN = {
	"ysolde": dict(n="Ysolde", g="w",
		d="junge Elfe, lange, wellige hellblonde Haare zu einem hohen Pferdeschwanz gebunden, Federn und Blätter im Haar, braune Augen, dunkelgrünes Halstuch, Schulterumhang aus hellen Federn, dunkelgrüner, zerfranster Umhang mit Goldranken am Saum, braune Lederrüstung mit Gürtel und Lederschurz, braune Handschuhe und Stiefel, Köcher mit Pfeilen auf dem Rücken",
		hand="Ysolde hat in der Welt KEINEN Bogen und KEINEN Pfeil in der Hand, die Hände sind leer; der Köcher bleibt auf dem Rücken.",
		rueck="Hinterkopf mit dem hohen hellblonden Pferdeschwanz, den Federn und dem kleinen Zopf, KEIN Gesicht, der Köcher mit Pfeilen, der Federumhang und der grüne Umhang über dem Rücken",
		waffe="kein Bogen in der Hand"),
	"fenn": dict(n="Fenn", g="m",
		d="junger Mann, strubbelige dunkelbraune Haare, braune Augen, dunkelgrüne Kapuze mit goldener Rankenborte, dunkelgrünes Tuch über Mund und Nase, Schulterkragen aus hellen Federn, dunkelgrüner, zerfranster Umhang, braune Lederrüstung mit gekreuzten Gurten und Gürtel, braune Armschienen, Handschuhe und Stiefel, Köcher mit Pfeilen auf dem Rücken",
		hand="Fenn hat in der Welt KEINEN Bogen und KEINEN Pfeil in der Hand, die Hände sind leer; der Köcher bleibt auf dem Rücken.",
		rueck="die grüne Kapuze von hinten mit ein paar Haarsträhnen, KEIN Gesicht, der Köcher mit Pfeilen, der Federkragen und der grüne Umhang über dem Rücken",
		waffe="kein Bogen in der Hand"),
	"tilda": dict(n="Tilda", g="w",
		d="junge Frau, lange, wilde rotbraune Haare zu einem hohen Pferdeschwanz, grünes Stirnband mit kleinen Federn, braune Augen, dicker heller Fellkragen und Fellbesatz, grün-braune Lederkleidung mit Gürtel und Gürteltaschen, Fellstulpen an den Beinen, braune Stiefel, ein Wanderstab aus Holz mit Spiralkopf und Federn",
		hand="Tilda hat in der Welt den Stab NICHT in der Hand, die Hände sind leer; der Stab ist schräg auf dem Rücken festgeschnallt.",
		rueck="Hinterkopf mit dem wilden rotbraunen Pferdeschwanz und den Enden des grünen Stirnbands, KEIN Gesicht, der helle Fellkragen, der Stab schräg auf dem Rücken, die Gürteltaschen",
		waffe="kein Stab in der Hand"),
	"esche": dict(n="Esche", g="m",
		d="Junge mit wuscheligen braunen Locken und grünen Blättern im Haar, runde Brille, grüne Augen, dunkelgrüner Schal, helles Hemd, braune Weste, dunkelgrüner Mantel mit Goldranken am Saum, viele kleine Ledertaschen am Gürtel, Rucksack mit Schriftrollen auf dem Rücken, braune Handschuhe und Stiefel",
		hand="Esche hat beim Gehen KEIN Buch und KEINE Lupe in der Hand, die Hände sind leer; das Buch steckt im Rucksack, die Lupe hängt an einer Schnur am Gürtel.",
		rueck="Hinterkopf mit den wuscheligen braunen Locken und den Blättern, KEIN Gesicht, der Rucksack mit den Schriftrollen und der grüne Mantel über dem Rücken",
		waffe="kein Buch und keine Lupe in der Hand"),
	# Kreuzweg
	"ye": dict(n="Ye", g="m",
		d="junger Mann, schwarzbraune, zerzauste Haare zu einem kleinen Zopf mit rotbraunem Band gebunden, müde halb geschlossene graue Augen, roter Schal, langer abgetragener graubrauner Mantel mit Flicken und ausgefranstem Saum, helles Hemd, dunkelbraune Hose, braune Stiefel, ein geschlossener dunkelvioletter Schirm",
		hand="Ye hat in der Welt den Schirm NICHT in der Hand, die Hände sind leer; der geschlossene Schirm ist schräg auf dem Rücken festgeschnallt.",
		rueck="Hinterkopf mit den zerzausten schwarzbraunen Haaren und dem kleinen Zopf mit Band, KEIN Gesicht, der rote Schal, der geflickte Mantel und der geschlossene Schirm schräg auf dem Rücken",
		waffe="kein Schirm in der Hand"),
	"bingo": dict(n="Bingo", g="m",
		d="kräftiger Mann, volle wellige braune Haare, großer gezwirbelter Schnurrbart, braune Augen, prächtiger rotbrauner Mantel mit Goldmustern und dickem hellem Fellkragen, weißes Rüschenhalstuch, braune Weste, ein Bündel Goldmünzen am Gürtel, ein goldener Ring, dunkle Hose, braune Stiefel",
		hand="Bingo hat beim Gehen nichts in der Hand, die Hände sind leer; die Goldmünzen hängen am Gürtel.",
		rueck="Hinterkopf mit den vollen welligen braunen Haaren, KEIN Gesicht, der dicke helle Fellkragen und der rotbraune Mantel mit Goldmustern über dem Rücken",
		waffe="nichts in den Händen"),
	"marv": dict(n="Marv", g="m",
		d="junger Mann, wilde, abstehende rotbraune Haare, Fliegerbrille auf der Stirn, braune Augen, fröhliches freches Gesicht, rotes Halstuch mit wehenden Enden, helles Hemd mit hochgekrempelten Ärmeln, braune Lederweste mit Gurten und Gürtel, Gürteltaschen, braune Handschuhe, dunkle Hose, braune Stiefel",
		hand="Marv hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="Hinterkopf mit den wilden rotbraunen Haaren und dem Band der Fliegerbrille, KEIN Gesicht, das rote Halstuch, die Lederweste mit Gurten und die Gürteltaschen",
		waffe="nichts in den Händen"),
	"mira": dict(n="Mira", g="w",
		d="zarte, blasse junge Frau, sehr lange, wellige hellblonde Haare mit einem Flechtkranz, goldene Sternspangen und eine rotbraune Schleife im Haar, braune Augen, stilles sanftes Gesicht, braunes Schultertuch mit Fransen, helles langes Kleid mit kleinen goldenen Sternen, braune Stiefel",
		hand="Mira hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="Hinterkopf mit den sehr langen welligen hellblonden Haaren, dem Flechtkranz, den goldenen Sternspangen und der Schleife, KEIN Gesicht, das braune Schultertuch und das helle Sternenkleid",
		waffe="nichts in den Händen"),
	# Glutoase
	"hadrak": dict(n="Hadrak", g="m",
		d="kleiner, sehr breiter, kräftiger Mann, rotbraune Haare zu einem hohen Zopf gebunden, langer geflochtener rotbrauner Bart, buschige Brauen, grimmiger Blick, Narbe auf der Stirn, schwere Eisenkette über der Schulter, helles Hemd mit hochgekrempelten Ärmeln, braune Lederschürze mit Flammenzeichen, breiter Gürtel mit Taschen, rotes Tuch am Gürtel, dicke Lederhandschuhe, schwere braune Stiefel, ein großer Steinhammer",
		hand="Hadrak hat in der Welt den Hammer NICHT in der Hand, die Hände sind leer; der Hammer ist mit dem Stiel nach unten auf dem Rücken festgeschnallt, die Kette bleibt über der Schulter.",
		rueck="Hinterkopf mit dem hohen rotbraunen Zopf, KEIN Gesicht, die Eisenkette über der Schulter, der Hammer auf dem Rücken, die Schürzenbänder, der Gürtel mit Taschen und das rote Tuch",
		waffe="kein Hammer in der Hand"),
	"brakkus": dict(n="Brakkus", g="m",
		d="kleiner, sehr breiter, kräftiger Mann, wilde schwarzbraune Haare zu einem Zopf, Fliegerbrille auf der Stirn, dichter schwarzer Bart mit grauen Strähnen, buschige Brauen, grimmiger Blick, helles Hemd mit hochgekrempelten Ärmeln, dunkle Lederschürze mit Flammenzeichen und gekreuzten Trägern, breiter Gürtel mit Werkzeugtaschen, rotes Tuch am Gürtel, dicke Lederhandschuhe, schwere braune Stiefel, ein großer Schmiedehammer",
		hand="Brakkus hat in der Welt den Hammer NICHT in der Hand, die Hände sind leer; der Hammer ist mit dem Stiel nach unten auf dem Rücken festgeschnallt.",
		rueck="Hinterkopf mit dem schwarzbraunen Zopf und dem Band der Fliegerbrille, KEIN Gesicht, die gekreuzten Schürzenträger, der Hammer auf dem Rücken, der Gürtel mit Werkzeugtaschen und das rote Tuch",
		waffe="kein Hammer in der Hand"),
	"samira": dict(n="Samira", g="w",
		d="junge Frau mit gebräunter Haut, langer wilder schwarzbrauner Mähne zu einem hohen Pferdeschwanz, rote Haarbänder, goldener Stirnreif, goldene Ohrringe, braune Augen, entschlossener Blick, kurzes rot-goldenes Oberteil, goldener Halsschmuck, Armreifen und Armschienen, weite orangerote Pluderhose mit hellem Tuch und Goldborten, braune Stiefel, zwei gebogene Dolche",
		hand="Samira hat in der Welt KEINE Dolche in den Händen, die Hände sind leer; beide Dolche stecken in Scheiden links und rechts am Gürtel.",
		rueck="Hinterkopf mit der wilden schwarzbraunen Mähne, dem hohen Pferdeschwanz und den roten Haarbändern, KEIN Gesicht, der nackte Rücken mit den Bändern des Oberteils, die beiden Dolche in Scheiden am Gürtel, die weite Pluderhose",
		waffe="keine Dolche in den Händen"),
	"xavina": dict(n="Xavina", g="w",
		d="junge Frau, sehr lange, wellige kastanienbraune Haare, hochgesteckt mit goldenem Haarkranz und orangen Blüten, goldener Stirnschmuck, goldene Ohrringe, braune Augen, sanftes Lächeln, langes rot-goldenes Kleid mit weiten hellen Ärmeln, Goldborten und Sternmuster, eine kleine goldene Harfe",
		hand="Xavina hat beim Gehen die Harfe NICHT in der Hand, die Hände sind leer; die kleine Harfe hängt an einem Riemen auf dem Rücken.",
		rueck="Hinterkopf mit den sehr langen kastanienbraunen Haaren, dem goldenen Haarkranz und den orangen Blüten, KEIN Gesicht, die kleine Harfe an einem Riemen auf dem Rücken, das lange rot-goldene Kleid",
		waffe="keine Harfe in der Hand"),
	# Übrige Hauptfiguren (18.11.): Vorlage ist ein sauberes Blatt aus den Spielbildern (tools/referenz/teil_u/haupt_<figur>_welt.png)
	"ren": dict(n="Ren", g="w",
		d="junge Kunoichi, lange wilde dunkelbraune Haare zu einem hohen Pferdeschwanz, große rosa Kirschblüte und rosa Bänder im Haar, braune Augen, dunkles Tuch über Mund und Nase, langer rosa Schal mit Blütenmuster, kurzes helles Gewand mit rosa Blüten, dunkle Armschienen, rosa Schärpe mit goldenem Knoten, dunkle Pluderhose, umwickelte braune Stiefel",
		hand="Ren hat in der Welt KEINE Waffe in der Hand, die Hände sind leer.",
		rueck="Hinterkopf mit dem hohen dunkelbraunen Pferdeschwanz, der Kirschblüte und den rosa Bändern, KEIN Gesicht, der lange rosa Schal und die Schärpe mit Knoten",
		waffe="keine Waffe in der Hand"),
	"zaid": dict(n="Zaid", g="m",
		d="kräftiger Händler mit dunkler Haut, schwarzer Vollbart, braune Augen, freundliches Lächeln, goldener Ohrring, heller Turban mit rotem Band und goldenem Juwel, helles Hemd mit goldenen Knöpfen, rotbraune Jacke, breiter Gürtel mit Ledertasche, langer senfgelber Reiseumhang mit Kapuze und roten Streifen am Saum, dunkle Hose, braune Stiefel",
		hand="Zaid hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="Hinterkopf mit dem hellen Turban und den herabhängenden Enden des roten Bands, KEIN Gesicht, der lange senfgelbe Umhang mit Kapuze und roten Streifen über dem Rücken",
		waffe="nichts in den Händen"),
	"hagebutte": dict(n="Oma Hagebutte", g="w",
		koerper="Alte Frau: klein und rundlich, leicht gebeugter Rücken, kurze gemütliche Schritte, die Füße heben nur wenig vom Boden ab.",
		d="kleine, rundliche alte Frau, weiße lockige Haare, grünes Kopftuch mit roten Hagebutten, runde Brille, freundliches faltiges Lächeln, dicke olivgrüne Strickjacke mit großen Knöpfen und Taschen, braunes langes Kleid, braune Schuhe",
		hand="Oma Hagebutte hat beim Gehen nichts in der Hand, die Hände sind leer; der Kartenstapel steckt in der Jackentasche.",
		rueck="Hinterkopf mit den weißen Locken und dem grünen Kopftuch mit Hagebutten, KEIN Gesicht, die dicke olivgrüne Strickjacke und das braune Kleid",
		waffe="nichts in den Händen"),
	"hatta": dict(n="Hatta", g="m",
		d="Hutmacher, braune lockige Haare, kleiner Schnurrbart, braune Augen, riesiger rotbrauner Zylinder mit bunten Flicken, rotem Hutband, weißen und roten Federn, goldener Rosette und einer Garnspule mit Nadeln, helles Hemd, weinrote Weste, gelbes Maßband um den Hals, brauner Gürtel, dunkle Hose, braune Stiefel",
		hand="Hatta hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="der riesige Zylinder mit Flicken, Federn und Garnspule von hinten über den braunen Locken, KEIN Gesicht, die weinrote Weste mit Gürtel und das gelbe Maßband",
		waffe="nichts in den Händen"),
	"ilse": dict(n="Bankhüterin Ilse", g="w",
		koerper="Alte Frau: klein, leicht gebeugter Rücken, kurze ruhige Schritte, die Füße heben nur wenig vom Boden ab.",
		d="kleine alte Frau, graue Haare zu einem Dutt mit goldener Haarnadel, runde Brille, freundliches Gesicht, lange pflaumenfarbene Robe mit hellem Kragen und hellen Ärmelschonern, ein goldener Schlüsselbund am Gürtel, dunkle Schuhe",
		hand="Ilse hat in der Welt nichts in der Hand, die Hände sind leer; der Schlüsselbund hängt am Gürtel.",
		rueck="Hinterkopf mit dem grauen Dutt und der goldenen Haarnadel, KEIN Gesicht, der helle Kragen und die pflaumenfarbene Robe",
		waffe="nichts in den Händen"),
	"edmar": dict(n="Vogt Edmar", g="m",
		d="kräftiger Mann, volle wellige braune Haare mit einer weißen Strähne, Vollbart und großer Schnurrbart, braune Augen, goldene Amtskette mit rundem Abzeichen, breite Festschärpe in fünf Farben quer über der Brust, helles Hemd, braune Weste, goldener Gürtel, braune Handschuhe, dunkle Hose, braune Stiefel",
		hand="Edmar hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="Hinterkopf mit den vollen welligen braunen Haaren und der weißen Strähne, KEIN Gesicht, die goldene Amtskette am Nacken, die bunte Festschärpe quer über dem Rücken, die braune Weste",
		waffe="nichts in den Händen"),
	"ilwen": dict(n="Ilwen", g="w",
		d="junge Frau, sehr lange silberweiße Haare, hochgesteckt mit einem goldenen Stern mit blauem Stein und einer dunkelblauen Schleife, dunkelblaue Augen, ernstes ruhiges Gesicht, langer dunkelblauer Mantel mit Goldmustern und Kragen, helles Kleid darunter, brauner Gürtel, dunkle Stiefel",
		hand="Ilwen hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="Hinterkopf mit den langen silberweißen Haaren, dem Haarknoten, dem goldenen Stern und der blauen Schleife, KEIN Gesicht, der lange dunkelblaue Mantel mit Goldmustern",
		waffe="nichts in den Händen"),
	"pim": dict(n="Pim", g="m",
		d="Junge, wilde strubbelige braune Haare, große Messing-Fliegerbrille auf der Stirn, braune Augen, fröhliches Gesicht, rotes Halstuch, helles Hemd mit hochgekrempelten Ärmeln, braune Latzhose mit gekreuzten Trägern, Gürtel mit Werkzeugtaschen und einem Zahnrad, braune Handschuhe, braune Stiefel",
		hand="Pim hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="Hinterkopf mit den strubbeligen braunen Haaren und dem Band der Fliegerbrille, KEIN Gesicht, der Knoten des roten Halstuchs, die gekreuzten Träger und der Gürtel mit Taschen und Zahnrad",
		waffe="nichts in den Händen"),
	"nalia": dict(n="Nalia", g="w",
		d="junge Frau, sehr lange wilde dunkelbraune Locken, rotes Kopftuch mit goldenen Münzen, rotes Stirnjuwel, goldene Ohrringe, braune Augen, fröhliches Lächeln, kurzes orangerotes Oberteil, goldene Armreifen, Münzgürtel, weiter orange-heller Rock mit Quasten, braune Sandalen",
		hand="Nalia hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="Hinterkopf mit den sehr langen wilden dunkelbraunen Locken und dem Knoten des roten Kopftuchs, KEIN Gesicht, die Bänder des Oberteils, der Münzgürtel und der weite Rock",
		waffe="nichts in den Händen"),
	"aske": dict(n="Aske", g="m",
		d="Junge, braune Haare, grüne Augen, ernster Blick, spitze dunkelgrüne Kapuze mit goldener Borte, einer hellen Feder und einer goldenen Brosche, dunkelgrüner Schal, Umhang aus grünen Blättern, helles Hemd mit grünem Rand, brauner Gürtel und Schultergurt mit Umhängetasche, braune Handschuhe, braune Stiefel",
		hand="Aske hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="die spitze grüne Kapuze von hinten mit Feder und Brosche, KEIN Gesicht, der Umhang aus grünen Blättern, der Schultergurt und die Umhängetasche",
		waffe="nichts in den Händen"),
	"mei": dict(n="Mei", g="w",
		d="junges Mädchen, lange dunkelbraune Haare mit einem Dutt, rosa Kirschblüten, roter Schleife und goldenen Haarnadeln mit Quasten, braune Augen, sanftes Lächeln, helles Gewand mit weiten Ärmeln und rosa Blütenmuster, rote Schärpe mit Schleife, roter Faltenrock, braune Sandalen",
		hand="Mei hat in der Welt nichts in der Hand, die Hände sind leer.",
		rueck="Hinterkopf mit den langen dunkelbraunen Haaren, dem Dutt, den Kirschblüten, der roten Schleife und den Haarnadeln, KEIN Gesicht, die weiten Ärmel, die Schleife der Schärpe und der rote Faltenrock",
		waffe="nichts in den Händen"),
}
WEIBLICH = ("Weibliche Figur: schmale Schultern, deutliche Taille, breitere Hüfte, schlanke Arme und Beine, kleinere Hände "
	"und Füße. Die Füße setzen beim Gehen fast auf einer Linie auf, die Hüfte wiegt leicht mit. Haltung leicht und "
	"anmutig, nicht breitbeinig.")
RICHTUNGEN = {
	"schraeg_vorne": ("schräg von vorne", "Gehen SCHRÄG VON VORNE. Die Figur schaut und läuft nach links unten, Gesicht UND Körper zeigen nach links unten. Ihre linke Seite ist dem Betrachter zugewandt."),
	"vorne": ("von vorne", "Gehen VON VORNE. Die Figur läuft gerade auf den Betrachter zu, man sieht die Brust und das ganze Gesicht. Ihr rechter Arm und ihr rechtes Bein sind im Bild LINKS."),
	"seite": ("von der Seite", "Gehen VON DER SEITE. Die Figur schaut und läuft genau nach links, im Profil (ein Auge sichtbar). Ihre linke Seite ist dem Betrachter zugewandt."),
	"schraeg_hinten": ("schräg von hinten", "Gehen SCHRÄG VON HINTEN. Die Figur läuft nach links oben, man sieht den Rücken schräg und vom Gesicht nur ein Stück Wange und Ohr. Ihre linke Seite ist dem Betrachter zugewandt."),
	"hinten": ("von hinten", "Gehen VON HINTEN. Die Figur läuft gerade vom Betrachter weg, man sieht den ganzen Rücken. Ihr rechter Arm und ihr rechtes Bein sind im Bild RECHTS."),
}
PUPPE = ("Sie gilt Feld für Feld: Male in jedes Feld die Figur genau in der Pose der Puppe in diesem Feld, gleich groß "
	"und an derselben Stelle. Rot = RECHTES Bein und RECHTER Arm der Figur, Blau = LINKES Bein und LINKER Arm (dunkles "
	"Rot oder Blau = diese Seite ist vom Betrachter abgewandt).")


def gehen(key, f, erstes):
	name, satz = RICHTUNGEN[key]
	hinten = "hinten" in key
	if hinten:
		satz += f" Man sieht nur den RÜCKEN, so wie in haupt_{f['key']}_welt.png in der unteren Reihe: {f['rueck']}."
	weiblich = f"\n- {f.get('koerper', WEIBLICH)}" if f["g"] == "w" else ""
	gesicht = "" if hinten else ", das Gesicht ist in jedem Bild dasselbe"
	pruef = "von hinten ist kein Gesicht zu sehen" if hinten else "das Gesicht ist in jedem Bild dasselbe"
	return f"""{"" if erstes else "Neues Blatt, gleiche Figur wie eben: "}Welt-Blatt „{f['n']}, Gehen {name}“ für Asterfall. Aufbau wie bei den Spieler-Figuren in Ragnarok Online: Gehen mit 8 Bildern je Richtung (nur Aufbau und Gangart als Vorbild, nichts abmalen).

ZWEI ANHÄNGE
1. haupt_{f['key']}_welt.png = die FIGUR {f['n']} ({f['d']}). Übernimm Gesicht, Haare, Kleidung, Farben, Größe und den Malstil exakt{"" if erstes else ", genau wie im Blatt eben"}. Oben in der Vorlage sieht man die Figur von vorne, unten von hinten.
2. posen_{f['g']}_gehen_{key}.png = die POSEN-VORLAGE mit 8 Gliederpuppen. {PUPPE} Jeder Fuß der Figur steht genau dort, wo der Fuß der Puppe steht, jedes Knie ist so gebeugt wie bei der Puppe, jeder Arm schwingt wie bei der Puppe. Die Puppen selbst und ihre Farben Rot, Blau, Grau kommen NICHT ins Bild. Bei der Puppe ist der Kopf ein grünes Oval, bei {f['n']} bleibt der echte Kopf.

FORMAT
- Querformat 3:2, Hintergrund einfarbig reines Pink (#FF00FF), kein Verlauf, kein Bodenschatten, keine Schrift, keine Linien.
- 2 Reihen, je 4 Felder, gleiche Plätze wie in der Vorlage, nichts berührt sich. Oben Bild 1 bis 4, unten Bild 5 bis 8.
- Die Figur ist in allen 8 Bildern gleich groß und gleich angezogen{gesicht}, nur die Beine und Arme bewegen sich.
- Blick von schräg oben wie in der Vorlage, Licht von links oben, klare dunkle Umrisslinie.{weiblich}

RICHTUNG: {satz}

GANGART: ruhiges Gehen, kein Rennen. Körper aufrecht, kleine Schritte, immer ein Fuß am Boden, die Arme schwingen leicht gegengleich zum Bein. {f['hand']} Umhang und Haare wehen nur wenig. Ein Doppelschritt als Schleife:
Bild 1: rechtes Bein setzt vorne auf, linkes Bein hinten.
Bild 2: Gewicht geht aufs rechte Bein.
Bild 3: rechtes Bein steht gerade, linkes Bein schwingt gebeugt durch (Knie angehoben).
Bild 4: linkes Bein kommt nach vorne.
Bild 5: linkes Bein setzt vorne auf, rechtes Bein hinten.
Bild 6: Gewicht geht aufs linke Bein.
Bild 7: linkes Bein steht gerade, rechtes Bein schwingt gebeugt durch (Knie angehoben).
Bild 8: rechtes Bein kommt nach vorne, geht nahtlos in Bild 1 über.

Prüfe vor der Abgabe Feld für Feld gegen die Vorlage: genau 8 Figuren, in jedem Feld ist dasselbe Bein vorne und dasselbe Knie gebeugt wie bei der Puppe, kein Bein und kein Arm abgeschnitten, {f['waffe']}, {pruef}. Stimmt ein Feld nicht, male es neu, bevor du abgibst."""


def stehen(f):
	weiblich = f"\n- {f.get('koerper', WEIBLICH)}" if f["g"] == "w" else ""
	if f["g"] == "w":
		sitz = "Gesäß am Boden, Beine seitlich angewinkelt, Hände im Schoß, Oberkörper aufrecht."
	else:
		sitz = "Gesäß am Boden, Beine locker nach vorne, Knie leicht angezogen, Hände auf den Knien, Oberkörper aufrecht."
	return f"""Neues Blatt, gleiche Figur wie eben: Welt-Blatt „{f['n']}, Stehen und Sitzen“ für Asterfall. Aufbau wie bei den Spieler-Figuren in Ragnarok Online: Stehen und Sitzen mit je 1 Bild in jeder der fünf Richtungen (nur Aufbau und Posen als Vorbild, nichts abmalen).

ZWEI ANHÄNGE
1. haupt_{f['key']}_welt.png = die FIGUR {f['n']} ({f['d']}). Übernimm Gesicht, Haare, Kleidung, Farben, Größe und den Malstil exakt, genau wie in den Blättern eben. Oben in der Vorlage sieht man die Figur von vorne, unten von hinten.
2. posen_{f['g']}_stehen_sitzen.png = die POSEN-VORLAGE mit 10 Gliederpuppen. {PUPPE} Jeder Fuß und jedes Knie der Figur ist dort, wo es bei der Puppe ist. Die Puppen selbst und ihre Farben Rot, Blau, Grau kommen NICHT ins Bild. Bei der Puppe ist der Kopf ein grünes Oval, bei {f['n']} bleibt der echte Kopf.

FORMAT
- Querformat 3:2, Hintergrund einfarbig reines Pink (#FF00FF), kein Verlauf, kein Bodenschatten, keine Schrift, keine Linien.
- 2 Reihen, je 5 Felder, gleiche Plätze wie in der Vorlage, nichts berührt sich.
- Die Figur ist in allen 10 Bildern gleich angezogen und gleich groß wie in den Geh-Blättern eben, nur die Pose ändert sich.
- Blick von schräg oben wie in der Vorlage, Licht von links oben, klare dunkle Umrisslinie.
- {f['hand']}{weiblich}

RICHTUNGEN (in beiden Reihen gleich, von links nach rechts):
Bild 1 VON VORNE (schaut zum Betrachter), Bild 2 SCHRÄG VON VORNE (Gesicht UND Körper zeigen nach links unten, genau wie beim Gehen schräg von vorne), Bild 3 VON DER SEITE (schaut genau nach links, Profil), Bild 4 SCHRÄG VON HINTEN (schaut nach links oben, Rücken schräg), Bild 5 VON HINTEN (ganzer Rücken).
Bei Bild 4 und 5 sieht man nur den RÜCKEN, so wie in haupt_{f['key']}_welt.png in der unteren Reihe: {f['rueck']}.

REIHE 1: Stehen, ruhig und aufrecht, Füße nebeneinander, Arme locker hängend.
REIHE 2: Sitzen am Boden wie Spieler in Ragnarok Online: {sitz} Umhang oder Mantel liegt locker auf dem Boden, bleibt aber ganz im Feld.

Prüfe vor der Abgabe Feld für Feld gegen die Vorlage: genau 10 Figuren, jede Richtung stimmt, in Reihe 2 sitzt die Figur wirklich am Boden (nicht hocken, nicht knien), kein Bein und kein Arm abgeschnitten, {f['waffe']}, das Gesicht ist in Bild 1 bis 3 jeder Reihe dasselbe. Stimmt ein Feld nicht, male es neu, bevor du abgibst."""


def main():
	alt = json.loads(ZIEL.read_text(encoding="utf-8")) if ZIEL.exists() else {}
	for key in sys.argv[1:] or list(FIGUREN):
		f = dict(FIGUREN[key], key=key)
		reihe = list(RICHTUNGEN)
		alt[key] = {"g": f["g"], "blaetter": [[r, gehen(r, f, i == 0)] for i, r in enumerate(reihe)] + [["stehen_sitzen", stehen(f)]]}
		print(f"{key}: {len(alt[key]['blaetter'])} Prompts")
	ZIEL.write_text(json.dumps(alt, ensure_ascii=False, indent="\t"), encoding="utf-8")


if __name__ == "__main__":
	main()
