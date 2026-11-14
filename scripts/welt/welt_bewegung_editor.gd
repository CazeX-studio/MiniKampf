class_name WeltBewegungEditor
extends Node2D
## Bewegungs-Editor in der Welt (S3b): eine Figur in allen vier Richtungen nebeneinander (nach links, nach rechts,
## schräg von vorne, schräg von hinten), stehen, laufen, liegen oder sitzen, im Tempo normal, langsam, sehr langsam
## oder Bild für Bild. Gezeigt wird mit derselben WorldCharacter-Anzeige wie im Spiel.
## Figuren: Novizen und Klassen-Körper mit jedem passenden Kopf, Baukasten-Körper mit Volks-Köpfen, alle Figuren der Welt.

const SCREEN := Vector2(1280, 720)
const ZEITLUPEN: Array[float] = [1.0, 0.3, 0.1]
const GRUPPEN := ["Novizen", "Klassen-Körper", "Baukasten-Körper", "Figuren aus der Welt"]
const RICHTUNGEN := [["Nach links", -1, false, false], ["Nach rechts", 1, false, false],
		["Schräg von vorne", 1, true, false], ["Schräg von hinten", 1, true, true]]
const BEWEGUNGEN := [["Stehen", "stehen"], ["Laufen", "laufen"], ["Liegen", "liegen"], ["Sitzen", "sitzen"]]
const KLASSEN_NAMEN := {"bogen": "Bogenschütze", "zaehmer": "Monster-Zähmer", "klingentaenzer": "Klingentänzer",
		"schmied": "Rüstungsschmied", "saengerin": "Sternensängerin"}
## Größer als im Spiel, damit man Einzelheiten sieht
const ZOOM := 1.6

## Gewählt (bleibt beim Neuaufbau)
static var gruppe := 0
static var figur := ""
static var kopf := ""
static var bewegung := "laufen"
static var zeitlupe := 0
static var bild_fuer_bild := false
static var bild := 0

var _figuren: Array[WorldCharacter] = []
var _hinweise: Array[Label] = []
var _bild_text: Label
var _leiste: VBoxContainer


func _ready() -> void:
	Engine.time_scale = ZEITLUPEN[zeitlupe]
	var boden := ColorRect.new()
	boden.color = Color("4f7a3a")
	boden.size = SCREEN
	add_child(boden)
	var streifen := ColorRect.new()
	streifen.color = Color("8a6d45")
	streifen.position = Vector2(0, 330)
	streifen.size = Vector2(SCREEN.x, 70)
	add_child(streifen)
	if figur == "" or not _figuren_der_gruppe().has(figur):
		figur = _figuren_der_gruppe()[0] if not _figuren_der_gruppe().is_empty() else ""
	_figuren_bauen()
	_leiste_bauen()


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _process(_delta: float) -> void:
	for i in _figuren.size():
		var f := _figuren[i]
		f.festes_bild = bild if bild_fuer_bild else -1
		var anzahl := f.bild_anzahl()
		_hinweise[i].text = "%s\n%s: %d Bilder" % [RICHTUNGEN[i][0], _anim_name(f.aktuelle_anim), anzahl]
	if _bild_text != null:
		var anzahl := _figuren[0].bild_anzahl() if not _figuren.is_empty() else 0
		_bild_text.text = "Bild %d" % (bild + 1) if bild_fuer_bild else "läuft"
		if bild_fuer_bild and anzahl > 0:
			_bild_text.text += " (je Richtung %s)" % " / ".join(PackedStringArray(_figuren.map(
					func(f: WorldCharacter) -> String: return str(bild % maxi(f.bild_anzahl(), 1) + 1))))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_ESCAPE:
			_zurueck()
		elif event.physical_keycode in [KEY_RIGHT, KEY_D]:
			_schritt(1)
		elif event.physical_keycode in [KEY_LEFT, KEY_A]:
			_schritt(-1)


## Welche Bilder gerade laufen, in Worten (für die Anzeige unter jeder Figur)
static func _anim_name(anim: String) -> String:
	var name := "Laufen" if anim.begins_with("run") else ("Liegen" if anim == "liegen" else ("Sitzen" if anim.begins_with("sitzen") else "Stehen"))
	if anim.ends_with("_vorn"):
		name += " (Bilder von vorne)"
	elif anim.ends_with("_hinten"):
		name += " (Bilder von hinten)"
	else:
		name += " (Bilder von der Seite)"
	return name


# --- Auswahl der Figuren ------------------------------------------------------

## Kennungen der Figuren in der gewählten Gruppe.
static func _figuren_der_gruppe() -> Array:
	var liste: Array = []
	if gruppe == 3:
		return welt_figuren().keys()
	for k: String in FigurTeile.koerper_liste():
		var art := k.get_slice("_", 0)
		if gruppe == 0 and art == "novize" or gruppe == 1 and KLASSEN_NAMEN.has(art) or gruppe == 2 and art == "grund":
			liste.append(k)
	liste.sort()
	return liste


## Alle Aussehen der Figuren in der Welt (Kreuzweg und alle Karten): Aussehen -> Anzeigename.
static func welt_figuren() -> Dictionary:
	var liste := {}
	var alle: Array = [GameData.get_file("kreuzweg").get("npcs", {})]
	var karten := GameData.get_file("karten")
	for id: String in karten:
		if karten[id] is Dictionary:
			alle.append(karten[id].get("npcs", {}))
	for npcs: Dictionary in alle:
		for id: String in npcs:
			var look := str(npcs[id].get("aussehen", ""))
			if look != "" and not liste.has(look):
				liste[look] = str(npcs[id].get("name", id))
	var sortiert := {}
	var keys := liste.keys()
	keys.sort_custom(func(a: String, b: String) -> bool: return str(liste[a]).naturalnocasecmp_to(str(liste[b])) < 0)
	for k: String in keys:
		sortiert[k] = liste[k]
	return sortiert


static func _figur_name(id: String) -> String:
	if gruppe == 3:
		return "%s (%s)" % [welt_figuren().get(id, id), id]
	var teile := id.split("_")
	var art: String = teile[0]
	var geschlecht := " (m)" if teile[-1] == "m" else (" (w)" if teile[-1] == "w" else "")
	if KLASSEN_NAMEN.has(art):
		return str(KLASSEN_NAMEN[art]) + geschlecht
	if art == "novize":
		return "Novize" + geschlecht
	return str(FigurTeile.koerper_liste().get(id, id))


## Köpfe, die zur gewählten Figur passen (Novizen und Klassen: die wählbaren, Baukasten: alle).
static func _koepfe() -> Array:
	if gruppe == 3:
		return []
	var liste: Array = FigurTeile.passende_koepfe(figur) if gruppe < 2 else FigurTeile.koepfe(figur).keys()
	if liste.is_empty():
		liste = FigurTeile.koepfe(figur).keys()
	liste.sort()
	return liste


## Das Aussehen, das gezeigt wird: Körper+Kopf oder die Figur aus der Welt.
static func aussehen() -> String:
	if gruppe == 3:
		return figur
	var koepfe := _koepfe()
	if not kopf in koepfe:
		kopf = koepfe[0] if not koepfe.is_empty() else ""
	return figur + ("+" + kopf if kopf != "" else "")


# --- Figuren ------------------------------------------------------------------

func _figuren_bauen() -> void:
	for f in _figuren:
		f.queue_free()
	for l in _hinweise:
		l.queue_free()
	_figuren.clear()
	_hinweise.clear()
	if figur == "":
		return
	var look := aussehen()
	for i in RICHTUNGEN.size():
		var r: Array = RICHTUNGEN[i]
		var f := WorldCharacter.new()
		f.setup(look, look)
		f.position = Vector2(170 + i * 300, 370)
		f.scale = Vector2(ZOOM, ZOOM)
		f.facing = int(r[1])
		f.richtungen = bool(r[2]) or f.richtungen
		f.hinten = bool(r[3])
		f.moving = bewegung == "laufen"
		f.liegt = bewegung == "liegen"
		f.sitzt = bewegung == "sitzen"
		f.idle_fps = 6.0
		add_child(f)
		_figuren.append(f)
		var hinweis := Label.new()
		hinweis.position = Vector2(f.position.x - 140, 400)
		hinweis.size = Vector2(280, 50)
		hinweis.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hinweis.add_theme_font_size_override("font_size", 15)
		hinweis.add_theme_color_override("font_outline_color", Color.BLACK)
		hinweis.add_theme_constant_override("outline_size", 6)
		add_child(hinweis)
		_hinweise.append(hinweis)


# --- Leiste unten -------------------------------------------------------------

func _leiste_bauen() -> void:
	var ebene := CanvasLayer.new()
	ebene.layer = 10
	add_child(ebene)
	var titel := Label.new()
	titel.text = "Bewegungen in der Welt"
	titel.position = Vector2(20, 12)
	titel.add_theme_font_size_override("font_size", 28)
	titel.add_theme_color_override("font_color", Color("f2c14e"))
	titel.add_theme_color_override("font_outline_color", Color.BLACK)
	titel.add_theme_constant_override("outline_size", 8)
	ebene.add_child(titel)
	var zurueck := _klein("Zurück zum Editor", 200)
	zurueck.position = Vector2(1060, 14)
	zurueck.pressed.connect(_zurueck)
	ebene.add_child(zurueck)

	var panel := PanelContainer.new()
	panel.theme = Combat.make_theme()
	panel.position = Vector2(4, 512)
	panel.size = Vector2(1272, 204)
	ebene.add_child(panel)
	var spalten := HBoxContainer.new()
	spalten.add_theme_constant_override("separation", 14)
	panel.add_child(spalten)

	var wahl := _spalte(spalten, "Figur", 300)
	wahl.add_child(_auswahl(GRUPPEN, gruppe, func(i: int) -> void:
		gruppe = i
		figur = ""
		kopf = ""
		get_tree().reload_current_scene()))
	var figuren := _figuren_der_gruppe()
	wahl.add_child(_auswahl(figuren.map(func(f: String) -> String: return _figur_name(f)), figuren.find(figur),
			func(i: int) -> void:
				figur = figuren[i]
				get_tree().reload_current_scene()))
	var koepfe := _koepfe()
	if not koepfe.is_empty():
		aussehen()
		wahl.add_child(_auswahl(koepfe.map(func(k: String) -> String: return "Kopf: %s" % FigurTeile.koepfe(figur).get(k, {}).get("name", k)),
				koepfe.find(kopf), func(i: int) -> void:
					kopf = koepfe[i]
					_figuren_bauen()))

	var bewegt := _spalte(spalten, "Bewegung", 230)
	var raster := GridContainer.new()
	raster.columns = 2
	bewegt.add_child(raster)
	for b: Array in BEWEGUNGEN:
		var knopf := _klein(str(b[0]), 110)
		knopf.toggle_mode = true
		knopf.button_pressed = bewegung == b[1]
		var art: String = b[1]
		knopf.pressed.connect(func() -> void:
			bewegung = art
			get_tree().reload_current_scene())
		raster.add_child(knopf)

	var tempo := _spalte(spalten, "Tempo", 360)
	var tempo_reihe := HBoxContainer.new()
	tempo.add_child(tempo_reihe)
	for i in ZEITLUPEN.size():
		var knopf := _klein(["normal", "langsam", "sehr langsam"][i], 116)
		knopf.toggle_mode = true
		knopf.button_pressed = zeitlupe == i and not bild_fuer_bild
		var stufe := i
		knopf.pressed.connect(func() -> void:
			zeitlupe = stufe
			bild_fuer_bild = false
			get_tree().reload_current_scene())
		tempo_reihe.add_child(knopf)
	var schritt_reihe := HBoxContainer.new()
	tempo.add_child(schritt_reihe)
	var anhalten := _klein("Bild für Bild", 140)
	anhalten.toggle_mode = true
	anhalten.button_pressed = bild_fuer_bild
	anhalten.pressed.connect(func() -> void:
		bild_fuer_bild = not bild_fuer_bild
		bild = 0
		get_tree().reload_current_scene())
	schritt_reihe.add_child(anhalten)
	var vor := _klein("◀", 50)
	vor.pressed.connect(func() -> void: _schritt(-1))
	schritt_reihe.add_child(vor)
	var weiter := _klein("▶", 50)
	weiter.pressed.connect(func() -> void: _schritt(1))
	schritt_reihe.add_child(weiter)
	vor.disabled = not bild_fuer_bild
	weiter.disabled = not bild_fuer_bild
	_bild_text = Label.new()
	_bild_text.add_theme_font_size_override("font_size", 14)
	tempo.add_child(_bild_text)

	var info := _spalte(spalten, "Hinweis", 300)
	var text := Label.new()
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(300, 0)
	text.add_theme_font_size_override("font_size", 13)
	text.text = "Im Spiel laufen Figuren mit Seiten-Bildern nach links und rechts; die Bilder von vorne und hinten " \
			+ "nutzt bisher nur der Baukasten. Bild für Bild: mit ◀ ▶ oder den Pfeiltasten blättern. " \
			+ "Hat eine Figur keine eigenen Bilder für eine Bewegung, zeigt sie die nächstbeste."
	info.add_child(text)


func _schritt(richtung: int) -> void:
	if not bild_fuer_bild:
		bild_fuer_bild = true
		bild = 0
		get_tree().reload_current_scene()
		return
	var anzahl := 1
	for f in _figuren:
		anzahl = maxi(anzahl, f.bild_anzahl())
	bild = posmod(bild + richtung, anzahl * 8)


func _zurueck() -> void:
	get_tree().change_scene_to_file("res://scenes/editor.tscn")


# --- Bausteine (wie im Bewegungs-Editor S3a) -----------------------------------

func _spalte(eltern: Node, titel: String, breite: float) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.custom_minimum_size = Vector2(breite, 0)
	var kopfzeile := Label.new()
	kopfzeile.text = titel
	kopfzeile.add_theme_font_size_override("font_size", 16)
	kopfzeile.add_theme_color_override("font_color", Color("f2c14e"))
	box.add_child(kopfzeile)
	eltern.add_child(box)
	return box


func _auswahl(eintraege: Array, gewaehlt: int, aktion: Callable) -> OptionButton:
	var k := OptionButton.new()
	for e in eintraege:
		k.add_item(str(e))
	k.select(maxi(0, gewaehlt))
	k.custom_minimum_size = Vector2(290, 32)
	k.clip_text = true
	k.fit_to_longest_item = false
	k.add_theme_font_size_override("font_size", 14)
	k.focus_mode = Control.FOCUS_NONE
	k.item_selected.connect(aktion)
	return k


func _klein(text: String, breite := 210.0) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(breite, 32)
	b.add_theme_font_size_override("font_size", 14)
	b.focus_mode = Control.FOCUS_NONE
	b.clip_text = true
	return b
