class_name Pilzhoehle
extends RefCounted
## Test-Dungeon Pilzhöhle unter dem Urbaum (design.md: „Grünwacht im Detail“ und „Dungeon-Regeln“).
## - Eigene Monster: Leuchtmotte, Wurzelkriecher, Sporenwolf, Glimmerkäfer
## - Zwischenboss Sporenkönigin: pro Kampf zufällig EINE Mechanik
##     Wipe „Sporenblüte“ (5 Giftwolken) oder Zusammenspiel (Sporenknospen in derselben Runde besiegen)
## - Endboss Phase 1 Wurzelmutter: Rinde heilt, Splitter-Knoten treffen,
##     Wipe „Verschlingen“ und Zusammenspiel „Zwillingsknoten“
## - Endboss Phase 2 Vorbote: Dunkelheit, keine Zugleiste,
##     Wipe „Lichtfraß“ und Zusammenspiel „Das letzte Licht“

const ENEMY_IDS: Array[String] = [
	"leuchtmotte", "wurzelkriecher", "sporenwolf", "glimmerkaefer",
	"sporenkoenigin", "sporenling", "wurzelmutter", "knoten_vorne", "knoten_hinten", "vorbote",
]
const MAX_CLOUDS := 5
const CLOUD_DAMAGE := 2
const SPORE_HEAL := 0.08
const DEVOUR_TURNS := 3
## Ein zerstörtes Knotenpaar kostet die Wurzelmutter diesen Anteil ihres Lebens.
const PAIR_DAMAGE := 0.25
const MAX_DARKNESS := 6
const DARKNESS_STEP := 0.13

var c: BattleState
## Mechanik der Sporenkönigin in diesem Kampf: "bluete" (Wipe) oder "zwillinge" (Zusammenspiel)
var queen_mode := ""
var clouds := 0
var devour := DEVOUR_TURNS
var pairs_since_warning := 0
var pair_broken := false
var phase2 := false
var darkness := 0


func _init(p_combat: BattleState) -> void:
	c = p_combat


func handles(e: Fighter) -> bool:
	return e.klass in ENEMY_IDS


func _find(klass: String) -> Fighter:
	for e in c.enemies:
		if e.klass == klass:
			return e
	return null


## Wird zu Beginn jeder Welle aufgerufen.
func on_wave(_index: int) -> void:
	queen_mode = ""
	clouds = 0
	if _find("sporenkoenigin") != null:
		queen_mode = c.pick(["bluete", "zwillinge"])
		clouds = 0
		c.add_log("[b]Zwischenboss: Die Sporenkönigin![/b] Ihre Sporenknospen heilen sie.")
		if queen_mode == "bluete":
			c.add_log("[color=#c8a0ff]Mechanik heute: Sporenblüte.[/color] Feuer trifft hart, setzt aber Giftwolken frei. "
				+ "Bei %d Wolken gleichzeitig stirbt die Gruppe! Wind und „Giftwolke vertreiben“ helfen." % MAX_CLOUDS)
		else:
			c.add_log("[color=#c8a0ff]Mechanik heute: Sporen-Zwillinge.[/color] Besiegt beide Sporenknospen in derselben Runde, "
				+ "sonst holt der eine den anderen zurück.")
	elif _find("wurzelmutter") != null:
		devour = DEVOUR_TURNS
		pairs_since_warning = 0
		pair_broken = false
		phase2 = false
		c.add_log("[b]Endboss: Die Wurzelmutter[/b], der gequälte Urbaum. Schläge auf die Rinde heilen sie, "
			+ "trefft die leuchtenden Splitter-Knoten!")
		c.add_log("[color=#c8a0ff]Zwillingsknoten:[/color] Knoten vorne und hinten vor ihrem nächsten Zug zerstören, sonst wachsen sie nach. "
			+ "[color=#ff8080]Verschlingen[/color] kommt in %d Zügen, wenn bis dahin kein Knotenpaar zerstört ist." % DEVOUR_TURNS)
	else:
		c.add_log("[b]Tief in der Pilzhöhle unter dem Urbaum …[/b] Diese Monster gibt es nur hier.")
	_update_intents()


func intent(e: Fighter) -> String:
	match e.klass:
		"leuchtmotte":
			return "Nächster Zug: Blendstaub (blendet)"
		"wurzelkriecher":
			return "Nächster Zug: Umklammern (hält fest)"
		"sporenwolf":
			return "Nächster Zug: Rudelbiss (stärker im Rudel)"
		"glimmerkaefer":
			if e.charge >= 2:
				return "NÄCHSTER ZUG: Entladung auf alle!"
			return "Lädt sich auf (%d/3)" % e.charge
		"sporenling":
			if queen_mode == "zwillinge":
				return "Heilt die Königin, holt Gefallene zurück"
			return "Heilt die Königin"
		"sporenkoenigin":
			var text := "Nächster Zug: %s" % ("Sporenpeitsche" if e.step % 2 == 0 else "Giftsporen (alle)")
			if queen_mode == "bluete":
				text += "\nGiftwolken: %d / %d" % [clouds, MAX_CLOUDS]
			return text
		"wurzelmutter":
			return "Verschlingen in %d Zügen!\n%s" % [devour, "Wurzelschlag" if e.step % 2 == 0 else "Wurzelzug nach vorne"]
		"knoten_vorne", "knoten_hinten":
			return "Splitter-Knoten"
		"vorbote":
			return "Dunkelheit %d / %d\n%s" % [darkness, MAX_DARKNESS, "Schattenwelle (alle)" if e.step % 2 == 0 else "Leerengriff"]
	return ""


func _update_intents() -> void:
	for e in c.enemies:
		e.intent = intent(e)


# --- Gegner-Züge --------------------------------------------------------------

func enemy_turn(e: Fighter) -> void:
	match e.klass:
		"leuchtmotte":
			var t := c.pick_target(false, true)
			await c.enemy_attack(e, [t], 9, "magic", "Blendstaub")
			if t.is_alive():
				t.blind_turns = 2
				c.float_text(t, "Geblendet", Color("fff3b0"), 30)
		"wurzelkriecher":
			var t := c.pick_target()
			await c.enemy_attack(e, [t], 11, "melee", "Umklammern")
			if t.is_alive():
				c.delay(t, 0.4)
				c.float_text(t, "Festgehalten", Color("c99a5b"), 30)
		"sporenwolf":
			var pack := c.alive(c.enemies).filter(func(o: Fighter) -> bool: return o.klass == "sporenwolf" and o != e).size()
			if pack > 0:
				c.add_log("Das Rudel heult: Der Sporenwolf beißt härter.")
			await c.enemy_attack(e, [c.pick_target()], 9 + 4 * pack, "melee", "Rudelbiss")
		"glimmerkaefer":
			if e.charge >= 2:
				e.charge = 0
				await c.enemy_attack(e, c.allies(), 12, "magic", "Entladung")
			else:
				await c.enemy_attack(e, [c.pick_target(false, true)], 6 + 5 * e.charge, "magic", "Funkenbiss")
				e.charge += 1
		"sporenling":
			_sporeling_turn(e)
		"sporenkoenigin":
			await _queen_turn(e)
		"wurzelmutter":
			await _mother_turn(e)
		"vorbote":
			await _herald_turn(e)
	e.step += 1
	_update_intents()


func _sporeling_turn(e: Fighter) -> void:
	if queen_mode == "zwillinge":
		for other in c.enemies:
			if other.klass == "sporenling" and other != e and not other.is_alive():
				other.hp = other.max_hp
				other.next_time = c.now + other.turn_delay()
				c.burst(other, Elements.color("Pflanze"))
				c.add_log("[color=#c8a0ff]Die Sporenknospe holt ihren Zwilling zurück![/color] Beide in derselben Runde besiegen!")
				return
	var queen := _find("sporenkoenigin")
	if queen != null and queen.is_alive():
		c.heal(null, queen, roundi(queen.max_hp * SPORE_HEAL))
		c.add_log("Die Sporenknospe heilt die Sporenkönigin.")
	c.wait(0.3)


func _queen_turn(e: Fighter) -> void:
	if queen_mode == "bluete" and clouds > 0:
		c.add_log("Die Giftwolken brennen in der Lunge (%d Schaden je Wolke)." % CLOUD_DAMAGE)
		for a in c.allies():
			c.apply_damage(a, CLOUD_DAMAGE * clouds, e)
		c.wait(0.3)
	if e.step % 2 == 0:
		await c.enemy_attack(e, [c.pick_target()], 16, "melee", "Sporenpeitsche")
	else:
		await c.enemy_attack(e, c.allies(), 7, "magic", "Giftsporen")
		if queen_mode == "bluete":
			_add_cloud(e, "Die Königin stößt eine Giftwolke aus!")


func _add_cloud(where: Fighter, text: String) -> void:
	clouds += 1
	c.float_text(where, "Giftwolke! (%d/%d)" % [clouds, MAX_CLOUDS], Color("b0ff70"), 52)
	c.add_log("[color=#b0ff70]%s[/color] Giftwolken: %d von %d." % [text, clouds, MAX_CLOUDS])
	_update_intents()


func _mother_turn(e: Fighter) -> void:
	var front := _find("knoten_vorne")
	var back := _find("knoten_hinten")
	if pair_broken:
		pair_broken = false
		_regrow(front)
		_regrow(back)
		c.add_log("Neue Splitter-Knoten wachsen aus der Rinde.")
	elif front.is_alive() != back.is_alive():
		_regrow(back if front.is_alive() else front)
		c.add_log("[color=#c8a0ff]Der zerstörte Knoten wächst nach![/color] Beide vor ihrem Zug zerstören.")

	devour -= 1
	if devour <= 0:
		if pairs_since_warning > 0:
			c.add_log("[color=#8affc1]Verschlingen abgewehrt![/color] Die Wurzeln weichen zurück … und sammeln neue Kraft.")
			devour = DEVOUR_TURNS
			pairs_since_warning = 0
		else:
			c.burst(e, Color("4a2a10"), 300.0)
			c.wipe("Verschlingen! Die Wurzeln ziehen alle unter die Erde.")
			return
	elif devour == 1:
		c.add_log("[color=#ff8080]Der Boden bebt: Im nächsten Zug kommt Verschlingen![/color]")

	if e.step % 2 == 0:
		await c.enemy_attack(e, [c.pick_target()], 15, "melee", "Wurzelschlag")
	else:
		var back_row := c.allies().filter(func(h: Fighter) -> bool: return h.back_row)
		var target: Fighter = c.pick(back_row) if not back_row.is_empty() else c.pick_target()
		if target.back_row:
			target.back_row = false
			c.add_log("[color=yellow]Wurzeln reißen %s nach vorne![/color]" % target.display_name)
			c.move_to_row(target)
		await c.enemy_attack(e, [target], 8, "melee", "Wurzelzug")


func _regrow(knot: Fighter) -> void:
	knot.hp = knot.max_hp
	c.burst(knot, Elements.color("Sternenkraft"), 90.0)


func _herald_turn(e: Fighter) -> void:
	darkness += 1
	c.set_darkness(darkness * DARKNESS_STEP)
	if darkness >= MAX_DARKNESS:
		c.wipe("Lichtfraß! Die Dunkelheit verschlingt die Gruppe.")
		return
	if darkness == MAX_DARKNESS - 1:
		c.add_log("[color=#ff8080]Fast völlig dunkel! Laternen entzünden oder mit Licht angreifen![/color]")

	var holder := _light_holder()
	if holder != null:
		holder.light_turns += 1
		var burn := 4 + 4 * holder.light_turns
		c.float_text(holder, "Splitterlicht brennt", Color("fff3b0"), 30)
		c.apply_damage(holder, burn, e)
		c.wait(0.3)

	var others := c.allies().filter(func(h: Fighter) -> bool: return not h.light)
	if others.is_empty():
		return
	var typed: Array[Fighter] = []
	typed.assign(others)
	if e.step % 2 == 0:
		await c.enemy_attack(e, typed, 11, "magic", "Schattenwelle")
	else:
		await c.enemy_attack(e, [c.pick(typed)], 20, "magic", "Leerengriff")


func _light_holder() -> Fighter:
	for h in c.alive(c.heroes):
		if h.light:
			return h
	return null


# --- Phasen, Wipes, Treffer ---------------------------------------------------

## Wird nach jeder Aktion geprüft: Phasenwechsel, Knotenpaare, Wipe durch Giftwolken.
func check_phase() -> void:
	if queen_mode == "bluete" and clouds >= MAX_CLOUDS and not c.alive(c.allies()).is_empty():
		var queen := _find("sporenkoenigin")
		if queen != null and queen.is_alive():
			clouds = 0
			c.wipe("Sporenblüte! Fünf Giftwolken erblühen gleichzeitig.")
			return

	var mother := _find("wurzelmutter")
	if mother != null and mother.is_alive() and not pair_broken:
		var front := _find("knoten_vorne")
		var back := _find("knoten_hinten")
		if not front.is_alive() and not back.is_alive():
			pair_broken = true
			pairs_since_warning += 1
			var dmg := roundi(mother.max_hp * PAIR_DAMAGE)
			c.add_log("[color=#8affc1][b]Zwillingsknoten zerstört![/b][/color] Die Wurzelmutter schreit auf.")
			c.burst(mother, Elements.color("Sternenkraft"), 200.0)
			var lost := c.apply_damage(mother, dmg)
			if c.current != null and c.current.is_ally():
				c.current.credit().stat_damage += lost
			_update_intents()

	if mother != null and not mother.is_alive() and not phase2:
		_start_phase2()

	var herald := _find("vorbote")
	if herald != null:
		if not herald.is_alive():
			c.set_darkness(0.0)
			c.set_order_visible(true)
			for h in c.heroes:
				h.light = false
		elif _light_holder() == null and not c.alive(c.heroes).is_empty():
			var next: Fighter = c.pick(c.alive(c.heroes))
			next.light = true
			next.light_turns = 0
			c.add_log("Das Splitterlicht springt zu %s." % next.display_name)


func _start_phase2() -> void:
	phase2 = true
	c.add_log("\n[color=#c8a0ff][b]Phase 2: Aus dem Splitter bricht etwas hervor … der Vorbote![/b][/color]")
	c.add_log("Ein Wesen der Leere. Es frisst das Licht: Das Feld wird dunkler, die Zugleiste verschwindet.")
	c.add_log("[color=#fff3b0]Das letzte Licht:[/color] Wer das Splitterlicht hält, ist vor dem Vorboten sicher, "
		+ "brennt aber immer stärker. Reicht es weiter! Laternen entzünden vertreibt die Dunkelheit.")
	c.screen_flash(Color("200030"))
	c.wait(0.8)
	c.banner("Der Vorbote")
	c.spawn_enemies(["vorbote"])
	darkness = 1
	c.set_darkness(darkness * DARKNESS_STEP)
	c.set_order_visible(false)
	var heroes := c.alive(c.heroes)
	if not heroes.is_empty():
		var holder: Fighter = c.pick(heroes)
		holder.light = true
		holder.light_turns = 0
		c.add_log("%s hält das Splitterlicht." % holder.display_name)
	_update_intents()
	c.refresh()
	c.wait(1.0)


## Schläge auf die Rinde der Wurzelmutter heilen sie (nur Angriffe der Helden).
func absorbs(target: Fighter, amount: int, source: Fighter) -> bool:
	if target.klass != "wurzelmutter" or source == null or not source.is_ally():
		return false
	var healed := target.heal(maxi(1, amount / 2))
	c.float_text(target, "Rinde heilt! +%d" % healed, Color("6dff8a"))
	return true


func on_hit(_attacker: Fighter, target: Fighter, element: String, _lost: int) -> void:
	if queen_mode == "bluete" and _find("sporenkoenigin") != null and _find("sporenkoenigin").is_alive():
		if element == "Feuer" and target.klass in ["sporenkoenigin", "sporenling"]:
			_add_cloud(target, "Feuer lässt Sporen aufsteigen: Giftwolke!")
		elif element == "Wind" and clouds > 0:
			clouds -= 1
			c.float_text(target, "Wind vertreibt eine Wolke", Elements.color("Wind"), 52)
			_update_intents()
	if target.klass == "vorbote" and element == "Licht" and darkness > 0:
		darkness -= 1
		c.set_darkness(darkness * DARKNESS_STEP)
		c.float_text(target, "Licht drängt die Dunkelheit zurück", Color("fff3b0"), 52)
		_update_intents()


# --- Aktionen für alle Klassen ------------------------------------------------

## Mechaniken setzen keine bestimmte Klasse voraus: Diese Aktionen hat jeder Held.
func extra_abilities(f: Fighter) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var queen := _find("sporenkoenigin")
	if queen_mode == "bluete" and queen != null and queen.is_alive() and clouds > 0:
		list.append({id = "clear_cloud", name = "Giftwolke vertreiben", info = "Eine Wolke weniger (kostet den Zug)", target = "none", dungeon = true})
	var herald := _find("vorbote")
	if herald != null and herald.is_alive():
		list.append({id = "lantern", name = "Laterne entzünden", info = "Dunkelheit −2 (kostet den Zug)", target = "none", dungeon = true})
		if f.light:
			list.append({id = "pass_light", name = "Licht weiterreichen", info = "Splitterlicht an Verbündeten", target = "ally_hero_other", dungeon = true})
	return list


func execute(f: Fighter, ab: Dictionary, target: Fighter) -> void:
	match ab.id:
		"clear_cloud":
			clouds = maxi(clouds - 1, 0)
			c.float_text(f, "Wolke vertrieben", Color("b0ff70"))
			c.add_log("%s vertreibt eine Giftwolke (%d übrig)." % [f.display_name, clouds])
		"lantern":
			darkness = maxi(darkness - 2, 0)
			c.set_darkness(darkness * DARKNESS_STEP)
			c.burst(f, Color("ffd36b"), 160.0)
			c.add_log("%s entzündet eine Laterne. Die Dunkelheit weicht." % f.display_name)
		"pass_light":
			f.light = false
			f.light_turns = 0
			target.light = true
			target.light_turns = 0
			c.burst(target, Color("fff3b0"), 120.0)
			c.add_log("%s reicht das Splitterlicht an %s weiter." % [f.display_name, target.display_name])
	_update_intents()
	c.wait(0.3)


# --- Entscheidung nach dem Dungeon --------------------------------------------

## Die Knöpfe verraten absichtlich nicht, was danach passiert (das zeigt sich erst nach der Wahl).
const FINAL_CHOICES: Array[Dictionary] = [
	{id = "faellen", name = "Baum fällen, großen Splitter mitnehmen", info = ""},
	{id = "retten", name = "Splitter herausschneiden, Baum retten", info = ""},
]


## Nach dem Sieg über den Vorboten: Was geschieht mit dem Urbaum? (design.md: „Entscheidung danach“)
func final_choice() -> void:
	var id := Sandbox.pilz_choice
	if id == "":
		# Erster Abschluss: Die Gruppe entscheidet. Bei jedem weiteren Lauf gilt diese Wahl automatisch.
		c.add_log("\n[b]Der Urbaum liegt still. In seinem Stamm pulsiert der große Splitter.[/b] Was tut ihr?")
		id = await c.ask_choice("Was geschieht mit dem Urbaum?", FINAL_CHOICES)
		Sandbox.pilz_choice = id
	else:
		c.add_log("\n[b]Wie beim ersten Mal …[/b]")
	if id == "faellen":
		c.add_log("[color=#c8a0ff]Ihr fällt den Urbaum und nehmt den großen Splitter mit.[/color] Er summt leise in eurem Gepäck. "
			+ "Über Grünwacht bleibt es grau.")
	else:
		c.add_log("[color=#8affc1]Vorsichtig schneidet ihr den Splitter heraus und nehmt ihn mit. Der Urbaum atmet auf.[/color] "
			+ "Grünwacht blüht auf, und die Zähmer werden davon hören (besserer Ruf).")
