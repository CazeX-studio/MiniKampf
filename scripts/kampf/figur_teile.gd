class_name FigurTeile
extends RefCounted
## Figuren wie bei Ragnarok (Projekt 11): Körper und Kopf sind getrennte Bilder und werden im Spiel zusammengesetzt.
## Die Teile erzeugt tools/kopf_koerper.py aus den fertigen Bildern und dem Kopf-Blatt der Figur:
## assets/teile/koerper (Körper ohne Kopf), assets/teile/kopf (der alte Kopf jedes Bildes) und
## assets/teile/koepfe (die Köpfe aus dem Kopf-Blatt, je Richtung und Gesicht). Die Stellen stehen in data/figurteile.json.
## Bilder ohne Trennung (liegend) bleiben ganz. Später kommt hier die Wahl des Kopfes dazu.

enum Art {
	GANZ, ## die fertigen Bilder aus assets/figuren (wie bisher)
	TEILE, ## Körper + alter Kopf des Bildes (muss genauso aussehen wie GANZ)
	KOPFBLATT, ## Körper + Kopf aus dem Kopf-Blatt mit passendem Gesicht (so wird es mit wählbaren Köpfen)
}

const DATEN := "res://data/figurteile.json"
const KOERPER := "res://assets/teile/koerper/%s_%s_f%d.png"
const ALTER_KOPF := "res://assets/teile/kopf/%s_%s_f%d.png"
const KOPF := "res://assets/teile/koepfe/%s_%s.png"  # Kopf, Richtung_Gesicht
## Gesicht je Animation (seitlich); fehlt ein Gesicht in einer Richtung, gilt „normal“
const GESICHT := {
	"hit": "schmerz", "parry": "entschlossen", "attack": "entschlossen", "attack2": "entschlossen",
	"wurf": "entschlossen", "victory": "freude", "cast": "augen_zu",
}

## So viel Platz (Pixel) bekommen Körper-Blätter oben und an den Seiten für den Kopf
const RAND := 24
## Zusätzlicher Platz, wenn Hut oder Rückenteil getragen werden
const RAND_SCHICHT := 24
## Zusätzlicher Platz bei Körpern mit Waffe: Das hochgereckte Schwert ragt weit über die Figur hinaus
const RAND_WAFFE := 48
## Ab dieser Neigung (Grad) gilt eine Figur als liegend
const LIEGEND := 60.0

## Aussehen-Schichten (Projekt 13, Schritt 4): Hut über dem Kopf, Rückenteil hinter dem Körper
const SCHICHTEN := "res://data/aussehen_teile.json"
const HUT_BILD := "res://assets/teile/hut/%s_%s.png"  # Hut, Richtung
const RUECKEN_BILD := "res://assets/teile/ruecken/%s_%s_f%d.png"  # Rückenteil, Richtung, Bild
## Bilder je Rückenteil: erst Stehen, dann Laufen
const RUECKEN_STEHEN := 2
const RUECKEN_LAUFEN := 4
## Waffe als eigenes Teil (Projekt 13, Schritt 3): Sie sitzt am Griff und dreht sich mit dem Bild
const WAFFE_BILD := "res://assets/teile/waffe/%s.png"
## Umfärben (Projekt 13, Schritt 5): Farbpaletten je Farbfläche
const PALETTEN := "res://data/farbpaletten.json"
## So nah (Abstand im Farbraum, 0 bis 1,7) muss ein Bildpunkt an einem festen Ton liegen, damit er umgefärbt wird
const FARB_TOLERANZ := 0.1

## Gilt für alle Figuren, die Teile haben (Umschalter in Editor → Figuren-Animationen)
static var art := Art.GANZ
## Gewählter Kopf bei KOPFBLATT ("" = der eigene Kopf der Figur), siehe koepfe()
static var kopf := ""
## Getragener Hut und getragenes Rückenteil ("" = keins), siehe hut_liste() und ruecken_liste().
## Gilt nur, wo Kopf und Körper zusammengesetzt werden (neuer Kopf und Körper-Blätter).
static var hut := ""
static var ruecken := ""
## Waffen-Aussehen ("" = die Waffe des Körpers), siehe waffe_liste()
static var waffe := ""
## Gewählte Farbpalette ("" = Grundfarben), siehe paletten_liste(). Färbt Hut, Rückenteil und Klassen-Körper um,
## nie die Novizen-Körper.
static var farben := ""
static var _schichten := {}
static var _paletten := {}
static var _daten := {}
static var _cache := {}


## Körper einer zusammengesetzten Figur: „novize_w+mira“ -> „novize_w“ (andere Namen bleiben, wie sie sind).
static func koerper_von(look: String) -> String:
	return look.get_slice("#", 0).get_slice("+", 0)


## Aussehen-Plätze (Projekt 13, Schritt 6): Das Aussehen hängt hinten am Namen der Figur, getrennt von den Werten:
## „novize_w+mira#hut=wanderhut,ruecken=reiseumhang,farben=glutschmiede,waffe=krummklinge“. So kommt es überall mit, wo die
## Figur gezeigt wird (Welt, Kampf, Mitspieler) und steht im Spielstand. Ergebnis: {hut, ruecken, farben, waffe} (fehlt = "").
static func aussehen_von(look: String) -> Dictionary:
	var aussehen := {hut = "", ruecken = "", farben = "", waffe = ""}
	if "#" in look:
		for teil: String in look.get_slice("#", 1).split(",", false):
			var platz := teil.get_slice("=", 0)
			if aussehen.has(platz):
				aussehen[platz] = teil.get_slice("=", 1)
	return aussehen


## Figur ohne Aussehen-Teil: „novize_w+mira#hut=…“ -> „novize_w+mira“.
static func ohne_aussehen(look: String) -> String:
	return look.get_slice("#", 0)


## Figur mit neuem Aussehen. Unbekannte Teile fallen weg; ohne Teile bleibt der Name ohne „#“.
static func mit_aussehen(look: String, aussehen: Dictionary) -> String:
	var gueltig := {hut = hut_liste(), ruecken = ruecken_liste(), farben = paletten_liste(), waffe = waffe_liste()}
	var teile: PackedStringArray = []
	for platz: String in ["hut", "ruecken", "farben", "waffe"]:
		var id := str(aussehen.get(platz, ""))
		if id != "" and gueltig[platz].has(id):
			teile.append("%s=%s" % [platz, id])
	var basis := ohne_aussehen(look)
	return basis if teile.is_empty() else "%s#%s" % [basis, ",".join(teile)]


## Körper der Klassen (D18): Wer die Klasse gelernt hat, trägt ihren Körper, der Kopf bleibt.
## Klasse -> Anfang des Körpernamens (dazu _m oder _w wie beim Novizen). Klassen ohne eigenen Körper bleiben Novize.
const KLASSEN_KOERPER := {"archer": "bogen", "tamer": "zaehmer"}


## Figur mit dem Körper der Klasse: „novize_w+w1#hut=…“ als Bogenschützin -> „bogen_w+w1#hut=…“.
## klasse "" oder "novize": wieder der Novizen-Körper. Figuren ohne Kopf und Körper bleiben, wie sie sind.
static func mit_klasse(look: String, klasse: String) -> String:
	var koerper := koerper_von(look)
	var teile := koerper.split("_")
	if not kann_aussehen(look) or teile.size() != 2 or not teile[1] in ["m", "w"]:
		return look
	var neu := "%s_%s" % [KLASSEN_KOERPER.get(klasse, "novize"), teile[1]]
	if neu == koerper or not koerper_liste().has(neu):
		return look
	return neu + look.substr(koerper.length())


## Kann diese Figur Aussehen-Teile tragen? (Nur Figuren aus Körper und Kopf, z. B. aus „Figur erstellen“.)
static func kann_aussehen(look: String) -> bool:
	return koerper_liste().has(koerper_von(look))


## Hat die Figur zerlegte Teile?
static func hat_teile(figur: String) -> bool:
	return _alle().has(koerper_von(figur))


## Einzelbild einer Figur je nach eingestellter Art; null = kein Bild (dann gilt das ganze Bild).
## figur kann auch „Körper+Kopf“ sein (z. B. „novize_w+mira“, so speichert „Figur erstellen“ das Aussehen):
## dann gilt dieser Kopf statt des im Editor gewählten.
static func bild(figur: String, anim: String, frame: int) -> Texture2D:
	var kopf_wahl := kopf
	var hut_wahl := hut
	var ruecken_wahl := ruecken
	var farben_wahl := farben
	var waffe_wahl := waffe
	if "#" in figur or "+" in figur:
		# Figuren aus „Figur erstellen“ tragen ihr eigenes Aussehen (aus dem Namen), die Wahl im Editor gilt für sie nicht
		var aussehen := aussehen_von(figur)
		hut_wahl = aussehen.hut
		ruecken_wahl = aussehen.ruecken
		farben_wahl = aussehen.farben
		waffe_wahl = aussehen.waffe
		figur = ohne_aussehen(figur)
	if "+" in figur:
		kopf_wahl = figur.get_slice("+", 1)
		figur = koerper_von(figur)
	if not hat_teile(figur):
		return null
	# Körper-Blätter (grüner Platzhalter statt Kopf) werden immer zusammengesetzt
	var art_jetzt := Art.KOPFBLATT if _alle()[figur].get("_nur_teile", false) else art
	if art_jetzt == Art.GANZ:
		return null
	var info: Dictionary = _alle()[figur].get("%s_f%d" % [anim, frame], {})
	if info.is_empty():
		return null
	var kopf_id := kopf_wahl if koepfe(figur).has(kopf_wahl) else standardkopf(figur)
	var hut_jetzt := hut_wahl if art_jetzt == Art.KOPFBLATT and hut_liste().has(hut_wahl) else ""
	var ruecken_jetzt := ruecken_wahl if art_jetzt == Art.KOPFBLATT and ruecken_liste().has(ruecken_wahl) else ""
	var farben_jetzt := farben_wahl if paletten_liste().has(farben_wahl) else ""
	var waffe_jetzt := _waffe_von(figur, waffe_wahl)
	var schluessel := "%s/%s/%d/%d/%s/%s/%s/%s/%s" % [figur, anim, frame, art_jetzt, kopf_id, hut_jetzt, ruecken_jetzt, farben_jetzt, waffe_jetzt]
	if _cache.has(schluessel):
		return _cache[schluessel]
	var koerper := _bild_laden(KOERPER % [figur, anim, frame])
	if koerper == null:
		return null
	# Klassen-Körper mit festen Farbflächen werden umgefärbt, Novizen-Körper haben keine
	if farben_jetzt != "" and _alle()[figur].has("_flaechen"):
		koerper = umfaerben(koerper, _alle()[figur]._flaechen, farben_jetzt)
	var ergebnis := koerper
	if not info.get("ganz", false):
		# Erst der Kopf, dann der Körper darüber: Halstuch und Schwert liegen vor dem Kopf
		# Körper-Blätter: oben und seitlich Platz lassen, damit ein großer oder geneigter Kopf nicht abgeschnitten wird
		# (die Füße bleiben unten in der Mitte, dort richtet das Spiel die Figur aus)
		var rand := RAND if _alle()[figur].get("_nur_teile", false) else 0
		if _alle()[figur].has("_waffe"):
			rand += RAND_WAFFE
		if hut_jetzt != "" or ruecken_jetzt != "":
			rand += RAND_SCHICHT
		ergebnis = Image.create_empty(koerper.get_width() + 2 * rand, koerper.get_height() + rand, false, Image.FORMAT_RGBA8)
		var kopf_bild: Image
		var ecke: Vector2i
		if art_jetzt == Art.TEILE:
			kopf_bild = _bild_laden(ALTER_KOPF % [figur, anim, frame])
			ecke = Vector2i(int(info.alt[0]), int(info.alt[1]))
		else:
			# Der Kopf wird mit seinem Halspunkt auf den Halspunkt des Bildes gesetzt
			var punkte: Dictionary = koepfe(figur)[kopf_id].hals
			var variante := "%s_%s" % [info.richtung, gesicht(anim, frame)]
			if not punkte.has(variante):
				variante = "%s_normal" % info.richtung
			kopf_bild = _bild_laden(KOPF % [kopf_id, variante])
			var punkt := Vector2(punkte[variante][0], punkte[variante][1])
			if kopf_bild != null and hut_jetzt != "":
				# Den Hut auf den noch ungedrehten Kopf setzen, dann dreht er sich mit
				var mit_hut := _hut_aufsetzen(kopf_bild, hut_jetzt, info.richtung, farben_jetzt)
				kopf_bild = mit_hut.bild
				punkt += mit_hut.verschoben
			var winkel: float = info.get("winkel", 0.0)
			if kopf_bild != null and absf(winkel) > 1.0:
				# Geneigter Kopf (Körper-Blätter mit länglichem Oval): um den Halspunkt drehen
				var radius := ceili(maxf(maxf(punkt.length(), (Vector2(kopf_bild.get_size()) - punkt).length()),
						maxf(Vector2(kopf_bild.get_width() - punkt.x, punkt.y).length(), Vector2(punkt.x, kopf_bild.get_height() - punkt.y).length())))
				kopf_bild = _drehen(kopf_bild, punkt, winkel, radius)
				punkt = Vector2(radius, radius)
			ecke = Vector2i(roundi(info.hals[0] - punkt.x), roundi(info.hals[1] - punkt.y)) + Vector2i(rand, rand)
		# Rückenteil: von der Seite und von vorne hinter allem, von hinten über dem Körper
		var umhang := {}
		if ruecken_jetzt != "" and info.has("hals"):
			umhang = _rueckenteil(ruecken_jetzt, info, rand, farben_jetzt, anim, frame)
		if not umhang.is_empty() and not umhang.vorne:
			ergebnis.blend_rect(umhang.bild, Rect2i(Vector2i.ZERO, umhang.bild.get_size()), umhang.ecke)
		if kopf_bild != null:
			ergebnis.blend_rect(kopf_bild, Rect2i(Vector2i.ZERO, kopf_bild.get_size()), ecke)
		ergebnis.blend_rect(koerper, Rect2i(Vector2i.ZERO, koerper.get_size()), Vector2i(rand, rand))
		if not umhang.is_empty() and umhang.vorne:
			ergebnis.blend_rect(umhang.bild, Rect2i(Vector2i.ZERO, umhang.bild.get_size()), umhang.ecke)
		# Die Waffe liegt über dem Körper und deckt den gemalten Griff ab
		if waffe_jetzt != "" and info.has("griff"):
			var teil := _waffe_gedreht(waffe_jetzt, float(info.waffe_winkel))
			var griff := Vector2(info.griff[0], info.griff[1]) + Vector2(rand, rand)
			ergebnis.blend_rect(teil.bild, Rect2i(Vector2i.ZERO, teil.bild.get_size()), Vector2i((griff - teil.punkt).round()))
	ergebnis.generate_mipmaps()
	var textur := ImageTexture.create_from_image(ergebnis)
	_cache[schluessel] = textur
	return textur


## Waffe, die eine Figur trägt: die gewählte, sonst die des Körpers ("" = keine).
static func _waffe_von(figur: String, wahl: String) -> String:
	if not _alle().get(koerper_von(figur), {}).has("_waffe"):
		return ""
	return wahl if waffe_liste().has(wahl) else str(_alle()[koerper_von(figur)]._waffe)


## Waffenbild in einem Winkel: {bild, punkt} (punkt = Stelle der Parierstange). Je Waffe und Winkel nur einmal gerechnet.
static func _waffe_gedreht(id: String, winkel: float) -> Dictionary:
	var schluessel := "waffe/%s/%d" % [id, roundi(winkel)]
	if _cache.has(schluessel):
		return _cache[schluessel]
	var bild := _bild_laden(WAFFE_BILD % id)
	var anker_daten: Array = _alle_schichten().waffe[id].anker
	var anker := Vector2(anker_daten[0], anker_daten[1])
	var radius := ceili(maxf(maxf(anker.length(), (Vector2(bild.get_size()) - anker).length()),
			maxf(Vector2(bild.get_width() - anker.x, anker.y).length(), Vector2(anker.x, bild.get_height() - anker.y).length())))
	var teil := {bild = _drehen(bild, anker, winkel, radius), punkt = Vector2(radius, radius)}
	_cache[schluessel] = teil
	return teil


## Alle Waffen-Aussehen: Name -> Anzeigename.
static func waffe_liste() -> Dictionary:
	return _namen(_alle_schichten().get("waffe", {}))


## Alle Hüte: Name -> Anzeigename.
static func hut_liste() -> Dictionary:
	return _namen(_alle_schichten().get("hut", {}))


## Gibt es diesen Hut nur als Belohnung (Kartenalbum, D17)? Dann ist er erst nach dem Freischalten wählbar.
static func hut_belohnung(hut_id: String) -> bool:
	return bool(_alle_schichten().get("hut", {}).get(hut_id, {}).get("belohnung", false))


## Alle Rückenteile: Name -> Anzeigename.
static func ruecken_liste() -> Dictionary:
	return _namen(_alle_schichten().get("ruecken", {}))


static func _namen(teile: Dictionary) -> Dictionary:
	var liste := {}
	for id: String in teile:
		liste[id] = teile[id].get("name", id)
	return liste


## Hut auf ein Kopfbild setzen. Ergebnis: {bild, verschoben} (um so viel ist der alte Inhalt im neuen Bild verrutscht).
static func _hut_aufsetzen(kopf_bild: Image, hut_id: String, richtung: String, palette := "") -> Dictionary:
	var daten: Dictionary = _alle_schichten().hut[hut_id].get(richtung, {})
	# "bild": Bilder eines anderen Huts nutzen (Platzhalter, z. B. Belohnungs-Hüte des Kartenalbums)
	var hut_bild := _bild_laden(HUT_BILD % [str(_alle_schichten().hut[hut_id].get("bild", hut_id)), richtung])
	if hut_bild == null or daten.is_empty():
		return {bild = kopf_bild, verschoben = Vector2.ZERO}
	hut_bild = _schicht_faerben(hut_bild, _alle_schichten().hut[hut_id], palette)
	var sichtbar := kopf_bild.get_used_rect()
	var ziel := Vector2(sichtbar.position.x + sichtbar.size.x / 2.0,
			sichtbar.position.y + sichtbar.size.y * float(daten.get("sitz", 0.3)))
	var hut_ecke := Vector2i((ziel - Vector2(daten.anker[0], daten.anker[1])).round())
	# Neues Bild, in das Kopf und Hut beide passen
	var links := mini(0, hut_ecke.x)
	var oben := mini(0, hut_ecke.y)
	var rechts := maxi(kopf_bild.get_width(), hut_ecke.x + hut_bild.get_width())
	var unten := maxi(kopf_bild.get_height(), hut_ecke.y + hut_bild.get_height())
	var neu := Image.create_empty(rechts - links, unten - oben, false, Image.FORMAT_RGBA8)
	var verschoben := Vector2i(-links, -oben)
	# Stirnbänder (Kartenalbum): Der hintere Teil des Rings (Zeilen über "hinten_bis") liegt hinter dem Kopf
	var hinten := int(daten.get("hinten_bis", 0))
	if hinten > 0:
		neu.blend_rect(hut_bild, Rect2i(0, 0, hut_bild.get_width(), hinten), hut_ecke + verschoben)
	neu.blend_rect(kopf_bild, Rect2i(Vector2i.ZERO, kopf_bild.get_size()), verschoben)
	neu.blend_rect(hut_bild, Rect2i(0, hinten, hut_bild.get_width(), hut_bild.get_height() - hinten), hut_ecke + verschoben + Vector2i(0, hinten))
	return {bild = neu, verschoben = Vector2(verschoben)}


## Rückenteil für ein Bild: {bild, ecke, vorne} oder leer. Es hängt am Halspunkt und neigt sich mit dem Körper.
## Im Laufen weht es: Stehen und Laufen haben eigene Bilder.
static func _rueckenteil(id: String, info: Dictionary, rand: int, palette: String, anim: String, frame: int) -> Dictionary:
	var richtung: String = info.richtung
	var daten: Dictionary = _alle_schichten().ruecken[id].get(richtung, {})
	var nummer := RUECKEN_STEHEN + frame % RUECKEN_LAUFEN if anim.begins_with("run") else frame % RUECKEN_STEHEN
	var bild := _bild_laden(RUECKEN_BILD % [id, richtung, nummer])
	if bild == null or daten.is_empty():
		return {}
	bild = _schicht_faerben(bild, _alle_schichten().ruecken[id], palette)
	var anker := Vector2(daten.anker[nummer][0], daten.anker[nummer][1])
	var versatz: Array = daten.get("versatz", [0, 0])
	var winkel: float = info.get("winkel", 0.0)
	# Liegend (Ende vom Fallen) würde der Umhang nach oben abstehen: dann liegt er unter dem Körper und ist nicht zu sehen
	if absf(winkel) > LIEGEND:
		return {}
	if absf(winkel) > 1.0:
		var radius := ceili(maxf(maxf(anker.length(), (Vector2(bild.get_size()) - anker).length()),
				maxf(Vector2(bild.get_width() - anker.x, anker.y).length(), Vector2(anker.x, bild.get_height() - anker.y).length())))
		bild = _drehen(bild, anker, winkel, radius)
		anker = Vector2(radius, radius)
	var hals := Vector2(info.hals[0] + versatz[0], info.hals[1] + versatz[1])
	var ecke := Vector2i((hals - anker).round()) + Vector2i(rand, rand)
	return {bild = bild, ecke = ecke, vorne = richtung == "hinten"}


## Alle Farbpaletten: Name -> Anzeigename.
static func paletten_liste() -> Dictionary:
	return _namen(_alle_paletten())


## Bild umfärben: Jeder Bildpunkt, der nah an einem festen Ton einer Farbfläche liegt, bekommt den Ton gleicher Stufe
## aus der Palette. Kleine Abweichungen (weiche Übergänge der KI-Bilder) bleiben als Helligkeit erhalten.
## flaechen: Farbfläche -> vier Töne (hell, mittel, dunkel, Schatten) als „#rrggbb“.
static func umfaerben(bild: Image, flaechen: Dictionary, palette_id: String) -> Image:
	var ziel_flaechen: Dictionary = _alle_paletten().get(palette_id, {}).get("flaechen", {})
	var von: Array[Color] = []
	var nach: Array[Color] = []
	for flaeche: String in flaechen:
		if not ziel_flaechen.has(flaeche):
			continue
		var quelle: Array = flaechen[flaeche]
		var ziel: Array = ziel_flaechen[flaeche]
		for stufe in mini(quelle.size(), ziel.size()):
			von.append(Color.html(quelle[stufe]))
			nach.append(Color.html(ziel[stufe]))
	if von.is_empty():
		return bild
	var neu := bild.duplicate() as Image
	for y in neu.get_height():
		for x in neu.get_width():
			var farbe := neu.get_pixel(x, y)
			if farbe.a <= 0.0:
				continue
			var bester := -1
			var abstand := FARB_TOLERANZ
			for i in von.size():
				var d := Vector3(farbe.r - von[i].r, farbe.g - von[i].g, farbe.b - von[i].b).length()
				if d < abstand:
					abstand = d
					bester = i
			if bester < 0:
				continue
			var heller := farbe.get_luminance() - von[bester].get_luminance()
			var ergebnis := nach[bester]
			ergebnis = Color(clampf(ergebnis.r + heller, 0.0, 1.0), clampf(ergebnis.g + heller, 0.0, 1.0),
					clampf(ergebnis.b + heller, 0.0, 1.0), farbe.a)
			neu.set_pixel(x, y, ergebnis)
	return neu


## Hut oder Rückenteil in der gewählten Palette.
static func _schicht_faerben(bild: Image, teil: Dictionary, palette: String) -> Image:
	# Ohne gewählte Farben: die Grundfarbe des Teils (z. B. Platzhalter-Hüte in anderer Farbe)
	if palette == "":
		palette = str(teil.get("palette", ""))
	if palette == "" or not paletten_liste().has(palette) or not teil.has("flaechen"):
		return bild
	return umfaerben(bild, teil.flaechen, palette)


static func _alle_paletten() -> Dictionary:
	if _paletten.is_empty() and FileAccess.file_exists(PALETTEN):
		var gelesen: Variant = JSON.parse_string(FileAccess.get_file_as_string(PALETTEN))
		if gelesen is Dictionary:
			_paletten = gelesen
			_paletten.erase("_hinweis")
	return _paletten


static func _alle_schichten() -> Dictionary:
	if _schichten.is_empty() and FileAccess.file_exists(SCHICHTEN):
		var gelesen: Variant = JSON.parse_string(FileAccess.get_file_as_string(SCHICHTEN))
		if gelesen is Dictionary:
			_schichten = gelesen
			_schichten.erase("_hinweis")
	return _schichten


## Körper aus Körper-Blättern (mit grünem Platzhalter statt Kopf), z. B. der Novizen-Körper: Name -> Anzeigename.
static func koerper_liste() -> Dictionary:
	var liste := {}
	for figur: String in _alle():
		if _alle()[figur].get("_nur_teile", false):
			liste[figur] = _alle()[figur].get("_name", figur)
	return liste


## Kopf, wenn keiner gewählt ist: der eigene Kopf der Figur (Kofi: m1), sonst der erste passende.
static func standardkopf(figur: String) -> String:
	var daten: Dictionary = _alle().get(koerper_von(figur), {})
	if daten.has("_eigener_kopf"):
		return daten._eigener_kopf
	var passend := passende_koepfe(figur)
	return passend[0] if not passend.is_empty() else ""


## Köpfe, die bei „Figur erstellen“ zum Körper passen (gleiches Geschlecht), in Reihenfolge m1, m2 …
static func passende_koepfe(figur: String) -> Array:
	var geschlecht: String = _alle().get(koerper_von(figur), {}).get("_geschlecht", "")
	var liste: Array = []
	for id: String in koepfe(figur):
		if geschlecht == "" or koepfe(figur)[id].get("geschlecht", "") == geschlecht:
			liste.append(id)
	liste.sort()
	return liste


## Alle Köpfe, die auf den Körper der Figur passen: Kopf-Name -> {name, hals}.
static func koepfe(figur: String) -> Dictionary:
	return _alle().get(koerper_von(figur), {}).get("_koepfe", {})


## Gesicht zu einem Bild: beim Fallen erst Schmerz, dann Augen zu.
static func gesicht(anim: String, frame: int) -> String:
	if anim == "death":
		return "schmerz" if frame < 2 else "augen_zu"
	return GESICHT.get(anim, "normal")


## Bild um einen Punkt drehen (Grad, im Uhrzeigersinn). Ergebnis: Quadrat mit Seite 2 * radius + 1, der Punkt in der Mitte.
static func _drehen(bild: Image, punkt: Vector2, winkel: float, radius: int) -> Image:
	var seite := 2 * radius + 1
	var ziel := Image.create_empty(seite, seite, false, Image.FORMAT_RGBA8)
	var c := cos(deg_to_rad(winkel))
	var s := sin(deg_to_rad(winkel))
	var w := bild.get_width()
	var h := bild.get_height()
	for y in seite:
		for x in seite:
			# Rückwärts drehen: welcher Punkt des Kopfbildes landet hier?
			var dx := float(x - radius)
			var dy := float(y - radius)
			var qx := dx * c + dy * s + punkt.x
			var qy := -dx * s + dy * c + punkt.y
			if qx < -1.0 or qy < -1.0 or qx > w or qy > h:
				continue
			# Weich zwischen den vier Nachbarpunkten mischen
			var x0 := floori(qx)
			var y0 := floori(qy)
			var fx := qx - x0
			var fy := qy - y0
			var summe := Color(0, 0, 0, 0)
			for oy in 2:
				for ox in 2:
					var px := x0 + ox
					var py := y0 + oy
					if px < 0 or py < 0 or px >= w or py >= h:
						continue
					var g := (fx if ox == 1 else 1.0 - fx) * (fy if oy == 1 else 1.0 - fy)
					var farbe := bild.get_pixel(px, py)
					summe += Color(farbe.r * farbe.a, farbe.g * farbe.a, farbe.b * farbe.a, farbe.a) * g
			if summe.a > 0.003:
				ziel.set_pixel(x, y, Color(summe.r / summe.a, summe.g / summe.a, summe.b / summe.a, summe.a))
	return ziel


static func _bild_laden(pfad: String) -> Image:
	if not ResourceLoader.exists(pfad):
		return null
	var textur: Texture2D = load(pfad)
	var bild := textur.get_image()
	if bild.is_compressed():
		bild.decompress()
	bild.clear_mipmaps()
	bild.convert(Image.FORMAT_RGBA8)
	return bild


static func _alle() -> Dictionary:
	if _daten.is_empty() and FileAccess.file_exists(DATEN):
		var gelesen: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATEN))
		if gelesen is Dictionary:
			_daten = gelesen
			_daten.erase("_hinweis")
	return _daten
