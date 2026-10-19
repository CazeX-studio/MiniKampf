class_name Dialogs
extends RefCounted
## Gesprächstexte der NPCs. Jede Zeile: wer spricht und was.

const YE_FIRST: Array[Dictionary] = [
	{who = "Ye", text = "Ah, ein neues Gesicht. Willkommen in Kreuzweg, Novize."},
	{who = "Ye", text = "Ich bin Ye. Ich bringe Anfängern bei, wie man da draußen überlebt. Nicht mehr, nicht weniger."},
	{who = "Ye", text = "Merk dir eins für den Kampf: Schild hoch, Schild runter. Im richtigen Moment, nicht früher."},
	{who = "Ye", text = "Sechs Straßen führen aus dieser Stadt. Benutzt werden nur fünf. Frag mich nicht, warum."},
	{who = "Ye", text = "Die Laterne an der Wand? … Ein Erinnerungsstück. Vielleicht erzähle ich dir irgendwann davon."},
]
const YE_AGAIN: Array[Dictionary] = [
	{who = "Ye", text = "Na? Schon geübt? Schild hoch, Schild runter."},
]


static func lines_for(npc_id: String, first_time: bool) -> Array[Dictionary]:
	match npc_id:
		"ye":
			return YE_FIRST if first_time else YE_AGAIN
	return []
