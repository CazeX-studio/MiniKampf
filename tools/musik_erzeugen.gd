extends SceneTree
## Erzeugt die Platzhalter-Musik (einfache Retro-Melodien) als WAV-Dateien in assets/musik/.
## Selbst erzeugt, keine Lizenzfragen. Aufruf: Godot --headless --path . --script res://tools/musik_erzeugen.gd

const RATE := 22050
const OUT := "res://assets/musik/%s.wav"

## Stücke: Tempo (Schläge pro Minute) und Stimmen. Jede Stimme: Klangform, Lautstärke, Noten [Tonhöhe, Schläge].
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
			if pitch > 0.0:
				var freq := 440.0 * pow(2.0, (pitch - 69.0) / 12.0)
				for i in count:
					if start + i >= length:
						break
					var s := float(i) / RATE
					# Hüllkurve: kurz anschwellen, am Ende ausklingen
					var env := minf(1.0, s / 0.01) * minf(1.0, (dur - s) / 0.05)
					if voice.wave == "bell":
						env *= exp(-s * 2.5)
					mix[start + i] += _wave(voice.wave, freq * s, noise) * env * float(voice.vol)
			t += dur
	var data := PackedByteArray()
	data.resize(length * 2)
	for i in length:
		data.encode_s16(i * 2, int(clampf(mix[i], -1.0, 1.0) * 32000.0))
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
	return sin(TAU * x)


## Arpeggio: Tonfolge "pattern" so oft wiederholen, jede Note "step" Schläge lang.
func _arp(pattern: Array, times: int, step: float) -> Array:
	var notes := []
	for i in times:
		for pitch: int in pattern:
			notes.append([pitch, step])
	return notes


func _repeat(notes: Array, times: int) -> Array:
	var result := []
	for i in times:
		result.append_array(notes)
	return result
