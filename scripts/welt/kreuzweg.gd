extends Node2D
## Kreuzweg-Demo (Lernprojekt 3) und Grünwacht (Lernprojekt 5): Welt schräg von oben, Laufen, Gespräche mit Antworten,
## Aufträge, Gold, Tasche, Erfahrung und Stufen, Speichern. Gezeigt wird immer die Karte, auf der der eigene Spieler steht
## (Kreuzweg, der Weg nach Grünwacht, Waldboden, Wipfelheim); wechselt er die Karte, wird sie neu aufgebaut.
## Dieses Skript ist nur die Anzeige: Es zeichnet den Zustand aus WorldState und
## schickt Befehle. Allein läuft ein zweiter Spieler („Testgefährte“) zur Probe mit,
## gesteuert über genau dieselben Befehle. Beim Zusammenspielen (Netz) kommen die Befehle
## echter Mitspieler beim Gastgeber an, und die Welt hier ist die des Gastgebers bzw. ihr Spiegelbild.
## Alle Texte stehen in res://data (siehe data/LIESMICH.md).

## Eigene Spielfigur beim Alleinspielen (Bilder in assets/figuren/)
const PLAYER_LOOK := "vega"
const TILE_W := 64.0
const TILE_H := 32.0
const BOT_ID := "gefaehrte"

const TILE_COLORS := {
	WorldState.Tile.GRASS: [Color("3f6b3a"), Color("456f3d")],
	WorldState.Tile.ROAD: [Color("8a7556"), Color("837052")],
	WorldState.Tile.PLAZA: [Color("9d9585"), Color("948c7c")],
	WorldState.Tile.OVERGROWN: [Color("2f4d2a"), Color("3a5a2e")],
	WorldState.Tile.FOREST: [Color("33502c"), Color("37552f")],
	WorldState.Tile.PLANKS: [Color("8a6440"), Color("805c3a")],
	WorldState.Tile.BRIDGE: [Color("a07a4c"), Color("987246")],
	WorldState.Tile.CANOPY: [Color("1f3a1f"), Color("244222")],
	WorldState.Tile.CAVE: [Color("3a3240"), Color("362e3c")],
	WorldState.Tile.ROCK: [Color("1c1820"), Color("201b24")],
}

# Steuerung: Steuerknopf und Aktions-Knopf fürs Handy
const STICK_RADIUS := 70.0
const STICK_DEADZONE := 12.0
const STICK_HOME := Vector2(170, 560)
const NOTICE_SECONDS := 3.5
## Farbe der Nebenaufträge (wie das blaue „!“ und „?“)
const SIDE_COLOR := Color("5ab8ff")
## Meldungen mit Rahmen: [Vorlage in data/texte.json, Rahmenfarbe, Symbol]. Reihenfolge zählt
## („+%d Gold“ und „+%d Erfahrung“ vor „+%d %s“ für Gegenstände).
const NOTICE_STYLES: Array[Array] = [
	["gold", "gold", "gold"], ["gold_weg", "gold", "gold"], ["zu_wenig_gold", "gold", "gold"],
	["erfahrung", "lila", "kristall"], ["stufe", "lila", "kristall"], ["erfolg", "lila", "kristall"],
	["gegenstand", "gruen", "tasche"], ["gegenstand_weg", "gruen", "tasche"],
	["auftrag_neu", "gold", "ausrufe"], ["nebenauftrag_neu", "gold", "ausrufe"],
	["auftrag_fertig", "gold", "frage"], ["auftrag_abgegeben", "gruen", "kaestchen_an"],
	["kampf_gewonnen", "gruen", "schwert"], ["karten_sieg", "gruen", "schwert"], ["karte_neu", "lila", "schluessel"],
	["rudel_neu", "gruen", "schild"], ["ruf_aenderung", "lila", "schild"],
]
## Dinge, die Figuren verdecken können, und welche Fläche sie über ihrem Fußpunkt bedecken (werden dann durchsichtig)
const OCCLUDER_RECTS := {
	"tree": Rect2(-26, -70, 52, 72), "stand": Rect2(-32, -64, 64, 66), "stamm": Rect2(-40, -160, 80, 162),
	"riesenbaum": Rect2(-58, -272, 116, 274), "riesenpilz": Rect2(-36, -70, 72, 72),
}
## F gedrückt halten: erst nach dieser Pause, dann in diesem Takt weiterblättern (Sekunden)
const SKIP_FIRST_DELAY := 0.35
const SKIP_REPEAT := 0.12
## NPCs stehen ruhiger als Spieler (langsamere Steh-Animation)
const NPC_IDLE_FPS := 2.0
## NPC-Namen: bis zu dieser Entfernung (Felder) voll sichtbar, ab der zweiten ganz ausgeblendet
const NAME_FADE_START := 4.0
const NAME_FADE_END := 6.5
const NIGHT_COLOR := Color(0.45, 0.5, 0.78)
## Farben der fünf Festlaternen (eine pro Region)
const LANTERN_COLORS: Array[Color] = [Color("b8b0ff"), Color("e0a060"), Color("ffb070"), Color("a8e088"), Color("ffb8d8")]

## Welche Dinge leuchten: Art -> [Lichtart (siehe Licht.ARTEN), Höhe der Flamme über dem Boden]
const PROP_LIGHTS := {
	"lantern": ["laterne", Vector2(0, -60)],
	"strassenlaterne": ["laterne", Vector2(0, -62)],
	"fackel": ["fackel", Vector2(0, -44)],
	"lagerfeuer": ["lagerfeuer", Vector2(0, -12)],
	"riesenpilz": ["pilz", Vector2(0, -34)],
}
## Haus mit glühender Esse hinter der Tür
const FORGE := "Schmiede"
const PICKUP_LIGHTS := {
	"urbaum_herz": ["splitter", Vector2(0, -40)],
	"grab": ["splitter", Vector2(12, 0)],
	"splittertier": ["splitter", Vector2(0, -22)],
	"silberhirsch": ["silber", Vector2(0, -26)],
	"hoehle": ["pilz", Vector2(0, -8)],
}

var state: WorldState
## Kennung des eigenen Spielers (beim Zusammenspielen vom Netz vergeben)
var local_id := "spieler"

var _ground: Node2D
var _objects: Node2D
var _characters := {}
## Sammelpunkt-Ziel ("punkt:0") und Ort ("ort:0") -> Grafik
var _pickup_nodes := {}
## Schmuck-Grafik -> Bedingung, wann sie zu sehen ist
var _deco_nodes := {}
## Alles, was zur gerade gezeigten Karte gehört (Häuser, Kleinkram, NPCs …); wird beim Kartenwechsel ersetzt
var _map_nodes: Array[Node] = []
## Karte, die gerade gezeigt wird
var _shown_map := ""
## Färbt die Welt nachts dunkelblau (Fest der fünf Wege)
var _night: CanvasModulate
var _flash_rect: ColorRect
var _camera: Camera2D
var _marker := Vector2.ZERO
var _marker_time := 0.0
var _marker_node: Node2D
## Wegweiser zum nächsten Ziel der Hauptgeschichte: Ring und Pfeil an der Stelle, Pfeil am Bildrand, wenn sie nicht zu sehen ist
var _waypoint := Vector2i(-1, -1)
## Wegweiser der Nebenaufträge (blau, mit Nummer): [{nummer, feld}]
var _side_waypoints: Array[Dictionary] = []
## Auftragsbuch: welcher Reiter offen ist ("offen", "fertig", "erfolge")
var _quest_tab := "offen"
var _quest_tabs: HBoxContainer
## Rudel-Fenster des Zähmers (Gepäck ordnen, Stall bei Tilda, gleich nach dem Zähmen tauschen)
var _pack_panel: PanelContainer
var _pack_box: VBoxContainer
var _pack_button: Button
var _pack_open := false
var _pack_shown := ""
var _waypoint_node: Node2D
var _edge_arrow: Control
## Häuser, Bäume und Stände, die durchsichtig werden, wenn jemand dahinter steht: {node, rect (Welt-Koordinaten)}
var _occluders: Array[Dictionary] = []
var _bot_timer := 2.0
var _time := 0.0
## Beim "Neu beginnen" nicht mehr speichern
var _no_save := false

var _dialog: PanelContainer
var _dialog_name: Label
var _dialog_text: Label
var _dialog_answers: VBoxContainer
var _dialog_next: Button
var _dialog_shown := {}
var _info: Label
var _hud: Label
var _goal: Label
var _notices: VBoxContainer
var _notice_patterns: Array[Array] = []
var _panel: PanelContainer
var _panel_title: Label
var _panel_text: RichTextLabel
var _panel_mode := ""
## Kästchen der Tasche (Raster im Taschen-Fenster) und das gerade angeklickte Kästchen
var _bag_grid: GridContainer
var _bag_footer: HBoxContainer
var _bag_tests: HBoxContainer
var _quest_view: HBoxContainer
var _quest_list: VBoxContainer
var _quest_detail: RichTextLabel
## Im Auftragsbuch ausgewählter Auftrag ("" = der erste der Liste)
var _quest_selected := ""
var _stats_head: HBoxContainer
var _rep_box: VBoxContainer
var _bag_selected := -1
## Gegenstand, bei dem gerade „Wirklich wegwerfen?“ gefragt wird ("" = keine Frage)
var _discard_ask := ""
## Beute-Fenster: Beute nach einem Sieg, die nicht mehr in die Tasche gepasst hat
var _loot_panel: PanelContainer
var _loot_box: VBoxContainer
var _loot_shown := ""
var _shop_panel: PanelContainer
var _shop_box: VBoxContainer
## Was im Ladenfenster gerade angezeigt wird (zum Neuaufbau bei Änderungen)
var _shop_shown := ""
## Knöpfe, auf denen ein Antippen nicht als Laufen zählt
var _buttons: Array[Control] = []

## Chat beim Zusammenspielen: Knopf, Eingabezeile und die letzten Nachrichten
var _chat_button: Button
var _chat_input: LineEdit
var _chat_box: VBoxContainer
var _chat_lines: Array[Label] = []
const CHAT_LINES := 6
const CHAT_FADE_SECONDS := 20.0

## Gruppe beim Zusammenspielen: Fenster mit den Mitgliedern, Menü beim Antippen eines Mitspielers, Einladung
var _group_panel: PanelContainer
var _group_box: VBoxContainer
var _player_menu: PanelContainer
var _player_menu_box: VBoxContainer
var _invite_panel: PanelContainer
var _invite_label: Label
const GROUP_NAME_COLOR := Color("7fc8ff")

## Hinweis beim Wiederverbinden und ob die Stadt beim Neuladen nicht „verlassen“ melden soll
var _reconnect_label: Label
var _skip_leave := false

var _steer_sent := Vector2.ZERO
## F gedrückt: Zeit bis zum nächsten automatischen „Weiter“ (-1 = F nicht gedrückt)
var _skip_timer := -1.0
var _touch_ui := false
var _stick_layer: Control
var _action_button: Button
var _stick_index := -1
var _stick_origin := Vector2.ZERO
var _stick_vec := Vector2.ZERO
var _stick_moved := false


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("1b2418"))
	state = Netz.world if Netz.online() else WorldState.new()
	if Netz.online():
		local_id = Netz.my_id
		Netz._node().disconnected.connect(_on_net_lost)
		Netz._node().chat_received.connect(_on_chat)
		Netz._node().group_changed.connect(_update_group)
		Netz._node().group_invited.connect(_on_group_invited)
		Netz._node().group_notice.connect(func(text: String) -> void: _on_notice(local_id, text))
		Netz._node().battle_started.connect(_on_group_battle)
		Netz._node().reconnecting.connect(_on_reconnecting)
		Netz._node().reconnected.connect(_on_reconnected)
	state.notice.connect(_on_notice)
	state.progress_changed.connect(_on_progress_changed)
	state.battle_requested.connect(_on_battle_requested)
	state.effect_requested.connect(_on_effect)
	state.scene_requested.connect(_on_scene)
	_night = CanvasModulate.new()
	add_child(_night)
	var local: PlayerState
	if Netz.online():
		local = state.add_player(local_id, Netz.my_name, Netz.my_look, WorldState.start_cell())
		SaveGame.load_into(local)
		state.fix_position(local)
		Netz.enter_world(local)
	else:
		local = state.add_player(local_id, "Du", PLAYER_LOOK, WorldState.start_cell())
		SaveGame.load_into(local)
		state.fix_position(local)
		state.add_player(BOT_ID, "Testgefährte", "lizard_f", WorldState.start_cell() + Vector2i(-1, 0))

	_ground = Node2D.new()
	_ground.z_index = -10
	_ground.draw.connect(_draw_ground)
	add_child(_ground)
	_marker_node = Node2D.new()
	_marker_node.z_index = -9
	_marker_node.draw.connect(_draw_tap_marker)
	add_child(_marker_node)

	# Alles, was steht, wird nach Tiefe sortiert (wer weiter unten steht, ist vorne)
	_objects = Node2D.new()
	_objects.y_sort_enabled = true
	add_child(_objects)
	_build_map_view()

	_waypoint_node = Node2D.new()
	_waypoint_node.z_index = 15
	_waypoint_node.draw.connect(_draw_waypoint)
	add_child(_waypoint_node)

	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.25, 1.25)
	_camera.position_smoothing_enabled = true
	add_child(_camera)
	_build_ui()
	_set_touch_ui(DisplayServer.is_touchscreen_available())
	_sync()
	_camera.reset_smoothing()
	# Zurück aus einem Kampf: Ergebnis verbuchen (Erfahrung, Aufträge)
	if not BattleRequest.result.is_empty():
		var cmd := {type = "kampf_ergebnis", kampf = BattleRequest.result.kampf, gewonnen = BattleRequest.result.gewonnen,
				traenke_benutzt = BattleRequest.result.get("traenke_benutzt", 0), gezaehmt = BattleRequest.result.get("gezaehmt", []),
				belohnung_gezeigt = BattleRequest.result.get("belohnung_gezeigt", false)}
		if BattleRequest.result.has("karte"):
			cmd["karte"] = BattleRequest.result.karte
		_send(cmd)
		BattleRequest.result = {}
	# Zurück von einer Partie Kreuzweg-Karten: Ergebnis verbuchen
	if not KartenTisch.ergebnis.is_empty():
		_send({type = "karten_ergebnis", gegner = KartenTisch.ergebnis.gegner, gewonnen = KartenTisch.ergebnis.gewonnen,
				unentschieden = KartenTisch.ergebnis.unentschieden})
		KartenTisch.ergebnis = {}
	# Beim ersten Betreten der Stadt kommt die Einleitung
	_send({type = "start"})


## Baut die Karte des eigenen Spielers auf (beim Start und nach jedem Kartenwechsel).
func _build_map_view() -> void:
	var local := local_player()
	_shown_map = local.map
	for node in _map_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_map_nodes.clear()
	_occluders.clear()
	_pickup_nodes.clear()
	_deco_nodes.clear()
	for id: String in _characters.keys():
		if id.begins_with("npc:") or id.begins_with("monster:"):
			_characters.erase(id)
	var m := state.get_map(local.map)
	for b: Dictionary in m.buildings:
		_add_building(b)
	for prop: Dictionary in m.props:
		_add_prop(prop)
	for i in state.pickups.size():
		if state.pickups[i].map == local.map:
			_add_pickup("punkt:%d" % i)
	for i in state.places.size():
		if state.places[i].map == local.map:
			_add_pickup("ort:%d" % i)
	for deco: Dictionary in state.decorations:
		if deco.map == local.map:
			_add_decoration(deco)
	for id: String in state.npcs:
		var npc: Dictionary = state.npcs[id]
		if npc.map != local.map:
			continue
		var view := WorldCharacter.new()
		view.setup(npc.look, npc.name, npc.tint, Color("f2c14e"))
		view.idle_fps = NPC_IDLE_FPS
		# Jeder NPC beginnt an einer anderen Stelle der Animation, damit nicht alle im Gleichtakt wippen
		view.time_offset(randf() * 4.0)
		view.position = cell_center(Vector2(npc.cell))
		view.facing = 1
		_add_map_node(view)
		_characters["npc:" + id] = view
	# Monster in der Wildnis: Aussehen wie im Kampf, Name mit Stufe
	for i in state.monsters.size():
		var wild: Dictionary = state.monsters[i]
		if wild.karte != local.map:
			continue
		var look: Dictionary = FighterView.LOOKS.get(wild.gegner[0], {sprite = "goblin"})
		var label := "%s%s · Stufe %d" % [Sandbox.ENEMIES[wild.gegner[0]].name, " +%d" % (wild.gegner.size() - 1) if wild.gegner.size() > 1 else "", wild.stufe]
		var view := WorldCharacter.new()
		view.setup(look.sprite, label, look.get("tint", Color.WHITE), _danger_color(wild.stufe, local.progress.level))
		view.idle_fps = NPC_IDLE_FPS * 2.0
		view.time_offset(randf() * 4.0)
		view.position = cell_center(Vector2(wild.feld))
		view.facing = -1 if i % 2 == 0 else 1
		_add_map_node(view)
		_characters["monster:%d" % i] = view
	_ground.queue_redraw()


## Farbe des Monsternamens: grau = leicht, weiß = passend, orange = schwer, rot = sehr schwer.
static func _danger_color(monster_level: int, player_level: int) -> Color:
	var diff := monster_level - player_level
	if diff <= -3:
		return Color("a8a8a8")
	if diff <= 2:
		return Color.WHITE
	if diff <= 4:
		return Color("ffb050")
	return Color("ff6060")


func _add_map_node(node: Node2D) -> void:
	_objects.add_child(node)
	_map_nodes.append(node)


func _exit_tree() -> void:
	if not _no_save:
		SaveGame.save(local_player())
	if Netz.online() and not _skip_leave:
		Netz.leave_world()


func _process(delta: float) -> void:
	_time += delta
	_update_steer()
	_update_skip(delta)
	if not Netz.online():
		# Beim Zusammenspielen spielt der Gastgeber die Welt weiter (Netz), hier nur allein
		_drive_bot(delta)
		state.tick(delta)
	_sync()
	_update_dialog()
	_update_shop()
	_update_loot()
	_update_pack()
	_update_chat()
	_marker_time = maxf(_marker_time - delta, 0.0)
	_marker_node.queue_redraw()
	_waypoint_node.queue_redraw()
	_edge_arrow.queue_redraw()
	_update_occluders(delta)


func local_player() -> PlayerState:
	return state.players[local_id]


## Schickt einen Befehl des eigenen Spielers: allein direkt an die Welt, zusammen über das Netz.
func _send(cmd: Dictionary) -> void:
	if Netz.online():
		Netz.send(cmd)
	else:
		state.apply_command(local_id, cmd)


## Überträgt den Zustand der Spieler auf ihre Figuren.
func _sync() -> void:
	var local := local_player()
	if local.map != _shown_map:
		_build_map_view()
		_camera.position = cell_center(local.pos)
		_camera.reset_smoothing()
	for id: String in state.players:
		var p: PlayerState = state.players[id]
		if not _characters.has(id):
			var view := WorldCharacter.new()
			var is_local := id == local_id
			view.setup(p.look, p.display_name, Color.WHITE, Color("8affc1") if is_local else Color.WHITE)
			_objects.add_child(view)
			_characters[id] = view
		var view: WorldCharacter = _characters[id]
		if id != local_id and Netz.online():
			view.set_name_color(GROUP_NAME_COLOR if Netz.in_my_group(id) else Color.WHITE)
		view.position = cell_center(p.pos)
		view.moving = p.is_walking()
		view.facing = p.facing
		# Wer auf einer anderen Karte steht, ist hier nicht zu sehen. Im Dungeon sieht man nur die eigene Gruppe.
		view.visible = p.map == local.map and (id == local_id or state.get_map(p.map).dungeon == "" or Netz.in_my_group(id))
	# Mitspieler, die gegangen sind (oder gerade kämpfen), verschwinden
	for id: String in _characters.keys():
		if not id.begins_with("npc:") and not id.begins_with("monster:") and not state.players.has(id):
			_characters[id].queue_free()
			_characters.erase(id)
	_camera.position = cell_center(local.pos)
	# Sammelpunkte: Jeder sieht nur die, die er selbst noch nicht eingesammelt hat
	for target: String in _pickup_nodes:
		var node: Node2D = _pickup_nodes[target]
		node.visible = state.can_use(local, target)
		node.queue_redraw()
	# Schmuck (Festlaternen, Krater) und Nacht: je nachdem, wie weit der eigene Spieler ist
	for node: Node2D in _deco_nodes:
		node.visible = state.check(local, _deco_nodes[node])
		if node.visible:
			node.queue_redraw()
	var m := state.get_map(local.map)
	var night_color := NIGHT_COLOR if local.progress.flags.has("nacht") else m.light
	_night.color = _night.color.lerp(night_color, 0.05)
	Musik.play("nacht" if local.progress.flags.has("nacht") else m.music_for(local.progress.flags))
	var here := state.players.values().filter(func(other: PlayerState) -> bool: return other.map == local.map).size()
	if Netz.online():
		_info.text = "%s · Zusammen: %d Spieler%s" % [m.title, here, " · Gastgeber, Adresse: " + Netz.local_address() if Netz.mode == Netz.Mode.HOST else ""]
		_info.reset_size()
	else:
		_info.text = "Spieler in %s: %d" % [m.title, here]
	for i in state.monsters.size():
		if _characters.has("monster:%d" % i):
			var monster_view: WorldCharacter = _characters["monster:%d" % i]
			var was_visible := monster_view.visible
			monster_view.visible = state.can_use(local, "monster:%d" % i)
			# Monster laufen herum (beim Zusammenspielen kommt ihr Platz nur ein paar Mal pro Sekunde: weich hinterher)
			var wild: Dictionary = state.monsters[i]
			var target := cell_center(wild.pos)
			if Netz.online() and was_visible and monster_view.position.distance_to(target) < 80.0:
				monster_view.position = monster_view.position.lerp(target, 0.25)
			else:
				monster_view.position = target
			monster_view.moving = wild.moving
			monster_view.facing = wild.facing
			monster_view.set_name_color(_danger_color(state.monsters[i].stufe, local.progress.level))
	for id: String in state.npcs:
		if not _characters.has("npc:" + id):
			continue
		var npc_view: WorldCharacter = _characters["npc:" + id]
		npc_view.visible = state.npc_visible(local, id)
		_place_npc(npc_view, id, local)
		npc_view.marker = state.npc_marker(local, id)
		npc_view.marker_side = state.npc_marker_side(local, id)
		# Namen nur in der Nähe zeigen (Zeichen ! und ? bleiben immer sichtbar)
		var distance := (Vector2(state.npcs[id].cell) - local.pos).length()
		npc_view.set_name_alpha(clampf((NAME_FADE_END - distance) / (NAME_FADE_END - NAME_FADE_START), 0.0, 1.0))
	_waypoint = state.objective_cell(local)
	_side_waypoints = state.side_objectives(local)
	var goal := state.objective(local)
	_goal.text = "Ziel: " + goal if goal != "" else ""
	_update_hud()


## NPCs stehen an ihrem Platz – außer einer läuft gerade zum eigenen Spieler hin oder wieder zurück.
func _place_npc(npc_view: WorldCharacter, id: String, local: PlayerState) -> void:
	var walk := local.npc_walk
	if walk.get("id", "") != id:
		npc_view.position = cell_center(Vector2(state.npcs[id].cell))
		npc_view.moving = false
		return
	var target := cell_center(walk.pos)
	# Beim Zusammenspielen kommt der Platz nur ein paar Mal pro Sekunde: weich hinterherlaufen
	if Netz.online() and npc_view.position.distance_to(target) < 80.0:
		npc_view.position = npc_view.position.lerp(target, 0.35)
	else:
		npc_view.position = target
	npc_view.moving = walk.phase != "reden"
	npc_view.facing = walk.facing


## Der Testgefährte läuft ab und zu irgendwohin (wie ein Mitspieler).
func _drive_bot(delta: float) -> void:
	_bot_timer -= delta
	if _bot_timer > 0.0:
		return
	_bot_timer = randf_range(3.0, 6.0)
	for i in 20:
		var cell := Vector2i(randi_range(3, WorldState.SIZE.x - 4), randi_range(3, WorldState.SIZE.y - 4))
		if state.is_walkable(cell):
			state.apply_command(BOT_ID, {type = "move", cell = cell})
			return


# --- Umrechnung Feld <-> Bildschirm (schräg von oben) --------------------------

func cell_to_screen(c: Vector2) -> Vector2:
	return Vector2((c.x - c.y) * TILE_W * 0.5, (c.x + c.y) * TILE_H * 0.5)


func cell_center(c: Vector2) -> Vector2:
	return cell_to_screen(c + Vector2(0.5, 0.5))


func screen_to_cell(p: Vector2) -> Vector2i:
	var x := (p.x / (TILE_W * 0.5) + p.y / (TILE_H * 0.5)) * 0.5
	var y := (p.y / (TILE_H * 0.5) - p.x / (TILE_W * 0.5)) * 0.5
	return Vector2i(floori(x), floori(y))



# --- Eingabe --------------------------------------------------------------------
# PC: Klicken = hinlaufen, WASD/Pfeiltasten = laufen, E/Leertaste = reden bzw. weiter,
#     1–4 = Antwort wählen, J = Auftragsbuch, I = Tasche, C = Werte, Esc = Fenster schließen.
# Handy: Antippen = hinlaufen, Steuerknopf unten links (erscheint unter dem Daumen), Aktions-Knopf unten rechts.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key: Key = event.physical_keycode
		var handled := true
		if key in [KEY_ENTER, KEY_KP_ENTER] and Netz.online():
			_open_chat()
		elif key in [KEY_E, KEY_SPACE]:
			_action()
		elif key >= KEY_1 and key <= KEY_9:
			_send({type = "dialog_choose", index = key - KEY_1})
		elif key == KEY_J:
			_toggle_panel("auftraege")
		elif key == KEY_I:
			_toggle_panel("tasche")
		elif key == KEY_C:
			_toggle_panel("werte")
		elif key == KEY_R and _is_tamer():
			_pack_open = not _pack_open
		elif key == KEY_ESCAPE and local_player().shop != "":
			_send({type = "laden_zu"})
		elif key == KEY_ESCAPE and _player_menu != null and _player_menu.visible:
			_player_menu.visible = false
		elif key == KEY_ESCAPE and _panel.visible:
			_panel.visible = false
		else:
			handled = false
		if handled:
			get_viewport().set_input_as_handled()
		return
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_touch(event)
		return
	if _dialog.visible:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	# Finger-Berührungen kommen auch als Maus an; die werden schon in _touch behandelt
	if event.device == InputEvent.DEVICE_ID_EMULATION and _touch_ui:
		return
	_tap_at(get_global_mouse_position())


## E, Leertaste oder Aktions-Knopf: im Gespräch weiter, sonst das Nächste nebenan benutzen.
func _action() -> void:
	if local_player().in_dialog():
		_send({type = "dialog_next"})
	else:
		_send({type = "interact"})


## F: im Gespräch weiter. Gedrückt halten blättert schnell durch, bis eine Antwort gewählt werden muss.
func _update_skip(delta: float) -> void:
	var typing := _chat_input != null and _chat_input.has_focus()
	if typing or not Input.is_physical_key_pressed(KEY_F) or not local_player().in_dialog():
		_skip_timer = -1.0
		return
	if _skip_timer < 0.0:
		_skip_timer = SKIP_FIRST_DELAY
		_send({type = "dialog_next"})
		return
	_skip_timer -= delta
	if _skip_timer <= 0.0:
		_skip_timer = SKIP_REPEAT
		_send({type = "dialog_next"})


## Richtung aus Tasten und Steuerknopf; wird nur bei Änderung als Befehl geschickt.
func _update_steer() -> void:
	var dir := Vector2.ZERO
	var typing := _chat_input != null and _chat_input.has_focus()
	if not local_player().in_dialog() and not local_player().awaiting_npc():
		# Beim Schreiben im Chat laufen die Buchstaben nicht mit
		if not typing:
			if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
				dir.x -= 1.0
			if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
				dir.x += 1.0
			if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
				dir.y -= 1.0
			if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
				dir.y += 1.0
		dir = dir.normalized()
		if _stick_vec != Vector2.ZERO:
			dir = _stick_vec
	if dir != _steer_sent:
		_steer_sent = dir
		_send({type = "steer", dir = dir})


func _touch(event: InputEvent) -> void:
	if not _touch_ui:
		_set_touch_ui(true)
	if event is InputEventScreenTouch:
		if event.pressed:
			if _dialog.visible or _on_buttons(event.position):
				return
			if _stick_index == -1 and _in_stick_zone(event.position):
				_stick_index = event.index
				_stick_origin = event.position
				_stick_moved = false
				_stick_vec = Vector2.ZERO
			else:
				_tap_at(_to_world(event.position))
		elif event.index == _stick_index:
			# Kurz angetippt ohne zu ziehen: wie ein normales Antippen (hinlaufen)
			if not _stick_moved and not _dialog.visible:
				_tap_at(_to_world(event.position))
			_stick_index = -1
			_stick_vec = Vector2.ZERO
		_stick_layer.queue_redraw()
	elif event is InputEventScreenDrag and event.index == _stick_index:
		var offset: Vector2 = event.position - _stick_origin
		if offset.length() > STICK_DEADZONE:
			_stick_moved = true
		_stick_vec = (offset / STICK_RADIUS).limit_length(1.0) if _stick_moved else Vector2.ZERO
		_stick_layer.queue_redraw()


func _in_stick_zone(pos: Vector2) -> bool:
	return pos.x < 1280.0 * 0.45 and pos.y > 720.0 * 0.4


func _on_buttons(pos: Vector2) -> bool:
	for c in _buttons:
		if c.visible and c.get_global_rect().has_point(pos):
			return true
	return false


func _to_world(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos


## Antippen / Klicken auf eine Stelle der Welt: hinlaufen, mit dem NPC dort reden oder etwas einsammeln.
func _tap_at(world: Vector2) -> void:
	if _panel.visible:
		_panel.visible = false
		return
	# Mitspieler angetippt? Dann das Menü (einladen, Gruppe)
	if Netz.online():
		for id: String in state.players:
			if id == local_id or state.players[id].map != local_player().map:
				continue
			var player_pos := cell_center(state.players[id].pos)
			if absf(world.x - player_pos.x) < 30.0 and world.y > player_pos.y - 90.0 and world.y < player_pos.y + 12.0:
				_open_player_menu(id)
				return
	# NPC angetippt? Dann hinlaufen und reden
	for id: String in state.npcs:
		if not state.npc_visible(local_player(), id):
			continue
		var npc_pos := cell_center(Vector2(state.npcs[id].cell))
		if absf(world.x - npc_pos.x) < 30.0 and world.y > npc_pos.y - 90.0 and world.y < npc_pos.y + 12.0:
			_send({type = "talk", npc = id})
			_show_marker(npc_pos)
			return
	# Monster angetippt? Dann hinlaufen, der Kampf beginnt
	for id: String in _characters:
		if id.begins_with("monster:") and _characters[id].visible:
			var monster_pos: Vector2 = _characters[id].position
			if absf(world.x - monster_pos.x) < 30.0 and world.y > monster_pos.y - 90.0 and world.y < monster_pos.y + 12.0:
				_send({type = "use", target = id})
				_show_marker(monster_pos)
				return
	# Sammelpunkt angetippt? Dann hinlaufen und einsammeln
	for target: String in _pickup_nodes:
		var node: Node2D = _pickup_nodes[target]
		if node.visible and (world - (node.position + Vector2(0, -12))).length() < 26.0:
			_send({type = "use", target = target})
			_show_marker(node.position)
			return
	var cell := screen_to_cell(world)
	if state.is_walkable(cell, local_player().map):
		_send({type = "move", cell = cell})
		_show_marker(cell_center(Vector2(cell)))


func _show_marker(pos: Vector2) -> void:
	_marker = pos
	_marker_time = 0.6


# --- Zeichnen -------------------------------------------------------------------

func _draw_ground() -> void:
	var m := state.get_map(_shown_map)
	for y in m.size.y:
		for x in m.size.x:
			var cell := Vector2i(x, y)
			var tile := m.tile_at(cell)
			var colors: Array = TILE_COLORS[tile]
			var color: Color = colors[(x + y) % 2]
			var top := cell_to_screen(Vector2(cell))
			var diamond := PackedVector2Array([
				top,
				top + Vector2(TILE_W * 0.5, TILE_H * 0.5),
				top + Vector2(0, TILE_H),
				top + Vector2(-TILE_W * 0.5, TILE_H * 0.5),
			])
			_ground.draw_colored_polygon(diamond, color)
			_ground.draw_polyline(diamond + PackedVector2Array([top]), Color(0, 0, 0, 0.08), 1.0)
			# Klare Straßen: dunkler Rand, wo Straße oder Platz an Gras grenzt
			var edges := [[Vector2i(0, -1), 0, 1], [Vector2i(1, 0), 1, 2], [Vector2i(0, 1), 2, 3], [Vector2i(-1, 0), 3, 0]]
			if tile == WorldState.Tile.ROAD or tile == WorldState.Tile.PLAZA:
				for e: Array in edges:
					var other := m.tile_at(cell + e[0])
					if other in [WorldState.Tile.GRASS, WorldState.Tile.OVERGROWN, WorldState.Tile.FOREST]:
						_ground.draw_line(diamond[e[1]], diamond[e[2]], Color("4a3c2a"), 3.0)
			elif tile == WorldState.Tile.ROCK:
				# Fels: ein dunkler Block mit hellerer Kante zum Höhlenboden
				for e: Array in edges:
					if m.tile_at(cell + e[0]) == WorldState.Tile.CAVE:
						_ground.draw_line(diamond[e[1]], diamond[e[2]], Color("4a4250"), 3.0)
			elif tile == WorldState.Tile.CANOPY:
				# Baumkronen unter den Plattformen: ein paar Blätterbüschel
				var leaf := Color("2c5228") if (x * 7 + y * 3) % 5 < 2 else Color("1a3218")
				_ground.draw_circle(top + Vector2(((x * 13) % 9) - 4.0, TILE_H * 0.5 + ((y * 7) % 5) - 2.0), 9.0, leaf)
			elif tile == WorldState.Tile.PLANKS or tile == WorldState.Tile.BRIDGE:
				# Bretterfugen; am Rand zur Tiefe ein dunkler Rand, an Brücken Seile
				var a: Vector2 = diamond[0].lerp(diamond[3], 0.5)
				var b: Vector2 = diamond[1].lerp(diamond[2], 0.5)
				_ground.draw_line(a, b, color.darkened(0.25), 1.0)
				for e: Array in edges:
					if m.tile_at(cell + e[0]) in [WorldState.Tile.CANOPY, -1]:
						var rim := Color("3a2414") if tile == WorldState.Tile.PLANKS else Color("d8c08a")
						_ground.draw_line(diamond[e[1]], diamond[e[2]], rim, 3.0 if tile == WorldState.Tile.PLANKS else 2.0)


## Wohin getippt wurde: kleiner Ring auf dem Boden (eigene Ebene, damit der Boden nicht jedes Bild neu gemalt wird).
func _draw_tap_marker() -> void:
	if _marker_time > 0.0:
		var r := 22.0 * (1.0 - _marker_time / 0.6) + 6.0
		_marker_node.draw_set_transform(_marker, 0.0, Vector2(1.0, 0.5))
		_marker_node.draw_arc(Vector2.ZERO, r, 0, TAU, 24, Color(1, 0.9, 0.5, _marker_time / 0.6), 3.0)
		_marker_node.draw_set_transform_matrix(Transform2D.IDENTITY)


## Wegweiser an der Zielstelle: leuchtender Ring am Boden und ein wippender Pfeil darüber.
## Nebenaufträge bekommen einen kleineren blauen Wegweiser mit ihrer Nummer.
func _draw_waypoint() -> void:
	if local_player().in_dialog():
		return
	var font := ThemeDB.fallback_font
	for side: Dictionary in _side_waypoints:
		var spot := cell_center(Vector2(side.feld))
		_waypoint_node.draw_set_transform(spot, 0.0, Vector2(1.0, 0.5))
		_waypoint_node.draw_arc(Vector2.ZERO, 22.0, 0, TAU, 32, Color(SIDE_COLOR, 0.8), 3.0)
		_waypoint_node.draw_set_transform_matrix(Transform2D.IDENTITY)
		var badge := spot + Vector2(22 * (side.nummer % 2 * 2 - 1), -150 + sin(_time * 3.0 + side.nummer) * 5.0)
		_waypoint_node.draw_circle(badge, 14.0, SIDE_COLOR)
		_waypoint_node.draw_arc(badge, 14.0, 0, TAU, 24, Color.BLACK, 2.0)
		_waypoint_node.draw_string(font, badge + Vector2(-14, 7), str(side.nummer), HORIZONTAL_ALIGNMENT_CENTER, 28, 20, Color.WHITE)
	if _waypoint == Vector2i(-1, -1):
		return
	var pos := cell_center(Vector2(_waypoint))
	var pulse := 0.5 + 0.5 * sin(_time * 4.0)
	_waypoint_node.draw_set_transform(pos, 0.0, Vector2(1.0, 0.5))
	_waypoint_node.draw_arc(Vector2.ZERO, 26.0 + 6.0 * pulse, 0, TAU, 32, Color(1.0, 0.85, 0.3, 0.5 + 0.4 * pulse), 4.0)
	_waypoint_node.draw_set_transform_matrix(Transform2D.IDENTITY)
	# Der Pfeil schwebt über dem Kopf des Ziels (über dem „!“ oder „?“)
	var tip := pos + Vector2(0, -150 + sin(_time * 3.0) * 6.0)
	var arrow := PackedVector2Array([tip, tip + Vector2(-14, -16), tip + Vector2(-6, -16), tip + Vector2(-6, -30),
			tip + Vector2(6, -30), tip + Vector2(6, -16), tip + Vector2(14, -16)])
	_waypoint_node.draw_colored_polygon(arrow, Color("ffd34d"))
	arrow.append(tip)
	_waypoint_node.draw_polyline(arrow, Color.BLACK, 2.0)


## Liegt ein Ziel außerhalb des Bildes, zeigt ein Pfeil am Rand die Richtung (Hauptgeschichte gelb mit Entfernung,
## Nebenaufträge blau mit ihrer Nummer).
func _draw_edge_arrow() -> void:
	# Über offenen Fenstern (Auftragsbuch, Laden) keine Pfeile
	if local_player().in_dialog() or _panel.visible or _shop_panel.visible or _loot_panel.visible:
		return
	for side: Dictionary in _side_waypoints:
		_draw_one_edge_arrow(side.feld, SIDE_COLOR, str(side.nummer), 0.75)
	if _waypoint != Vector2i(-1, -1):
		var distance := roundi((Vector2(_waypoint) - local_player().pos).length())
		_draw_one_edge_arrow(_waypoint, Color("ffd34d"), "%d m" % distance, 1.0)


func _draw_one_edge_arrow(target_cell: Vector2i, color: Color, label: String, size: float) -> void:
	var screen := get_viewport().get_canvas_transform() * cell_center(Vector2(target_cell))
	# Ist das Ziel im Bild zu sehen, reicht der Pfeil darüber
	if Rect2(Vector2(30, 30), Vector2(1280 - 60, 720 - 60)).has_point(screen):
		return
	var area := Rect2(Vector2(70, 150), Vector2(1280 - 140, 720 - 230))
	var center := area.get_center()
	var dir := (screen - center).normalized()
	# Schnittpunkt der Richtung mit dem Rand des Bereichs
	var scale_x := (area.size.x * 0.5) / maxf(absf(dir.x), 0.001)
	var scale_y := (area.size.y * 0.5) / maxf(absf(dir.y), 0.001)
	var pos := center + dir * minf(scale_x, scale_y)
	var tip := pos + dir * (18.0 + sin(_time * 4.0) * 4.0) * size
	var side := Vector2(-dir.y, dir.x) * size
	var points := PackedVector2Array([tip, pos - dir * 6.0 + side * 16.0, pos - dir * 6.0 - side * 16.0])
	_edge_arrow.draw_circle(pos - dir * 6.0, 26.0 * size, Color(0, 0, 0, 0.45))
	_edge_arrow.draw_colored_polygon(points, color)
	points.append(tip)
	_edge_arrow.draw_polyline(points, Color.BLACK, 2.0)
	var font := ThemeDB.fallback_font
	var text_pos := pos - dir * 46.0 * size + Vector2(-40, 6)
	_edge_arrow.draw_string_outline(font, text_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 80, 15, 4, Color.BLACK)
	_edge_arrow.draw_string(font, text_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 80, 15, color)


## Häuser, Bäume und Stände, hinter denen jemand steht, werden durchsichtig (Spieler, NPCs, Monster).
func _update_occluders(delta: float) -> void:
	var points: Array[Vector2] = []
	for view: Node2D in _characters.values():
		if is_instance_valid(view) and view.visible:
			points.append(view.position)
	# Orte und Sammelpunkte (z. B. der Silberhirsch) sollen auch nicht hinter Bäumen verschwinden
	for node: Node2D in _pickup_nodes.values():
		if is_instance_valid(node) and node.visible:
			points.append(node.position)
	for occ: Dictionary in _occluders:
		var node: Node2D = occ.node
		if not is_instance_valid(node):
			continue
		var rect: Rect2 = occ.rect
		var hidden := false
		for p in points:
			# Nur wer hinter dem Ding steht (weiter oben auf dem Bildschirm) und von ihm bedeckt wird
			if p.y < node.position.y and (rect.has_point(p + Vector2(0, -20)) or rect.has_point(p + Vector2(0, -50))):
				hidden = true
				break
		node.modulate.a = move_toward(node.modulate.a, 0.4 if hidden else 1.0, delta * 4.0)


## Ein Haus (Wände, Satteldach, Tür, Fenster) oder die Statue, mit Namensschild.
func _add_building(b: Dictionary) -> void:
	var rect: Rect2i = b.rect
	var node := Node2D.new()
	# Sortierpunkt: die vorderste Ecke unten
	node.position = cell_to_screen(Vector2(rect.end))
	if b.get("art", "haus") == "statue":
		node.draw.connect(func() -> void: _draw_statue(node, rect, b.height, b.color, b.name))
	else:
		node.draw.connect(func() -> void: _draw_house(node, rect, b.height, b.color, b.roof, b.name))
		# Fläche, die das Haus samt Dach auf dem Bildschirm bedeckt
		var top := cell_to_screen(Vector2(rect.position))
		var left := cell_to_screen(Vector2(rect.position.x, rect.end.y))
		var right := cell_to_screen(Vector2(rect.end.x, rect.position.y))
		var roof_top: float = top.y - b.height - minf(rect.size.y, rect.size.x) * 9.0 - 30.0
		_occluders.append({node = node, rect = Rect2(left.x - 8.0, roof_top, right.x - left.x + 16.0, node.position.y - roof_top)})
	_add_map_node(node)
	if b.name == FORGE:
		# Aus der Tür der Schmiede leuchtet die Glut der Esse
		var d := cell_to_screen(Vector2(rect.position.x, rect.end.y)) - node.position
		_add_light(node, "glut", d * 0.7 + Vector2(0, -6))


func _draw_house(node: Node2D, rect: Rect2i, height: float, color: Color, roof: Color, label: String) -> void:
	var base := node.position
	var a := cell_to_screen(Vector2(rect.position)) - base
	var b := cell_to_screen(Vector2(rect.end.x, rect.position.y)) - base
	var c := Vector2.ZERO
	var d := cell_to_screen(Vector2(rect.position.x, rect.end.y)) - base
	var up := Vector2(0, -height)
	# Wände
	node.draw_colored_polygon(PackedVector2Array([d, c, c + up, d + up]), color.darkened(0.15))
	node.draw_colored_polygon(PackedVector2Array([c, b, b + up, c + up]), color.darkened(0.4))
	# Fachwerk-Balken an den Ecken und unter dem Dach
	var beam := color.darkened(0.6)
	for p: Vector2 in [d, c, b]:
		node.draw_line(p, p + up, beam, 3.0)
	node.draw_line(d + up, c + up, beam, 3.0)
	node.draw_line(c + up, b + up, beam, 3.0)
	# Tür und Fenster auf der vorderen Seite
	var front := c - d
	var door := d + front * 0.3
	# In der Schmiede glüht hinter der Tür die Esse
	var door_color := Color("c8582a").lightened(0.1 * sin(_time * 5.0)) if label == FORGE else Color("2a1c14")
	node.draw_colored_polygon(PackedVector2Array([door + Vector2(-8, 4), door + Vector2(8, 8), door + Vector2(8, -18), door + Vector2(-8, -22)]), door_color)
	node.draw_circle(door + Vector2(0, -21), 8.0, door_color)
	for t: float in [0.62, 0.84]:
		var w := d + front * t + Vector2(0, -height * 0.55)
		node.draw_colored_polygon(PackedVector2Array([w + Vector2(-6, -7), w + Vector2(6, -4), w + Vector2(6, 7), w + Vector2(-6, 4)]), Color("f2d38a"))
	var side := b - c
	var w2 := c + side * 0.5 + Vector2(0, -height * 0.55)
	node.draw_colored_polygon(PackedVector2Array([w2 + Vector2(-6, -4), w2 + Vector2(6, -7), w2 + Vector2(6, 4), w2 + Vector2(-6, 7)]), Color("c9ad6e"))
	# Satteldach: First über der Mitte, vorne und hinten ein Stück überstehend
	var ridge_h := Vector2(0, -minf(rect.size.y, rect.size.x) * 9.0 - 14.0)
	var over := (c - d).normalized() * 6.0
	var r1 := (a + d) * 0.5 + up + ridge_h - over
	var r2 := (b + c) * 0.5 + up + ridge_h + over
	var eave := (d - a).normalized() * 6.0 + Vector2(0, 3)
	node.draw_colored_polygon(PackedVector2Array([a + up - eave - over, b + up - eave + over, r2, r1]), roof.darkened(0.3))
	node.draw_colored_polygon(PackedVector2Array([c + up, b + up, (b + c) * 0.5 + up + ridge_h]), color.darkened(0.3))
	node.draw_colored_polygon(PackedVector2Array([r1, r2, c + up + eave + over, d + up + eave - over]), roof)
	# Ziegelreihen
	for t: float in [0.33, 0.66]:
		node.draw_line(r1.lerp(d + up + eave - over, t), r2.lerp(c + up + eave + over, t), roof.darkened(0.25), 2.0)
	node.draw_line(r1, r2, roof.lightened(0.25), 3.0)
	# Schornstein
	var chimney := r1.lerp(r2, 0.75) + Vector2(0, 4)
	node.draw_rect(Rect2(chimney + Vector2(-5, -18), Vector2(10, 18)), Color("5a4a44"))
	if label != "":
		var font := ThemeDB.fallback_font
		var title_pos := (r1 + r2) * 0.5 + Vector2(-90, -14)
		node.draw_string_outline(font, title_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 180, 14, 5, Color.BLACK)
		node.draw_string(font, title_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 180, 14, Color("f3ead8"))


## Statue der Fünf: runder Sockel mit fünf Figuren (Platzhalter).
func _draw_statue(node: Node2D, rect: Rect2i, height: float, color: Color, label: String) -> void:
	var center := cell_to_screen(Vector2(rect.position) + Vector2(rect.size) * 0.5) - node.position
	node.draw_set_transform(center, 0.0, Vector2(1.0, 0.5))
	node.draw_circle(Vector2.ZERO, 50.0, color.darkened(0.35))
	node.draw_set_transform(center + Vector2(0, -12), 0.0, Vector2(1.0, 0.5))
	node.draw_circle(Vector2.ZERO, 44.0, color.darkened(0.1))
	node.draw_set_transform_matrix(Transform2D.IDENTITY)
	node.draw_rect(Rect2(center + Vector2(-44, -12), Vector2(88, 12)), color.darkened(0.1))
	for i in 5:
		var p := center + Vector2.from_angle(TAU * i / 5.0 - PI / 2) * Vector2(26, 11) + Vector2(0, -14)
		node.draw_rect(Rect2(p + Vector2(-5, -height * 0.7), Vector2(10, height * 0.7)), color)
		node.draw_circle(p + Vector2(0, -height * 0.7 - 5), 7.0, color.lightened(0.15))
		node.draw_circle(p + Vector2(0, -height * 0.7 - 16), 3.0, LANTERN_COLORS[i])
	var font := ThemeDB.fallback_font
	var title_pos := center + Vector2(-90, -height - 30)
	node.draw_string_outline(font, title_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 180, 14, 5, Color.BLACK)
	node.draw_string(font, title_pos, label, HORIZONTAL_ALIGNMENT_CENTER, 180, 14, Color("f3ead8"))


func _add_prop(prop: Dictionary) -> void:
	var node := Node2D.new()
	node.position = cell_center(Vector2(prop.cell))
	var kind: String = prop.kind
	node.draw.connect(func() -> void: _draw_prop(node, kind, prop))
	_add_map_node(node)
	if OCCLUDER_RECTS.has(kind):
		var r: Rect2 = OCCLUDER_RECTS[kind]
		_occluders.append({node = node, rect = Rect2(node.position + r.position, r.size)})
	if PROP_LIGHTS.has(kind):
		_add_light(node, PROP_LIGHTS[kind][0], PROP_LIGHTS[kind][1])


func _draw_prop(node: Node2D, kind: String, prop: Dictionary) -> void:
	match kind:
		"stand":
			_draw_stand(node, prop.color, prop.text)
		"well":
			node.draw_set_transform(Vector2(0, -4), 0.0, Vector2(1.0, 0.5))
			node.draw_circle(Vector2.ZERO, 20.0, Color("6a6458"))
			node.draw_circle(Vector2.ZERO, 14.0, Color("1e3a4a"))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_rect(Rect2(-20, -4, 40, 8), Color("6a6458"))
			node.draw_line(Vector2(-16, -4), Vector2(-16, -40), Color("5a3a22"), 3.0)
			node.draw_line(Vector2(16, -4), Vector2(16, -40), Color("5a3a22"), 3.0)
			node.draw_colored_polygon(PackedVector2Array([Vector2(-24, -38), Vector2(0, -54), Vector2(24, -38)]), Color("7a3a2a"))
		"flowers":
			for i in 5:
				var p := Vector2((i - 2) * 7.0, (i % 2) * 5.0 - 4.0)
				node.draw_line(p, p + Vector2(0, -8), Color("3c7a33"), 2.0)
				node.draw_circle(p + Vector2(0, -9), 3.5, [Color("ff8fb0"), Color("ffd36b"), Color("b8b0ff")][i % 3])
		"tree":
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
			node.draw_circle(Vector2.ZERO, 20.0, Color(0, 0, 0, 0.3))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_rect(Rect2(-4, -26, 8, 26), Color("5a3a22"))
			node.draw_circle(Vector2(0, -44), 24.0, Color("2f5a2a"))
			node.draw_circle(Vector2(-8, -52), 14.0, Color("3c6e33"))
		"bush":
			node.draw_circle(Vector2(0, -10), 16.0, Color("26401f"))
			node.draw_circle(Vector2(10, -14), 10.0, Color("30502a"))
		"pilze":
			for i in 3:
				var at := Vector2((i - 1) * 7.0, (i % 2) * 4.0 - 2.0)
				node.draw_rect(Rect2(at + Vector2(-1.5, -6), Vector2(3, 6)), Color("e8dcc0"))
				node.draw_circle(at + Vector2(0, -7), 4.5, [Color("c84a3a"), Color("d8a050"), Color("b8885a")][i])
		"stein":
			node.draw_set_transform(Vector2(0, -6), 0.0, Vector2(1.0, 0.7))
			node.draw_circle(Vector2.ZERO, 14.0, Color("6a6a62"))
			node.draw_circle(Vector2(-4, -4), 8.0, Color("7e7e74"))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
		"riesenbaum":
			# Stamm eines Riesenbaums: geht oben aus dem Bild hinaus (dort oben liegt Wipfelheim)
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
			node.draw_circle(Vector2.ZERO, 46.0, Color(0, 0, 0, 0.35))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			for root in [-1.0, 1.0]:
				node.draw_colored_polygon(PackedVector2Array([Vector2(root * 18, -20), Vector2(root * 46, 8), Vector2(root * 10, 4)]), Color("4a3020"))
			node.draw_rect(Rect2(-24, -230, 48, 234), Color("5a3a24"))
			node.draw_rect(Rect2(-24, -230, 13, 234), Color("4a2e1c"))
			for k in 4:
				node.draw_line(Vector2(-12 + (k % 3) * 11, -40 - k * 50), Vector2(-9 + (k % 3) * 11, -68 - k * 50), Color("3a2414"), 2.0)
			# Oben verschwindet der Stamm im Blätterdach
			node.draw_circle(Vector2(0, -236), 34.0, Color("23401f"))
			node.draw_circle(Vector2(-24, -226), 22.0, Color("2a4a24"))
			node.draw_circle(Vector2(24, -224), 22.0, Color("264522"))
		"stamm":
			# Stamm, der durch eine Plattform wächst
			node.draw_set_transform(Vector2(0, -4), 0.0, Vector2(1.0, 0.5))
			node.draw_circle(Vector2.ZERO, 22.0, Color("4a2e1c"))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_rect(Rect2(-20, -110, 40, 106), Color("5a3a24"))
			node.draw_circle(Vector2(0, -120), 38.0, Color("2f5a2a"))
			node.draw_circle(Vector2(-18, -132), 24.0, Color("3c6e33"))
			node.draw_circle(Vector2(20, -128), 22.0, Color("355f2e"))
		"riesenpilz":
			# Leuchtender Riesenpilz in der Pilzhöhle
			var pulse := 0.8 + 0.2 * sin(_time * 2.0 + node.position.x * 0.01)
			node.draw_circle(Vector2(0, -34), 34.0, Color(0.6, 0.4, 1.0, 0.10 * pulse))
			node.draw_rect(Rect2(-5, -30, 10, 30), Color("d8d0c0"))
			node.draw_set_transform(Vector2(0, -34), 0.0, Vector2(1.0, 0.55))
			node.draw_circle(Vector2.ZERO, 22.0, Color(0.55, 0.35, 0.85).lightened(0.2 * pulse))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			for i in 4:
				node.draw_circle(Vector2(-12 + i * 8.0, -38 + (i % 2) * 4.0), 2.5, Color(0.9, 0.85, 1.0, pulse))
		"wurzel":
			node.draw_line(Vector2(-28, -6), Vector2(-6, -20), Color("4a3020"), 9.0)
			node.draw_line(Vector2(-6, -20), Vector2(22, -4), Color("4a3020"), 9.0)
			node.draw_line(Vector2(-6, -20), Vector2(-2, -44), Color("3e2818"), 7.0)
		"zielscheibe":
			node.draw_line(Vector2(-8, 0), Vector2(-4, -24), Color("5a3a22"), 3.0)
			node.draw_line(Vector2(8, 0), Vector2(4, -24), Color("5a3a22"), 3.0)
			for r: Array in [[16.0, Color("e8e0c8")], [11.0, Color("c84a3a")], [6.0, Color("e8e0c8")], [2.5, Color("c84a3a")]]:
				node.draw_circle(Vector2(0, -32), r[0], r[1])
		"lagerfeuer":
			var flicker := 0.8 + 0.2 * sin(_time * 9.0)
			node.draw_circle(Vector2(0, -10), 30.0, Color(1.0, 0.6, 0.2, 0.15 * flicker))
			for i in 5:
				var a := TAU * i / 5.0
				node.draw_circle(Vector2(cos(a) * 12.0, sin(a) * 6.0 - 2.0), 4.0, Color("6a6a62"))
			node.draw_colored_polygon(PackedVector2Array([Vector2(-7, -2), Vector2(0, -22 * flicker), Vector2(7, -2)]), Color("ff9a3c"))
			node.draw_colored_polygon(PackedVector2Array([Vector2(-3, -2), Vector2(0, -12 * flicker), Vector2(3, -2)]), Color("ffe08a"))
		"strassenlaterne":
			# Laterne auf einem Pfahl (Kreuzweg)
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
			node.draw_circle(Vector2.ZERO, 10.0, Color(0, 0, 0, 0.3))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_rect(Rect2(-2.5, -54, 5, 54), Color("3a3330"))
			node.draw_rect(Rect2(-6, -4, 12, 4), Color("3a3330"))
			node.draw_circle(Vector2(0, -62), 13.0, Color(1.0, 0.82, 0.45, 0.22))
			node.draw_rect(Rect2(-6, -70, 12, 14), Color("ffe2a0"))
			node.draw_rect(Rect2(-8, -73, 16, 3), Color("3a3330"))
			node.draw_rect(Rect2(-6, -56, 12, 2), Color("3a3330"))
		"fackel":
			# Fackel an einem Holzpfahl (Wache in Kreuzweg, Wände der Pilzhöhle)
			var flame := 0.8 + 0.2 * sin(_time * 11.0 + node.position.x)
			node.draw_rect(Rect2(-2.5, -36, 5, 36), Color("5a3a22"))
			node.draw_rect(Rect2(-4, -40, 8, 6), Color("3a2a1a"))
			node.draw_circle(Vector2(0, -46), 14.0, Color(1.0, 0.6, 0.2, 0.2 * flame))
			node.draw_colored_polygon(PackedVector2Array([Vector2(-5, -40), Vector2(0, -40 - 16 * flame), Vector2(5, -40)]), Color("ff9a3c"))
			node.draw_colored_polygon(PackedVector2Array([Vector2(-2.5, -40), Vector2(0, -40 - 9 * flame), Vector2(2.5, -40)]), Color("ffe08a"))
		"lantern":
			# Ye's Laterne an der Wand der Gilde (Hinweis auf den Klassenlosen)
			node.draw_circle(Vector2(0, -60), 14.0, Color(1.0, 0.8, 0.4, 0.25))
			node.draw_rect(Rect2(-5, -66, 10, 12), Color("f2c14e"))
			node.draw_rect(Rect2(-1, -74, 2, 8), Color("3a3a3a"))



## Ein Sammelpunkt (z. B. Silberkraut: kleine leuchtende Pflanze) oder ein Ort zum Benutzen (Kater, Laternenhaken).
func _add_pickup(target: String) -> void:
	var node := Node2D.new()
	node.position = cell_center(Vector2(state.target_cell(target)))
	var art: String
	if target.begins_with("ort:"):
		art = state.places[int(target.substr(4))].art
	else:
		art = state.pickups[int(target.substr(6))].item
	node.draw.connect(func() -> void: _draw_pickup(node, art))
	_add_map_node(node)
	_pickup_nodes[target] = node
	if PICKUP_LIGHTS.has(art):
		_add_light(node, PICKUP_LIGHTS[art][0], PICKUP_LIGHTS[art][1])
	elif not FighterView.LOOKS.has(art) and art != "leer" and target.begins_with("punkt:"):
		# Leuchtende Kräuter zum Einsammeln
		_add_light(node, "kraut", Vector2(0, -8))
	# Bosse in Dungeons: dieselbe Figur wie im Kampf, nur größer
	if FighterView.LOOKS.has(art):
		var look: Dictionary = FighterView.LOOKS[art]
		var boss := WorldCharacter.new()
		boss.setup(look.sprite, Sandbox.ENEMIES.get(art, {name = ""}).name, look.get("tint", Color.WHITE), Color("ff9090"))
		boss.scale = Vector2(1.8, 1.8)
		boss.idle_fps = NPC_IDLE_FPS * 2.0
		node.add_child(boss)


func _draw_pickup(node: Node2D, art: String) -> void:
	var glow := 0.5 + 0.5 * sin(_time * 3.0 + node.position.x)
	# Bosse in Dungeons (die Figur selbst hängt als Kind am Knoten): nur ein leichtes Leuchten darunter
	if FighterView.LOOKS.has(art):
		node.draw_circle(Vector2(0, -40), 60.0, Color(0.7, 0.5, 1.0, 0.06 + 0.06 * glow))
		return
	match art:
		"kater":
			# Hannes Kater: kleine schwarze Katze, der Schwanz wippt
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
			node.draw_circle(Vector2.ZERO, 12.0, Color(0, 0, 0, 0.3))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			var tail := Vector2(16, -22 + sin(_time * 4.0) * 4.0)
			node.draw_line(Vector2(8, -6), tail, Color("1c1c22"), 3.0)
			node.draw_circle(Vector2(0, -7), 9.0, Color("1c1c22"))
			node.draw_circle(Vector2(-8, -15), 6.5, Color("1c1c22"))
			node.draw_colored_polygon(PackedVector2Array([Vector2(-13, -18), Vector2(-12, -26), Vector2(-8, -20)]), Color("1c1c22"))
			node.draw_colored_polygon(PackedVector2Array([Vector2(-7, -20), Vector2(-4, -26), Vector2(-3, -17)]), Color("1c1c22"))
			node.draw_circle(Vector2(-10, -16), 1.5, Color("d8f060"))
			node.draw_circle(Vector2(-6, -16), 1.5, Color("d8f060"))
			return
		"laternenhaken":
			# Leerer Laternenpfahl, an dem eine Festlaterne fehlt
			node.draw_circle(Vector2(0, -58), 14.0, Color(1.0, 0.9, 0.6, 0.10 + 0.12 * glow))
			node.draw_rect(Rect2(-2, -50, 4, 50), Color("3a2a1a"))
			node.draw_rect(Rect2(-8, -68, 16, 3), Color("3a2a1a"))
			node.draw_line(Vector2(0, -65), Vector2(0, -58), Color("6a6a6a"), 2.0)
			node.draw_arc(Vector2(0, -56), 3.0, 0.0, PI, 8, Color("6a6a6a"), 2.0)
			return
		"wildfleisch":
			# Vom Jäger bereitgelegtes Fleisch, in Tuch gewickelt
			node.draw_circle(Vector2(0, -8), 16.0, Color(1.0, 0.9, 0.8, 0.10 + 0.10 * glow))
			node.draw_set_transform(Vector2(0, -6), 0.0, Vector2(1.0, 0.6))
			node.draw_circle(Vector2.ZERO, 10.0, Color("e8dcc0"))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_circle(Vector2(0, -8), 5.0, Color("a0483a"))
			return
		"seilaufzug":
			# Plattform an Seilen, die nach oben in die Baumkronen führen
			var sway := sin(_time * 1.5) * 2.0
			node.draw_line(Vector2(-14, -8), Vector2(-10 + sway, -150), Color("c8b080"), 2.0)
			node.draw_line(Vector2(14, -8), Vector2(10 + sway, -150), Color("c8b080"), 2.0)
			node.draw_colored_polygon(PackedVector2Array([Vector2(-20, -6), Vector2(0, -16), Vector2(20, -6), Vector2(0, 4)]), Color("7a5634"))
			node.draw_polyline(PackedVector2Array([Vector2(-20, -6), Vector2(0, -16), Vector2(20, -6), Vector2(0, 4), Vector2(-20, -6)]), Color("4a3020"), 2.0)
			node.draw_circle(Vector2(0, -6), 18.0, Color(1.0, 0.95, 0.7, 0.06 + 0.08 * glow))
			return
		"urbaum_herz":
			# Das Herz des Urbaums: ein großer Splitter im Stamm, der pulsiert
			var beat := 0.5 + 0.5 * sin(_time * 2.4)
			node.draw_rect(Rect2(-22, -70, 44, 70), Color("4a3020"))
			node.draw_rect(Rect2(-22, -70, 12, 70), Color("3a2414"))
			node.draw_circle(Vector2(0, -40), 34.0 + 6.0 * beat, Color(0.75, 0.55, 1.0, 0.12 + 0.12 * beat))
			node.draw_colored_polygon(PackedVector2Array([Vector2(0, -60), Vector2(10, -40), Vector2(0, -22), Vector2(-10, -40)]),
					Color(0.85, 0.7, 1.0).lightened(0.3 * beat))
			return
		"hoehle":
			# Eingang zur Pilzhöhle zwischen den Wurzeln des Urbaums
			node.draw_set_transform(Vector2(0, -6), 0.0, Vector2(1.0, 0.6))
			node.draw_circle(Vector2.ZERO, 30.0, Color("4a3020"))
			node.draw_circle(Vector2(0, 2), 22.0, Color("0c0810"))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_circle(Vector2(0, -8), 26.0, Color(0.6, 0.4, 1.0, 0.08 + 0.08 * glow))
			for side: float in [-1.0, 1.0]:
				node.draw_line(Vector2(side * 30, -4), Vector2(side * 14, -30), Color("4a3020"), 7.0)
			return
		"bienenstock":
			# Der verrückte Bienenstock: hängt an einem Ast, Bienen kreisen im Takt
			node.draw_line(Vector2(-30, -78), Vector2(30, -78), Color("4a3020"), 6.0)
			node.draw_line(Vector2(0, -78), Vector2(0, -64), Color("4a3020"), 3.0)
			node.draw_set_transform(Vector2(0, -44), 0.0, Vector2(0.8, 1.0))
			node.draw_circle(Vector2.ZERO, 20.0, Color("c89838"))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			for i in 4:
				node.draw_line(Vector2(-14, -54 + i * 7), Vector2(14, -54 + i * 7), Color("8a6420"), 2.0)
			node.draw_circle(Vector2(0, -30), 4.0, Color("2a1c10"))
			for i in 6:
				var angle := _time * (2.0 + i * 0.3) + i
				node.draw_circle(Vector2(cos(angle) * 30.0, -44 + sin(angle * 1.3) * 20.0), 2.5, Color("ffe060"))
			return
		"grab":
			# Rowans Grabstein, davor eingesunkene Erde und ein kleiner Splitter
			node.draw_set_transform(Vector2(0, 2), 0.0, Vector2(1.0, 0.45))
			node.draw_circle(Vector2(6, 0), 16.0, Color("1c140e"))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_rect(Rect2(-14, -34, 20, 34), Color("7a7a74"))
			node.draw_circle(Vector2(-4, -34), 10.0, Color("7a7a74"))
			node.draw_rect(Rect2(-10, -26, 12, 2), Color("55554f"))
			node.draw_rect(Rect2(-10, -21, 12, 2), Color("55554f"))
			node.draw_circle(Vector2(-12, -6), 5.0, Color("3c6e33"))
			node.draw_circle(Vector2(12, 0), 3.0, Color(0.85, 0.7, 1.0, 0.5 + 0.4 * glow))
			node.draw_circle(Vector2(12, 0), 9.0, Color(0.85, 0.7, 1.0, 0.12 * glow))
			return
		"splittertier":
			# Rindenbär mit leuchtenden Splittern im Fell (Geschichte Grünwacht Teil 1)
			var bark := Color("5a4030")
			node.draw_circle(Vector2(0, -22), 40.0, Color(0.7, 0.5, 1.0, 0.10 + 0.12 * glow))
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.4))
			node.draw_circle(Vector2.ZERO, 24.0, Color(0, 0, 0, 0.35))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_circle(Vector2(0, -20), 20.0, bark)
			node.draw_circle(Vector2(-14, -36), 11.0, bark)
			node.draw_circle(Vector2(-20, -45), 4.0, bark.darkened(0.2))
			node.draw_circle(Vector2(-8, -45), 4.0, bark.darkened(0.2))
			node.draw_circle(Vector2(-17, -37), 1.8, Color("f0e0ff"))
			for i in 4:
				var at := Vector2(-6 + i * 6.0, -30 + (i % 2) * 8.0)
				node.draw_colored_polygon(PackedVector2Array([at, at + Vector2(3, -9), at + Vector2(6, 0)]), Color(0.8, 0.6, 1.0, 0.7 + 0.3 * glow))
			return
		"silberhirsch":
			# Fenns drittes Ziel: ein silberner Hirsch, der leise schimmert
			var fur := Color(0.88, 0.92, 1.0)
			node.draw_circle(Vector2(0, -26), 36.0, Color(0.85, 0.95, 1.0, 0.10 + 0.10 * glow))
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.4))
			node.draw_circle(Vector2.ZERO, 18.0, Color(0, 0, 0, 0.3))
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			for leg: float in [-10.0, -5.0, 6.0, 11.0]:
				node.draw_line(Vector2(leg, -18), Vector2(leg, 0), fur.darkened(0.2), 2.5)
			node.draw_set_transform(Vector2(0, -24), 0.0, Vector2(1.0, 0.55))
			node.draw_circle(Vector2.ZERO, 15.0, fur)
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_line(Vector2(-11, -28), Vector2(-16, -42), fur, 5.0)
			node.draw_circle(Vector2(-18, -45), 5.5, fur)
			for side: float in [-1.0, 1.0]:
				var base := Vector2(-18 + side * 3.0, -50)
				node.draw_line(base, base + Vector2(side * 6.0, -10), Color(0.95, 0.95, 0.85), 2.0)
				node.draw_line(base + Vector2(side * 3.0, -5), base + Vector2(side * 10.0, -8), Color(0.95, 0.95, 0.85), 2.0)
			node.draw_circle(Vector2(-20, -46), 1.2, Color("1c2030"))
			return
		"leer":
			return
	node.draw_circle(Vector2(0, -10), 16.0, Color(0.8, 1.0, 0.9, 0.12 + 0.12 * glow))
	for i in 3:
		var angle := -PI / 2 + (i - 1) * 0.6
		var tip := Vector2(0, -2) + Vector2.from_angle(angle) * 16.0
		node.draw_line(Vector2(0, -2), tip, Color("9fe8c8"), 3.0)
		node.draw_circle(tip, 3.5, Color(0.85, 1.0, 0.95, 0.7 + 0.3 * glow))


# --- Oberfläche -----------------------------------------------------------------

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)
	var root := Control.new()
	root.size = Vector2(1280, 720)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = Combat.make_theme()
	ui.add_child(root)

	var hint := _label("Laufen: antippen / WASD · Reden: E / Leertaste · Text weiter: F (halten = schnell)", 14, Color.WHITE)
	hint.position = Vector2(16, 10)
	root.add_child(hint)
	_hud = _label("", 18, Color("f2c14e"))
	_hud.position = Vector2(16, 32)
	root.add_child(_hud)
	_goal = _label("", 17, Color("9fe8ff"))
	_goal.position = Vector2(16, 56)
	root.add_child(_goal)
	_info = _label("", 13, Color("8affc1"))
	_info.position = Vector2(16, 82)
	root.add_child(_info)
	# Lautstärke (auch im Startmenü)
	var volume := Musik.make_slider(130.0)
	volume.position = Vector2(16, 102)
	root.add_child(volume)
	_buttons.append(volume)
	if Netz.online():
		_build_chat(root)
		_build_group(root)

	# Schnellleiste oben rechts wie im UI-Entwurf: Symbol mit Taste, Name als Hinweis beim Darüberfahren
	var x := 1270.0
	for info: Array in [["", "zahnrad", "Menü", 56, _go_menu], ["I", "tasche", "Tasche (I)", 72, _toggle_panel.bind("tasche")],
			["C", "schild", "Werte (C)", 72, _toggle_panel.bind("werte")], ["J", "ausrufe", "Aufträge (J)", 72, _toggle_panel.bind("auftraege")],
			[GameData.text("neu_beginnen"), "", GameData.text("neu_beginnen"), 140, _restart]]:
		var button := Button.new()
		button.text = info[0]
		if info[1] != "":
			button.icon = UiStil.symbol(info[1])
			button.add_theme_constant_override("icon_max_width", 26)
		button.tooltip_text = info[2]
		button.size = Vector2(info[3], 46)
		x -= info[3] + 8.0
		button.position = Vector2(x + 8.0, 10)
		button.add_theme_font_size_override("font_size", 15)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(info[4])
		root.add_child(button)
		_buttons.append(button)
	# Nur für Zähmer: Rudel-Fenster
	_pack_button = Button.new()
	_pack_button.text = "Rudel (R)"
	_pack_button.size = Vector2(110, 44)
	_pack_button.position = Vector2(x - 110, 10)
	_pack_button.add_theme_font_size_override("font_size", 15)
	_pack_button.focus_mode = Control.FOCUS_NONE
	_pack_button.pressed.connect(func() -> void: _pack_open = not _pack_open)
	_pack_button.visible = false
	root.add_child(_pack_button)
	_buttons.append(_pack_button)
	_pack_panel = _framed_panel()
	_pack_panel.position = Vector2(330, 80)
	_pack_panel.custom_minimum_size = Vector2(620, 0)
	_pack_panel.visible = false
	root.add_child(_pack_panel)
	_buttons.append(_pack_panel)
	_pack_box = VBoxContainer.new()
	_pack_box.add_theme_constant_override("separation", 5)
	_pack_panel.add_child(_pack_box)


	# Handy: Steuerknopf (unten links, erscheint unter dem Daumen) und Aktions-Knopf (unten rechts)
	_stick_layer = Control.new()
	_stick_layer.size = Vector2(1280, 720)
	_stick_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stick_layer.draw.connect(_draw_stick)
	root.add_child(_stick_layer)
	_action_button = Button.new()
	_action_button.text = "Reden"
	_action_button.position = Vector2(1100, 560)
	_action_button.size = Vector2(150, 120)
	_action_button.add_theme_font_size_override("font_size", 22)
	_action_button.focus_mode = Control.FOCUS_NONE
	_action_button.pressed.connect(_action)
	root.add_child(_action_button)
	_buttons.append(_action_button)

	# Gesprächsfenster mit Antwort-Knöpfen
	_dialog = _framed_panel()
	_dialog.position = Vector2(120, 440)
	_dialog.size = Vector2(960, 260)
	_dialog.visible = false
	root.add_child(_dialog)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	_dialog.add_child(box)
	_dialog_name = _label("", 20, Color("f2c14e"))
	box.add_child(_dialog_name)
	_dialog_text = Label.new()
	_dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialog_text.custom_minimum_size = Vector2(920, 54)
	_dialog_text.add_theme_font_size_override("font_size", 19)
	box.add_child(_dialog_text)
	_dialog_answers = VBoxContainer.new()
	_dialog_answers.add_theme_constant_override("separation", 4)
	box.add_child(_dialog_answers)
	_dialog_next = Button.new()
	_dialog_next.text = GameData.text("weiter") + " (F)"
	_dialog_next.custom_minimum_size = Vector2(160, 44)
	# Weiter-Dreieck wie im UI-Entwurf
	_dialog_next.icon = UiStil.symbol("weiter")
	_dialog_next.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_dialog_next.add_theme_constant_override("icon_max_width", 22)
	_dialog_next.size_flags_horizontal = Control.SIZE_SHRINK_END
	_dialog_next.add_theme_font_size_override("font_size", 17)
	_dialog_next.focus_mode = Control.FOCUS_NONE
	_dialog_next.pressed.connect(func() -> void: _send({type = "dialog_next"}))
	box.add_child(_dialog_next)

	# Fenster für Auftragsbuch und Tasche
	_panel = _framed_panel()
	_panel.position = Vector2(295, 84)
	_panel.size = Vector2(690, 460)
	_panel.visible = false
	root.add_child(_panel)
	_buttons.append(_panel)
	var panel_box := VBoxContainer.new()
	_panel.add_child(panel_box)
	_panel_title = _label("", 22, Color("f2c14e"))
	panel_box.add_child(UiStil.titel_mit_banner(_panel_title))
	panel_box.add_child(UiStil.trennlinie())
	# Reiter im Auftragsbuch: Offen, Abgeschlossen, Erfolge
	_quest_tabs = HBoxContainer.new()
	_quest_tabs.add_theme_constant_override("separation", 6)
	for tab: Array in [["offen", "Offen"], ["fertig", "Abgeschlossen"], ["erfolge", "Erfolge"]]:
		var tab_button := Button.new()
		tab_button.text = tab[1]
		tab_button.toggle_mode = true
		tab_button.custom_minimum_size = Vector2(150, 34)
		tab_button.theme_type_variation = &"Reiter"
		tab_button.focus_mode = Control.FOCUS_NONE
		tab_button.set_meta("tab", tab[0])
		tab_button.pressed.connect(func() -> void:
			_quest_tab = tab[0]
			_fill_panel())
		_quest_tabs.add_child(tab_button)
	panel_box.add_child(_quest_tabs)
	# Auftragsbuch wie im UI-Entwurf: Liste links, Einzelheiten des gewählten Auftrags rechts
	_quest_view = HBoxContainer.new()
	_quest_view.add_theme_constant_override("separation", 12)
	panel_box.add_child(_quest_view)
	var quest_scroll := ScrollContainer.new()
	quest_scroll.custom_minimum_size = Vector2(250, 330)
	quest_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_quest_view.add_child(quest_scroll)
	_quest_list = VBoxContainer.new()
	_quest_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quest_list.add_theme_constant_override("separation", 4)
	quest_scroll.add_child(_quest_list)
	_quest_detail = RichTextLabel.new()
	_quest_detail.bbcode_enabled = true
	_quest_detail.custom_minimum_size = Vector2(400, 330)
	_quest_detail.add_theme_font_size_override("normal_font_size", 15)
	_quest_detail.add_theme_font_size_override("bold_font_size", 16)
	_quest_view.add_child(_quest_detail)
	# Werte wie im UI-Entwurf: Bild der Figur im Goldrahmen, daneben Stufe, Erfahrung und Leisten
	_stats_head = HBoxContainer.new()
	_stats_head.add_theme_constant_override("separation", 16)
	panel_box.add_child(_stats_head)
	# Ruf bei den Gruppen als Leiste mit Feldern (nur nach der Klassenwahl)
	_rep_box = VBoxContainer.new()
	_rep_box.add_theme_constant_override("separation", 4)
	panel_box.add_child(_rep_box)
	# Tasche: Kästchen mit Bild und Anzahl, per Ziehen und Ablegen umsortieren
	_bag_grid = GridContainer.new()
	_bag_grid.columns = 10
	_bag_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_bag_grid.add_theme_constant_override("h_separation", 4)
	_bag_grid.add_theme_constant_override("v_separation", 4)
	panel_box.add_child(_bag_grid)
	_panel_text = RichTextLabel.new()
	_panel_text.bbcode_enabled = true
	_panel_text.custom_minimum_size = Vector2(570, 330)
	_panel_text.add_theme_font_size_override("normal_font_size", 16)
	_panel_text.add_theme_font_size_override("bold_font_size", 17)
	# „Benutzen“ in der Tasche (z. B. die Bürste an der Statue)
	_panel_text.meta_clicked.connect(func(meta: Variant) -> void:
		var link := str(meta)
		if link == "testtasche" or link == "testbeute":
			_send({type = "test_tasche" if link == "testtasche" else "test_beute"})
			return
		if link.begins_with("wegwerfen:"):
			_discard_ask = link.trim_prefix("wegwerfen:")
			_fill_panel()
			return
		if link == "wegwerfen_ja" or link == "wegwerfen_nein":
			if link == "wegwerfen_ja":
				_send({type = "wegwerfen", gegenstand = _discard_ask})
			_discard_ask = ""
			_fill_panel()
			return
		if str(meta).begins_with("testgeld:"):
			_send({type = "test_geld", bronze = int(str(meta).trim_prefix("testgeld:"))})
			return
		_panel.visible = false
		_send({type = "benutzen", gegenstand = str(meta)}))
	panel_box.add_child(_panel_text)
	# Fußzeile der Tasche: links das Gold, rechts belegte Plätze
	_bag_footer = HBoxContainer.new()
	_bag_footer.add_theme_constant_override("separation", 6)
	panel_box.add_child(_bag_footer)
	# Testknöpfe der Tasche (nur in der Godot-Testversion)
	_bag_tests = HBoxContainer.new()
	_bag_tests.add_theme_constant_override("separation", 6)
	panel_box.add_child(_bag_tests)
	var close := Button.new()
	close.text = "Schließen"
	close.custom_minimum_size = Vector2(140, 40)
	close.size_flags_horizontal = Control.SIZE_SHRINK_END
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(func() -> void: _panel.visible = false)
	panel_box.add_child(close)

	# Lichtblitz über allem (Sternenfall)
	_flash_rect = ColorRect.new()
	_flash_rect.size = Vector2(1280, 720)
	_flash_rect.color = Color(1, 1, 1, 0)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_flash_rect)

	# Ladenfenster (Kaufen und Verkaufen)
	_shop_panel = _framed_panel()
	_shop_panel.position = Vector2(290, 130)
	_shop_panel.size = Vector2(700, 0)
	_shop_panel.visible = false
	root.add_child(_shop_panel)
	_buttons.append(_shop_panel)
	_shop_box = VBoxContainer.new()
	_shop_box.add_theme_constant_override("separation", 6)
	_shop_panel.add_child(_shop_box)

	# Beute-Fenster rechts neben der Tasche
	_loot_panel = _framed_panel()
	_loot_panel.position = Vector2(950, 130)
	_loot_panel.size = Vector2(320, 0)
	_loot_panel.visible = false
	root.add_child(_loot_panel)
	_buttons.append(_loot_panel)
	_loot_box = VBoxContainer.new()
	_loot_box.add_theme_constant_override("separation", 6)
	_loot_panel.add_child(_loot_box)

	# Pfeil am Bildrand zum nächsten Ziel
	_edge_arrow = Control.new()
	_edge_arrow.size = Vector2(1280, 720)
	_edge_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_edge_arrow.draw.connect(_draw_edge_arrow)
	root.add_child(_edge_arrow)

	# Kurze Meldungen oben in der Mitte („+30 Gold“, „Neuer Auftrag …“), über allen Fenstern
	_notices = VBoxContainer.new()
	_notices.position = Vector2(390, 80)
	_notices.size = Vector2(500, 0)
	_notices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_notices)


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 5)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _framed_panel() -> PanelContainer:
	# Rahmen kommt aus dem UI-Theme (assets/ui/asterfall_theme.tres)
	return PanelContainer.new()


## Schmuck in der Stadt (Festlaternen, Krater des Sternenfalls).
func _add_decoration(deco: Dictionary) -> void:
	var node := Node2D.new()
	node.position = cell_center(Vector2(deco.cell))
	var index := _deco_nodes.size()
	var art: String = deco.art
	node.set_meta("text", deco.get("text", ""))
	node.draw.connect(func() -> void: _draw_decoration(node, art, index))
	_add_map_node(node)
	_deco_nodes[node] = deco.cond
	if art == "festlaterne":
		_add_light(node, "laterne", Vector2(0, -58), LANTERN_COLORS[index % LANTERN_COLORS.size()].lerp(Color("ffd38a"), 0.4))
	elif art == "krater":
		_add_light(node, "splitter", Vector2(0, -4))


## Hängt einen Lichtschein an eine Grafik (verschwindet mit ihr, wenn sie unsichtbar wird).
func _add_light(node: Node2D, art: String, offset: Vector2, color := Color(0, 0, 0, 0)) -> void:
	var light := Licht.erzeugen(art, color)
	light.position = offset
	node.add_child(light)


func _draw_decoration(node: Node2D, art: String, index: int) -> void:
	match art:
		"festlaterne":
			var color: Color = LANTERN_COLORS[index % LANTERN_COLORS.size()]
			var flicker := 0.85 + 0.15 * sin(_time * 5.0 + index)
			node.draw_circle(Vector2(0, -58), 26.0, Color(color, 0.18 * flicker))
			node.draw_rect(Rect2(-2, -50, 4, 50), Color("3a2a1a"))
			node.draw_rect(Rect2(-7, -66, 14, 16), Color(color.lightened(0.3), flicker))
			node.draw_rect(Rect2(-8, -68, 16, 3), Color("3a2a1a"))
		"wegweiser":
			# Text "links|rechts": oben ein Schild nach links (Westen), darunter eins nach rechts
			node.draw_rect(Rect2(-2, -64, 4, 64), Color("5a3a22"))
			var font := ThemeDB.fallback_font
			var parts := str(node.get_meta("text", "")).split("|")
			for i in parts.size():
				if parts[i] == "":
					continue
				var w := font.get_string_size(parts[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 14.0
				var y := -66.0 + i * 20.0
				var dir := -1.0 if i == 0 else 1.0
				var near := 4.0 * -dir
				var far := near + w * dir
				node.draw_colored_polygon(PackedVector2Array([Vector2(near, y), Vector2(far, y), Vector2(far + 8.0 * dir, y + 8.0),
						Vector2(far, y + 16.0), Vector2(near, y + 16.0)]), Color("a07a4c"))
				node.draw_string(font, Vector2(minf(near, far) + 7.0, y + 12.0), parts[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("2a1c10"))
		"bluete":
			# Grünwacht blüht auf (Urbaum gerettet)
			for i in 6:
				var at := Vector2((i % 3 - 1) * 12.0, -float(i / 3) * 8.0 - 4.0)
				node.draw_circle(at, 5.0, [Color("ffb8d8"), Color("ffe680"), Color("ffffff")][i % 3])
				node.draw_circle(at, 2.0, Color("f2c14e"))
		"welk":
			# Welkes Laub (Urbaum gefällt)
			for i in 5:
				var at := Vector2((i - 2) * 9.0, float(i % 2) * 5.0 - 2.0)
				node.draw_colored_polygon(PackedVector2Array([at + Vector2(-5, 0), at + Vector2(0, -4), at + Vector2(5, 0), at + Vector2(0, 3)]),
						[Color("8a6a3a"), Color("6a5030"), Color("9a7a4a")][i % 3])
		"krater":
			node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.5))
			node.draw_circle(Vector2.ZERO, 34.0, Color(0.1, 0.08, 0.15, 0.85))
			node.draw_arc(Vector2.ZERO, 34.0, 0, TAU, 32, Color(0.95, 0.9, 1.0, 0.5 + 0.3 * sin(_time * 3.0)), 3.0)
			node.draw_set_transform_matrix(Transform2D.IDENTITY)
			node.draw_circle(Vector2(0, -4), 5.0, Color(0.95, 0.9, 1.0, 0.8))


## Besondere Effekte: Beim Sternenfall wird es kurz taghell und das Bild wackelt.
func _on_effect(player_id: String, effect: String) -> void:
	if player_id != local_id or effect != "sternenfall":
		return
	_flash_rect.color = Color(1, 1, 1, 0.9)
	var tween := create_tween()
	tween.tween_property(_flash_rect, "color:a", 0.0, 1.6)
	var shake := create_tween()
	for i in 8:
		shake.tween_property(_camera, "offset", Vector2(randf_range(-10, 10), randf_range(-8, 8)), 0.05)
	shake.tween_property(_camera, "offset", Vector2.ZERO, 0.05)


func _go_menu() -> void:
	# Zurück ins Menü beendet das Zusammenspielen (beim Gastgeber für alle)
	if Netz.online():
		SaveGame.save(local_player())
		_no_save = true
		Netz.stop()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


# --- Chat (nur beim Zusammenspielen) --------------------------------------------
# PC: Enter öffnet die Eingabe, Enter schickt ab, Esc bricht ab. Handy: Knopf „Chat“.

func _build_chat(root: Control) -> void:
	_chat_button = Button.new()
	_chat_button.text = "Chat (Enter)"
	_chat_button.position = Vector2(16, 140)
	_chat_button.size = Vector2(130, 40)
	_chat_button.add_theme_font_size_override("font_size", 15)
	_chat_button.focus_mode = Control.FOCUS_NONE
	_chat_button.pressed.connect(_open_chat)
	root.add_child(_chat_button)
	_buttons.append(_chat_button)
	_chat_input = LineEdit.new()
	_chat_input.position = Vector2(154, 140)
	_chat_input.size = Vector2(420, 40)
	_chat_input.max_length = Netz.CHAT_MAX_LENGTH
	_chat_input.placeholder_text = "Nachricht an alle in Kreuzweg …"
	_chat_input.add_theme_font_size_override("font_size", 16)
	_chat_input.visible = false
	_chat_input.text_submitted.connect(_on_chat_submitted)
	_chat_input.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
			_close_chat()
			_chat_input.accept_event())
	root.add_child(_chat_input)
	_buttons.append(_chat_input)
	_chat_box = VBoxContainer.new()
	_chat_box.position = Vector2(16, 188)
	_chat_box.custom_minimum_size = Vector2(460, 0)
	_chat_box.add_theme_constant_override("separation", 2)
	_chat_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_chat_box)
	# Was vorher geschrieben wurde (z. B. während eines Kampfes), gleich zeigen
	var start := maxi(Netz.chat_log.size() - CHAT_LINES, 0)
	for i in range(start, Netz.chat_log.size()):
		var entry: Dictionary = Netz.chat_log[i]
		_add_chat_line(entry.name, entry.text)


func _open_chat() -> void:
	if _chat_input == null:
		return
	_chat_input.visible = true
	_chat_input.grab_focus()
	for line in _chat_lines:
		line.set_meta("zeit", _time)


func _close_chat() -> void:
	_chat_input.text = ""
	_chat_input.release_focus()
	_chat_input.visible = false


func _on_chat_submitted(text: String) -> void:
	Netz.chat(text)
	_close_chat()


func _on_chat(id: String, sender: String, text: String) -> void:
	_add_chat_line(sender, text)
	if sender != "" and _characters.has(id):
		_characters[id].say(text)


func _add_chat_line(sender: String, text: String) -> void:
	var line := Label.new()
	line.text = "%s: %s" % [sender, text] if sender != "" else text
	line.add_theme_font_size_override("font_size", 15)
	line.add_theme_color_override("font_color", Color("ffffff") if sender != "" else Color("b8c4d0"))
	line.add_theme_color_override("font_outline_color", Color.BLACK)
	line.add_theme_constant_override("outline_size", 5)
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.custom_minimum_size = Vector2(460, 0)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.set_meta("zeit", _time)
	_chat_box.add_child(line)
	_chat_lines.append(line)
	while _chat_lines.size() > CHAT_LINES:
		_chat_lines.pop_front().queue_free()


## Alte Nachrichten blenden langsam aus (bei offener Eingabe bleiben alle sichtbar).
func _update_chat() -> void:
	if _chat_box == null:
		return
	var open := _chat_input.visible
	for line in _chat_lines:
		var age := _time - float(line.get_meta("zeit", _time))
		line.modulate.a = 1.0 if open else clampf((CHAT_FADE_SECONDS - age) / 3.0, 0.0, 1.0)


# --- Gruppe (nur beim Zusammenspielen) ------------------------------------------
# Mitspieler antippen → Menü (einladen; als Gruppenführer: entfernen, Führung übergeben).
# Rechts oben das Gruppenfenster mit Namen, Stufe und Leben, ★ = Gruppenführer.

func _build_group(root: Control) -> void:
	_group_panel = _framed_panel()
	_group_panel.position = Vector2(1040, 66)
	_group_panel.custom_minimum_size = Vector2(226, 0)
	_group_panel.visible = false
	root.add_child(_group_panel)
	_buttons.append(_group_panel)
	_group_box = VBoxContainer.new()
	_group_box.add_theme_constant_override("separation", 4)
	_group_panel.add_child(_group_box)

	_player_menu = _framed_panel()
	_player_menu.position = Vector2(500, 150)
	_player_menu.custom_minimum_size = Vector2(280, 0)
	_player_menu.visible = false
	root.add_child(_player_menu)
	_buttons.append(_player_menu)
	_player_menu_box = VBoxContainer.new()
	_player_menu_box.add_theme_constant_override("separation", 6)
	_player_menu.add_child(_player_menu_box)

	_invite_panel = _framed_panel()
	_invite_panel.position = Vector2(440, 300)
	_invite_panel.custom_minimum_size = Vector2(400, 0)
	_invite_panel.visible = false
	root.add_child(_invite_panel)
	_buttons.append(_invite_panel)
	var invite_box := VBoxContainer.new()
	invite_box.add_theme_constant_override("separation", 8)
	_invite_panel.add_child(invite_box)
	_invite_label = _label("", 18, Color.WHITE)
	_invite_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_invite_label.custom_minimum_size = Vector2(370, 0)
	invite_box.add_child(_invite_label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	invite_box.add_child(row)
	for info: Array in [["Annehmen", "annehmen"], ["Ablehnen", "ablehnen"]]:
		var answer: String = info[1]
		row.add_child(_menu_button(info[0], func() -> void:
			Netz.group_action(answer)
			_invite_panel.visible = false))
	_update_group()


func _menu_button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(170, 44)
	button.add_theme_font_size_override("font_size", 16)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	return button


func _open_player_menu(id: String) -> void:
	var p: PlayerState = state.players[id]
	for child in _player_menu_box.get_children():
		child.queue_free()
	_player_menu_box.add_child(_label(p.display_name, 20, Color("f2c14e")))
	var buttons := 0
	if not Netz.in_my_group(id) and (Netz.group.is_empty() or Netz.i_lead()):
		_player_menu_box.add_child(_menu_button("In Gruppe einladen", _player_action.bind("einladen", id)))
		buttons += 1
	if Netz.in_my_group(id) and Netz.i_lead():
		_player_menu_box.add_child(_menu_button("Führung übergeben", _player_action.bind("fuehrung", id)))
		_player_menu_box.add_child(_menu_button("Aus Gruppe nehmen", _player_action.bind("entfernen", id)))
		buttons += 2
	if buttons == 0:
		var hint := _label("In deiner Gruppe." if Netz.in_my_group(id) else "Nur der Gruppenführer kann einladen.", 15, Color("cccccc"))
		_player_menu_box.add_child(hint)
	_player_menu_box.add_child(_menu_button("Schließen", func() -> void: _player_menu.visible = false))
	_player_menu.reset_size()
	_player_menu.visible = true


func _player_action(action: String, id: String) -> void:
	Netz.group_action(action, id)
	_player_menu.visible = false


func _on_group_invited(_from_id: String, from_name: String) -> void:
	_invite_label.text = "%s lädt dich in die Gruppe ein." % from_name
	_invite_panel.reset_size()
	_invite_panel.visible = true


## Gruppenfenster neu aufbauen (Mitglieder, Stufe, Leben, wer gerade kämpft).
func _update_group() -> void:
	if _group_panel == null:
		return
	for child in _group_box.get_children():
		child.queue_free()
	var members: Array = Netz.group.get("members", [])
	_group_panel.visible = not members.is_empty()
	if members.is_empty():
		return
	_group_box.add_child(_label("Gruppe (%d/%d)" % [members.size(), Gruppen.MAX_SIZE], 17, Color("f2c14e")))
	for m: Dictionary in members:
		var star := "★ " if m.id == Netz.group.leader else ""
		var color := Color("8affc1") if m.id == local_id else GROUP_NAME_COLOR
		_group_box.add_child(_label(star + str(m.name), 16, color))
		var info := "Stufe %d · Leben %d" % [m.level, m.leben]
		if not m.in_stadt:
			info += " · kämpft gerade"
		_group_box.add_child(_label(info, 13, Color("dddddd")))
		# Leben (in der Stadt immer voll; im gemeinsamen Kampf später die echte Leiste)
		var bar := ColorRect.new()
		bar.color = Color("5ac85a")
		bar.custom_minimum_size = Vector2(200, 5)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_group_box.add_child(bar)
	_group_box.add_child(_menu_button("Gruppe verlassen", func() -> void: Netz.group_action("verlassen")))
	_group_panel.reset_size()


## Verbindung kurz weg: Hinweis zeigen, das Spiel verbindet von selbst neu.
func _on_reconnecting(attempt: int, tries: int) -> void:
	if not _no_save:
		SaveGame.save(local_player())
	if _reconnect_label == null:
		_reconnect_label = _label("", 24, Color("fff3b0"))
		_reconnect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_reconnect_label.size = Vector2(1280, 40)
		_reconnect_label.position = Vector2(0, 330)
		_flash_rect.get_parent().add_child(_reconnect_label)
	_reconnect_label.text = "Verbindung weg – verbinde neu (Versuch %d von %d) …" % [attempt, tries]


## Wieder verbunden: die Stadt mit dem gespeicherten Fortschritt neu betreten.
func _on_reconnected() -> void:
	_no_save = true
	_skip_leave = true
	get_tree().reload_current_scene.call_deferred()


## Verbindung zum Gastgeber verloren: zurück ins Menü (der Spielstand ist auf dem Gerät gespeichert).
func _on_net_lost() -> void:
	_no_save = true
	get_tree().set_meta("netz_meldung", "Die Verbindung zum Gastgeber ist abgerissen. Dein Fortschritt ist gespeichert.")
	get_tree().change_scene_to_file.call_deferred("res://scenes/zusammen.tscn")


## Spielstand löschen und von vorn beginnen.
func _restart() -> void:
	_no_save = true
	SaveGame.delete()
	get_tree().reload_current_scene()


## Steuerknopf und Aktions-Knopf nur auf Geräten mit Touchscreen zeigen.
func _set_touch_ui(on: bool) -> void:
	_touch_ui = on
	_action_button.visible = on
	_stick_layer.queue_redraw()


func _draw_stick() -> void:
	if not _touch_ui:
		return
	var active := _stick_index != -1
	var center := _stick_origin if active else STICK_HOME
	_stick_layer.draw_circle(center, STICK_RADIUS, Color(0, 0, 0, 0.35 if active else 0.18))
	_stick_layer.draw_arc(center, STICK_RADIUS, 0, TAU, 48, Color(1, 0.9, 0.6, 0.7 if active else 0.3), 3.0)
	var knob := center + _stick_vec * STICK_RADIUS
	_stick_layer.draw_circle(knob, 30.0, Color(1, 0.9, 0.6, 0.75 if active else 0.3))


# --- Gespräch, Anzeige oben, Meldungen, Fenster --------------------------------

## Zeigt das Gespräch des eigenen Spielers so, wie es im Zustand steht.
func _update_dialog() -> void:
	var view := state.dialog_view(local_player())
	if view == _dialog_shown:
		return
	_dialog_shown = view
	_dialog.visible = not view.is_empty()
	_action_button.text = "Weiter" if _dialog.visible else "Reden"
	if view.is_empty():
		return
	_dialog_name.text = view.wer
	_dialog_text.text = view.text
	for child in _dialog_answers.get_children():
		child.queue_free()
	var answers: Array = view.antworten
	# Gemeinsame Szene: Stimmen zählen, wer spricht, wer zuschaut
	var scene: Dictionary = view.get("szene", {})
	var watching: bool = scene.get("rolle", "") == "zuschauen"
	var markers: Array = view.get("zeichen", [])
	for i in answers.size():
		var button := Button.new()
		button.text = "%d. %s" % [i + 1, answers[i]]
		# Antworten, die die Hauptgeschichte weiterbringen, tragen das gelbe Zeichen wie die NPCs („!“ oder „?“)
		var marker: String = markers[i] if i < markers.size() else ""
		if marker != "":
			button.text = "      " + button.text
			var sign := _label(marker, 24, Color("ffd34d"))
			sign.position = Vector2(12, 1)
			button.add_child(sign)
		if not scene.is_empty():
			var votes: int = scene.stimmen[i]
			if votes > 0:
				button.text += "   (%d %s)" % [votes, "Stimme" if votes == 1 else "Stimmen"]
			if scene.meine == i:
				button.text = "✔ " + button.text
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(920, 38)
		button.add_theme_font_size_override("font_size", 17)
		button.focus_mode = Control.FOCUS_NONE
		button.disabled = watching
		button.pressed.connect(func() -> void: _send({type = "dialog_choose", index = i}))
		_dialog_answers.add_child(button)
	var speaking: bool = scene.is_empty() or scene.rolle == "spricht"
	_dialog_next.visible = answers.is_empty() and speaking
	if not scene.is_empty():
		_dialog_answers.add_child(_scene_status(scene, answers.size()))
	# Viele Antworten: Fenster wächst nach oben, damit es nicht aus dem Bild ragt
	_place_dialog.call_deferred()


## Zeile unter einem gemeinsamen Gespräch: wer spricht, Stand der Abstimmung, Knopf zum Verlassen.
func _scene_status(scene: Dictionary, answer_count: int) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	var text := ""
	match scene.rolle:
		"zuschauen":
			text = "Du schaust zu: Du bist in der Geschichte an einer anderen Stelle (oder hast das schon erlebt)."
		_:
			if answer_count > 0:
				text = "Abstimmung: noch %d offen · %d s · Bei Gleichstand entscheidet der Gruppenführer." % [scene.offen, scene.zeit] \
						if scene.offen > 0 else "Alle haben gewählt."
			elif scene.rolle != "spricht":
				text = "%s blättert weiter …" % scene.sprecher
	if scene.rolle != "spricht":
		text = ("Gemeinsam mit %s. " % scene.sprecher) + text
	var label := _label(text, 14, Color("9fe8ff"))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(740, 0)
	row.add_child(label)
	var leave := Button.new()
	leave.text = "Szene verlassen"
	leave.custom_minimum_size = Vector2(160, 34)
	leave.add_theme_font_size_override("font_size", 14)
	leave.focus_mode = Control.FOCUS_NONE
	leave.pressed.connect(func() -> void: _send({type = "szene_verlassen"}))
	row.add_child(leave)
	return row


## Ladenfenster: wird neu aufgebaut, sobald sich Laden, Gold oder Tasche ändern.
func _is_tamer() -> bool:
	return str(local_player().progress.flags.get("klasse", "")) == "tamer" and local_player().progress.flags.has("monster")


## Rudel-Fenster: Platz 1 kämpft, 2 und 3 unterstützen (sichtbar im Kampf), 4 bis 6 zum Tauschen. Bei Tilda: Stall.
## Nach dem Zähmen mit vollem Gepäck geht es von selbst auf und bietet den Tausch an.
func _update_pack() -> void:
	var p := local_player()
	var tamer := _is_tamer()
	_pack_button.visible = tamer
	var fresh := int(p.progress.flags.get("stall_neu", -1))
	var show := tamer and (_pack_open or fresh >= 0) and not p.in_dialog()
	var pack: Array = p.progress.flags.get("monster", [])
	var stall: Array = p.progress.flags.get("stall", [])
	var key := "" if not show else "%s|%s|%d|%s" % [str(pack), str(stall), fresh, str(state.at_stall(p))]
	if key == _pack_shown:
		return
	_pack_shown = key
	_pack_panel.visible = show
	for child in _pack_box.get_children():
		child.queue_free()
	if not show:
		return
	_pack_box.add_child(_label("Dein Rudel (%d / %d)" % [pack.size(), Sandbox.MAX_MONSTERS], 22, Color("f2c14e")))
	if fresh >= 0 and fresh < stall.size():
		_pack_box.add_child(_label("%s ist im Stall. Gegen eins aus dem Gepäck tauschen?" % WorldState.monster_name(stall[fresh]), 17, Color("8fd36b")))
	else:
		_pack_box.add_child(_label("Platz 1 kämpft, 2 und 3 unterstützen im Kampf, 4 bis 6 kannst du einwechseln.", 15, Color(1, 1, 1, 0.75)))
	for i in pack.size():
		var role := "kämpft" if i == 0 else ("unterstützt" if i < Sandbox.MONSTERS_IN_FIGHT else "zum Tauschen")
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var name_label := _label("%d. %s  (%s)" % [i + 1, WorldState.monster_name(pack[i]), role], 16, Color.WHITE)
		name_label.custom_minimum_size = Vector2(330, 0)
		row.add_child(name_label)
		if fresh >= 0:
			row.add_child(_small_button("Tauschen", func() -> void: _send({type = "rudel", aktion = "tauschen", index = i})))
		else:
			if i > 0:
				row.add_child(_small_button("Nach vorn", func() -> void: _send({type = "rudel", aktion = "hoch", index = i})))
			if state.at_stall(p) and pack.size() > 1:
				row.add_child(_small_button("In den Stall", func() -> void: _send({type = "rudel", aktion = "ablegen", index = i})))
		_pack_box.add_child(row)
	if fresh >= 0:
		_pack_box.add_child(_small_button("Im Stall lassen", func() -> void: _send({type = "rudel", aktion = "behalten"})))
	elif state.at_stall(p):
		_pack_box.add_child(_label("Stall bei Tilda (%d)" % stall.size(), 18, Color("9fe8ff")))
		for i in stall.size():
			var row := HBoxContainer.new()
			var name_label := _label(WorldState.monster_name(stall[i]), 16, Color.WHITE)
			name_label.custom_minimum_size = Vector2(330, 0)
			row.add_child(name_label)
			if pack.size() < Sandbox.MAX_MONSTERS:
				row.add_child(_small_button("Mitnehmen", func() -> void: _send({type = "rudel", aktion = "holen", index = i})))
			_pack_box.add_child(row)
	elif not stall.is_empty():
		_pack_box.add_child(_label("Im Stall bei Tilda warten noch %d Monster." % stall.size(), 15, Color(1, 1, 1, 0.75)))
	var close := _small_button("Schließen", func() -> void: _pack_open = false)
	close.size_flags_horizontal = Control.SIZE_SHRINK_END
	close.visible = fresh < 0
	_pack_box.add_child(close)
	_pack_panel.reset_size()


func _small_button(text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(120, 34)
	button.add_theme_font_size_override("font_size", 14)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	return button


func _update_shop() -> void:
	var p := local_player()
	var key := "" if p.shop == "" else "%s|%d|%s|%s" % [p.shop, p.progress.gold, str(p.progress.items), str(p.progress.bank)]
	if key == _shop_shown:
		return
	_shop_shown = key
	_shop_panel.visible = p.shop != ""
	for child in _shop_box.get_children():
		child.queue_free()
	if p.shop == "":
		return
	var shop: Dictionary = GameData.get_file("laeden").get(p.shop, {})
	if shop.get("bank", false):
		_fill_bank(p)
		_add_shop_close()
		return
	var title := _label("%s  ·  %s" % [shop.get("name", p.shop), Geld.text(p.progress.gold)], 22, Color("f2c14e"))
	_shop_box.add_child(UiStil.titel_mit_banner(title))
	_shop_box.add_child(_label(GameData.text("laden_kaufen"), 17, Color("9fe8ff")))
	for ware in state.shop_wares(p.shop):
		var item := GameData.item(ware.gegenstand)
		var row := _shop_row("%s – %s" % [item.get("name", ware.gegenstand), item.get("beschreibung", "")],
				"%s · %s" % [GameData.text("laden_kaufen"), Geld.text(ware.preis)], ware.gegenstand)
		row.button.pressed.connect(func() -> void: _send({type = "kaufen", gegenstand = ware.gegenstand}))
		if p.progress.gold < ware.preis:
			row.button.modulate = Color(1, 1, 1, 0.5)
		_shop_box.add_child(row.box)
	_shop_box.add_child(_label(GameData.text("laden_verkaufen"), 17, Color("9fe8ff")))
	var any := false
	for item_id: String in p.progress.items:
		var price := state.sell_price(p.shop, item_id)
		if price <= 0:
			continue
		any = true
		var row := _shop_row("%d × %s" % [p.progress.items[item_id], GameData.item_name(item_id)],
				"%s · %s" % [GameData.text("laden_verkaufen"), Geld.text(price)], item_id)
		row.button.pressed.connect(func() -> void: _send({type = "verkaufen", gegenstand = item_id}))
		_shop_box.add_child(row.box)
	if not any:
		_shop_box.add_child(_label(GameData.text("laden_nichts_verkaufen"), 15, Color(1, 1, 1, 0.6)))
	_add_shop_close()


func _add_shop_close() -> void:
	var close := Button.new()
	close.text = GameData.text("schliessen")
	close.custom_minimum_size = Vector2(140, 40)
	close.size_flags_horizontal = Control.SIZE_SHRINK_END
	close.focus_mode = Control.FOCUS_NONE
	close.pressed.connect(func() -> void: _send({type = "laden_zu"}))
	_shop_box.add_child(close)
	_shop_panel.reset_size()


## Bankfenster (im Ladenfenster): links was in der Tasche ist (Einlagern), darunter was in der Bank liegt (Abholen).
## Jede Bankstelle zeigt dieselbe Bank.
func _fill_bank(p: PlayerState) -> void:
	var title := _label(GameData.text("bank_titel"), 22, Color("f2c14e"))
	_shop_box.add_child(UiStil.titel_mit_banner(title))
	# Beide Listen in einem Bereich mit Bildlaufleiste (Tasche 30 und Bank 20 Plätze passen nicht auf einmal)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(690, 400)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_shop_box.add_child(scroll)
	var list := VBoxContainer.new()
	scroll.add_child(list)
	list.add_child(_label(GameData.text("bank_tasche"), 17, Color("9fe8ff")))
	if p.progress.items.is_empty():
		list.add_child(_label(GameData.text("bank_tasche_leer"), 15, Color(1, 1, 1, 0.6)))
	for item_id: String in p.progress.bag_slots():
		if item_id == "":
			continue
		var row := _shop_row("%d × %s" % [p.progress.item_count(item_id), GameData.item_name(item_id)], GameData.text("bank_einlagern"), item_id)
		row.button.icon = null
		row.button.pressed.connect(func() -> void: _send({type = "einlagern", gegenstand = item_id}))
		if not p.progress.bank_has_room(item_id):
			row.button.modulate = Color(1, 1, 1, 0.5)
		list.add_child(row.box)
	list.add_child(_label(GameData.text("bank_inhalt", [p.progress.bank.size(), p.progress.bank_size]), 17, Color("9fe8ff")))
	if p.progress.bank.is_empty():
		list.add_child(_label(GameData.text("bank_leer"), 15, Color(1, 1, 1, 0.6)))
	for item_id: String in p.progress.bank:
		var row := _shop_row("%d × %s" % [int(p.progress.bank[item_id]), GameData.item_name(item_id)], GameData.text("bank_abholen"), item_id)
		row.button.icon = null
		row.button.pressed.connect(func() -> void: _send({type = "abholen", gegenstand = item_id}))
		if not p.progress.has_room(item_id):
			row.button.modulate = Color(1, 1, 1, 0.5)
		list.add_child(row.box)


## Beute-Fenster: zeigt Beute, die nach einem Sieg nicht mehr in die Tasche gepasst hat.
## „Nehmen“ geht, sobald in der Tasche Platz ist; „Liegen lassen“ gibt sie auf.
func _update_loot() -> void:
	var p := local_player()
	var loot := p.progress.loot
	var key := "" if loot.is_empty() else "%s|%s" % [str(loot), str(p.progress.items)]
	if key == _loot_shown:
		return
	_loot_shown = key
	_loot_panel.visible = not loot.is_empty()
	for child in _loot_box.get_children():
		child.queue_free()
	if loot.is_empty():
		return
	_loot_box.add_child(_label(GameData.text("beute"), 22, Color("f2c14e")))
	var hint := _label(GameData.text("beute_erklaerung"), 14, Color(1, 1, 1, 0.75))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(290, 0)
	_loot_box.add_child(hint)
	for item_id: String in loot:
		var row := HBoxContainer.new()
		var icon := BagSlot.new()
		icon.show_item(item_id, int(loot[item_id]), false)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)
		var name_label := _label(GameData.item_name(item_id), 15, Color.WHITE)
		name_label.custom_minimum_size = Vector2(120, 0)
		name_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(name_label)
		var take := _small_button(GameData.text("beute_nehmen"), func() -> void: _send({type = "beute_nehmen", gegenstand = item_id}))
		take.custom_minimum_size = Vector2(90, 34)
		take.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if not p.progress.has_room(item_id):
			take.modulate = Color(1, 1, 1, 0.5)
		row.add_child(take)
		_loot_box.add_child(row)
	var buttons := HBoxContainer.new()
	buttons.add_child(_small_button(GameData.text("beute_tasche"), func() -> void:
		if not (_panel.visible and _panel_mode == "tasche"):
			_toggle_panel("tasche")))
	buttons.add_child(_small_button(GameData.text("beute_lassen"), func() -> void: _send({type = "beute_lassen"})))
	_loot_box.add_child(buttons)
	_loot_panel.reset_size()


## Eine Zeile im Laden: Text links, Knopf rechts. Gibt {box, button} zurück.
func _shop_row(text: String, button_text: String, item_id := "") -> Dictionary:
	var box := HBoxContainer.new()
	# Symbol des Gegenstands vor der Zeile (gemalte Bilder aus assets/gegenstaende/)
	var tex := BagSlot.icon_texture(item_id) if item_id != "" else null
	if tex != null:
		var icon := TextureRect.new()
		icon.texture = tex
		icon.custom_minimum_size = Vector2(36, 36)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		box.add_child(icon)
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(430, 0)
	label.add_theme_font_size_override("font_size", 15)
	box.add_child(label)
	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(190, 40)
	button.add_theme_font_size_override("font_size", 15)
	button.focus_mode = Control.FOCUS_NONE
	button.icon = UiStil.symbol("gold")
	button.expand_icon = false
	button.add_theme_constant_override("icon_max_width", 22)
	box.add_child(button)
	return {box = box, button = button}


func _update_hud() -> void:
	var progress := local_player().progress
	var xp_span := progress.xp_range()
	var xp_text := GameData.text("hud_max") if xp_span.y < 0 else GameData.text("hud_erfahrung", [progress.xp, xp_span.y])
	_hud.text = GameData.text("hud", [progress.level, xp_text, Geld.text(progress.gold)])
	if _panel.visible:
		_fill_panel()


func _on_notice(player_id: String, text: String) -> void:
	if player_id != local_id:
		return
	var label: Control
	var kind := _notice_kind(text)
	if kind.is_empty():
		label = _label(text, 20, Color("fff3b0"))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.custom_minimum_size = Vector2(500, 0)
	else:
		label = UiStil.meldung(text, kind[0], kind[1])
	_notices.add_child(label)
	var tween := create_tween()
	tween.tween_interval(NOTICE_SECONDS)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)


## Welcher Rahmen und welches Symbol zu einer Meldung passen. Die Meldungen kommen als fertiger Text
## (auch übers Netz), darum wird am Text erkannt, aus welcher Vorlage in data/texte.json er stammt.
## Leer = einfache Textzeile wie bisher (z. B. Ortsnamen).
func _notice_kind(text: String) -> Array:
	if _notice_patterns.is_empty():
		for entry: Array in NOTICE_STYLES:
			var regex := RegEx.new()
			var template := GameData.text(entry[0])
			regex.compile("(?s)^" + _escape_regex(template).replace("%d", "-?\\d+").replace("%s", ".+") + "$")
			_notice_patterns.append([regex, entry[1], entry[2]])
	for pattern: Array in _notice_patterns:
		if pattern[0].search(text):
			return [pattern[1], pattern[2]]
	return []


static func _escape_regex(template: String) -> String:
	var out := ""
	for c in template:
		out += "\\" + c if c in ".^$*+?()[]{}|\\" else c
	return out


## Automatisch speichern, sobald sich der Fortschritt des eigenen Spielers ändert.
func _on_progress_changed(player_id: String) -> void:
	if player_id == local_id and not _no_save:
		SaveGame.save(local_player())


func _toggle_panel(mode: String) -> void:
	if _panel.visible and _panel_mode == mode:
		_panel.visible = false
		return
	_panel_mode = mode
	_panel.visible = true
	_fill_panel()


func _fill_panel() -> void:
	var p := local_player()
	var lines: PackedStringArray = []
	var quest_list := _panel_mode == "auftraege" and _quest_tab != "erfolge"
	_quest_tabs.visible = _panel_mode == "auftraege"
	_quest_view.visible = quest_list
	_panel_text.visible = not quest_list
	_stats_head.visible = _panel_mode == "werte"
	_rep_box.visible = _panel_mode == "werte"
	for child in _rep_box.get_children():
		child.queue_free()
	_bag_grid.visible = _panel_mode == "tasche"
	_bag_footer.visible = _panel_mode == "tasche"
	_bag_tests.visible = _panel_mode == "tasche"
	_panel_text.custom_minimum_size.y = {"tasche": 120.0, "werte": 220.0}.get(_panel_mode, 330.0)
	for tab_button: Button in _quest_tabs.get_children():
		tab_button.button_pressed = tab_button.get_meta("tab") == _quest_tab
	if _panel_mode == "auftraege":
		_panel_title.text = GameData.text("auftragsbuch")
		if quest_list:
			_fill_quests(p, _quest_tab == "fertig")
			return
		var achievements := GameData.get_file("erfolge")
		for id: String in achievements:
			if id != "hinweis" and p.progress.flags.has("erfolg:" + id):
				lines.append("%s [color=#f2c14e]%s[/color] – %s" % [UiStil.bild("kristall"), achievements[id].name, achievements[id].beschreibung])
		if lines.is_empty():
			lines.append("Noch keine Erfolge.")
	elif _panel_mode == "werte":
		_panel_title.text = GameData.text("werte")
		var klasse := p.progress.battle_class()
		if p.progress.flags.has("klasse_bestaetigt") and Sandbox.CLASSES.has(klasse):
			# Nach der Klassenwahl: Werte der eigenen Klasse (so kämpft man in der Wildnis)
			var data: Dictionary = Sandbox.CLASSES[klasse]
			var bonus := p.progress.level - 1
			_fill_stats_head(p, data.title, data.hp + BattleState.LEVEL_HP * bonus, data.mana + BattleState.LEVEL_MANA * bonus if data.mana > 0 else 0)
			lines.append(UiStil.bild("pfeil") + " [b]Tempo: %d[/b]" % data.tempo)
			lines.append(UiStil.bild("schwert") + " [b]Stärke: %d %%[/b] (Schaden und Heilung)" % roundi(BattleRequest.hero_power(p.progress.level) * 100))
			if klasse == "tamer":
				var pack: PackedStringArray = []
				for id: String in p.progress.flags.get("monster", []):
					pack.append(Sandbox.MONSTERS.get(id, Sandbox.ENEMIES.get(id, {name = id})).name)
				lines.append("[b]Rudel:[/b] %s" % (", ".join(pack) if not pack.is_empty() else GameData.text("rudel_leer")))
			_reputation_lines(p)
			lines.append("")
			lines.append(GameData.text("werte_klasse", [BattleState.LEVEL_HP, BattleState.LEVEL_MANA, roundi(BattleRequest.HERO_POWER_PER_LEVEL * 100)]))
			_panel_text.text = "\n".join(lines)
			return
		var stats := Grundwerte.for_level(p.progress.level)
		_fill_stats_head(p, "Novize", stats.leben, stats.mana)
		var chosen := str(p.progress.flags.get("klasse", ""))
		if p.progress.flags.has("klasse_bestaetigt") and Sandbox.CLASSES.has(chosen):
			# Klasse gewählt, aber noch nicht beim Lehrmeister gelernt: noch Novize
			lines.append("[color=#f2c14e]%s[/color]" % GameData.text("werte_noch_novize", [Sandbox.CLASSES[chosen].title,
					GameData.get_file("klassen").get(chosen, {}).get("lehrmeister", "?")]))
			lines.append("")
		lines.append(UiStil.bild("schwert") + " [b]%s: %d[/b]     " % [Grundwerte.NAMES.angriff, stats.angriff]
				+ UiStil.bild("pfeil") + " [b]%s: %d[/b]" % [Grundwerte.NAMES.tempo, stats.tempo])
		lines.append("")
		lines.append(GameData.text("werte_naechste", [Grundwerte.growth_text()]))
		lines.append("")
		lines.append(GameData.text("werte_erklaerung"))
		lines.append("")
		lines.append("[color=#a0a0a0]%s[/color]" % GameData.text("werte_spaeter"))
	else:
		_panel_title.text = GameData.text("tasche")
		var slots := _fill_bag(p)
		_fill_bag_footer(p, slots)
		var picked := str(slots[_bag_selected]) if _bag_selected >= 0 and _bag_selected < slots.size() else ""
		if picked != "":
			var item := GameData.item(picked)
			var use := "  [url=%s][color=#5ab8ff][%s][/color][/url]" % [picked, GameData.text("benutzen")] if item.has("benutzen") else ""
			if state.can_discard(p, picked):
				use += "  [url=wegwerfen:%s][color=#ff8a7a][%s][/color][/url]" % [picked, GameData.text("wegwerfen")]
			lines.append("[b]%d × %s[/b] – %s%s" % [p.progress.item_count(picked), item.get("name", picked), item.get("beschreibung", ""), use])
			if _discard_ask == picked:
				lines.append("[color=#ff8a7a]%s[/color]  [url=wegwerfen_ja][color=#ff8a7a][%s][/color][/url]  [url=wegwerfen_nein][color=#5ab8ff][%s][/color][/url]" % [
						GameData.text("wegwerfen_frage", [p.progress.item_count(picked), item.get("name", picked)]),
						GameData.text("wegwerfen_ja"), GameData.text("wegwerfen_nein")])
		elif p.progress.items.is_empty():
			lines.append(GameData.text("tasche_leer"))
		else:
			lines.append("[color=#a0a0a0]%s[/color]" % GameData.text("tasche_tipp"))
		# Kreuzweg-Karten (Sammlung)
		var cards: Dictionary = p.progress.flags.get("karten", {})
		if not cards.is_empty():
			var names: PackedStringArray = []
			for id: String in cards:
				names.append("%s%s" % [KartenSpiel.card(id).name, " ×%d" % cards[id] if int(cards[id]) > 1 else ""])
			lines.append("")
			lines.append("[b]Kreuzweg-Karten (%d):[/b] %s" % [names.size(), ", ".join(names)])
	_panel_text.text = "\n".join(lines)


## Auftragsbuch: links die Liste (Hauptaufträge zuerst), rechts der gewählte Auftrag.
func _fill_quests(p: PlayerState, done_tab: bool) -> void:
	for child in _quest_list.get_children():
		child.queue_free()
	var ids: Array[String] = []
	for main: bool in [true, false]:
		for id: String in p.progress.quests:
			var q := GameData.quest(id)
			if q.is_empty() or (p.progress.quests[id] == "abgegeben") != done_tab or (not q.get("neben", false)) != main:
				continue
			ids.append(id)
	if not ids.has(_quest_selected):
		_quest_selected = ids[0] if not ids.is_empty() else ""
	for id in ids:
		var q := GameData.quest(id)
		var quest_state: String = p.progress.quests[id]
		var button := Button.new()
		button.theme_type_variation = &"Menueintrag"
		button.toggle_mode = true
		button.button_pressed = id == _quest_selected
		button.focus_mode = Control.FOCUS_NONE
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size = Vector2(236, 50)
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_constant_override("icon_max_width", 22)
		var marker := "band_rolle" if q.get("neben", false) else "band_ausrufe"
		button.icon = UiStil.symbol({"fertig": "frage", "abgegeben": "kaestchen_an"}.get(quest_state, marker))
		button.text = "%s\n%s" % [q.get("titel", id), _quest_kind(p, id)]
		if q.get("neben", false):
			button.add_theme_color_override("font_color", SIDE_COLOR)
		button.pressed.connect(func() -> void:
			_quest_selected = id
			_fill_panel())
		_quest_list.add_child(button)
	if ids.is_empty():
		_quest_detail.text = GameData.text("auftragsbuch_leer") if not done_tab else "Noch nichts abgeschlossen."
		return
	_quest_detail.text = _quest_details(p, _quest_selected)


## „Hauptauftrag“ oder „Nebenauftrag (2)“ mit Wegweiser-Nummer.
func _quest_kind(p: PlayerState, id: String) -> String:
	if not GameData.quest(id).get("neben", false):
		return "Hauptauftrag"
	var number := state.side_number(p, id)
	return GameData.text("nebenauftrag") + (" (%d)" % number if number > 0 else "")


## Rechte Seite im Auftragsbuch: Titel, Art, Beschreibung, Ziele mit Häkchen und die Belohnung mit Symbolen.
func _quest_details(p: PlayerState, id: String) -> String:
	var q := GameData.quest(id)
	var quest_state: String = p.progress.quests[id]
	var lines: PackedStringArray = []
	lines.append("[font_size=21][color=#f2c14e]%s[/color][/font_size]" % q.get("titel", id))
	lines.append("[color=#a0a0a0]%s · %s[/color]" % [_quest_kind(p, id), GameData.text("stand_" + quest_state)])
	lines.append("")
	lines.append(q.get("beschreibung", ""))
	if quest_state != "abgegeben":
		lines.append("")
		for goal: Dictionary in q.get("ziele", []):
			if state.goal_shown(p, goal):
				var done := quest_state == "fertig" or state.goal_done(p, goal)
				lines.append("%s %s" % [UiStil.bild("kaestchen_an" if done else "kaestchen", 18), state.goal_text(p, goal)])
	var reward: Dictionary = q.get("belohnung", {})
	if not reward.is_empty():
		lines.append("")
		lines.append("[color=#f2c14e][b]Belohnung[/b][/color]")
		var parts: PackedStringArray = []
		if int(reward.get("gold", 0)) > 0:
			parts.append("%s %s" % [UiStil.bild("gold", 22), Geld.text(int(reward.gold))])
		if int(reward.get("erfahrung", 0)) > 0:
			parts.append("%s %d Erfahrung" % [UiStil.bild("kristall", 22), int(reward.erfahrung)])
		var items: Dictionary = reward.get("gegenstaende", {})
		for item_id: String in items:
			parts.append("%s %d × %s" % [UiStil.bild("tasche", 22), int(items[item_id]), GameData.item_name(item_id)])
		lines.append("     ".join(parts))
	return "\n".join(lines)


## Kopf der Werte: Bild der eigenen Figur im Goldrahmen, Name, Stufe, Erfahrung, Leben und Mana als Leisten.
func _fill_stats_head(p: PlayerState, title: String, hp: int, mana: int) -> void:
	for child in _stats_head.get_children():
		child.queue_free()
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override("panel", UiStil.bilderrahmen())
	frame.custom_minimum_size = Vector2(120, 120)
	var portrait := TextureRect.new()
	portrait.texture = FighterView.portrait(p.look if p.look != "" else "novize")
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = FighterView.filter_fuer(portrait.texture)
	frame.add_child(portrait)
	_stats_head.add_child(frame)
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 6)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stats_head.add_child(right)
	right.add_child(_label("%s · %s · Stufe %d" % [p.display_name, title, p.progress.level], 18, Color("f3ead8")))
	var xp_span := p.progress.xp_range()
	if xp_span.y > 0:
		right.add_child(_stat_bar("Erfahrung", p.progress.xp - xp_span.x, xp_span.y - xp_span.x, "gruen",
				"%d / %d" % [p.progress.xp, xp_span.y]))
	right.add_child(_stat_bar("Leben", hp, hp, "rot", "%d / %d" % [hp, hp]))
	if mana > 0:
		right.add_child(_stat_bar("Mana", mana, mana, "blau", "%d / %d" % [mana, mana]))


## Eine Zeile mit Name, Leiste aus dem UI-Set (Füllung rot, blau oder grün) und Zahl.
func _stat_bar(name: String, value: int, max_value: int, fill: String, text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var label := _label(name, 16, Color("f3ead8"))
	label.custom_minimum_size.x = 90
	row.add_child(label)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = maxi(max_value, 1)
	bar.value = value
	bar.custom_minimum_size = Vector2(250, 22)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.add_theme_stylebox_override("fill", UiStil.fuellung(fill))
	row.add_child(bar)
	row.add_child(_label(text, 15, Color.WHITE))
	return row


## Fußzeile der Tasche wie im UI-Entwurf: Münze und Gold links, Tasche und belegte Plätze rechts.
func _fill_bag_footer(p: PlayerState, slots: Array) -> void:
	for child in _bag_footer.get_children():
		child.queue_free()
	var used := p.progress.used_slots()
	for part: Array in [["gold", Geld.text(p.progress.gold)], [], ["tasche", "%d / %d" % [used, Progress.BAG_SIZE]]]:
		if part.is_empty():
			var spacer := Control.new()
			spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_bag_footer.add_child(spacer)
			continue
		var icon := TextureRect.new()
		icon.texture = UiStil.symbol(part[0])
		icon.custom_minimum_size = Vector2(26, 26)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_bag_footer.add_child(icon)
		var full: bool = part[0] == "tasche" and used >= Progress.BAG_SIZE
		_bag_footer.add_child(_label(part[1], 18, Color("ff8a7a") if full else Color("f3ead8")))
	for child in _bag_tests.get_children():
		child.queue_free()
	if OS.is_debug_build():
		# Testknöpfe (nur in der Godot-Testversion): Geld dazugeben, Tasche füllen, Beute-Fenster ausprobieren
		var tests := _bag_tests
		for bronze: int in [75, 9900]:
			tests.add_child(_small_button("%s +%s" % [GameData.text("test_geld"), Geld.text(bronze)], func() -> void:
				_send({type = "test_geld", bronze = bronze})
				_fill_panel()))
		for test: Array in [["test_tasche", "test_tasche_fuellen"], ["test_beute", "test_beute"]]:
			tests.add_child(_small_button(GameData.text(test[1]), func() -> void:
				_send({type = test[0]})
				_fill_panel()))


## Füllt die Kästchen der Tasche. Die Kästchen bleiben dieselben, damit Ziehen und Ablegen nicht abbricht.
func _fill_bag(p: PlayerState) -> Array:
	var slots := p.progress.bag_slots()
	while _bag_grid.get_child_count() < slots.size():
		var slot := BagSlot.new()
		slot.index = _bag_grid.get_child_count()
		slot.moved.connect(func(from: int, to: int) -> void:
			if _bag_selected == from:
				_bag_selected = to
			_send({type = "tasche_tauschen", von = from, nach = to})
			_fill_panel())
		slot.picked.connect(func(index: int) -> void:
			_bag_selected = index
			_discard_ask = ""
			_fill_panel())
		_bag_grid.add_child(slot)
	for slot: BagSlot in _bag_grid.get_children():
		var id := str(slots[slot.index]) if slot.index < slots.size() else ""
		slot.show_item(id, p.progress.item_count(id), slot.index == _bag_selected)
	return slots


## Ruf bei den Gruppen der Regionen als Leiste aus dem UI-Set (nur Gruppen, bei denen man schon Ruf hat).
## 11 Felder: wenig grüne Felder = abgelehnt, die Hälfte = neutral, alle = geschätzt.
func _reputation_lines(p: PlayerState) -> void:
	var shown := false
	for key: String in p.progress.flags:
		if not key.begins_with("ruf:"):
			continue
		if not shown:
			_rep_box.add_child(_label("Ruf", 17, Color("f2c14e")))
			shown = true
		var value := int(p.progress.flags[key])
		var cells := UiStil.RUF_ZELLEN.size() - 1
		var filled := roundi((value + WorldState.REPUTATION_MAX) / float(2 * WorldState.REPUTATION_MAX) * cells)
		var color := Color("6dff8a") if value > 20 else (Color("ff7070") if value < -20 else Color("c8c8c8"))
		var word := GameData.text("ruf_gut" if value > 20 else ("ruf_schlecht" if value < -20 else "ruf_neutral"))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var name_label := _label(GameData.text("ruf_" + key.substr(4)), 15, Color("f3ead8"))
		name_label.custom_minimum_size.x = 210
		row.add_child(name_label)
		row.add_child(UiStil.ruf_leiste(filled))
		row.add_child(_label(word, 15, color))
		_rep_box.add_child(row)
	if shown:
		_rep_box.add_child(UiStil.trennlinie())


## Belohnung für den Sieg-Bildschirm. Die Monsterkarte wird schon jetzt ausgewürfelt, wenn diese Welt die echte ist
## (allein spielen); beim Zusammenspielen würfelt der Server danach und meldet sie wie bisher.
func _prepare_reward(kampf_id: String) -> void:
	var roll := not Netz.online()
	BattleRequest.reward = state.battle_reward(local_player(), kampf_id, roll)
	if roll:
		BattleRequest.reward["karte_gewuerfelt"] = true


## Ein Kampf beginnt (z. B. eine Lektion bei Ye): speichern und zum Kampfbildschirm wechseln.
func _on_battle_requested(player_id: String, kampf_id: String) -> void:
	if player_id != local_id:
		return
	var progress := local_player().progress
	BattleRequest.player_look = local_player().look
	_prepare_reward(kampf_id)
	if BattleRequest.prepare(kampf_id, progress.level, progress.item_count("heiltrank"), progress.battle_class(),
			progress.flags.get("monster", [])):
		SaveGame.save(local_player())
		get_tree().change_scene_to_file.call_deferred("res://scenes/kampf.tscn")


## Gruppenkampf beginnt (Netz hat den Kampf schon vorbereitet): speichern und zum Kampfbildschirm.
func _on_group_battle(kampf_id: String) -> void:
	_prepare_reward(kampf_id)
	SaveGame.save(local_player())
	get_tree().change_scene_to_file.call_deferred("res://scenes/kampf.tscn")


func _place_dialog() -> void:
	_dialog.reset_size()
	_dialog.position.y = minf(440.0, 710.0 - _dialog.size.y)


## Ein Dialog wechselt zu einem anderen Bildschirm (Klassenwahl, Abspann): erst speichern.
func _on_scene(player_id: String, scene: String) -> void:
	if player_id != local_id:
		return
	SaveGame.save(local_player())
	# "klassenwahl:Glutoase" = die Klassen einer Region beim Gesandten ansehen
	var parts := scene.split(":")
	if parts[0] == "klassenwahl":
		Klassenwahl.region = parts[1] if parts.size() > 1 else ""
	# "abspann:gruenwacht" = Ende der Region Grünwacht (Rückblick), "abspann" = Ende von Akt 1
	if parts[0] == "abspann":
		Abspann.variante = parts[1] if parts.size() > 1 else ""
	# "kartenspiel:marv" = eine Partie Kreuzweg-Karten gegen diese Figur, mit den eigenen stärksten Karten
	if parts[0] == "kartenspiel":
		KartenTisch.gegner = parts[1] if parts.size() > 1 else ""
		KartenTisch.deck = KartenSpiel.best_deck(local_player().progress.flags.get("karten", {}))
		get_tree().change_scene_to_file.call_deferred("res://scenes/kartentisch.tscn")
		return
	# "erinnerung:rowan" = eine Erinnerungs-Szene aus data/erinnerungen.json
	if parts[0] == "erinnerung":
		Erinnerung.id = parts[1] if parts.size() > 1 else ""
	get_tree().change_scene_to_file.call_deferred("res://scenes/%s.tscn" % parts[0])


## Kleiner Werbe-Stand eines Gesandten: Tresen, zwei Pfosten, gestreiftes Sonnendach mit Bogenkante, Schild mit der Region.
func _draw_stand(node: Node2D, color: Color, text: String) -> void:
	node.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
	node.draw_circle(Vector2.ZERO, 26.0, Color(0, 0, 0, 0.25))
	node.draw_set_transform_matrix(Transform2D.IDENTITY)
	var wood := Color("6e4a2c")
	# Pfosten
	node.draw_line(Vector2(-22, 2), Vector2(-22, -46), wood.darkened(0.2), 3.0)
	node.draw_line(Vector2(22, 2), Vector2(22, -46), wood.darkened(0.2), 3.0)
	# Tresen mit Tuch in der Farbe der Region
	node.draw_colored_polygon(PackedVector2Array([Vector2(-24, -16), Vector2(24, -16), Vector2(22, 2), Vector2(-22, 2)]), wood)
	node.draw_colored_polygon(PackedVector2Array([Vector2(-18, -16), Vector2(18, -16), Vector2(16, -4), Vector2(-16, -4)]), color.darkened(0.15))
	node.draw_rect(Rect2(-26, -19, 52, 4), wood.lightened(0.15))
	# Ein paar Waren auf dem Tresen
	node.draw_circle(Vector2(-12, -22), 4.0, color.lightened(0.3))
	node.draw_rect(Rect2(2, -27, 8, 8), Color("d8c8a0"))
	node.draw_circle(Vector2(16, -22), 3.0, Color("f2c14e"))
	# Sonnendach: Streifen, vorne mit Bogenkante
	var stripes := 6
	for i in stripes:
		var x0 := -30.0 + i * 60.0 / stripes
		var x1 := x0 + 60.0 / stripes
		var col := color if i % 2 == 0 else Color("f3ead8")
		node.draw_colored_polygon(PackedVector2Array([Vector2(x0 * 0.8, -58), Vector2(x1 * 0.8, -58), Vector2(x1, -44), Vector2(x0, -44)]), col)
		node.draw_circle(Vector2((x0 + x1) * 0.5, -44), 5.0, col)
	# Schild
	var font := ThemeDB.fallback_font
	node.draw_string_outline(font, Vector2(-60, -64), text, HORIZONTAL_ALIGNMENT_CENTER, 120, 12, 4, Color.BLACK)
	node.draw_string(font, Vector2(-60, -64), text, HORIZONTAL_ALIGNMENT_CENTER, 120, 12, color.lightened(0.4))
