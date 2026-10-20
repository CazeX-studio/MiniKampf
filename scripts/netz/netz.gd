class_name Netz
extends Node
## Zusammen spielen (Lernprojekt 4): Verbindung zwischen Spielern über das Netz (WebSocket, geht auch im Browser).
##
## Der Gastgeber (oder ein Server ohne Grafik) hat die einzige echte Welt (WorldState) und spielt sie weiter.
## Mitspieler schicken nur Befehle („steuern“, „rede mit Ye“) und bekommen zurück, wo alle stehen,
## dazu ihren eigenen Fortschritt, Meldungen und Kampf-Wünsche. Bei ihnen ist die Welt nur ein Spiegelbild.
##
## Aufruf von überall: Netz.host(...), Netz.join(...), Netz.send(befehl), Netz.stop().
## Wie Musik hängt sich der Knoten selbst an die Wurzel des Spiels und bleibt beim Szenenwechsel bestehen.
## Ein Server ohne Grafik startet mit: Godot --headless --path . -- --server

## Die Verbindung zum Gastgeber steht (nur Mitspieler)
signal connected
## Die Verbindung kam nicht zustande (nur Mitspieler)
signal connection_failed
## Die Verbindung ist abgerissen (nur Mitspieler)
signal disconnected

enum Mode { OFFLINE, HOST, SERVER, CLIENT }

const PORT := 8910
const MAX_PLAYERS := 4
## So oft pro Sekunde schickt der Gastgeber, wo alle stehen
const SNAPSHOT_RATE := 15.0
## Diese Figuren kann man sich aussuchen (Namen aus dem 0x72-Paket)
const LOOKS: Array[String] = ["elf_m", "elf_f", "knight_m", "knight_f", "wizzard_m", "wizzard_f", "lizard_m", "lizard_f"]

static var mode := Mode.OFFLINE
## Die Welt: beim Gastgeber die echte, bei Mitspielern das Spiegelbild. Offline: null.
static var world: WorldState
## Kennung des eigenen Spielers in der Welt ("p1" = Gastgeber)
static var my_id := ""
static var my_name := ""
static var my_look := "elf_m"
static var _instance: Netz

var _snapshot_timer := 0.0
## Gastgeber: zuletzt geschickter eigener Zustand je Mitspieler (nur Änderungen werden geschickt)
var _sent_own := {}
## Mitspieler: wohin die Figuren laufen (aus dem letzten Bericht des Gastgebers)
var _targets := {}


static func online() -> bool:
	return mode != Mode.OFFLINE


## Adresse dieses Geräts im eigenen Netz (WLAN), die Mitspieler beim Beitreten eingeben.
static func local_address() -> String:
	for address in IP.get_local_addresses():
		if address.begins_with("192.168.") or address.begins_with("10.") or address.begins_with("172."):
			return address
	return "localhost"


## Gastgeber werden: eigene Welt öffnen, Mitspieler können beitreten. Geht nicht im Browser.
static func host(p_name: String, look: String) -> Error:
	return _start_server(p_name, look, Mode.HOST)


## Server ohne eigenen Spieler (z. B. später im Internet).
static func serve() -> Error:
	return _start_server("Server", "elf_m", Mode.SERVER)


static func _start_server(p_name: String, look: String, p_mode: Mode) -> Error:
	stop()
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_server(PORT)
	if err != OK:
		return err
	var node := _node()
	_api().multiplayer_peer = peer
	mode = p_mode
	_set_me(p_name, look, "p1")
	world = WorldState.new()
	world.notice.connect(node._on_world_notice)
	world.progress_changed.connect(node._on_world_progress)
	world.battle_requested.connect(node._on_world_battle)
	world.effect_requested.connect(node._on_world_effect)
	world.scene_requested.connect(node._on_world_scene)
	if not _api().peer_disconnected.is_connected(node._on_peer_disconnected):
		_api().peer_disconnected.connect(node._on_peer_disconnected)
	print("Netz: Gastgeber bereit auf Port %d" % PORT)
	return OK


## Bei einem Gastgeber mitspielen. Adresse: "localhost", "192.168.0.5" oder eine volle Adresse ("wss://…").
static func join(address: String, p_name: String, look: String) -> Error:
	stop()
	var url := address.strip_edges()
	if url == "":
		url = "localhost"
	if not url.begins_with("ws://") and not url.begins_with("wss://"):
		url = "ws://%s:%d" % [url, PORT]
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_client(url)
	if err != OK:
		return err
	var node := _node()
	_api().multiplayer_peer = peer
	mode = Mode.CLIENT
	_set_me(p_name, look, "")
	world = WorldState.new()
	node._targets.clear()
	for sig: Signal in [_api().connected_to_server, _api().connection_failed, _api().server_disconnected]:
		for c: Dictionary in sig.get_connections():
			sig.disconnect(c.callable)
	_api().connected_to_server.connect(node._on_connected)
	_api().connection_failed.connect(node._on_failed)
	_api().server_disconnected.connect(node._on_server_lost)
	return OK


## Verbindung beenden, zurück zum Allein-Spielen.
static func stop() -> void:
	if _api().multiplayer_peer is WebSocketMultiplayerPeer:
		_api().multiplayer_peer.close()
		_api().multiplayer_peer = OfflineMultiplayerPeer.new()
	mode = Mode.OFFLINE
	world = null
	my_id = ""
	SaveGame.path = SaveGame.DEFAULT_PATH


## Schickt einen Befehl des eigenen Spielers an die Welt.
static func send(cmd: Dictionary) -> void:
	match mode:
		Mode.HOST:
			world.apply_command(my_id, cmd)
		Mode.CLIENT:
			_instance._c_command.rpc_id(1, cmd)


## Der eigene Spieler betritt die Stadt (er steht schon in Netz.world, beim Mitspieler im Spiegelbild).
static func enter_world(p: PlayerState) -> void:
	if mode == Mode.CLIENT:
		_instance._c_join.rpc_id(1, p.display_name, p.look, p.progress.to_dict(), [p.cell.x, p.cell.y])


## Der eigene Spieler verlässt die Stadt (Kampf, Klassenwahl, Menü).
static func leave_world() -> void:
	if world == null:
		return
	world.remove_player(my_id)
	if mode == Mode.CLIENT and _api().multiplayer_peer is WebSocketMultiplayerPeer:
		_instance._c_leave.rpc_id(1)


static func _set_me(p_name: String, look: String, id: String) -> void:
	my_name = p_name
	my_look = look
	my_id = id
	# Jeder Name hat beim Zusammenspielen einen eigenen Spielstand (so gehen auch mehrere Fenster auf einem PC)
	var safe := ""
	for ch in p_name.to_lower():
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
			safe += ch
	SaveGame.path = "user://spielstand_zusammen_%s.json" % (safe if safe != "" else "spieler")


## Die Netz-Schnittstelle des ganzen Spiels (gilt für alle Knoten, auch für diesen hier).
static func _api() -> MultiplayerAPI:
	return (Engine.get_main_loop() as SceneTree).get_multiplayer()


static func _node() -> Netz:
	if _instance != null and is_instance_valid(_instance):
		return _instance
	var tree := Engine.get_main_loop() as SceneTree
	_instance = Netz.new()
	_instance.name = "Netz"
	_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	tree.root.add_child(_instance)
	return _instance


func _process(delta: float) -> void:
	if mode == Mode.HOST or mode == Mode.SERVER:
		world.tick(delta)
		_snapshot_timer -= delta
		if _snapshot_timer <= 0.0:
			_snapshot_timer = 1.0 / SNAPSHOT_RATE
			_send_snapshot()
			for id: String in world.players:
				_flush_own(id)
	elif mode == Mode.CLIENT and world != null:
		# Figuren gleiten sanft zu dem Platz, den der Gastgeber zuletzt gemeldet hat
		for id: String in _targets:
			var p: PlayerState = world.players.get(id)
			if p == null:
				continue
			var target: Vector2 = _targets[id]
			p.pos = target if p.pos.distance_to(target) > 3.0 else p.pos.lerp(target, clampf(delta * 12.0, 0.0, 1.0))


# --- Gastgeber ------------------------------------------------------------------

func _send_snapshot() -> void:
	var list: Array = []
	for p: PlayerState in world.players.values():
		list.append([p.id, p.display_name, p.look, p.pos, p.facing, p.is_walking()])
	_s_snapshot.rpc(list)


## Schickt einem Mitspieler seinen eigenen Zustand (Gespräch, Laden, Fortschritt), wenn er sich geändert hat.
func _flush_own(id: String) -> void:
	var peer := _peer_of(id)
	var p: PlayerState = world.players.get(id)
	if peer <= 1 or p == null:
		return
	var data := {dialog = p.dialog, shop = p.shop, progress = p.progress.to_dict(), feld = [p.cell.x, p.cell.y]}
	var text := var_to_str(data)
	if _sent_own.get(id, "") == text:
		return
	_sent_own[id] = text
	_s_own.rpc_id(peer, data)


func _peer_of(id: String) -> int:
	return int(id.substr(1)) if id.begins_with("p") else 0


func _forward(id: String, kind: String, a: Variant, b: Variant = null) -> void:
	var peer := _peer_of(id)
	if peer <= 1:
		return
	# Erst den Fortschritt schicken, damit der Mitspieler beim Ereignis schon den neuen Stand hat
	_flush_own(id)
	_s_event.rpc_id(peer, kind, a, b)


func _on_world_notice(id: String, text: String) -> void:
	_forward(id, "notice", text)


func _on_world_progress(id: String) -> void:
	_forward(id, "progress", null)


func _on_world_battle(id: String, kampf_id: String) -> void:
	_forward(id, "battle", kampf_id)


func _on_world_effect(id: String, effect: String) -> void:
	_forward(id, "effect", effect)


func _on_world_scene(id: String, scene: String) -> void:
	_forward(id, "scene", scene)


func _on_peer_disconnected(peer: int) -> void:
	var id := "p%d" % peer
	if world != null and world.players.has(id):
		print("Netz: %s hat das Spiel verlassen" % world.players[id].display_name)
		world.remove_player(id)
	_sent_own.erase(id)


## Ein Mitspieler betritt die Stadt und bringt seinen Spielstand mit.
@rpc("any_peer", "reliable")
func _c_join(p_name: String, look: String, progress: Dictionary, cell: Array) -> void:
	if mode != Mode.HOST and mode != Mode.SERVER:
		return
	var peer := multiplayer.get_remote_sender_id()
	var id := "p%d" % peer
	var others := world.players.size() - (1 if world.players.has(id) else 0)
	if others >= MAX_PLAYERS:
		return
	var start := WorldState.start_cell()
	if cell.size() == 2 and world.is_walkable(Vector2i(int(cell[0]), int(cell[1]))):
		start = Vector2i(int(cell[0]), int(cell[1]))
	world.remove_player(id)
	var p := world.add_player(id, p_name.left(16), look if look in LOOKS else "elf_m", start)
	p.progress.load_dict(progress)
	_sent_own.erase(id)
	print("Netz: %s ist in Kreuzweg" % p.display_name)


@rpc("any_peer", "reliable")
func _c_leave() -> void:
	if world != null and (mode == Mode.HOST or mode == Mode.SERVER):
		world.remove_player("p%d" % multiplayer.get_remote_sender_id())


@rpc("any_peer", "reliable")
func _c_command(cmd: Dictionary) -> void:
	if world != null and (mode == Mode.HOST or mode == Mode.SERVER):
		world.apply_command("p%d" % multiplayer.get_remote_sender_id(), cmd)


# --- Mitspieler -----------------------------------------------------------------

func _on_connected() -> void:
	my_id = "p%d" % multiplayer.get_unique_id()
	connected.emit()


func _on_failed() -> void:
	stop()
	connection_failed.emit()


func _on_server_lost() -> void:
	stop()
	disconnected.emit()


## Wo alle Spieler stehen (vom Gastgeber, mehrmals pro Sekunde).
@rpc("authority", "unreliable_ordered")
func _s_snapshot(list: Array) -> void:
	if mode != Mode.CLIENT or world == null:
		return
	var seen := {}
	for entry: Array in list:
		var id: String = entry[0]
		seen[id] = true
		var p: PlayerState = world.players.get(id)
		if p == null:
			# Den eigenen Spieler legt die Stadt selbst an; erst wenn er dort steht, kommen die anderen dazu
			if id == my_id or not world.players.has(my_id):
				continue
			p = world.add_player(id, entry[1], entry[2], Vector2i(Vector2(entry[3]).round()))
		var pos: Vector2 = entry[3]
		_targets[id] = pos
		p.cell = Vector2i(pos.round())
		p.facing = entry[4]
		p.remote_walking = entry[5]
	for id: String in world.players.keys():
		if id != my_id and not seen.has(id):
			world.remove_player(id)
			_targets.erase(id)


## Eigener Zustand vom Gastgeber: Gespräch, Laden, Fortschritt.
@rpc("authority", "reliable")
func _s_own(data: Dictionary) -> void:
	if mode != Mode.CLIENT or world == null or not world.players.has(my_id):
		return
	var p: PlayerState = world.players[my_id]
	p.dialog = data.get("dialog", {})
	p.shop = data.get("shop", "")
	p.progress.load_dict(data.get("progress", {}))


## Ein Ereignis für den eigenen Spieler (Meldung, Fortschritt, Kampf, Effekt, Bildschirmwechsel).
@rpc("authority", "reliable")
func _s_event(kind: String, a: Variant, _b: Variant) -> void:
	if mode != Mode.CLIENT or world == null or not world.players.has(my_id):
		return
	match kind:
		"notice":
			world.notice.emit(my_id, a)
		"progress":
			world.progress_changed.emit(my_id)
		"battle":
			world.battle_requested.emit(my_id, a)
		"effect":
			world.effect_requested.emit(my_id, a)
		"scene":
			world.scene_requested.emit(my_id, a)
