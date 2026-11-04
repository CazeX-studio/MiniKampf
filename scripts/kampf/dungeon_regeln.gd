class_name DungeonRegeln
extends RefCounted
## Grundlage für die Boss-Mechaniken eines Dungeons (Pilzhöhle, Vulkanschmiede). Der Kampf ruft diese Stellen auf;
## jeder Dungeon überschreibt, was er braucht. Mechaniken setzen keine bestimmte Klasse voraus (design.md).

var c: BattleState


func _init(p_combat: BattleState) -> void:
	c = p_combat


## Steuert dieser Dungeon den Zug dieses Gegners selbst?
func handles(_e: Fighter) -> bool:
	return false


func on_wave(_index: int) -> void:
	pass


func intent(_e: Fighter) -> String:
	return ""


func enemy_turn(_e: Fighter) -> void:
	pass


func check_phase() -> void:
	pass


func final_choice() -> void:
	pass


func absorbs(_target: Fighter, _amount: int, _source: Fighter) -> bool:
	return false


func on_hit(_attacker: Fighter, _target: Fighter, _element: String, _lost: int) -> void:
	pass


## Aktionen, die jeder Held in diesem Kampf zusätzlich hat (z. B. Laterne entzünden).
func extra_abilities(_f: Fighter) -> Array[Dictionary]:
	return []


func execute(_f: Fighter, _ab: Dictionary, _target: Fighter) -> void:
	pass


func _find(klass: String) -> Fighter:
	for e in c.enemies:
		if e.klass == klass:
			return e
	return null
