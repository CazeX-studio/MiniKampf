class_name LavaTakt
extends RefCounted
## Lava-Takt der Vulkanschmiede der Ketten (D32, design.md „Glutoase im Detail“, Sitzung 24):
## Die Lava steigt abwechselnd bei der vorderen und der hinteren Reihe der Helden und wird zwei Runden vorher
## angekündigt. Wer rechtzeitig die Reihe wechselt (kostet einen Zug), entgeht ihr.
## Eine Runde ist so lang wie ein Zug bei Tempo 10 (die Zugleiste kennt sonst keine Runden).

const RUNDE := 10.0
## Alle so viele Runden steigt die Lava (abwechselnd vorne und hinten)
const ABSTAND := 4
## Wie viele Runden vorher sie angekündigt wird
const VORWARNUNG := 2
## So viel ihres Lebens verliert jede Figur in der Reihe, in der die Lava steigt
const ANTEIL := 0.15

var c: BattleState
## Bis zu welcher Runde schon gerechnet ist
var runde := 0
## Reihe, in der die Lava gerade oben ist ("" = unten), und die angekündigte Reihe
var oben := ""
var angekuendigt := ""


func _init(p_combat: BattleState) -> void:
	c = p_combat


## Reihe, in der die Lava in Runde r steigt ("" = in dieser Runde nicht).
static func reihe_in_runde(r: int) -> String:
	if r < ABSTAND or r % ABSTAND != 0:
		return ""
	return "vorne" if (r / ABSTAND) % 2 == 1 else "hinten"


## Vor jedem Zug: Sind seit dem letzten Mal neue Runden angebrochen?
func vor_dem_zug(jetzt: float) -> void:
	var bis := int(jetzt / RUNDE) + 1
	while runde < bis:
		runde += 1
		_neue_runde(runde)


func _neue_runde(r: int) -> void:
	if oben != "":
		oben = ""
		c.add_log("Die Lava sinkt wieder.")
		c.zeige_lava("", "")
	var reihe := reihe_in_runde(r)
	if reihe != "":
		_steigen(reihe)
	var naechste := reihe_in_runde(r + VORWARNUNG)
	if naechste != "":
		angekuendigt = naechste
		var text := "Die Lava brodelt %s!" % ("vorne" if naechste == "vorne" else "hinten")
		c.banner(text)
		c.add_log("[color=#ff8a3d][b]%s[/b] In 2 Runden steigt sie dort. Wechsle die Reihe![/color]" % text)
		c.zeige_lava(naechste, "warnung")


func _steigen(reihe: String) -> void:
	oben = reihe
	angekuendigt = ""
	c.banner("Die Lava steigt %s!" % reihe)
	c.add_log("[color=#ff5a2a][b]Die Lava steigt %s![/b][/color]" % reihe)
	c.zeige_lava(reihe, "oben")
	for h in c.allies():
		if h.back_row == (reihe == "hinten") and c.on_field(h):
			c.float_text(h, "Lava!", Color("ff7a3d"), 40)
			c.apply_damage(h, maxi(1, roundi(h.max_hp * ANTEIL)), null, "magic")
	c.wait(0.6)
