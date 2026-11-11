class_name KetteBild
extends RefCounted
## Gemalte Kette (GRAFIK_AUFTRAG.md Teil M, fx_kette_glied, A9c1): Stücke aus drei Gliedern, aneinandergereiht zwischen
## zwei Punkten. stufe 0 = kaltes Eisen, 1 = glimmt, 2 = glüht, 3 = weiß glühend.

const NAME := "kette_glied"


## Zeichnet die Kette auf "ci" (in dessen _draw bzw. draw-Signal). "groesse": Höhe wie im Bild mal groesse.
static func zeichnen(ci: CanvasItem, von: Vector2, bis: Vector2, stufe: int, groesse := 0.8, zittern := 0.0, deckung := 1.0) -> void:
	var bilder := FxBild.bilder(NAME)
	if bilder.is_empty() or von.distance_to(bis) < 1.0:
		return
	var tex: Texture2D = bilder[clampi(stufe, 0, bilder.size() - 1)]
	var weg := bis - von
	var anzahl := maxi(1, roundi(weg.length() / (tex.get_width() * groesse)))
	var stueck := weg.length() / anzahl
	var skala := Vector2(stueck / tex.get_width(), groesse)
	for i in anzahl:
		var ort := von + weg * ((i + 0.5) / anzahl)
		if zittern > 0.0:
			ort += Vector2(randf_range(-zittern, zittern), randf_range(-zittern, zittern))
		ci.draw_set_transform(ort, weg.angle(), skala)
		ci.draw_texture(tex, -tex.get_size() * 0.5, Color(1, 1, 1, deckung))
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
