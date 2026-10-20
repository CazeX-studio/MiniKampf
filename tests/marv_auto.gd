extends "res://scripts/welt/kreuzweg.gd"
## Kreuzweg nach der Grundausbildung: Marv spricht dich an, Bingos Laden (für Bildschirmfotos).

var _t := 0.0
var _step := 0


func _ready() -> void:
	var p := PlayerState.new("spieler", "Du", "elf_m", Vector2i(22, 38))
	p.progress.quests = {ankunft = "abgegeben", zu_ye = "abgegeben", erster_auftrag = "abgegeben",
		grundausbildung = "abgegeben", erster_gruppenkampf = "abgegeben"}
	p.progress.flags = {angekommen = true, gilde_angemeldet = true, ausbildung_morgen = true}
	p.progress.xp = 700
	p.progress.level = 5
	p.progress.gold = 75
	p.progress.items = {heiltrank = 3}
	SaveGame.save(p)
	super()


func _process(delta: float) -> void:
	_t += delta
	var choose := func(i: int) -> void: state.apply_command(LOCAL_ID, {type = "dialog_choose", index = i})
	var plan: Array = [
		[0.5, func() -> void: state.apply_command(LOCAL_ID, {type = "move", cell = Vector2i(22, 32)})],
		[3.5, choose.bind(0)],
		[4.0, choose.bind(0)],
		[4.5, func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_next"})],
		[5.0, func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_next"})],
		[5.5, func() -> void: state.apply_command(LOCAL_ID, {type = "talk", npc = "bingo"})],
		[9.0, choose.bind(0)],
		[9.5, func() -> void: state.apply_command(LOCAL_ID, {type = "kaufen", gegenstand = "sternentafel"})],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
