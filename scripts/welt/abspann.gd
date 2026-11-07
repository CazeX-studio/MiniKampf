class_name Abspann
extends Control
## Abspann von Akt 1 (Ende der Kreuzweg-Demo): Abreise. Danach geht es mit demselben Spielstand weiter nach Grünwacht
## (Entscheidung 21.10.: In dieser Demo ist Grünwacht für alle die erste Region).

const SCREEN := Vector2(1280, 720)
## "" = Ende von Akt 1 (Kreuzweg), sonst Ende einer Region mit Rückblick auf die Entscheidungen ("gruenwacht", "glutoase")
static var variante := ""


func _ready() -> void:
	theme = Combat.make_theme()
	Musik.play("nacht")
	var bg := ColorRect.new()
	bg.color = Color("0b0d1a")
	bg.size = SCREEN
	add_child(bg)

	var klasse := SaveGame.get_flag("klasse")
	var data: Dictionary = Sandbox.CLASSES.get(klasse, {title = "Novize", region = "die Welt"})
	var extra: Dictionary = GameData.get_file("klassen").get(klasse, {})

	var box := VBoxContainer.new()
	box.position = Vector2(140, 150)
	box.size = Vector2(1000, 0)
	box.add_theme_constant_override("separation", 22)
	add_child(box)
	if REGIONEN.has(variante):
		_region(box, variante)
		return
	box.add_child(_label("Ende von Akt 1", 44, Color("f2c14e")))
	var journey := "Dein Weg führt hinaus in die Welt."
	if extra.has("lehrmeister"):
		var wohin: String = GameData.get_file("klassen").get("wohin", {}).get(data.region, "nach " + str(data.region))
		journey = "Dein Weg führt %s, zu %s." % [wohin, extra.lehrmeister]
	box.add_child(_label("Du verlässt Kreuzweg als %s.\n%s" % [data.title, journey], 24, Color.WHITE))
	box.add_child(_label("Hinter dir bleibt die Statue der Fünf zurück – und eine sechste Straße, die niemand benutzt.", 19, Color(1, 1, 1, 0.7)))
	# Gebaut sind Grünwacht und die Glutoase. Die Geschichte beginnt in der Glutoase (Marco, 07.11.): Nur Bogenschützen
	# und Zähmer lernen zuerst in Grünwacht, alle anderen reisen gleich in die Glutoase
	var glutoase: bool = data.region != "Grünwacht"
	if data.region not in ["Grünwacht", "Glutoase"]:
		box.add_child(_label("%s ist in dieser Demo noch nicht gebaut. Deine Reise beginnt deshalb in der Glutoase." % data.region, 19, Color(1, 1, 1, 0.7)))
	box.add_child(_label("Die Reise geht weiter: Folge der Südstraße in die Glutoase." if glutoase
			else "Die Reise geht weiter: Folge der Weststraße nach Grünwacht.", 22, Color("8affc1")))

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	box.add_child(row)
	var go := Button.new()
	go.text = "Weiter in die Glutoase" if glutoase else "Weiter nach Grünwacht"
	go.custom_minimum_size = Vector2(300, 60)
	go.add_theme_font_size_override("font_size", 20)
	go.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn"))
	row.add_child(go)
	var menu := Button.new()
	menu.text = "Zum Menü"
	menu.custom_minimum_size = Vector2(240, 60)
	menu.add_theme_font_size_override("font_size", 20)
	menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/menu.tscn"))
	row.add_child(menu)
	var again := Button.new()
	again.text = "Neu beginnen"
	again.custom_minimum_size = Vector2(240, 60)
	again.add_theme_font_size_override("font_size", 20)
	again.pressed.connect(func() -> void:
		SaveGame.delete()
		get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn"))
	row.add_child(again)


## Regionen mit eigenem Ende: Titel, Farbe und der Knopf zurück (Texte in data/texte.json: rueckblick_<region>,
## ende_<region>, ende_<region>_weiter)
const REGIONEN := {
	"gruenwacht": {titel = "Ende von Grünwacht", farbe = "a8e088", zurueck = "Zurück nach Wipfelheim"},
	"glutoase": {titel = "Ende der Glutoase", farbe = "ffb070", zurueck = "Zurück in die Glutoase"},
}


## Ende einer Region: Rückblick auf die eigenen Entscheidungen, dann zurück in die Welt.
func _region(box: VBoxContainer, region: String) -> void:
	var info: Dictionary = REGIONEN[region]
	box.position.y = 40
	box.add_theme_constant_override("separation", 16)
	box.add_child(_label(info.titel, 44, Color(info.farbe)))
	var flags: Dictionary = SaveGame.read_progress().get("flags", {})
	var lines: PackedStringArray = []
	for entry: Array in GameData.get_file("texte").get("rueckblick_" + region, []):
		if flags.has(entry[0]):
			lines.append("• " + str(entry[1]))
	box.add_child(_label("\n".join(lines), 20, Color.WHITE))
	box.add_child(_label(GameData.text("ende_" + region), 21, Color(1, 1, 1, 0.75)))
	var quests: Dictionary = SaveGame.read_progress().get("quests", {})
	# Die Demo endet erst nach beiden Regionen (Marco, 06.11.): vorher geht die Reise in die andere weiter
	if not demo_zu_ende(quests):
		box.add_child(_label(GameData.text("ende_%s_weiter" % region), 20, Color(1, 1, 1, 0.75)))
		box.add_child(_label(GameData.text("weiter_nach_" + ANDERE[region]), 22, Color("8affc1")))
		box.add_child(_knopf_reihe(info, true))
		return
	box.add_child(_label(GameData.text("demo_ende"), 21, Color("8affc1")))
	# Demo durchgespielt (S1): Tester-Code, einmal vergeben, und „Abschluss melden“ ins Formular
	var code := Tester.abschliessen(region)
	var name := Tester.spitzname() if Tester.spitzname() != "" else "Tester"
	box.add_child(_label("%s  %s" % [GameData.text("abschluss_text", [name]), code], 24, Color("f2c14e")))
	box.add_child(_label(GameData.text("abschluss_hinweis"), 17, Color(1, 1, 1, 0.7)))
	box.add_child(_knopf_reihe(info, Tester.gemeldet()))


## Letzter Auftrag jeder Region der Demo und die jeweils andere Region
const LETZTER_AUFTRAG := {"gruenwacht": "die_wahrheit", "glutoase": "miras_splitter"}
const ANDERE := {"gruenwacht": "glutoase", "glutoase": "gruenwacht"}


## Ist die Demo durch? Erst wenn beide Regionen zu Ende gespielt sind.
static func demo_zu_ende(quests: Dictionary) -> bool:
	for id: String in LETZTER_AUFTRAG.values():
		if str(quests.get(id, "neu")) != "abgegeben":
			return false
	return true


## Knöpfe am Ende einer Region. Am Ende der Demo erst nur „Abschluss melden“ (Marco, 06.11.), danach zurück
## oder ins Menü; wer schon gemeldet hat oder die Demo noch nicht durch hat, sieht gleich die Wege.
func _knopf_reihe(info: Dictionary, wege_offen: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 24)
	var weiter_knoepfe: Array[Button] = []
	for knopf: Array in [[info.zurueck, "res://scenes/kreuzweg.tscn"], ["Zum Menü", "res://scenes/menu.tscn"]]:
		var button := Button.new()
		button.text = knopf[0]
		button.custom_minimum_size = Vector2(260, 60)
		button.add_theme_font_size_override("font_size", 20)
		var target: String = knopf[1]
		button.pressed.connect(func() -> void:
			variante = ""
			get_tree().change_scene_to_file(target))
		button.visible = wege_offen
		weiter_knoepfe.append(button)
	if not wege_offen:
		var melden := Button.new()
		melden.text = GameData.text("abschluss_melden")
		melden.custom_minimum_size = Vector2(320, 60)
		melden.add_theme_font_size_override("font_size", 20)
		melden.pressed.connect(func() -> void:
			# Ohne Formular (noch nicht verbunden) geht es trotzdem weiter, sonst säße man fest
			if not Tester.formular_oeffnen("Demo durchgespielt", info.titel):
				Tester.hinweis_fenster(self, GameData.text("feedback_titel"), GameData.text("feedback_fehlt"))
			Tester.melden()
			melden.visible = false
			for b in weiter_knoepfe:
				b.visible = true)
		row.add_child(melden)
	for b in weiter_knoepfe:
		row.add_child(b)
	return row

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(1000, 0)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
