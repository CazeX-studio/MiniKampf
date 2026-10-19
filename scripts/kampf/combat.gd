class_name Combat
extends Control
## Kampf-Sandbox nach design.md (Abschnitt 4 und 5):
## - Zugreihenfolge nach Tempo, Leiste oben zeigt die nächsten Züge
## - Zwei Reihen: Hinten macht und bekommt man weniger Nahkampf-Schaden
## - Perfekte Reaktion: Ring schließt sich, im richtigen Moment tippen = Parieren / Ausweichen
## - Ult-Leiste je Klasse, lädt nur durch die klassentypische Aktion
## - Element-Sechseck, Licht/Schatten, Sternenkraft
## - Begleiter (Roboter, Monster des Zähmers) mit eigenem Zug
## - Auswertung am Ende: Schaden, Heilung, abgewehrter Schaden pro Klasse
## Die Fähigkeiten der Klassen stehen in skills.gd, die Werte in sandbox.gd.

signal _turn_done

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

## Nahkampf-Schaden wird so stark verringert, wenn Angreifer oder Ziel hinten stehen.
const BACK_ROW_MELEE := 0.6
## Zeitfenster der perfekten Reaktion in Sekunden (vor bzw. nach dem Treffer).
const REACT_EARLY := 0.15
const REACT_LATE := 0.18
const RING_START := 170.0
const RING_TARGET := 40.0
const CRIT_CHANCE := 0.1
const CRIT_MULT := 1.5
const MANA_REGEN := 6
const BUFF_TURNS := 2
const ATK_BUFF := 1.4
const DEF_BUFF := 0.7
const VULN_MULT := 1.3
## Zwischen zwei Wellen heilen sich die Helden um diesen Anteil.
const WAVE_HEAL := 0.25

## Boss-Werte
const BOSS_FIST := 23
const BOSS_ROCKFALL := 30
const BOSS_CHAIN := 10
const BOSS_RAGE_AT := 0.3
const BOSS_RAGE_MULT := 1.3

var heroes: Array[Fighter] = []
## Begleiter auf dem Feld (Roboter, kämpfendes Monster)
var companions: Array[Fighter] = []
var enemies: Array[Fighter] = []
var current: Fighter
var battle_over := false
## Zeitpunkt des aktuellen Zuges auf der Zugleiste
var now := 0.0
var skills: Skills
## Dungeon-Regeln (Pilzhöhle), sonst null
var dungeon: Pilzhoehle

var _views := {}
var _pending := {}
var _pending_user: Fighter
var _waves: Array = []
var _wave := 0
var _turns := 0

var _reacting := false
var _react_start := 0
var _react_duration := 1.0
var _react_press := -1.0
var _react_target: Fighter
var _react_feedback := ""
## Ob das Aufblitzen zu Beginn des Zeitfensters schon gezeigt wurde.
var _react_glint := false
var _last_crit := false
var _last_eff := 1.0
## Kritische Treffer der laufenden Aktion (lädt die Ult des Bogenschützen).
var crits := 0

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
	randomize()
	skills = Skills.new(self)
	if Sandbox.team.is_empty():
		Sandbox.team = ["tank", "archer", "ritualist", "singer"]
	_build_ui()
	_create_heroes()
	_waves = Sandbox.ENCOUNTERS[Sandbox.encounter].waves
	if Sandbox.ENCOUNTERS[Sandbox.encounter].get("dungeon", "") == "pilzhoehle":
		dungeon = Pilzhoehle.new(self)
	_spawn_wave(0)
	add_log("Tippe eine Fähigkeit an, dann das Ziel.")
	add_log("Bei Gegner-Angriffen: tippen, wenn sich der [color=#f2c14e]Ring[/color] schließt!")
	_battle_loop()


## Beim Verlassen des Kampfes gegenseitige Verweise lösen (Held <-> Roboter/Monster, Schilde),
## sonst bleiben die Teilnehmer im Speicher liegen.
func _exit_tree() -> void:
	var everyone := all_fighters()
	for h in heroes:
		everyone.append_array(h.monsters)
		if h.robot != null:
			everyone.append(h.robot)
	for f in everyone:
		f.owner = null
		f.robot = null
		f.active_monster = null
		f.monsters.clear()
		f.protecting = null
		f.smoke_source = null
		f.shields.clear()


func _process(_delta: float) -> void:
	if _reacting:
		_update_glint()
		_ring_layer.queue_redraw()


# --- Teilnehmer ---------------------------------------------------------------

func _create_heroes() -> void:
	for i in Sandbox.team.size():
		var id: String = Sandbox.team[i]
		var data: Dictionary = Sandbox.CLASSES[id]
		var hero := Fighter.new(data.hero, id, data.title, true, data.hp, data.tempo, data.color)
		hero.max_mana = data.mana
		hero.mana = data.get("start_mana", data.mana)
		hero.reaction = data.reaction
		hero.back_row = data.back
		heroes.append(hero)
		skills.setup_hero(hero)
		_add_view(hero, Vector2(BACK_X if hero.back_row else FRONT_X, HERO_FEET_Y[i]))
		hero.next_time = hero.turn_delay() * randf_range(0.2, 1.0)

	var mechanic := hero("mechanic")
	if mechanic != null:
		add_companion(mechanic.robot, Vector2(COMPANION_X, ROBOT_FEET_Y))
	var tamer := hero("tamer")
	if tamer != null:
		add_companion(tamer.active_monster, Vector2(COMPANION_X, MONSTER_FEET_Y))


func add_companion(f: Fighter, feet: Vector2) -> void:
	companions.append(f)
	f.on_bench = false
	_add_view(f, feet)
	f.next_time = now + f.turn_delay() * randf_range(0.3, 1.0)


func remove_companion(f: Fighter) -> void:
	companions.erase(f)
	f.on_bench = true
	if _views.has(f):
		_views[f].queue_free()
		_views.erase(f)


func _spawn_wave(index: int) -> void:
	_wave = index
	var ids: Array = _waves[index]
	spawn_enemies(ids)
	if _waves.size() > 1:
		add_log("\n[b]Welle %d von %d[/b]" % [index + 1, _waves.size()])
	if dungeon != null:
		dungeon.on_wave(index)
	elif "boss" in ids:
		add_log("[b]Ein Steinwächter (Erde) und seine Begleiter greifen an![/b]")
	else:
		add_log("[b]Monster mit vier Elementen greifen an![/b] Auf die Farbe am Namen achten.")


## Ersetzt alle Gegner durch neue (Kennungen aus Sandbox.ENEMIES).
## Ist ein großer Gegner dabei, steht er links groß, die anderen davor.
func spawn_enemies(ids: Array) -> void:
	for e in enemies:
		if _views.has(e):
			_views[e].queue_free()
			_views.erase(e)
	enemies.clear()
	var hp_scale: float = Sandbox.HP_SCALE[heroes.size() - 1]
	var has_big := false
	for id: String in ids:
		has_big = has_big or Sandbox.ENEMIES[id].get("big", false)
	var slots := BOSS_SLOTS if has_big else WAVE_SLOTS
	for i in ids.size():
		var id: String = ids[i]
		var data: Dictionary = Sandbox.ENEMIES[id]
		var e := Fighter.new(data.name, id, data.element, false, roundi(data.hp * hp_scale), data.tempo, Elements.color(data.element))
		e.element = data.element
		e.resist = data.get("resist", 1.0)
		e.big = data.get("big", false)
		e.passive = data.get("passive", false)
		if data.has("title"):
			e.display_name = data.title
		enemies.append(e)
		e.intent = skills.enemy_intent(e)
		_add_view(e, slots[i])
		e.next_time = now + e.turn_delay() * randf_range(0.2, 1.0)


## Wipe-Mechanik: Die ganze Gruppe stirbt.
func wipe(reason: String) -> void:
	add_log("[color=red][b]%s Die ganze Gruppe ist besiegt.[/b][/color]" % reason)
	screen_flash(Color("200030"))
	for f in allies():
		f.hp = 0
	refresh()


## Dunkelheit über dem Kampffeld (0 = hell, 1 = schwarz).
func set_darkness(amount: float) -> void:
	create_tween().tween_property(_dark_rect, "color:a", clampf(amount, 0.0, 0.92), 0.5)


func set_order_visible(on: bool) -> void:
	_order_box.visible = on


## Legt die Grafik eines Teilnehmers an. "feet" ist der Punkt, auf dem die Figur steht.
func _add_view(f: Fighter, feet: Vector2) -> void:
	var v := FighterView.new()
	v.setup(f)
	v.position = Vector2(feet.x, feet.y - v.sprite_size.y)
	v.tapped.connect(_on_fighter_tapped)
	_field.add_child(v)
	_views[f] = v


func all_fighters() -> Array[Fighter]:
	var result: Array[Fighter] = []
	result.append_array(heroes)
	result.append_array(companions)
	result.append_array(enemies)
	return result


func alive(group: Array[Fighter]) -> Array[Fighter]:
	var result: Array[Fighter] = []
	for f in group:
		if f.is_alive():
			result.append(f)
	return result


## Lebende Helden und Begleiter auf dem Feld.
func allies() -> Array[Fighter]:
	var result := alive(heroes)
	result.append_array(alive(companions))
	return result


func has_view(f: Fighter) -> bool:
	return _views.has(f)


func view(f: Fighter) -> FighterView:
	return _views[f]


func hero(klass: String) -> Fighter:
	for h in heroes:
		if h.klass == klass:
			return h
	return null


# --- Zugreihenfolge -----------------------------------------------------------

## Wer als Nächstes dran ist: kleinster Zeitpunkt, bei Gleichstand zuerst die Helden.
func _earliest(times: Dictionary) -> Fighter:
	var best: Fighter = null
	for f: Fighter in times:
		if best == null or times[f] < times[best] - 0.001 \
				or (absf(times[f] - times[best]) <= 0.001 and f.is_ally() and not best.is_ally()):
			best = f
	return best


## Simuliert die nächsten Züge für die Leiste oben.
func peek_order(count: int) -> Array[Fighter]:
	var times := {}
	for f in alive(all_fighters()):
		if not f.passive:
			times[f] = f.next_time
	var result: Array[Fighter] = []
	while result.size() < count and not times.is_empty():
		var f := _earliest(times)
		result.append(f)
		times[f] += f.turn_delay()
	return result


## Der nächste Gegner auf der Zugleiste (für den gut getimten Monster-Wechsel).
func next_enemy() -> Fighter:
	for f in peek_order(12):
		if not f.is_ally():
			return f
	return null


## Schiebt ein Ziel auf der Zugleiste nach hinten (Anteil eines Zuges).
func delay(target: Fighter, fraction: float) -> void:
	target.next_time += target.turn_delay() * fraction


## Holt ein Ziel auf der Zugleiste nach vorne (Anteil eines Zuges).
func hasten(target: Fighter, fraction: float) -> void:
	target.next_time = maxf(now + 0.01, target.next_time - target.turn_delay() * fraction)


func _battle_loop() -> void:
	while not battle_over:
		var times := {}
		for f in alive(all_fighters()):
			if not f.passive:
				times[f] = f.next_time
		var f := _earliest(times)
		current = f
		now = f.next_time
		refresh()
		await _begin_turn(f)
		if await _check_end():
			return
		if f.is_alive():
			_turns += 1
			if f.is_ally():
				await _player_turn(f)
			else:
				await _enemy_turn(f)
		f.next_time += f.turn_delay()
		current = null
		refresh()
		if await _check_end():
			return


## Was zu Beginn jedes eigenen Zuges passiert (Abklingzeiten, Mana, Klassen-Mechaniken).
func _begin_turn(f: Fighter) -> void:
	for id: String in f.cooldowns.keys():
		f.cooldowns[id] = maxi(f.cooldowns[id] - 1, 0)
	f.atk_buff_turns = maxi(f.atk_buff_turns - 1, 0)
	f.def_buff_turns = maxi(f.def_buff_turns - 1, 0)
	f.vuln_turns = maxi(f.vuln_turns - 1, 0)
	f.blind_turns = maxi(f.blind_turns - 1, 0)
	if f.max_mana > 0:
		f.mana = mini(f.mana + MANA_REGEN, f.max_mana)
	await skills.begin_turn(f)
	refresh()


## Prüft Sieg und Niederlage. Nach einer gewonnenen Welle kommt die nächste.
func _check_end() -> bool:
	if battle_over:
		return true
	if dungeon != null:
		await dungeon.check_phase()
	var lost := alive(heroes).is_empty()
	var won := alive(enemies).is_empty()
	if won and not lost and _wave < _waves.size() - 1:
		await _next_wave()
		return false
	if not won and not lost:
		return false
	battle_over = true
	_clear_actions()
	current = null
	refresh()
	_turn_label.text = "Sieg!" if won else "Niederlage …"
	if won:
		add_log("\n[color=green][b]Alle Gegner sind besiegt![/b][/color]")
	else:
		add_log("\n[color=red][b]Alle Helden sind gefallen.[/b][/color]")
	await wait(1.0)
	_show_end_screen(won)
	return true


func _next_wave() -> void:
	_clear_actions()
	_turn_label.text = "Welle geschafft!"
	await wait(0.8)
	_banner("Welle %d" % (_wave + 2))
	for h in alive(heroes):
		heal(null, h, roundi(h.max_hp * WAVE_HEAL))
	_spawn_wave(_wave + 1)
	refresh()
	await wait(1.0)


# --- Spieler-Zug --------------------------------------------------------------

func _player_turn(f: Fighter) -> void:
	_show_actions(f)
	await _turn_done


func _show_actions(f: Fighter) -> void:
	_clear_actions()
	_turn_label.text = "%s (%s) ist am Zug" % [f.display_name, f.class_title]
	var list := skills.abilities(f)
	# Mehr als 8 Knöpfe (z. B. mit Dungeon-Aktionen): kleiner, damit 3 Reihen passen
	var compact := list.size() > 8
	for ab in list:
		var reason := skills.blocked_reason(f, ab)
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
		await _execute(f, ab, null)
		_turn_done.emit()
		return
	# Ziel auswählen: passende Figuren blinken
	_pending = ab
	_pending_user = f
	_clear_actions()
	_turn_label.text = "%s: Ziel antippen" % ab.name
	for target in skills.valid_targets(f, ab):
		view(target).targetable = true
	_add_back_button(f)


## Zweiter Schritt einer Fähigkeit mit Auswahl (Rüstung, Ware, Siegel, Monster).
func _show_choices(f: Fighter, ab: Dictionary) -> void:
	_clear_actions()
	_turn_label.text = "%s: auswählen" % ab.name
	for choice: Dictionary in ab.choices:
		var reason := skills.choice_blocked(f, ab, choice)
		var button := _action_button("%s\n%s" % [choice.name, reason if reason != "" else choice.info])
		button.disabled = reason != ""
		var picked := ab.duplicate()
		picked.choice = choice.id
		picked.target = choice.get("then", ab.get("then", "none"))
		button.pressed.connect(_on_ability_pressed.bind(f, picked))
		_grid.add_child(button)
	_add_back_button(f)


func _add_back_button(f: Fighter) -> void:
	var back := _action_button("Zurück")
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_on_back_pressed.bind(f))
	_grid.add_child(back)


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
	var f := _pending_user
	_cancel_targeting()
	_clear_actions()
	await _execute(f, ab, target)
	_turn_done.emit()


## Führt eine Fähigkeit aus (inklusive Animation).
func _execute(f: Fighter, ab: Dictionary, target: Fighter) -> void:
	var id: String = ab.id
	_turn_label.text = "%s: %s" % [f.display_name, ab.name]
	crits = 0
	f.mana -= ab.get("mana", 0)
	if ab.has("cd"):
		f.cooldowns[id] = ab.cd + 1

	if id == "row":
		f.back_row = not f.back_row
		add_log("%s wechselt nach %s." % [f.display_name, f.row_name()])
		await move_to_row(f)
		return
	# Glühen beim Wirken einer Fähigkeit (Ult: goldener Lichtblitz über den ganzen Bildschirm)
	var v := view(f)
	v.cast_hop()
	if id == "ult":
		f.ult = 0.0
		f.credit().stat_ults += 1
		add_log("[color=#f2c14e][b]%s entfesselt %s![/b][/color]" % [f.display_name, ab.name])
		v.glow(Color("ffe08a"), 1.2)
		Fx.spawn(_field, Fx.Kind.GLOW, v.center(), Color("f2c14e"), 220.0, 1.0)
		Fx.spawn(_field, Fx.Kind.RING, v.center(), Color("ffe08a"), 260.0, 0.8)
		screen_flash(Color("f2c14e"))
		await wait(0.35)
	else:
		v.glow(f.color.lightened(0.35))
		Fx.spawn(_field, Fx.Kind.GLOW, v.center(), f.color.lightened(0.35), 110.0, 0.6)
		if ab.has("duet"):
			add_log("[color=#ffa8e0][b]Duett: %s![/b][/color]" % ab.name)

	await skills.execute(f, ab, target)
	refresh()
	await wait(0.35)


# --- Gegner-Zug ---------------------------------------------------------------

func _enemy_turn(e: Fighter) -> void:
	_turn_label.text = "%s ist am Zug …" % e.display_name
	await wait(0.5)
	if dungeon != null and dungeon.handles(e):
		await dungeon.enemy_turn(e)
	elif e.klass == "boss":
		await _boss_turn(e)
	else:
		var data: Dictionary = Sandbox.ENEMIES[e.klass]
		var attack: Dictionary = data.attacks[e.step % data.attacks.size()]
		var targets: Array[Fighter] = []
		if attack.get("all", false):
			targets = allies()
		elif attack.kind == "melee":
			targets = [pick_target()]
		else:
			targets = [pick_target(attack.get("back", false), true)]
		await enemy_attack(e, targets, attack.base, attack.kind, attack.name)
		e.step += 1
	e.intent = skills.enemy_intent(e)


func _boss_turn(boss: Fighter) -> void:
	if not boss.enraged and boss.hp <= boss.max_hp * BOSS_RAGE_AT:
		boss.enraged = true
		add_log("[color=red][b]Der Steinwächter wird wütend![/b] Er schlägt härter zu.[/color]")
	match boss.step % 4:
		0:
			await enemy_attack(boss, [pick_target()], BOSS_FIST, "melee", "Steinfaust")
		1:
			await enemy_attack(boss, [pick_target()], BOSS_FIST - 6, "melee", "Steinfaust")
			add_log("[color=yellow]Der Steinwächter hebt die Arme: Gleich regnet es Felsen auf die hintere Reihe! (Magie)[/color]")
		2:
			var targets := allies().filter(func(h: Fighter) -> bool: return h.back_row)
			if targets.is_empty():
				add_log("Felsregen! Aber hinten steht niemand mehr.")
				float_text(boss, "Verfehlt!", Color.WHITE)
			else:
				var typed: Array[Fighter] = []
				typed.assign(targets)
				await enemy_attack(boss, typed, BOSS_ROCKFALL, "magic", "Felsregen")
		3:
			var back := allies().filter(func(h: Fighter) -> bool: return h.back_row)
			var target: Fighter = back.pick_random() if not back.is_empty() else pick_target()
			if target.back_row:
				target.back_row = false
				add_log("[color=yellow]Kettenzug! %s wird nach vorne gerissen.[/color]" % target.display_name)
				await move_to_row(target)
			await enemy_attack(boss, [target], BOSS_CHAIN, "melee", "Kettenzug")
	boss.step += 1


## Wen ein Gegner angreift. Bedrohung (Bann-Zeichen, Amboss, Moosschild, Magnet-Haken) zwingt zum Ziel.
## Nahkämpfer zielen meist auf die vordere Reihe, Fernkämpfer und Magier auf irgendwen.
func pick_target(prefer_back := false, anyone := false) -> Fighter:
	var candidates := allies()
	var taunting := candidates.filter(func(h: Fighter) -> bool: return h.taunt > 0)
	if not taunting.is_empty():
		taunting.sort_custom(func(a: Fighter, b: Fighter) -> bool: return a.taunt > b.taunt)
		var forced: Fighter = taunting[0]
		forced.taunt -= 1
		return forced
	var front := candidates.filter(func(h: Fighter) -> bool: return not h.back_row)
	var back := candidates.filter(func(h: Fighter) -> bool: return h.back_row)
	if prefer_back and not back.is_empty():
		return back.pick_random()
	if anyone:
		return candidates.pick_random()
	if not front.is_empty() and (back.is_empty() or randf() < 0.7):
		return front.pick_random()
	return back.pick_random()


## Ein Gegner-Angriff mit Chance auf perfekte Reaktion.
func enemy_attack(e: Fighter, p_targets: Array[Fighter], base: int, kind: String, attack_name: String) -> void:
	# Der Roboter fängt Angriffe auf den Verbündeten ab, den er beschützt
	var targets: Array[Fighter] = []
	var mechanic := hero("mechanic")
	for t in p_targets:
		var actual := t
		if mechanic != null and mechanic.robot.is_alive() and mechanic.robot.protecting == t \
				and t != mechanic.robot and p_targets.size() == 1:
			float_text(t, "Roboter schützt!", Color("d9a441"), 26)
			actual = mechanic.robot
		if not actual in targets:
			targets.append(actual)
	var names: Array[String] = []
	for t in targets:
		names.append(t.display_name)
	add_log("%s: [b]%s[/b] (%s) auf %s" % [e.display_name, attack_name, e.element, ", ".join(names)])
	_turn_label.text = "%s: %s!" % [e.display_name, attack_name]

	var reactors := targets.filter(func(h: Fighter) -> bool: return h.reaction != "" and h.smoke == 0)
	var focus: Fighter = reactors[0] if not reactors.is_empty() else targets[0]
	var duration := randf_range(0.75, 1.15)
	if kind == "melee":
		lunge(e, focus, duration)
	else:
		for t in targets:
			projectile(e, t, Elements.color(e.element), duration)

	var success := false
	if reactors.is_empty():
		await wait(duration)
	else:
		success = await _reaction_window(e, focus, duration)

	for t in targets:
		if not t.is_alive():
			continue
		if t.smoke > 0:
			t.smoke -= 1
			var saved := calc_damage(e, t, base, kind, e.element)
			if t.smoke_source != null:
				t.smoke_source.credit().stat_blocked += saved
			float_text(t, "Verfehlt!", Color("d8d8e8"))
			continue
		if success and t.reaction != "":
			t.credit().stat_perfect += 1
			t.stat_blocked += calc_damage(e, t, base, kind, e.element)
			_last_crit = false
			_last_eff = 1.0
			await skills.on_perfect_reaction(t, e)
		else:
			hit(e, t, base, kind, e.element)
	refresh()
	await wait(0.45)


# --- Perfekte Reaktion --------------------------------------------------------

## Zeigt den schrumpfenden Ring und die Zeitleiste. Gibt true zurück,
## wenn im richtigen Moment getippt wurde.
func _reaction_window(attacker: Fighter, target: Fighter, duration: float) -> bool:
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
	return _react_press >= 0.0 and _is_perfect(_react_press)


func _is_perfect(t: float) -> bool:
	return t >= _react_duration - REACT_EARLY and t <= _react_duration + REACT_LATE


func _react_time() -> float:
	return (Time.get_ticks_usec() - _react_start) / 1_000_000.0


func _input(event: InputEvent) -> void:
	if not _reacting:
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
	if _is_perfect(_react_press):
		_react_feedback = "PERFEKT!"
		var c := view(_react_target).center()
		Fx.spawn(_field, Fx.Kind.RING, c, Color("6dff8a"), 150.0, 0.45)
		Fx.spawn(_field, Fx.Kind.GLOW, c, Color("6dff8a"), 120.0, 0.4)
	elif _react_press < _react_duration:
		_react_feedback = "Zu früh!"
	else:
		_react_feedback = "Zu spät!"


## Kurzes Aufblitzen im Zielkreis, genau wenn das Zeitfenster aufgeht.
func _update_glint() -> void:
	if _react_glint or _react_time() < _react_duration - REACT_EARLY:
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
	var in_window := _is_perfect(t)
	var green := Color("6dff8a")
	var gold := Color("f2c14e")
	var ring_color := green if in_window else gold

	# Zielkreis: Wenn der Ring ihn erreicht, ist der richtige Moment
	var pulse := 0.5 + 0.5 * sin(t * 30.0)
	_ring_layer.draw_circle(c, RING_TARGET, Color(green, 0.25 + 0.2 * pulse) if in_window else Color(1, 1, 1, 0.12))
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

	# Zeitleiste oben: Der Strich muss im grünen Feld sein
	var bar := Rect2(440, 104, 400, 18)
	var total := _react_duration + REACT_LATE
	var zone_from := bar.position.x + bar.size.x * (_react_duration - REACT_EARLY) / total
	var zone_to := bar.end.x
	_ring_layer.draw_rect(bar.grow(3), Color(0, 0, 0, 0.75))
	_ring_layer.draw_rect(bar, Color(1, 1, 1, 0.12))
	_ring_layer.draw_rect(Rect2(zone_from, bar.position.y, zone_to - zone_from, bar.size.y), Color(green, 0.55 + 0.35 * pulse if in_window else 0.55))
	var marker_t := _react_press if _react_press >= 0.0 else t
	var marker_x := bar.position.x + bar.size.x * clampf(marker_t / total, 0.0, 1.0)
	_ring_layer.draw_rect(Rect2(marker_x - 3, bar.position.y - 6, 6, bar.size.y + 12), Color.WHITE)

	var verb := "Parieren" if _react_target.reaction == "parry" else "Ausweichen"
	var text := _react_feedback if _react_feedback != "" else "%s: Tippen zum %s!" % [_react_target.display_name, verb]
	var color := Color.WHITE
	if _react_feedback == "PERFEKT!":
		color = green
	elif _react_feedback != "":
		color = Color("ff6b6b")
	elif in_window:
		text = "JETZT!"
		color = green
	var font := ThemeDB.fallback_font
	_ring_layer.draw_string_outline(font, Vector2(340, 94), text, HORIZONTAL_ALIGNMENT_CENTER, 600, 26, 8, Color.BLACK)
	_ring_layer.draw_string(font, Vector2(340, 94), text, HORIZONTAL_ALIGNMENT_CENTER, 600, 26, color)


# --- Schaden und Heilung ------------------------------------------------------

## Berechnet den Schaden eines Angriffs (ohne Schilde und Rüstungen des Ziels).
## kind: melee (Nahkampf), ranged (Fernkampf) oder magic (Magie)
func calc_damage(attacker: Fighter, target: Fighter, base: float, kind: String, element := "") -> int:
	var dmg := base * randf_range(0.9, 1.1)
	var star := element == "Sternenkraft"
	_last_crit = false
	if attacker.atk_buff_turns > 0:
		dmg *= ATK_BUFF
	if kind == "melee":
		if attacker.back_row:
			dmg *= BACK_ROW_MELEE
		if target.back_row:
			dmg *= BACK_ROW_MELEE
	if target.def_buff_turns > 0 and not star:
		dmg *= DEF_BUFF
	if attacker.blind_turns > 0:
		dmg *= 0.7
	if attacker.enraged:
		dmg *= BOSS_RAGE_MULT
	if target.vuln_turns > 0:
		dmg *= VULN_MULT
	if not star:
		dmg *= target.resist
	_last_eff = Elements.multiplier(element, target.element)
	dmg *= _last_eff
	dmg *= skills.damage_bonus(attacker)
	if attacker.is_ally():
		# Passive "Ruhige Hand": Der Bogenschütze trifft aus der hinteren Reihe öfter kritisch.
		var chance := CRIT_CHANCE
		if attacker.klass == "archer" and attacker.back_row:
			chance += 0.2
		if randf() < chance:
			dmg *= CRIT_MULT
			_last_crit = true
	return maxi(1, roundi(dmg))


## Angriff: Schaden berechnen und zufügen. Gibt die verlorenen LP zurück.
func hit(attacker: Fighter, target: Fighter, base: float, kind: String, element := "") -> int:
	if not target.is_alive():
		return 0
	var dmg := calc_damage(attacker, target, base, kind, element)
	var lost := apply_damage(target, dmg, attacker, kind)
	if dungeon != null:
		dungeon.on_hit(attacker, target, element, lost)
	return lost


## Zieht Leben ab (Festung, Rüstung, Schilde und Umwandlung eingerechnet).
## Gibt den tatsächlich verlorenen Lebensbetrag zurück.
func apply_damage(target: Fighter, amount: int, source: Fighter = null, kind := "") -> int:
	var crit := _last_crit
	var eff := _last_eff
	_last_crit = false
	_last_eff = 1.0
	if not target.is_alive():
		return 0
	if dungeon != null and dungeon.absorbs(target, amount, source):
		return 0
	if crit:
		crits += 1
	var tank := hero("tank")
	if target.is_ally() and tank != null and target != tank and tank.fortress and tank.is_alive():
		float_text(target, "Festung!", Color("6fa8ff"))
		var halved := roundi(amount * 0.5)
		tank.stat_blocked += amount - halved
		target = tank
		amount = halved
	if tank != null and target == tank and tank.fortress:
		tank.fortress_absorbed += amount

	amount = skills.mitigate(target, amount, kind)

	if target.shield_total() > 0 and amount > 0:
		var blocked_total := 0
		for giver: Fighter in target.shields.keys():
			var used := mini(target.shields[giver], amount)
			target.shields[giver] -= used
			amount -= used
			blocked_total += used
			giver.credit().stat_blocked += used
			if target.shields[giver] <= 0:
				target.shields.erase(giver)
		if blocked_total > 0:
			float_text(target, "Schild -%d" % blocked_total, Color("6fa8ff"), 24)

	# Umwandlung: Der Magier-Tank fängt die Hälfte mit Mana ab. Das lädt seine Ult.
	if target.klass == "tank" and amount > 0:
		var to_mana := mini(target.mana, amount / 2)
		target.mana -= to_mana
		amount -= to_mana
		target.stat_blocked += to_mana
		target.add_ult(to_mana * 1.5)
		if to_mana > 0:
			float_text(target, "-%d Mana" % to_mana, Color("6fa8ff"), 24)

	var lost := mini(amount, target.hp)
	target.hp -= lost
	if source != null and source.is_ally() and not target.is_ally():
		source.credit().stat_damage += lost
	# Was der Roboter einsteckt, kommt bei niemand anderem an: zählt beim Mechaniker als abgewehrt
	if target.klass == "robot":
		target.credit().stat_blocked += lost
	elif target.is_ally():
		target.credit().stat_taken += lost

	if crit:
		float_text(target, "KRITISCH -%d" % amount, Color("ffd34d"))
	else:
		float_text(target, "-%d" % amount, Color("ff6b6b"))
	if eff > 1.0:
		float_text(target, "Sehr effektiv!", Color("ffe14d"), 52)
	elif eff < 1.0:
		float_text(target, "Wenig effektiv …", Color(0.75, 0.75, 0.8), 52)
	if has_view(target):
		var target_view := view(target)
		target_view.hit_react()
		Fx.spawn(_field, Fx.Kind.SPARKS, target_view.center(), Color("ffd9a0") if not crit else Color("ffe14d"), 70.0 if not crit else 110.0, 0.4)

	skills.after_damage(target, lost)
	if not target.is_alive():
		add_log("[color=red]%s ist besiegt![/color]" % target.display_name)
		skills.on_death(target)
	refresh()
	return lost


## Heilt ein Ziel. "source" bekommt die Heilung in der Auswertung gutgeschrieben.
func heal(source: Fighter, target: Fighter, amount: int) -> int:
	var healed := target.heal(amount)
	if source != null:
		source.credit().stat_heal += healed
	if has_view(target):
		float_text(target, "+%d" % healed, Color("6dff8a"))
		var v := view(target)
		v.glow(Color("8affa0"), 0.6)
		Fx.spawn(_field, Fx.Kind.GLOW, v.center(), Color("4cff7a"), 90.0, 0.6)
		Fx.spawn(_field, Fx.Kind.SPARKS, v.center(), Color("b6ffc8"), 60.0, 0.6)
	return healed


func give_shield(source: Fighter, target: Fighter, amount: int) -> void:
	target.add_shield(source, amount)
	float_text(target, "Schild +%d" % amount, Color("6fa8ff"))


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
	add_child(Backdrop.new())
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
	menu.text = "Auswahl"
	menu.position = Vector2(1170, 16)
	menu.size = Vector2(96, 44)
	menu.add_theme_font_size_override("font_size", 16)
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
		view(f).active = f == current

	for child in _order_box.get_children():
		child.queue_free()
	var order := peek_order(8)
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
		portrait.texture = FighterView.portrait(f.klass)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.custom_minimum_size = Vector2(24, 48)
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		portrait.flip_h = f.is_ally()
		portrait.self_modulate = FighterView.tint(f.klass)
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
	sub.text = "Kampfauswertung · %d Züge · Welle %d von %d · %s" % [_turns, _wave + 1, _waves.size(), Sandbox.ENCOUNTERS[Sandbox.encounter].name]
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
	for h in heroes:
		best.dmg = maxi(best.dmg, h.stat_damage)
		best.heal = maxi(best.heal, h.stat_heal)
		best.blocked = maxi(best.blocked, h.stat_blocked)
	for h in heroes:
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


func _cell(text: String, color: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
