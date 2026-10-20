class_name Combat
extends Control
## Anzeige der Kampf-Sandbox. Die Regeln stehen in battle_state.gd (ohne Grafik).
## Diese Datei
## - spielt die Ereignisse ab, die der Kampf-Zustand meldet (Treffer, Heilung, Geschosse, Log …),
## - zeigt Knöpfe und Ziele und gibt die Wahl des Spielers als Befehl an den Zustand zurück,
## - zeigt den Reaktions-Ring (Parieren / Ausweichen) und meldet, ob im richtigen Moment getippt wurde,
## - zeigt am Ende die Auswertung.

signal _action_chosen(command: Dictionary)
signal _choice_made(id: String)

const SCREEN := Vector2(1280, 720)
## Kampfbildschirm wie Final Fantasy 6: Gegner links, Helden rechts in zwei Reihen.
const FRONT_X := 740.0
const BACK_X := 1000.0
## Fußpunkte der Helden (von oben nach unten).
const HERO_FEET_Y: Array[float] = [258.0, 334.0, 410.0, 486.0]
## Begleiter stehen vor den Helden, Roboter oben, Monster unten.
const COMPANION_X := 590.0
const ROBOT_FEET_Y := 330.0
const MONSTER_FEET_Y := 478.0
const FIELD_BOTTOM := 528.0
const VIGNETTE_SHADER := preload("res://shaders/vignette.gdshader")

## Fußpunkte der Gegner: Welle mit 4 Monstern bzw. Boss-Welle (Boss zuerst)
const WAVE_SLOTS: Array[Vector2] = [Vector2(30, 300), Vector2(30, 476), Vector2(318, 300), Vector2(318, 476)]
const BOSS_SLOTS: Array[Vector2] = [Vector2(40, 400), Vector2(330, 290), Vector2(330, 462)]

## Zeitfenster der normalen Reaktion in Sekunden (vor bzw. nach dem Treffer).
const REACT_EARLY := 0.25
const REACT_LATE := 0.25
## Die Perfekt-Zone liegt in der Mitte der normalen Zone und ist so breit (Anteil)
const PERFECT_SHARE := 0.2
const RING_START := 170.0
const RING_TARGET := 40.0
## Unter diesem Namen merkt sich der Spielstand die Urbaum-Entscheidung der Pilzhöhle
const PILZ_CHOICE_FLAG := "pilzhoehle_urbaum"
## So oft gelingt den Novizen-Mitstreitern (Computer) eine perfekte Reaktion
const ALLY_PARRY_CHANCE := 0.1
## ... und so oft eine normale (25 % weniger Schaden)
const ALLY_NORMAL_CHANCE := 0.3

var state: BattleState

var _views := {}
## Wer gerade am Zug ist (so weit, wie die Anzeige abgespielt hat)
var _current: Fighter
var _pending := {}
var _pending_user: Fighter

var _reacting := false
var _react_start := 0
var _react_duration := 1.0
var _react_press := -1.0
var _react_target: Fighter
var _react_feedback := ""
## Ob das Aufblitzen zu Beginn des Zeitfensters schon gezeigt wurde.
var _react_glint := false
## Computer-Spieler für Novizen-Mitstreiter und schon gezeigte Erklär-Fenster
var _ki := KampfKI.new(randi())
var _hints_shown := {}
## Gruppenkampf beim Zusammenspielen: {bid, seed, mine, owners} (leer = allein). Siehe GemeinsamerKampf.
var _group := {}
## Fortlaufende Nummer jeder Frage der Kampfregeln (auf allen Geräten gleich)
var _seq := 0
## Restzeit für den eigenen Zug im Gruppenkampf (Sekunden, < 0 = keine Uhr)
var _turn_time := -1.0
var _turn_text := ""

var _field: Control
var _ring_layer: Control
var _order_box: HBoxContainer
var _turn_label: Label
var _grid: GridContainer
var _log: RichTextLabel
var _rotate_hint: Label
var _react_dim: ColorRect
var _flash_rect: ColorRect
var _dark_rect: ColorRect


func _ready() -> void:
	Musik.play("kampf")
	if Sandbox.team.is_empty():
		Sandbox.team = ["tank", "archer", "ritualist", "singer"]
	_build_ui()
	add_log("Tippe eine Fähigkeit an, dann das Ziel.")
	add_log("Bei Gegner-Angriffen: tippen, wenn sich der [color=#f2c14e]Ring[/color] schließt!")
	# Entscheidungen fallen nur beim ersten Abschluss; danach gilt die gespeicherte Wahl
	Sandbox.pilz_choice = SaveGame.get_flag(PILZ_CHOICE_FLAG)
	if BattleRequest.active() and not BattleRequest.group.is_empty():
		# Gruppenkampf: gleicher Startwert wie bei allen anderen, Entscheidungen kommen übers Netz
		_group = BattleRequest.group
		state = BattleState.new(self, [] as Array[String], "", int(_group.seed))
		state.setup = BattleRequest.setup
		_ki = KampfKI.new(GemeinsamerKampf.ki_seed(int(_group.seed)))
		Netz._node().disconnected.connect(func() -> void:
			get_tree().set_meta("netz_meldung", "Die Verbindung ist während des Kampfes abgerissen. Dein Fortschritt ist gespeichert.")
			BattleRequest.finish(false)
			BattleRequest.result = {}
			get_tree().change_scene_to_file.call_deferred("res://scenes/zusammen.tscn"))
	elif BattleRequest.active():
		# Kampf aus der Kreuzweg-Demo (Lektion, Gruppenkampf)
		state = BattleState.new(self, [] as Array[String], "", randi())
		state.setup = BattleRequest.setup
	else:
		state = BattleState.new(self, Sandbox.team, Sandbox.encounter, randi())
	state.run()


## Name des Kampfes für die Auswertung.
func _battle_name() -> String:
	if not state.setup.is_empty():
		return state.setup.get("name", "")
	return Sandbox.ENCOUNTERS[state.encounter].name


## Zurück in die Stadt (Kampf aus der Kreuzweg-Demo).
func _back_to_world(won: bool) -> void:
	# Verbrauchte Heiltränke fehlen danach in der Tasche
	BattleRequest.finish(won, _potions_used())
	get_tree().change_scene_to_file(BattleRequest.return_scene)


## Wie viele Heiltränke der Spieler in diesem Kampf getrunken hat.
func _potions_used() -> int:
	var index := int(_group.get("mine", 0))
	var player := state.heroes[index]
	if not player.wares.has("heiltrank"):
		return 0
	return int(state.setup.helden[index].get("traenke", 0)) - int(player.wares.heiltrank)


# --- Gruppenkampf ---------------------------------------------------------------

## Wer steuert diese Figur? "" = ich (oder allein), sonst der Spieler (Kennung) bzw. "computer".
func _owner(f: Fighter) -> String:
	if state.computer.has(f):
		return "computer"
	if _group.is_empty():
		return ""
	var who := GemeinsamerKampf.owner_in(state, _group.owners, f)
	if who == "":
		return "computer"
	return "" if who == str(_group.owners[int(_group.mine)]) else who


func _is_remote(f: Fighter) -> bool:
	return _owner(f) not in ["", "computer"]


## Wartet auf die Entscheidung Nummer "seq" vom Gastgeber.
func _net_decision(seq: int) -> Dictionary:
	while not Netz.battle_buffer.has(seq):
		await Netz._node().battle_decision
	return Netz.battle_buffer[seq]


## Erklärung zur Reaktion zeigen, BEVOR der erste Gegner-Angriff auf den Spieler losgeht
## (sonst passt der Ring nicht mehr zum Schlag).
func _attack_hint(target: Fighter) -> void:
	if target.is_ally() and _owner(target) == "" and target.reaction != "":
		await _show_hint("erste_reaktion")


## Erklär-Fenster der Grundausbildung: Der Kampf wartet, bis „Verstanden“ angetippt wird.
func _show_hint(key: String) -> void:
	var hints: Dictionary = state.setup.get("hinweise", {})
	# Im langen Lernkampf hat jede Phase ihre eigenen Erklärungen
	var seen := "%d:%s" % [state.wave, key]
	if _hints_shown.has(seen) or not hints.has(key):
		return
	_hints_shown[seen] = true
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.11, 0.96)
	style.border_color = Color("8affc1")
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", style)
	panel.position = Vector2(300, 150)
	panel.size = Vector2(680, 0)
	panel.z_index = 40
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	var title := Label.new()
	title.text = "Ye erklärt"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color("8affc1"))
	box.add_child(title)
	var text := Label.new()
	text.text = hints[key]
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(640, 0)
	text.add_theme_font_size_override("font_size", 18)
	box.add_child(text)
	var ok := Button.new()
	ok.text = GameData.text("verstanden")
	ok.custom_minimum_size = Vector2(180, 48)
	ok.size_flags_horizontal = Control.SIZE_SHRINK_END
	ok.add_theme_font_size_override("font_size", 18)
	box.add_child(ok)
	add_child(panel)
	await ok.pressed
	panel.queue_free()


## Beim Verlassen des Kampfes Verweise lösen, sonst bleiben die Teilnehmer im Speicher liegen.
func _exit_tree() -> void:
	if state != null:
		state.cleanup()


func _process(delta: float) -> void:
	# Uhr für den eigenen Zug im Gruppenkampf
	if _turn_time >= 0.0:
		_turn_time -= delta
		_turn_label.text = "%s · noch %d s" % [_turn_text, ceili(maxf(_turn_time, 0.0))]
		if _turn_time <= 0.0:
			_turn_time = -1.0
			_time_up()
	if _reacting:
		_update_glint()
		_ring_layer.queue_redraw()


# --- Ereignisse abspielen -----------------------------------------------------

## Spielt die Ereignisse des Kampf-Zustands der Reihe nach ab.
func play(events: Array[Dictionary]) -> void:
	for event in events:
		await _play_event(event)
	# Am Ende stimmt die Anzeige wieder genau mit dem Zustand überein
	for f: Fighter in _views:
		view(f).shown = f.hp
	refresh()


func _play_event(event: Dictionary) -> void:
	match event.type:
		"log":
			add_log(event.text)
		"float":
			float_text(event.f, event.text, event.color, event.offset)
		"status":
			_turn_label.text = event.text
		"turn":
			_current = event.f
			if _current == null:
				_clear_actions()
			refresh()
		"refresh":
			refresh()
		"spawn":
			_add_view(event.f, _feet(event.f, event.place, event.index))
			if event.f.big:
				Musik.play("boss")
			view(event.f).shown = event.hp
		"despawn":
			if has_view(event.f):
				_views[event.f].queue_free()
				_views.erase(event.f)
		"hp":
			if has_view(event.f):
				view(event.f).shown = event.hp
		"cast":
			Geraeusche.play("zauber", 0.8 if event.ult else 1.0)
			_cast(event.f, event.ult)
		"projectile":
			Geraeusche.play("wurf")
			if event.blocking:
				await projectile(event.from, event.to, event.color, event.duration)
			else:
				await _attack_hint(event.to)
				projectile(event.from, event.to, event.color, event.duration)
		"lunge":
			Geraeusche.play("schlag")
			if event.blocking:
				await lunge(event.f, event.target, event.duration)
			else:
				await _attack_hint(event.target)
				lunge(event.f, event.target, event.duration)
		"wait":
			await wait(event.seconds)
		"burst":
			burst(event.f, event.color, event.radius)
		"flash":
			screen_flash(event.color)
		"hop":
			if has_view(event.f):
				view(event.f).cast_hop()
		"banner":
			_banner(event.text)
		"row":
			await move_to_row(event.f)
		"darkness":
			create_tween().tween_property(_dark_rect, "color:a", clampf(event.amount, 0.0, 0.92), 0.5)
		"order_visible":
			_order_box.visible = event.on
		"hit_fx":
			Geraeusche.play("kritisch" if event.crit else "treffer")
			if has_view(event.f):
				var v := view(event.f)
				v.hit_react()
				Fx.spawn(_field, Fx.Kind.SPARKS, v.center(), Color("ffd9a0") if not event.crit else Color("ffe14d"), 70.0 if not event.crit else 110.0, 0.4)
		"heal_fx":
			Geraeusche.play("heilung")
			if has_view(event.f):
				var v := view(event.f)
				v.glow(Color("8affa0"), 0.6)
				Fx.spawn(_field, Fx.Kind.GLOW, v.center(), Color("4cff7a"), 90.0, 0.6)
				Fx.spawn(_field, Fx.Kind.SPARKS, v.center(), Color("b6ffc8"), 60.0, 0.6)
		"end":
			_clear_actions()
			if not event.aborted:
				if event.won and state.dungeon != null and Sandbox.pilz_choice != "":
					SaveGame.set_flag(PILZ_CHOICE_FLAG, Sandbox.pilz_choice)
				_show_end_screen(event.won)


## Wo eine Figur steht ("feet" ist der Punkt, auf dem sie steht).
func _feet(f: Fighter, place: String, index: int) -> Vector2:
	match place:
		"hero":
			return Vector2(BACK_X if f.back_row else FRONT_X, HERO_FEET_Y[index])
		"robot":
			return Vector2(COMPANION_X, ROBOT_FEET_Y)
		"monster":
			return Vector2(COMPANION_X, MONSTER_FEET_Y)
		"boss_wave":
			return BOSS_SLOTS[index]
	return WAVE_SLOTS[index]


## Glühen beim Wirken einer Fähigkeit (Ult: goldener Lichtblitz über den ganzen Bildschirm).
func _cast(f: Fighter, ult: bool) -> void:
	if not has_view(f):
		return
	var v := view(f)
	v.cast_hop()
	if ult:
		v.glow(Color("ffe08a"), 1.2)
		Fx.spawn(_field, Fx.Kind.GLOW, v.center(), Color("f2c14e"), 220.0, 1.0)
		Fx.spawn(_field, Fx.Kind.RING, v.center(), Color("ffe08a"), 260.0, 0.8)
		screen_flash(Color("f2c14e"))
	else:
		v.glow(f.color.lightened(0.35))
		Fx.spawn(_field, Fx.Kind.GLOW, v.center(), f.color.lightened(0.35), 110.0, 0.6)


## Legt die Grafik eines Teilnehmers an. "feet" ist der Punkt, auf dem die Figur steht.
func _add_view(f: Fighter, feet: Vector2) -> void:
	var v := FighterView.new()
	v.setup(f)
	v.position = Vector2(feet.x, feet.y - v.sprite_size.y)
	v.tapped.connect(_on_fighter_tapped)
	_field.add_child(v)
	_views[f] = v


func has_view(f: Fighter) -> bool:
	return _views.has(f)


func view(f: Fighter) -> FighterView:
	return _views[f]


# --- Eingaben für den Kampf-Zustand -------------------------------------------

## Der Zustand fragt: Was macht diese Figur? Antwort kommt, sobald Fähigkeit und Ziel angetippt sind.
func choose_action(f: Fighter) -> Dictionary:
	_seq += 1
	var seq := _seq
	# Novizen-Mitstreiter handeln selbst (Computer)
	if state.computer.has(f) or _owner(f) == "computer":
		_turn_label.text = "%s ist am Zug" % f.display_name
		await wait(0.6)
		return _ki.choose(state.skills, f)
	# Mitspieler: warten, bis seine Entscheidung übers Netz kommt
	if _is_remote(f):
		_clear_actions()
		_turn_label.text = "%s ist am Zug …" % f.display_name
		return GemeinsamerKampf.decode_action(state.skills, f, await _net_decision(seq))
	await _show_hint("erster_zug")
	_show_actions(f)
	if not _group.is_empty():
		_turn_text = _turn_label.text
		_turn_time = GemeinsamerKampf.TURN_SECONDS
	var command: Dictionary = await _action_chosen
	_turn_time = -1.0
	if _group.is_empty():
		return command
	# Gruppenkampf: an den Gastgeber schicken; was er zurückschickt, gilt (auf allen Geräten gleich)
	Netz.battle_decide(seq, GemeinsamerKampf.encode_action(state.skills, f, command))
	_clear_actions()
	_turn_label.text = "Warte auf die anderen …"
	var decided := GemeinsamerKampf.decode_action(state.skills, f, await _net_decision(seq))
	return decided if not decided.is_empty() else command


## Zeit für den eigenen Zug ist um: Standardangriff.
func _time_up() -> void:
	if _pending_user == null and _grid_buttons().is_empty():
		return
	var f: Fighter = _current
	if f == null:
		return
	_cancel_targeting()
	_clear_actions()
	add_log("[color=#ffb070]Zeit abgelaufen – Standardangriff.[/color]")
	_action_chosen.emit(GemeinsamerKampf.default_action(state.skills, f, _ki_fallback()))


## Zufall nur für den Notfall-Standardangriff (darf den gemeinsamen Zufall der Mitstreiter nicht verändern)
func _ki_fallback() -> KampfKI:
	return KampfKI.new(randi())


## Eine Entscheidung mit mehreren Möglichkeiten (z. B. nach dem Dungeon). Gibt die Kennung zurück.
func choose_option(title: String, options: Array[Dictionary]) -> String:
	_seq += 1
	var seq := _seq
	_clear_actions()
	# Gruppenkampf: Der erste Spieler entscheidet, die anderen warten
	if not _group.is_empty() and str(_group.owners[int(_group.mine)]) != _first_player():
		_turn_label.text = "%s – die Gruppe entscheidet …" % title
		return str((await _net_decision(seq)).get("o", options[0].id))
	_turn_label.text = title
	for option in options:
		var info: String = option.get("info", "")
		var button := _action_button(option.name if info == "" else "%s\n%s" % [option.name, info])
		button.custom_minimum_size.x = 404
		button.pressed.connect(func() -> void: _choice_made.emit(option.id))
		_grid.add_child(button)
	_number_buttons()
	var id: String = await _choice_made
	_clear_actions()
	if _group.is_empty():
		return id
	Netz.battle_decide(seq, {o = id})
	return str((await _net_decision(seq)).get("o", id))


func _first_player() -> String:
	for o in _group.get("owners", []):
		if str(o) != "":
			return str(o)
	return ""


func _show_actions(f: Fighter) -> void:
	_clear_actions()
	if f.display_name == "Du" or (not _group.is_empty() and _owner(f) == ""):
		_turn_label.text = "Du bist am Zug"
	else:
		_turn_label.text = "%s (%s) ist am Zug" % [f.display_name, f.class_title]
	var list := state.skills.abilities(f)
	# Mehr als 8 Knöpfe (z. B. mit Dungeon-Aktionen): kleiner, damit 3 Reihen passen
	var compact := list.size() > 8
	for ab in list:
		var reason := state.skills.blocked_reason(f, ab)
		var title: String = ab.name
		if ab.id == "ult":
			title = "ULT: " + title
		elif ab.has("duet"):
			title = "DUETT: " + title
		var button := _action_button("%s\n%s" % [title, reason if reason != "" else ab.info])
		button.disabled = reason != ""
		if compact:
			button.custom_minimum_size.y = 38
			button.add_theme_font_size_override("font_size", 11)
		if reason == "" and ab.id == "ult":
			button.add_theme_color_override("font_color", Color("f2c14e"))
		elif reason == "" and ab.has("duet"):
			button.add_theme_color_override("font_color", Color("ffa8e0"))
		elif reason == "" and ab.has("dungeon"):
			button.add_theme_color_override("font_color", Color("9fe8ff"))
		button.pressed.connect(_on_ability_pressed.bind(f, ab))
		_grid.add_child(button)
	_number_buttons()


## Eine Entscheidung mit mehreren Möglichkeiten (z. B. nach dem Dungeon). Gibt die Kennung zurück.
func _action_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(198, 60)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.add_theme_font_size_override("font_size", 13)
	return button


func _on_ability_pressed(f: Fighter, ab: Dictionary) -> void:
	if ab.target == "choice":
		_show_choices(f, ab)
		return
	if ab.target == "none":
		_clear_actions()
		_action_chosen.emit({ab = ab, target = null})
		return
	# Ziel auswählen: passende Figuren blinken
	_pending = ab
	_pending_user = f
	_clear_actions()
	_turn_label.text = "%s: Ziel antippen" % ab.name
	for target in state.skills.valid_targets(f, ab):
		view(target).targetable = true
	_add_back_button(f)


## Zweiter Schritt einer Fähigkeit mit Auswahl (Rüstung, Ware, Siegel, Monster).
func _show_choices(f: Fighter, ab: Dictionary) -> void:
	_clear_actions()
	_turn_label.text = "%s: auswählen" % ab.name
	for choice: Dictionary in ab.choices:
		var reason := state.skills.choice_blocked(f, ab, choice)
		var button := _action_button("%s\n%s" % [choice.name, reason if reason != "" else choice.info])
		button.disabled = reason != ""
		var picked := ab.duplicate()
		picked.choice = choice.id
		picked.target = choice.get("then", ab.get("then", "none"))
		button.pressed.connect(_on_ability_pressed.bind(f, picked))
		_grid.add_child(button)
	_add_back_button(f)


## PC: Zahlentasten 1–9 drücken den passenden Knopf unten (Fähigkeiten, Auswahl, Zurück).
func _number_key(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key: Key = event.physical_keycode
	var index := -1
	if key >= KEY_1 and key <= KEY_9:
		index = key - KEY_1
	elif key >= KEY_KP_1 and key <= KEY_KP_9:
		index = key - KEY_KP_1
	if index < 0:
		return
	var buttons := _grid_buttons()
	if index < buttons.size() and not buttons[index].disabled:
		get_viewport().set_input_as_handled()
		buttons[index].pressed.emit()


func _grid_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	for child in _grid.get_children():
		if child is Button and not child.is_queued_for_deletion():
			buttons.append(child)
	return buttons


## Am PC steht vor jedem Knopf seine Zahlentaste.
func _number_buttons() -> void:
	if DisplayServer.is_touchscreen_available():
		return
	var buttons := _grid_buttons()
	for i in mini(buttons.size(), 9):
		buttons[i].text = "%d · %s" % [i + 1, buttons[i].text]


func _add_back_button(f: Fighter) -> void:
	var back := _action_button("Zurück")
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_on_back_pressed.bind(f))
	_grid.add_child(back)
	_number_buttons()


func _on_back_pressed(f: Fighter) -> void:
	_cancel_targeting()
	_show_actions(f)


func _cancel_targeting() -> void:
	_pending = {}
	_pending_user = null
	for v: FighterView in _views.values():
		v.targetable = false


func _on_fighter_tapped(target: Fighter) -> void:
	if _pending.is_empty() or not view(target).targetable:
		return
	var ab := _pending
	_cancel_targeting()
	_clear_actions()
	_action_chosen.emit({ab = ab, target = target})



# --- Perfekte Reaktion --------------------------------------------------------

## Zeigt den schrumpfenden Ring und die Zeitleiste. Gibt die Reaktion zurück:
## 0 = verpasst, 1 = normal pariert/ausgewichen (normale Zone), 2 = perfekt (schmale Zone in der Mitte).
func react(attacker: Fighter, target: Fighter, duration: float) -> int:
	_seq += 1
	var seq := _seq
	# Mitspieler: Er pariert auf seinem Gerät, hier kommt nur das Ergebnis an
	if _is_remote(target):
		await wait(duration + REACT_LATE)
		var remote := clampi(int((await _net_decision(seq)).get("g", 0)), 0, 2)
		if remote == BattleState.REACT_PERFECT:
			Geraeusche.play("perfekt")
		elif remote == BattleState.REACT_NORMAL:
			Geraeusche.play("parade")
		return remote
	# Mitstreiter des Computers reagieren selbst, ohne Ring
	if state.computer.has(target) or _owner(target) == "computer":
		await wait(duration + REACT_LATE)
		var grade := _ki.react_grade(ALLY_PARRY_CHANCE, ALLY_NORMAL_CHANCE)
		if grade == BattleState.REACT_PERFECT:
			Geraeusche.play("perfekt")
		elif grade == BattleState.REACT_NORMAL:
			Geraeusche.play("parade")
		return grade
	await _show_hint("erste_reaktion")
	_react_target = target
	_react_duration = duration
	_react_press = -1.0
	_react_feedback = ""
	_react_glint = false
	_react_start = Time.get_ticks_usec()
	_reacting = true
	# Alles außer Angreifer und Ziel wird abgedunkelt, damit man sich auf den Moment konzentriert
	var raised: Array[FighterView] = [view(attacker), view(target)]
	for v in raised:
		v.z_index = 16
	create_tween().tween_property(_react_dim, "color:a", 0.55, 0.15)
	await wait(duration + REACT_LATE)
	_reacting = false
	_ring_layer.queue_redraw()
	create_tween().tween_property(_react_dim, "color:a", 0.0, 0.25)
	for v in raised:
		if is_instance_valid(v):
			v.z_index = 0
	var grade := _grade(_react_press) if _react_press >= 0.0 else BattleState.REACT_NONE
	if _group.is_empty():
		return grade
	Netz.battle_decide(seq, {g = grade})
	return clampi(int((await _net_decision(seq)).get("g", grade)), 0, 2)


## Halbe Breite der Perfekt-Zone in Sekunden.
func _perfect_half() -> float:
	return (REACT_EARLY + REACT_LATE) * PERFECT_SHARE * 0.5


## Wie gut ein Tippen zum Zeitpunkt t war (Sekunden seit Beginn des Angriffs).
func _grade(t: float) -> int:
	if absf(t - _react_duration) <= _perfect_half():
		return BattleState.REACT_PERFECT
	if t >= _react_duration - REACT_EARLY and t <= _react_duration + REACT_LATE:
		return BattleState.REACT_NORMAL
	return BattleState.REACT_NONE


func _react_time() -> float:
	return (Time.get_ticks_usec() - _react_start) / 1_000_000.0


func _input(event: InputEvent) -> void:
	if not _reacting:
		_number_key(event)
		return
	var pressed := false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	elif event is InputEventKey and event.pressed and not event.echo \
			and event.keycode in [KEY_SPACE, KEY_ENTER]:
		pressed = true
	if not pressed:
		return
	get_viewport().set_input_as_handled()
	if _react_press >= 0.0:
		return
	_react_press = _react_time()
	var c := view(_react_target).center()
	match _grade(_react_press):
		BattleState.REACT_PERFECT:
			_react_feedback = "PERFEKT!"
			Geraeusche.play("perfekt")
			Fx.spawn(_field, Fx.Kind.RING, c, Color("6dff8a"), 150.0, 0.45)
			Fx.spawn(_field, Fx.Kind.GLOW, c, Color("6dff8a"), 120.0, 0.4)
		BattleState.REACT_NORMAL:
			_react_feedback = "Pariert!" if _react_target.reaction == "parry" else "Ausgewichen!"
			Geraeusche.play("parade" if _react_target.reaction == "parry" else "wurf", 1.0 if _react_target.reaction == "parry" else 1.3)
			Fx.spawn(_field, Fx.Kind.RING, c, Color("9fd0ff"), 110.0, 0.35)
		_:
			_react_feedback = "Zu früh!" if _react_press < _react_duration else "Zu spät!"


## Kurzes Aufblitzen im Zielkreis, genau wenn die Perfekt-Zone aufgeht.
func _update_glint() -> void:
	if _react_glint or _react_time() < _react_duration - _perfect_half():
		return
	_react_glint = true
	if _react_press < 0.0:
		Fx.spawn(_field, Fx.Kind.GLOW, view(_react_target).center(), Color.WHITE, 90.0, 0.22)


func _draw_ring() -> void:
	if not _reacting:
		return
	var c := view(_react_target).center()
	var t := _react_time()
	var progress := clampf(t / _react_duration, 0.0, 1.0)
	var radius := lerpf(RING_START, RING_TARGET, progress)
	var grade := _grade(t)
	var green := Color("6dff8a")
	var light := Color("c8f08a")
	var gold := Color("f2c14e")
	var ring_color := gold
	if grade == BattleState.REACT_PERFECT:
		ring_color = green
	elif grade == BattleState.REACT_NORMAL:
		ring_color = light

	# Zielkreis: Wenn der Ring ihn erreicht, ist der perfekte Moment
	var pulse := 0.5 + 0.5 * sin(t * 30.0)
	var fill := Color(1, 1, 1, 0.12)
	if grade == BattleState.REACT_PERFECT:
		fill = Color(green, 0.3 + 0.25 * pulse)
	elif grade == BattleState.REACT_NORMAL:
		fill = Color(light, 0.2)
	_ring_layer.draw_circle(c, RING_TARGET, fill)
	_ring_layer.draw_arc(c, RING_TARGET, 0, TAU, 48, Color.WHITE, 4)

	# Schrumpfender Ring mit Leucht-Saum und vier Pfeilen, die nach innen zeigen
	if _react_press < 0.0:
		_ring_layer.draw_arc(c, radius, 0, TAU, 64, Color(ring_color, 0.15), 22)
		_ring_layer.draw_arc(c, radius, 0, TAU, 64, Color(ring_color, 0.35), 12)
		_ring_layer.draw_arc(c, radius, 0, TAU, 64, ring_color, 5)
		for i in 4:
			var dir := Vector2.RIGHT.rotated(TAU * i / 4.0 + t * 1.5)
			var tip := c + dir * (radius - 10.0)
			var side := dir.orthogonal() * 9.0
			var back := c + dir * (radius + 12.0)
			_ring_layer.draw_colored_polygon(PackedVector2Array([tip, back + side, back - side]), ring_color)

	# Zeitleiste oben: hellgrüne Zone = normal (25 % weniger Schaden), schmale grüne Mitte = perfekt
	var bar := Rect2(440, 104, 400, 18)
	var total := _react_duration + REACT_LATE
	_ring_layer.draw_rect(bar.grow(3), Color(0, 0, 0, 0.75))
	_ring_layer.draw_rect(bar, Color(1, 1, 1, 0.12))
	var normal_from := _bar_x(bar, total, _react_duration - REACT_EARLY)
	var normal_to := _bar_x(bar, total, _react_duration + REACT_LATE)
	_ring_layer.draw_rect(Rect2(normal_from, bar.position.y, normal_to - normal_from, bar.size.y), Color(light, 0.45))
	var perfect_from := _bar_x(bar, total, _react_duration - _perfect_half())
	var perfect_to := _bar_x(bar, total, _react_duration + _perfect_half())
	var perfect_alpha := 0.75 + 0.25 * pulse if grade == BattleState.REACT_PERFECT else 0.85
	_ring_layer.draw_rect(Rect2(perfect_from, bar.position.y - 2, perfect_to - perfect_from, bar.size.y + 4), Color(green, perfect_alpha))
	var marker_t := _react_press if _react_press >= 0.0 else t
	var marker_x := _bar_x(bar, total, marker_t)
	_ring_layer.draw_rect(Rect2(marker_x - 3, bar.position.y - 6, 6, bar.size.y + 12), Color.WHITE)

	var verb := "Parieren" if _react_target.reaction == "parry" else "Ausweichen"
	var text := _react_feedback if _react_feedback != "" else "%s: Tippen zum %s!" % [_react_target.display_name, verb]
	var color := Color.WHITE
	if _react_feedback == "PERFEKT!":
		color = green
	elif _react_feedback == "Pariert!" or _react_feedback == "Ausgewichen!":
		color = Color("9fd0ff")
	elif _react_feedback != "":
		color = Color("ff6b6b")
	elif grade == BattleState.REACT_PERFECT:
		text = "JETZT!"
		color = green
	elif grade == BattleState.REACT_NORMAL:
		text = "Jetzt …"
		color = light
	var font := ThemeDB.fallback_font
	_ring_layer.draw_string_outline(font, Vector2(340, 94), text, HORIZONTAL_ALIGNMENT_CENTER, 600, 26, 8, Color.BLACK)
	_ring_layer.draw_string(font, Vector2(340, 94), text, HORIZONTAL_ALIGNMENT_CENTER, 600, 26, color)


## Position eines Zeitpunkts auf der Zeitleiste.
func _bar_x(bar: Rect2, total: float, time: float) -> float:
	return bar.position.x + bar.size.x * clampf(time / total, 0.0, 1.0)


# --- Animationen --------------------------------------------------------------

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


## Figur holt aus, stürmt auf das Ziel zu und kehrt zurück.
## Der Aufprall ist genau nach "duration" Sekunden, dort erscheint ein Hieb.
func lunge(f: Fighter, target: Fighter, duration: float) -> void:
	var target_view := view(target)
	await view(f).lunge(target_view.home_feet(), duration)
	if is_instance_valid(target_view):
		Fx.spawn(_field, Fx.Kind.SLASH, target_view.center(), Color("fff4d6"), 46.0, 0.25)


## Ein leuchtendes Geschoss mit Lichtschweif fliegt vom Angreifer zum Ziel.
func projectile(from: Fighter, to: Fighter, color: Color, duration := 0.3) -> void:
	if not has_view(from) or not has_view(to):
		await wait(duration)
		return
	var orb := Node2D.new()
	orb.position = view(from).center()
	orb.z_index = 7
	orb.material = Fx.add_material()
	orb.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var halo := Sprite2D.new()
	halo.texture = Fx.glow_texture()
	halo.scale = Vector2(0.75, 0.75)
	halo.modulate = Color(color, 0.9)
	halo.use_parent_material = true
	orb.add_child(halo)
	var core := Sprite2D.new()
	core.texture = Fx.glow_texture()
	core.scale = Vector2(0.22, 0.22)
	core.use_parent_material = true
	orb.add_child(core)
	var trail := CPUParticles2D.new()
	trail.use_parent_material = true
	trail.local_coords = false
	trail.amount = 24
	trail.lifetime = 0.35
	trail.gravity = Vector2.ZERO
	trail.initial_velocity_max = 20.0
	trail.spread = 180.0
	trail.scale_amount_min = 3.0
	trail.scale_amount_max = 5.0
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color, 0.9))
	ramp.set_color(1, Color(color, 0.0))
	trail.color_ramp = ramp
	orb.add_child(trail)
	_field.add_child(orb)

	var end := view(to).center()
	var tween := create_tween()
	tween.tween_property(orb, "position", end, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	Fx.spawn(_field, Fx.Kind.GLOW, end, color, 90.0, 0.35)
	orb.queue_free()


## Leuchten an einer Figur (z. B. bei Siegeln oder Explosionen).
func burst(f: Fighter, color: Color, radius := 160.0) -> void:
	if not has_view(f):
		return
	var v := view(f)
	v.glow(color, 0.8)
	Fx.spawn(_field, Fx.Kind.GLOW, v.center(), color, radius, 0.7)
	Fx.spawn(_field, Fx.Kind.RING, v.center(), color.lightened(0.3), radius * 1.4, 0.6)


## Kurzer farbiger Lichtblitz über das ganze Bild (Ult, Festung).
func screen_flash(color: Color) -> void:
	_flash_rect.color = Color(color, 0.35)
	create_tween().tween_property(_flash_rect, "color:a", 0.0, 0.5)


func move_to_row(f: Fighter) -> void:
	var v := view(f)
	var x := BACK_X if f.back_row else FRONT_X
	v.play("run", 0.4)
	var tween := create_tween()
	tween.tween_property(v, "position:x", x, 0.4).set_trans(Tween.TRANS_QUAD)
	await tween.finished


## Schwebender Text über einer Figur (Schaden, Heilung, Hinweise).
func float_text(f: Fighter, text: String, color: Color, offset := 0.0) -> void:
	if not has_view(f):
		return
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(300, 30)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 10
	var v := view(f)
	label.position = Vector2(v.center().x - 150, v.position.y + 10 + offset)
	_field.add_child(label)
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(label, "position:y", label.position.y - 45, 1.1)
	tween.tween_property(label, "modulate:a", 0.0, 1.1).set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)


## Großer Schriftzug in der Bildmitte (z. B. "Welle 2").
func _banner(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_color_override("font_color", Color("f2c14e"))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 10)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size = Vector2(SCREEN.x, 90)
	label.position = Vector2(0, 200)
	label.z_index = 22
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	var tween := create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)


# --- Oberfläche ---------------------------------------------------------------

func _build_ui() -> void:
	theme = make_theme()

	# Hintergrund: Gewölbe mit Fackeln und Lava-Brunnen, zum Rand hin abgedunkelt
	var backdrop := Backdrop.new()
	if BattleRequest.active():
		backdrop.style = BattleRequest.setup.get("hintergrund", "gewoelbe")
	add_child(backdrop)
	add_child(_vignette(0.85))

	_field = Control.new()
	_field.size = SCREEN
	_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_field)

	# Dunkelheit (Vorbote in der Pilzhöhle)
	_dark_rect = ColorRect.new()
	_dark_rect.color = Color(0.01, 0.0, 0.04, 0.0)
	_dark_rect.size = Vector2(SCREEN.x, FIELD_BOTTOM)
	_dark_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dark_rect)

	# Leichte Abdunklung auch über den Figuren, damit das Bild einen "Rahmen" bekommt
	add_child(_vignette(0.35))

	# Abdunklung während der perfekten Reaktion (nur Angreifer und Ziel bleiben hell)
	_react_dim = ColorRect.new()
	_react_dim.color = Color(0.01, 0.0, 0.03, 0.0)
	_react_dim.size = Vector2(SCREEN.x, FIELD_BOTTOM)
	_react_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_react_dim.z_index = 15
	add_child(_react_dim)

	for info: Array in [["hinten", BACK_X], ["vorne", FRONT_X]]:
		var row_label := Label.new()
		row_label.text = "Reihe " + info[0]
		row_label.position = Vector2(info[1] + 8, 118)
		row_label.add_theme_color_override("font_color", Color(1, 0.92, 0.75, 0.55))
		row_label.add_theme_color_override("font_outline_color", Color.BLACK)
		row_label.add_theme_constant_override("outline_size", 4)
		add_child(row_label)

	# Zugleiste oben
	var order_title := Label.new()
	order_title.text = "Nächste\nZüge"
	order_title.position = Vector2(14, 14)
	order_title.add_theme_font_size_override("font_size", 14)
	order_title.add_theme_color_override("font_outline_color", Color.BLACK)
	order_title.add_theme_constant_override("outline_size", 4)
	add_child(order_title)
	_order_box = HBoxContainer.new()
	_order_box.position = Vector2(80, 10)
	_order_box.add_theme_constant_override("separation", 6)
	add_child(_order_box)

	var menu := Button.new()
	menu.text = GameData.text("aufgeben") if BattleRequest.active() else "Auswahl"
	menu.position = Vector2(1170, 16)
	menu.size = Vector2(96, 44)
	menu.add_theme_font_size_override("font_size", 16)
	if BattleRequest.active():
		menu.pressed.connect(func() -> void:
			# Gruppenkampf: Die anderen kämpfen weiter, für die eigene Figur entscheidet ab jetzt der Gastgeber
			if not _group.is_empty():
				Netz.battle_leave()
			_back_to_world(false))
	else:
		menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/auswahl.tscn"))
	add_child(menu)

	# Untere Leiste: Kampf-Log links, Fähigkeiten rechts
	var bottom := Panel.new()
	var bottom_style := StyleBoxFlat.new()
	bottom_style.bg_color = Color(0.03, 0.03, 0.07, 0.96)
	bottom_style.border_color = Color(0.85, 0.7, 0.4, 0.6)
	bottom_style.border_width_top = 2
	bottom.add_theme_stylebox_override("panel", bottom_style)
	bottom.position = Vector2(0, FIELD_BOTTOM)
	bottom.size = Vector2(SCREEN.x, SCREEN.y - FIELD_BOTTOM)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom)

	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.position = Vector2(10, 534)
	_log.size = Vector2(420, 180)
	_log.add_theme_font_size_override("normal_font_size", 13)
	_log.add_theme_font_size_override("bold_font_size", 13)
	add_child(_log)

	_turn_label = Label.new()
	_turn_label.position = Vector2(444, 532)
	_turn_label.size = Vector2(820, 26)
	_turn_label.add_theme_font_size_override("font_size", 19)
	_turn_label.add_theme_color_override("font_color", Color("f2c14e"))
	add_child(_turn_label)

	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.position = Vector2(444, 562)
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	add_child(_grid)

	# Ebene für den Reaktions-Ring über allem
	_ring_layer = Control.new()
	_ring_layer.size = SCREEN
	_ring_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring_layer.z_index = 20
	_ring_layer.draw.connect(_draw_ring)
	add_child(_ring_layer)

	_flash_rect = ColorRect.new()
	_flash_rect.color = Color(1, 1, 1, 0)
	_flash_rect.size = SCREEN
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_rect.material = Fx.add_material()
	_flash_rect.z_index = 25
	add_child(_flash_rect)

	_rotate_hint = Label.new()
	_rotate_hint.text = "Tipp: Handy quer halten"
	_rotate_hint.position = Vector2(490, 470)
	_rotate_hint.add_theme_font_size_override("font_size", 30)
	_rotate_hint.add_theme_color_override("font_color", Color("ffd34d"))
	_rotate_hint.visible = false
	add_child(_rotate_hint)
	get_tree().root.size_changed.connect(_update_rotate_hint)
	_update_rotate_hint()


func _vignette(strength: float) -> ColorRect:
	var rect := ColorRect.new()
	rect.size = Vector2(SCREEN.x, FIELD_BOTTOM)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = VIGNETTE_SHADER
	mat.set_shader_parameter("strength", strength)
	rect.material = mat
	return rect


## Menü-Optik im Stil von Octopath: dunkelblaue Felder mit feinem goldenen Rand.
static func make_theme() -> Theme:
	var t := Theme.new()
	var states := {
		"normal": [Color(0.06, 0.07, 0.15, 0.95), Color(0.85, 0.72, 0.45, 0.55)],
		"hover": [Color(0.1, 0.12, 0.24, 0.95), Color(1.0, 0.85, 0.5, 0.9)],
		"pressed": [Color(0.16, 0.14, 0.08, 0.95), Color(1.0, 0.85, 0.5, 1.0)],
		"disabled": [Color(0.05, 0.05, 0.08, 0.85), Color(0.5, 0.5, 0.55, 0.25)],
		"focus": [Color(0, 0, 0, 0), Color(1.0, 0.85, 0.5, 0.6)],
	}
	for state: String in states:
		var box := StyleBoxFlat.new()
		box.bg_color = states[state][0]
		box.border_color = states[state][1]
		box.set_border_width_all(1 if state == "normal" else 2)
		box.set_corner_radius_all(3)
		box.content_margin_left = 8
		box.content_margin_right = 8
		box.draw_center = state != "focus"
		if state != "focus":
			box.shadow_color = Color(0, 0, 0, 0.4)
			box.shadow_size = 3
		t.set_stylebox(state, "Button", box)
	t.set_color("font_color", "Button", Color("f3ead8"))
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", Color(1, 1, 1, 0.35))
	return t


func _update_rotate_hint() -> void:
	var window := DisplayServer.window_get_size()
	_rotate_hint.visible = window.y > window.x


func _clear_actions() -> void:
	for child in _grid.get_children():
		if child is Button:
			child.disabled = true
		child.queue_free()


func refresh() -> void:
	for f: Fighter in _views:
		view(f).active = f == _current

	for child in _order_box.get_children():
		child.queue_free()
	var order := state.peek_order(8)
	for i in order.size():
		var f := order[i]
		var chip := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.bg_color = Color(f.color.darkened(0.7), 0.9)
		style.set_corner_radius_all(4)
		style.border_color = f.color if i > 0 else Color("f2c14e")
		style.set_border_width_all(2 if i > 0 else 4)
		style.content_margin_left = 4
		style.content_margin_right = 4
		chip.add_theme_stylebox_override("panel", style)
		chip.custom_minimum_size = Vector2(118, 56)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		chip.add_child(row)
		# Kleines Bild der Figur
		var portrait := TextureRect.new()
		portrait.texture = FighterView.portrait(f.look_key())
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.custom_minimum_size = Vector2(24, 48)
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		portrait.flip_h = f.is_ally()
		portrait.self_modulate = FighterView.tint(f.look_key())
		row.add_child(portrait)
		var label := Label.new()
		label.text = ("JETZT\n" if i == 0 else "") + f.display_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.clip_text = true
		label.add_theme_font_size_override("font_size", 12)
		row.add_child(label)
		_order_box.add_child(chip)


func add_log(text: String) -> void:
	_log.append_text(text + "\n")


# --- Auswertung ---------------------------------------------------------------

func _show_end_screen(won: bool) -> void:
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.82)
	shade.size = SCREEN
	shade.z_index = 30
	add_child(shade)
	var title := Label.new()
	title.text = "SIEG!" if won else "NIEDERLAGE"
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color("6dff8a") if won else Color("ff6b6b"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(SCREEN.x, 70)
	title.position = Vector2(0, 40)
	shade.add_child(title)

	var sub := Label.new()
	sub.text = "Kampfauswertung · %d Züge · Welle %d von %d · %s" % [state.turns, state.wave + 1, state.waves.size(), _battle_name()]
	if won and state.dungeon != null:
		sub.text += (" · Urbaum gefällt" if Sandbox.pilz_choice == "faellen" else " · Urbaum gerettet") + " · Belohnung: Sternensplitter"
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color("f2c14e"))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.size = Vector2(SCREEN.x, 30)
	sub.position = Vector2(0, 112)
	shade.add_child(sub)

	# Tabelle: eine Zeile pro Klasse (Begleiter zählen beim Besitzer mit)
	var grid := GridContainer.new()
	grid.columns = 8
	grid.position = Vector2(110, 160)
	grid.add_theme_constant_override("h_separation", 26)
	grid.add_theme_constant_override("v_separation", 10)
	shade.add_child(grid)
	var headers := ["Klasse", "Rolle", "Schaden", "Heilung", "Abgewehrt", "Erlitten", "Perfekt", "Ults"]
	for text: String in headers:
		grid.add_child(_cell(text, Color("f2c14e"), 18))
	var best := {}
	for key in ["dmg", "heal", "blocked"]:
		best[key] = 0
	for h in state.heroes:
		best.dmg = maxi(best.dmg, h.stat_damage)
		best.heal = maxi(best.heal, h.stat_heal)
		best.blocked = maxi(best.blocked, h.stat_blocked)
	for h in state.heroes:
		var data: Dictionary = Sandbox.CLASSES[h.klass]
		var name_text := "%s (%s)" % [h.class_title, h.display_name]
		if not h.is_alive():
			name_text += " †"
		grid.add_child(_cell(name_text, h.color.lightened(0.2), 18))
		grid.add_child(_cell(data.role, Sandbox.ROLE_COLORS[data.role], 18))
		grid.add_child(_cell(str(h.stat_damage), Color("ffe14d") if h.stat_damage == best.dmg and best.dmg > 0 else Color.WHITE, 20))
		grid.add_child(_cell(str(h.stat_heal), Color("6dff8a") if h.stat_heal == best.heal and best.heal > 0 else Color.WHITE, 20))
		grid.add_child(_cell(str(h.stat_blocked), Color("6fa8ff") if h.stat_blocked == best.blocked and best.blocked > 0 else Color.WHITE, 20))
		grid.add_child(_cell(str(h.stat_taken), Color.WHITE, 20))
		grid.add_child(_cell(str(h.stat_perfect), Color.WHITE, 20))
		grid.add_child(_cell(str(h.stat_ults), Color.WHITE, 20))

	var hint := Label.new()
	hint.text = "Abgewehrt = Schaden, der durch Schilde, Rüstung, Mana, Parieren, Ausweichen oder Rauch nicht angekommen ist.\nRoboter und Monster zählen bei Mechaniker und Zähmer mit (was der Roboter einsteckt, zählt als abgewehrt)."
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size = Vector2(SCREEN.x, 50)
	hint.position = Vector2(0, 470)
	shade.add_child(hint)

	if BattleRequest.active():
		_world_buttons(shade, won)
		return
	var again := Button.new()
	again.text = "Nochmal (gleiches Team)"
	again.add_theme_font_size_override("font_size", 22)
	again.size = Vector2(330, 72)
	again.position = Vector2(290, 560)
	again.pressed.connect(func() -> void: get_tree().reload_current_scene())
	shade.add_child(again)
	var change := Button.new()
	change.text = "Team ändern"
	change.add_theme_font_size_override("font_size", 22)
	change.size = Vector2(330, 72)
	change.position = Vector2(660, 560)
	change.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/auswahl.tscn"))
	shade.add_child(change)


## Knöpfe am Ende eines Kampfes aus der Kreuzweg-Demo: zurück in die Stadt, bei Niederlage auch nochmal.
func _world_buttons(shade: Control, won: bool) -> void:
	var back := Button.new()
	back.text = GameData.text("zurueck_kreuzweg")
	back.add_theme_font_size_override("font_size", 22)
	back.size = Vector2(330, 72)
	back.position = Vector2(660 if not won and not state.setup.get("kein_nochmal", false) else 475, 560)
	back.pressed.connect(func() -> void: _back_to_world(won))
	shade.add_child(back)
	var retry: bool = not won and not state.setup.get("kein_nochmal", false)
	if retry:
		var again := Button.new()
		again.text = GameData.text("nochmal")
		again.add_theme_font_size_override("font_size", 22)
		again.size = Vector2(330, 72)
		again.position = Vector2(290, 560)
		again.pressed.connect(func() -> void:
			BattleRequest.retry(_potions_used(), state.wave)
			get_tree().reload_current_scene())
		shade.add_child(again)


func _cell(text: String, color: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
