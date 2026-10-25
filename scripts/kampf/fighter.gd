class_name Fighter
extends RefCounted
## Ein Teilnehmer im Kampf (Held, Begleiter oder Gegner) mit allen Werten,
## die die Klassen-Mechaniken aus design.md brauchen.

## So lange "dauert" ein Zug. Geteilt durch Tempo ergibt das den Abstand bis zum nächsten Zug.
const TURN_COST := 100.0
const MAX_ULT := 100.0
const MAX_BLOOD := 40
const MAX_RES := 5
const MAX_BLADES := 5
const MAX_HARD := 5
const MAX_BALANCE := 5
const MAX_SEALS := 2

var display_name: String
## Kennung: Klasse (tank, archer …), Begleiter (robot, moosling …) oder Gegner-Art (glutkobold, boss …)
var klass: String
var class_title: String
## Welche Pixel-Figur gezeigt wird ("" = die der Klasse), z. B. für Novizen-Mitstreiter
var look := ""
var is_hero: bool
## Begleiter (Roboter, Monster) kämpfen für einen Helden ("owner").
var owner: Fighter
var color: Color
var element := ""
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
## Schilde: wer den Schild gegeben hat -> verbleibende Stärke (für die Auswertung).
var shields := {}
var atk_buff_turns := 0
var def_buff_turns := 0
## Verwundbar: bekommt mehr Schaden (Wertgutachten, Bohrer, Treibjagd).
var vuln_turns := 0
## Rauch / Schleier: so viele Angriffe verfehlen noch.
var smoke := 0
var smoke_source: Fighter
## Bedrohung: so viele Einzelangriffe müssen noch auf diese Figur gehen.
var taunt := 0
## Gegner kann nicht als Ziel gewählt werden (nur für Bank-Monster).
var on_bench := false

# Auswertung (für Begleiter zählt alles beim Besitzer)
var stat_damage := 0
var stat_heal := 0
var stat_blocked := 0
var stat_taken := 0
var stat_perfect := 0
var stat_ults := 0

# Magier-Tank
var fortress := false
var fortress_absorbed := 0

# Mechaniker: Roboter; Roboter: wen er beschützt
var robot: Fighter
var protecting: Fighter

# Rüstungsschmied: aktuelle Rüstung (melee / magic / ranged) und Härte
var armor := "melee"
var hard := 0

# Bogenschütze
var charged := false

# Klingentänzerin: Klingen, letzte Tanzschritte, Züge mit Feuer-Klingen
var blades := 0
var dance: Array[String] = []
var fire_turns := 0
## Sternentanz: so viele eigene Züge treffen die Klingen mit Sternenkraft
var star_turns := 0

# Zwielicht-Wandler: -5 (Schatten) bis +5 (Licht), letzte Seite für das Überqueren der Mitte
var balance := 0
var last_side := 0

# Monster-Zähmer: alle Monster und das kämpfende
var monsters: Array[Fighter] = []
var active_monster: Fighter

# Ritualist
var blood := 0

# Quartiermeister
var gold := 0
var gold_spent := 0
var cart_hp := 0
var cart_max := 0
var wares := {}

# Sternensängerin: zwei Sternbilder und wie viele eigene Züge sie nicht gefüllt wurden
var res_off := 0
var res_def := 0
var off_idle := 0
var def_idle := 0

## Angriffs-Faktor aus den Grundwerten (Novize in der Kreuzweg-Demo): mehr Schaden und Heilung pro Stufe
var power := 1.0

# Gegner
var resist := 1.0
## Großer Gegner (Boss): größeres Namensschild unter der Figur
var big := false
## Hat keinen eigenen Zug (z. B. Splitter-Knoten der Wurzelmutter)
var passive := false
## Geblendet: macht weniger Schaden
var blind_turns := 0
## Aufgeladener Splitterstaub (Glimmerkäfer)
var charge := 0
## Hält das Splitterlicht (Vorbote, Zusammenspiel „Das letzte Licht“) und wie lange schon
var light := false
var light_turns := 0
var seals: Array[String] = []
var step := 0
var intent := ""
var enraged := false
## Sternenpanzer (Sternenfresser): Schaden-Faktor, solange er nicht erschüttert ist (1.0 = kein Panzer)
var plate := 1.0
## So viele eigene Züge ist der Panzer nach einer perfekten Parade noch offen
var stagger_turns := 0
var stagger_length := 2
## Tödliche Angriffe (Sternenfresser): Ohne perfekte Parade fällt das Ziel sofort, normal pariert kostet es 90 % des Lebens
var deadly := false
## Abwarten: bis zum nächsten eigenen Zug weniger Schaden (und danach früher wieder dran)
var waiting := false


func _init(p_name: String, p_klass: String, p_title: String, p_hero: bool, p_hp: int, p_tempo: int, p_color: Color) -> void:
	display_name = p_name
	klass = p_klass
	class_title = p_title
	is_hero = p_hero
	max_hp = p_hp
	hp = p_hp
	tempo = p_tempo
	color = p_color


func is_alive() -> bool:
	return hp > 0


## Steht auf der Seite der Helden (Held oder Begleiter).
func is_ally() -> bool:
	return is_hero or owner != null


## Wem die Werte für die Auswertung gutgeschrieben werden.
func credit() -> Fighter:
	return owner if owner != null else self


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


func shield_total() -> int:
	var total := 0
	for amount: int in shields.values():
		total += amount
	return total


func add_shield(source: Fighter, amount: int) -> void:
	shields[source] = shields.get(source, 0) + amount


func row_name() -> String:
	return "hinten" if back_row else "vorne"


## Schlüssel für das Aussehen (FighterView.LOOKS).
func look_key() -> String:
	return look if look != "" else klass
