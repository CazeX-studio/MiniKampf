extends Node2D
## Foto der Leute-Köpfe (Teil U12) auf Leute-Körpern in fünf Richtungen. Ordner nach --
## Spalten: gerade von vorne, schräg von vorne, Seite, schräg von hinten, gerade von hinten.

const KOEPFE := ["v_m1", "v_m2", "v_m3", "v_w1", "v_w2", "v_w3", "a_m1", "a_m2", "a_w1", "a_w2", "k_m1", "k_w1"]
const KOERPER := {"v_m1": "grund_mann", "v_m2": "grund_handwerker", "v_m3": "grund_wache", "v_w1": "grund_frau",
		"v_w2": "grund_frau_korpulent", "v_w3": "grund_haendler", "a_m1": "grund_alter_mensch", "a_m2": "grund_gelehrter",
		"a_w1": "grund_alter_mensch", "a_w2": "grund_frau", "k_m1": "grund_kind", "k_w1": "grund_kind"}
const ANIMS := ["idle_gerade_vorn", "idle_vorn", "idle_welt_seite", "idle_hinten", "idle_gerade_hinten"]


func _ready() -> void:
	var ordner: String = OS.get_cmdline_user_args()[0]
	var bg := ColorRect.new()
	bg.color = Color("4f7a3a")
	bg.size = Vector2(1280, 720)
	add_child(bg)
	FigurTeile.art = FigurTeile.Art.KOPFBLATT
	for i in KOEPFE.size():
		FigurTeile.kopf = KOEPFE[i]
		for j in ANIMS.size():
			var t := FigurTeile.bild(KOERPER[KOEPFE[i]], ANIMS[j], 0)
			if t == null:
				continue
			var s := Sprite2D.new()
			s.texture = t
			s.scale = Vector2(0.7, 0.7)
			s.position = Vector2(60 + (i % 6) * 205 + j * 38, 150 + (i / 6) * 330)
			add_child(s)
		var l := Label.new()
		l.text = "%s (%s)" % [KOEPFE[i], KOERPER[KOEPFE[i]].trim_prefix("grund_")]
		l.position = Vector2(30 + (i % 6) * 205, 20 + (i / 6) * 330)
		add_child(l)
	await get_tree().create_timer(0.5).timeout
	get_viewport().get_texture().get_image().save_png(ordner + "/leute_koepfe.png")
	get_tree().quit()
