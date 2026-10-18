extends Control
## Kampf-Prototyp nach design.md (Abschnitt 4 und 5):
## - Zugreihenfolge nach Tempo, Leiste oben zeigt die nächsten Züge
## - Zwei Reihen: Hinten macht und bekommt man weniger Nahkampf-Schaden
## - Perfekte Reaktion: Ring schließt sich, im richtigen Moment tippen = Parieren / Ausweichen
## - Ult-Leiste je Klasse, lädt nur durch die klassentypische Aktion
## Die Oberfläche wird komplett im Code gebaut, damit alles an einer Stelle steht.

signal _turn_done

const SCREEN := Vector2(1280, 720)
const HERO_SIZE := Vector2(250, 100)
const BACK_X := 20.0
const FRONT_X := 290.0
const HERO_Y: Array[float] = [100.0, 207.0, 314.0, 421.0]

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

## Boss-Werte
const BOSS_FIST := 23
const BOSS_ROCKFALL := 32
const BOSS_CHAIN := 10
const BOSS_RAGE_AT := 0.3
const BOSS_RAGE_MULT := 1.3

var heroes: Array[Fighter] = []
var enemies: Array[Fighter] = []
var current: Fighter
var battle_over := false

var _views := {}
var _pending := {}
var _pending_user: Fighter

var _reacting := false
var _react_start := 0
var _react_duration := 1.0
var _react_press := -1.0
var _react_target: Fighter
var _react_feedback := ""
var _last_crit := false
## Kritische Treffer der laufenden Aktion (lädt die Ult des Bogenschützen).
var _crits := 0

var _field: Control
var _ring_layer: Control
var _order_box: HBoxContainer
var _turn_label: Label
var _grid: GridContainer
var _log: RichTextLabel
var _rotate_hint: Label


func _ready() -> void:
	randomize()
	_build_ui()
	_create_fighters()
	_add_log("[b]Ein Steinwächter und seine Begleiter greifen an![/b]")
	_add_log("Tippe eine Fähigkeit an, dann das Ziel.")
	_add_log("Bei Gegner-Angriffen: tippen, wenn sich der [color=#f2c14e]Ring[/color] schließt!")
	_battle_loop()


func _process(_delta: float) -> void:
	if _reacting:
		_ring_layer.queue_redraw()


# --- Teilnehmer ---------------------------------------------------------------

func _create_fighters() -> void:
	var tank := Fighter.new("Arkon", "tank", "Magier-Tank", true, 150, 9, Color("4a7cff"), Fighter.Shape.SQUARE)
	tank.max_mana = 80
	tank.mana = 60
	tank.reaction = "parry"
	var archer := Fighter.new("Wren", "archer", "Bogenschütze", true, 95, 13, Color("5fd35f"), Fighter.Shape.TRIANGLE)
	archer.max_mana = 50
	archer.mana = 50
	archer.reaction = "dodge"
	archer.back_row = true
	var ritualist := Fighter.new("Vesna", "ritualist", "Ritualist", true, 110, 10, Color("c2304f"), Fighter.Shape.DIAMOND)
	ritualist.back_row = true
	var singer := Fighter.new("Lyra", "singer", "Sternensängerin", true, 95, 11, Color("ffd34d"), Fighter.Shape.STAR)
	singer.max_mana = 90
	singer.mana = 90
	singer.reaction = "dodge"
	singer.back_row = true
	heroes = [tank, archer, ritualist, singer]

	var wolf := Fighter.new("Grubenwolf", "wolf", "Monster", false, 55, 14, Color("9aa3b5"), Fighter.Shape.FANG)
	var slime := Fighter.new("Schleimling", "slime", "Monster", false, 65, 7, Color("7ad66b"), Fighter.Shape.CIRCLE)
	var boss := Fighter.new("Steinwächter", "boss", "BOSS", false, 380, 9, Color("9b5cd6"), Fighter.Shape.HEXAGON)
	boss.intent = "Schlägt mit der Steinfaust zu."
	enemies = [wolf, slime, boss]

	for i in heroes.size():
		var hero := heroes[i]
		var x := BACK_X if hero.back_row else FRONT_X
		_add_view(hero, Vector2(x, HERO_Y[i]), HERO_SIZE)
	_add_view(wolf, Vector2(790, 110), Vector2(230, 100))
	_add_view(slime, Vector2(790, 330), Vector2(230, 100))
	_add_view(boss, Vector2(1035, 190), Vector2(235, 190))

	for f in _all():
		f.next_time = f.turn_delay() * randf_range(0.2, 1.0)


func _add_view(f: Fighter, pos: Vector2, view_size: Vector2) -> void:
	var view := FighterView.new()
	view.setup(f, view_size)
	view.position = pos
	view.tapped.connect(_on_fighter_tapped)
	_field.add_child(view)
	_views[f] = view


func _all() -> Array[Fighter]:
	var result: Array[Fighter] = []
	result.append_array(heroes)
	result.append_array(enemies)
	return result


func _alive(group: Array[Fighter]) -> Array[Fighter]:
	var result: Array[Fighter] = []
	for f in group:
		if f.is_alive():
			result.append(f)
	return result


func _view(f: Fighter) -> FighterView:
	return _views[f]


func _hero(klass: String) -> Fighter:
	for hero in heroes:
		if hero.klass == klass:
			return hero
	return null


# --- Zugreihenfolge -----------------------------------------------------------

## Wer als Nächstes dran ist: kleinster Zeitpunkt, bei Gleichstand zuerst die Helden.
func _earliest(times: Dictionary) -> Fighter:
	var best: Fighter = null
	for f: Fighter in times:
		if best == null or times[f] < times[best] - 0.001 \
				or (absf(times[f] - times[best]) <= 0.001 and f.is_hero and not best.is_hero):
			best = f
	return best


## Simuliert die nächsten Züge für die Leiste oben.
func _peek_order(count: int) -> Array[Fighter]:
	var times := {}
	for f in _alive(_all()):
		times[f] = f.next_time
	var result: Array[Fighter] = []
	while result.size() < count and not times.is_empty():
		var f := _earliest(times)
		result.append(f)
		times[f] += f.turn_delay()
	return result


func _battle_loop() -> void:
	while not battle_over:
		var times := {}
		for f in _alive(_all()):
			times[f] = f.next_time
		var f := _earliest(times)
		current = f
		_refresh()
		await _begin_turn(f)
		if _check_end():
			return
		if f.is_hero:
			await _player_turn(f)
		else:
			await _enemy_turn(f)
		f.next_time += f.turn_delay()
		current = null
		_refresh()
		if _check_end():
			return


## Was zu Beginn jedes eigenen Zuges passiert (Abklingzeiten, Mana, Klassen-Mechaniken).
func _begin_turn(f: Fighter) -> void:
	for id: String in f.cooldowns.keys():
		f.cooldowns[id] = maxi(f.cooldowns[id] - 1, 0)
	f.atk_buff_turns = maxi(f.atk_buff_turns - 1, 0)
	f.def_buff_turns = maxi(f.def_buff_turns - 1, 0)
	if f.max_mana > 0:
		f.mana = mini(f.mana + MANA_REGEN, f.max_mana)

	if f.klass == "tank" and f.fortress:
		f.fortress = false
		var power := maxi(20, f.fortress_absorbed)
		_add_log("[color=#4a8cf0][b]Die Arkane Festung explodiert![/b][/color] (%d aufgefangener Schaden)" % f.fortress_absorbed)
		_shake(_view(f))
		await _wait(0.4)
		for enemy in _alive(enemies):
			_apply_damage(enemy, power)
		await _wait(0.6)

	if f.klass == "singer":
		# Verblassen: Ein Sternbild, das 2 Züge nicht gefüllt wurde, verliert jeden Zug 1 Resonanz.
		if f.off_idle >= 2 and f.res_off > 0:
			f.res_off -= 1
			_float(f, "Verblassen", Color("ff8a3d"))
		if f.def_idle >= 2 and f.res_def > 0:
			f.res_def -= 1
			_float(f, "Verblassen", Color("6fe0ff"))
		f.off_idle += 1
		f.def_idle += 1
	_refresh()


func _check_end() -> bool:
	if battle_over:
		return true
	var won := _alive(enemies).is_empty()
	var lost := _alive(heroes).is_empty()
	if not won and not lost:
		return false
	battle_over = true
	_clear_actions()
	current = null
	_refresh()
	_turn_label.text = "Sieg!" if won else "Niederlage …"
	if won:
		_add_log("\n[color=green][b]Der Steinwächter ist besiegt![/b][/color]")
	else:
		_add_log("\n[color=red][b]Alle Helden sind gefallen.[/b][/color]")
	_show_end_screen(won)
	return true


# --- Spieler-Zug --------------------------------------------------------------

func _player_turn(f: Fighter) -> void:
	_show_actions(f)
	await _turn_done


## Alle Fähigkeiten einer Klasse (vereinfacht nach design.md).
## target: enemy, ally, ally_other oder none
func _abilities(f: Fighter) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	match f.klass:
		"tank":
			list = [
				{id = "arcane_strike", name = "Arkaner Stoß", info = "16 Magie-Schaden", target = "enemy"},
				{id = "ban", name = "Bann-Zeichen", info = "Nächste 3 Angriffe auf dich · 10 Mana", target = "none", mana = 10, cd = 3},
				{id = "barrier", name = "Barriere", info = "Schild 25 für Verbündeten · 15 Mana", target = "ally", mana = 15, cd = 2},
				{id = "condense", name = "Rüstung verdichten", info = "+25 Mana, Abwehr+ für 2 Züge", target = "none", cd = 3},
				{id = "ult", name = "Arkane Festung", info = "Fängt Schaden der Gruppe ab, explodiert im nächsten Zug", target = "none"},
			]
		"archer":
			var shot_name := "Aufgeladener Schuss" if f.charged else "Schneller Schuss"
			var shot_info := "32 Fernkampf-Schaden" if f.charged else "12 Fernkampf-Schaden"
			list = [
				{id = "shot", name = shot_name, info = shot_info, target = "enemy"},
				{id = "charge", name = "Bogen spannen", info = "Nächster Schuss ×2,5 (Treffer unterbricht)", target = "none"},
				{id = "volley", name = "Pfeilhagel", info = "9 Schaden an alle · 15 Mana", target = "none", mana = 15, cd = 2},
				{id = "net", name = "Netzpfeil", info = "6 Schaden, Ziel rutscht auf der Leiste zurück · 10 Mana", target = "enemy", mana = 10, cd = 3},
				{id = "ult", name = "Jägerpfeil", info = "70 Fernkampf-Schaden", target = "enemy"},
			]
		"ritualist":
			list = [
				{id = "bite", name = "Biss", info = "14 Nahkampf, heilt dich, füllt Blutvorrat", target = "enemy"},
				{id = "gift", name = "Blutgabe", info = "Heilt 32 · kostet 14 Blut/Leben", target = "ally_other", blood = 14},
				{id = "circle", name = "Blutkreis", info = "Heilt alle 16 · kostet 22 Blut/Leben", target = "none", blood = 22, cd = 2},
				{id = "pact", name = "Blutpakt", info = "Angriff+ für Verbündeten · kostet 10", target = "ally_other", blood = 10, cd = 2},
				{id = "ult", name = "Großes Opfer", info = "Kostet halbe LP: heilt alle 60, belebt Gefallene", target = "none"},
			]
		"singer":
			var lullaby_info := "Heilt 24, +1 Schutz-Sternbild · 8 Mana"
			if f.res_def >= Fighter.MAX_RES:
				lullaby_info = "Sternenglanz: heilt die GANZE Gruppe 24 · 8 Mana"
			var comet_info := "Verbraucht Angriffs-Resonanz: 8 + 8 je Punkt · 10 Mana"
			if f.res_off >= Fighter.MAX_RES:
				comet_info = "Sternenglanz: trifft ALLE Gegner mit 48 · 10 Mana"
			list = [
				{id = "spark", name = "Sternenfunke", info = "11 Magie, +1 Angriffs-Sternbild", target = "enemy"},
				{id = "lullaby", name = "Mondwiegenlied", info = lullaby_info, target = "ally", mana = 8},
				{id = "comet", name = "Kometenlied", info = comet_info, target = "enemy", mana = 10},
				{id = "meteor", name = "Sternschnuppenregen", info = "Verbraucht Schutz-Resonanz: heilt alle 7 je Punkt · 10 Mana", target = "none", mana = 10},
				{id = "ult", name = "Himmelszelt", info = "Heilt alle 35, Angriff+ und Abwehr+", target = "none"},
			]
	var row_name := "Nach vorne" if f.back_row else "Nach hinten"
	list.append({id = "row", name = row_name, info = "Reihe wechseln (kostet den Zug)", target = "none"})
	return list


## Kann die Fähigkeit gerade benutzt werden? Gibt "" zurück oder den Grund, warum nicht.
func _blocked_reason(f: Fighter, ab: Dictionary) -> String:
	var id: String = ab.id
	if id == "ult":
		if not f.ult_ready():
			return "Ult %d %%" % int(f.ult)
		if f.klass == "ritualist" and f.hp - maxi(f.max_hp / 2 - f.blood, 0) < 10:
			return "Zu wenig Leben"
		return ""
	if f.cooldown(id) > 0:
		return "Bereit in %d" % f.cooldown(id)
	if ab.get("mana", 0) > f.mana:
		return "Zu wenig Mana"
	if ab.has("blood") and f.hp + f.blood - int(ab.blood) < 1:
		return "Zu wenig Leben"
	match id:
		"charge":
			if f.charged:
				return "Schon gespannt"
		"comet":
			if f.res_off == 0:
				return "Keine Resonanz"
		"meteor":
			if f.res_def == 0:
				return "Keine Resonanz"
	return ""


func _show_actions(f: Fighter) -> void:
	_clear_actions()
	_turn_label.text = "%s (%s) ist am Zug" % [f.display_name, f.class_title]
	for ab in _abilities(f):
		var reason := _blocked_reason(f, ab)
		var button := Button.new()
		var title: String = ab.name
		if ab.id == "ult":
			title = "ULT: " + title
		button.text = "%s\n%s" % [title, reason if reason != "" else ab.info]
		button.disabled = reason != ""
		button.custom_minimum_size = Vector2(266, 72)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_size_override("font_size", 15)
		if ab.id == "ult" and reason == "":
			button.add_theme_color_override("font_color", Color("f2c14e"))
		button.pressed.connect(_on_ability_pressed.bind(f, ab))
		_grid.add_child(button)


func _on_ability_pressed(f: Fighter, ab: Dictionary) -> void:
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
	for target in _valid_targets(f, ab):
		_view(target).targetable = true
	var back := Button.new()
	back.text = "Zurück"
	back.custom_minimum_size = Vector2(266, 72)
	back.add_theme_font_size_override("font_size", 18)
	back.pressed.connect(_on_back_pressed.bind(f))
	_grid.add_child(back)


func _on_back_pressed(f: Fighter) -> void:
	_cancel_targeting()
	_show_actions(f)


func _valid_targets(f: Fighter, ab: Dictionary) -> Array[Fighter]:
	match ab.target:
		"enemy":
			return _alive(enemies)
		"ally":
			return _alive(heroes)
		"ally_other":
			var others := _alive(heroes)
			others.erase(f)
			return others
	return []


func _cancel_targeting() -> void:
	_pending = {}
	_pending_user = null
	for view: FighterView in _views.values():
		view.targetable = false


func _on_fighter_tapped(target: Fighter) -> void:
	if _pending.is_empty() or not _view(target).targetable:
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
	_crits = 0
	f.mana -= ab.get("mana", 0)
	if ab.has("cd"):
		f.cooldowns[id] = ab.cd + 1

	if id == "row":
		f.back_row = not f.back_row
		_add_log("%s wechselt nach %s." % [f.display_name, f.row_name()])
		await _move_to_row(f)
		return
	if id == "ult":
		f.ult = 0.0
		_add_log("[color=#f2c14e][b]%s entfesselt %s![/b][/color]" % [f.display_name, ab.name])
		_shake(_view(f))

	match f.klass:
		"tank":
			await _execute_tank(f, id, target)
		"archer":
			await _execute_archer(f, id, target)
		"ritualist":
			await _execute_ritualist(f, id, target, int(ab.get("blood", 0)))
		"singer":
			await _execute_singer(f, id, target)
	_refresh()
	await _wait(0.35)


func _execute_tank(f: Fighter, id: String, target: Fighter) -> void:
	match id:
		"arcane_strike":
			await _projectile(f, target, Color("4a8cf0"))
			_apply_damage(target, _calc_damage(f, target, 16, "magic"))
		"ban":
			f.taunt = 3
			_add_log("%s zeichnet ein Bann-Zeichen: Gegner müssen ihn angreifen." % f.display_name)
			_float(f, "Bann!", Color("6fa8ff"))
		"barrier":
			target.shield += 25
			_float(target, "Schild +25", Color("6fa8ff"))
			_add_log("%s schützt %s mit einer Barriere." % [f.display_name, target.display_name])
		"condense":
			f.mana = mini(f.mana + 25, f.max_mana)
			f.def_buff_turns = BUFF_TURNS + 1
			_float(f, "+25 Mana", Color("6fa8ff"))
			_add_log("%s verdichtet seine Rüstung." % f.display_name)
		"ult":
			f.fortress = true
			f.fortress_absorbed = 0
			_add_log("Bis zu seinem nächsten Zug fängt Arkon den Schaden der Gruppe zur Hälfte ab.")


func _execute_archer(f: Fighter, id: String, target: Fighter) -> void:
	match id:
		"shot":
			var base := 12.0
			if f.charged:
				base = 30.0
				f.charged = false
				f.add_ult(30)
			await _projectile(f, target, Color("b8ff8a"))
			_apply_damage(target, _calc_damage(f, target, base, "ranged"))
		"charge":
			f.charged = true
			_float(f, "Gespannt", Color("b8ff8a"))
			_add_log("%s spannt den Bogen." % f.display_name)
		"volley":
			for enemy in _alive(enemies):
				_projectile(f, enemy, Color("b8ff8a"))
			await _wait(0.3)
			for enemy in _alive(enemies):
				_apply_damage(enemy, _calc_damage(f, enemy, 9, "ranged"))
		"net":
			await _projectile(f, target, Color.WHITE)
			_apply_damage(target, _calc_damage(f, target, 6, "ranged"))
			target.next_time += target.turn_delay() * 0.7
			_float(target, "Gefesselt", Color.WHITE, 30)
			_add_log("%s rutscht auf der Zugleiste nach hinten." % target.display_name)
		"ult":
			await _projectile(f, target, Color("f2c14e"))
			_apply_damage(target, _calc_damage(f, target, 70, "ranged"))
	f.add_ult(20 * _crits)


func _execute_ritualist(f: Fighter, id: String, target: Fighter, cost: int) -> void:
	match id:
		"bite":
			await _lunge(f, target, 0.25)
			var dealt := _apply_damage(target, _calc_damage(f, target, 14, "melee"))
			var healed := f.heal(ceili(dealt * 0.5))
			f.blood = mini(f.blood + ceili(dealt * 0.5), Fighter.MAX_BLOOD)
			if healed > 0:
				_float(f, "+%d" % healed, Color("6dff8a"))
		"gift":
			_pay_blood(f, cost)
			_heal(target, 32)
		"circle":
			_pay_blood(f, cost)
			for hero in _alive(heroes):
				_heal(hero, 16)
		"pact":
			_pay_blood(f, cost)
			target.atk_buff_turns = BUFF_TURNS + 1
			_float(target, "Angriff+", Color("ff8080"))
			_add_log("%s schließt einen Blutpakt mit %s." % [f.display_name, target.display_name])
		"ult":
			var price := f.max_hp / 2
			var from_blood := mini(f.blood, price)
			f.blood -= from_blood
			f.hp -= price - from_blood
			_float(f, "-%d" % (price - from_blood), Color("ff6060"))
			for hero in heroes:
				if hero == f:
					continue
				if not hero.is_alive():
					hero.hp = 1
					hero.next_time = current.next_time + hero.turn_delay()
					_add_log("%s wird wiederbelebt!" % hero.display_name)
				_heal(hero, 60)
	await _wait(0.1)


## Ritualist bezahlt mit Blutvorrat, der Rest kommt aus dem eigenen Leben.
## Für andere geopfertes Leben lädt die Ult.
func _pay_blood(f: Fighter, cost: int) -> void:
	var from_blood := mini(f.blood, cost)
	f.blood -= from_blood
	var from_hp := cost - from_blood
	f.hp = maxi(f.hp - from_hp, 1)
	if from_hp > 0:
		_float(f, "-%d" % from_hp, Color("ff6060"))
	f.add_ult(cost * 1.2)


func _execute_singer(f: Fighter, id: String, target: Fighter) -> void:
	match id:
		"spark":
			await _projectile(f, target, Color("ffe680"))
			_apply_damage(target, _calc_damage(f, target, 11, "magic"))
			_add_resonance(f, true)
		"lullaby":
			if f.res_def >= Fighter.MAX_RES:
				_add_log("[color=#6fe0ff]Sternenglanz![/color] Das Wiegenlied klingt für die ganze Gruppe.")
				for hero in _alive(heroes):
					_heal(hero, 24)
			else:
				_heal(target, 24)
			_add_resonance(f, false)
		"comet":
			var used := f.res_off
			f.res_off = 0
			f.add_ult(used * 12)
			var dmg := 8.0 + 8.0 * used
			var targets: Array[Fighter] = [target]
			if used >= Fighter.MAX_RES:
				_add_log("[color=#ff8a3d]Sternenglanz![/color] Der Komet trifft alle Gegner.")
				targets = _alive(enemies)
			for enemy in targets:
				_projectile(f, enemy, Color("ff8a3d"))
			await _wait(0.3)
			for enemy in targets:
				_apply_damage(enemy, _calc_damage(f, enemy, dmg, "magic"))
		"meteor":
			var used := f.res_def
			f.res_def = 0
			f.add_ult(used * 12)
			for hero in _alive(heroes):
				_heal(hero, 7 * used)
		"ult":
			for hero in _alive(heroes):
				_heal(hero, 35)
				hero.atk_buff_turns = BUFF_TURNS + 1
				hero.def_buff_turns = BUFF_TURNS + 1
	await _wait(0.1)


func _add_resonance(f: Fighter, offensive: bool) -> void:
	if offensive:
		f.res_off = mini(f.res_off + 1, Fighter.MAX_RES)
		f.off_idle = 0
	else:
		f.res_def = mini(f.res_def + 1, Fighter.MAX_RES)
		f.def_idle = 0


# --- Gegner-Zug ---------------------------------------------------------------

func _enemy_turn(e: Fighter) -> void:
	_turn_label.text = "%s ist am Zug …" % e.display_name
	await _wait(0.5)
	match e.klass:
		"wolf":
			await _enemy_attack(e, [_pick_target()], 13, "melee", "Biss")
		"slime":
			await _enemy_attack(e, [_pick_target()], 15, "melee", "Schleimschlag")
		"boss":
			await _boss_turn(e)


func _boss_turn(boss: Fighter) -> void:
	if not boss.enraged and boss.hp <= boss.max_hp * BOSS_RAGE_AT:
		boss.enraged = true
		_add_log("[color=red][b]Der Steinwächter wird wütend![/b] Er schlägt härter zu.[/color]")
	match boss.boss_step % 4:
		0:
			await _enemy_attack(boss, [_pick_target()], BOSS_FIST, "melee", "Steinfaust")
			boss.intent = "Sammelt Kraft …"
		1:
			await _enemy_attack(boss, [_pick_target()], BOSS_FIST - 6, "melee", "Steinfaust")
			boss.intent = "NÄCHSTER ZUG: Felsregen auf die HINTERE Reihe!"
			_add_log("[color=yellow]Der Steinwächter hebt die Arme: Gleich regnet es Felsen auf die hintere Reihe![/color]")
		2:
			var targets := _alive(heroes).filter(func(h: Fighter) -> bool: return h.back_row)
			if targets.is_empty():
				_add_log("Felsregen! Aber hinten steht niemand mehr.")
				_float(boss, "Verfehlt!", Color.WHITE)
			else:
				var typed: Array[Fighter] = []
				typed.assign(targets)
				await _enemy_attack(boss, typed, BOSS_ROCKFALL, "magic", "Felsregen")
			boss.intent = "Wirft seine Kette nach hinten."
		3:
			var back := _alive(heroes).filter(func(h: Fighter) -> bool: return h.back_row)
			var target: Fighter = back.pick_random() if not back.is_empty() else _pick_target()
			if target.back_row:
				target.back_row = false
				_add_log("[color=yellow]Kettenzug! %s wird nach vorne gerissen.[/color]" % target.display_name)
				await _move_to_row(target)
			await _enemy_attack(boss, [target], BOSS_CHAIN, "melee", "Kettenzug")
			boss.intent = "Schlägt mit der Steinfaust zu."
	boss.boss_step += 1


## Nahkämpfer zielen meist auf die vordere Reihe. Ein Bann-Zeichen zwingt sie zum Tank.
func _pick_target() -> Fighter:
	var tank := _hero("tank")
	if tank.is_alive() and tank.taunt > 0:
		tank.taunt -= 1
		return tank
	var alive := _alive(heroes)
	var front := alive.filter(func(h: Fighter) -> bool: return not h.back_row)
	var back := alive.filter(func(h: Fighter) -> bool: return h.back_row)
	if not front.is_empty() and (back.is_empty() or randf() < 0.7):
		return front.pick_random()
	return back.pick_random()


## Ein Gegner-Angriff mit Chance auf perfekte Reaktion.
func _enemy_attack(e: Fighter, targets: Array[Fighter], base: int, kind: String, attack_name: String) -> void:
	var names: Array[String] = []
	for t in targets:
		names.append(t.display_name)
	_add_log("%s: [b]%s[/b] auf %s" % [e.display_name, attack_name, ", ".join(names)])
	_turn_label.text = "%s: %s!" % [e.display_name, attack_name]

	var reactors := targets.filter(func(h: Fighter) -> bool: return h.reaction != "")
	var focus: Fighter = reactors[0] if not reactors.is_empty() else targets[0]
	var duration := randf_range(0.75, 1.15)
	if kind == "melee":
		_lunge(e, focus, duration)
	else:
		for t in targets:
			_projectile(e, t, Color("b98cff"), duration)

	var success := false
	if reactors.is_empty():
		await _wait(duration)
	else:
		success = await _reaction_window(focus, duration)

	for t in targets:
		if not t.is_alive():
			continue
		if success and t.reaction != "":
			_on_perfect_reaction(t)
		else:
			_apply_damage(t, _calc_damage(e, t, base, kind))
	_refresh()
	await _wait(0.45)


func _on_perfect_reaction(h: Fighter) -> void:
	match h.klass:
		"tank":
			h.mana = mini(h.mana + 15, h.max_mana)
			_float(h, "PARIERT! +15 Mana", Color("6fa8ff"))
		"singer":
			_add_resonance(h, true)
			_add_resonance(h, false)
			_float(h, "AUSGEWICHEN! +1 Resonanz", Color("ffe680"))
		_:
			_float(h, "AUSGEWICHEN!", Color("b8ff8a"))
	_add_log("[color=#8affc1]%s reagiert perfekt![/color]" % h.display_name)


# --- Perfekte Reaktion --------------------------------------------------------

## Zeigt den schrumpfenden Ring. Gibt true zurück, wenn im richtigen Moment getippt wurde.
func _reaction_window(target: Fighter, duration: float) -> bool:
	_react_target = target
	_react_duration = duration
	_react_press = -1.0
	_react_feedback = ""
	_react_start = Time.get_ticks_usec()
	_reacting = true
	await _wait(duration + REACT_LATE)
	_reacting = false
	_ring_layer.queue_redraw()
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
	elif _react_press < _react_duration:
		_react_feedback = "Zu früh!"
	else:
		_react_feedback = "Zu spät!"


func _draw_ring() -> void:
	if not _reacting:
		return
	var c := _view(_react_target).center()
	var t := _react_time()
	var progress := clampf(t / _react_duration, 0.0, 1.0)
	var radius := lerpf(RING_START, RING_TARGET, progress)
	var in_window := _is_perfect(t)
	var font := ThemeDB.fallback_font
	_ring_layer.draw_circle(c, RING_TARGET, Color(1, 1, 1, 0.12))
	_ring_layer.draw_arc(c, RING_TARGET, 0, TAU, 48, Color(1, 1, 1, 0.9), 3)
	var ring_color := Color("6dff8a") if in_window else Color("f2c14e")
	if _react_press < 0.0:
		_ring_layer.draw_arc(c, radius, 0, TAU, 64, ring_color, 6)
	var verb := "PARIEREN" if _react_target.reaction == "parry" else "AUSWEICHEN"
	var text := _react_feedback if _react_feedback != "" else "Tippen zum " + verb.capitalize() + "!"
	var color := Color("6dff8a") if _react_feedback == "PERFEKT!" else Color.WHITE
	if _react_feedback != "" and _react_feedback != "PERFEKT!":
		color = Color("ff6b6b")
	var text_y := c.y - RING_START - 12
	if text_y < 30:
		text_y = c.y + RING_START + 30
	_ring_layer.draw_string(font, Vector2(c.x - 150, text_y), text, HORIZONTAL_ALIGNMENT_CENTER, 300, 22, color)


# --- Schaden und Heilung ------------------------------------------------------

func _calc_damage(attacker: Fighter, target: Fighter, base: float, kind: String) -> int:
	var dmg := base * randf_range(0.9, 1.1)
	_last_crit = false
	if attacker.atk_buff_turns > 0:
		dmg *= ATK_BUFF
	if kind == "melee":
		if attacker.back_row:
			dmg *= BACK_ROW_MELEE
		if target.back_row:
			dmg *= BACK_ROW_MELEE
	if target.def_buff_turns > 0:
		dmg *= DEF_BUFF
	if attacker.enraged:
		dmg *= BOSS_RAGE_MULT
	if attacker.is_hero:
		# Passive "Ruhige Hand": Der Bogenschütze trifft aus der hinteren Reihe öfter kritisch.
		var chance := CRIT_CHANCE
		if attacker.klass == "archer" and attacker.back_row:
			chance += 0.2
		if randf() < chance:
			dmg *= CRIT_MULT
			_last_crit = true
	return maxi(1, roundi(dmg))


## Zieht Leben ab (Schild, Festung und Umwandlung des Magier-Tanks eingerechnet).
## Gibt den tatsächlich verlorenen Lebensbetrag zurück.
func _apply_damage(target: Fighter, amount: int) -> int:
	var crit := _last_crit
	_last_crit = false
	if crit:
		_crits += 1
	var tank := _hero("tank")
	if target.is_hero and target != tank and tank.fortress and tank.is_alive():
		_float(target, "Festung!", Color("6fa8ff"))
		target = tank
		amount = roundi(amount * 0.5)
	if target == tank and tank.fortress:
		tank.fortress_absorbed += amount

	if target.shield > 0:
		var blocked := mini(target.shield, amount)
		target.shield -= blocked
		amount -= blocked
		if blocked > 0:
			_float(target, "Schild -%d" % blocked, Color("6fa8ff"), 24)

	# Umwandlung: Der Magier-Tank fängt die Hälfte mit Mana ab. Das lädt seine Ult.
	if target.klass == "tank" and amount > 0:
		var to_mana := mini(target.mana, amount / 2)
		target.mana -= to_mana
		amount -= to_mana
		target.add_ult(to_mana * 1.5)
		if to_mana > 0:
			_float(target, "-%d Mana" % to_mana, Color("6fa8ff"), 24)

	target.hp = maxi(target.hp - amount, 0)
	if crit:
		_float(target, "KRITISCH -%d" % amount, Color("ffd34d"))
	else:
		_float(target, "-%d" % amount, Color("ff6b6b"))
	_shake(_view(target))

	if target.charged and amount > 0:
		target.charged = false
		_add_log("%s wird getroffen, das Spannen bricht ab." % target.display_name)
	if not target.is_alive():
		_add_log("[color=red]%s ist besiegt![/color]" % target.display_name)
		if target.klass == "tank":
			target.fortress = false
			target.taunt = 0
	_refresh()
	return amount


func _heal(target: Fighter, amount: int) -> void:
	var healed := target.heal(amount)
	_float(target, "+%d" % healed, Color("6dff8a"))


# --- Animationen --------------------------------------------------------------

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


## Figur stürmt auf das Ziel zu und kehrt zurück. Der Aufprall ist nach "duration" Sekunden.
func _lunge(f: Fighter, target: Fighter, duration: float) -> void:
	var view := _view(f)
	var home := view.position
	var to := _view(target).center() - view.size * 0.5
	var hit_pos := home.lerp(to, 0.8)
	view.z_index = 5
	var tween := create_tween()
	tween.tween_property(view, "position", hit_pos, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(view, "position", home, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(duration).timeout
	view.z_index = 0


## Ein Geschoss fliegt vom Angreifer zum Ziel.
func _projectile(from: Fighter, to: Fighter, color: Color, duration := 0.3) -> void:
	var ball := Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(9)
	ball.add_theme_stylebox_override("panel", style)
	ball.size = Vector2(18, 18)
	ball.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ball.position = _view(from).center() - ball.size * 0.5
	ball.z_index = 6
	_field.add_child(ball)
	var tween := create_tween()
	tween.tween_property(ball, "position", _view(to).center() - ball.size * 0.5, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(ball.queue_free)
	await tween.finished


func _shake(view: FighterView) -> void:
	var tween := create_tween()
	for i in 3:
		tween.tween_property(view, "rotation", 0.04 * (1 if i % 2 == 0 else -1), 0.04)
	tween.tween_property(view, "rotation", 0.0, 0.04)


func _move_to_row(f: Fighter) -> void:
	var view := _view(f)
	var x := BACK_X if f.back_row else FRONT_X
	var tween := create_tween()
	tween.tween_property(view, "position:x", x, 0.35).set_trans(Tween.TRANS_QUAD)
	await tween.finished


## Schwebender Text über einer Figur (Schaden, Heilung, Hinweise).
func _float(f: Fighter, text: String, color: Color, offset := 0.0) -> void:
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
	var view := _view(f)
	label.position = Vector2(view.center().x - 150, view.position.y + 10 + offset)
	_field.add_child(label)
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(label, "position:y", label.position.y - 45, 1.1)
	tween.tween_property(label, "modulate:a", 0.0, 1.1).set_delay(0.4)
	tween.chain().tween_callback(label.queue_free)


# --- Oberfläche ---------------------------------------------------------------

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("161827")
	background.size = SCREEN
	add_child(background)

	# Zugleiste oben
	var order_title := Label.new()
	order_title.text = "Nächste\nZüge"
	order_title.position = Vector2(14, 12)
	order_title.add_theme_font_size_override("font_size", 14)
	add_child(order_title)
	_order_box = HBoxContainer.new()
	_order_box.position = Vector2(80, 10)
	_order_box.add_theme_constant_override("separation", 6)
	add_child(_order_box)

	for info: Array in [["hinten", BACK_X], ["vorne", FRONT_X]]:
		var row_label := Label.new()
		row_label.text = "Reihe " + info[0]
		row_label.position = Vector2(info[1] + 8, 76)
		row_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
		add_child(row_label)

	_field = Control.new()
	_field.size = SCREEN
	_field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_field)

	# Untere Leiste: Kampf-Log links, Fähigkeiten rechts
	var bottom := ColorRect.new()
	bottom.color = Color("0f1019")
	bottom.position = Vector2(0, 528)
	bottom.size = Vector2(1280, 192)
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
	_grid.columns = 3
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

	_rotate_hint = Label.new()
	_rotate_hint.text = "Tipp: Handy quer halten"
	_rotate_hint.position = Vector2(490, 470)
	_rotate_hint.add_theme_font_size_override("font_size", 30)
	_rotate_hint.add_theme_color_override("font_color", Color("ffd34d"))
	_rotate_hint.visible = false
	add_child(_rotate_hint)
	get_tree().root.size_changed.connect(_update_rotate_hint)
	_update_rotate_hint()


func _update_rotate_hint() -> void:
	var window := DisplayServer.window_get_size()
	_rotate_hint.visible = window.y > window.x


func _clear_actions() -> void:
	for child in _grid.get_children():
		if child is Button:
			child.disabled = true
		child.queue_free()


func _refresh() -> void:
	for f: Fighter in _views:
		_view(f).active = f == current

	for child in _order_box.get_children():
		child.queue_free()
	var order := _peek_order(9)
	for i in order.size():
		var f := order[i]
		var chip := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.bg_color = f.color.darkened(0.55)
		style.set_corner_radius_all(6)
		style.border_color = f.color if i > 0 else Color("f2c14e")
		style.set_border_width_all(2 if i > 0 else 4)
		style.content_margin_left = 6
		style.content_margin_right = 6
		chip.add_theme_stylebox_override("panel", style)
		chip.custom_minimum_size = Vector2(118, 56)
		var label := Label.new()
		label.text = ("JETZT\n" if i == 0 else "") + f.display_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 15)
		chip.add_child(label)
		_order_box.add_child(chip)


func _add_log(text: String) -> void:
	_log.append_text(text + "\n")


func _show_end_screen(won: bool) -> void:
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.6)
	shade.size = SCREEN
	shade.z_index = 30
	add_child(shade)
	var title := Label.new()
	title.text = "SIEG!" if won else "NIEDERLAGE"
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color("6dff8a") if won else Color("ff6b6b"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size = Vector2(1280, 90)
	title.position = Vector2(0, 230)
	shade.add_child(title)
	var again := Button.new()
	again.text = "Nochmal kämpfen"
	again.add_theme_font_size_override("font_size", 26)
	again.size = Vector2(320, 80)
	again.position = Vector2(480, 360)
	again.pressed.connect(func() -> void: get_tree().reload_current_scene())
	shade.add_child(again)
