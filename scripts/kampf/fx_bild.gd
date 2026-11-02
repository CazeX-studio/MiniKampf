class_name FxBild
extends Sprite2D
## Effekt als gemalte Bildfolge (D9h): assets/fx/NAME_f0.png, _f1.png ... Spielt einmal ab und räumt sich auf.
## Bilder kommen aus tools/effekt_bilder.py. Abgelegte Bildfolgen werden pro Name nur einmal geladen.

const PFAD := "res://assets/fx/%s_f%d.png"
## Größe der Pixel im Kampfbild
const GROESSE := 2.0

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


static func spawn(feld: Node, name: String, ort: Vector2, sekunden: float, gespiegelt := false, winkel := 0.0) -> FxBild:
	var fx := FxBild.new()
	fx._liste = bilder(name)
	fx.texture = fx._liste[0]
	fx.position = ort
	fx.rotation = winkel
	fx.flip_h = gespiegelt
	fx.scale = Vector2.ONE * GROESSE
	fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fx.z_index = 8
	feld.add_child(fx)
	var tween := fx.create_tween()
	tween.tween_method(fx._zeige, 0, fx._liste.size() - 1, sekunden)
	tween.tween_callback(fx.queue_free)
	return fx


func _zeige(nummer: int) -> void:
	texture = _liste[nummer]
