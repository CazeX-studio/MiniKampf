extends SceneTree
## Erzeugt die Platzhalter-Musik (einfache Retro-Melodien) als WAV-Dateien in assets/musik/.
## Selbst erzeugt, keine Lizenzfragen. Aufruf: Godot --headless --path . --script res://tools/musik_erzeugen.gd

const RATE := 22050
const OUT := "res://assets/musik/%s.wav"

## Stücke: Tempo (Schläge pro Minute), Lautstärke des ganzen Stücks (gain, sonst 1) und Stimmen. Jede Stimme: Klangform, Lautstärke, Noten [Tonhöhe, Schläge].
## Tonhöhe als MIDI-Zahl (60 = C4), 0 = Pause.
var tracks := {
	# Stadt: ruhig, Dur-Pentatonik, Dreiecks-Arpeggio über weichem Bass
	"stadt": {bpm = 96, voices = [
		{wave = "triangle", vol = 0.22, notes = _arp([60, 64, 67, 72, 69, 67, 64, 62], 8, 0.5)},
		{wave = "sine", vol = 0.20, notes = _repeat([[48, 4], [45, 4], [41, 4], [43, 4]], 2)},
		{wave = "square", vol = 0.05, notes = _repeat([[0, 2], [76, 1], [74, 1], [72, 2], [0, 2], [69, 1], [72, 1], [74, 4], [0, 2]], 2)},
	]},
	# Nacht (Fest): langsam, Moll, Glocken
	"nacht": {bpm = 72, voices = [
		{wave = "bell", vol = 0.20, notes = _repeat([[69, 1], [72, 1], [76, 2], [74, 1], [72, 1], [71, 2], [69, 1], [67, 1], [69, 4], [0, 2]], 2)},
		{wave = "sine", vol = 0.18, notes = _repeat([[45, 4], [41, 4], [43, 4], [40, 4]], 2)},
	]},
	# Kampf: schnell, Moll, Rechteck-Bass als Ostinato
	"kampf": {bpm = 140, voices = [
		{wave = "square", vol = 0.10, notes = _repeat([[38, 0.5], [38, 0.5], [50, 0.5], [38, 0.5], [41, 0.5], [38, 0.5], [48, 0.5], [45, 0.5]], 8)},
		{wave = "triangle", vol = 0.20, notes = _repeat([[62, 1], [65, 1], [69, 1.5], [67, 0.5], [65, 1], [64, 1], [62, 2],
			[60, 1], [62, 1], [65, 1.5], [64, 0.5], [62, 2], [57, 2]], 2)},
		{wave = "noise", vol = 0.05, notes = _repeat([[1, 0.5], [0, 0.5], [1, 0.25], [1, 0.25], [0, 0.5]], 16)},
	]},
	# Boss: noch schneller, tief, unruhig
	"boss": {bpm = 152, voices = [
		{wave = "square", vol = 0.11, notes = _repeat([[40, 0.5], [40, 0.5], [41, 0.5], [40, 0.5], [46, 0.5], [40, 0.5], [45, 0.5], [43, 0.5]], 8)},
		{wave = "triangle", vol = 0.20, notes = _repeat([[64, 0.5], [71, 0.5], [70, 1], [64, 0.5], [67, 0.5], [66, 1], [64, 2],
			[76, 1], [75, 1], [71, 1], [70, 1], [64, 4]], 2)},
		{wave = "noise", vol = 0.06, notes = _repeat([[1, 0.25], [0, 0.25]], 64)},
	]},
	# Grünwacht (Tag): Holzflöte über Harfen-Arpeggio, ab und zu Vogelrufe. D-Dur, ruhig.
	"wald": {bpm = 84, gain = 1.4, voices = [
		{wave = "harp", vol = 0.20, notes = _repeat(_arp([50, 57, 62, 66, 69, 66, 62, 57], 1, 0.5) + _arp([43, 50, 55, 59, 62, 59, 55, 50], 1, 0.5)
			+ _arp([47, 54, 59, 62, 66, 62, 59, 54], 1, 0.5) + _arp([45, 52, 57, 61, 64, 61, 57, 52], 1, 0.5), 3)},
		{wave = "sine", vol = 0.10, notes = _repeat([[38, 4], [43, 4], [47, 4], [45, 4]], 3)},
		{wave = "flute", vol = 0.16, attack = 0.08, notes = [[74, 1], [76, 1], [78, 2], [76, 1], [74, 1], [71, 2], [69, 1.5], [71, 0.5], [74, 2], [76, 4],
			[78, 1], [81, 1], [78, 1], [76, 1], [74, 2], [71, 2], [73, 1], [74, 1], [76, 1], [73, 1], [74, 4], [0, 16]]},
		{wave = "bird", vol = 0.05, notes = _pad([[0, 6], [96, 0.25], [0, 0.25], [98, 0.25], [0, 13.25], [93, 0.25], [0, 0.25], [93, 0.25],
			[0, 0.25], [97, 0.5], [0, 7.5], [99, 0.25], [0, 0.5], [96, 0.25]], 48)},
	]},
	# Grünwacht (welk, wenn der Urbaum gefällt wurde): dieselbe Stimmung in Moll, langsamer, keine Vögel
	"wald_welk": {bpm = 72, gain = 1.5, voices = [
		{wave = "harp", vol = 0.18, notes = _repeat(_arp([47, 54, 59, 62, 66, 62, 59, 54], 1, 0.5) + _arp([43, 50, 55, 59, 62, 59, 55, 50], 1, 0.5)
			+ _arp([40, 47, 52, 55, 59, 55, 52, 47], 1, 0.5) + _arp([42, 49, 54, 58, 61, 58, 54, 49], 1, 0.5), 2)},
		{wave = "sine", vol = 0.10, notes = _repeat([[35, 4], [31, 4], [40, 4], [42, 4]], 2)},
		{wave = "flute", vol = 0.14, attack = 0.12, notes = [[74, 2], [73, 1], [71, 1], [69, 2], [66, 2], [67, 1], [69, 1], [71, 2], [66, 4], [0, 16]]},
	]},
	# Pilzhöhle (Grünwacht bei Nacht): langsame Harfe in h-Moll, tiefe Flöte, Tropfen
	"wald_nacht": {bpm = 60, gain = 2.2, voices = [
		{wave = "harp", vol = 0.18, notes = _repeat([[47, 1], [54, 1], [59, 1], [62, 1], [40, 1], [47, 1], [52, 1], [55, 1],
			[43, 1], [50, 1], [55, 1], [59, 1], [42, 1], [49, 1], [54, 1], [58, 1]], 2)},
		{wave = "flute", vol = 0.12, attack = 0.2, notes = [[71, 3], [69, 1], [66, 4], [67, 2], [66, 2], [64, 4], [0, 4], [74, 2], [73, 2], [71, 4], [0, 4]]},
		{wave = "bell", vol = 0.05, notes = _pad([[0, 3], [88, 0.5], [0, 7], [91, 0.5], [0, 9], [86, 0.5]], 32)},
	]},
}


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/musik"))
	for name: String in tracks:
		var wav := _render(tracks[name])
		var path := ProjectSettings.globalize_path(OUT % name)
		wav.save_to_wav(path)
		print("%s: %.1f Sekunden" % [name, float(wav.data.size()) / 2.0 / RATE])
	quit()


func _render(track: Dictionary) -> AudioStreamWAV:
	var beat := 60.0 / float(track.bpm)
	var length := 0
	for voice: Dictionary in track.voices:
		var beats := 0.0
		for note: Array in voice.notes:
			beats += float(note[1])
		length = maxi(length, int(beats * beat * RATE))
	var mix := PackedFloat32Array()
	mix.resize(length)
	var noise := RandomNumberGenerator.new()
	noise.seed = 3
	for voice: Dictionary in track.voices:
		var t := 0.0
		for note: Array in voice.notes:
			var pitch: float = note[0]
			var dur: float = float(note[1]) * beat
			var start := int(t * RATE)
			var count := int(dur * RATE)
			var attack: float = voice.get("attack", 0.01)
			if pitch > 0.0:
				var freq := 440.0 * pow(2.0, (pitch - 69.0) / 12.0)
				for i in count:
					if start + i >= length:
						break
					var s := float(i) / RATE
					# Hüllkurve: kurz anschwellen, am Ende ausklingen
					var env := minf(1.0, s / attack) * minf(1.0, (dur - s) / 0.05)
					var phase := freq * s
					match voice.wave:
						"bell":
							env *= exp(-s * 2.5)
						"harp":
							# Gezupft: schnell leiser, klingt aber in die nächste Note hinein
							env *= exp(-s * 3.5)
						"flute":
							# Leichtes Vibrato wie beim Atmen
							phase += freq * 0.006 * sin(TAU * 5.0 * s) / (TAU * 5.0)
						"bird":
							# Vogelruf: Ton rutscht schnell nach oben
							phase = freq * (s + 0.4 * s * s / dur)
					mix[start + i] += _wave(voice.wave, phase, noise) * env * float(voice.vol)
			t += dur
	var data := PackedByteArray()
	data.resize(length * 2)
	for i in length:
		data.encode_s16(i * 2, int(clampf(mix[i] * float(track.get("gain", 1.0)), -1.0, 1.0) * 32000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_end = length
	return wav


func _wave(kind: String, phase: float, noise: RandomNumberGenerator) -> float:
	var x := fmod(phase, 1.0)
	match kind:
		"square":
			return 1.0 if x < 0.5 else -1.0
		"triangle":
			return 4.0 * absf(x - 0.5) - 1.0
		"noise":
			return noise.randf_range(-1.0, 1.0)
		"bell":
			return sin(TAU * x) * 0.7 + sin(TAU * x * 2.0) * 0.3
		"harp":
			return sin(TAU * x) * 0.75 + sin(TAU * x * 2.0) * 0.18 + sin(TAU * x * 3.0) * 0.07
		"flute":
			return sin(TAU * x) * 0.9 + sin(TAU * x * 2.0) * 0.1 + noise.randf_range(-0.03, 0.03)
	return sin(TAU * x)


## Arpeggio: Tonfolge "pattern" so oft wiederholen, jede Note "step" Schläge lang.
func _arp(pattern: Array, times: int, step: float) -> Array:
	var notes := []
	for i in times:
		for pitch: int in pattern:
			notes.append([pitch, step])
	return notes


## Mit einer Pause auffüllen, bis die Stimme "total" Schläge lang ist.
func _pad(notes: Array, total: float) -> Array:
	var beats := 0.0
	for note: Array in notes:
		beats += float(note[1])
	var result := notes.duplicate()
	if beats < total:
		result.append([0, total - beats])
	return result


func _repeat(notes: Array, times: int) -> Array:
	var result := []
	for i in times:
		result.append_array(notes)
	return result
