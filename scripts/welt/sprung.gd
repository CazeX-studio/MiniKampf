class_name Sprung
extends RefCounted
## Spielstand-Editor (S5): an eine Stelle der Geschichte springen. Alle Hauptaufträge davor gelten als erledigt
## (mit allem, was sie sich merken), der gewählte steht als nächster an: Hat er einen Auftraggeber, steht man
## vor ihm und er hat ein „!“; sonst ist er gleich aktiv und man steht dort, wo es weitergeht.
## Der Weg hängt von der Klasse ab (S1b): Glutoase-Klassen zuerst in die Glutoase, Bogenschütze und Zähmer erst nach
## Grünwacht (Klasse lernen), dann Glutoase, zum Schluss für alle der zweite Teil von Grünwacht.
## Entscheidungen der Geschichte (Hirsch, Urbaum, Mira …) gelten als mit der ersten Antwort getroffen.

const KREUZWEG: Array[String] = ["zu_ye", "erster_auftrag", "grundausbildung", "erster_gruppenkampf", "gesandte",
		"korb_fuer_die_wache", "leises_singen", "fest", "sternenfall", "abreise"]
const GLUTOASE: Array[String] = ["nach_glutoase", "kochende_brunnen", "miras_lied", "fest_der_glut", "rivale_kael",
		"die_ketten", "miras_splitter", "rueckkehr_gruenwacht"]
const GRUENWACHT_2: Array[String] = ["veraenderte_tiere", "der_fremde", "das_leere_grab", "der_urbaum", "die_wahrheit"]
## Klassen der Demo (mit Lehrmeister) und wo sie anfangen
const KLASSEN_GRUENWACHT: Array[String] = ["archer", "tamer"]
const KLASSEN_GLUTOASE: Array[String] = ["smith", "blade", "singer"]
## Was sich die Geschichte unterwegs in Gesprächen merkt (nicht als Ziel eines Auftrags): gilt, wenn der Auftrag erledigt ist.
## „angesprochen:…“: Figuren, die einen von selbst ansprechen, haben das schon getan.
const MERKEN_ERLEDIGT := {
	"zu_ye": ["angekommen", "gilde_angemeldet", "bei_ye_gemeldet"],
	"erster_auftrag": ["ausbildung_morgen"],
	"erster_gruppenkampf": ["gesandte_angekuendigt"],
	"gesandte": ["gesandte_bedankt"],
	"leises_singen": ["mira_getroffen", "angesprochen:mira"],
	"fest": ["marv_fest", "angesprochen:marv", "angesprochen:marv_fest"],
	"sternenfall": ["sternenfall", "ren_getroffen", "abreise_angekuendigt", "angesprochen:ren"],
	"abreise": ["klasse_bestaetigt"],
	"klasse_lernen": ["klasse_gelernt"],
	"fenns_pruefung": ["pruefung_hirsch", "hirsch_geschossen"],
	"esches_monster": ["starter_moosling", "starter_gewaehlt"],
	"veraenderte_tiere": ["entscheidung_jaeger"],
	"der_fremde": ["kael_getroffen", "angesprochen:kael"],
	"das_leere_grab": ["erinnerung_rowan"],
	"der_urbaum": ["urbaum_gefaellt"],
	"die_wahrheit": ["wahrheit_wipfelheim"],
	"miras_splitter": ["mira_geheilt"],
}
## Gilt, solange der Auftrag gerade ansteht (die Festnacht)
const MERKEN_ANSTEHEND := {"sternenfall": ["nacht", "marv_fest"]}
## Was bei einem Sprung erhalten bleibt (Sammlungen, nicht die Geschichte)
const BEHALTEN: Array[String] = ["karten", "titel"]


## Hauptaufträge in der Reihenfolge, in der man sie mit dieser Klasse spielt ("" = noch keine Klasse: nur Kreuzweg).
static func pfad(klasse: String) -> Array[String]:
	var liste: Array[String] = KREUZWEG.duplicate()
	if klasse in KLASSEN_GRUENWACHT:
		liste.append_array(["nach_gruenwacht", "klasse_lernen"])
		liste.append_array(["fenns_pruefung"] if klasse == "archer" else ["esches_monster", "tildas_unterricht"])
		liste.append("bericht_ysolde")
		liste.append_array(GLUTOASE)
		liste.append_array(GRUENWACHT_2)
	elif klasse != "":
		liste.append_array(["nach_glutoase", "klasse_lernen"])
		liste.append_array(GLUTOASE.slice(1))
		liste.append_array(GRUENWACHT_2)
	return liste


## Anzeigename eines Sprungpunkts, mit dem Gebiet davor
static func titel(auftrag: String) -> String:
	var gebiet := "Kreuzweg"
	if auftrag in GRUENWACHT_2 or auftrag in ["nach_gruenwacht", "fenns_pruefung", "esches_monster", "tildas_unterricht", "bericht_ysolde"]:
		gebiet = "Grünwacht"
	elif auftrag in GLUTOASE:
		gebiet = "Glutoase"
	elif auftrag == "klasse_lernen":
		gebiet = "Klasse"
	return "%s: %s" % [gebiet, GameData.quest(auftrag).get("titel", auftrag)]


## Springt mit dem Spieler an den Auftrag „ziel“ (aus pfad(klasse)). Stufe, Gold und Tasche bleiben.
static func springen(world: WorldState, p: PlayerState, ziel: String, klasse: String) -> void:
	var weg := pfad(klasse)
	var bis := weg.find(ziel)
	if bis < 0:
		return
	var flags := {}
	for f: String in p.progress.flags:
		if f in BEHALTEN or f.begins_with("karten_gesehen:"):
			flags[f] = p.progress.flags[f]
	var quests := {"ankunft": "abgegeben"}
	for i in bis:
		var q := weg[i]
		quests[q] = "abgegeben"
		for ziel_info: Dictionary in GameData.quest(q).get("ziele", []):
			if ziel_info.has("merken"):
				flags[ziel_info.merken] = true
		for f: String in MERKEN_ERLEDIGT.get(q, []):
			flags[f] = true
	# Hadrak schickt einen am Ende der Glutoase zurück: der Weg nach Grünwacht gilt dann als gegangen
	if quests.has("rueckkehr_gruenwacht") or (quests.has("miras_splitter") and not klasse in KLASSEN_GRUENWACHT):
		quests["nach_gruenwacht"] = "abgegeben"
	if klasse != "" and bis > weg.find("abreise"):
		flags["klasse"] = klasse
		flags["klasse_gewaehlt"] = true
	if flags.has("sternenfall"):
		flags.erase("nacht")
	var info := GameData.quest(ziel)
	var geber := str(info.get("start_bei", ""))
	quests[ziel] = "neu" if geber != "" else "aktiv"
	for f: String in MERKEN_ANSTEHEND.get(ziel, []):
		flags[f] = true
	p.progress.quests = quests
	p.progress.flags = flags
	p.dialog = {}
	p.path.clear()
	world._update_quests(p)
	# Hinstellen: vor den Auftraggeber, sonst dorthin, wo das erste Ziel wartet
	var npc := geber
	if npc == "":
		for z: Dictionary in info.get("ziele", []):
			npc = str(z.get("bei", z.get("npc", (z.get("wegweiser", [""]) as Array)[0] if z.has("wegweiser") else "")))
			if npc != "":
				break
	if npc == "" or not world.npcs.has(npc):
		npc = str(info.get("abgeben_bei", ""))
	if world.npcs.has(npc):
		var n: Dictionary = world.npcs[npc]
		world.change_map(p, n.map, frei_neben(world, n.map, n.cell))
	else:
		world.change_map(p, WorldState.KREUZWEG, WorldState.start_cell())


## Ein begehbares Feld möglichst nah an einem Feld (vor der Figur, nicht auf ihr)
static func frei_neben(world: WorldState, karte: String, feld: Vector2i) -> Vector2i:
	for r in range(1, 6):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var c := feld + Vector2i(dx, dy)
				if world.is_walkable(c, karte):
					return c
	return world.get_map(karte).start
