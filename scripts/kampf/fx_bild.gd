class_name FxBild
extends Sprite2D
## Effekt als gemalte Bildfolge (D9h): assets/fx/NAME_f0.png, _f1.png ... Spielt einmal ab und räumt sich auf.
## Bilder kommen aus tools/effekt_bilder.py. Abgelegte Bildfolgen werden pro Name nur einmal geladen.

const PFAD := "res://assets/fx/%s_f%d.png"
## Größe der Pixel im Kampfbild
const GROESSE := 2.0
## Bilder pro Sekunde bei Geschossen, die ihre Bildfolge im Flug wiederholen
const FLUG_TAKT := 14.0

static var _bilder := {}

var _liste: Array[Texture2D] = []


static func bilder(name: String) -> Array[Texture2D]:
	if not _bilder.has(name):
		var liste: Array[Texture2D] = []
		var i := 0
		while ResourceLoader.exists(PFAD % [name, i]):
			liste.append(load(PFAD % [name, i]))
			i += 1
		_bilder[name] = liste
	return _bilder[name]


static func _neu(feld: Node, name: String, ort: Vector2, groesse: float) -> FxBild:
	var fx := FxBild.new()
	fx._liste = bilder(name)
	fx.texture = fx._liste[0]
	fx.position = ort
	fx.scale = Vector2.ONE * GROESSE * groesse
	fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fx.z_index = 8
	feld.add_child(fx)
	return fx


## Spielt die Bildfolge einmal mittig über "ort" ab. "halten": so lange bleibt das letzte Bild stehen, dann verblasst es.
static func spawn(feld: Node, name: String, ort: Vector2, sekunden: float, gespiegelt := false, winkel := 0.0,
		groesse := 1.0, halten := 0.0) -> FxBild:
	var fx := _neu(feld, name, ort, groesse)
	fx.rotation = winkel
	fx.flip_h = gespiegelt
	var tween := fx.create_tween()
	tween.tween_method(fx._zeige, 0, fx._liste.size() - 1, sekunden)
	if halten > 0.0:
		tween.tween_interval(halten)
		tween.tween_property(fx, "modulate:a", 0.0, 0.25)
	tween.tween_callback(fx.queue_free)
	return fx


## Wie spawn, aber der untere Rand des Bildes steht auf "fuss" (Staub, Kuppel, Lichtstrahl, Risse).
static func am_boden(feld: Node, name: String, fuss: Vector2, sekunden: float, groesse := 1.0, gespiegelt := false,
		halten := 0.0) -> FxBild:
	var hoehe := bilder(name)[0].get_height() * GROESSE * groesse
	return spawn(feld, name, fuss - Vector2(0, hoehe * 0.5), sekunden, gespiegelt, 0.0, groesse, halten)


## Ein Geschoss (Pfeil, Stern, Klinge) fliegt von "von" nach "nach", die Spitze zeigt in Flugrichtung.
## Mit "bogen" > 0 fliegt es im Bogen nach oben. Wartet, bis es angekommen ist.
static func flug(feld: Node, name: String, von: Vector2, nach: Vector2, sekunden: float, groesse := 1.0, bogen := 0.0) -> void:
	var fx := _neu(feld, name, von, groesse)
	fx._richte(nach - von)
	var tween := fx.create_tween()
	tween.tween_method(func(t: float) -> void:
		var ort := von.lerp(nach, t) + Vector2(0, -bogen * 4.0 * t * (1.0 - t))
		if t > 0.0:
			fx._richte(ort - fx.position)
		fx.position = ort
		fx.texture = fx._liste[int(t * sekunden * FLUG_TAKT) % fx._liste.size()], 0.0, 1.0, sekunden)
	await tween.finished
	fx.queue_free()


## Ein waagerecht gemaltes Band (Schneise) wird zwischen zwei Punkten aufgespannt.
static func streifen(feld: Node, name: String, von: Vector2, nach: Vector2, sekunden: float, dicke := 1.0) -> FxBild:
	var fx := spawn(feld, name, von.lerp(nach, 0.5), sekunden, false, (nach - von).angle())
	fx.scale = Vector2(von.distance_to(nach) / fx.texture.get_width(), GROESSE * dicke)
	return fx


## Dreht das Bild in Flugrichtung, ohne dass es auf dem Kopf steht.
func _richte(weg: Vector2) -> void:
	if weg.length_squared() < 0.01:
		return
	rotation = weg.angle()
	flip_v = weg.x < 0.0


func _zeige(nummer: int) -> void:
	texture = _liste[nummer]
