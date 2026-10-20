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
## Eine Chat-Nachricht für alle in Kreuzweg ist angekommen. Leerer Name = Hinweis des Spiels („Mira ist in Kreuzweg“).
signal chat_received(id: String, sender: String, text: String)
## Die eigene Gruppe hat sich geändert (siehe Netz.group)
signal group_changed
## Jemand lädt einen in seine Gruppe ein
signal group_invited(from_id: String, from_name: String)
## Kurze Meldung zur Gruppe („Mira ist der Gruppe beigetreten.“)
signal group_notice(text: String)

enum Mode { OFFLINE, HOST, SERVER, CLIENT }

const PORT := 8910
## Adresse des Online-Servers im Internet (Schritt 2, kostenloser Anbieter Render).
## Stimmt sie nicht (z. B. weil der Name beim Anbieter schon vergeben war), hier ändern.
const ONLINE_ADDRESS := "wss://asterfall-server.onrender.com"
## So lange wird auf den Online-Server gewartet (Sekunden). Der kostenlose Server schläft, wenn niemand spielt,
## und braucht dann bis zu einer Minute zum Aufwachen.
const ONLINE_WAIT := 120.0
## Alle so viele Sekunden meldet sich ein Mitspieler kurz beim Gastgeber, auch wenn er nur herumsteht
## (sonst hält der kostenlose Server die Runde für leer und schläft ein)
const PING_SECONDS := 30.0
## Mitspieler zeigen die anderen Figuren so viele Sekunden „in der Vergangenheit“. Dafür laufen sie gleichmäßig,
## auch wenn die Berichte des Gastgebers unregelmäßig ankommen (Internet).
const INTERP_DELAY := 0.2
## Bleiben Berichte aus (Aussetzer), läuft eine Figur höchstens so lange in ihrer Richtung weiter (Sekunden)
const EXTRAPOLATE_MAX := 0.6
## Ein Server ohne Grafik rechnet höchstens so oft pro Sekunde (spart Rechenzeit beim kostenlosen Anbieter)
const SERVER_FPS := 30
## Diese Befehle führt ein Mitspieler sofort auch bei sich aus, damit die eigene Figur ohne Verzögerung läuft
const PREDICTED := ["steer", "move", "talk", "use"]
## Chat: so viele Zeichen höchstens pro Nachricht
const CHAT_MAX_LENGTH := 120
## Chat: so viele Sekunden mindestens zwischen zwei Nachrichten eines Spielers (gegen Überfluten)
const CHAT_MIN_GAP := 0.6
## Chat: so viele Nachrichten werden aufgehoben (z. B. für die Rückkehr aus einem Kampf)
const CHAT_HISTORY := 30
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
## Die letzten Chat-Nachrichten: {id, name, text}
static var chat_log: Array[Dictionary] = []
## Nur für automatische Tests: fester Spielstand, damit kein echter Spielstand überschrieben wird
static var save_override := ""
## Die eigene Gruppe: {leader = Spieler, members = [{id, name, level, leben, in_stadt}, …]} oder leer
static var group := {}

## Merkt, welches Fenster gerade den normalen Spielstand benutzt (damit ein zweites Fenster auf demselben PC
## einen eigenen bekommt und sich die beiden nicht gegenseitig überschreiben)
const LOCK_PATH := "user://spielstand_in_benutzung.json"
const LOCK_SECONDS := 6.0

var _snapshot_timer := 0.0
var _lock_timer := 0.0
var _ping_timer := PING_SECONDS
## Kennung dieses Fensters für die Spielstand-Sperre
var _window_id := str(randi())
## Gastgeber: zuletzt geschickter eigener Zustand je Mitspieler (nur Änderungen werden geschickt)
var _sent_own := {}
## Mitspieler: die letzten Berichte des Gastgebers je Figur: [Zeit beim Gastgeber, Platz, Blickrichtung, läuft]
var _history := {}
## Mitspieler: Unterschied zwischen eigener Uhr und der Uhr des Gastgebers (kleinster gemessener Wert)
var _clock_offset := INF
## Mitspieler: seit wann die eigene Figur nicht mehr selbst läuft (Sekunden)
var _own_idle := 0.0
## Gastgeber: wann jeder Spieler zuletzt geschrieben hat
var _last_chat := {}
## Gastgeber: Namen der Mitspieler, die schon begrüßt wurden (Rückkehr aus einem Kampf zählt nicht als neu)
var _greeted := {}
## Gastgeber: Gruppen aller Spieler
var _groups: Gruppen
## Gastgeber: zuletzt geschickte Gruppen-Ansicht je Spieler (nur Änderungen werden geschickt)
var _sent_group := {}
## Gastgeber: letzte bekannte Stufe je Spieler (auch während er kämpft)
var _levels := {}


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
	Engine.max_fps = SERVER_FPS
	return _start_server("Server", "elf_m", Mode.SERVER)


static func _start_server(p_name: String, look: String, p_mode: Mode) -> Error:
	stop()
	var peer := WebSocketMultiplayerPeer.new()
	var port := server_port()
	var err := peer.create_server(port)
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
	node._groups = Gruppen.new()
	node._groups.notice.connect(node._on_group_notice)
	node._groups.invited.connect(node._on_group_invited)
	node._sent_group.clear()
	node._levels.clear()
	if p_mode == Mode.HOST:
		node._groups.set_player_name("p1", p_name)
	if not _api().peer_disconnected.is_connected(node._on_peer_disconnected):
		_api().peer_disconnected.connect(node._on_peer_disconnected)
	print("Netz: Gastgeber bereit auf Port %d" % port)
	return OK


## Port für Gastgeber und Server: Der Anbieter im Internet gibt ihn vor (PORT), sonst --port=… oder 8910.
static func server_port() -> int:
	var from_env := OS.get_environment("PORT")
	if from_env.is_valid_int():
		return int(from_env)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--port=") and arg.substr(7).is_valid_int():
			return int(arg.substr(7))
	return PORT


## Bei einem Gastgeber mitspielen. Adresse: "localhost", "192.168.0.5" oder eine volle Adresse ("wss://…").
static func join(address: String, p_name: String, look: String) -> Error:
	stop()
	var url := address.strip_edges()
	if url == "":
		url = "localhost"
	if not url.begins_with("ws://") and not url.begins_with("wss://"):
		url = "ws://%s:%d" % [url, PORT]
	var peer := WebSocketMultiplayerPeer.new()
	# Ein Server im Internet darf länger brauchen (er wacht vielleicht gerade auf)
	peer.handshake_timeout = ONLINE_WAIT if url.begins_with("wss://") else 5.0
	var err := peer.create_client(url)
	if err != OK:
		return err
	var node := _node()
	_api().multiplayer_peer = peer
	mode = Mode.CLIENT
	_set_me(p_name, look, "")
	world = WorldState.new()
	node._history.clear()
	node._clock_offset = INF
	for sig: Signal in [_api().connected_to_server, _api().connection_failed, _api().server_disconnected]:
		for c: Dictionary in sig.get_connections():
			sig.disconnect(c.callable)
	_api().connected_to_server.connect(node._on_connected)
	_api().connection_failed.connect(node._on_failed)
	_api().server_disconnected.connect(node._on_server_lost)
	return OK


## Verbindung beenden, zurück zum Allein-Spielen.
static func stop() -> void:
	chat_log.clear()
	group = {}
	if _instance != null and is_instance_valid(_instance):
		_instance._last_chat.clear()
		_instance._greeted.clear()
	if _api().multiplayer_peer is WebSocketMultiplayerPeer:
		_api().multiplayer_peer.close()
		_api().multiplayer_peer = OfflineMultiplayerPeer.new()
	mode = Mode.OFFLINE
	world = null
	my_id = ""
	if _instance != null and is_instance_valid(_instance) and _instance._owns_lock():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(LOCK_PATH))
	SaveGame.path = SaveGame.DEFAULT_PATH


## Schickt einen Befehl des eigenen Spielers an die Welt.
static func send(cmd: Dictionary) -> void:
	match mode:
		Mode.HOST:
			world.apply_command(my_id, cmd)
		Mode.CLIENT:
			_instance._c_command.rpc_id(1, cmd)
			# Laufen sofort selbst ausführen (der Gastgeber rechnet dasselbe und korrigiert nur, wenn es abweicht)
			if cmd.get("type", "") in PREDICTED:
				world.apply_command(my_id, cmd)


## Schickt eine Chat-Nachricht an alle in Kreuzweg.
static func chat(text: String) -> void:
	var clean := clean_chat(text)
	if clean == "":
		return
	match mode:
		Mode.HOST:
			_instance._chat_from(my_id, clean)
		Mode.CLIENT:
			_instance._c_chat.rpc_id(1, clean)


## Gruppe: "einladen", "annehmen", "ablehnen", "verlassen", "entfernen" oder "fuehrung" (Führung übergeben).
static func group_action(action: String, target := "") -> void:
	match mode:
		Mode.HOST:
			_instance._group_from(my_id, action, target)
		Mode.CLIENT:
			_instance._c_group.rpc_id(1, action, target)


static func in_my_group(id: String) -> bool:
	for m: Dictionary in group.get("members", []):
		if m.id == id:
			return true
	return false


static func i_lead() -> bool:
	return group.get("leader", "") == my_id


## Chat-Text aufräumen: keine Zeilenumbrüche, nicht zu lang.
static func clean_chat(text: String) -> String:
	return text.replace("\n", " ").replace("\r", " ").replace("\t", " ").strip_edges().left(CHAT_MAX_LENGTH)


## Der eigene Spieler betritt die Stadt (er steht schon in Netz.world, beim Mitspieler im Spiegelbild).
static func enter_world(p: PlayerState) -> void:
	if mode == Mode.CLIENT:
		_instance._c_join.rpc_id(1, p.display_name, p.look, p.progress.to_dict(), [p.cell.x, p.cell.y])


## Der eigene Spieler verlässt die Stadt (Kampf, Klassenwahl, Menü).
static func leave_world() -> void:
	if world == null:
		return
	world.remove_player(my_id)
	if _instance != null:
		_instance._history.erase(my_id)
	if mode == Mode.CLIENT and _api().multiplayer_peer is WebSocketMultiplayerPeer:
		_instance._c_leave.rpc_id(1)


static func _set_me(p_name: String, look: String, id: String) -> void:
	my_name = p_name
	my_look = look
	my_id = id
	# Beim Zusammenspielen gilt derselbe Spielstand wie allein (ein Charakter für alles).
	# Ausnahme: Benutzt ein anderes Fenster auf diesem Gerät ihn gerade, bekommt dieses Fenster einen eigenen.
	if save_override != "":
		SaveGame.path = save_override
	elif _node()._lock_taken_by_other():
		var safe := ""
		for ch in p_name.to_lower():
			if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
				safe += ch
		SaveGame.path = "user://spielstand_fenster_%s.json" % (safe if safe != "" else "spieler")
	else:
		SaveGame.path = SaveGame.DEFAULT_PATH
		_node()._write_lock()


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
	if online() and _owns_lock():
		_lock_timer -= delta
		if _lock_timer <= 0.0:
			_lock_timer = LOCK_SECONDS / 3.0
			_write_lock()
	if mode == Mode.HOST or mode == Mode.SERVER:
		world.tick(delta)
		_snapshot_timer -= delta
		if _snapshot_timer <= 0.0:
			_snapshot_timer = 1.0 / SNAPSHOT_RATE
			_send_snapshot()
			for id: String in world.players:
				_flush_own(id)
			_flush_groups()
	elif mode == Mode.CLIENT and world != null:
		_ping_timer -= delta
		if _ping_timer <= 0.0 and my_id != "":
			_ping_timer = PING_SECONDS
			_c_ping.rpc_id(1)
		_move_mirror(delta)


# --- Spielstand-Sperre (mehrere Fenster auf einem PC) ---------------------------

func _read_lock() -> Dictionary:
	if not FileAccess.file_exists(LOCK_PATH):
		return {}
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(LOCK_PATH))
	return data if data is Dictionary else {}


func _lock_taken_by_other() -> bool:
	var lock := _read_lock()
	return lock.get("fenster", _window_id) != _window_id \
			and Time.get_unix_time_from_system() - float(lock.get("zeit", 0.0)) < LOCK_SECONDS


func _owns_lock() -> bool:
	return SaveGame.path == SaveGame.DEFAULT_PATH and _read_lock().get("fenster", "") == _window_id


func _write_lock() -> void:
	var file := FileAccess.open(LOCK_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({fenster = _window_id, zeit = Time.get_unix_time_from_system()}))


# --- Gastgeber ------------------------------------------------------------------

func _send_snapshot() -> void:
	var list: Array = []
	for p: PlayerState in world.players.values():
		list.append([p.id, p.display_name, p.look, p.pos, p.facing, p.is_walking()])
	_s_snapshot.rpc(_clock(), list)


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
	if _greeted.has(id):
		_s_chat.rpc("", "", "%s hat das Spiel verlassen." % _greeted[id])
		_greeted.erase(id)
	_sent_own.erase(id)
	_last_chat.erase(id)
	if _groups != null:
		_groups.remove_player(id)
	_sent_group.erase(id)
	_levels.erase(id)


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
	_groups.set_player_name(id, p.display_name)
	_sent_own.erase(id)
	print("Netz: %s ist in Kreuzweg" % p.display_name)
	if not _greeted.has(id):
		_greeted[id] = p.display_name
		_s_chat.rpc("", "", "%s ist in Kreuzweg." % p.display_name)


## Lebenszeichen eines Mitspielers (hält den kostenlosen Server wach)
@rpc("any_peer", "reliable")
func _c_ping() -> void:
	pass


## Gruppen-Wunsch eines Mitspielers
@rpc("any_peer", "reliable")
func _c_group(action: String, target: String) -> void:
	if mode == Mode.HOST or mode == Mode.SERVER:
		_group_from("p%d" % multiplayer.get_remote_sender_id(), action, target)


func _group_from(id: String, action: String, target: String) -> void:
	if _groups == null or not _groups.names.has(id):
		return
	match action:
		"einladen":
			_groups.invite(id, target, _clock())
		"annehmen":
			_groups.accept(id, _clock())
		"ablehnen":
			_groups.decline(id)
		"verlassen":
			_groups.leave(id)
		"entfernen":
			_groups.kick(id, target)
		"fuehrung":
			_groups.promote(id, target)
	_flush_groups()


## Schickt jedem Spieler seine Gruppe, wenn sie sich geändert hat (Mitglieder, Führung, Stufe, wer gerade kämpft).
func _flush_groups() -> void:
	if _groups == null:
		return
	for id: String in world.players:
		_levels[id] = world.players[id].progress.level
	for id: String in _groups.names:
		var view := _group_view(id)
		var text := var_to_str(view)
		if _sent_group.get(id, "") == text:
			continue
		_sent_group[id] = text
		if id == my_id and mode == Mode.HOST:
			_s_group(view)
		elif _peer_of(id) > 1:
			_s_group.rpc_id(_peer_of(id), view)


func _group_view(id: String) -> Dictionary:
	var g := _groups.group(id)
	if g.is_empty():
		return {}
	var members: Array = []
	for m: String in g.members:
		var level: int = _levels.get(m, 1)
		members.append({id = m, name = _groups.names.get(m, "?"), level = level,
				leben = int(Grundwerte.for_level(level).leben), in_stadt = world.players.has(m)})
	return {leader = g.leader, members = members}


func _on_group_notice(id: String, text: String) -> void:
	if id == my_id and mode == Mode.HOST:
		_s_group_event("notice", text, "")
	elif _peer_of(id) > 1:
		_s_group_event.rpc_id(_peer_of(id), "notice", text, "")


func _on_group_invited(id: String, from_id: String, from_name: String) -> void:
	if id == my_id and mode == Mode.HOST:
		_s_group_event("einladung", from_id, from_name)
	elif _peer_of(id) > 1:
		_s_group_event.rpc_id(_peer_of(id), "einladung", from_id, from_name)


## Die eigene Gruppe (vom Gastgeber)
@rpc("authority", "reliable")
func _s_group(view: Dictionary) -> void:
	group = view
	group_changed.emit()


## Gruppen-Ereignis für den eigenen Spieler: Meldung oder Einladung
@rpc("authority", "reliable")
func _s_group_event(kind: String, a: String, b: String) -> void:
	if kind == "einladung":
		group_invited.emit(a, b)
	else:
		group_notice.emit(a)


## Chat-Nachricht eines Mitspielers
@rpc("any_peer", "reliable")
func _c_chat(text: String) -> void:
	if mode == Mode.HOST or mode == Mode.SERVER:
		_chat_from("p%d" % multiplayer.get_remote_sender_id(), clean_chat(text))


## Gastgeber: prüft eine Nachricht und schickt sie an alle (nur wer in der Stadt steht, nicht zu oft).
func _chat_from(id: String, text: String) -> void:
	var p: PlayerState = world.players.get(id) if world != null else null
	if p == null or text == "":
		return
	var now := _clock()
	if now - float(_last_chat.get(id, -INF)) < CHAT_MIN_GAP:
		return
	_last_chat[id] = now
	_s_chat.rpc(id, p.display_name, text)


## Chat-Nachricht für alle (kommt auch beim Gastgeber selbst an)
@rpc("authority", "call_local", "reliable")
func _s_chat(id: String, sender: String, text: String) -> void:
	chat_log.append({id = id, name = sender, text = text})
	while chat_log.size() > CHAT_HISTORY:
		chat_log.pop_front()
	chat_received.emit(id, sender, text)


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


## Wo alle Spieler stehen (vom Gastgeber, mehrmals pro Sekunde, mit seiner Uhrzeit).
@rpc("authority", "unreliable_ordered")
func _s_snapshot(server_time: float, list: Array) -> void:
	if mode != Mode.CLIENT or world == null:
		return
	# Der schnellste Bericht zeigt am besten, wie die beiden Uhren zueinander stehen
	_clock_offset = minf(_clock_offset, _clock() - server_time)
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
		var history: Array = _history.get(id, [])
		history.append([server_time, entry[3], entry[4], entry[5]])
		while history.size() > 2 and float(history[1][0]) < server_time - 1.0:
			history.pop_front()
		_history[id] = history
	for id: String in world.players.keys():
		if id != my_id and not seen.has(id):
			world.remove_player(id)
			_history.erase(id)


## Bewegt die Figuren im Spiegelbild: die eigene sofort (vorhergesagt), die anderen gleichmäßig etwas verzögert.
func _move_mirror(delta: float) -> void:
	var render_time := _clock() - _clock_offset - INTERP_DELAY
	for id: String in _history:
		var p: PlayerState = world.players.get(id)
		if p == null:
			continue
		var sample := sample_history(_history[id], render_time)
		if id == my_id:
			_correct_own(p, delta, sample)
			continue
		# Kleine Sprünge (z. B. nach einem Aussetzer) weich ausgleichen, große sofort übernehmen
		var target: Vector2 = sample.pos
		p.pos = target if p.pos.distance_to(target) > 2.0 else p.pos.lerp(target, clampf(delta * 15.0, 0.0, 1.0))
		p.cell = Vector2i(p.pos.round())
		p.facing = sample.facing
		p.remote_walking = sample.walking
	var me: PlayerState = world.players.get(my_id)
	if me != null and not _history.has(my_id):
		world.move_player(me, delta)


## Eigene Figur: läuft sofort selbst. Weicht sie stark vom Gastgeber ab, wird sie zu ihm gezogen.
func _correct_own(me: PlayerState, delta: float, sample: Dictionary) -> void:
	me.remote_walking = false
	world.move_player(me, delta)
	var history: Array = _history[my_id]
	var latest: Array = history[history.size() - 1]
	var server_pos: Vector2 = latest[1]
	var server_walking: bool = latest[3]
	if me.is_walking():
		_own_idle = 0.0
		if me.pos.distance_to(server_pos) > 3.0:
			me.pos = server_pos
			me.path.clear()
	else:
		_own_idle += delta
		if _own_idle > 1.0 and server_walking:
			# Der Gastgeber lässt die Figur laufen (z. B. nach einem Antippen, das hier nicht vorhergesagt wurde)
			me.pos = sample.pos
			me.facing = sample.facing
			me.remote_walking = true
		elif _own_idle > 0.5 and me.pos.distance_to(server_pos) > 0.05:
			# Stehen geblieben: sanft auf den Platz, den der Gastgeber kennt
			me.pos = me.pos.move_toward(server_pos, WorldState.WALK_SPEED * delta)
			me.remote_walking = me.pos.distance_to(server_pos) > 0.3
	me.cell = Vector2i(me.pos.round())


## Platz einer Figur zu einem Zeitpunkt, zwischen zwei Berichten des Gastgebers verrechnet.
static func sample_history(history: Array, time: float) -> Dictionary:
	var last: Array = history[history.size() - 1]
	if time >= float(last[0]):
		# Noch kein neuer Bericht: Eine laufende Figur läuft kurz in ihrer Richtung weiter
		if bool(last[3]) and history.size() >= 2:
			var before: Array = history[history.size() - 2]
			var span := float(last[0]) - float(before[0])
			if span > 0.0001:
				var velocity := (Vector2(last[1]) - Vector2(before[1])) / span
				return {pos = Vector2(last[1]) + velocity * minf(time - float(last[0]), EXTRAPOLATE_MAX), facing = last[2], walking = true}
		return {pos = last[1], facing = last[2], walking = last[3]}
	var first: Array = history[0]
	if time <= float(first[0]):
		return {pos = first[1], facing = first[2], walking = first[3]}
	for i in range(history.size() - 1, 0, -1):
		var a: Array = history[i - 1]
		var b: Array = history[i]
		if time >= float(a[0]):
			var t := (time - float(a[0])) / maxf(float(b[0]) - float(a[0]), 0.0001)
			return {pos = Vector2(a[1]).lerp(b[1], t), facing = b[2], walking = b[3] or a[3]}
	return {pos = first[1], facing = first[2], walking = first[3]}


static func _clock() -> float:
	return Time.get_ticks_usec() / 1000000.0


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
