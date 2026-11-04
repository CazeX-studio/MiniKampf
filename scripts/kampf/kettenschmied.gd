class_name Kettenschmied
extends DungeonRegeln
## Endboss der Vulkanschmiede der Ketten (D34, design.md „Glutoase im Detail“, Sitzung 24): ein Wesen aus Schlacke
## und Glut, entstanden aus Splitterstaub. Wird von Vulkanschmiede (vulkanschmiede.gd) mit aufgerufen.
## Phase 1:
## - Wipe „Lavaflut“: Drei Anker an den Wänden. Bei jedem seiner Züge reißt er an einer Kette, der Anker wackelt.
##     Hämmert bis zu seinem nächsten Zug niemand daran („Anker festhämmern“, kostet den Zug), löst er sich.
##     Sind alle drei lose, flutet die Lava die Kammer.
## - Zusammenspiel „Gefesselt“: Zwei Helden werden aneinandergekettet und teilen jeden Schaden;
##     ein dritter zerschlägt die Kette („Kette zerschlagen“).
## Phase 2 „Entfesselt“: Die Ketten reißen, die Lava steigt stufenweise; auf der höchsten Stufe schmilzt alles.
## - Am Rand das Kühlbecken: Wer es angreift, wird nass (kommt später dran, zwei seiner Züge lang).
## - Die glühende Kette lässt sich erst zerschlagen, wenn beide Angeketteten nass sind.
## - Ein nasser Held, der den Kettenschmied hart trifft, sprengt ein Stück seiner Panzerung ab.

const ANKER := 3
## Jeder so vielte Zug des Kettenschmieds: zwei Helden aneinanderketten
const FESSELN_ALLE := 3
## Phase 2: Lava-Stufen bis alles schmilzt, und alle wie viele Züge des Kettenschmieds sie steigt
const LAVA_STUFEN := 6
const LAVA_STEIGT_ALLE := 3
const LAVA_SCHADEN_JE_STUFE := 2
## Panzer in Phase 2: Stücke, und welcher Anteil des Schadens durchkommt, solange noch Panzer da ist
const PANZER := 3
const PANZER_DURCH := 0.75
## Ab so viel Schaden (vor dem Panzer) zählt ein Treffer als hart
const HARTER_TREFFER := 18
## Nass: so viele Züge des Kettenschmieds lang, und so weit rutscht man auf der Zugleiste zurück
const NASS_ZUEGE := 2
const NASS_VERZOEGERUNG := 0.5

## Zustand der Anker: "fest", "wackelt" oder "lose"
var anker: Array[String] = []
var phase2 := false
var lava_stufe := 0
var panzer := PANZER
## Die beiden aneinandergeketteten Helden (leer = niemand)
var gefesselt: Array[Fighter] = []
var _teilt := false


func handles(e: Fighter) -> bool:
	return e.klass in ["kettenschmied_1", "kettenschmied_2", "kuehlbecken"]


func on_wave(_index: int) -> void:
	if _find("kettenschmied_1") == null:
		return
	anker.assign(["fest", "fest", "fest"])
	phase2 = false
	lava_stufe = 0
	panzer = PANZER
	gefesselt.clear()
	c.add_log("[b]Endboss: Der Kettenschmied![/b] Ein Wesen aus Schlacke und Glut, geboren aus Splitterstaub.")
	c.add_log("[color=#ffb070]Lavaflut:[/color] Er reißt an den drei Ankerketten. Hämmert den wackelnden Anker fest, bevor er wieder dran ist – "
			+ "lösen sich alle drei, flutet die Lava die Kammer.")
	c.add_log("[color=#ffb070]Gefesselt:[/color] Aneinandergekettete teilen jeden Schaden. Ein Dritter kann die Kette zerschlagen.")
	_update_intents()


func _anker_text() -> String:
	var teile: PackedStringArray = []
	for a in anker:
		teile.append({"fest": "fest", "wackelt": "WACKELT", "lose": "lose"}[a])
	return "Anker: " + ", ".join(teile)


func intent(e: Fighter) -> String:
	match e.klass:
		"kettenschmied_1":
			return "%s\n%s" % [_anker_text(), "Kettenhieb" if e.step % 2 == 0 else "Glutwelle (alle)"]
		"kettenschmied_2":
			return "Lava: Stufe %d von %d · Panzer: %d\n%s" % [lava_stufe, LAVA_STUFEN, panzer, "Schlackenfaust" if e.step % 2 == 0 else "Glutsturm (alle)"]
		"kuehlbecken":
			return "Angreifen macht nass"
	return ""


func _update_intents() -> void:
	for e in c.enemies:
		if handles(e):
			e.intent = intent(e)


# --- Züge -----------------------------------------------------------------------

func enemy_turn(e: Fighter) -> void:
	match e.klass:
		"kettenschmied_1":
			await _zug_phase1(e)
		"kettenschmied_2":
			await _zug_phase2(e)
		"kuehlbecken":
			c.wait(0.1)
	e.step += 1
	_update_intents()


func _zug_phase1(e: Fighter) -> void:
	if not anker_ziehen(e):
		return
	_fessel_pruefen(e)
	if e.step % 2 == 0:
		await c.enemy_attack(e, [c.pick_target()], 16, "melee", "Kettenhieb")
	else:
		await c.enemy_attack(e, c.allies(), 9, "magic", "Glutwelle")


## Lavaflut: Der wackelnde Anker löst sich (wenn niemand gehämmert hat), dann wackelt der nächste.
## Gibt false zurück, wenn die Lava die Kammer flutet.
func anker_ziehen(e: Fighter) -> bool:
	var w := anker.find("wackelt")
	if w >= 0:
		anker[w] = "lose"
		c.add_log("[color=#ff8a3d]Ein Anker reißt aus der Wand![/color] (%d von %d lose)" % [anker.count("lose"), ANKER])
		c.float_text(e, "Anker lose!", Color("ff8a3d"), 52)
		if anker.count("lose") >= ANKER:
			c._emit({type = "cast", f = e, ult = false, name = "Lavaflut"})
			c.burst(e, Color("ff5a2a"), 360.0)
			c.wipe("Lavaflut! Alle drei Anker sind lose, die Lava flutet die Kammer.")
			return false
	var feste: Array[int] = []
	for i in anker.size():
		if anker[i] == "fest":
			feste.append(i)
	if not feste.is_empty():
		anker[c.pick(feste)] = "wackelt"
		c.add_log("Der Kettenschmied reißt an einer Kette: [color=#ffb070]ein Anker wackelt![/color] Hämmert ihn fest!")
	return true


func _zug_phase2(e: Fighter) -> void:
	# Nass trocknet
	for h in c.allies():
		if h.has_meta("nass"):
			var rest := int(h.get_meta("nass")) - 1
			if rest <= 0:
				h.remove_meta("nass")
				c.float_text(h, "Trocken", Color("d8d8e8"), 30)
			else:
				h.set_meta("nass", rest)
	if e.step % LAVA_STEIGT_ALLE == LAVA_STEIGT_ALLE - 1:
		lava_stufe += 1
		c.banner("Die Lava steigt! Stufe %d von %d" % [lava_stufe, LAVA_STUFEN])
		c.add_log("[color=#ff5a2a][b]Die Lava steigt: Stufe %d von %d.[/b][/color]" % [lava_stufe, LAVA_STUFEN])
		if lava_stufe >= LAVA_STUFEN:
			c.zeige_lava("vorne", "oben")
			c.zeige_lava("hinten", "oben")
			c.wipe("Die Lava erreicht die höchste Stufe. Alles schmilzt.")
			return
		if lava_stufe >= LAVA_STUFEN - 2:
			c.zeige_lava("vorne", "warnung")
			c.zeige_lava("hinten", "warnung")
	if lava_stufe > 0:
		for h in c.allies():
			c.apply_damage(h, LAVA_SCHADEN_JE_STUFE * lava_stufe, e, "magic")
		if c.allies().is_empty():
			return
	_fessel_pruefen(e)
	if e.step % 2 == 0:
		await c.enemy_attack(e, [c.pick_target()], 20, "melee", "Schlackenfaust")
	else:
		await c.enemy_attack(e, c.allies(), 11, "magic", "Glutsturm")


## Gefesselt: jeder dritte Zug zwei Helden aneinanderketten (wenn noch niemand gefesselt ist).
func _fessel_pruefen(e: Fighter) -> void:
	_fessel_aufraeumen()
	if not gefesselt.is_empty() or e.step % FESSELN_ALLE != FESSELN_ALLE - 1:
		return
	var helden := c.allies()
	if helden.size() < 2:
		return
	helden.shuffle()
	gefesselt.assign([helden[0], helden[1]])
	for h in gefesselt:
		c.float_text(h, "Gefesselt!", Color("ffb070"), 40)
	c.add_log("[color=#ffb070][b]Gefesselt![/b] %s und %s hängen an einer glühenden Kette und teilen jeden Schaden.[/color]"
			% [gefesselt[0].display_name, gefesselt[1].display_name])
	if phase2:
		c.add_log("Die Kette glüht: Zerschlagen geht erst, wenn beide nass sind (Kühlbecken).")


func _fessel_aufraeumen() -> void:
	if gefesselt.size() == 2 and (not gefesselt[0].is_alive() or not gefesselt[1].is_alive()):
		gefesselt.clear()
		c.add_log("Die Kette fällt klirrend zu Boden.")


# --- Phase 2 -------------------------------------------------------------------

func check_phase() -> void:
	var eins := _find("kettenschmied_1")
	if eins != null and not eins.is_alive() and not phase2:
		_starte_phase2()
	var zwei := _find("kettenschmied_2")
	var becken := _find("kuehlbecken")
	if zwei != null and not zwei.is_alive() and becken != null and becken.is_alive():
		# Ist der Kettenschmied besiegt, gehört das Kühlbecken nicht mehr zum Kampf
		becken.set_meta("geflohen", true)
		becken.hp = 0
		c._emit({type = "despawn", f = becken})
		c.zeige_lava("", "")
		c.refresh()


func _starte_phase2() -> void:
	phase2 = true
	lava_stufe = 0
	panzer = PANZER
	# Der Lava-Takt endet: Jetzt steigt die Lava überall, Stufe für Stufe
	c.lava = null
	c.zeige_lava("", "")
	c.add_log("\n[color=#ff8a3d][b]Phase 2: Entfesselt![/b][/color] Die Ketten reißen, der Kettenschmied glüht auf. Die Lava steigt Stufe für Stufe – "
			+ "auf Stufe %d schmilzt alles." % LAVA_STUFEN)
	c.add_log("[color=#8fd3ff]Kühlbecken:[/color] Wer es angreift, wird nass. Nasse Helden sprengen mit harten Treffern seine Panzerung ab.")
	c.screen_flash(Color("401000"))
	c.wait(0.8)
	c.banner("Der Kettenschmied – entfesselt")
	c.spawn_enemies(["kettenschmied_2", "kuehlbecken"])
	_update_intents()
	c.refresh()
	c.wait(1.0)


## Gefesselte teilen den Schaden; das Kühlbecken nimmt keinen Schaden; der Panzer hält einen Teil ab.
func absorbs(target: Fighter, amount: int, source: Fighter) -> bool:
	if _teilt:
		return false
	if target.klass == "kuehlbecken":
		if source != null and source.is_ally():
			_nass(source)
		return true
	if target.klass == "kettenschmied_2" and panzer > 0 and source != null and source.is_ally():
		if source.has_meta("nass") and amount >= HARTER_TREFFER:
			panzer -= 1
			c.float_text(target, "Panzer splittert!", Color("8fd3ff"), 52)
			c.burst(target, Color("8fd3ff"), 180.0)
			c.add_log("[color=#8fd3ff][b]%s sprengt ein Stück Panzer ab![/b][/color] (noch %d)" % [source.display_name, panzer])
			_update_intents()
			return false
		_teilt = true
		c.apply_damage(target, maxi(1, roundi(amount * PANZER_DURCH)), source)
		_teilt = false
		return true
	_fessel_aufraeumen()
	if target.is_ally() and gefesselt.has(target) and amount > 1:
		var partner: Fighter = gefesselt[1] if gefesselt[0] == target else gefesselt[0]
		_teilt = true
		c.apply_damage(target, amount - amount / 2, source)
		c.apply_damage(partner, amount / 2, source)
		_teilt = false
		return true
	return false


func _nass(f: Fighter) -> void:
	if not f.has_meta("nass"):
		c.delay(f, NASS_VERZOEGERUNG)
	f.set_meta("nass", NASS_ZUEGE)
	c.float_text(f, "Nass!", Color("8fd3ff"), 40)
	c.add_log("%s ist klatschnass." % f.display_name)


# --- Aktionen für alle Klassen ----------------------------------------------------

func extra_abilities(f: Fighter) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var eins := _find("kettenschmied_1")
	if eins != null and eins.is_alive() and anker.has("wackelt"):
		list.append({id = "anker", name = "Anker festhämmern", info = "Der wackelnde Anker hält wieder (kostet den Zug)", target = "none", dungeon = true})
	_fessel_aufraeumen()
	if gefesselt.size() == 2 and not gefesselt.has(f) and (not phase2 or gefesselt.all(func(h: Fighter) -> bool: return h.has_meta("nass"))):
		list.append({id = "kette", name = "Kette zerschlagen", info = "Befreit die Gefesselten (kostet den Zug)", target = "none", dungeon = true})
	return list


func execute(f: Fighter, ab: Dictionary, _target: Fighter) -> void:
	match ab.id:
		"anker":
			var w := anker.find("wackelt")
			if w >= 0:
				anker[w] = "fest"
				c.float_text(f, "Anker fest!", Color("8affc1"), 40)
				c.add_log("%s hämmert den Anker fest." % f.display_name)
		"kette":
			c.add_log("[color=#8affc1]%s zerschlägt die Kette zwischen %s und %s![/color]" % [f.display_name, gefesselt[0].display_name, gefesselt[1].display_name])
			for h in gefesselt:
				c.float_text(h, "Befreit!", Color("8affc1"), 40)
			gefesselt.clear()
	_update_intents()
	c.wait(0.3)
