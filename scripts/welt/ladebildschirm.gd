class_name Ladebildschirm
extends CanvasLayer
## Ladebildschirm mit den gemalten Szenen (A20, GRAFIK_AUFTRAG.md Teil S, design.md Tagebuch 11.11.):
## Beim Spielstart und beim Wechsel in eine andere Region (Kreuzweg, Grünwacht, Glutoase) oder in einen Dungeon zeigt das
## Spiel kurz ein Szenenbild bildschirmfüllend, darauf groß den Ortsnamen und einen kurzen Tipp. Antippen oder eine
## Taste schließt es früher. Innerhalb einer Region (z. B. Glutoase → Palmenrast) und nach einem Kampf kommt es nicht.
## Bildwahl: Vor der Klassenwahl beim ersten Mal das Gruppenbild, sonst zufällig; nach der Klassenwahl meist die
## Szene der eigenen Klasse. Bilder und Tipps: data/ladebildschirm.json, Bilder in assets/ladebildschirme/.

const ORDNER := "res://assets/ladebildschirme/%s.png"
const SCHRIFT := "res://assets/schrift/Cinzel.ttf"
const SCREEN := Vector2(1280, 720)
## So lange steht das Bild, dann blendet es aus (Sekunden)
const STEHT := 2.4
const AUSBLENDEN := 0.6
## Nach der Klassenwahl: so oft kommt die Szene der eigenen Klasse
const EIGENE_KLASSE := 0.6

## Zuletzt gezeigte Region bzw. Dungeon ("" = in diesem Spiel noch keiner, also Spielstart)
static var _zuletzt := ""
## Zum Abschalten (z. B. Fotos aus dem Spiel)
static var aus := false

var _fertig := false


## Prüft, ob beim Betreten von "karte" ein Ladebildschirm kommt, und zeigt ihn. Gibt true zurück, wenn er kommt
## (dann steht der Ortsname schon darauf).
static func pruefen(welt: Node, karte: String, titel: String) -> bool:
	var ort := ort_von(karte)
	if ort == "" or ort == _zuletzt:
		return false
	var erster := _zuletzt == ""
	_zuletzt = ort
	if aus or DisplayServer.get_name() == "headless":
		return false
	var bild := bild_waehlen(erster, SaveGame.get_flag("klasse"))
	if not ResourceLoader.exists(ORDNER % bild):
		return false
	var schirm := Ladebildschirm.new()
	schirm.layer = 90
	welt.add_child(schirm)
	schirm._aufbauen(load(ORDNER % bild), titel, _tipp())
	return true


## Nächstes Betreten der Welt zählt wieder als Spielstart (aus dem Menü).
static func zuruecksetzen() -> void:
	_zuletzt = ""


## Wofür ein Ladebildschirm kommt: die Region der Karte, bei Dungeons die Karte selbst ("" = gar nicht, z. B. Innenräume).
static func ort_von(karte: String) -> String:
	var eintrag: Dictionary = GameData.get_file("weltkarte").get("karten", {}).get(karte, {})
	if eintrag.is_empty():
		return ""
	return karte if str(eintrag.get("art", "")) == "dungeon" else str(eintrag.get("region", ""))


## Welches Szenenbild: beim ersten Mal ohne Klasse das Gruppenbild, mit Klasse meist ihre Szene, sonst zufällig.
static func bild_waehlen(erster: bool, klasse: String) -> String:
	var daten: Dictionary = GameData.get_file("ladebildschirm")
	var bilder: Array = daten.get("bilder", ["gruppe"])
	var eigene := str(daten.get("klassen", {}).get(klasse, ""))
	if eigene != "" and randf() < EIGENE_KLASSE:
		return eigene
	if erster and eigene == "":
		return "gruppe"
	return str(bilder.pick_random())


static func _tipp() -> String:
	var tipps: Array = GameData.get_file("ladebildschirm").get("tipps", [])
	return "" if tipps.is_empty() else str(tipps.pick_random())


func _aufbauen(bild: Texture2D, titel: String, tipp: String) -> void:
	var ebene := Control.new()
	ebene.size = SCREEN
	ebene.mouse_filter = Control.MOUSE_FILTER_STOP
	ebene.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed or event is InputEventScreenTouch and event.pressed:
			_schliessen())
	add_child(ebene)
	var grund := ColorRect.new()
	grund.color = Color.BLACK
	grund.size = SCREEN
	grund.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ebene.add_child(grund)
	var szene := TextureRect.new()
	szene.texture = bild
	szene.size = SCREEN
	szene.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	szene.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	szene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ebene.add_child(szene)
	# Dunkler Verlauf unten, damit Name und Tipp lesbar sind
	var verlauf := TextureRect.new()
	var farben := Gradient.new()
	farben.colors = PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.85)])
	var textur := GradientTexture2D.new()
	textur.gradient = farben
	textur.fill_from = Vector2(0, 0)
	textur.fill_to = Vector2(0, 1)
	verlauf.texture = textur
	verlauf.position = Vector2(0, SCREEN.y - 260)
	verlauf.size = Vector2(SCREEN.x, 260)
	verlauf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ebene.add_child(verlauf)
	var name := Label.new()
	var schrift := FontVariation.new()
	schrift.base_font = load(SCHRIFT)
	schrift.variation_embolden = 0.6
	name.add_theme_font_override("font", schrift)
	name.add_theme_font_size_override("font_size", 58)
	name.add_theme_color_override("font_color", Color("f6d27a"))
	name.add_theme_color_override("font_outline_color", Color("1a1208"))
	name.add_theme_constant_override("outline_size", 10)
	name.text = titel
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.position = Vector2(0, SCREEN.y - 190)
	name.size = Vector2(SCREEN.x, 80)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ebene.add_child(name)
	var hinweis := Label.new()
	hinweis.text = tipp
	hinweis.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hinweis.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hinweis.add_theme_font_size_override("font_size", 20)
	hinweis.add_theme_color_override("font_color", Color("f4e6d0"))
	hinweis.add_theme_color_override("font_outline_color", Color.BLACK)
	hinweis.add_theme_constant_override("outline_size", 6)
	hinweis.position = Vector2(140, SCREEN.y - 100)
	hinweis.size = Vector2(SCREEN.x - 280, 70)
	hinweis.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ebene.add_child(hinweis)
	# Langsames Heranfahren an das Bild, dann ausblenden
	szene.pivot_offset = SCREEN * 0.5
	create_tween().tween_property(szene, "scale", Vector2.ONE * 1.04, STEHT + AUSBLENDEN)
	var warten := create_tween()
	warten.tween_interval(STEHT)
	warten.tween_callback(_schliessen)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		_schliessen()


func _schliessen() -> void:
	if _fertig:
		return
	_fertig = true
	var ebene := get_child(0) as Control
	ebene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween := create_tween()
	tween.tween_property(ebene, "modulate:a", 0.0, AUSBLENDEN)
	tween.tween_callback(queue_free)
