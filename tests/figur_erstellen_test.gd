extends SceneTree
## Projekt 11, Schritt 5: Figur erstellen. Zusammengesetztes Aussehen („novize_w+mira“) wird gezeigt und gespeichert.


func _init() -> void:
	var fehler := 0
	# Aussehen „Körper+Kopf“: eigene Figur, gleiche Größe wie Kofi, Bilder werden zusammengesetzt
	var look := "novize_w+mira"
	if not FighterView.is_own_sprite(look) or FighterView.look_data(look).scale != 3.0:
		print("FEHLER: novize_w+mira gilt nicht als eigene Figur")
		fehler += 1
	if FighterView.sprite_path(look, "idle", 0) != FighterView.sprite_path("novize_w", "idle", 0):
		print("FEHLER: Bildpfad sollte vom Körper kommen")
		fehler += 1
	var mit_mira := FighterView.einzelbild(look, "idle", 0)
	var mit_kofi := FighterView.einzelbild("novize_w+kofi", "idle", 0)
	if mit_mira == null or mit_kofi == null or mit_mira == mit_kofi:
		print("FEHLER: verschiedene Köpfe sollten verschiedene Bilder geben")
		fehler += 1
	# Der Kopf im Aussehen gilt, egal welcher Kopf im Editor gewählt ist
	FigurTeile.kopf = "kofi"
	if FighterView.einzelbild(look, "idle", 0) != mit_mira:
		print("FEHLER: Kopf aus dem Aussehen wird vom Editor-Kopf überschrieben")
		fehler += 1
	FigurTeile.kopf = ""

	# Speichern und Laden
	SaveGame.path = "user://test_figur_erstellen.json"
	SaveGame.delete()
	var p := PlayerState.new("spieler", "Du", "vega", Vector2i(3, 3))
	p.look = look
	p.figur_name = "Mira"
	SaveGame.save(p)
	if not SaveGame.exists():
		print("FEHLER: Spielstand wurde nicht geschrieben")
		fehler += 1
	var q := PlayerState.new("spieler", "Du", "vega", Vector2i(3, 3))
	SaveGame.load_into(q)
	if q.look != look or q.figur_name != "Mira":
		print("FEHLER: Figur nicht geladen (%s, %s)" % [q.look, q.figur_name])
		fehler += 1
	# Alter Spielstand ohne Figur: Aussehen bleibt wie vorher
	var alt := PlayerState.new("spieler", "Du", "kofi", Vector2i(3, 3))
	alt.figur_name = ""
	SaveGame.save(alt)
	var r := PlayerState.new("spieler", "Du", "kofi", Vector2i(3, 3))
	SaveGame.load_into(r)
	if r.look != "kofi" or r.figur_name != "":
		print("FEHLER: Spielstand ohne Figur ändert das Aussehen")
		fehler += 1
	SaveGame.delete()
	SaveGame.path = SaveGame.DEFAULT_PATH

	print("figur_erstellen_test: %s" % ("OK" if fehler == 0 else "%d Fehler" % fehler))
	quit(1 if fehler > 0 else 0)
