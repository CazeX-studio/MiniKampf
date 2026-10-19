extends Node
## Automatischer Testkampf mit dem Kampf-Zustand (battle_state.gd) ohne jede Grafik.
## Dieser Knoten ist der "Steuerer": Der Computer wählt Fähigkeiten und Reaktionen,
## die gemeldeten Ereignisse werden nur mitgeschrieben.

var ki: KampfKI
var protokoll := KampfProtokoll.new()
var start_seed := 1
## Kampf aus der Kreuzweg-Demo (BattleRequest.setup); leer = Sandbox-Kampf
var setup := {}
## Angenommener Spieler bei Kämpfen aus der Welt: so oft perfekt bzw. normal pariert
const PLAYER_PERFECT := 0.35
const PLAYER_NORMAL := 0.35
var state: BattleState


func _ready() -> void:
	ki = KampfKI.new(start_seed + 1000)
	if setup.is_empty():
		state = BattleState.new(self, Sandbox.team, Sandbox.encounter, start_seed)
	else:
		state = BattleState.new(self, [] as Array[String], "", start_seed)
		state.setup = setup
	state.max_turns = KampfProtokoll.MAX_TURNS
	state.run()


func _exit_tree() -> void:
	state.cleanup()


func play(events: Array[Dictionary]) -> void:
	for event in events:
		match event.type:
			"log":
				protokoll.log_text(event.text)
			"float":
				protokoll.float_text(event.f, event.text)
			"turn":
				if event.f != null:
					protokoll.turn(state.turns, event.f, state.all_fighters())
			"end":
				protokoll.finish("Abbruch" if event.aborted else ("Sieg" if event.won else "Niederlage"), state.heroes)


func choose_action(f: Fighter) -> Dictionary:
	return ki.choose(state.skills, f)


func react(_attacker: Fighter, target: Fighter, _duration: float) -> Variant:
	# Kämpfe aus der Welt: Reaktion mit Stufe (Spieler: je 35 % perfekt und normal, Mitstreiter wie im Spiel)
	if not setup.is_empty():
		if state.computer.has(target):
			return ki.react_grade(Combat.ALLY_PARRY_CHANCE, Combat.ALLY_NORMAL_CHANCE)
		return ki.react_grade(PLAYER_PERFECT, PLAYER_NORMAL)
	# Sandbox (Vergleich mit dem alten Stand): ja/nein, die Hälfte der Fälle
	return ki.react(Combat.ALLY_PARRY_CHANCE if state.computer.has(target) else 0.5)



func choose_option(_title: String, options: Array[Dictionary]) -> String:
	return ki.choose_option(options)
