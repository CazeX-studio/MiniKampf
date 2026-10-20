class_name GemeinsamerKampf
extends RefCounted
## Gemeinsamer Kampf beim Zusammenspielen (Lernprojekt 4, Schritt 6).
##
## Die Kampfregeln (BattleState) ergeben bei gleichem Startwert und gleichen Entscheidungen immer genau denselben Kampf.
## Darum rechnet jedes Gerät den Kampf selbst, übers Netz gehen nur die Entscheidungen der Spieler
## (Fähigkeit und Ziel, wie gut pariert wurde). Jede Entscheidung hat eine fortlaufende Nummer.
##
## Der Gastgeber rechnet mit diesem Objekt unsichtbar mit (ohne Grafik und ohne Wartezeiten). So weiß er immer,
## wer gerade entscheiden muss, prüft jede Entscheidung und springt ein, wenn jemand die Verbindung verliert oder aufgibt:
## Dann entscheidet er für dessen Figur (Standardangriff) und schickt das an alle.
## Die Novizen-Mitstreiter (Computer) entscheiden auf jedem Gerät gleich, weil ihr Zufall denselben Startwert hat.

signal decided(seq: int)
signal finished

## So lange hat ein Spieler für seinen Zug Zeit (Sekunden), danach kommt ein Standardangriff (design.md: 20–30 s)
const TURN_SECONDS := 25.0

var bid: int
var state: BattleState
## Held (Nummer) -> Spieler, "" = Computer
var owners: Array = []
## Entscheidungen: Nummer -> Daten
var decisions := {}
## Spieler, die nicht mehr mitspielen (Verbindung weg oder aufgegeben)
var gone := {}
var pending_seq := -1
var pending_owner := ""
var pending_kind := ""
var pending_fighter: Fighter
var pending_options: Array = []
## Gastgeber schickt Entscheidungen weiter: broadcast.call(bid, seq, data)
var broadcast: Callable
var _seq := 0
## Gleicher Zufall wie auf allen Geräten (Novizen-Mitstreiter)
var _ki: KampfKI
## Nur für den Gastgeber, wenn er für jemanden einspringt
var _helper: KampfKI
var _early := {}


func _init(p_bid: int, setup: Dictionary, p_seed: int, p_owners: Array, p_broadcast: Callable) -> void:
	bid = p_bid
	owners = p_owners
	broadcast = p_broadcast
	state = BattleState.new(self, [] as Array[String], "", p_seed)
	state.setup = setup.duplicate(true)
	_ki = KampfKI.new(ki_seed(p_seed))
	_helper = KampfKI.new(p_seed + 7)


## Startwert für den Zufall der Mitstreiter (auf allen Geräten gleich).
static func ki_seed(battle_seed: int) -> int:
	return battle_seed + 1


func start() -> void:
	await state.run()
	state.cleanup()
	finished.emit()


## Wer entscheidet für diese Figur ("" = Computer). Begleiter (Roboter, Monster) gehören dem Spieler ihres Helden.
static func owner_in(battle: BattleState, list: Array, f: Fighter) -> String:
	var hero := f.owner if f.owner != null else f
	var index := battle.heroes.find(hero)
	return str(list[index]) if index >= 0 and index < list.size() else ""


# --- Entscheidungen verpacken (gleich auf allen Geräten) --------------------------

## Fähigkeit und Ziel als Nummern: Platz in der Fähigkeiten-Liste, in der Auswahl und in der Ziel-Liste.
static func encode_action(skills: Skills, f: Fighter, command: Dictionary) -> Dictionary:
	var ab: Dictionary = command.ab
	var list := skills.abilities(f)
	var a := -1
	for i in list.size():
		if list[i].id == ab.id:
			a = i
	var c := -1
	if ab.has("choice") and a >= 0:
		var choices: Array = list[a].get("choices", [])
		for i in choices.size():
			if choices[i].id == ab.choice:
				c = i
	var t := -1
	if command.target != null:
		t = skills.valid_targets(f, ab).find(command.target)
	return {a = a, c = c, t = t}


## Nummern zurück in Fähigkeit und Ziel. Leer = ungültig.
static func decode_action(skills: Skills, f: Fighter, data: Dictionary) -> Dictionary:
	var list := skills.abilities(f)
	var a := int(data.get("a", -1))
	if a < 0 or a >= list.size():
		return {}
	var ab: Dictionary = list[a]
	if skills.blocked_reason(f, ab) != "":
		return {}
	if ab.target == "choice":
		var choices: Array = ab.get("choices", [])
		var c := int(data.get("c", -1))
		if c < 0 or c >= choices.size() or skills.choice_blocked(f, ab, choices[c]) != "":
			return {}
		var picked := ab.duplicate()
		picked.choice = choices[c].id
		picked.target = choices[c].get("then", ab.get("then", "none"))
		ab = picked
	if ab.target == "none":
		return {ab = ab, target = null}
	var targets := skills.valid_targets(f, ab)
	var t := int(data.get("t", -1))
	if t < 0 or t >= targets.size():
		return {}
	return {ab = ab, target = targets[t]}


## Standardangriff (Zeit abgelaufen oder Spieler weg): die erste Fähigkeit auf einen Gegner, sonst irgendeine erlaubte.
static func default_action(skills: Skills, f: Fighter, fallback: KampfKI) -> Dictionary:
	for ab in skills.abilities(f):
		if ab.target == "enemy" and skills.blocked_reason(f, ab) == "":
			var targets := skills.valid_targets(f, ab)
			if not targets.is_empty():
				return {ab = ab, target = targets[0]}
	return fallback.choose(skills, f)


# --- Steuerer für die Kampfregeln (Gastgeber, ohne Grafik) ------------------------

func play(_events: Array[Dictionary]) -> void:
	pass


func choose_action(f: Fighter) -> Dictionary:
	var seq := _next()
	if state.computer.has(f):
		return _ki.choose(state.skills, f)
	var data: Dictionary = await _wait(seq, "action", owner_in(state, owners, f), f)
	var command := decode_action(state.skills, f, data)
	return command if not command.is_empty() else default_action(state.skills, f, _helper)


func react(_attacker: Fighter, target: Fighter, _duration: float) -> int:
	var seq := _next()
	if state.computer.has(target):
		return _ki.react_grade(Combat.ALLY_PARRY_CHANCE, Combat.ALLY_NORMAL_CHANCE)
	var data: Dictionary = await _wait(seq, "react", owner_in(state, owners, target), target)
	return clampi(int(data.get("g", 0)), 0, 2)


func choose_option(_title: String, options: Array[Dictionary]) -> String:
	var seq := _next()
	pending_options = options
	var data: Dictionary = await _wait(seq, "option", first_owner(), null)
	return str(data.get("o", options[0].id))


## Erster Spieler (entscheidet z. B. nach dem Dungeon)
func first_owner() -> String:
	for o in owners:
		if str(o) != "":
			return str(o)
	return ""


func _next() -> int:
	_seq += 1
	return _seq


func _wait(seq: int, kind: String, p_owner: String, f: Fighter) -> Dictionary:
	pending_seq = seq
	pending_kind = kind
	pending_owner = p_owner
	pending_fighter = f
	if p_owner == "" or gone.has(p_owner):
		_substitute()
	elif _early.has(seq):
		var early: Array = _early[seq]
		_early.erase(seq)
		receive(early[0], seq, early[1])
	while not decisions.has(seq):
		await decided
	pending_seq = -1
	return decisions[seq]


## Eine Entscheidung kommt von einem Spieler. Nur wer gerade dran ist, darf; Ungültiges ersetzt der Gastgeber.
func receive(sender: String, seq: int, data: Dictionary) -> void:
	if decisions.has(seq):
		return
	if seq != pending_seq:
		if seq > pending_seq:
			_early[seq] = [sender, data]
		return
	if sender != pending_owner:
		return
	match pending_kind:
		"action":
			if decode_action(state.skills, pending_fighter, data).is_empty():
				_substitute()
				return
		"react":
			data = {g = clampi(int(data.get("g", 0)), 0, 2)}
		"option":
			var ok := false
			for option: Dictionary in pending_options:
				ok = ok or option.id == str(data.get("o", ""))
			if not ok:
				_substitute()
				return
	_accept(seq, data)


## Ein Spieler ist weg: Ab jetzt entscheidet der Gastgeber für seine Figur.
func player_gone(id: String) -> void:
	gone[id] = true
	if pending_seq >= 0 and pending_owner == id and not decisions.has(pending_seq):
		_substitute()


func _substitute() -> void:
	var data := {}
	match pending_kind:
		"action":
			data = encode_action(state.skills, pending_fighter, default_action(state.skills, pending_fighter, _helper))
		"react":
			data = {g = 0}
		"option":
			data = {o = pending_options[0].id}
	_accept(pending_seq, data)


func _accept(seq: int, data: Dictionary) -> void:
	decisions[seq] = data
	if broadcast.is_valid():
		broadcast.call(bid, seq, data)
	decided.emit(seq)
