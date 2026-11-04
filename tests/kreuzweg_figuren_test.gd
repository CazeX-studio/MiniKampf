extends SceneTree
## D20c: Kreuzweg-Figuren nach Steckbrief (eigene Köpfe auf Baukasten-Körpern, Bingo, Marv, Mira) und ihre Porträts.
## Aufruf: Godot --headless --path . -s tests/kreuzweg_figuren_test.gd

const NEBEN := {"schreiberin": "grund_gelehrter+lene", "hanne": "grund_frau+hanne", "bank_kreuzweg": "grund_alter_mensch+ilse",
	"edmar": "grund_mann+edmar", "wache": "grund_wache+brom", "quill": "grund_handwerker+quill", "pip": "grund_kind+pip",
	"lotte": "grund_kind+lotte"}
const HAUPT := {"bingo": "bingo", "marv": "marv", "marv_fest": "marv", "marv_abschied": "marv", "mira": "mira"}

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	Tageszeit.feste_stunde = 12.0
	var world := WorldState.new()
	for npc: String in NEBEN:
		var look: String = NEBEN[npc]
		_check(world.npcs[npc].look == look, "%s trägt %s" % [npc, look])
		for anim: String in ["idle_vorn", "idle_hinten", "run_vorn", "run_hinten"]:
			_check(FigurTeile.bild(look, anim, 0) != null, "%s lässt sich zeichnen (%s)" % [npc, anim])
	for npc: String in HAUPT:
		_check(world.npcs[npc].look == HAUPT[npc] and ResourceLoader.exists(FighterView.sprite_path(HAUPT[npc], "run_hinten", 3)),
				"%s mit eigenen Bildern" % npc)
	_check(ResourceLoader.exists(FighterView.sprite_path("mira", "liegen", 1)), "Mira liegend (für später)")
	for wer: String in ["Lene", "Hanne", "Ilse", "Edmar", "Brom", "Quill", "Pip", "Lotte", "Bingo", "Marv", "Mira"]:
		_check(WorldState.portraet({wer = wer}) != "", "Porträt von %s" % wer)
	_check(WorldState.portraet({wer = "Hanne", stimmung = "ruhig"}).ends_with("hanne_laechelnd.png"), "Fehlende Stimmung: die nächstbeste")
	_check(WorldState.portraet({wer = "Quill", stimmung = "traurig"}).ends_with("quill_traurig.png"), "Quill traurig")
	Tageszeit.feste_stunde = -1.0
	print("Kreuzweg-Figuren: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
