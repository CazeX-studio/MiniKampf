class_name FigurTeile
extends RefCounted
## Figuren wie bei Ragnarok (Projekt 11): Körper und Kopf sind getrennte Bilder und werden im Spiel zusammengesetzt.
## Die Teile erzeugt tools/kopf_koerper.py aus den fertigen Bildern (assets/teile/koerper, assets/teile/kopf),
## die Ankerpunkte stehen in data/figurteile.json. Bilder ohne Trennung (z. B. liegend) bleiben ganz.
## Später kommt hier die Wahl von Kopf/Frisur dazu; jetzt gibt es zum Prüfen drei Arten (siehe Art).

enum Art {
	GANZ, ## die fertigen Bilder aus assets/figuren (wie bisher)
	TEILE, ## Körper + eigener Kopf des Bildes (muss genauso aussehen wie GANZ)
	STANDARDKOPF, ## Körper + immer derselbe Kopf je Blickrichtung (so wird es mit wählbaren Köpfen)
}

const DATEN := "res://data/figurteile.json"
const KOERPER := "res://assets/teile/koerper/%s_%s_f%d.png"
const KOPF := "res://assets/teile/kopf/%s_%s_f%d.png"

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
	var name := "%s_f%d" % [anim, frame]
	var info: Dictionary = _alle()[figur].get(name, {})
	if info.is_empty():
		return null
	var schluessel := "%s/%s/%d" % [figur, name, art]
	if _cache.has(schluessel):
		return _cache[schluessel]
	var koerper := _bild_laden(KOERPER % [figur, anim, frame])
	if koerper == null:
		return null
	if not info.get("ganz", false):
		var kopf_name := name if art == Art.TEILE else _standardkopf(anim)
		var kopf_info: Dictionary = _alle()[figur].get(kopf_name, info)
		var kopf := _bild_laden(KOPF % [figur, kopf_name.rsplit("_f", true, 1)[0], int(kopf_name.rsplit("_f", true, 1)[1])])
		if kopf != null:
			var hals: Array = info.hals
			var anker: Array = kopf_info.anker
			var ziel := Vector2i(roundi(hals[0] - anker[0]), roundi(hals[1] - anker[1]))
			koerper.blend_rect(kopf, Rect2i(Vector2i.ZERO, kopf.get_size()), ziel)
	koerper.generate_mipmaps()
	var textur := ImageTexture.create_from_image(koerper)
	_cache[schluessel] = textur
	return textur


## Kopf, der bei „Standardkopf“ immer benutzt wird: das erste Stehbild der passenden Blickrichtung.
static func _standardkopf(anim: String) -> String:
	if anim.ends_with("_vorn"):
		return "idle_vorn_f0"
	if anim.ends_with("_hinten"):
		return "idle_hinten_f0"
	return "idle_f0"


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
