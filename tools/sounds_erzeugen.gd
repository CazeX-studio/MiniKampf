extends SceneTree
## Erzeugt die Platzhalter-Geräusche für Kämpfe als WAV-Dateien in assets/sfx/.
## Selbst erzeugt, keine Lizenzfragen. Aufruf: Godot --headless --path . --script res://tools/sounds_erzeugen.gd

const RATE := 22050
const OUT := "res://assets/sfx/%s.wav"

var _noise := RandomNumberGenerator.new()


func _initialize() -> void:
	_noise.seed = 7
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/sfx"))
	var sounds := {
		schlag = _swoosh(0.18, 0.35),
		wurf = _swoosh(0.12, 0.6),
		treffer = _thump(),
		kritisch = _thump(1.4),
		parade = _clang([880.0, 1320.0, 2090.0], 0.35),
		perfekt = _perfect(),
		zauber = _spell(),
		heilung = _chime([784.0, 1175.0], 0.5),
	}
	for name: String in sounds:
		var wav := _to_wav(sounds[name])
		wav.save_to_wav(ProjectSettings.globalize_path(OUT % name))
		print("%s: %.2f Sekunden" % [name, float(sounds[name].size()) / RATE])
	quit()


## Luftzug (Schlag, Wurf): Rauschen, das an- und abschwillt. "bright" = höher (weniger tief gefiltert).
func _swoosh(length: float, bright: float) -> PackedFloat32Array:
	var out := _empty(length)
	var low := 0.0
	for i in out.size():
		var t := float(i) / out.size()
		low = lerpf(low, _noise.randf_range(-1.0, 1.0), bright * (0.3 + t * 0.7))
		out[i] = low * sin(PI * t) * 0.9
	return out


## Treffer: dumpfer Schlag (fallender Ton) mit kurzem Knall. "power" > 1 = kräftiger (kritisch).
func _thump(power := 1.0) -> PackedFloat32Array:
	var out := _empty(0.18 * power)
	var phase := 0.0
	for i in out.size():
		var s := float(i) / RATE
		var freq := lerpf(170.0, 55.0, minf(1.0, s / 0.12))
		phase += freq / RATE
		var body := sin(TAU * phase) * exp(-s * 18.0 / power)
		var crack := _noise.randf_range(-1.0, 1.0) * exp(-s * 70.0)
		out[i] = (body * 0.8 + crack * 0.5) * minf(1.0, power)
	return out


## Metallisches Klirren (Parade): mehrere Obertöne, schnell ausklingend.
func _clang(freqs: Array, length: float) -> PackedFloat32Array:
	var out := _empty(length)
	for i in out.size():
		var s := float(i) / RATE
		var v := 0.0
		for f: float in freqs:
			v += sin(TAU * f * s) * exp(-s * (6.0 + f / 400.0))
		out[i] = v / freqs.size() * 0.9 + _noise.randf_range(-1.0, 1.0) * exp(-s * 90.0) * 0.4
	return out


## Perfekte Parade: Klirren und ein heller Dreiklang nach oben.
func _perfect() -> PackedFloat32Array:
	var out := _clang([1046.0, 1568.0, 2350.0], 0.55)
	var notes := [1046.0, 1318.0, 1568.0, 2093.0]
	for n in notes.size():
		var start := int((0.04 + n * 0.06) * RATE)
		for i in int(0.3 * RATE):
			if start + i >= out.size():
				break
			var s := float(i) / RATE
			out[start + i] += sin(TAU * notes[n] * s) * exp(-s * 9.0) * 0.35
	return out


## Zauber: aufsteigender Ton mit Flimmern.
func _spell() -> PackedFloat32Array:
	var out := _empty(0.42)
	var phase := 0.0
	for i in out.size():
		var t := float(i) / out.size()
		var freq := lerpf(300.0, 1250.0, t * t) * (1.0 + 0.03 * sin(TAU * 18.0 * t))
		phase += freq / RATE
		out[i] = (sin(TAU * phase) * 0.6 + sin(TAU * phase * 2.0) * 0.2) * sin(PI * t) * 0.7
	return out


## Heilung: zwei weiche Glockentöne nacheinander.
func _chime(freqs: Array, length: float) -> PackedFloat32Array:
	var out := _empty(length)
	for n in freqs.size():
		var start := int(n * 0.12 * RATE)
		for i in range(start, out.size()):
			var s := float(i - start) / RATE
			out[i] += (sin(TAU * freqs[n] * s) * 0.7 + sin(TAU * freqs[n] * 2.0 * s) * 0.2) * exp(-s * 5.0) * minf(1.0, s / 0.01) * 0.5
	return out


func _empty(length: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(length * RATE))
	return out


func _to_wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	# Kurz ausblenden, damit es am Ende nicht knackt
	var fade := mini(200, samples.size())
	for i in samples.size():
		var v := samples[i]
		if i >= samples.size() - fade:
			v *= float(samples.size() - i) / fade
		data.encode_s16(i * 2, int(clampf(v, -1.0, 1.0) * 30000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	return wav
