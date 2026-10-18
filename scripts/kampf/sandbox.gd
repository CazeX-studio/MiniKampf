class_name Sandbox
extends RefCounted
## Daten der Kampf-Sandbox: alle 11 Startklassen, Duette, Zähmer-Monster, Gegner und Kämpfe.
## Die Auswahl (Team, Start-Monster, Gegner) merkt sich das Spiel hier zwischen den Bildschirmen.

static var team: Array[String] = []
static var starter := "glutwelpe"
static var encounter := "beides"

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
		hero = "Lyra", title = "Sternensängerin", role = "Support", region = "Glutoase", color = Color("ffd34d"),
		hp = 95, mana = 90, tempo = 11, back = true, reaction = "dodge",
		mechanic = "Zwei Sternbilder (Angriff/Schutz) füllen. Ungenutzt verblassen sie.",
		reaction_text = "Ausweichen: +1 Resonanz in beide",
		ult = "Himmelszelt · lädt durch verbrauchte Resonanz",
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

const ROBOT := {name = "Zahnrad", hp = 130, tempo = 9}

## Gegner. attacks: der Reihe nach benutzt. kind: melee / ranged / magic, all = trifft alle.
const ENEMIES := {
	"glutkobold": {name = "Glutkobold", element = "Feuer", hp = 62, tempo = 13,
		attacks = [{name = "Glutdolch", base = 13, kind = "melee"}]},
	"sumpfschleim": {name = "Sumpfschleim", element = "Wasser", hp = 75, tempo = 8,
		attacks = [{name = "Schleimschlag", base = 15, kind = "melee"}]},
	"dornling": {name = "Dornling", element = "Pflanze", hp = 66, tempo = 10,
		attacks = [{name = "Dornenschuss", base = 12, kind = "ranged"}, {name = "Dornenschuss", base = 12, kind = "ranged"},
			{name = "Dornenregen", base = 6, kind = "ranged", all = true}]},
	"sturmkobold": {name = "Sturmkobold", element = "Wind", hp = 58, tempo = 14,
		attacks = [{name = "Windklinge", base = 12, kind = "ranged", back = true}]},
	"funkenwicht": {name = "Funkenwicht", element = "Blitz", hp = 70, tempo = 12,
		attacks = [{name = "Funke", base = 12, kind = "magic"}, {name = "Funke", base = 12, kind = "magic"},
			{name = "Kettenblitz", base = 7, kind = "magic", all = true}]},
	"schattenhexe": {name = "Schattenhexe", element = "Schatten", hp = 80, tempo = 11,
		attacks = [{name = "Schattenpfeil", base = 14, kind = "magic"}, {name = "Dunkler Fluch", base = 6, kind = "magic", all = true}]},
	"boss": {name = "Steinwächter", element = "Erde", hp = 400, tempo = 9, resist = 0.85},
}

## Kämpfe zur Auswahl. Jede Welle ist eine Liste von Gegnern.
const ENCOUNTERS := {
	"monster": {name = "Monstergruppe", info = "4 Monster: Feuer, Wasser, Pflanze, Wind",
		waves = [["glutkobold", "sumpfschleim", "dornling", "sturmkobold"]]},
	"boss": {name = "Boss", info = "Steinwächter (Erde) + Blitz + Schatten",
		waves = [["boss", "funkenwicht", "schattenhexe"]]},
	"beides": {name = "Beides", info = "Erst die Monster, dann der Boss",
		waves = [["glutkobold", "sumpfschleim", "dornling", "sturmkobold"], ["boss", "funkenwicht", "schattenhexe"]]},
}
const ENCOUNTER_ORDER: Array[String] = ["monster", "boss", "beides"]

## Gegner-Leben je nach Teamgröße (1 bis 4 Klassen)
const HP_SCALE: Array[float] = [0.5, 0.68, 0.85, 1.0]


## Welche Duette das Team gerade hat.
static func active_duets(p_team: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for duet in DUETS:
		if duet.a in p_team and duet.b in p_team:
			result.append(duet)
	return result
