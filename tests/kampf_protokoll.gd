class_name KampfProtokoll
extends RefCounted
## Schreibt mit, was in einem automatischen Testkampf passiert (Log, Schwebetexte, Werte zu jedem Zug).
## Zwei Läufe mit demselben Startwert müssen genau dasselbe Protokoll ergeben.

const MAX_TURNS := 600

var lines: PackedStringArray = []


func log_text(text: String) -> void:
	lines.append("LOG " + text)


func float_text(f: Fighter, text: String) -> void:
	lines.append("TXT %s: %s" % [f.display_name, text])


## Werte aller Teilnehmer zu Beginn eines Zuges.
func turn(number: int, current: Fighter, everyone: Array[Fighter]) -> void:
	lines.append("ZUG %d %s" % [number, current.display_name])
	for f in everyone:
		lines.append("  %s %d/%d m%d u%.1f t%.3f s%d" % [f.display_name, f.hp, f.max_hp, f.mana, f.ult, f.next_time, f.shield_total()])


func finish(result: String, heroes: Array[Fighter]) -> void:
	lines.append("ENDE " + result)
	for h in heroes:
		lines.append("  %s Schaden %d Heilung %d Abgewehrt %d Erlitten %d Perfekt %d Ults %d" % [
			h.display_name, h.stat_damage, h.stat_heal, h.stat_blocked, h.stat_taken, h.stat_perfect, h.stat_ults])
