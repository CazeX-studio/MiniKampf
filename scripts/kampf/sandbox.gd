class_name Sandbox
extends RefCounted
## Daten der Kampf-Sandbox: alle 11 Startklassen, Duette, Zähmer-Monster, Gegner und Kämpfe.
## Die Auswahl (Team, Start-Monster, Gegner) merkt sich das Spiel hier zwischen den Bildschirmen.

static var team: Array[String] = []
static var starter := "glutwelpe"
static var encounter := "beides"
## Entscheidung nach der Pilzhöhle: "" (noch keine), "faellen" oder "retten"
static var pilz_choice := ""

const MAX_TEAM := 4

const ROLE_COLORS := {"Tank": Color("4a8cf0"), "Schaden": Color("e0533d"), "Support": Color("4cc46a")}

## Reihenfolge auf dem Auswahl-Bildschirm
const CLASS_ORDER: Array[String] = [
	"tank", "mechanic", "smith",
	"archer", "blade", "twilight", "tamer",
	"ritualist", "quartermaster", "kunoichi", "singer",
]

## Werte und Texte der Startklassen (vereinfacht nach design.md, Abschnitt 4).
## reaction: "parry" (Parieren), "dodge" (Ausweichen) oder "" (keine)
const CLASSES := {
	"tank": {
		hero = "Arkon", title = "Magier-Tank", role = "Tank", region = "Arkanum", color = Color("4a7cff"),
		hp = 150, mana = 80, start_mana = 60, tempo = 9, back = false, reaction = "parry",
		mechanic = "Umwandlung: Die Hälfte des Schadens geht auf Mana statt Leben.",
		reaction_text = "Parieren: +15 Mana",
		ult = "Arkane Festung · lädt durch Schaden, den er mit Mana auffängt",
	},
	"mechanic": {
		hero = "Fritz", title = "Mechaniker", role = "Tank", region = "Messinghafen", color = Color("d9a441"),
		hp = 95, mana = 60, tempo = 10, back = false, reaction = "parry",
		mechanic = "Roboter Zahnrad kämpft mit eigener Lebensleiste und eigenem Zug. Fritz selbst ist schwach.",
		reaction_text = "Parieren: Abklingzeiten −1",
		ult = "Neuer Roboter · lädt durch Schaden, den der Roboter einsteckt",
	},
	"smith": {
		hero = "Brunhild", title = "Rüstungsschmied", role = "Tank", region = "Glutoase", color = Color("e07a3d"),
		hp = 165, mana = 40, tempo = 8, back = false, reaction = "parry",
		mechanic = "Drei Rüstungen (Nahkampf, Magie, Fernkampf). Passende Treffer härten: bis 5× Gehärtet.",
		reaction_text = "Parieren: +1 Härte",
		ult = "Meisterstück · lädt durch Treffer in der passenden Rüstung",
	},
	"archer": {
		hero = "Wren", title = "Bogenschütze", role = "Schaden", region = "Grünwacht", color = Color("5fd35f"),
		hp = 95, mana = 50, tempo = 13, back = true, reaction = "dodge",
		mechanic = "Bogen spannen: nächster Schuss ×2,5. Hinten öfter kritisch (Ruhige Hand).",
		reaction_text = "Perfektes Ausweichen",
		ult = "Jägerpfeil · lädt durch aufgeladene Schüsse und kritische Treffer",
	},
	"blade": {
		hero = "Zara", title = "Klingentänzerin", role = "Schaden", region = "Glutoase", color = Color("ff9a5c"),
		hp = 100, mana = 50, tempo = 14, back = false, reaction = "parry",
		mechanic = "Bis zu 5 schwebende Klingen (+5 % Schaden je Klinge). Schritt, Wirbel, Ausfall = Tanzfolge.",
		reaction_text = "Parieren: +1 Klinge",
		ult = "Tanz der tausend Klingen · lädt durch Tanzfolgen und verbrauchte Klingen",
	},
	"twilight": {
		hero = "Nyx", title = "Zwielicht-Wandler", role = "Schaden", region = "Arkanum", color = Color("9b7cff"),
		hp = 90, mana = 70, tempo = 12, back = true, reaction = "",
		mechanic = "Leiste zwischen Licht und Schatten. Am Rand überladen: ×1,6 Schaden, aber Rückstoß.",
		reaction_text = "keine Reaktion",
		ult = "Sonnenfinsternis · lädt bei jedem Überqueren der Mitte",
	},
	"tamer": {
		hero = "Pip", title = "Monster-Zähmer", role = "Schaden", region = "Grünwacht", color = Color("8fd36b"),
		hp = 80, mana = 50, tempo = 11, back = true, reaction = "",
		mechanic = "3 Monster (Moosling, Glutwelpe, Bachotter), eines kämpft. Wechsel wie bei Pokémon.",
		reaction_text = "keine Reaktion",
		ult = "Rudelruf · lädt durch Monster-Aktionen und gut getimte Wechsel",
	},
	"ritualist": {
		hero = "Vesna", title = "Ritualist", role = "Support", region = "Nebelinseln", color = Color("c2304f"),
		hp = 110, mana = 0, tempo = 10, back = true, reaction = "",
		mechanic = "Heilen kostet Blutvorrat, danach eigenes Leben. Biss füllt den Vorrat.",
		reaction_text = "keine Reaktion",
		ult = "Großes Opfer · lädt durch für andere geopfertes Leben",
	},
	"quartermaster": {
		hero = "Gundo", title = "Quartiermeister", role = "Support", region = "Messinghafen", color = Color("f2c14e"),
		hp = 105, mana = 0, tempo = 10, back = true, reaction = "",
		mechanic = "Karren mit gekauften Waren, bezahlt mit Gold. Geht der Karren kaputt, sind die Waren weg.",
		reaction_text = "keine Reaktion",
		ult = "Goldrausch · lädt durch ausgegebenes Gold",
	},
	"kunoichi": {
		hero = "Hana", title = "Kunoichi", role = "Support", region = "Nebelinseln", color = Color("ff7fb0"),
		hp = 95, mana = 60, tempo = 15, back = true, reaction = "dodge",
		mechanic = "Klebt Element-Siegel auf Gegner und löst sie. Zwei Siegel zusammen = Kombination.",
		reaction_text = "Ausweichen + Konter-Kunai",
		ult = "Tausend Siegel · lädt durch ausgelöste Siegel-Kombinationen",
	},
	"singer": {
		hero = "Vega", title = "Sternensängerin", role = "Support", region = "Glutoase", color = Color("ffd34d"),
		hp = 95, mana = 90, tempo = 11, back = true, reaction = "dodge",
		mechanic = "Zwei Sternbilder (Angriff/Schutz) füllen. Ungenutzt verblassen sie.",
		reaction_text = "Ausweichen: +1 Resonanz in beide",
		ult = "Himmelszelt · lädt durch verbrauchte Resonanz",
	},
	# Novize: Spielfigur der Kreuzweg-Demo vor der Klassenwahl (nicht in der Sandbox-Auswahl)
	"novize": {
		hero = "Novize", title = "Novize", role = "Schaden", region = "Kreuzweg", color = Color("8affc1"),
		hp = 90, mana = 40, tempo = 11, back = false, reaction = "parry",
		mechanic = "Grundlagen: Schlag, Kraftschlag, Erste Hilfe. Noch keine Klasse.",
		reaction_text = "Parieren",
		ult = "keine (kommt mit der Klasse)",
	},
}

## Duett-Fähigkeiten: Klassen-Paare aus derselben Region (Sternentanz: Sternensängerin + Tänzerin).
const DUETS: Array[Dictionary] = [
	{id = "treibjagd", name = "Treibjagd", a = "archer", b = "tamer", target = "enemy",
		info = "Pfeil + Monster-Angriff, Ziel gehetzt"},
	{id = "blutsiegel", name = "Blutsiegel", a = "kunoichi", b = "ritualist", target = "enemy",
		info = "24 Schatten, Gruppe heilt die Hälfte"},
	{id = "nachschub", name = "Nachschub", a = "mechanic", b = "quartermaster", target = "none",
		info = "Roboter +40, alle +12 LP/Mana · 20 Gold"},
	{id = "gluehende_klingen", name = "Glühende Klingen", a = "smith", b = "blade", target = "enemy",
		info = "18 Feuer, Zara +3 Klingen mit Feuer"},
	{id = "zwielicht_barriere", name = "Zwielicht-Barriere", a = "tank", b = "twilight", target = "none",
		info = "Alle Schild 20, 10 Licht an alle"},
	{id = "sternentanz", name = "Sternentanz", a = "singer", b = "blade", target = "none",
		info = "Klingen treffen 1 Runde mit Sternenkraft, +2 Klingen"},
]
const DUET_CD := 4

## Monster des Zähmers (Element-Dreieck: Feuer > Pflanze > Wasser > Feuer)
const MONSTERS := {
	"moosling": {name = "Moosling", element = "Pflanze", role = "Beschützer", hp = 120, tempo = 8,
		bench = "Auf der Bank: aktives Monster bekommt 15 % weniger Schaden"},
	"glutwelpe": {name = "Glutwelpe", element = "Feuer", role = "Angreifer", hp = 80, tempo = 13,
		bench = "Auf der Bank: aktives Monster macht 15 % mehr Schaden"},
	"bachotter": {name = "Bachotter", element = "Wasser", role = "Helfer", hp = 90, tempo = 11,
		bench = "Auf der Bank: aktives Monster heilt sich jeden Zug um 5"},
}
const MONSTER_ORDER: Array[String] = ["moosling", "glutwelpe", "bachotter"]
## So viele Monster kann der Zähmer höchstens dabeihaben (3 Start-Monster + 2 gezähmte).
const MAX_MONSTERS := 5

const ROBOT := {name = "Zahnrad", hp = 130, tempo = 9}

## Gegner. attacks: der Reihe nach benutzt. kind: melee / ranged / magic, all = trifft alle.
## tame: zähmbar (Monster-Zähmer), mit dem Angriff, den das Monster dann für die Helden benutzt.
const ENEMIES := {
	"glutkobold": {name = "Glutkobold", element = "Feuer", hp = 62, tempo = 13,
		attacks = [{name = "Glutdolch", base = 13, kind = "melee"}],
		tame = {name = "Glutdolch", base = 13, kind = "melee"}},
	"sumpfschleim": {name = "Sumpfschleim", element = "Wasser", hp = 75, tempo = 8,
		attacks = [{name = "Schleimschlag", base = 15, kind = "melee"}],
		tame = {name = "Schleimschlag", base = 15, kind = "melee"}},
	"dornling": {name = "Dornling", element = "Pflanze", hp = 66, tempo = 10,
		attacks = [{name = "Dornenschuss", base = 12, kind = "ranged"}, {name = "Dornenschuss", base = 12, kind = "ranged"},
			{name = "Dornenregen", base = 6, kind = "ranged", all = true}],
		tame = {name = "Dornenschuss", base = 12, kind = "ranged"}},
	"sturmkobold": {name = "Sturmkobold", element = "Wind", hp = 58, tempo = 14,
		attacks = [{name = "Windklinge", base = 12, kind = "ranged", back = true}],
		tame = {name = "Windklinge", base = 12, kind = "ranged"}},
	"funkenwicht": {name = "Funkenwicht", element = "Blitz", hp = 70, tempo = 12,
		attacks = [{name = "Funke", base = 12, kind = "magic"}, {name = "Funke", base = 12, kind = "magic"},
			{name = "Kettenblitz", base = 7, kind = "magic", all = true}],
		tame = {name = "Funke", base = 12, kind = "magic"}},
	"schattenhexe": {name = "Schattenhexe", element = "Schatten", hp = 80, tempo = 11,
		attacks = [{name = "Schattenpfeil", base = 14, kind = "magic"}, {name = "Dunkler Fluch", base = 6, kind = "magic", all = true}],
		tame = {name = "Schattenpfeil", base = 14, kind = "magic"}},
	"boss": {name = "Steinwächter", element = "Erde", hp = 400, tempo = 9, resist = 0.85, big = true},
	# Pilzhöhle (Abläufe in pilzhoehle.gd)
	"leuchtmotte": {name = "Leuchtmotte", element = "Licht", hp = 48, tempo = 14,
		tame = {name = "Blendstaub", base = 9, kind = "magic"}},
	"wurzelkriecher": {name = "Wurzelkriecher", element = "Erde", hp = 72, tempo = 8,
		tame = {name = "Umklammern", base = 11, kind = "melee"}},
	"sporenwolf": {name = "Sporenwolf", element = "Pflanze", hp = 56, tempo = 13,
		tame = {name = "Rudelbiss", base = 11, kind = "melee"}},
	"glimmerkaefer": {name = "Glimmerkäfer", element = "Blitz", hp = 52, tempo = 12,
		tame = {name = "Funkenbiss", base = 10, kind = "magic"}},
	"sporenkoenigin": {name = "Sporenkönigin", element = "Pflanze", hp = 260, tempo = 9, big = true},
	"sporenling": {name = "Sporenknospe", element = "Pflanze", hp = 42, tempo = 10},
	"wurzelmutter": {name = "Wurzelmutter", element = "Pflanze", hp = 300, tempo = 8, big = true},
	"knoten_vorne": {name = "Knoten vorne", element = "Sternenkraft", hp = 40, tempo = 1, passive = true},
	"knoten_hinten": {name = "Knoten hinten", element = "Sternenkraft", hp = 40, tempo = 1, passive = true},
	"vorbote": {name = "Der Vorbote", element = "Schatten", hp = 240, tempo = 10, big = true},
	# Vor dem Stadttor (Grundausbildung in der Kreuzweg-Demo)
	"feldschleim": {name = "Feldschleim", element = "Wasser", hp = 40, tempo = 8,
		attacks = [{name = "Schleimstoß", base = 8, kind = "melee"}],
		tame = {name = "Schleimstoß", base = 8, kind = "melee"}},
	"wiesenkobold": {name = "Wiesenkobold", element = "Erde", hp = 44, tempo = 12,
		attacks = [{name = "Stockhieb", base = 9, kind = "melee"}, {name = "Steinwurf", base = 8, kind = "ranged"}],
		tame = {name = "Stockhieb", base = 9, kind = "melee"}},
	"ruepelkobold": {name = "Rüpelkobold", element = "Feuer", hp = 110, tempo = 9,
		attacks = [{name = "Keulenschlag", base = 21, kind = "melee"}],
		tame = {name = "Keulenschlag", base = 13, kind = "melee"}},
	"uebungs_ye": {name = "Ausbilder Ye", element = "", hp = 999, tempo = 12, title = "Ausbilder Ye",
		attacks = [{name = "Übungsschwert", base = 7, kind = "melee"}]},
	# Nacht des Sternenfalls (Kreuzweg-Demo): Ein Feldschleim hat einen Splitter gefressen
	"sternenfresser": {name = "Der Sternenfresser", element = "Sternenkraft", hp = 240, tempo = 9, big = true,
		panzer = 0.1, erschuettert = 2, wipe_nach = 10, wipe_text = "Der Splitter im Bauch des Sternenfressers explodiert!",
		attacks = [{name = "Sternenschlag", base = 28, kind = "melee"}, {name = "Splitterregen", base = 14, kind = "magic", all = true},
			{name = "Sternenschlag", base = 28, kind = "melee"}, {name = "Leuchtender Biss", base = 20, kind = "melee"}]},
}

## Kämpfe zur Auswahl. Jede Welle ist eine Liste von Gegnern.
const ENCOUNTERS := {
	"monster": {name = "Monstergruppe", info = "4 Monster: Feuer, Wasser, Pflanze, Wind",
		waves = [["glutkobold", "sumpfschleim", "dornling", "sturmkobold"]]},
	"boss": {name = "Boss", info = "Steinwächter (Erde) + Blitz + Schatten",
		waves = [["boss", "funkenwicht", "schattenhexe"]]},
	"beides": {name = "Beides", info = "Erst die Monster, dann der Boss",
		waves = [["glutkobold", "sumpfschleim", "dornling", "sturmkobold"], ["boss", "funkenwicht", "schattenhexe"]]},
	"pilzhoehle": {name = "Pilzhöhle", info = "Ganzer Dungeon: Monster, Sporenkönigin, Wurzelmutter", dungeon = "pilzhoehle",
		waves = [["sporenwolf", "sporenwolf", "leuchtmotte", "wurzelkriecher"], ["sporenkoenigin", "sporenling", "sporenling"],
			["glimmerkaefer", "glimmerkaefer", "leuchtmotte", "sporenwolf"], ["wurzelmutter", "knoten_vorne", "knoten_hinten"]]},
	"pilzbosse": {name = "Pilzhöhle: nur Bosse", info = "Sporenkönigin, dann Wurzelmutter und Vorbote", dungeon = "pilzhoehle",
		waves = [["sporenkoenigin", "sporenling", "sporenling"], ["wurzelmutter", "knoten_vorne", "knoten_hinten"]]},
}
const ENCOUNTER_ORDER: Array[String] = ["monster", "boss", "beides", "pilzhoehle", "pilzbosse"]

## Gegner-Leben je nach Teamgröße (1 bis 4 Klassen)
const HP_SCALE: Array[float] = [0.5, 0.68, 0.85, 1.0]


## Welche Duette das Team gerade hat.
static func active_duets(p_team: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for duet in DUETS:
		if duet.a in p_team and duet.b in p_team:
			result.append(duet)
	return result
