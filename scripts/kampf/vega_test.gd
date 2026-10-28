extends Node
## Figuren-Animationen (Editor): ein kleiner Testkampf, in dem man jede Animation der gewählten eigenen Figur
## (Vega, Kofi …, siehe FigurWahl) per Knopf abspielen kann.
## Der Kampf selbst läuft nicht weiter (es geht nur ums Anschauen). Zeitlupe hilft, einzelne Bilder zu prüfen.

const ZEITLUPE := 0.3
const ART_NAMEN: Array[String] = ["Bilder: ganz", "Bilder: aus Teilen", "Bilder: Standardkopf"]

var _combat: Node
var _vega: FighterView
var _enemy: Fighter
var _slow := false
var _slow_button: Button


func _ready() -> void:
	BattleRequest.player_look = FigurWahl.gewaehlt()
	BattleRequest.prepare("wild:0", 10, 2, "")
	# Falls der Kampf doch endet: zurück in den Editor, nichts wird verbucht
	BattleRequest.return_scene = "res://scenes/editor.tscn"
	_combat = load("res://scenes/kampf.tscn").instantiate()
	add_child(_combat)
	_build_buttons()


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	_slow = false
	BattleRequest.kampf_id = ""
	BattleRequest.result = {}
	BattleRequest.player_look = ""


## Vega und den Gegner suchen (erst nachdem der Kampfbildschirm aufgebaut ist).
func _find() -> bool:
	if _vega != null and is_instance_valid(_vega):
		return true
	for f: Fighter in _combat.state.heroes:
		_vega = _combat.view(f)
	_enemy = _combat.state.enemies[0]
	return _vega != null


func _build_buttons() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 50
	add_child(layer)
	var panel := PanelContainer.new()
	panel.theme = Combat.make_theme()
	# Rechts am Rand: links stehen die Gegner mit ihren Schildern
	panel.position = Vector2(1280 - 200, 96)
	layer.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	var title := Label.new()
	title.text = "%s-Animationen" % FigurWahl.NAMEN[FigurWahl.gewaehlt()]
	title.add_theme_color_override("font_color", Color("f2c14e"))
	box.add_child(title)
	var actions: Array = [
		["Stehen", func() -> void: _reset()],
		["Laufen", func() -> void: _vega.play("run", 1.2)],
		["Getroffen", func() -> void: _vega.hit_react()],
		["Parade", func() -> void: _vega.parry_pose()],
		["Angriff", func() -> void: _combat.lunge(_vega.fighter, _enemy, 0.6)],
		["Fallen", func() -> void: _vega.shown = 0],
		["Sieg", func() -> void: _vega.cheer()],
		["Fähigkeit", func() -> void: _vega.cast_hop()],
	]
	for a: Array in actions:
		var b := _small(a[0])
		var action: Callable = a[1]
		b.pressed.connect(func() -> void:
			if _find():
				action.call())
		box.add_child(b)
	_slow_button = _small("Zeitlupe: aus")
	_slow_button.pressed.connect(func() -> void:
		_slow = not _slow
		Engine.time_scale = ZEITLUPE if _slow else 1.0
		_slow_button.text = "Zeitlupe: an" if _slow else "Zeitlupe: aus")
	box.add_child(_slow_button)
	# Projekt 11: Kopf und Körper getrennt (nur für Figuren, die schon zerlegt sind, z. B. Kofi)
	if FigurTeile.hat_teile(FigurWahl.gewaehlt()):
		var teile := _small(ART_NAMEN[FigurTeile.art])
		teile.tooltip_text = "Ganz: fertige Bilder. Aus Teilen: Körper + eigener Kopf.\nStandardkopf: immer derselbe Kopf (so wird es mit wählbaren Köpfen)."
		teile.pressed.connect(func() -> void:
			FigurTeile.art = ((FigurTeile.art + 1) % ART_NAMEN.size()) as FigurTeile.Art
			get_tree().reload_current_scene())
		box.add_child(teile)
	var back := _small("Zurück zum Editor")
	back.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/editor.tscn"))
	box.add_child(back)


## Nach dem Fallen wieder aufstehen und normal stehen.
func _reset() -> void:
	_vega.shown = -1
	_vega._set_anim("idle")


func _small(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(170, 36)
	b.add_theme_font_size_override("font_size", 16)
	b.focus_mode = Control.FOCUS_NONE
	return b
