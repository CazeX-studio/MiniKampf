class_name Tageszeit
## Tag und Nacht nach der echten Uhrzeit (design.md, 22.10.): Nacht von 21 bis 6 Uhr, dazwischen Dämmerung.
## Zwei Uhren: Licht und Stimmung nach der Uhr des Spielers, welche Monster unterwegs sind, nach der Uhr dessen,
## der die Welt führt (allein der eigene Rechner, beim Zusammenspielen der Server). Beides liest diese Uhr auf
## dem jeweiligen Rechner. Dungeons haben keinen Tag und keine Nacht, die Fest-Nacht der Geschichte ist immer Nacht.

## Abend: von 19 bis 21 Uhr wird es dunkel. Morgen: von 6 bis 8 Uhr wird es hell.
const ABEND_BEGINN := 19.0
const NACHT_BEGINN := 21.0
const NACHT_ENDE := 6.0
const MORGEN_ENDE := 8.0
## Farbe der Nacht (wird mit dem Grundlicht der Karte gemischt) und der Dämmerung (warmer Schein am Abend und Morgen)
const NACHT_FARBE := Color(0.42, 0.48, 0.8)
const DAEMMERUNG_FARBE := Color(1.0, 0.78, 0.62)
## Nachts leuchten Laternen, Fenster und Fackeln stärker (Faktor bei voller Nacht)
const LICHT_NACHTS := 1.6

## Testknopf: so viele Stunden wird die Uhr vorgestellt (nur zum Ausprobieren, wird nicht gespeichert)
static var versatz := 0.0
## Für die Prüfungen: feste Uhrzeit, damit sie nicht von der echten Uhr abhängen (-1 = echte Uhr).
## Auch über die Umgebung MINIKAMPF_STUNDE einstellbar (z. B. 23 = Nacht).
static var feste_stunde := -1.0


## Uhrzeit dieses Rechners in Stunden (0 bis unter 24), samt Testversatz.
static func stunde() -> float:
	if feste_stunde >= 0.0:
		return fposmod(feste_stunde + versatz, 24.0)
	var aus_umgebung := OS.get_environment("MINIKAMPF_STUNDE")
	if aus_umgebung.is_valid_float():
		return fposmod(float(aus_umgebung) + versatz, 24.0)
	var t := Time.get_time_dict_from_system()
	return fposmod(float(t.hour) + float(t.minute) / 60.0 + versatz, 24.0)


## Ist es nach dieser Uhr Nacht (21 bis 6 Uhr)?
static func ist_nacht(h := -1.0) -> bool:
	if h < 0.0:
		h = stunde()
	return h >= NACHT_BEGINN or h < NACHT_ENDE


## Wie dunkel es ist: 0 = Tag, 1 = Nacht, dazwischen Dämmerung.
static func dunkelheit(h := -1.0) -> float:
	if h < 0.0:
		h = stunde()
	if ist_nacht(h):
		return 1.0
	if h >= ABEND_BEGINN:
		return smoothstep(ABEND_BEGINN, NACHT_BEGINN, h)
	if h < MORGEN_ENDE:
		return 1.0 - smoothstep(NACHT_ENDE, MORGEN_ENDE, h)
	return 0.0


## Wie stark die Dämmerung gerade färbt: 0 bei Tag und tiefer Nacht, am stärksten mitten in der Dämmerung.
static func daemmerung(h := -1.0) -> float:
	var d := dunkelheit(h)
	return 4.0 * d * (1.0 - d)


## Licht einer Karte zu dieser Uhrzeit: das Grundlicht, abends und morgens warm, nachts bläulich und dunkler.
static func licht(grundlicht: Color, h := -1.0) -> Color:
	var nacht := grundlicht * NACHT_FARBE
	nacht.a = 1.0
	var farbe := grundlicht.lerp(nacht, dunkelheit(h))
	return farbe.lerp(farbe * DAEMMERUNG_FARBE, daemmerung(h) * 0.6)


## Wie stark Lichter gerade leuchten (1 bei Tag, LICHT_NACHTS in der Nacht).
static func licht_faktor(h := -1.0) -> float:
	return lerpf(1.0, LICHT_NACHTS, dunkelheit(h))


## Uhrzeit als Text, z. B. „21:30“.
static func text(h := -1.0) -> String:
	if h < 0.0:
		h = stunde()
	var minuten := int(h * 60.0) % (24 * 60)
	return "%02d:%02d" % [minuten / 60, minuten % 60]
