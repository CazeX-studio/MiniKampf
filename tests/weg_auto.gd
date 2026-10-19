extends "res://scripts/welt/kreuzweg.gd"
## Kreuzweg: Korb zur Wache am zugewachsenen Weg, Mira spricht dich an (für Bildschirmfotos).

var _t := 0.0
var _step := 0


func _ready() -> void:
	var p := PlayerState.new("spieler", "Du", "elf_m", Vector2i(13, 12))
	p.progress.quests = {ankunft = "abgegeben", zu_ye = "abgegeben", erster_auftrag = "abgegeben",
		grundausbildung = "abgegeben", erster_gruppenkampf = "abgegeben", marvs_traum = "abgegeben", gesandte = "abgegeben",
		korb_fuer_die_wache = "aktiv"}
	p.progress.flags = {"angekommen": true, "gilde_angemeldet": true, "ausbildung_morgen": true, "angesprochen:marv": true, "probestunde_gemacht": true, "gesandte_bedankt": true}
	p.progress.xp = 700
	p.progress.level = 5
	p.progress.gold = 75
	p.progress.items = {heiltrank = 3, essenskorb = 1}
	SaveGame.save(p)
	super()


func _process(delta: float) -> void:
	_t += delta
	var plan: Array = [
		[0.5, func() -> void: state.apply_command(LOCAL_ID, {type = "talk", npc = "wache"})],
		[5.5, func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_choose", index = 0})],
		[6.0, func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_choose", index = 1})],
		[6.5, func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_next"})],
		[7.5, func() -> void: state.apply_command(LOCAL_ID, {type = "dialog_next"})],
	]
	while _step < plan.size() and _t >= plan[_step][0]:
		plan[_step][1].call()
		_step += 1
	super(delta)


func _exit_tree() -> void:
	_no_save = true
	SaveGame.delete()
