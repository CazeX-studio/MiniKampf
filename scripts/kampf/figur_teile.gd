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

## Gilt für alle Figuren, die Teile haben (Umschalter in Editor → Figuren-Animationen)
static var art := Art.GANZ
## Gewählter Kopf bei KOPFBLATT ("" = der eigene Kopf der Figur), siehe koepfe()
static var kopf := ""
static var _daten := {}
static var _cache := {}


## Körper einer zusammengesetzten Figur: „novize_w+mira“ -> „novize_w“ (andere Namen bleiben, wie sie sind).
static func koerper_von(look: String) -> String:
	return look.get_slice("+", 0)


## Hat die Figur zerlegte Teile?
static func hat_teile(figur: String) -> bool:
	return _alle().has(koerper_von(figur))


## Einzelbild einer Figur je nach eingestellter Art; null = kein Bild (dann gilt das ganze Bild).
## figur kann auch „Körper+Kopf“ sein (z. B. „novize_w+mira“, so speichert „Figur erstellen“ das Aussehen):
## dann gilt dieser Kopf statt des im Editor gewählten.
static func bild(figur: String, anim: String, frame: int) -> Texture2D:
	var kopf_wahl := kopf
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
	var schluessel := "%s/%s/%d/%d/%s" % [figur, anim, frame, art_jetzt, kopf_id]
	if _cache.has(schluessel):
		return _cache[schluessel]
	var koerper := _bild_laden(KOERPER % [figur, anim, frame])
	if koerper == null:
		return null
	var ergebnis := koerper
	if not info.get("ganz", false):
		# Erst der Kopf, dann der Körper darüber: Halstuch und Schwert liegen vor dem Kopf
		# Körper-Blätter: oben und seitlich Platz lassen, damit ein großer oder geneigter Kopf nicht abgeschnitten wird
		# (die Füße bleiben unten in der Mitte, dort richtet das Spiel die Figur aus)
		var rand := RAND if _alle()[figur].get("_nur_teile", false) else 0
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
			var winkel: float = info.get("winkel", 0.0)
			if kopf_bild != null and absf(winkel) > 1.0:
				# Geneigter Kopf (Körper-Blätter mit länglichem Oval): um den Halspunkt drehen
				var radius := ceili(maxf(maxf(punkt.length(), (Vector2(kopf_bild.get_size()) - punkt).length()),
						maxf(Vector2(kopf_bild.get_width() - punkt.x, punkt.y).length(), Vector2(punkt.x, kopf_bild.get_height() - punkt.y).length())))
				kopf_bild = _drehen(kopf_bild, punkt, winkel, radius)
				punkt = Vector2(radius, radius)
			ecke = Vector2i(roundi(info.hals[0] - punkt.x), roundi(info.hals[1] - punkt.y)) + Vector2i(rand, rand)
		if kopf_bild != null:
			ergebnis.blend_rect(kopf_bild, Rect2i(Vector2i.ZERO, kopf_bild.get_size()), ecke)
		ergebnis.blend_rect(koerper, Rect2i(Vector2i.ZERO, koerper.get_size()), Vector2i(rand, rand))
	ergebnis.generate_mipmaps()
	var textur := ImageTexture.create_from_image(ergebnis)
	_cache[schluessel] = textur
	return textur


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
