extends Control
## Spielstand-Editor (S5): Stufe, Klasse, Gold und Gegenstände setzen und an jede Stelle der Geschichte springen
## (Sprung). Arbeitet mit dem Editor-Spielstand (wie „Demo testen“ im Editor) oder, wenn gewählt, mit dem eigenen.
## „Spielen“ speichert und startet die Welt mit diesem Spielstand.

const SCREEN := Vector2(1280, 720)
const GOLD_SCHRITTE: Array[int] = [-1000, -100, 100, 1000]

## Welcher Spielstand bearbeitet wird (bleibt beim Neuladen der Szene)
static var speicher := "user://spielstand_editor.json"

var world: WorldState
var p: PlayerState
var klasse := ""

var _stand: Label
var _meldung: Label
var _ziel_wahl: OptionButton
var _klasse_wahl: OptionButton
var _gegenstand_wahl: OptionButton
var _gegenstaende: Array = []
var _klassen: Array[String] = [""]


func _ready() -> void:
	theme = Combat.make_theme()
	Tageszeit.feste_stunde = 12.0
	add_child(Backdrop.new())
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.05, 0.8)
	shade.size = SCREEN
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	_laden()
	_bauen()
	_zeigen()


func _exit_tree() -> void:
	Tageszeit.feste_stunde = -1.0


func _laden() -> void:
	world = WorldState.new()
	p = world.add_player("spieler", "Du", "novize_w+w1", WorldState.start_cell())
	var alter_pfad := SaveGame.path
	SaveGame.path = speicher
	if not SaveGame.load_into(p):
		# Noch kein Spielstand: Kreuzweg ist erreicht, Ye wartet
		Sprung.springen(world, p, "zu_ye", "")
	SaveGame.path = alter_pfad
	world.fix_position(p)
	klasse = str(p.progress.flags.get("klasse", ""))


# --- Ändern (auch für die Prüfungen) ----------------------------------------------

func klasse_setzen(neu: String) -> void:
	klasse = neu
	if _klasse_wahl != null and _klasse_wahl.selected != _klassen.find(neu):
		_klasse_wahl.select(maxi(0, _klassen.find(neu)))
	_meldung_setzen("Klasse gewählt. Sie gilt ab dem nächsten Sprung (nach der Abreise).")
	_ziele_fuellen()
	_zeigen()


func springen_zu(ziel: String) -> void:
	Sprung.springen(world, p, ziel, klasse)
	_stufe_klasse_angleichen()
	_meldung_setzen("Gesprungen: %s" % Sprung.titel(ziel))
	_zeigen()


func stufe_setzen(stufe: int) -> void:
	var tabelle := GameData.level_xp()
	stufe = clampi(stufe, 1, tabelle.size())
	p.progress.level = stufe
	p.progress.xp = int(tabelle[stufe - 1])
	_stufe_klasse_angleichen()
	_zeigen()


## Wer seine Klasse gelernt hat, bekommt die Klassenstufe passend zur Stufe (für die Fähigkeiten-Punkte)
func _stufe_klasse_angleichen() -> void:
	if p.progress.flags.has("klasse_gelernt"):
		p.progress.klassen_xp = p.progress.xp


func gold_dazu(menge: int) -> void:
	p.progress.gold = maxi(0, p.progress.gold + menge)
	_zeigen()


func gegenstand_dazu(id: String, anzahl: int) -> void:
	var platz := 0
	for i in anzahl:
		if not p.progress.has_room(id):
			break
		p.progress.add_item(id, 1)
		platz += 1
	_meldung_setzen("%d × %s in die Tasche%s" % [platz, GameData.item_name(id), "" if platz == anzahl else " (Tasche voll)"])
	_zeigen()


func speichern() -> void:
	var alter_pfad := SaveGame.path
	SaveGame.path = speicher
	SaveGame.save(p)
	SaveGame.path = alter_pfad
	_meldung_setzen("Gespeichert.")


func spielen() -> void:
	speichern()
	SaveGame.path = speicher
	get_tree().change_scene_to_file("res://scenes/kreuzweg.tscn")


# --- Anzeige --------------------------------------------------------------------

func _zeigen() -> void:
	if _stand == null:
		return
	var aktiv: Array = []
	for q: String in p.progress.quests:
		if p.progress.quests[q] in ["aktiv", "fertig"]:
			aktiv.append(str(GameData.quest(q).get("titel", q)))
	var naechster := ""
	for q: String in Sprung.pfad(str(p.progress.flags.get("klasse", ""))):
		if p.progress.quest_state(q) == "neu":
			naechster = str(GameData.quest(q).get("titel", q))
			break
	var k := str(p.progress.flags.get("klasse", ""))
	var kampf := p.progress.battle_class()
	_stand.text = "Stufe %d   ·   Gold %d   ·   Ort: %s (Feld %d, %d)\nKlasse: %s%s\nAktive Aufträge: %s\nAls Nächstes: %s" % [
		p.progress.level, p.progress.gold, world.get_map(p.map).title, p.cell.x, p.cell.y,
		_klassen_name(k) if k != "" else "noch keine (Novize)", "" if k == "" or kampf == k else " (noch nicht gelernt)",
		", ".join(aktiv) if not aktiv.is_empty() else "keine", naechster if naechster != "" else "–"]


func _klassen_name(k: String) -> String:
	return str(Sandbox.CLASSES[k].title) if Sandbox.CLASSES.has(k) else "Novize"


func _meldung_setzen(text: String) -> void:
	if _meldung != null:
		_meldung.text = text


func _ziele_fuellen() -> void:
	if _ziel_wahl == null:
		return
	_ziel_wahl.clear()
	for q: String in Sprung.pfad(klasse):
		_ziel_wahl.add_item(Sprung.titel(q))


func _bauen() -> void:
	_titel("Spielstand-Editor", 40, Vector2(0, 16), SCREEN.x)
	var wahl := _knopf("", Vector2(40, 80), Vector2(560, 44), func() -> void: pass)
	wahl.text = "Bearbeitet: %s (wechseln)" % ("Editor-Spielstand" if speicher != SaveGame.DEFAULT_PATH else "DEIN SPIELSTAND")
	wahl.pressed.connect(func() -> void:
		speicher = SaveGame.DEFAULT_PATH if speicher != SaveGame.DEFAULT_PATH else "user://spielstand_editor.json"
		get_tree().reload_current_scene())
	_stand = Label.new()
	_stand.position = Vector2(40, 136)
	_stand.size = Vector2(1200, 110)
	_stand.add_theme_font_size_override("font_size", 18)
	_stand.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_stand)

	# Linke Spalte: Klasse und Sprung
	_titel("1. Klasse (gilt ab der Abreise)", 20, Vector2(40, 260), 560)
	for k: String in Sprung.KLASSEN_GLUTOASE + Sprung.KLASSEN_GRUENWACHT:
		_klassen.append(k)
	_klasse_wahl = _auswahl(_klassen.map(func(k: String) -> String: return _klassen_name(k)), Vector2(40, 296), 560)
	_klasse_wahl.select(maxi(0, _klassen.find(klasse)))
	_klasse_wahl.item_selected.connect(func(i: int) -> void: klasse_setzen(_klassen[i]))
	_titel("2. Springen zu (alles davor gilt als erledigt)", 20, Vector2(40, 350), 560)
	_ziel_wahl = _auswahl([], Vector2(40, 386), 560)
	_ziele_fuellen()
	_knopf("Hierhin springen", Vector2(40, 436), Vector2(560, 50), func() -> void:
		springen_zu(Sprung.pfad(klasse)[_ziel_wahl.selected]))

	# Rechte Spalte: Stufe, Gold, Gegenstände
	_titel("Stufe", 20, Vector2(680, 260), 560)
	_knopf("−", Vector2(680, 296), Vector2(60, 44), func() -> void: stufe_setzen(p.progress.level - 1))
	_knopf("+", Vector2(748, 296), Vector2(60, 44), func() -> void: stufe_setzen(p.progress.level + 1))
	_knopf("Stufe 10", Vector2(816, 296), Vector2(120, 44), func() -> void: stufe_setzen(10))
	_knopf("Stufe 15", Vector2(944, 296), Vector2(120, 44), func() -> void: stufe_setzen(15))
	_knopf("Stufe 20", Vector2(1072, 296), Vector2(120, 44), func() -> void: stufe_setzen(20))
	_titel("Gold", 20, Vector2(680, 350), 560)
	for i in GOLD_SCHRITTE.size():
		var menge := GOLD_SCHRITTE[i]
		_knopf("%+d" % menge, Vector2(680 + i * 128, 386), Vector2(120, 44), func() -> void: gold_dazu(menge))
	_titel("Gegenstand in die Tasche", 20, Vector2(680, 440), 560)
	_gegenstaende = GameData.get_file("gegenstaende").keys().filter(func(id: String) -> bool:
		return not id.begins_with("testkiesel") and GameData.get_file("gegenstaende")[id] is Dictionary)
	_gegenstaende.sort_custom(func(a: String, b: String) -> bool: return GameData.item_name(a).naturalnocasecmp_to(GameData.item_name(b)) < 0)
	_gegenstand_wahl = _auswahl(_gegenstaende.map(func(id: String) -> String: return GameData.item_name(id)), Vector2(680, 476), 330)
	_knopf("+1", Vector2(1018, 476), Vector2(80, 44), func() -> void: gegenstand_dazu(_gegenstaende[_gegenstand_wahl.selected], 1))
	_knopf("+10", Vector2(1106, 476), Vector2(86, 44), func() -> void: gegenstand_dazu(_gegenstaende[_gegenstand_wahl.selected], 10))

	_meldung = Label.new()
	_meldung.position = Vector2(40, 540)
	_meldung.size = Vector2(1200, 40)
	_meldung.add_theme_font_size_override("font_size", 16)
	_meldung.add_theme_color_override("font_color", Color("8affc1"))
	add_child(_meldung)
	_knopf("Spielen", Vector2(40, 600), Vector2(360, 70), spielen)
	_knopf("Speichern", Vector2(420, 600), Vector2(240, 70), speichern)
	_knopf("Zurück zum Editor", Vector2(680, 600), Vector2(300, 70), func() -> void:
		get_tree().change_scene_to_file("res://scenes/editor.tscn"))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		get_tree().change_scene_to_file("res://scenes/editor.tscn")


func _titel(text: String, groesse: int, pos: Vector2, breite: float) -> void:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = Vector2(breite, groesse + 12)
	l.add_theme_font_size_override("font_size", groesse)
	l.add_theme_color_override("font_color", Color("f2c14e"))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if breite >= SCREEN.x else HORIZONTAL_ALIGNMENT_LEFT
	add_child(l)


func _auswahl(eintraege: Array, pos: Vector2, breite: float) -> OptionButton:
	var k := OptionButton.new()
	for e in eintraege:
		k.add_item(str(e))
	if not eintraege.is_empty():
		k.select(0)
	k.position = pos
	k.size = Vector2(breite, 44)
	k.clip_text = true
	k.fit_to_longest_item = false
	k.add_theme_font_size_override("font_size", 17)
	k.focus_mode = Control.FOCUS_NONE
	add_child(k)
	return k


func _knopf(text: String, pos: Vector2, groesse: Vector2, aktion: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = groesse
	b.add_theme_font_size_override("font_size", 18)
	b.focus_mode = Control.FOCUS_NONE
	b.pressed.connect(aktion)
	add_child(b)
	return b
