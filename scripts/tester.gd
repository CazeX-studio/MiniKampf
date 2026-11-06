class_name Tester
## Demo-Start (S1): Tester mit festem Spitznamen und eindeutiger Tester-Nummer, Feedback-Formular mit vorausgefüllten
## Feldern, Tester-Code beim Durchspielen (für eine spätere Belohnung, gilt nur, wenn er in Marcos Tabelle steht),
## Versionsnummer, Dankesliste. Dazu die Frage, ob Werkzeuge (Editor, Testknöpfe) gezeigt werden.
## Die Tester-Daten liegen getrennt vom Spielstand (bleiben bei „Neu beginnen“).

const DATEI := "user://tester.json"
## Buchstaben ohne Verwechslungsgefahr (kein I, O, 0, 1)
const ZEICHEN := "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
const NAME_MAX := 20

## Nur für die Prüfungen: andere Datei
static var datei := DATEI
## Nur für Fotos und Prüfungen: so tun, als wäre es die Demo im Web (ohne Werkzeuge, mit Spitznamen-Frage)
static var als_demo := false
static var _daten := {}
static var _geladen := false


## Editor und Testknöpfe: im Godot-Editor (Testversion) und in der Werkstatt-Fassung, nicht in der Demo.
static func werkzeuge() -> bool:
	if als_demo:
		return false
	return OS.is_debug_build() or OS.has_feature("werkstatt")


## Fragt das Spiel vor dem ersten Spielen nach dem Spitznamen? Nur in fertigen Fassungen (Demo und Werkstatt im Web).
static func spitzname_noetig() -> bool:
	return (als_demo or not OS.is_debug_build()) and spitzname() == ""


static func version() -> String:
	return str(GameData.get_file("version").get("version", "Entwicklung"))


static func _laden() -> void:
	if _geladen:
		return
	_geladen = true
	_daten = {}
	if FileAccess.file_exists(datei):
		var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(datei))
		if d is Dictionary:
			_daten = d


static func _speichern() -> void:
	var f := FileAccess.open(datei, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_daten, "\t"))


## Nur für die Prüfungen: Daten neu aus der Datei lesen
static func neu_laden() -> void:
	_geladen = false
	_laden()


static func spitzname() -> String:
	_laden()
	return str(_daten.get("spitzname", ""))


static func nummer() -> String:
	_laden()
	return str(_daten.get("nummer", ""))


static func code() -> String:
	_laden()
	return str(_daten.get("code", ""))


static func durchgespielt() -> bool:
	_laden()
	return bool(_daten.get("durchgespielt", false))


## Spitzname bereinigt (Leerzeichen am Rand weg, höchstens NAME_MAX Zeichen, keine Zeilenumbrüche)
static func bereinigen(text: String) -> String:
	return text.replace("\n", " ").strip_edges().left(NAME_MAX)


## Legt den Spitznamen einmal fest und vergibt die Tester-Nummer. Ein schon festgelegter Name bleibt.
static func festlegen(name: String) -> bool:
	_laden()
	var sauber := bereinigen(name)
	if sauber == "" or spitzname() != "":
		return false
	_daten.spitzname = sauber
	_daten.nummer = "T-" + zufall(6)
	_daten.seit = Time.get_date_string_from_system()
	_speichern()
	return true


## Demo durchgespielt (Ende von Grünwacht oder der Glutoase): Code einmal vergeben, danach immer derselbe.
static func abschliessen(region: String) -> String:
	_laden()
	if code() == "":
		_daten.code = "AST-%s-%s" % [zufall(4), zufall(4)]
		_daten.durchgespielt = true
		_daten.region = region
		_daten.am = Time.get_date_string_from_system()
		_speichern()
	return code()


static func zufall(laenge: int) -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var text := ""
	for i in laenge:
		text += ZEICHEN[rng.randi_range(0, ZEICHEN.length() - 1)]
	return text


## Link zum Feedback-Formular mit ausgefüllten Feldern. Vorlage in data/demo.json („formular_vorlage“): Marcos
## vorausgefüllter Link mit den Platzhaltern SPITZNAME, NUMMER, ART, CODE, VERSION, ORT. Leer = noch kein Formular.
static func formular_link(art: String, ort: String) -> String:
	var vorlage := str(GameData.get_file("demo").get("formular_vorlage", ""))
	if vorlage == "":
		return ""
	var werte := {SPITZNAME = spitzname(), NUMMER = nummer(), ART = art, CODE = code(), VERSION = version(), ORT = ort}
	for platzhalter: String in werte:
		vorlage = vorlage.replace("=" + platzhalter, "=" + str(werte[platzhalter]).uri_encode())
	return vorlage


## Formular im Browser öffnen. Gibt false zurück, wenn es noch kein Formular gibt.
static func formular_oeffnen(art: String, ort: String) -> bool:
	var link := formular_link(art, ort)
	if link == "":
		return false
	OS.shell_open(link)
	return true


## Spitznamen der Dankesliste (data/dankesliste.json)
static func dankesliste() -> Array:
	return GameData.get_file("dankesliste").get("namen", [])


# --- Fenster ------------------------------------------------------------------

## Fenster für den Spitznamen vor dem ersten Spielen. weiter wird nach dem Festlegen aufgerufen.
static func spitzname_fenster(eltern: Control, weiter: Callable) -> Control:
	var schatten := ColorRect.new()
	schatten.color = Color(0, 0, 0, 0.75)
	schatten.size = Vector2(1280, 720)
	eltern.add_child(schatten)
	var panel := PanelContainer.new()
	panel.position = Vector2(290, 150)
	panel.custom_minimum_size = Vector2(700, 0)
	schatten.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(_text(GameData.text("tester_titel"), 30, Color("f2c14e")))
	box.add_child(_text(GameData.text("tester_erklaerung", [NAME_MAX]), 19, Color.WHITE))
	var eingabe := LineEdit.new()
	eingabe.max_length = NAME_MAX
	eingabe.placeholder_text = GameData.text("tester_platzhalter")
	eingabe.custom_minimum_size = Vector2(0, 52)
	eingabe.add_theme_font_size_override("font_size", 22)
	box.add_child(eingabe)
	var fehler := _text("", 17, Color("ff8a7a"))
	box.add_child(fehler)
	var ok := Button.new()
	ok.text = GameData.text("tester_festlegen")
	ok.custom_minimum_size = Vector2(0, 56)
	ok.add_theme_font_size_override("font_size", 20)
	box.add_child(ok)
	var bestaetigen := func(_t := "") -> void:
		if not festlegen(eingabe.text):
			fehler.text = GameData.text("tester_leer")
			return
		schatten.queue_free()
		weiter.call()
	ok.pressed.connect(bestaetigen)
	eingabe.text_submitted.connect(bestaetigen)
	eingabe.grab_focus.call_deferred()
	return schatten


## Kleines Fenster mit Text und Schließen-Knopf (z. B. „Formular kommt noch“, Dankesliste)
static func hinweis_fenster(eltern: Control, titel: String, text: String, knoepfe: Array = []) -> Control:
	var schatten := ColorRect.new()
	schatten.color = Color(0, 0, 0, 0.7)
	schatten.size = Vector2(1280, 720)
	eltern.add_child(schatten)
	var panel := PanelContainer.new()
	panel.position = Vector2(240, 110)
	panel.custom_minimum_size = Vector2(800, 0)
	schatten.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(_text(titel, 28, Color("f2c14e")))
	box.add_child(_text(text, 19, Color.WHITE))
	var reihe := HBoxContainer.new()
	reihe.alignment = BoxContainer.ALIGNMENT_CENTER
	reihe.add_theme_constant_override("separation", 16)
	box.add_child(reihe)
	for k: Array in knoepfe + [[GameData.text("schliessen"), Callable()]]:
		var b := Button.new()
		b.text = k[0]
		b.custom_minimum_size = Vector2(220, 52)
		b.add_theme_font_size_override("font_size", 18)
		var aktion: Callable = k[1]
		b.pressed.connect(func() -> void:
			if aktion.is_valid():
				aktion.call()
			else:
				schatten.queue_free())
		reihe.add_child(b)
	return schatten


## Feedback geben: Formular öffnen oder sagen, dass es noch kommt
static func feedback(eltern: Control, ort: String) -> void:
	if not formular_oeffnen("Feedback", ort):
		hinweis_fenster(eltern, GameData.text("feedback_titel"), GameData.text("feedback_fehlt"))


static func _text(text: String, groesse: int, farbe: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", groesse)
	label.add_theme_color_override("font_color", farbe)
	return label
