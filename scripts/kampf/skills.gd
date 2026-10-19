class_name Skills
extends RefCounted
## Fähigkeiten, Passiven, Reaktionen und Ults der 11 Startklassen, ihrer Begleiter
## und der Duette (vereinfacht nach design.md, Abschnitt 4 und 5).
## Jede Fähigkeit ist ein Dictionary:
##   id, name, info, target (enemy, enemy_sealed, ally, ally_hero, ally_other, none, choice),
##   optional mana, cd (Abklingzeit), gold, blood, choices + then (zweiter Schritt), duet

const ARMORS := {
	"melee": {name = "Plattenrüstung", info = "gegen Nahkampf"},
	"magic": {name = "Runenrüstung", info = "gegen Magie"},
	"ranged": {name = "Schuppenpanzer", info = "gegen Fernkampf"},
}
## Passende Rüstung fängt so viel Schaden ab, jede Härte zusätzlich HARD_STEP.
const ARMOR_BLOCK := 0.4
const HARD_STEP := 0.06

const WARES := {
	"heiltrank": {name = "Heiltrank", info = "Heilt 35", value = 25, then = "ally"},
	"manatrank": {name = "Manatrank", info = "+30 Mana (Ritualist: +20 Blut)", value = 20, then = "ally"},
	"bombe": {name = "Bombe", info = "26 Feuer-Schaden", value = 30, then = "enemy"},
	"kraftkraut": {name = "Kraftkraut", info = "Angriff+ 2 Züge, +10 LP", value = 25, then = "ally"},
}
const START_WARES := {"heiltrank": 3, "manatrank": 2, "bombe": 2, "kraftkraut": 2}
const START_GOLD := 300
const CART_HP := 60
## Passive "Feilschen": Gold-Fähigkeiten kosten weniger.
const HAGGLE := 0.8

const SEALS := {
	"Feuer": "14 Feuer, brennt jeden Zug",
	"Blitz": "10 Blitz, Ziel wird gebremst",
	"Wind": "6 Wind, Gruppe wird schneller",
	"Erde": "Alle Verbündeten Schild 14",
	"Wasser": "Alle Verbündeten +12 LP",
}
const SEAL_ORDER: Array[String] = ["Feuer", "Wind", "Erde", "Wasser", "Blitz"]
const BURN := 5

## Zwielicht-Wandler: Überladung am Rand der Leiste
const OVERLOAD_MULT := 1.6
const OVERLOAD_RECOIL := 0.08

var c: BattleState


func _init(p_combat: BattleState) -> void:
	c = p_combat


## Richtet klassentypische Werte und Begleiter eines Helden ein.
func setup_hero(h: Fighter) -> void:
	match h.klass:
		"mechanic":
			var data := Sandbox.ROBOT
			var robot := Fighter.new(data.name, "robot", "Roboter", false, data.hp, data.tempo, Color("aebfd4"))
			robot.owner = h
			h.robot = robot
		"tamer":
			for id: String in Sandbox.MONSTER_ORDER:
				var data: Dictionary = Sandbox.MONSTERS[id]
				var m := Fighter.new(data.name, id, data.role, false, data.hp, data.tempo, Elements.color(data.element))
				m.element = data.element
				m.owner = h
				m.on_bench = true
				h.monsters.append(m)
				if id == Sandbox.starter:
					h.active_monster = m
			if h.active_monster == null:
				h.active_monster = h.monsters[0]
		"quartermaster":
			h.gold = START_GOLD
			h.cart_hp = CART_HP
			h.cart_max = CART_HP
			h.wares = START_WARES.duplicate()


static func gold_cost(base: int) -> int:
	return roundi(base * HAGGLE)


# --- Fähigkeiten-Listen -------------------------------------------------------

func abilities(f: Fighter) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	match f.klass:
		"tank":
			list = [
				{id = "arcane_strike", name = "Arkaner Stoß", info = "16 Magie", target = "enemy"},
				{id = "ban", name = "Bann-Zeichen", info = "Nächste 3 Angriffe auf dich · 10 Mana", target = "none", mana = 10, cd = 3},
				{id = "barrier", name = "Barriere", info = "Schild 25 für Verbündeten · 15 Mana", target = "ally", mana = 15, cd = 2},
				{id = "condense", name = "Rüstung verdichten", info = "+25 Mana, Abwehr+ 2 Züge", target = "none", cd = 3},
				{id = "ult", name = "Arkane Festung", info = "Fängt Schaden der Gruppe ab, explodiert danach", target = "none"},
			]
		"mechanic":
			list = [
				{id = "wrench", name = "Schraubenschlüssel", info = "13 Nahkampf", target = "enemy"},
				{id = "hook", name = "Magnet-Haken", info = "6 Schaden, 2 Angriffe gehen auf den Roboter · 10 Mana", target = "enemy", mana = 10, cd = 3},
				{id = "guard", name = "Roboter als Schild", info = "Roboter fängt Angriffe auf ihn ab · 6 Mana", target = "ally_hero", mana = 6, cd = 1},
				{id = "repair", name = "Notreparatur", info = "Roboter +45 LP · 12 Mana", target = "none", mana = 12, cd = 3},
				{id = "ult", name = "Neuer Roboter", info = "Kaputt: neu bauen. Sonst: stärker, voll repariert", target = "none"},
			]
		"robot":
			list = [
				{id = "drill", name = "Bohrer", info = "10 Nahkampf, Ziel verwundbar", target = "enemy"},
				{id = "guardmode", name = "Schutzmodus", info = "Zieht 2 Angriffe auf sich, Abwehr+", target = "none", cd = 2},
			]
		"smith":
			var choices: Array[Dictionary] = []
			for id: String in ARMORS:
				choices.append({id = id, name = ARMORS[id].name, info = ARMORS[id].info})
			list = [
				{id = "hammer", name = "Hammerschlag", info = "15 Nahkampf", target = "enemy"},
				{id = "armor", name = "Rüstung wechseln", info = "Jetzt: %s" % ARMORS[f.armor].name, target = "choice", cd = 2, choices = choices},
				{id = "anvil", name = "Amboss aufstellen", info = "Zieht 3 Angriffe auf sich, +1 Härte · 10 Mana", target = "none", mana = 10, cd = 3},
				{id = "reinforce", name = "Rüstung verstärken", info = "Schild 28 für Verbündeten · 12 Mana", target = "ally", mana = 12, cd = 2},
				{id = "ult", name = "Meisterstück", info = "Alle Schild 30 und Abwehr+, Härte 5", target = "none"},
			]
		"archer":
			var shot_name := "Aufgeladener Schuss" if f.charged else "Schneller Schuss"
			var shot_info := "30 Fernkampf" if f.charged else "12 Fernkampf"
			list = [
				{id = "shot", name = shot_name, info = shot_info, target = "enemy"},
				{id = "charge", name = "Bogen spannen", info = "Nächster Schuss ×2,5 (Treffer unterbricht)", target = "none"},
				{id = "volley", name = "Pfeilhagel", info = "9 an alle Gegner · 15 Mana", target = "none", mana = 15, cd = 2},
				{id = "net", name = "Netzpfeil", info = "6 Schaden, Ziel rutscht auf der Leiste zurück · 10 Mana", target = "enemy", mana = 10, cd = 3},
				{id = "rapid", name = "Schnellfeuer", info = "3 schnelle Pfeile à 7 auf zufällige Gegner · 12 Mana", target = "none", mana = 12, cd = 2},
				{id = "ult", name = "Jägerpfeil", info = "70 Fernkampf", target = "enemy"},
			]
		"blade":
			var step := " (Tanzschritt %d/3)" % (f.dance.size() + 1)
			list = [
				{id = "step", name = "Klingenschritt", info = "12 Nahkampf, +1 Klinge" + step, target = "enemy"},
				{id = "whirl", name = "Wirbel", info = "7 an alle, +1 Klinge · 8 Mana" + step, target = "none", mana = 8, cd = 1},
				{id = "lunge", name = "Ausfallschritt", info = "17 Nahkampf · 6 Mana" + step, target = "enemy", mana = 6},
				{id = "storm", name = "Klingensturm", info = "Verbraucht alle Klingen: %d Schaden" % (9 * f.blades), target = "enemy"},
				{id = "ult", name = "Tanz der 1000 Klingen", info = "3× 10 an alle Gegner, 5 Klingen", target = "none"},
			]
		"twilight":
			list = [
				{id = "light", name = "Lichtstrahl", info = "14 Licht, Leiste +2", target = "enemy"},
				{id = "shadow", name = "Schattenbiss", info = "13 Schatten, heilt dich, Leiste −2", target = "enemy"},
				{id = "blind", name = "Blendendes Licht", info = "6 Licht an alle, bremst, +1 · 12 Mana", target = "none", mana = 12, cd = 3},
				{id = "veil", name = "Schattenschleier", info = "Nächster Angriff verfehlt, −1 · 10 Mana", target = "ally", mana = 10, cd = 2},
				{id = "turn", name = "Wendepunkt", info = "Licht ↔ Schatten tauschen · 8 Mana", target = "none", mana = 8, cd = 3},
				{id = "ult", name = "Sonnenfinsternis", info = "%d an alle (Licht oder Schatten)" % (26 + 5 * absi(f.balance)), target = "none"},
			]
		"tamer":
			var choices: Array[Dictionary] = []
			for m in f.monsters:
				choices.append({id = m.klass, name = m.display_name, info = "%s · %d/%d LP" % [m.element, m.hp, m.max_hp]})
			list = [
				{id = "sling", name = "Schleuder", info = "8 Fernkampf", target = "enemy"},
				{id = "command", name = "Befehl", info = "Monster ist sofort dran · 8 Mana", target = "none", mana = 8, cd = 2},
				{id = "switch", name = "Wechsel", info = "Anderes Monster schicken", target = "choice", cd = 1, choices = choices},
				{id = "cheer", name = "Anfeuern", info = "Monster Angriff+, +10 LP · 8 Mana", target = "none", mana = 8, cd = 2},
				{id = "care", name = "Pflege", info = "Monster +30 LP · 10 Mana", target = "none", mana = 10, cd = 1},
				{id = "tame", name = "Zähmen", info = "Geschwächtes Monster (unter 50 % LP) fangen · 10 Mana", target = "enemy_tamable", mana = 10, cd = 2},
				{id = "ult", name = "Rudelruf", info = "Alle Monster greifen an (je 16, eigenes Element)", target = "enemy"},
			]
		"moosling":
			list = [
				{id = "vine", name = "Rankenhieb", info = "12 Pflanze (Nahkampf)", target = "enemy"},
				{id = "moss", name = "Moosschild", info = "Zieht 2 Angriffe auf sich, Abwehr+", target = "none", cd = 2},
			]
		"glutwelpe":
			list = [
				{id = "ember", name = "Glutbiss", info = "15 Feuer (Nahkampf)", target = "enemy"},
				{id = "breath", name = "Flammenatem", info = "8 Feuer an alle Gegner", target = "none", cd = 2},
			]
		"bachotter":
			list = [
				{id = "jet", name = "Wasserstrahl", info = "11 Wasser (Magie)", target = "enemy"},
				{id = "spring", name = "Quellwasser", info = "Heilt Verbündeten 22", target = "ally", cd = 1},
			]
		"ritualist":
			list = [
				{id = "bite", name = "Biss", info = "14 Nahkampf, heilt dich, füllt Blutvorrat", target = "enemy"},
				{id = "gift", name = "Blutgabe", info = "Heilt 32 · kostet 14 Blut/Leben", target = "ally_other", blood = 14},
				{id = "circle", name = "Blutkreis", info = "Heilt alle 16 · kostet 22 Blut/Leben", target = "none", blood = 22, cd = 2},
				{id = "pact", name = "Blutpakt", info = "Angriff+ für Verbündeten · kostet 10", target = "ally_other", blood = 10, cd = 2},
				{id = "ult", name = "Großes Opfer", info = "Kostet halbe LP: heilt alle 60, belebt Gefallene", target = "none"},
			]
		"quartermaster":
			var choices: Array[Dictionary] = []
			for id: String in WARES:
				choices.append({id = id, name = "%s (%d×)" % [WARES[id].name, f.wares.get(id, 0)], info = WARES[id].info, then = WARES[id].then})
			var count := 0
			for n: int in f.wares.values():
				count += n
			list = [
				{id = "ware", name = "Ware reichen", info = "Aus dem Karren (%d Waren)" % count, target = "choice", choices = choices},
				{id = "delivery", name = "Großlieferung", info = "Alle +14 LP, +12 Mana · %d Gold" % gold_cost(60), target = "none", gold = gold_cost(60), cd = 2},
				{id = "appraise", name = "Wertgutachten", info = "Ziel verwundbar, zeigt Schwächen · %d Gold" % gold_cost(20), target = "enemy", gold = gold_cost(20), cd = 1},
				{id = "coins", name = "Münzhagel", info = "24 Fernkampf · %d Gold" % gold_cost(40), target = "enemy", gold = gold_cost(40)},
				{id = "ult", name = "Goldrausch", info = "Alle Angriff+ und schneller, Schaden je nach Gold", target = "none"},
			]
		"kunoichi":
			var choices: Array[Dictionary] = []
			for el: String in SEAL_ORDER:
				choices.append({id = el, name = "%s-Siegel" % el, info = SEALS[el]})
			list = [
				{id = "kunai", name = "Kunai-Wurf", info = "11 Fernkampf", target = "enemy"},
				{id = "talisman", name = "Talisman kleben", info = "Element-Siegel auf Gegner · 5 Mana", target = "choice", mana = 5, then = "enemy", choices = choices},
				{id = "release", name = "Siegel lösen", info = "Siegel wirken, zwei = Kombination · 8 Mana", target = "enemy_sealed", mana = 8},
				{id = "smoke", name = "Rauchbombe", info = "Nächster Angriff auf jeden verfehlt · 12 Mana", target = "none", mana = 12, cd = 3},
				{id = "ult", name = "Tausend Siegel", info = "Jeder Gegner 22 mit seiner Schwäche, alle +18 LP", target = "none"},
			]
		"novize":
			list = [
				{id = "schlag", name = "Schlag", info = "12 Nahkampf", target = "enemy"},
				{id = "kraftschlag", name = "Kraftschlag", info = "20 Nahkampf · 10 Mana", target = "enemy", mana = 10, cd = 2},
				{id = "erste_hilfe", name = "Erste Hilfe", info = "Heilt 22 · 12 Mana", target = "ally", mana = 12, cd = 2},
			]
			if f.wares.has("heiltrank"):
				list.append({id = "trank", name = "Heiltrank (%d)" % f.wares.heiltrank, info = "Heilt 35 · aus deiner Tasche", target = "ally"})
		"singer":
			var lullaby_info := "Heilt 24, +1 Schutz-Sternbild · 8 Mana"
			if f.res_def >= Fighter.MAX_RES:
				lullaby_info = "Sternenglanz: heilt die GANZE Gruppe 24 · 8 Mana"
			var polar_info := "Abwehr+ und früher dran, +1 Schutz-Sternbild · 10 Mana"
			if f.res_def >= Fighter.MAX_RES:
				polar_info = "Sternenglanz: Abwehr+ und früher dran für die GANZE Gruppe · 10 Mana"
			var comet_info := "Verbraucht Angriffs-Resonanz: 8 + 8 je Punkt · 10 Mana"
			if f.res_off >= Fighter.MAX_RES:
				comet_info = "Sternenglanz: trifft ALLE Gegner mit 48 · 10 Mana"
			list = [
				{id = "spark", name = "Sternenfunke", info = "11 Magie, +1 Angriffs-Sternbild", target = "enemy"},
				{id = "lullaby", name = "Mondwiegenlied", info = lullaby_info, target = "ally", mana = 8},
				{id = "polar", name = "Polarstern", info = polar_info, target = "ally", mana = 10, cd = 3},
				{id = "comet", name = "Kometenlied", info = comet_info, target = "enemy", mana = 10},
				{id = "meteor", name = "Sternschnuppenregen", info = "Verbraucht Schutz-Resonanz: alle 7 je Punkt · 10 Mana", target = "none", mana = 10},
				{id = "ult", name = "Himmelszelt", info = "Alle +35 LP, Angriff+/Abwehr+, 22 Sternenkraft", target = "none"},
			]
		_:
			# Gezähmtes Monster: kämpft mit seinem eigenen Angriff für den Zähmer
			if is_pet(f) and Sandbox.ENEMIES.has(f.klass):
				var tame: Dictionary = Sandbox.ENEMIES[f.klass].tame
				list = [
					{id = "pet_attack", name = tame.name, info = "%d %s" % [tame.base, f.element], target = "enemy"},
					{id = "pet_guard", name = "Beschützen", info = "Zieht 2 Angriffe auf sich, Abwehr+", target = "none", cd = 2},
				]
	if f.is_hero:
		for duet in Sandbox.active_duets(c.team):
			if f.klass == duet.a or f.klass == duet.b:
				var partner: String = duet.b if f.klass == duet.a else duet.a
				list.append({id = duet.id, name = duet.name, info = duet.info, target = duet.target, duet = true, partner = partner})
		if c.dungeon != null:
			list.append_array(c.dungeon.extra_abilities(f))
		var row_name := "Nach vorne" if f.back_row else "Nach hinten"
		list.append({id = "row", name = row_name, info = "Reihe wechseln (kostet den Zug)", target = "none"})
	# Grundausbildung: nur die Fähigkeiten, die die Lektion schon erlaubt
	var allowed: Array = c.setup.get("erlaubt", [])
	if not allowed.is_empty() and f.is_hero:
		list = list.filter(func(ab: Dictionary) -> bool: return ab.id in allowed)
	return list


## Kann die Fähigkeit gerade benutzt werden? Gibt "" zurück oder den Grund, warum nicht.
func blocked_reason(f: Fighter, ab: Dictionary) -> String:
	var id: String = ab.id
	# Lektion: Die erste Aktion des Spielers ist vorgegeben (z. B. „Nach hinten“), alles andere ist bis dahin gesperrt
	var first: String = c.setup.get("zuerst", "")
	if first != "" and not c.first_done and f.is_hero and not c.computer.has(f) and id != first:
		return "Erst „Nach hinten“" if first == "row" else "Noch gesperrt"
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
	if ab.get("gold", 0) > f.gold:
		return "Zu wenig Gold"
	if ab.has("duet"):
		var partner := c.hero(ab.partner)
		if partner == null or not partner.is_alive():
			return "Partner besiegt"
		match id:
			"blutsiegel":
				if partner.klass == "ritualist" and partner.hp + partner.blood - 12 < 1 \
						or f.klass == "ritualist" and f.hp + f.blood - 12 < 1:
					return "Zu wenig Leben"
			"nachschub":
				if c.hero("quartermaster").gold < 20:
					return "Zu wenig Gold"
	match id:
		"charge":
			if f.charged:
				return "Schon gespannt"
		"hook", "guard", "repair":
			if not f.robot.is_alive():
				return "Roboter kaputt"
		"storm":
			if f.blades == 0:
				return "Keine Klingen"
		"turn":
			if f.balance == 0:
				return "Leiste in der Mitte"
		"command", "cheer", "care":
			if not f.active_monster.is_alive():
				return "Kein Monster im Kampf"
		"ware":
			if f.cart_hp <= 0:
				return "Karren kaputt"
			var count := 0
			for n: int in f.wares.values():
				count += n
			if count == 0:
				return "Karren leer"
		"release":
			if valid_targets(f, ab).is_empty():
				return "Keine Siegel"
		"trank":
			if f.wares.get("heiltrank", 0) <= 0:
				return "Keine Tränke mehr"
		"tame":
			if f.monsters.size() >= Sandbox.MAX_MONSTERS:
				return "Kein Platz (%d Monster)" % Sandbox.MAX_MONSTERS
			if valid_targets(f, ab).is_empty():
				return "Kein Monster geschwächt"
		"comet":
			if f.res_off == 0:
				return "Keine Resonanz"
		"meteor":
			if f.res_def == 0:
				return "Keine Resonanz"
	return ""


## Ob eine Auswahl im zweiten Schritt möglich ist.
func choice_blocked(f: Fighter, ab: Dictionary, choice: Dictionary) -> String:
	match ab.id:
		"armor":
			if choice.id == f.armor:
				return "Trägst du schon"
		"switch":
			var m := _monster(f, choice.id)
			if not m.is_alive():
				return "Kampfunfähig"
			if m == f.active_monster:
				return "Kämpft schon"
		"ware":
			if f.wares.get(choice.id, 0) <= 0:
				return "Ausverkauft"
	return ""


func valid_targets(f: Fighter, ab: Dictionary) -> Array[Fighter]:
	match ab.target:
		"enemy":
			return c.alive(c.enemies)
		"enemy_sealed":
			return c.alive(c.enemies).filter(func(e: Fighter) -> bool: return not e.seals.is_empty())
		"enemy_tamable":
			return c.alive(c.enemies).filter(func(e: Fighter) -> bool:
				return Sandbox.ENEMIES[e.klass].has("tame") and e.hp * 2 <= e.max_hp)
		"ally":
			return c.allies()
		"ally_hero":
			return c.alive(c.heroes)
		"ally_other":
			var others := c.allies()
			others.erase(f)
			return others
		"ally_hero_other":
			var others := c.alive(c.heroes)
			others.erase(f)
			return others
	return []


func _monster(tamer: Fighter, id: String) -> Fighter:
	for m in tamer.monsters:
		if m.klass == id:
			return m
	return null


# --- Ausführen ----------------------------------------------------------------

func execute(f: Fighter, ab: Dictionary, target: Fighter) -> void:
	var id: String = ab.id
	if ab.has("dungeon"):
		c.dungeon.execute(f, ab, target)
		return
	if ab.has("gold"):
		_spend_gold(f, ab.gold)
	if ab.has("duet"):
		_execute_duet(f, ab, target)
		var partner := c.hero(ab.partner)
		f.cooldowns[id] = Sandbox.DUET_CD + 1
		partner.cooldowns[id] = Sandbox.DUET_CD + 1
		c.delay(partner, 0.3)
		return
	match f.klass:
		"tank":
			_tank(f, id, target)
		"mechanic":
			_mechanic(f, id, target)
		"robot":
			_robot(f, id, target)
		"smith":
			_smith(f, id, target, ab)
		"archer":
			_archer(f, id, target)
		"blade":
			_blade(f, id, target)
		"twilight":
			_twilight(f, id, target)
		"tamer":
			_tamer(f, id, target, ab)
		"ritualist":
			_ritualist(f, id, target, int(ab.get("blood", 0)))
		"quartermaster":
			_quartermaster(f, id, target, ab)
		"kunoichi":
			_kunoichi(f, id, target, ab)
		"novize":
			_novize(f, id, target)
		"singer":
			_singer(f, id, target)
		_:
			if is_pet(f):
				_monster_action(f, id, target)


## Monster des Zähmers (Start-Monster und gezähmte).
static func is_pet(f: Fighter) -> bool:
	return f.owner != null and f.klass != "robot"


func _tank(f: Fighter, id: String, target: Fighter) -> void:
	match id:
		"arcane_strike":
			c.projectile(f, target, Color("4a8cf0"))
			c.hit(f, target, 16, "magic")
		"ban":
			f.taunt = 3
			c.add_log("%s zeichnet ein Bann-Zeichen: Gegner müssen ihn angreifen." % f.display_name)
			c.float_text(f, "Bann!", Color("6fa8ff"))
		"barrier":
			c.give_shield(f, target, 25)
			c.add_log("%s schützt %s mit einer Barriere." % [f.display_name, target.display_name])
		"condense":
			f.mana = mini(f.mana + 25, f.max_mana)
			f.def_buff_turns = BattleState.BUFF_TURNS + 1
			c.float_text(f, "+25 Mana", Color("6fa8ff"))
			c.add_log("%s verdichtet seine Rüstung." % f.display_name)
		"ult":
			f.fortress = true
			f.fortress_absorbed = 0
			c.add_log("Bis zu seinem nächsten Zug fängt %s den Schaden der Gruppe zur Hälfte ab." % f.display_name)


func _mechanic(f: Fighter, id: String, target: Fighter) -> void:
	var robot := f.robot
	match id:
		"wrench":
			c.lunge(f, target, 0.25)
			c.hit(f, target, 13, "melee")
		"hook":
			c.projectile(f, target, Color("d9a441"))
			c.hit(f, target, 6, "ranged")
			robot.taunt = 2
			c.float_text(robot, "Komm her!", Color("d9a441"))
			c.add_log("Magnet-Haken! Die nächsten 2 Angriffe gehen auf %s." % robot.display_name)
		"guard":
			robot.protecting = target
			c.float_text(target, "Beschützt", Color("d9a441"))
			c.add_log("%s beschützt jetzt %s." % [robot.display_name, target.display_name])
		"repair":
			c.heal(f, robot, 45)
			c.add_log("%s repariert %s." % [f.display_name, robot.display_name])
		"ult":
			if not robot.is_alive():
				robot.hp = robot.max_hp
				robot.next_time = c.now + robot.turn_delay() * 0.5
				c.burst(robot, Color("d9a441"))
				c.add_log("%s baut einen neuen Roboter!" % f.display_name)
			else:
				robot.max_hp += 30
				c.heal(f, robot, robot.max_hp)
				robot.atk_buff_turns = 3
				c.burst(robot, Color("d9a441"))
				c.add_log("%s baut %s aus: mehr Leben, mehr Kraft." % [f.display_name, robot.display_name])


func _robot(f: Fighter, id: String, target: Fighter) -> void:
	match id:
		"drill":
			c.lunge(f, target, 0.3)
			c.hit(f, target, 10, "melee")
			if target.is_alive():
				target.vuln_turns = 3
				c.float_text(target, "Panzer durchbohrt", Color("d9a441"), 30)
		"guardmode":
			f.taunt = 2
			f.def_buff_turns = BattleState.BUFF_TURNS + 1
			c.float_text(f, "Schutzmodus", Color("aebfd4"))


func _smith(f: Fighter, id: String, target: Fighter, ab: Dictionary) -> void:
	match id:
		"hammer":
			c.lunge(f, target, 0.3)
			c.hit(f, target, 15, "melee")
		"armor":
			f.armor = ab.choice
			c.float_text(f, ARMORS[f.armor].name, Color("ffb070"))
			c.add_log("%s legt die %s an (%s)." % [f.display_name, ARMORS[f.armor].name, ARMORS[f.armor].info])
		"anvil":
			f.taunt = 3
			_add_hard(f, 1)
			c.add_log("%s stellt den Amboss auf: Gegner müssen sie angreifen." % f.display_name)
		"reinforce":
			c.give_shield(f, target, 28)
		"ult":
			for a in c.allies():
				c.give_shield(f, a, 30)
				a.def_buff_turns = BattleState.BUFF_TURNS + 1
			f.hard = Fighter.MAX_HARD
			c.add_log("Meisterstück! %s schmiedet für alle eine Rüstung." % f.display_name)


func _add_hard(f: Fighter, amount: int) -> void:
	var before := f.hard
	f.hard = mini(f.hard + amount, Fighter.MAX_HARD)
	if f.hard > before:
		c.float_text(f, "Gehärtet %d" % f.hard, Color("ffb070"), 30)


func _archer(f: Fighter, id: String, target: Fighter) -> void:
	match id:
		"shot":
			var base := 12.0
			if f.charged:
				base = 30.0
				f.charged = false
				f.add_ult(30)
			c.projectile(f, target, Color("b8ff8a"))
			c.hit(f, target, base, "ranged")
		"charge":
			f.charged = true
			c.float_text(f, "Gespannt", Color("b8ff8a"))
			c.add_log("%s spannt den Bogen." % f.display_name)
		"volley":
			for enemy in c.alive(c.enemies):
				c.projectile_bg(f, enemy, Color("b8ff8a"))
			c.wait(0.3)
			for enemy in c.alive(c.enemies):
				c.hit(f, enemy, 9, "ranged")
		"net":
			c.projectile(f, target, Color.WHITE)
			c.hit(f, target, 6, "ranged")
			c.delay(target, 0.7)
			c.float_text(target, "Gefesselt", Color.WHITE, 30)
			c.add_log("%s rutscht auf der Zugleiste nach hinten." % target.display_name)
		"rapid":
			for i in 3:
				var targets := c.alive(c.enemies)
				if targets.is_empty():
					break
				var t: Fighter = c.pick(targets)
				c.projectile(f, t, Color("b8ff8a"), 0.15)
				c.hit(f, t, 7, "ranged")
		"ult":
			c.projectile(f, target, Color("f2c14e"))
			c.hit(f, target, 70, "ranged")
	f.add_ult(20 * c.crits)


func _blade(f: Fighter, id: String, target: Fighter) -> void:
	var element := "Feuer" if f.fire_turns > 0 else ""
	if f.star_turns > 0:
		element = "Sternenkraft"
	match id:
		"step":
			var mult := _dance_step(f, id)
			c.lunge(f, target, 0.25)
			c.hit(f, target, 12 * mult, "melee", element)
			_add_blades(f, 1)
		"whirl":
			var mult := _dance_step(f, id)
			c.burst(f, Color("ffb07a"), 120.0)
			c.wait(0.25)
			for enemy in c.alive(c.enemies):
				c.hit(f, enemy, 7 * mult, "melee", element)
			_add_blades(f, 1)
		"lunge":
			var mult := _dance_step(f, id)
			c.lunge(f, target, 0.2)
			c.hit(f, target, 17 * mult, "melee", element)
		"storm":
			var count := f.blades
			f.blades = 0
			f.add_ult(8 * count)
			c.projectile(f, target, Color("ffd0a0"))
			c.hit(f, target, 9 * count, "ranged", element)
			c.add_log("Klingensturm mit %d Klingen!" % count)
		"ult":
			for i in 3:
				for enemy in c.alive(c.enemies):
					c.projectile_bg(f, enemy, Color("ffd0a0"), 0.2)
				c.wait(0.25)
				for enemy in c.alive(c.enemies):
					c.hit(f, enemy, 10, "melee", element)
				c.wait(0.15)
			f.blades = Fighter.MAX_BLADES


## Tanzfolge: Klingenschritt, Wirbel und Ausfallschritt in beliebiger Reihenfolge hintereinander.
## Der dritte Schritt macht 1,5-fachen Schaden und lädt die Ult.
func _dance_step(f: Fighter, move: String) -> float:
	if move in f.dance:
		f.dance.clear()
	f.dance.append(move)
	if f.dance.size() < 3:
		return 1.0
	f.dance.clear()
	f.add_ult(30)
	c.float_text(f, "TANZFOLGE!", Color("ffd0a0"), -20)
	c.add_log("[color=#ffb07a]Tanzfolge abgeschlossen![/color] Der letzte Schritt trifft härter.")
	return 1.5


func _add_blades(f: Fighter, amount: int) -> void:
	f.blades = mini(f.blades + amount, Fighter.MAX_BLADES)


func _twilight(f: Fighter, id: String, target: Fighter) -> void:
	var mult := OVERLOAD_MULT if absi(f.balance) >= Fighter.MAX_BALANCE else 1.0
	if mult > 1.0 and id != "turn" and id != "veil":
		c.float_text(f, "Überladung!", Color("e0c8ff"), -20)
	match id:
		"light":
			c.projectile(f, target, Elements.color("Licht"))
			c.hit(f, target, 14 * mult, "magic", "Licht")
			_shift_balance(f, 2)
		"shadow":
			c.projectile(f, target, Elements.color("Schatten"))
			var dealt := c.hit(f, target, 13 * mult, "magic", "Schatten")
			c.heal(f, f, ceili(dealt * 0.4))
			_shift_balance(f, -2)
		"blind":
			c.screen_flash(Elements.color("Licht"))
			for enemy in c.alive(c.enemies):
				c.hit(f, enemy, 6 * mult, "magic", "Licht")
				c.delay(enemy, 0.3)
			c.add_log("Geblendet! Alle Gegner rutschen auf der Zugleiste zurück.")
			_shift_balance(f, 1)
		"veil":
			target.smoke = 1
			target.smoke_source = f
			c.float_text(target, "Schleier", Elements.color("Schatten"))
			_shift_balance(f, -1)
		"turn":
			f.balance = -f.balance
			c.float_text(f, "Wendepunkt", Color("e0c8ff"))
			_check_crossing(f)
		"ult":
			c.screen_flash(Color("2a1040"))
			c.wait(0.3)
			var power := 26 + 5 * absi(f.balance)
			for enemy in c.alive(c.enemies):
				var el := Elements.best_against(enemy.element, ["Licht", "Schatten"])
				c.burst(enemy, Elements.color(el), 110.0)
				c.hit(f, enemy, power, "magic", el)
			f.balance = 0


func _shift_balance(f: Fighter, amount: int) -> void:
	f.balance = clampi(f.balance + amount, -Fighter.MAX_BALANCE, Fighter.MAX_BALANCE)
	_check_crossing(f)
	if absi(f.balance) == Fighter.MAX_BALANCE:
		c.float_text(f, "ÜBERLADEN", Color("e0c8ff"), 30)


## Jedes Überqueren der Mitte der Leiste lädt die Ult.
func _check_crossing(f: Fighter) -> void:
	var side := signi(f.balance)
	if side == 0:
		return
	if f.last_side != 0 and side != f.last_side:
		f.add_ult(25)
		c.float_text(f, "Mitte überquert! Ult +25", Color("e0c8ff"), 54)
	f.last_side = side


func _tamer(f: Fighter, id: String, target: Fighter, ab: Dictionary) -> void:
	var m := f.active_monster
	match id:
		"sling":
			c.projectile(f, target, Color("c9b28a"))
			c.hit(f, target, 8, "ranged")
		"command":
			m.next_time = c.now + 0.001
			c.float_text(m, "Los!", Color("8fd36b"))
			c.add_log("%s gibt %s einen Befehl: Es ist sofort dran." % [f.display_name, m.display_name])
		"switch":
			var next := _monster(f, ab.choice)
			c.remove_companion(m)
			f.active_monster = next
			c.add_companion(next)
			next.next_time = c.now + next.turn_delay() * 0.5
			c.burst(next, Elements.color(next.element), 100.0)
			c.add_log("%s: „%s, zurück! %s, du bist dran!“" % [f.display_name, m.display_name, next.display_name])
			var enemy := c.next_enemy()
			if enemy != null and Elements.multiplier(enemy.element, next.element) < 1.0:
				f.add_ult(25)
				c.float_text(next, "Gut getimt! Ult +25", Color("8fd36b"), 30)
				c.add_log("Gut getimter Wechsel: %s (%s) hält %s (%s) gut aus." % [next.display_name, next.element, enemy.display_name, enemy.element])
		"cheer":
			m.atk_buff_turns = BattleState.BUFF_TURNS + 1
			c.heal(f, m, 10)
			c.float_text(m, "Angriff+", Color("ff8080"), 30)
		"care":
			c.heal(f, m, 30)
		"tame":
			c.projectile(f, target, Color("8fd36b"), 0.3)
			# Je schwächer das Monster, desto sicherer klappt es (50 % LP = halbe Chance)
			var chance := 1.0 - float(target.hp) / target.max_hp
			if c.zufall() < chance:
				c.tame(f, target)
				f.add_ult(25)
			else:
				c.float_text(target, "Reißt sich los!", Color("8fd36b"), 30)
				c.add_log("%s reißt sich los. Weiter schwächen und nochmal versuchen!" % target.display_name)
		"ult":
			c.add_log("Rudelruf! Alle Monster von %s greifen an." % f.display_name)
			for monster in f.monsters:
				if not monster.is_alive() or not target.is_alive():
					continue
				var from := monster if c.on_field(monster) else f
				c.projectile(from, target, Elements.color(monster.element), 0.25)
				c.hit(monster, target, 16, "magic", monster.element)
			for monster in f.monsters:
				if monster.is_alive():
					c.heal(f, monster, 15)


func _monster_action(f: Fighter, id: String, target: Fighter) -> void:
	match id:
		"vine":
			c.lunge(f, target, 0.3)
			c.hit(f, target, 12, "melee", "Pflanze")
		"moss":
			f.taunt = 2
			f.def_buff_turns = BattleState.BUFF_TURNS + 1
			c.float_text(f, "Moosschild", Elements.color("Pflanze"))
		"ember":
			c.lunge(f, target, 0.25)
			c.hit(f, target, 15, "melee", "Feuer")
		"breath":
			for enemy in c.alive(c.enemies):
				c.projectile_bg(f, enemy, Elements.color("Feuer"))
			c.wait(0.3)
			for enemy in c.alive(c.enemies):
				c.hit(f, enemy, 8, "magic", "Feuer")
		"jet":
			c.projectile(f, target, Elements.color("Wasser"))
			c.hit(f, target, 11, "magic", "Wasser")
		"spring":
			c.heal(f, target, 22)
		"pet_attack":
			var tame: Dictionary = Sandbox.ENEMIES[f.klass].tame
			if tame.kind == "melee":
				c.lunge(f, target, 0.3)
			else:
				c.projectile(f, target, Elements.color(f.element))
			c.hit(f, target, tame.base, tame.kind, f.element)
		"pet_guard":
			f.taunt = 2
			f.def_buff_turns = BattleState.BUFF_TURNS + 1
			c.float_text(f, "Beschützt", Elements.color(f.element))
	f.owner.add_ult(12)


func _ritualist(f: Fighter, id: String, target: Fighter, cost: int) -> void:
	match id:
		"bite":
			c.lunge(f, target, 0.25)
			var dealt := c.hit(f, target, 14, "melee")
			var healed := f.heal(ceili(dealt * 0.5))
			f.stat_heal += healed
			f.blood = mini(f.blood + ceili(dealt * 0.5), Fighter.MAX_BLOOD)
			if healed > 0:
				c.float_text(f, "+%d" % healed, Color("6dff8a"))
		"gift":
			pay_blood(f, cost)
			c.heal(f, target, 32)
		"circle":
			pay_blood(f, cost)
			for a in c.allies():
				c.heal(f, a, 16)
		"pact":
			pay_blood(f, cost)
			target.atk_buff_turns = BattleState.BUFF_TURNS + 1
			c.float_text(target, "Angriff+", Color("ff8080"))
			c.add_log("%s schließt einen Blutpakt mit %s." % [f.display_name, target.display_name])
		"ult":
			var price := f.max_hp / 2
			var from_blood := mini(f.blood, price)
			f.blood -= from_blood
			f.hp -= price - from_blood
			c.float_text(f, "-%d" % (price - from_blood), Color("ff6060"))
			for h in c.heroes:
				if h == f:
					continue
				if not h.is_alive():
					h.hp = 1
					h.next_time = c.now + h.turn_delay()
					c.add_log("%s wird wiederbelebt!" % h.display_name)
				c.heal(f, h, 60)
			for comp in c.alive(c.companions):
				c.heal(f, comp, 60)
	c.wait(0.1)


## Ritualist bezahlt mit Blutvorrat, der Rest kommt aus dem eigenen Leben.
## Für andere geopfertes Leben lädt die Ult.
func pay_blood(f: Fighter, cost: int) -> void:
	var from_blood := mini(f.blood, cost)
	f.blood -= from_blood
	var from_hp := cost - from_blood
	f.hp = maxi(f.hp - from_hp, 1)
	if from_hp > 0:
		c.float_text(f, "-%d" % from_hp, Color("ff6060"))
	f.add_ult(cost * 1.2)


## Quartiermeister: Ausgegebenes Gold lädt die Ult.
func _spend_gold(f: Fighter, amount: int) -> void:
	f.gold -= amount
	f.gold_spent += amount
	f.add_ult(amount * 0.5)
	c.float_text(f, "-%d Gold" % amount, Color("f2c14e"), 30)


func _quartermaster(f: Fighter, id: String, target: Fighter, ab: Dictionary) -> void:
	match id:
		"ware":
			var ware: String = ab.choice
			f.wares[ware] -= 1
			# Die Ware wurde vorher mit Gold gekauft: Ihr Wert zählt als ausgegebenes Gold
			f.gold_spent += WARES[ware].value
			f.add_ult(WARES[ware].value * 0.5)
			c.add_log("%s reicht %s: %s." % [f.display_name, target.display_name, WARES[ware].name])
			match ware:
				"heiltrank":
					c.heal(f, target, 35)
				"manatrank":
					if target.klass == "ritualist":
						target.blood = mini(target.blood + 20, Fighter.MAX_BLOOD)
						c.float_text(target, "+20 Blut", Color("ff6080"))
					elif target.max_mana > 0:
						target.mana = mini(target.mana + 30, target.max_mana)
						c.float_text(target, "+30 Mana", Color("6fa8ff"))
					else:
						c.float_text(target, "Kein Mana …", Color.WHITE)
				"bombe":
					c.projectile(f, target, Elements.color("Feuer"))
					c.hit(f, target, 26, "ranged", "Feuer")
				"kraftkraut":
					target.atk_buff_turns = BattleState.BUFF_TURNS + 1
					c.heal(f, target, 10)
					c.float_text(target, "Angriff+", Color("ff8080"), 30)
		"delivery":
			for a in c.allies():
				c.heal(f, a, 14)
				if a.max_mana > 0:
					a.mana = mini(a.mana + 12, a.max_mana)
			c.add_log("Großlieferung! Alle bekommen Proviant und Tränke.")
		"appraise":
			target.vuln_turns = 3
			c.float_text(target, "Schwachstelle!", Color("f2c14e"), 30)
			c.add_log("Wertgutachten: %s (%s) ist schwach gegen %s." % [target.display_name, target.element, ", ".join(Elements.weaknesses(target.element))])
		"coins":
			c.projectile(f, target, Color("f2c14e"))
			c.hit(f, target, 24, "ranged")
		"ult":
			var power := 8 + mini(40, f.gold_spent / 10)
			c.add_log("Goldrausch! (%d Gold ausgegeben)" % f.gold_spent)
			for a in c.allies():
				a.atk_buff_turns = BattleState.BUFF_TURNS + 2
				c.hasten(a, 0.4)
				c.float_text(a, "Motiviert!", Color("f2c14e"))
			for enemy in c.alive(c.enemies):
				c.projectile_bg(f, enemy, Color("f2c14e"))
			c.wait(0.3)
			for enemy in c.alive(c.enemies):
				c.hit(f, enemy, power, "ranged")


func _kunoichi(f: Fighter, id: String, target: Fighter, ab: Dictionary) -> void:
	match id:
		"kunai":
			c.projectile(f, target, Color("e8e8f0"), 0.2)
			c.hit(f, target, 11, "ranged")
		"talisman":
			var el: String = ab.choice
			c.projectile(f, target, Elements.color(el), 0.25)
			target.seals.append(el)
			if target.seals.size() > Fighter.MAX_SEALS:
				target.seals.pop_front()
			c.float_text(target, "%s-Siegel" % el, Elements.color(el), 30)
		"release":
			var seals := target.seals.duplicate()
			target.seals.clear()
			var combo := seals.size() >= 2
			var mult := 1.5 if combo else 1.0
			if combo:
				c.add_log("[color=#ff7fb0]Siegel-Kombination: %s![/color]" % " + ".join(seals))
				# Die Ult lädt nur durch ausgelöste Kombinationen (design.md), einzelne Siegel laden nichts
				f.add_ult(35)
			for el: String in seals:
				c.burst(target, Elements.color(el), 120.0)
				_seal_effect(f, target, el, mult)
				c.wait(0.2)
		"smoke":
			for a in c.allies():
				a.smoke = 1
				a.smoke_source = f
			c.add_log("Rauchbombe! Der nächste Angriff auf jeden Verbündeten geht daneben.")
		"ult":
			for enemy in c.alive(c.enemies):
				var el := Elements.best_against(enemy.element, Elements.NATURE)
				c.burst(enemy, Elements.color(el), 110.0)
				c.hit(f, enemy, 22, "magic", el)
			for a in c.allies():
				c.heal(f, a, 18)
				c.give_shield(f, a, 12)


func _seal_effect(f: Fighter, target: Fighter, el: String, mult: float) -> void:
	match el:
		"Feuer":
			c.hit(f, target, 14 * mult, "magic", "Feuer")
		"Blitz":
			c.hit(f, target, 10 * mult, "magic", "Blitz")
			c.delay(target, 0.4 * mult)
		"Wind":
			c.hit(f, target, 6 * mult, "magic", "Wind")
			for a in c.allies():
				c.hasten(a, 0.2 * mult)
			c.add_log("Rückenwind: Die Gruppe ist schneller dran.")
		"Erde":
			for a in c.allies():
				c.give_shield(f, a, roundi(14 * mult))
		"Wasser":
			for a in c.allies():
				c.heal(f, a, roundi(12 * mult))


func _singer(f: Fighter, id: String, target: Fighter) -> void:
	match id:
		"spark":
			c.projectile(f, target, Color("ffe680"))
			c.hit(f, target, 11, "magic")
			_add_resonance(f, true)
		"lullaby":
			if f.res_def >= Fighter.MAX_RES:
				c.add_log("[color=#6fe0ff]Sternenglanz![/color] Das Wiegenlied klingt für die ganze Gruppe.")
				for a in c.allies():
					c.heal(f, a, 24)
			else:
				c.heal(f, target, 24)
			_add_resonance(f, false)
		"polar":
			# Polarstern: ein fester Leitstern. Mit vollem Schutz-Sternbild (Sternenglanz) für alle.
			var targets: Array[Fighter] = [target]
			if f.res_def >= Fighter.MAX_RES:
				c.add_log("[color=#6fe0ff]Sternenglanz![/color] Der Polarstern leuchtet für die ganze Gruppe.")
				targets = c.allies()
			for a in targets:
				a.def_buff_turns = BattleState.BUFF_TURNS + 1
				c.hasten(a, 0.3)
				c.burst(a, Color("cfe6ff"), 90.0)
				c.float_text(a, "Polarstern", Color("cfe6ff"), 30)
			_add_resonance(f, false)
		"comet":
			var used := f.res_off
			f.res_off = 0
			f.add_ult(used * 12)
			var dmg := 8.0 + 8.0 * used
			var targets: Array[Fighter] = [target]
			if used >= Fighter.MAX_RES:
				c.add_log("[color=#ff8a3d]Sternenglanz![/color] Der Komet trifft alle Gegner.")
				targets = c.alive(c.enemies)
			for enemy in targets:
				c.projectile_bg(f, enemy, Color("ff8a3d"))
			c.wait(0.3)
			for enemy in targets:
				c.hit(f, enemy, dmg, "magic")
		"meteor":
			var used := f.res_def
			f.res_def = 0
			f.add_ult(used * 12)
			for a in c.allies():
				c.heal(f, a, 7 * used)
		"ult":
			for a in c.allies():
				c.heal(f, a, 35)
				a.atk_buff_turns = BattleState.BUFF_TURNS + 1
				a.def_buff_turns = BattleState.BUFF_TURNS + 1
			for enemy in c.alive(c.enemies):
				c.projectile_bg(f, enemy, Elements.color("Sternenkraft"))
			c.wait(0.3)
			for enemy in c.alive(c.enemies):
				c.hit(f, enemy, 22, "magic", "Sternenkraft")
	c.wait(0.1)


func _add_resonance(f: Fighter, offensive: bool) -> void:
	if offensive:
		f.res_off = mini(f.res_off + 1, Fighter.MAX_RES)
		f.off_idle = 0
	else:
		f.res_def = mini(f.res_def + 1, Fighter.MAX_RES)
		f.def_idle = 0


# --- Duette -------------------------------------------------------------------

func _execute_duet(f: Fighter, ab: Dictionary, target: Fighter) -> void:
	match ab.id:
		"treibjagd":
			var archer := c.hero("archer")
			var tamer := c.hero("tamer")
			var m := tamer.active_monster
			c.projectile(archer, target, Color("b8ff8a"))
			c.hit(archer, target, 18, "ranged")
			if m.is_alive() and target.is_alive():
				c.lunge(m, target, 0.3)
				c.hit(m, target, 14, "melee", m.element)
			if target.is_alive():
				target.vuln_turns = 3
				c.delay(target, 0.3)
				c.float_text(target, "Gehetzt!", Color("b8ff8a"), 30)
		"blutsiegel":
			var ritualist := c.hero("ritualist")
			var kunoichi := c.hero("kunoichi")
			pay_blood(ritualist, 12)
			c.projectile(kunoichi, target, Color("c2304f"))
			c.burst(target, Color("c2304f"), 120.0)
			var dealt := c.hit(kunoichi, target, 24, "magic", "Schatten")
			for a in c.allies():
				c.heal(ritualist, a, ceili(dealt * 0.5))
		"nachschub":
			var mechanic := c.hero("mechanic")
			var quartermaster := c.hero("quartermaster")
			_spend_gold(quartermaster, 20)
			if mechanic.robot.is_alive():
				c.heal(mechanic, mechanic.robot, 40)
			for a in c.allies():
				c.heal(quartermaster, a, 12)
				if a.max_mana > 0:
					a.mana = mini(a.mana + 12, a.max_mana)
		"gluehende_klingen":
			var smith := c.hero("smith")
			var blade := c.hero("blade")
			c.projectile(smith, target, Elements.color("Feuer"))
			c.hit(smith, target, 18, "ranged", "Feuer")
			_add_blades(blade, 3)
			blade.fire_turns = 3
			c.burst(blade, Elements.color("Feuer"), 110.0)
			c.add_log("Zaras Klingen glühen: 3 Züge lang Feuer-Schaden.")
		"zwielicht_barriere":
			var twilight := c.hero("twilight")
			for a in c.allies():
				c.give_shield(f, a, 20)
			c.wait(0.2)
			for enemy in c.alive(c.enemies):
				c.hit(twilight, enemy, 10, "magic", "Licht")
		"sternentanz":
			var singer := c.hero("singer")
			var blade := c.hero("blade")
			# Die Sängerin singt, die Klingen leuchten im Takt und treffen eine Runde lang mit Sternenkraft
			_add_resonance(singer, true)
			_add_resonance(singer, false)
			_add_blades(blade, 2)
			blade.star_turns = 2
			c.burst(blade, Elements.color("Sternenkraft"), 120.0)
			c.add_log("Sternentanz! Zaras Klingen leuchten wie Sterne: Bis nach ihrem nächsten Zug treffen sie mit Sternenkraft.")


# --- Zugbeginn, Reaktionen, Schaden -------------------------------------------

## Klassen-Mechaniken zu Beginn des eigenen Zuges.
func begin_turn(f: Fighter) -> void:
	match f.klass:
		"tank":
			if f.fortress:
				f.fortress = false
				var power := maxi(20, f.fortress_absorbed)
				c.add_log("[color=#4a8cf0][b]Die Arkane Festung explodiert![/b][/color] (%d aufgefangener Schaden)" % f.fortress_absorbed)
				c.burst(f, Color("4a8cf0"), 260.0)
				c.screen_flash(Color("4a8cf0"))
				c.wait(0.4)
				for enemy in c.alive(c.enemies):
					c.apply_damage(enemy, power, f)
				c.wait(0.6)
		"singer":
			# Verblassen: Ein Sternbild, das 2 Züge nicht gefüllt wurde, verliert jeden Zug 1 Resonanz.
			if f.off_idle >= 2 and f.res_off > 0:
				f.res_off -= 1
				c.float_text(f, "Verblassen", Color("ff8a3d"))
			if f.def_idle >= 2 and f.res_def > 0:
				f.res_def -= 1
				c.float_text(f, "Verblassen", Color("6fe0ff"))
			f.off_idle += 1
			f.def_idle += 1
		"twilight":
			if absi(f.balance) >= Fighter.MAX_BALANCE:
				c.float_text(f, "Rückstoß", Color("e0c8ff"), 30)
				c.apply_damage(f, roundi(f.max_hp * OVERLOAD_RECOIL))
		"blade":
			f.fire_turns = maxi(f.fire_turns - 1, 0)
			f.star_turns = maxi(f.star_turns - 1, 0)
		"robot":
			# Passive "Wartung": Solange der Mechaniker lebt, repariert sich der Roboter etwas.
			if f.owner.is_alive() and f.hp < f.max_hp:
				c.heal(f.owner, f, 5)
		_:
			if is_pet(f) and _bench_has(f.owner, "bachotter"):
				c.heal(f.owner, f, 5)
	if not f.is_ally() and "Feuer" in f.seals:
		c.float_text(f, "Brennt", Elements.color("Feuer"), 30)
		c.apply_damage(f, BURN, c.hero("kunoichi"))
		c.wait(0.3)


## Was eine perfekte Reaktion bei der jeweiligen Klasse bewirkt (der Treffer wird immer abgewehrt).
func on_perfect_reaction(h: Fighter, attacker: Fighter) -> void:
	match h.klass:
		"tank":
			h.mana = mini(h.mana + 15, h.max_mana)
			c.float_text(h, "PARIERT! +15 Mana", Color("6fa8ff"))
		"mechanic":
			for owner_or_robot: Fighter in [h, h.robot]:
				for id: String in owner_or_robot.cooldowns.keys():
					owner_or_robot.cooldowns[id] = maxi(owner_or_robot.cooldowns[id] - 1, 0)
			c.float_text(h, "PARIERT! Abklingzeit −1", Color("d9a441"))
		"smith":
			c.float_text(h, "PARIERT!", Color("ffb070"))
			_add_hard(h, 1)
		"blade":
			_add_blades(h, 1)
			c.float_text(h, "PARIERT! +1 Klinge", Color("ffd0a0"))
		"novize":
			c.float_text(h, "PARIERT!", Color("8affc1"))
			c.hop(h)
		"kunoichi":
			c.float_text(h, "AUSGEWICHEN! Konter!", Color("ff7fb0"))
			c.hop(h)
			c.projectile(h, attacker, Color("e8e8f0"), 0.15)
			c.hit(h, attacker, 8, "ranged")
		"singer":
			_add_resonance(h, true)
			_add_resonance(h, false)
			c.float_text(h, "AUSGEWICHEN! +1 Resonanz", Color("ffe680"))
			c.hop(h)
		_:
			c.float_text(h, "AUSGEWICHEN!", Color("b8ff8a"))
			c.hop(h)
	c.burst(h, Color("cfe2ff"), 90.0)
	if h.display_name == "Du":
		c.add_log("[color=#8affc1]Du reagierst perfekt![/color]")
	else:
		c.add_log("[color=#8affc1]%s reagiert perfekt![/color]" % h.display_name)


## Zusätzlicher Schaden durch Klassen-Passiven des Angreifers.
func damage_bonus(attacker: Fighter) -> float:
	if attacker.klass == "blade":
		# Passive "Klingenkranz": jede Klinge +5 % Schaden
		return 1.0 + 0.05 * attacker.blades
	if attacker.owner != null and attacker == attacker.owner.active_monster and _bench_has(attacker.owner, "glutwelpe"):
		return 1.15
	return 1.0


## Schaden, den das Ziel durch Rüstung oder Bank-Monster abfängt.
func mitigate(target: Fighter, amount: int, kind: String) -> int:
	if target.klass == "smith" and kind != "" and amount > 0:
		if kind == target.armor:
			var saved := roundi(amount * ARMOR_BLOCK)
			amount -= saved
			target.stat_blocked += saved
			target.add_ult(18)
			c.float_text(target, "Passende Rüstung!", Color("ffb070"), 52)
			_add_hard(target, 1)
		elif target.hard > 0:
			target.hard -= 1
			c.float_text(target, "Falsche Rüstung: Härte −1", Color("ff9070"), 52)
		if target.hard > 0:
			var hardened := roundi(amount * HARD_STEP * target.hard)
			amount -= hardened
			target.stat_blocked += hardened
	if target.owner != null and target == target.owner.active_monster and _bench_has(target.owner, "moosling"):
		var saved := roundi(amount * 0.15)
		amount -= saved
		target.owner.stat_blocked += saved
	return amount


## Folgen eines Treffers (Ult-Aufladung, Karren, unterbrochenes Spannen).
func after_damage(target: Fighter, lost: int) -> void:
	if lost <= 0:
		return
	if target.klass == "robot":
		target.owner.add_ult(lost * 0.8)
	if target.klass == "quartermaster" and target.cart_hp > 0:
		target.cart_hp = maxi(target.cart_hp - ceili(lost * 0.5), 0)
		if target.cart_hp == 0:
			target.wares.clear()
			c.float_text(target, "Karren kaputt!", Color("f2c14e"), 52)
			c.add_log("[color=#f2c14e]Der Karren von %s ist kaputt, alle Waren sind verloren![/color]" % target.display_name)
	if target.charged:
		target.charged = false
		c.add_log("%s wird getroffen, das Spannen bricht ab." % target.display_name)


func on_death(target: Fighter) -> void:
	target.taunt = 0
	target.seals.clear()
	match target.klass:
		"tank":
			target.fortress = false
		"robot":
			# Der Roboter explodiert: Schaden an allen Gegnern, aber auch am beschützten Verbündeten
			c.add_log("[color=#d9a441][b]%s explodiert![/b][/color]" % target.display_name)
			c.burst(target, Color("ffb040"), 220.0)
			c.screen_flash(Color("ffb040"))
			for enemy in c.alive(c.enemies):
				c.apply_damage(enemy, 25, target)
			var protected := target.protecting
			target.protecting = null
			if protected != null and protected.is_alive():
				c.add_log("%s wird von der Explosion mitgetroffen." % protected.display_name)
				c.apply_damage(protected, 12)
		_:
			if is_pet(target):
				c.add_log("%s muss ein anderes Monster schicken (Wechsel)." % target.owner.display_name)


func _bench_has(tamer: Fighter, id: String) -> bool:
	for m in tamer.monsters:
		if m.klass == id and m != tamer.active_monster and m.is_alive():
			return true
	return false


## Was ein Gegner als Nächstes vorhat (steht auf seinem Namensschild).
func enemy_intent(e: Fighter) -> String:
	if c.dungeon != null and c.dungeon.handles(e):
		return c.dungeon.intent(e)
	if e.klass == "boss":
		match e.step % 4:
			0, 1:
				return "Nächster Zug: Steinfaust"
			2:
				return "NÄCHSTER ZUG: Felsregen auf die HINTERE Reihe!"
			3:
				return "Nächster Zug: Kettenzug nach hinten"
	var data: Dictionary = Sandbox.ENEMIES[e.klass]
	var attack: Dictionary = data.attacks[e.step % data.attacks.size()]
	var text := "Nächster Zug: %s%s" % [attack.name, " (alle!)" if attack.get("all", false) else ""]
	if data.has("wipe_nach"):
		text += "\nEXPLOSION in %d Zügen!" % (int(data.wipe_nach) - e.step)
	return text


# --- Novize (Kreuzweg-Demo) ---------------------------------------------------

func _novize(f: Fighter, id: String, target: Fighter) -> void:
	match id:
		"schlag":
			c.lunge(f, target, 0.25)
			c.hit(f, target, 12, "melee")
		"kraftschlag":
			c.lunge(f, target, 0.3)
			c.hit(f, target, 20, "melee")
		"erste_hilfe":
			c.heal(f, target, 22)
		"trank":
			f.wares.heiltrank -= 1
			c.add_log("%s trinkt einen Heiltrank." % f.display_name if target == f else "%s reicht %s einen Heiltrank." % [f.display_name, target.display_name])
			c.heal(f, target, 35)
