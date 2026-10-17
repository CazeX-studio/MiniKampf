extends Control
## Rundenbasierter Kampf: drei Helden (Tank, Heiler, Schaden) gegen einen Boss.
## Die Oberfläche wird komplett im Code gebaut, damit alles an einer Stelle steht.

const BOSS_MAX_HP := 320
## Ab diesem Anteil an LP wird der Boss wütend und macht mehr Schaden.
const ENRAGE_THRESHOLD := 0.25
const ENRAGE_MULTIPLIER := 1.3
## Jede n-te Runde trifft der Boss alle Helden mit dem Erdstampfer.
const STOMP_EVERY := 4
const STOMP_DAMAGE := 10
const BOSS_HIT_MIN := 14
const BOSS_HIT_MAX := 20
## Anteil der Heilung, der als Bedrohung zählt.
const HEAL_THREAT_FACTOR := 0.5

var heroes: Array[Combatant] = []
var boss: Combatant
var round_num := 0
var current_index := 0
var battle_over := false
var boss_enraged := false

var _hero_panels: Array[PanelContainer] = []
var _hero_labels: Array[Label] = []
var _hero_bars: Array[ProgressBar] = []
var _boss_label: Label
var _boss_bar: ProgressBar
var _log: RichTextLabel
var _turn_label: Label
var _actions: HBoxContainer


func _ready() -> void:
	_build_ui()
	_start_battle()


# --- Kampfablauf ---------------------------------------------------------

func _start_battle() -> void:
	heroes = [
		Combatant.new("Brom", Combatant.Role.TANK, 140),
		Combatant.new("Lira", Combatant.Role.HEALER, 80),
		Combatant.new("Kael", Combatant.Role.DPS, 70),
	]
	boss = Combatant.new("Höhlentroll", Combatant.Role.BOSS, BOSS_MAX_HP)
	round_num = 0
	battle_over = false
	boss_enraged = false
	_log.clear()
	_add_log("[b]Ein Höhlentroll versperrt den Weg![/b]")
	_add_log("Tipp: Der Troll greift immer an, wer die höchste [b]Bedrohung[/b] hat.")
	_start_round()


func _start_round() -> void:
	round_num += 1
	for hero in heroes:
		hero.blocking = false
	_add_log("\n[color=gray]— Runde %d —[/color]" % round_num)
	if round_num % STOMP_EVERY == STOMP_EVERY - 1:
		_add_log("[color=yellow]Der Troll sammelt Kraft für einen Erdstampfer …[/color]")
	current_index = -1
	_next_hero()


func _next_hero() -> void:
	current_index += 1
	while current_index < heroes.size() and not heroes[current_index].is_alive():
		current_index += 1
	if current_index >= heroes.size():
		_boss_turn()
	else:
		_show_actions(heroes[current_index])
	_refresh()


func _on_action(callback: Callable) -> void:
	_clear_actions()
	callback.call(heroes[current_index])
	_refresh()
	if boss.is_alive():
		_next_hero()
	else:
		_end_battle(true)


func _boss_turn() -> void:
	_clear_actions()
	_turn_label.text = "Der Höhlentroll holt aus …"
	await get_tree().create_timer(0.8).timeout

	var multiplier := 1.0
	if boss.hp <= boss.max_hp * ENRAGE_THRESHOLD:
		multiplier = ENRAGE_MULTIPLIER
		if not boss_enraged:
			boss_enraged = true
			_add_log("[color=red][b]Der Troll wird wütend![/b] Er schlägt härter zu.[/color]")

	if round_num % STOMP_EVERY == 0:
		_add_log("[b]Erdstampfer![/b] Der Boden bebt unter allen Helden.")
		for hero in heroes:
			if hero.is_alive():
				_hit_hero(hero, roundi(STOMP_DAMAGE * multiplier))
	else:
		var target := _boss_target()
		_hit_hero(target, roundi(randi_range(BOSS_HIT_MIN, BOSS_HIT_MAX) * multiplier))

	_refresh()
	if _any_hero_alive():
		_start_round()
	else:
		_end_battle(false)


func _end_battle(won: bool) -> void:
	battle_over = true
	_clear_actions()
	if won:
		_turn_label.text = "Sieg in Runde %d!" % round_num
		_add_log("\n[color=green][b]Der Höhlentroll ist besiegt![/b][/color]")
	else:
		_turn_label.text = "Niederlage …"
		_add_log("\n[color=red][b]Alle Helden sind gefallen.[/b][/color]")
	var button := Button.new()
	button.text = "Nochmal kämpfen"
	button.pressed.connect(_start_battle)
	_actions.add_child(button)
	_refresh()


# --- Fähigkeiten ----------------------------------------------------------

func _show_actions(hero: Combatant) -> void:
	_clear_actions()
	_turn_label.text = "%s (%s) ist am Zug:" % [hero.display_name, hero.role_name()]
	match hero.role:
		Combatant.Role.TANK:
			_add_action("Hieb", "8 Schaden, erzeugt doppelte Bedrohung", _tank_strike)
			_add_action("Spott", "Zieht den Troll sofort auf dich", _tank_taunt)
			_add_action("Schildblock", "Halbiert deinen erlittenen Schaden in dieser Runde", _tank_block)
		Combatant.Role.HEALER:
			_add_action("Heilen", "Heilt den am stärksten verletzten Helden um 28 LP", _healer_heal)
			_add_action("Gruppenheilung", "Heilt alle Helden um 12 LP", _healer_group_heal)
			_add_action("Heiliges Licht", "6 Schaden", _healer_smite)
		Combatant.Role.DPS:
			_add_action("Feuerball", "22 Schaden", _dps_fireball)
			_add_action("Verblassen", "Halbiert deine Bedrohung", _dps_fade)


func _tank_strike(hero: Combatant) -> void:
	_damage_boss(hero, 8, 2.0)


func _tank_taunt(hero: Combatant) -> void:
	hero.threat = _highest_threat() + 30.0
	_add_log("%s verspottet den Troll – er hat nur noch Augen für ihn." % hero.display_name)


func _tank_block(hero: Combatant) -> void:
	hero.blocking = true
	hero.threat += 5.0
	_add_log("%s hebt den Schild." % hero.display_name)


func _healer_heal(hero: Combatant) -> void:
	var target := _most_injured()
	var healed := target.heal(28)
	hero.threat += healed * HEAL_THREAT_FACTOR
	_add_log("%s heilt %s um [color=green]%d[/color] LP." % [hero.display_name, target.display_name, healed])


func _healer_group_heal(hero: Combatant) -> void:
	var total := 0
	for ally in heroes:
		total += ally.heal(12)
	hero.threat += total * HEAL_THREAT_FACTOR
	_add_log("%s heilt die Gruppe um insgesamt [color=green]%d[/color] LP." % [hero.display_name, total])


func _healer_smite(hero: Combatant) -> void:
	_damage_boss(hero, 6, 1.0)


func _dps_fireball(hero: Combatant) -> void:
	_damage_boss(hero, 22, 1.0)


func _dps_fade(hero: Combatant) -> void:
	hero.threat *= 0.5
	_add_log("%s zieht sich in die Schatten zurück (Bedrohung halbiert)." % hero.display_name)


func _damage_boss(attacker: Combatant, amount: int, threat_multiplier: float) -> void:
	boss.take_damage(amount)
	attacker.threat += amount * threat_multiplier
	_add_log("%s trifft den Troll für [color=orange]%d[/color] Schaden." % [attacker.display_name, amount])


func _hit_hero(hero: Combatant, amount: int) -> void:
	if hero.blocking:
		amount = roundi(amount * 0.5)
	hero.take_damage(amount)
	var blocked := " (geblockt)" if hero.blocking else ""
	_add_log("Der Troll trifft %s für [color=red]%d[/color] Schaden%s." % [hero.display_name, amount, blocked])
	if not hero.is_alive():
		_add_log("[color=red]%s fällt![/color]" % hero.display_name)


# --- Hilfsfunktionen ------------------------------------------------------

## Der lebende Held mit der höchsten Bedrohung (bei Gleichstand der vordere).
func _boss_target() -> Combatant:
	var target: Combatant = null
	for hero in heroes:
		if hero.is_alive() and (target == null or hero.threat > target.threat):
			target = hero
	return target


func _highest_threat() -> float:
	var highest := 0.0
	for hero in heroes:
		if hero.is_alive():
			highest = maxf(highest, hero.threat)
	return highest


func _most_injured() -> Combatant:
	var target: Combatant = null
	for hero in heroes:
		if not hero.is_alive():
			continue
		var ratio := float(hero.hp) / hero.max_hp
		if target == null or ratio < float(target.hp) / target.max_hp:
			target = hero
	return target


func _any_hero_alive() -> bool:
	for hero in heroes:
		if hero.is_alive():
			return true
	return false


# --- Oberfläche -----------------------------------------------------------

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("1b1b24")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 14)
	margin.add_child(root)

	var title := Label.new()
	title.text = "Mini-Kampf: Holy Trinity"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	_boss_label = Label.new()
	root.add_child(_boss_label)
	_boss_bar = _make_bar(Color("b33a3a"))
	root.add_child(_boss_bar)

	var hero_row := HBoxContainer.new()
	hero_row.add_theme_constant_override("separation", 16)
	root.add_child(hero_row)
	for i in 3:
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hero_row.add_child(panel)
		var box := VBoxContainer.new()
		panel.add_child(box)
		var label := Label.new()
		label.custom_minimum_size = Vector2(0, 80)
		box.add_child(label)
		var bar := _make_bar(Color("3a9b4a"))
		box.add_child(bar)
		_hero_panels.append(panel)
		_hero_labels.append(label)
		_hero_bars.append(bar)

	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.scroll_following = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_log)

	_turn_label = Label.new()
	_turn_label.add_theme_font_size_override("font_size", 18)
	root.add_child(_turn_label)

	_actions = HBoxContainer.new()
	_actions.add_theme_constant_override("separation", 8)
	_actions.custom_minimum_size = Vector2(0, 36)
	root.add_child(_actions)


func _make_bar(color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 18)
	bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	bar.add_theme_stylebox_override("fill", fill)
	return bar


func _add_action(text: String, tooltip: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.tooltip_text = tooltip
	button.pressed.connect(_on_action.bind(callback))
	_actions.add_child(button)


func _clear_actions() -> void:
	for child in _actions.get_children():
		_actions.remove_child(child)
		child.queue_free()


func _add_log(text: String) -> void:
	_log.append_text(text + "\n")


func _refresh() -> void:
	var target := _boss_target()
	for i in heroes.size():
		var hero := heroes[i]
		var text := "%s – %s\nLP: %d / %d\nBedrohung: %d" % [
			hero.display_name, hero.role_name(), hero.hp, hero.max_hp, roundi(hero.threat)]
		if hero.blocking:
			text += "  (blockt)"
		if hero == target:
			text += "\n» Ziel des Trolls «"
		if not hero.is_alive():
			text = "%s – %s\nbesiegt" % [hero.display_name, hero.role_name()]
		_hero_labels[i].text = text
		_hero_bars[i].max_value = hero.max_hp
		_hero_bars[i].value = hero.hp

		if not hero.is_alive():
			_hero_panels[i].modulate = Color(0.4, 0.4, 0.4)
		elif i == current_index and not battle_over:
			_hero_panels[i].modulate = Color(1.0, 1.0, 0.75)
		else:
			_hero_panels[i].modulate = Color(0.8, 0.8, 0.8)

	var enraged := " – WÜTEND" if boss_enraged else ""
	_boss_label.text = "%s%s   LP: %d / %d" % [boss.display_name, enraged, boss.hp, boss.max_hp]
	_boss_bar.max_value = boss.max_hp
	_boss_bar.value = boss.hp
