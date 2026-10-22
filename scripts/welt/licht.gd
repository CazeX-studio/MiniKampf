class_name Licht
extends PointLight2D
## Ein Lichtschein wie bei Octopath Traveler: Fackeln, Laternen, Glut, Sternensplitter und Leuchtpilze werfen
## einen weichen, leicht flackernden Schein auf Boden, Häuser und Figuren. Die Welt selbst ist dafür etwas
## abgedunkelt (Grundlicht der Karte, siehe WorldMap.light). Alle Lichtarten stehen hier an einer Stelle.

## farbe, groesse (Halbmesser in Bildpunkten), staerke, flackern (wie stark), tempo (wie schnell)
const ARTEN := {
	"laterne": {farbe = Color("ffd38a"), groesse = 150.0, staerke = 0.75, flackern = 0.06, tempo = 3.0},
	"fackel": {farbe = Color("ff9a48"), groesse = 190.0, staerke = 1.3, flackern = 0.16, tempo = 9.0},
	"glut": {farbe = Color("ff6a28"), groesse = 120.0, staerke = 0.85, flackern = 0.14, tempo = 5.0},
	"lagerfeuer": {farbe = Color("ff8a38"), groesse = 210.0, staerke = 1.0, flackern = 0.18, tempo = 8.0},
	"splitter": {farbe = Color("c6a6ff"), groesse = 150.0, staerke = 1.2, flackern = 0.3, tempo = 2.4},
	"pilz": {farbe = Color("9a7cff"), groesse = 150.0, staerke = 1.1, flackern = 0.15, tempo = 2.0},
	"kraut": {farbe = Color("b8ffe0"), groesse = 70.0, staerke = 0.5, flackern = 0.3, tempo = 3.0},
	"silber": {farbe = Color("dceeff"), groesse = 110.0, staerke = 0.6, flackern = 0.2, tempo = 3.0},
}
## Der Schein liegt flach auf dem Boden (schräge Sicht von oben), deshalb ist er breiter als hoch
const FLACH := Vector2(1.0, 0.62)

static var _textur: GradientTexture2D

var _art: Dictionary
var _zeit := 0.0


## Ein neues Licht der Art (siehe ARTEN). Eine eigene Farbe ersetzt die der Art (z. B. Festlaternen).
static func erzeugen(art: String, farbe := Color(0, 0, 0, 0)) -> Licht:
	var licht := Licht.new()
	licht._art = ARTEN.get(art, ARTEN.laterne)
	licht.color = farbe if farbe.a > 0.0 else licht._art.farbe
	licht.texture = _schein()
	licht.texture_scale = licht._art.groesse * 2.0 / _schein().width
	licht.scale = FLACH
	licht.energy = licht._art.staerke
	licht.blend_mode = Light2D.BLEND_MODE_ADD
	# Jedes Licht flackert in einem anderen Takt
	licht._zeit = randf() * 10.0
	return licht


## Weicher, runder Schein: in der Mitte hell, nach außen auslaufend (für alle Lichter dieselbe Textur).
static func _schein() -> GradientTexture2D:
	if _textur == null:
		var verlauf := Gradient.new()
		verlauf.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
		verlauf.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0)])
		_textur = GradientTexture2D.new()
		_textur.gradient = verlauf
		_textur.fill = GradientTexture2D.FILL_RADIAL
		_textur.fill_from = Vector2(0.5, 0.5)
		_textur.fill_to = Vector2(1.0, 0.5)
		_textur.width = 256
		_textur.height = 256
	return _textur


func _process(delta: float) -> void:
	_zeit += delta
	var t: float = _zeit * _art.tempo
	# Zwei Wellen übereinander, damit das Flackern nicht gleichmäßig wirkt
	var wackeln := 0.6 * sin(t) + 0.4 * sin(t * 2.3 + 1.7)
	energy = _art.staerke * (1.0 + _art.flackern * wackeln)
