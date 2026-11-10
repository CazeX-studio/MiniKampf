extends SceneTree
## D20c und D20c2: Kreuzweg-Figuren nach Steckbrief (eigene Köpfe auf Baukasten-Körpern, Bingo, Marv, Mira) und ihre Porträts.
## Aufruf: Godot --headless --path . -s tests/kreuzweg_figuren_test.gd

const NEBEN := {"schreiberin": "grund_gelehrter+lene", "hanne": "grund_frau+hanne#zubehoer=schuerze&kochloeffel",
	"edmar": "grund_mann+edmar#zubehoer=amtskette",
	"wache": "grund_wache+brom#hut=brom_helm", "quill": "grund_handwerker+quill#zubehoer=meissel",
	"pip": "grund_kind+pip#zubehoer=holzschwert", "lotte": "grund_kind+lotte#hut=lotte_krone"}
const HAUPT := {"bank_kreuzweg": "ilse", "bingo": "bingo", "marv": "marv", "marv_fest": "marv", "marv_abschied": "marv", "mira": "mira"}

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

	# D20c2: Zubehör liegt auf dem Körper
	for look: String in ["grund_frau+hanne#zubehoer=schuerze&kochloeffel", "grund_mann+edmar#zubehoer=amtskette"]:
		for anim: String in ["idle_vorn", "idle_hinten"]:
			var mit := FigurTeile.bild(look, anim, 0).get_image()
			var ohne := FigurTeile.bild(FigurTeile.ohne_aussehen(look), anim, 0).get_image()
			_check(mit.get_size() == ohne.get_size() and mit.get_data() != ohne.get_data(), "Zubehör sichtbar: %s %s" % [look, anim])
	_check(FigurTeile.hut_belohnung("brom_helm") and FigurTeile.hut_belohnung("lotte_krone"), "Helm und Krone kann man nicht einfach wählen")

	# Tessa und Gorm: eigene Köpfe auf den Novizen-Körpern, auch im Kampf, aber nicht bei „Figur erstellen“
	for wer: String in ["tessa", "gorm"]:
		var sprite: String = FighterView.look_data("novize_" + wer).sprite
		_check(sprite.ends_with("+" + wer), "%s im Kampf mit eigenem Kopf" % wer)
		for anim: String in ["idle", "attack", "parry", "death", "idle_vorn", "idle_hinten"]:
			_check(FigurTeile.bild(sprite, anim, 0) != null, "%s: %s" % [wer, anim])
		_check(WorldState.portraet({wer = wer.capitalize()}) != "", "Porträt von %s" % wer)
	_check(not FigurTeile.passende_koepfe("novize_w").has("tessa") and not FigurTeile.passende_koepfe("novize_m").has("gorm")
			and FigurTeile.passende_koepfe("novize_m")[0] == "m1", "Tessa und Gorm stehen nicht bei „Figur erstellen“")

	# Mira kann liegen (für das Krankenzelt in der Glutoase)
	var mira := WorldCharacter.new()
	mira.setup("mira", "Mira")
	mira.liegt = true
	mira._process(0.1)
	_check(mira._sprite.texture.resource_path.contains("mira_liegen"), "Mira liegt")
	mira.free()
	Tageszeit.feste_stunde = -1.0
	print("Kreuzweg-Figuren: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
