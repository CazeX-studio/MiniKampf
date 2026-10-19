extends "res://scripts/welt/kreuzweg.gd"
## Kreuzweg nach der Grundausbildung: Ye am Tor, die Gesandten, Gespräch mit vielen Antworten (für Bildschirmfotos).

var _t := 0.0
var _step := 0


func _ready() -> void:
	var p := PlayerState.new("spieler", "Du", "elf_m", Vector2i(11, 19))
	p.progress.quests = {ankunft = "abgegeben", zu_ye = "abgegeben", erster_auftrag = "abgegeben",
		grundausbildung = "abgegeben", erster_gruppenkampf = "abgegeben"}
	p.progress.flags = {"angekommen": true, "gilde_angemeldet": true, "ausbildung_morgen": true, "angesprochen:marv": true}
	p.progress.xp = 700
	p.progress.level = 5
	p.progress.gold = 75
	p.progress.items = {heiltrank = 3}
	SaveGame.save(p)
	super()


func _process(delta: float) -> void:
	_t += delta
	var plan: Array = [
		[2.5, func() -> void: state.apply_command(LOCAL_ID, {type = "talk", npc = "gesandte_glutoase"})],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
