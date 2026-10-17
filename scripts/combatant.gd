class_name Combatant
extends RefCounted
## Ein Kampfteilnehmer (Held oder Boss) mit Lebenspunkten und Bedrohung.

enum Role { TANK, HEALER, DPS, BOSS }

var display_name: String
var role: Role
var max_hp: int
var hp: int
## Bedrohung (Aggro): Der Boss greift den lebenden Helden mit der höchsten Bedrohung an.
var threat := 0.0
## Schildblock aktiv: erlittener Schaden wird diese Runde halbiert.
var blocking := false


func _init(p_name: String, p_role: Role, p_max_hp: int) -> void:
	display_name = p_name
	role = p_role
	max_hp = p_max_hp
	hp = p_max_hp


func is_alive() -> bool:
	return hp > 0


func take_damage(amount: int) -> void:
	hp = maxi(hp - amount, 0)


## Heilt und gibt zurück, wie viele LP tatsächlich geheilt wurden.
func heal(amount: int) -> int:
	if not is_alive():
		return 0
	var before := hp
	hp = mini(hp + amount, max_hp)
	return hp - before


func role_name() -> String:
	match role:
		Role.TANK:
			return "Tank"
		Role.HEALER:
			return "Heiler"
		Role.DPS:
			return "Schaden"
		Role.BOSS:
			return "Boss"
	return ""
