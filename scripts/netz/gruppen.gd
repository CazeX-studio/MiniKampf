class_name Gruppen
extends RefCounted
## Gruppen beim Zusammenspielen (Lernprojekt 4, Schritt 4): wer mit wem unterwegs ist, wer führt, Einladungen.
## Nur Regeln, keine Grafik und kein Netz. Der Gastgeber hat genau eine Gruppen-Verwaltung für alle Spieler.
## Später bauen die gemeinsame Geschichte (Abstimmung, Gruppenführer bei Gleichstand) und der gemeinsame Kampf darauf auf.

## Kurze Meldung für einen Spieler („Mira ist der Gruppe beigetreten.“)
signal notice(player_id: String, text: String)
## Ein Spieler wurde eingeladen
signal invited(player_id: String, from_id: String, from_name: String)

const MAX_SIZE := 4
## So lange gilt eine Einladung (Sekunden)
const INVITE_SECONDS := 60.0

## Gruppen-Nummer -> {leader = Spieler, members = [Spieler, …]}
var groups := {}
## Spieler -> Gruppen-Nummer
var group_of := {}
## Eingeladener Spieler -> {from = Spieler, until = Zeitpunkt}
var invites := {}
## Spieler -> Name (für Meldungen)
var names := {}
var _next_id := 1


func set_player_name(id: String, p_name: String) -> void:
	names[id] = p_name


## Die Gruppe eines Spielers ({leader, members}) oder leer.
func group(id: String) -> Dictionary:
	return groups.get(group_of.get(id, 0), {})


func is_leader(id: String) -> bool:
	return group(id).get("leader", "") == id


func same_group(a: String, b: String) -> bool:
	return group_of.has(a) and group_of.get(a) == group_of.get(b)


## Darf "from" den Spieler "target" einladen? Gibt den Grund zurück, warum nicht ("" = ja).
func invite_problem(from: String, target: String) -> String:
	if from == target or not names.has(target):
		return "Diesen Spieler kannst du nicht einladen."
	if group_of.has(target):
		return "%s ist schon in einer Gruppe." % _name(target)
	var g := group(from)
	if not g.is_empty() and g.leader != from:
		return "Nur der Gruppenführer kann einladen."
	if not g.is_empty() and g.members.size() >= MAX_SIZE:
		return "Die Gruppe ist voll (höchstens %d)." % MAX_SIZE
	return ""


func invite(from: String, target: String, now: float) -> bool:
	var problem := invite_problem(from, target)
	if problem != "":
		notice.emit(from, problem)
		return false
	invites[target] = {from = from, until = now + INVITE_SECONDS}
	notice.emit(from, "Einladung an %s geschickt." % _name(target))
	invited.emit(target, from, _name(from))
	return true


## Einladung annehmen: Wer eingeladen hat und noch allein ist, gründet die Gruppe und führt sie.
func accept(target: String, now: float) -> bool:
	var inv: Dictionary = invites.get(target, {})
	invites.erase(target)
	if inv.is_empty() or now > float(inv.until):
		notice.emit(target, "Die Einladung gilt nicht mehr.")
		return false
	var from: String = inv.from
	var problem := invite_problem(from, target)
	if problem != "":
		notice.emit(target, "Beitreten geht nicht: " + problem)
		return false
	if not group_of.has(from):
		var gid := _next_id
		_next_id += 1
		groups[gid] = {leader = from, members = [from]}
		group_of[from] = gid
	var gid: int = group_of[from]
	groups[gid].members.append(target)
	group_of[target] = gid
	_tell_group(gid, "%s ist der Gruppe beigetreten." % _name(target))
	return true


func decline(target: String) -> void:
	var inv: Dictionary = invites.get(target, {})
	invites.erase(target)
	if not inv.is_empty():
		notice.emit(inv.from, "%s hat die Einladung abgelehnt." % _name(target))


## Gruppe verlassen. Geht der Gruppenführer, führt der Nächste. Wer allein übrig bleibt, ist nicht mehr in einer Gruppe.
func leave(id: String, reason := "hat die Gruppe verlassen") -> void:
	if not group_of.has(id):
		return
	var gid: int = group_of[id]
	var g: Dictionary = groups[gid]
	g.members.erase(id)
	group_of.erase(id)
	notice.emit(id, "Du bist nicht mehr in der Gruppe.")
	_tell_group(gid, "%s %s." % [_name(id), reason])
	if g.members.size() <= 1:
		for rest: String in g.members:
			group_of.erase(rest)
			notice.emit(rest, "Die Gruppe ist aufgelöst.")
		groups.erase(gid)
	elif g.leader == id:
		g.leader = g.members[0]
		_tell_group(gid, "%s führt jetzt die Gruppe." % _name(g.leader))


## Gruppenführer nimmt jemanden aus der Gruppe.
func kick(leader: String, target: String) -> void:
	if is_leader(leader) and same_group(leader, target) and leader != target:
		leave(target, "wurde aus der Gruppe genommen")


## Gruppenführer gibt die Führung ab.
func promote(leader: String, target: String) -> void:
	if is_leader(leader) and same_group(leader, target) and leader != target:
		group(leader).leader = target
		_tell_group(group_of[leader], "%s führt jetzt die Gruppe." % _name(target))


## Spieler hat das Spiel verlassen.
func remove_player(id: String) -> void:
	leave(id, "hat das Spiel verlassen")
	invites.erase(id)
	for target: String in invites.keys():
		if invites[target].from == id:
			invites.erase(target)
	names.erase(id)


func _tell_group(gid: int, text: String) -> void:
	for member: String in groups.get(gid, {}).get("members", []):
		notice.emit(member, text)


func _name(id: String) -> String:
	return names.get(id, "Jemand")
