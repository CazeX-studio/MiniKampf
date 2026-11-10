extends SceneTree
## A9b: Zahlen der Dungeon-Bosse prüfen (wie der Probe-Lauf im Kampf-Editor). Der Computer spielt die Kämpfe
## einmal mit und einmal ohne die Mechaniken (Anker, Laternen, Licht weiterreichen, Kette, Bruder stören, Wolken).
## Bei den Endbossen heißt „ohne“: nur in Phase 2 ohne Mechanik (Phase 1 wie gewohnt).
## Kein Test, nur zum Messen: Godot --headless --path . -s tests/boss_probe.gd [-- <Anzahl>]

const KAEMPFE: Array[String] = ["pilz_koenigin", "pilz_urbaum", "hammerbrueder", "kettenschmied"]
const KLASSEN: Array[String] = ["blade", "smith", "singer", "archer", "tamer"]


func _gruppe(klasse: String, begleiter: int) -> Array:
	var g: Array = [{klasse = klasse, stufe = 20}]
	for i in 3:
		g.append({klasse = "novize" if i < begleiter else "", stufe = 20})
	return g


func _lauf(id: String, klasse: String, begleiter: int, mechanik: int, n: int) -> Dictionary:
	var a := KampfEditor.standard()
	a.art = "spiel"
	a.kampf = id
	a.gruppe = _gruppe(klasse, begleiter)
	a.traenke = 3
	var s := KampfEditor.setup_bauen(a)
	KampfKI.ohne_mechanik = mechanik
	var siege := 0
	var phase2 := 0
	var zuege := 0
	for i in n:
		var k := ProbeKampf.new()
		k.start_seed = i + 1
		k.setup = s.duplicate(true)
		root.add_child(k)
		if k.state.won:
			siege += 1
		zuege += k.state.turns
		var d := k.state.dungeon
		if (d is Pilzhoehle and (d as Pilzhoehle).phase2) or (d is Vulkanschmiede and (d as Vulkanschmiede).ks.phase2):
			phase2 += 1
		if d is Vulkanschmiede and (d as Vulkanschmiede).ks.phase2 and OS.get_environment("PROBE_DEBUG") != "":
			var ks := (d as Vulkanschmiede).ks
			print("   %s Panzer %d Lava %d %s" % [klasse, ks.panzer, ks.lava_stufe, "Sieg" if k.state.won else "verloren"])
		root.remove_child(k)
		k.free()
	KampfKI.ohne_mechanik = 0
	return {siege = siege, phase2 = phase2, zuege = zuege / maxi(1, n)}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var n := 12
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		n = int(args[0])
	var nur := args[1] if args.size() > 1 else ""
	for id in KAEMPFE:
		if nur != "" and not id.contains(nur):
			continue
		print("\n== %s (%d Kämpfe je Zeile) ==" % [id, n])
		for begleiter in [0, 2]:
			var mit_sum := 0
			var ohne_sum := 0
			var zeile: PackedStringArray = []
			for klasse in KLASSEN:
				var mit := _lauf(id, klasse, begleiter, 0, n)
				var ohne := _lauf(id, klasse, begleiter, 2 if id in ["pilz_urbaum", "kettenschmied"] else 1, n)
				mit_sum += mit.siege
				ohne_sum += ohne.siege
				zeile.append("%s %d/%d (Ph2 %d) ohne %d" % [klasse, mit.siege, n, mit.phase2, ohne.siege])
			print("%s: mit Mechanik %d %%, ohne %d %%  |  %s" % ["allein" if begleiter == 0 else "zu dritt",
					roundi(100.0 * mit_sum / (n * KLASSEN.size())), roundi(100.0 * ohne_sum / (n * KLASSEN.size())), " · ".join(zeile)])
	quit(0)
