class_name FigurWahl
extends RefCounted
## Welche eigene Figur man allein spielt (Vega, Kofi …), gewählt im Editor und gemerkt.
## Die andere eigene Figur läuft als Begleiter („Testgefährte“) mit.

const DATEI := "user://figur.json"
## Eigene Figuren aus Marcos Bildblättern (assets/figuren/)
const FIGUREN: Array[String] = ["vega", "kofi"]
const NAMEN := {"vega": "Vega", "kofi": "Kofi"}
## Gerade in „Figur erstellen“ zusammengestellt: {aussehen = "novize_w+mira", name = "…"}; Kreuzweg übernimmt sie beim Start
static var neue_figur := {}


static func gewaehlt() -> String:
	if FileAccess.file_exists(DATEI):
		var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATEI))
		if data is Dictionary and str(data.get("figur", "")) in FIGUREN:
			return data.figur
	return FIGUREN[0]


static func waehlen(figur: String) -> void:
	var file := FileAccess.open(DATEI, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({figur = figur}))


## Die nächste eigene Figur nach der gewählten (für den Begleiter).
static func begleiter() -> String:
	return FIGUREN[(FIGUREN.find(gewaehlt()) + 1) % FIGUREN.size()]
