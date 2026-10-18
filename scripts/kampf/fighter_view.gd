class_name FighterView
extends Control
## Zeigt einen Kampfteilnehmer als animierte Pixel-Figur mit Namensschild und Leisten.
## Animationen: stehen (idle), laufen/angreifen (run), getroffen (hit).
## Antippen (Maus oder Finger) meldet den Teilnehmer, z. B. um ihn als Ziel zu wählen.

signal tapped(fighter: Fighter)

const SPRITE_PATH := "res://assets/0x72_dungeontileset_ii/%s_%s_anim_f%d.png"
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
	# Begleiter
	"robot": {sprite = "big_zombie", scale = 2.5, tint = Color(0.72, 0.82, 1.0)},
	"moosling": {sprite = "swampy", scale = 3.5, tint = Color(0.75, 1.0, 0.65)},
	"glutwelpe": {sprite = "imp", scale = 3.5, tint = Color(1.0, 0.8, 0.6)},
	"bachotter": {sprite = "wogol", scale = 3.5, tint = Color(0.6, 0.85, 1.0)},
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
}
const ANIM_FPS := {"idle": 6.0, "run": 12.0, "hit": 8.0}

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
var _hold := 0.0
var _time := 0.0
var _home := Vector2.ZERO
var _plate := Rect2()
var _shader := ShaderMaterial.new()
var _glow_color := Color.WHITE
var _glow := 0.0
var _flash := 0.0


func setup(p_fighter: Fighter) -> void:
	fighter = p_fighter
	mouse_filter = Control.MOUSE_FILTER_STOP
	var look: Dictionary = LOOKS[fighter.klass]
	for anim: String in ANIM_FPS:
		var frames: Array[Texture2D] = []
		var i := 0
		while ResourceLoader.exists(SPRITE_PATH % [look.sprite, anim, i]):
			frames.append(load(SPRITE_PATH % [look.sprite, anim, i]))
			i += 1
		if not frames.is_empty():
			_frames[anim] = frames

	var texture: Texture2D = _frames.idle[0]
	var pixel_scale: float = look.scale
	sprite_size = texture.get_size() * pixel_scale
	_home = Vector2(sprite_size.x * 0.5 + 8.0, sprite_size.y)

	_shader.shader = FIGHTER_SHADER
	body = Sprite2D.new()
	body.texture = texture
	body.scale = Vector2(pixel_scale, pixel_scale)
	body.offset = Vector2(0, -texture.get_height() * 0.5)
	body.position = _home
	body.flip_h = fighter.is_ally()
	body.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.material = _shader
	body.self_modulate = look.get("tint", Color.WHITE)
	add_child(body)

	if fighter.big:
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
	var anim := _anim if _frames.has(_anim) else "idle"
	if not fighter.is_alive():
		anim = "hit" if _frames.has("hit") else "idle"
	var frames: Array = _frames[anim]
	body.texture = frames[int(_anim_time * ANIM_FPS[anim]) % frames.size()]

	# Besiegte Figuren werden grau und durchsichtig
	var alive := fighter.is_alive()
	body.modulate = Color.WHITE if alive else Color(0.45, 0.45, 0.5, 0.55)

	var outline := Color(0, 0, 0, 0)
	if targetable:
		outline = Color(COL_TARGET, 0.5 + 0.5 * sin(_time * 8.0))
	elif _glow > 0.0:
		outline = Color(_glow_color, _glow)
	_shader.set_shader_parameter("outline_color", outline)
	_shader.set_shader_parameter("flash", _flash)
	queue_redraw()


## Erstes Standbild einer Figur (für Zugleiste und Auswahl-Bildschirm).
static func portrait(klass: String) -> Texture2D:
	return load(SPRITE_PATH % [LOOKS[klass].sprite, "idle", 0])


static func tint(klass: String) -> Color:
	return LOOKS[klass].get("tint", Color.WHITE)


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
	if _anim != anim:
		_anim = anim
		_anim_time = 0.0


## Spielt eine Animation für "seconds" Sekunden, danach wieder stehen.
func play(anim: String, seconds: float) -> void:
	_set_anim(anim)
	_hold = seconds


## Mitte der Figur (im Koordinatensystem des Kampffelds).
func center() -> Vector2:
	return position + body.position + Vector2(0, -sprite_size.y * 0.45)


## Fußpunkt in der Ruheposition (im Koordinatensystem des Kampffelds).
func home_feet() -> Vector2:
	return position + _home


## Weißes Aufblitzen und kurzes Zurückweichen, wenn die Figur getroffen wird.
func hit_react() -> void:
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
func lunge(target_point: Vector2, duration: float) -> void:
	var toward := target_point - home_feet()
	var dir := signf(toward.x) if toward.x != 0.0 else 1.0
	var hit_offset := toward - Vector2(dir * (sprite_size.x * 0.5 + 34.0), 0)
	var windup := duration * 0.35
	z_index = 6
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


func _draw_plate() -> void:
	var font := ThemeDB.fallback_font
	var box := StyleBoxFlat.new()
	box.bg_color = COL_PLATE
	box.set_corner_radius_all(4)
	if active:
		box.border_color = COL_ULT
		box.set_border_width_all(2)
	elif targetable:
		box.border_color = Color(COL_TARGET, 0.4 + 0.6 * (0.5 + 0.5 * sin(_time * 8.0)))
		box.set_border_width_all(3)
	else:
		box.border_color = Color(0.75, 0.7, 0.55, 0.35)
		box.set_border_width_all(1)
	draw_style_box(box, _plate)

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

	var hp_ratio := float(fighter.hp) / fighter.max_hp
	_draw_bar(Rect2(x0, y + 21, w, 13), hp_ratio, COL_HP if hp_ratio > 0.3 else COL_HP_LOW, "%d / %d" % [fighter.hp, fighter.max_hp])

	if not fighter.is_alive():
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
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0, 1), rect.size.y)), color)
	# Heller Streifen oben, damit die Leiste etwas plastisch wirkt
	draw_rect(Rect2(rect.position, Vector2(rect.size.x * clampf(ratio, 0, 1), 2)), Color(1, 1, 1, 0.25))
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
