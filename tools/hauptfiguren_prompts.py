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
	weiblich = f"\n- {WEIBLICH}" if f["g"] == "w" else ""
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
	weiblich = f"\n- {WEIBLICH}" if f["g"] == "w" else ""
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
