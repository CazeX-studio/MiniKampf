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
const KOPF := "res://assets/teile/koepfe/%s_%s_%s.png"
## Gesicht je Animation (seitlich); fehlt ein Gesicht in einer Richtung, gilt „normal“
const GESICHT := {
	"hit": "schmerz", "parry": "entschlossen", "attack": "entschlossen", "attack2": "entschlossen",
	"wurf": "entschlossen", "victory": "freude", "cast": "augen_zu",
}

## Gilt für alle Figuren, die Teile haben (Umschalter in Editor → Figuren-Animationen)
static var art := Art.GANZ
static var _daten := {}
static var _cache := {}


## Hat die Figur zerlegte Teile?
static func hat_teile(figur: String) -> bool:
	return _alle().has(figur)


## Einzelbild einer Figur je nach eingestellter Art; null = kein Bild (dann gilt das ganze Bild).
static func bild(figur: String, anim: String, frame: int) -> Texture2D:
	if art == Art.GANZ or not hat_teile(figur):
		return null
	var info: Dictionary = _alle()[figur].get("%s_f%d" % [anim, frame], {})
	if info.is_empty():
		return null
	var schluessel := "%s/%s/%d/%d" % [figur, anim, frame, art]
	if _cache.has(schluessel):
		return _cache[schluessel]
	var koerper := _bild_laden(KOERPER % [figur, anim, frame])
	if koerper == null:
		return null
	var ergebnis := koerper
	if not info.get("ganz", false):
		# Erst der Kopf, dann der Körper darüber: Halstuch und Schwert liegen vor dem Kopf
		ergebnis = Image.create_empty(koerper.get_width(), koerper.get_height(), false, Image.FORMAT_RGBA8)
		var kopf: Image
		var ecke: Array
		if art == Art.TEILE:
			kopf = _bild_laden(ALTER_KOPF % [figur, anim, frame])
			ecke = info.alt
		else:
			kopf = _bild_laden(KOPF % [figur, info.richtung, gesicht(anim, frame)])
			if kopf == null:
				kopf = _bild_laden(KOPF % [figur, info.richtung, "normal"])
			ecke = info.kopf
		if kopf != null:
			ergebnis.blend_rect(kopf, Rect2i(Vector2i.ZERO, kopf.get_size()), Vector2i(int(ecke[0]), int(ecke[1])))
		ergebnis.blend_rect(koerper, Rect2i(Vector2i.ZERO, koerper.get_size()), Vector2i.ZERO)
	ergebnis.generate_mipmaps()
	var textur := ImageTexture.create_from_image(ergebnis)
	_cache[schluessel] = textur
	return textur


## Gesicht zu einem Bild: beim Fallen erst Schmerz, dann Augen zu.
static func gesicht(anim: String, frame: int) -> String:
	if anim == "death":
		return "schmerz" if frame < 2 else "augen_zu"
	return GESICHT.get(anim, "normal")


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
