class_name Vulkanschmiede
extends DungeonRegeln
## Boss-Mechaniken der Vulkanschmiede der Ketten (design.md „Glutoase im Detail“, Sitzung 24).
## Zwischenboss Hammerbrüder (D33): zwei große Ambossknechte von Hadrak. Pro Kampf zufällig EINE Mechanik:
## - Wipe „Doppelschlag“: Beide holen aus und schlagen gemeinsam auf den Amboss, zwei Züge vorher angekündigt,
##     tödlich für alle – außer jemand bringt einen der beiden aus dem Takt („Bruder stören“, kostet den Zug).
## - Zusammenspiel „Gleichschritt“: Liegt einer im Leben deutlich vorn, wird der schwächere rasend.
##     Beide gleichmäßig schwächen. Fällt einer, während der andere noch viel Leben hat, tobt der andere.
## Ab halbem Leben (beide zusammen) Hammerwut (A9b3, kurzer Film, Motiv „amboss“): Der Doppelschlag kommt viel
## öfter, beim Gleichschritt werden sie früher und stärker rasend, und ein rasender Bruder steckt viel weg. Die Mechanik wird Pflicht.
## Der Lava-Takt (lava_takt.gd) läuft in allen Kämpfen hier weiter.
## Endboss Kettenschmied (D34): eigene Datei kettenschmied.gd, hier nur weitergereicht.

const BRUEDER: Array[String] = ["hammerbruder_hammer", "hammerbruder_zange"]
## Nach so vielen Zügen des Hammer-Bruders kommt der Doppelschlag (angekündigt zwei Züge vorher)
const DOPPELSCHLAG_ALLE := 5
const ANKUENDIGUNG := 2
## Gleichschritt: ab diesem Abstand im Leben (Anteil) wird der schwächere rasend, darunter beruhigt er sich wieder
const ABSTAND_RASEND := 0.25
const ABSTAND_RUHIG := 0.12
const RASEND_SCHADEN := 1.7
## Hammerwut (A9b3): ab diesem Anteil Leben beider Brüder zusammen; dann gelten diese Werte
const WUT_AB := 0.5
const WUT_DOPPELSCHLAG_ALLE := 3
const WUT_ABSTAND_RASEND := 0.15
const WUT_RASEND_SCHADEN := 2.3
## In der Hammerwut kommt an einem rasenden Bruder nur dieser Anteil des Schadens an
const WUT_RASEND_SCHUTZ := 0.2

## Nur für Messungen (tests/boss_messen.gd): immer diese Mechanik statt einer zufälligen
static var modus_fest := ""
## Mechanik in diesem Kampf: "doppelschlag" (Wipe) oder "gleichschritt" (Zusammenspiel)
var modus := ""
## Züge des Hammer-Bruders bis zum Doppelschlag
var schlag_in := DOPPELSCHLAG_ALLE
## Hammerwut (A9b3)
var wut := false
var _teilt := false
## Endboss
var ks: Kettenschmied


func _init(p_combat: BattleState) -> void:
	super(p_combat)
	ks = Kettenschmied.new(p_combat)


func handles(e: Fighter) -> bool:
	return e.klass in BRUEDER or ks.handles(e)


func on_wave(index: int) -> void:
	ks.on_wave(index)
	modus = ""
	wut = false
	if _find(BRUEDER[0]) == null:
		return
	modus = c.pick(["doppelschlag", "gleichschritt"]) if modus_fest == "" else modus_fest
	schlag_in = DOPPELSCHLAG_ALLE
	c.add_log("[b]Zwischenboss: Die Hammerbrüder![/b] Zwei alte Ambossknechte aus Hadraks Schmiede.")
	if modus == "doppelschlag":
		c.add_log("[color=#ffb070]Mechanik heute: Doppelschlag.[/color] Holen beide aus, schlagen sie zwei Züge später gemeinsam auf "
				+ "den Amboss – das übersteht niemand. Bringt einen der beiden mit „Bruder stören“ aus dem Takt!")
	else:
		c.add_log("[color=#ffb070]Mechanik heute: Gleichschritt.[/color] Schwächt beide gleichmäßig: Liegt einer deutlich vorn, "
				+ "wird der schwächere rasend.")
	_update_intents()


func intent(e: Fighter) -> String:
	if ks.handles(e):
		return ks.intent(e)
	if not handles(e):
		return ""
	var text := ("Hammerschlag" if e.step % 2 == 0 else "Erdstoß (alle)") if e.klass == BRUEDER[0] \
			else ("Zangengriff (hält fest)" if e.step % 2 == 0 else "Funkenregen (hinten)")
	if e.has_meta("rasend"):
		text = "RASEND! " + text
	elif wut:
		text = "Hammerwut! " + text
	if modus == "doppelschlag":
		if e.has_meta("holt_aus"):
			text += "\nDOPPELSCHLAG in %d Zügen!" % schlag_in
		elif schlag_in <= ANKUENDIGUNG:
			text += "\nAus dem Takt"
	return text


func _update_intents() -> void:
	for e in c.enemies:
		if handles(e):
			e.intent = intent(e)


# --- Gegner-Züge --------------------------------------------------------------

func enemy_turn(e: Fighter) -> void:
	if ks.handles(e):
		await ks.enemy_turn(e)
		return
	if e.klass == BRUEDER[0] and modus == "doppelschlag":
		schlag_in -= 1
		if schlag_in == ANKUENDIGUNG:
			_ausholen()
		elif schlag_in <= 0:
			await _doppelschlag(e)
			schlag_in = WUT_DOPPELSCHLAG_ALLE if wut else DOPPELSCHLAG_ALLE
			e.step += 1
			_update_intents()
			return
	var mal := (WUT_RASEND_SCHADEN if wut else RASEND_SCHADEN) if e.has_meta("rasend") else 1.0
	if e.klass == BRUEDER[0]:
		if e.step % 2 == 0:
			await c.enemy_attack(e, [c.pick_target()], roundi(18 * mal), "melee", "Hammerschlag")
		else:
			await c.enemy_attack(e, c.allies(), roundi(8 * mal), "magic", "Erdstoß")
	else:
		if e.step % 2 == 0:
			var t := c.pick_target()
			await c.enemy_attack(e, [t], roundi(14 * mal), "melee", "Zangengriff")
			if t.is_alive() and c._getroffen.has(t):
				Effekte.anwenden(c, e, t, "festhalten", 0.0, 2)
		else:
			await c.enemy_attack(e, [c.pick_target(true, true)], roundi(12 * mal), "ranged", "Funkenregen")
	e.step += 1
	_update_intents()


## Beide Brüder holen aus (zwei Züge vor dem Doppelschlag).
func _ausholen() -> void:
	var lebende := c.alive(c.enemies).filter(func(b: Fighter) -> bool: return handles(b))
	if lebende.size() < 2:
		return
	for b: Fighter in lebende:
		b.set_meta("holt_aus", true)
		c.float_text(b, "Holt aus!", Color("ffb070"), 40)
	c.banner("Die Hammerbrüder holen aus!")
	c.add_log("[color=#ff8a3d][b]Die Hammerbrüder holen aus![/b] In %d Zügen schlagen sie gemeinsam zu. Stört einen der beiden![/color]" % ANKUENDIGUNG)


func _doppelschlag(e: Fighter) -> void:
	var im_takt := c.alive(c.enemies).filter(func(b: Fighter) -> bool: return handles(b) and b.has_meta("holt_aus"))
	for b in c.enemies:
		if handles(b):
			b.remove_meta("holt_aus")
	c._emit({type = "cast", f = e, ult = false, name = "Doppelschlag"})
	if im_takt.size() >= 2:
		c.burst(e, Color("ff8a3d"), 320.0)
		c.wipe("Doppelschlag! Beide Hämmer treffen den Amboss gleichzeitig.")
		return
	c.add_log("[color=#8affc1]Aus dem Takt![/color] Nur ein Hammer trifft den Amboss, die Druckwelle ist schwach.")
	await c.enemy_attack(e, c.allies(), 6, "magic", "Halber Doppelschlag")


# --- Gleichschritt ------------------------------------------------------------

func check_phase() -> void:
	ks.check_phase()
	if modus != "" and not wut:
		var leben := 0
		var gesamt := 0
		for name: String in BRUEDER:
			var b := _find(name)
			if b != null:
				leben += maxi(0, b.hp)
				gesamt += b.max_hp
		if gesamt > 0 and leben > 0 and leben <= gesamt * WUT_AB:
			_wut_start()


## Hammerwut (A9b3): kurzer Film, danach wird die Mechanik Pflicht.
func _wut_start() -> void:
	wut = true
	var hammer := _find(BRUEDER[0])
	var bruder := hammer if hammer != null and hammer.is_alive() else _find(BRUEDER[1])
	var unter := "Der Doppelschlag kommt jetzt viel öfter. Stört sie!" if modus == "doppelschlag" \
			else "Wer zurückliegt, rast und steckt viel weg. Schwächt beide gleich!"
	c.phasen_film(bruder, "amboss", "Hammerwut!", unter, Color("ffb070"))
	c.add_log("\n[color=#ff8a3d][b]Die Hammerbrüder geraten in Hammerwut![/b][/color]")
	if modus == "doppelschlag":
		schlag_in = mini(schlag_in, WUT_DOPPELSCHLAG_ALLE)
		c.add_log("Der Doppelschlag kommt jetzt alle %d Züge. Ohne „Bruder stören“ übersteht ihn niemand." % WUT_DOPPELSCHLAG_ALLE)
	else:
		c.add_log("Schon bei kleinem Abstand im Leben wird der schwächere rasend: Er schlägt viel härter zu und steckt viel weg.")
	_update_intents()
	c.refresh()


func absorbs(target: Fighter, amount: int, source: Fighter) -> bool:
	# Hammerwut: Ein rasender Bruder steckt viel weg (A9b3), darum beide gleichmäßig schwächen
	if wut and not _teilt and target.klass in BRUEDER and target.has_meta("rasend"):
		_teilt = true
		c.apply_damage(target, maxi(1, roundi(amount * WUT_RASEND_SCHUTZ)), source)
		_teilt = false
		return true
	return ks.absorbs(target, amount, source)


func on_hit(_attacker: Fighter, target: Fighter, _element: String, _lost: int) -> void:
	if modus != "gleichschritt" or not handles(target):
		return
	var a := _find(BRUEDER[0])
	var b := _find(BRUEDER[1])
	if a == null or b == null:
		return
	if not a.is_alive() or not b.is_alive():
		# Fällt einer, während der andere noch viel Leben hat, tobt der andere
		var rest := a if a.is_alive() else b
		if rest.is_alive() and rest.hp > rest.max_hp * ABSTAND_RASEND and not rest.has_meta("rasend"):
			_rasend(rest, "tobt über den gefallenen Bruder!")
		_update_intents()
		return
	var anteil_a := float(a.hp) / a.max_hp
	var anteil_b := float(b.hp) / b.max_hp
	var schwach := a if anteil_a < anteil_b else b
	var stark := b if schwach == a else a
	var abstand := absf(anteil_a - anteil_b)
	if abstand > (WUT_ABSTAND_RASEND if wut else ABSTAND_RASEND) and not schwach.has_meta("rasend"):
		_rasend(schwach, "wird rasend! Sein Bruder ist noch viel stärker.")
	elif abstand <= ABSTAND_RUHIG:
		for f: Fighter in [schwach, stark]:
			if f.has_meta("rasend"):
				f.remove_meta("rasend")
				c.float_text(f, "Beruhigt", Color("8affc1"), 40)
				c.add_log("[color=#8affc1]%s fällt wieder in den Gleichschritt.[/color]" % f.display_name)
	_update_intents()


func _rasend(f: Fighter, text: String) -> void:
	f.set_meta("rasend", true)
	c.float_text(f, "Rasend!", Color("ff5a2a"), 40)
	c.burst(f, Color("ff5a2a"), 160.0)
	c.add_log("[color=#ff5a2a][b]%s %s[/b][/color]" % [f.display_name, text])


# --- Aktion für alle Klassen ----------------------------------------------------

func extra_abilities(f: Fighter) -> Array[Dictionary]:
	var list: Array[Dictionary] = ks.extra_abilities(f)
	# Nur solange noch beide im Takt sind (einen zu stören reicht)
	if modus == "doppelschlag" and c.alive(c.enemies).filter(func(b: Fighter) -> bool: return handles(b) and b.has_meta("holt_aus")).size() >= 2:
		list.append({id = "stoeren", name = "Bruder stören", info = "Bringt einen Bruder aus dem Takt: kein Doppelschlag (kostet den Zug)",
				target = "none", dungeon = true})
	return list


func execute(f: Fighter, ab: Dictionary, target: Fighter) -> void:
	if ab.id in ["anker", "kette"]:
		ks.execute(f, ab, target)
		return
	if ab.id == "stoeren":
		var im_takt := c.alive(c.enemies).filter(func(b: Fighter) -> bool: return handles(b) and b.has_meta("holt_aus"))
		if not im_takt.is_empty():
			var b: Fighter = im_takt[0]
			b.remove_meta("holt_aus")
			c.float_text(b, "Aus dem Takt!", Color("8affc1"), 40)
			c.hop(b)
			c.add_log("%s wirft eine Kette zwischen die Hämmer: %s ist aus dem Takt." % [f.display_name, b.display_name])
	_update_intents()
	c.wait(0.3)
