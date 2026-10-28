class_name FighterView
extends Control
## Zeigt einen Kampfteilnehmer als animierte Pixel-Figur mit Namensschild und Leisten.
## Animationen: stehen (idle), laufen/angreifen (run), getroffen (hit).
## Antippen (Maus oder Finger) meldet den Teilnehmer, z. B. um ihn als Ziel zu wählen.

signal tapped(fighter: Fighter)

const SPRITE_PATH := "res://assets/0x72_dungeontileset_ii/%s_%s_anim_f%d.png"
## Eigene Figuren (z. B. Vega) liegen in assets/figuren/ und gehen vor dem 0x72-Paket.
## Sie sind größer gezeichnet (etwa 44 statt 28 Pixel hoch) und werden deshalb weniger stark vergrößert.
const OWN_SPRITE_PATH := "res://assets/figuren/%s_%s_anim_f%d.png"
const FIGHTER_SHADER := preload("res://shaders/fighter.gdshader")

## Welche Pixel-Figur zu welcher Klasse gehört (Platzhalter aus dem 0x72-Paket).
const LOOKS := {
	"tank": {sprite = "knight_m", scale = 4.0},
	"mechanic": {sprite = "knight_m", scale = 4.0, tint = Color(1.0, 0.82, 0.55)},
	"smith": {sprite = "knight_f", scale = 4.0, tint = Color(1.0, 0.86, 0.76)},
	"archer": {sprite = "elf_m", scale = 4.0},
	"blade": {sprite = "lizard_f", scale = 4.0, tint = Color(1.0, 0.82, 0.65)},
	"twilight": {sprite = "wizzard_m", scale = 4.0, tint = Color(0.82, 0.72, 1.0)},
	"tamer": {sprite = "lizard_m", scale = 4.0, tint = Color(0.85, 1.0, 0.75)},
	"ritualist": {sprite = "wizzard_f", scale = 4.0, tint = Color(1.0, 0.8, 0.85)},
	"quartermaster": {sprite = "wizzard_m", scale = 4.0, tint = Color(1.0, 0.9, 0.6)},
	"kunoichi": {sprite = "elf_f", scale = 4.0, tint = Color(1.0, 0.75, 0.88)},
	"singer": {sprite = "elf_f", scale = 4.0},
	# Novizen (Kreuzweg-Demo): der Spieler und die Mitstreiter
	"novize": {sprite = "elf_m", scale = 4.0},
	# Vega: eigene, fein gezeichnete Figur; fern = greift aus der Ferne an (ausholen, Geschoss)
	"vega": {sprite = "vega", scale = 3.0, fern = true},
	# Kofi: erster der sechs Novizen (Schwert und Schild, Nahkampf), Bilder aus tools/figur_bilder.py
	"kofi": {sprite = "kofi", scale = 3.0},
	# Mitschüler aus design.md: Tessa (übereifrig) und Gorm (ängstlich), Platzhalter bis zu eigenen Bildern
	"novize_tessa": {sprite = "elf_f", scale = 4.0, tint = Color(1.0, 0.88, 0.8)},
	"novize_gorm": {sprite = "knight_m", scale = 4.0, tint = Color(0.85, 0.95, 0.85)},
	# Begleiter
	"robot": {sprite = "big_zombie", scale = 2.5, tint = Color(0.72, 0.82, 1.0)},
	# Start-Monster aus Marcos Bildblättern (tools/monster_bilder.py)
	"moosling": {sprite = "moosling", scale = 1.0, angriffe = {"Dornenpeitsche": "attack2"}},
	"glutwelpe": {sprite = "glutwelpe", scale = 1.0, angriffe = {"Funkenregen": "spezial"}},
	"bachotter": {sprite = "bachotter", scale = 1.0, angriffe = {"Wasserstrahl": "wurf", "Welle": "spezial"}},
	# Rivale Kobalt (steht hinter seinem Monster)
	"kobalt": {sprite = "elf_m", scale = 4.0, tint = Color(0.75, 0.85, 1.0)},
	# Gegner
	"glutkobold": {sprite = "chort", scale = 4.0},
	"sumpfschleim": {sprite = "swampy", scale = 5.0, tint = Color(0.55, 0.75, 1.0)},
	"dornling": {sprite = "orc_shaman", scale = 4.5, tint = Color(0.8, 1.0, 0.7)},
	"sturmkobold": {sprite = "ice_zombie", scale = 5.0, tint = Color(0.9, 1.0, 0.95)},
	"funkenwicht": {sprite = "skelet", scale = 5.0, tint = Color(1.0, 0.95, 0.5)},
	"schattenhexe": {sprite = "necromancer", scale = 4.5, tint = Color(0.75, 0.65, 0.95)},
	"boss": {sprite = "ogre", scale = 5.0, tint = Color(0.88, 0.86, 1.0)},
	# Pilzhöhle
	"leuchtmotte": {sprite = "wogol", scale = 4.5, tint = Color(1.0, 1.0, 0.75)},
	"wurzelkriecher": {sprite = "muddy", scale = 5.0},
	"sporenwolf": {sprite = "zombie", scale = 4.5, tint = Color(0.85, 1.0, 0.8)},
	"glimmerkaefer": {sprite = "tiny_zombie", scale = 5.0, tint = Color(1.0, 1.0, 0.55)},
	"sporenkoenigin": {sprite = "big_demon", scale = 4.0, tint = Color(0.75, 1.0, 0.75)},
	"sporenling": {sprite = "swampy", scale = 4.5, tint = Color(1.0, 0.8, 1.0)},
	"wurzelmutter": {sprite = "big_zombie", scale = 4.5, tint = Color(0.8, 0.65, 0.5)},
	"knoten_vorne": {sprite = "ice_zombie", scale = 4.0, tint = Color(1.0, 0.95, 0.7)},
	"knoten_hinten": {sprite = "ice_zombie", scale = 4.0, tint = Color(1.0, 0.95, 0.7)},
	"vorbote": {sprite = "necromancer", scale = 6.5, tint = Color(0.45, 0.38, 0.65)},
	# Vor dem Stadttor (Grundausbildung)
	# Eigene Monster aus Marcos Bildblättern (tools/monster_bilder.py): fein gezeichnet, Größe 1.0.
	# "angriffe": welcher Angriff (Name aus Sandbox.ENEMIES) welche Animation zeigt, sonst "attack" bzw. "wurf".
	"feldschleim": {sprite = "feldschleim", scale = 1.0},
	"wiesenkobold": {sprite = "wiesenkobold", scale = 1.0, angriffe = {"Steinwurf": "wurf"}},
	"ruepelkobold": {sprite = "ruepelkobold", scale = 1.0},
	"kieselkobold": {sprite = "kieselkobold", scale = 1.0, angriffe = {"Kieselwurf": "wurf"}},
	"uebungs_ye": {sprite = "wizzard_m", scale = 4.0, tint = Color(0.8, 0.86, 0.95)},
	"sternenfresser": {sprite = "sternenfresser", scale = 1.0,
		angriffe = {"Leuchtender Biss": "attack2", "Splitterregen": "spezial"}},
	# Fenns Prüfung (Platzhalter-Bilder: Strohpuppen)
	"zielscheibe": {sprite = "zombie", scale = 4.0, tint = Color(1.0, 0.88, 0.55)},
	"laufscheibe": {sprite = "goblin", scale = 4.0, tint = Color(1.0, 0.9, 0.6)},
	"splitterbaer": {sprite = "ogre", scale = 5.5, tint = Color(0.85, 0.8, 1.0)},
	"bienenschwarm": {sprite = "imp", scale = 3.5, tint = Color(1.0, 0.9, 0.35)},
	# Kobalts Monster
	# Kobalts Monster: dieselben Bilder, etwas größer und dunkler gefärbt
	"kobalts_moosling": {sprite = "moosling", scale = 1.15, tint = Color(0.8, 0.95, 0.75), angriffe = {"Dornenpeitsche": "attack2"}},
	"kobalts_glutwelpe": {sprite = "glutwelpe", scale = 1.15, tint = Color(1.0, 0.82, 0.75), angriffe = {"Funkenregen": "spezial"}},
	"kobalts_bachotter": {sprite = "bachotter", scale = 1.15, tint = Color(0.8, 0.88, 1.0), angriffe = {"Wasserstrahl": "wurf", "Welle": "spezial"}},
	# Grünwacht
	"rindenbaer": {sprite = "ogre", scale = 4.5, tint = Color(0.75, 0.62, 0.45)},
	"windfalke": {sprite = "imp", scale = 4.0, tint = Color(0.85, 0.95, 1.0)},
	"donnerhirsch": {sprite = "chort", scale = 4.5, tint = Color(1.0, 0.92, 0.55)},
	"steinkroete": {sprite = "swampy", scale = 5.0, tint = Color(0.7, 0.68, 0.6)},
	"waldsporenling": {sprite = "muddy", scale = 4.0, tint = Color(0.75, 1.0, 0.65)},
	"wilder_moosling": {sprite = "moosling", scale = 1.0, angriffe = {"Dornenpeitsche": "attack2"}},
	"wilde_glutwelpe": {sprite = "glutwelpe", scale = 1.0, angriffe = {"Funkenregen": "spezial"}},
	"wilder_bachotter": {sprite = "bachotter", scale = 1.0, angriffe = {"Wasserstrahl": "wurf", "Welle": "spezial"}},
}
## Bilder pro Sekunde. attack, death, parry und victory haben bisher nur eigene Figuren (z. B. Vega);
## fehlen sie, nimmt die Anzeige wie bisher run bzw. hit.
## attack2, wurf und spezial: weitere Angriffe eigener Monster (siehe "angriffe" in LOOKS).
const ANIM_FPS := {"idle": 6.0, "run": 12.0, "hit": 8.0, "attack": 8.0, "death": 6.0, "parry": 6.0, "victory": 5.0,
		"attack2": 8.0, "wurf": 8.0, "spezial": 6.0, "cast": 6.0}
## Diese Animationen laufen einmal durch und bleiben auf dem letzten Bild stehen (die anderen wiederholen sich)
const ANIM_ONCE := ["attack", "death", "parry", "hit", "attack2", "wurf", "spezial", "cast"]

const PLATE_W := 168.0
const PLATE_H_HERO := 74.0
const PLATE_H_ENEMY := 64.0
const BOSS_PLATE_SIZE := Vector2(250, 92)
const COMPANION_PLATE_SIZE := Vector2(150, 44)

const COL_PLATE := Color(0.04, 0.04, 0.09, 0.82)
const COL_HP := Color("4cc46a")
const COL_HP_LOW := Color("e0533d")
const COL_MANA := Color("4a8cf0")
const COL_BLOOD := Color("a8243a")
const COL_ULT := Color("f2c14e")
const COL_RES_OFF := Color("ff8a3d")
const COL_RES_DEF := Color("6fe0ff")
const COL_GOLD := Color("f2c14e")
const COL_BLADE := Color("ffb07a")
const COL_HARD := Color("ff9a5c")
const COL_TARGET := Color(0.4, 1.0, 1.0)
## Leisten mit Füllung aus dem UI-Set: Farbe (als Hex) -> Bild in assets/ui/
const BAR_FILLS := {"4cc46a": "fuellung_gruen", "e0533d": "fuellung_rot", "4a8cf0": "fuellung_blau"}

static var _fills := {}

var fighter: Fighter
## Ist gerade am Zug (goldener Rahmen und Pfeil).
var active := false
## Kann gerade als Ziel gewählt werden (blinkender Umriss).
var targetable := false
## Die Pixel-Figur selbst. Bewegt sich bei Angriffen, das Namensschild bleibt stehen.
var body: Sprite2D
var sprite_size: Vector2

var _frames := {}
var _anim := "idle"
var _anim_time := 0.0
## Eigene Geschwindigkeit der laufenden Animation (0 = ANIM_FPS)
var _anim_fps := 0.0
## Eigene Zeitpunkte je Bild (leer = gleichmäßig), z. B. damit das Geschoss genau beim Loslassen erscheint
var _anim_times: Array[float] = []
var _hold := 0.0
var _time := 0.0
var _home := Vector2.ZERO
var _plate := Rect2()
var _shader := ShaderMaterial.new()
## Klingentänzerin: Schwerter, die vor der Figur schweben (die hinteren malt _draw unter der Figur)
var _blades_front: Node2D
## Unterstützer des Zähmers: kleine Figur mit Namen darunter statt Schild mit Leisten
var _compact := false
var _glow_color := Color.WHITE
## Hält das Splitterlicht (Pilzhöhle, Vorbote): leuchtet selbst lila (wird von der Kampfanzeige gesetzt)
var splitter_light := false
var _halo: Node2D
var _glow := 0.0
var _flash := 0.0
## Lebenspunkte, die gerade angezeigt werden. Die Anzeige setzt sie im Takt der abgespielten Treffer,
## damit die Leiste erst sinkt, wenn der Treffer zu sehen ist (-1 = immer den echten Wert zeigen).
var shown := -1
## Licht des Ortes auf allen Figuren (Höhle dunkler, Nacht bläulich), siehe Backdrop.fighter_light
static var light := Color.WHITE


func setup(p_fighter: Fighter) -> void:
	fighter = p_fighter
	mouse_filter = Control.MOUSE_FILTER_STOP
	var look: Dictionary = look_data(fighter.look_key())
	for anim: String in ANIM_FPS:
		var frames: Array[Texture2D] = []
		var i := 0
		while ResourceLoader.exists(sprite_path(look.sprite, anim, i)):
			frames.append(einzelbild(look.sprite, anim, i))
			i += 1
		if not frames.is_empty():
			_frames[anim] = frames

	var texture: Texture2D = _frames.idle[0]
	# Unterstützer des Zähmers (auf der Bank): kleiner, ohne Namensschild
	_compact = fighter.owner != null and fighter.on_bench
	var pixel_scale: float = look.scale * (0.7 if _compact else 1.0) / fein_faktor(texture)
	sprite_size = texture.get_size() * pixel_scale
	_home = Vector2(sprite_size.x * 0.5 + 8.0, sprite_size.y)

	_shader.shader = FIGHTER_SHADER
	body = Sprite2D.new()
	body.texture = texture
	body.scale = Vector2(pixel_scale, pixel_scale)
	body.offset = Vector2(0, -texture.get_height() * 0.5)
	body.position = _home
	body.flip_h = fighter.is_ally()
	body.texture_filter = filter_fuer(texture)
	body.material = _shader
	# Der leuchtende Umriss bleibt bei fein gezeichneten Bildern gleich dick
	_shader.set_shader_parameter("outline_width", fein_faktor(texture))
	body.self_modulate = look.get("tint", Color.WHITE) * light
	add_child(body)
	if fighter.klass == "blade":
		_blades_front = Node2D.new()
		_blades_front.draw.connect(func() -> void: _draw_blades(_blades_front, true))
		add_child(_blades_front)

	# Schein des Splitterlichts (nur sichtbar, solange die Figur es hält)
	_halo = Node2D.new()
	_halo.material = Fx.add_material()
	_halo.visible = false
	_halo.draw.connect(func() -> void:
		var r := maxf(sprite_size.x, sprite_size.y) * (0.95 + 0.08 * sin(_time * 4.0))
		var c := body.position + Vector2(0, -sprite_size.y * 0.45)
		_halo.draw_texture_rect(Fx.glow_texture(), Rect2(c - Vector2(r, r), Vector2(r, r) * 2.0), false, Color(0.8, 0.6, 1.0, 0.55)))
	add_child(_halo)

	if _compact:
		_plate = Rect2()
		size = Vector2(sprite_size.x + 16.0, sprite_size.y + 18.0)
	elif fighter.big:
		_plate = Rect2(Vector2(0, sprite_size.y + 8), BOSS_PLATE_SIZE)
		size = _plate.end
	elif fighter.owner != null:
		_plate = Rect2(Vector2(0, sprite_size.y + 4), COMPANION_PLATE_SIZE)
		size = Vector2(maxf(_plate.end.x, sprite_size.x + 16.0), _plate.end.y)
	else:
		var plate_h := PLATE_H_HERO if fighter.is_hero else PLATE_H_ENEMY
		_plate = Rect2(sprite_size.x + 22.0, sprite_size.y - plate_h, PLATE_W, plate_h)
		size = Vector2(_plate.end.x, sprite_size.y)


func _process(delta: float) -> void:
	_time += delta
	_anim_time += delta
	if _hold > 0.0:
		_hold -= delta
		if _hold <= 0.0:
			_set_anim("idle")
	var alive := shown_hp() > 0
	if not alive and _frames.has("death") and _anim != "death":
		_set_anim("death")
		_hold = 0.0
	var anim := _anim if _frames.has(_anim) else "idle"
	if not alive and not _frames.has("death"):
		anim = "hit" if _frames.has("hit") else "idle"
	var frames: Array = _frames[anim]
	var index := int(_anim_time * (_anim_fps if _anim_fps > 0.0 else ANIM_FPS[anim]))
	if not _anim_times.is_empty() and anim == _anim:
		index = maxi(_anim_times.filter(func(t: float) -> bool: return t <= _anim_time).size() - 1, 0)
	index = mini(index, frames.size() - 1) if anim in ANIM_ONCE else index % frames.size()
	var texture: Texture2D = frames[index]
	if body.texture != texture:
		body.texture = texture
		# Bilder einer Animation können unterschiedlich groß sein (z. B. mit Geschoss): Füße bleiben auf dem Boden
		body.offset = Vector2(0, -texture.get_height() * 0.5)

	# Besiegte Figuren werden grau und durchsichtig (mit eigener Fall-Animation nur etwas dunkler, sobald sie liegen)
	var dead_look := Color(0.75, 0.75, 0.8, 0.9) if _frames.has("death") else Color(0.45, 0.45, 0.5, 0.55)
	body.modulate = Color.WHITE if alive or (anim == "death" and index < frames.size() - 1) else dead_look

	var outline := Color(0, 0, 0, 0)
	if targetable:
		outline = Color(COL_TARGET, 0.5 + 0.5 * sin(_time * 8.0))
	elif _glow > 0.0:
		outline = Color(_glow_color, _glow)
	elif splitter_light:
		outline = Color(Color("e0c8ff"), 0.6 + 0.3 * sin(_time * 4.0))
	_halo.visible = splitter_light
	if splitter_light:
		_halo.queue_redraw()
	_shader.set_shader_parameter("outline_color", outline)
	_shader.set_shader_parameter("flash", _flash)
	queue_redraw()
	if _blades_front != null:
		_blades_front.queue_redraw()


func shown_hp() -> int:
	return shown if shown >= 0 else fighter.hp


## Erstes Standbild einer Figur (für Zugleiste und Auswahl-Bildschirm).
## Aussehen einer Figur. Unbekannte Namen sind Pixel-Figuren aus dem 0x72-Paket (z. B. die Figur, die ein Spieler
## beim Zusammenspielen gewählt hat).
static func look_data(key: String) -> Dictionary:
	if LOOKS.has(key):
		return LOOKS[key]
	if ResourceLoader.exists(OWN_SPRITE_PATH % [key, "idle", 0]):
		return {sprite = key, scale = 3.0}
	return {sprite = key, scale = 4.0} if ResourceLoader.exists(SPRITE_PATH % [key, "idle", 0]) else LOOKS["novize"]


## Datei eines Einzelbilds: erst bei den eigenen Figuren nachsehen, sonst im 0x72-Paket.
static func sprite_path(sprite: String, anim: String, frame: int) -> String:
	var own := OWN_SPRITE_PATH % [sprite, anim, frame]
	return own if ResourceLoader.exists(OWN_SPRITE_PATH % [sprite, "idle", 0]) else SPRITE_PATH % [sprite, anim, frame]


## Ein Einzelbild laden; Figuren mit Kopf und Körper (Projekt 11) werden je nach FigurTeile.art zusammengesetzt.
static func einzelbild(sprite: String, anim: String, frame: int) -> Texture2D:
	var teile := FigurTeile.bild(sprite, anim, frame)
	return teile if teile != null else load(sprite_path(sprite, anim, frame))


## Fein gezeichnete Bilder (z. B. Vega aus Marcos Bildblättern) sind dreimal so hoch aufgelöst wie die Pixel-Bilder.
## Sie werden um diesen Faktor kleiner und weich dargestellt, damit sie gleich groß, aber sauber aussehen.
static func fein_faktor(texture: Texture2D) -> float:
	return 3.0 if texture != null and texture.get_height() > 80 else 1.0


## Passende Bildglättung: Pixel-Bilder scharf, fein gezeichnete Bilder weich.
static func filter_fuer(texture: Texture2D) -> CanvasItem.TextureFilter:
	return CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS if fein_faktor(texture) > 1.0 else CanvasItem.TEXTURE_FILTER_NEAREST


## Ist das eine eigene Figur aus assets/figuren/?
static func is_own_sprite(sprite: String) -> bool:
	return ResourceLoader.exists(OWN_SPRITE_PATH % [sprite, "idle", 0])


static func portrait(klass: String) -> Texture2D:
	return load(sprite_path(look_data(klass).sprite, "idle", 0))


static func tint(klass: String) -> Color:
	return look_data(klass).get("tint", Color.WHITE)


## Antippbar sind nur die Figur selbst und ihr Namensschild
## (die Helden stehen eng, die leeren Ränder der Bilder sollen nichts verdecken).
func _has_point(point: Vector2) -> bool:
	if _plate.has_point(point):
		return true
	var figure := Rect2(_home.x - sprite_size.x * 0.5, sprite_size.y * 0.3, sprite_size.x, sprite_size.y * 0.7)
	return figure.has_point(point)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tapped.emit(fighter)
		accept_event()


# --- Animationen ----------------------------------------------------------------

func _set_anim(anim: String) -> void:
	if _anim == "death" and shown_hp() <= 0:
		return
	if _anim != anim:
		_anim = anim
		_anim_time = 0.0
		_anim_fps = 0.0
		_anim_times = []


## Spielt eine Animation für "seconds" Sekunden, danach wieder stehen. fps > 0: eigene Geschwindigkeit.
func play(anim: String, seconds: float, fps := 0.0) -> void:
	_set_anim(anim)
	_anim_time = 0.0
	_anim_fps = fps
	_anim_times = []
	_hold = seconds


## Hat diese Figur eine eigene Animation (z. B. "attack")?
func has_anim(anim: String) -> bool:
	return _frames.has(anim)


## Welche Animation ein Angriff zeigt (Monster mit eigenen Bildern): aus "angriffe" in LOOKS, sonst "standard".
## "" = keine passende Animation.
func anim_for(attack_name: String, standard: String) -> String:
	var anim: String = look_data(fighter.look_key()).get("angriffe", {}).get(attack_name, standard)
	if has_anim(anim):
		return anim
	return standard if has_anim(standard) else ""


## Angriff am Platz (Monster: Wurf, Splitterregen): das 4. Bild nach "release" Sekunden.
## Treffen mehrere Geschosse gleichzeitig, startet die Animation nur einmal.
func strike(anim: String, release: float) -> void:
	if _anim == anim and _hold > 0.0:
		return
	play(anim, release + 0.6, 3.5 / maxf(release, 0.1))


## Fernangriff (Figuren mit eigener Angriffs-Animation): ausholen, bei "release" Sekunden das Geschoss loslassen
## (4. Bild), danach ausschwingen. Die Figur bleibt an ihrem Platz und macht nur einen kleinen Schritt nach vorn.
func cast_attack(release: float) -> void:
	_set_anim("attack")
	_anim_time = 0.0
	_anim_fps = 0.0
	_anim_times = [0.0, release * 0.33, release * 0.66, release, release + 0.3, release + 0.6]
	_hold = release + 0.95
	var dir := -1.0 if fighter.is_ally() else 1.0
	var tween := create_tween()
	tween.tween_property(body, "position", _home + Vector2(dir * 10.0, 0), release).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.6)
	tween.tween_property(body, "position", _home, 0.35).set_trans(Tween.TRANS_SINE)


## Erfolgreiche Parade (nur Figuren mit eigener Parier-Animation). Läuft schon eine, wird sie nicht neu gestartet.
func parry_pose() -> void:
	if has_anim("parry") and shown_hp() > 0 and not parrying():
		play("parry", 0.95)


## Hält die Figur gerade die Parier-Pose?
func parrying() -> bool:
	return _anim == "parry" and _hold > 0.0


## Jubeln nach einem Sieg (nur Figuren mit eigener Sieges-Animation, solange sie stehen).
func cheer() -> void:
	if has_anim("victory") and shown_hp() > 0:
		_set_anim("victory")
		_hold = 0.0


## Mitte der Figur (im Koordinatensystem des Kampffelds).
func center() -> Vector2:
	return position + body.position + Vector2(0, -sprite_size.y * 0.45)


## Fußpunkt in der Ruheposition (im Koordinatensystem des Kampffelds).
func home_feet() -> Vector2:
	return position + _home


## Weißes Aufblitzen und kurzes Zurückweichen, wenn die Figur getroffen wird.
func hit_react() -> void:
	# Bei einer Parade bleibt die Parier-Pose stehen (sonst würde sie vom Getroffen-Bild verdeckt)
	if not parrying():
		play("hit", 0.35)
	var away := 1.0 if fighter.is_ally() else -1.0
	var tween := create_tween()
	tween.tween_method(func(v: float) -> void: _flash = v, 1.0, 0.0, 0.25)
	var knock := create_tween()
	knock.tween_property(body, "position", _home + Vector2(14.0 * away, 0), 0.06)
	knock.tween_property(body, "position", _home, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Leuchtender Umriss, z. B. wenn eine Fähigkeit gewirkt wird.
func glow(color: Color, seconds := 0.7) -> void:
	_glow_color = color
	var tween := create_tween()
	tween.tween_method(func(v: float) -> void: _glow = v, 1.0, 0.0, seconds).set_ease(Tween.EASE_IN)


## Angriff: kurz ausholen, auf das Ziel zustürmen und zurückkehren.
## Der Aufprall ist genau nach "duration" Sekunden (wichtig fürs Parieren).
func lunge(target_point: Vector2, duration: float, anim := "attack") -> void:
	var toward := target_point - home_feet()
	var dir := signf(toward.x) if toward.x != 0.0 else 1.0
	var hit_offset := toward - Vector2(dir * (sprite_size.x * 0.5 + 34.0), 0)
	var windup := duration * 0.35
	z_index = 6
	if has_anim(anim):
		# Das 4. Bild (Treffer bzw. Geschoss) erscheint genau beim Aufprall
		play(anim, duration + 0.3, 3.5 / maxf(duration, 0.1))
	else:
		play("run", duration + 0.3)
	var tween := create_tween()
	tween.tween_property(body, "position", _home + Vector2(-dir * 18.0, 0), windup).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(body, "position", _home + hit_offset, duration - windup).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_interval(0.08)
	tween.tween_property(body, "position", _home, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void: z_index = 0)
	await get_tree().create_timer(duration).timeout


## Kleiner Hüpfer beim Wirken einer Fähigkeit.
func cast_hop() -> void:
	# Während einer Parade bleibt die Parier-Pose stehen (z. B. Freude über die perfekte Parade)
	if parrying():
		return
	if has_anim("cast"):
		# Eigene Figur mit Zauber-Pose (z. B. Kofi: Hand auf die Brust bei Erster Hilfe)
		play("cast", 0.9)
		return
	if has_anim("attack"):
		# Eigene Figuren heben nur den Stab (die ersten drei Angriffs-Bilder, ohne Geschoss)
		_set_anim("attack")
		_anim_time = 0.0
		_anim_fps = 0.0
		_anim_times = [0.0, 0.2, 0.4, 99.0]
		_hold = 0.9
		return
	play("run", 0.3)
	var tween := create_tween()
	tween.tween_property(body, "position", _home + Vector2(0, -14), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(body, "position", _home, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


# --- Zeichnen -------------------------------------------------------------------

func _draw() -> void:
	# Schatten unter den Füßen
	var feet := body.position
	draw_set_transform(feet, 0.0, Vector2(1.0, 0.28))
	draw_circle(Vector2.ZERO, sprite_size.x * 0.48, Color(0, 0, 0, 0.5))
	if active:
		draw_arc(Vector2.ZERO, sprite_size.x * 0.6, 0, TAU, 32, Color(COL_ULT, 0.6 + 0.4 * sin(_time * 6.0)), 6.0)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	if _blades_front != null:
		_draw_blades(self, false)

	# Goldener Pfeil, wenn die Figur am Zug ist: bei Helden links daneben (wie die Hand in FF6),
	# bei Gegnern über dem Kopf
	if active:
		var bob := roundf(sin(_time * 5.0) * 2.0) * 2.0
		var points: PackedVector2Array
		if fighter.is_ally():
			var tip := Vector2(_home.x - sprite_size.x * 0.5 - 6.0 + bob, _home.y - sprite_size.y * 0.4)
			points = PackedVector2Array([tip, tip + Vector2(-16, -12), tip + Vector2(-16, 12)])
		else:
			var tip := Vector2(_home.x, _home.y - sprite_size.y - 4.0 + bob)
			if fighter.big:
				tip.y += 20.0
			points = PackedVector2Array([tip, tip + Vector2(-12, -16), tip + Vector2(12, -16)])
		draw_colored_polygon(points, COL_ULT)
		points.append(points[0])
		draw_polyline(points, Color.BLACK, 2.0)

	_draw_plate()


## Schwebende Klingen der Klingentänzerin: kreisen um die Figur, vordere über, hintere unter ihr.
func _draw_blades(canvas: CanvasItem, front: bool) -> void:
	if shown_hp() <= 0:
		return
	var color := COL_BLADE
	if fighter.star_turns > 0:
		color = Color("fff3b0")
	elif fighter.fire_turns > 0:
		color = Color("ff7a3d")
	for i in fighter.blades:
		var angle := _time * 1.4 + TAU * i / float(Fighter.MAX_BLADES)
		if (sin(angle) > 0.0) != front:
			continue
		var pos := body.position + Vector2(cos(angle) * sprite_size.x * 0.7, -sprite_size.y * 0.55 + sin(angle) * sprite_size.y * 0.14)
		pos.y += sin(_time * 3.0 + i) * 4.0
		canvas.draw_set_transform(pos, 0.25 * cos(angle) + PI, Vector2.ONE)
		# Klinge (Spitze nach oben), Parierstange, Griff
		canvas.draw_colored_polygon(PackedVector2Array([Vector2(-3, -12), Vector2(3, -12), Vector2(0, 16)]), Color("e8eef8"))
		canvas.draw_line(Vector2(0, -12), Vector2(0, 14), color.lightened(0.4), 1.0)
		canvas.draw_rect(Rect2(-7, -15, 14, 3), color)
		canvas.draw_rect(Rect2(-1.5, -22, 3, 7), Color("6e4a2c"))
		canvas.draw_circle(Vector2(0, -23), 2.5, color)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_plate() -> void:
	var font := ThemeDB.fallback_font
	if _compact:
		draw_string_outline(font, Vector2(_home.x - 60, sprite_size.y + 14), fighter.display_name + " (hilft)", HORIZONTAL_ALIGNMENT_CENTER, 120, 11, 4, Color.BLACK)
		draw_string(font, Vector2(_home.x - 60, sprite_size.y + 14), fighter.display_name + " (hilft)", HORIZONTAL_ALIGNMENT_CENTER, 120, 11, Color("cfe8c0"))
		return
	# Schild aus dem UI-Set: Feld mit Goldrand, golden leuchtend für die Figur am Zug
	draw_style_box(UiStil.feld_stil(active), _plate.grow(4))
	if targetable:
		var box := StyleBoxFlat.new()
		box.draw_center = false
		box.set_corner_radius_all(4)
		box.border_color = Color(COL_TARGET, 0.4 + 0.6 * (0.5 + 0.5 * sin(_time * 8.0)))
		box.set_border_width_all(3)
		draw_style_box(box, _plate.grow(5))

	var x0 := _plate.position.x + 7.0
	var w := _plate.size.x - 14.0
	var y := _plate.position.y
	draw_string(font, Vector2(x0, y + 16), fighter.display_name, HORIZONTAL_ALIGNMENT_LEFT, w, 14, Color.WHITE)
	var tag := fighter.row_name()
	var tag_color := Color(1, 1, 1, 0.5)
	if not fighter.is_hero:
		tag = fighter.element if fighter.element != "" else fighter.class_title
		tag_color = Elements.color(fighter.element)
		if fighter.big:
			tag = "BOSS · " + fighter.element
		elif fighter.passive:
			tag = "Splitter"
	draw_string(font, Vector2(x0, y + 16), tag, HORIZONTAL_ALIGNMENT_RIGHT, w, 11, tag_color)
	# Element-Symbol aus dem UI-Set links neben dem Element-Namen
	var element_icon := UiStil.element_symbol(fighter.element) if not fighter.is_hero else null
	if element_icon != null:
		var tag_width := font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
		draw_texture_rect(element_icon, Rect2(x0 + w - tag_width - 17, y + 3, 16, 16), false)

	if fighter.trainer:
		draw_string(font, Vector2(x0, y + 32), "Trainer – nicht angreifbar", HORIZONTAL_ALIGNMENT_LEFT, w, 11, Color(1, 1, 1, 0.7))
		return
	var hp_ratio := float(shown_hp()) / fighter.max_hp
	_draw_bar(Rect2(x0, y + 21, w, 13), hp_ratio, COL_HP if hp_ratio > 0.3 else COL_HP_LOW, "%d / %d" % [shown_hp(), fighter.max_hp])

	if shown_hp() <= 0:
		var text := "kaputt" if fighter.klass == "robot" else ("kampfunfähig" if fighter.owner != null else "besiegt")
		draw_string(font, Vector2(x0, y + 47), text, HORIZONTAL_ALIGNMENT_LEFT, w, 12, Color(1, 1, 1, 0.7))
		return
	if fighter.owner != null:
		draw_string(font, Vector2(x0, y + 40), " ".join(_status()), HORIZONTAL_ALIGNMENT_LEFT, w, 10, Color("ffe08a"))
	elif fighter.is_hero:
		_draw_hero_details(font, x0, y, w)
	else:
		_draw_enemy_details(font, x0, y, w)


func _draw_hero_details(font: Font, x0: float, y: float, w: float) -> void:
	match fighter.klass:
		"ritualist":
			_draw_bar(Rect2(x0, y + 37, w, 11), float(fighter.blood) / Fighter.MAX_BLOOD, COL_BLOOD, "Blut %d" % fighter.blood)
		"quartermaster":
			_draw_bar(Rect2(x0, y + 37, w, 11), float(fighter.gold) / Skills.START_GOLD, COL_GOLD, "Gold %d" % fighter.gold)
		_:
			_draw_bar(Rect2(x0, y + 37, w, 11), float(fighter.mana) / fighter.max_mana, COL_MANA, "Mana %d" % fighter.mana)

	# Ult-Leiste
	var ult_color := COL_ULT
	if fighter.ult_ready():
		ult_color = COL_ULT.lerp(Color.WHITE, 0.5 + 0.5 * sin(_time * 8.0))
	var ult_text := "ULT bereit!" if fighter.ult_ready() else "ULT %d %%" % int(fighter.ult)
	if fighter.klass == "novize":
		# Novizen haben noch keine Ult (kommt mit der Klasse)
		ult_text = "Ult kommt mit der Klasse"
		ult_color = Color(0.5, 0.5, 0.5)
	_draw_bar(Rect2(x0, y + 51, w, 10), fighter.ult / Fighter.MAX_ULT, ult_color, ult_text)

	# Letzte Zeile: besondere Mechanik der Klasse, danach Zustände
	var status := _status()
	var status_x := x0
	var line_y := y + 67
	match fighter.klass:
		"singer":
			_draw_pips(Vector2(x0, line_y), fighter.res_off, Fighter.MAX_RES, COL_RES_OFF)
			_draw_pips(Vector2(x0 + 52, line_y), fighter.res_def, Fighter.MAX_RES, COL_RES_DEF)
			status_x = x0 + 106
		"blade":
			_draw_pips(Vector2(x0, line_y), fighter.blades, Fighter.MAX_BLADES, COL_BLADE)
			status_x = x0 + 54
			if fighter.star_turns > 0:
				status.push_front("Sternenkraft")
			elif fighter.fire_turns > 0:
				status.push_front("Feuer")
		"smith":
			_draw_pips(Vector2(x0, line_y), fighter.hard, Fighter.MAX_HARD, COL_HARD)
			status_x = x0 + 54
			status.push_front(Skills.ARMORS[fighter.armor].name.substr(0, 6))
		"twilight":
			_draw_balance(Rect2(x0, line_y - 4, 70, 8))
			status_x = x0 + 76
		"quartermaster":
			var count := 0
			for n: int in fighter.wares.values():
				count += n
			status.push_front("Karren %d · %d Waren" % [fighter.cart_hp, count] if fighter.cart_hp > 0 else "Karren kaputt")
		"tamer":
			status.push_front(fighter.active_monster.display_name)
	draw_string(font, Vector2(status_x, y + 71), " ".join(status), HORIZONTAL_ALIGNMENT_LEFT, x0 + w - status_x, 10, Color("ffe08a"))


## Kurze Zustands-Texte (Schild, Bedrohung, Stärkungen …).
func _status() -> Array[String]:
	var status: Array[String] = []
	if fighter.shield_total() > 0:
		status.append("Schild %d" % fighter.shield_total())
	if fighter.taunt > 0:
		status.append("Bedr. %d" % fighter.taunt)
	if fighter.fortress:
		status.append("FESTUNG")
	if fighter.charged:
		status.append("GESPANNT")
	if fighter.smoke > 0:
		status.append("Rauch")
	if fighter.atk_buff_turns > 0:
		status.append("Angr+")
	if fighter.def_buff_turns > 0:
		status.append("Abw+")
	if fighter.vuln_turns > 0:
		status.append("Verwundbar")
	if fighter.blind_turns > 0:
		status.append("Geblendet")
	if fighter.plate < 1.0:
		status.append("ERSCHÜTTERT" if fighter.stagger_turns > 0 else "Sternenpanzer")
	if fighter.light:
		status.append("SPLITTERLICHT")
	if fighter.charge > 0:
		status.append("Ladung %d" % fighter.charge)
	if fighter.protecting != null and fighter.protecting.is_alive():
		status.append("schützt " + fighter.protecting.display_name)
	return status


## Leiste des Zwielicht-Wandlers: links Schatten, rechts Licht.
func _draw_balance(rect: Rect2) -> void:
	draw_rect(rect.grow(1), Color(0, 0, 0, 0.7))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * 0.5, rect.size.y)), Color(Elements.color("Schatten"), 0.25))
	draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.5, 0), Vector2(rect.size.x * 0.5, rect.size.y)), Color(Elements.color("Licht"), 0.25))
	var mid := rect.position.x + rect.size.x * 0.5
	var fill := rect.size.x * 0.5 * float(fighter.balance) / Fighter.MAX_BALANCE
	var color := Elements.color("Licht") if fighter.balance > 0 else Elements.color("Schatten")
	if absi(fighter.balance) >= Fighter.MAX_BALANCE:
		color = color.lerp(Color.WHITE, 0.5 + 0.5 * sin(_time * 10.0))
	draw_rect(Rect2(minf(mid, mid + fill), rect.position.y, absf(fill), rect.size.y), color)
	draw_rect(Rect2(mid - 1, rect.position.y - 2, 2, rect.size.y + 4), Color.WHITE)


func _draw_enemy_details(font: Font, x0: float, y: float, w: float) -> void:
	# Siegel der Kunoichi und Zustände
	var sx := x0
	for el: String in fighter.seals:
		draw_circle(Vector2(sx + 6, y + 41), 5, Elements.color(el))
		draw_string(font, Vector2(sx + 2, y + 45), el.substr(0, 1), HORIZONTAL_ALIGNMENT_LEFT, 12, 9, Color.BLACK)
		sx += 14
	var status := _status()
	if not status.is_empty():
		draw_string(font, Vector2(sx + 2, y + 45), " ".join(status), HORIZONTAL_ALIGNMENT_LEFT, x0 + w - sx, 10, Color("ffe08a"))
	var line_y := y + 47 if fighter.seals.is_empty() and status.is_empty() else y + 59
	if fighter.enraged:
		draw_string(font, Vector2(x0, line_y), "WUT!", HORIZONTAL_ALIGNMENT_LEFT, w, 12, COL_HP_LOW)
		line_y += 14
	if fighter.intent != "":
		draw_multiline_string(font, Vector2(x0, line_y), fighter.intent, HORIZONTAL_ALIGNMENT_LEFT, w, 11, -1, Color("ffd36b"))


func _draw_bar(rect: Rect2, ratio: float, color: Color, text: String) -> void:
	draw_rect(rect.grow(1), Color(0, 0, 0, 0.7))
	var fill := Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0, 1), rect.size.y))
	# Leben und Mana mit den Füllungen aus dem UI-Set, alles andere einfarbig
	var texture := BAR_FILLS.get(color.to_html(false), "") as String
	if texture != "" and fill.size.x >= 4.0:
		draw_style_box(_fill_style(texture), fill)
	else:
		draw_rect(fill, color)
		# Heller Streifen oben, damit die Leiste etwas plastisch wirkt
		draw_rect(Rect2(rect.position, Vector2(fill.size.x, 2)), Color(1, 1, 1, 0.25))
	# Feiner Goldrand wie beim Balken aus dem UI-Set
	draw_rect(rect.grow(1), Color(0.85, 0.66, 0.3, 0.75), false, 1.0)
	if text != "":
		var font_size := 10 if rect.size.y < 12 else 11
		draw_string_outline(ThemeDB.fallback_font, rect.position + Vector2(4, rect.size.y - 1.5), text, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 6, font_size, 3, Color(0, 0, 0, 0.8))
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(4, rect.size.y - 1.5), text, HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 6, font_size, Color.WHITE)


## Punkte für Stapel (Sternbild, Klingen, Härte).
func _draw_pips(origin: Vector2, filled: int, count: int, color: Color) -> void:
	for i in count:
		var c := origin + Vector2(5 + i * 10, 0)
		if i < filled:
			draw_circle(c, 4, color)
		else:
			draw_arc(c, 4, 0, TAU, 12, Color(color, 0.5), 1.5)


static func _fill_style(texture: String) -> StyleBoxTexture:
	if not _fills.has(texture):
		var style := StyleBoxTexture.new()
		style.texture = load("res://assets/ui/%s.png" % texture)
		style.texture_margin_left = 4
		style.texture_margin_right = 4
		style.texture_margin_top = 3
		style.texture_margin_bottom = 3
		_fills[texture] = style
	return _fills[texture]
