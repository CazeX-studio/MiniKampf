extends Node2D
## Foto der Nebenfiguren-Köpfe (Teil U2a) auf ihren Körpern in fünf Richtungen. Ordner nach --
## Spalten: gerade von vorne, schräg von vorne, Seite, schräg von hinten, gerade von hinten.
## Edmar, Hagebutte, Hatta, Ilse und Zaid stehen in der Welt noch als ganze Figur: hier auf einem passenden Leute-Körper.

const KOERPER := {"borko": "grund_mann", "brom": "grund_wache", "edmar": "grund_mann", "hagebutte": "grund_alter_mensch",
		"hanne": "grund_frau", "hatta": "grund_haendler", "ilse": "grund_alter_mensch", "kobalt": "zaehmer_m",
		"layla": "grund_frau", "lene": "grund_gelehrter", "lotte": "grund_kind", "nadia": "grund_frau", "pip": "grund_kind",
		"quill": "grund_handwerker", "rashid": "grund_alter_mensch", "salbei": "grund_frau_korpulent",
		"tamm": "grund_alter_mensch", "tarek": "grund_haendler", "zaid": "grund_haendler"}
const ANIMS := ["idle_gerade_vorn", "idle_vorn", "idle_welt_seite", "idle_hinten", "idle_gerade_hinten"]


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	var bg := ColorRect.new()
	bg.color = Color("4f7a3a")
	bg.size = Vector2(1280, 720)
	add_child(bg)
	FigurTeile.art = FigurTeile.Art.KOPFBLATT
	var koepfe: Array = KOERPER.keys()
	for i in koepfe.size():
		FigurTeile.kopf = koepfe[i]
		for j in ANIMS.size():
			var t := FigurTeile.bild(KOERPER[koepfe[i]], ANIMS[j], 0)
			if t == null:
				continue
			var s := Sprite2D.new()
			s.texture = t
			s.scale = Vector2(0.45, 0.45)
			s.position = Vector2(40 + (i % 5) * 255 + j * 46, 100 + (i / 5) * 175)
			add_child(s)
		var l := Label.new()
		l.text = "%s (%s)" % [koepfe[i], str(KOERPER[koepfe[i]]).trim_prefix("grund_")]
		l.position = Vector2(20 + (i % 5) * 255, 8 + (i / 5) * 175)
		add_child(l)
	await get_tree().create_timer(0.5).timeout
	get_viewport().get_texture().get_image().save_png(ordner + "/nebenfiguren_koepfe.png")
	get_tree().quit()
