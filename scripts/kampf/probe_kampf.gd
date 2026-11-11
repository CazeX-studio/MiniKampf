class_name ProbeKampf
extends Node
## Ein Kampf ohne Grafik, den der Computer für alle Seiten spielt (Kampf-Editor S2, „Probe-Lauf“).
## Wie tests/neu_kampf.gd: Fähigkeiten wählt die Kampf-KI, der Spieler pariert je 35 % perfekt und normal,
## Mitstreiter wie im Spiel. Der Kampf läuft beim Einhängen in den Baum ganz durch, danach steht das Ergebnis in state.

const PLAYER_PERFECT := 0.35
const PLAYER_NORMAL := 0.35
## Nach so vielen Zügen gilt der Kampf als unentschieden (verloren)
const MAX_TURNS := 400

var start_seed := 1
var setup := {}
var state: BattleState
var _ki: KampfKI


func _ready() -> void:
	_ki = KampfKI.new(start_seed + 1000)
	state = BattleState.new(self, [] as Array[String], "", start_seed)
	state.setup = setup
	state.max_turns = MAX_TURNS
	state.run()


func _exit_tree() -> void:
	state.cleanup()


func play(_events: Array[Dictionary]) -> void:
	pass


func choose_action(f: Fighter) -> Dictionary:
	return _ki.choose(state.skills, f)


func react(_attacker: Fighter, target: Fighter, _duration: float) -> Variant:
	if state.computer.has(target):
		return _ki.react_grade(Combat.ALLY_PARRY_CHANCE, Combat.ALLY_NORMAL_CHANCE)
	return _ki.react_grade(PLAYER_PERFECT, PLAYER_NORMAL)


func choose_option(_title: String, options: Array[Dictionary]) -> String:
	return _ki.choose_option(options)


## Spielt einen Kampf durch und gibt {gewonnen, zuege, leben} zurück (leben: Anteil Leben der Helden am Ende, 0–1).
static func einmal(eltern: Node, p_setup: Dictionary, seed_value: int) -> Dictionary:
	var k := ProbeKampf.new()
	k.start_seed = seed_value
	k.setup = p_setup.duplicate(true)
	eltern.add_child(k)
	var leben := 0.0
	var gesamt := 0.0
	for h: Fighter in k.state.heroes:
		leben += maxf(0.0, h.hp)
		gesamt += h.max_hp
	var d: DungeonRegeln = k.state.dungeon
	var phase2 := (d is Vulkanschmiede and (d as Vulkanschmiede).ks.phase2) or (d is Pilzhoehle and (d as Pilzhoehle).phase2)
	var ergebnis := {gewonnen = k.state.won, zuege = k.state.turns, leben = leben / maxf(1.0, gesamt), phase2 = phase2}
	eltern.remove_child(k)
	k.free()
	return ergebnis
