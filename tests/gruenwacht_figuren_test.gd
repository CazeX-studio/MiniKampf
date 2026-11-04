extends SceneTree
## D21: Grünwacht-Figuren nach Steckbrief (NPC.md): eigene Bilder, Köpfe, Porträts, Plätze bei Tag und Nacht, Wirt Borko.
## Aufruf: Godot --headless --path . -s tests/gruenwacht_figuren_test.gd

const NEBEN := {"salbei": "grund_haendler+salbei#zubehoer=kraeuterbuendel&korb", "bank_wipfelheim": "grund_alter_mensch+tamm#hut=tamm_moos_hut",
	"oma_hagebutte": "grund_alter_mensch+hagebutte#zubehoer=kartenstapel", "kobalt": "zaehmer_m+kobalt",
	"borko": "grund_mann+borko#hut=borko_kochmuetze,zubehoer=schoepfkelle"}
const HAUPT := ["ysolde", "fenn", "tilda", "esche", "kael"]

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	world.nacht = false
	for npc: String in NEBEN:
		_check(world.npcs[npc].look == NEBEN[npc], "%s trägt %s" % [npc, NEBEN[npc]])
		for anim: String in ["idle_vorn", "idle_hinten", "run_vorn"]:
			_check(FigurTeile.bild(world.npcs[npc].look, anim, 0) != null, "%s lässt sich zeichnen (%s)" % [npc, anim])
	for npc: String in HAUPT:
		_check(world.npcs[npc].look == npc and ResourceLoader.exists(FighterView.sprite_path(npc, "run_hinten", 3)), "%s mit eigenen Bildern" % npc)
	for wer: String in ["Ysolde", "Fenn", "Tilda", "Esche", "Kael", "Salbei", "Borko", "Oma Hagebutte", "Kobalt"]:
		_check(WorldState.portraet({wer = wer}) != "", "Porträt von %s" % wer)
	_check(FighterView.look_data("kobalt").sprite == "zaehmer_m+kobalt" and FigurTeile.bild("zaehmer_m+kobalt", "idle", 0) != null,
			"Kobalt im Kampf mit eigenem Kopf")
	_check(not FigurTeile.passende_koepfe("zaehmer_m").has("kobalt"), "Kobalts Kopf nicht bei „Figur erstellen“")

	var p := world.add_player("a", "Test", "novize_m+m1", Vector2i(20, 20))
	world.change_map(p, "wipfelheim", Vector2i(24, 24))
	var tag: Vector2i = world.npcs.ysolde.cell
	_check(world._npc_present(p, "kobalt") and world._npc_present(p, "borko"), "Tags: Kobalt und Borko da")
	world.nacht = true
	_check(world.npcs.ysolde.cell == Vector2i(14, 26) and world.npcs.ysolde.cell != tag, "Nachts: Ysolde am Rand des Dorfs")
	_check(world.npcs.fenn.cell == Vector2i(21, 27) and world.npcs.oma_hagebutte.cell == Vector2i(7, 21), "Nachts: Fenn am Rand, Oma beim Gasthaus")
	_check(not world._npc_present(p, "kobalt"), "Nachts: Kobalt nicht zu sehen")
	world.start_dialog(p, "ysolde")
	_check(world.dialog_view(p).text.contains("Nachts hat der Wald andere Augen"), "Ysolde nachts")
	world.apply_command("a", {type = "dialog_next"})
	world.apply_command("a", {type = "dialog_next"})
	world.nacht = false
	_check(world.npcs.ysolde.cell == tag, "Morgens: Ysolde wieder auf der Hauptplattform")
	world.start_dialog(p, "borko")
	_check(world.dialog_view(p).wer == "Borko" and WorldState.portraet(world.dialog_view(p)).ends_with("borko_wuetend.png"), "Borko brummt")
	Tageszeit.feste_stunde = -1.0
	print("Grünwacht-Figuren: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
