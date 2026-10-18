class_name Fighter
extends RefCounted
## Ein Teilnehmer im Kampf-Prototyp (Held oder Gegner) mit allen Werten,
## die die Klassen-Mechaniken aus design.md brauchen.

enum Shape { SQUARE, TRIANGLE, DIAMOND, STAR, CIRCLE, FANG, HEXAGON }

## So lange "dauert" ein Zug. Geteilt durch Tempo ergibt das den Abstand bis zum nächsten Zug.
const TURN_COST := 100.0
const MAX_ULT := 100.0
const MAX_BLOOD := 40
const MAX_RES := 5

var display_name: String
## Klassen-Kennung: tank, archer, ritualist, singer, slime, wolf, boss
var klass: String
var class_title: String
var is_hero: bool
var color: Color
var shape: Shape
var max_hp: int
var hp: int
var max_mana := 0
var mana := 0
var tempo: int
## true = hintere Reihe
var back_row := false
## Zeitpunkt des nächsten Zuges auf der Zugleiste (kleiner = früher dran).
var next_time := 0.0
## Reaktion bei Gegner-Angriffen: "" (keine), "parry" (Parieren) oder "dodge" (Ausweichen).
var reaction := ""
## Ult-Leiste 0–100, lädt nur durch die klassentypische Aktion.
var ult := 0.0
## Abklingzeiten: Fähigkeits-Kennung -> verbleibende eigene Züge.
var cooldowns := {}
var shield := 0
var atk_buff_turns := 0
var def_buff_turns := 0

# Magier-Tank
## Bann-Zeichen: so viele Einzelangriffe müssen noch auf den Tank gehen.
var taunt := 0
var fortress := false
var fortress_absorbed := 0

# Bogenschütze
var charged := false

# Ritualist
var blood := 0

# Sternensängerin: zwei Sternbilder und wie viele eigene Züge sie nicht gefüllt wurden
var res_off := 0
var res_def := 0
var off_idle := 0
var def_idle := 0

# Boss
var boss_step := 0
var intent := ""
var enraged := false


func _init(p_name: String, p_klass: String, p_title: String, p_hero: bool, p_hp: int, p_tempo: int, p_color: Color, p_shape: Shape) -> void:
	display_name = p_name
	klass = p_klass
	class_title = p_title
	is_hero = p_hero
	max_hp = p_hp
	hp = p_hp
	tempo = p_tempo
	color = p_color
	shape = p_shape


func is_alive() -> bool:
	return hp > 0


## Abstand bis zum nächsten Zug auf der Zugleiste.
func turn_delay() -> float:
	return TURN_COST / tempo


## Heilt und gibt zurück, wie viele LP tatsächlich geheilt wurden.
func heal(amount: int) -> int:
	if not is_alive():
		return 0
	var before := hp
	hp = mini(hp + amount, max_hp)
	return hp - before


func add_ult(amount: float) -> void:
	ult = minf(ult + amount, MAX_ULT)


func ult_ready() -> bool:
	return ult >= MAX_ULT


func cooldown(id: String) -> int:
	return cooldowns.get(id, 0)


func row_name() -> String:
	return "hinten" if back_row else "vorne"
