extends SceneTree
## Prüft die Bank (Projekt 4, Schritt 2): Einlagern und Abholen, dieselbe Bank an allen Bankstellen,
## volle Bank, volle Tasche, Speichern und Bankplätze kaufen.
## Aufruf: Godot --headless --path . --script res://tests/bank_test.gd

var _failed := 0


func _check(ok: bool, text: String) -> void:
	print(("ok      " if ok else "FEHLER  ") + text)
	if not ok:
		_failed += 1


func _initialize() -> void:
	var world := WorldState.new()
	var p := world.add_player("spieler", "Du", "vega", WorldState.start_cell())
	p.progress.items = {heiltrank = 3, kraut = 5}
	# Ohne geöffnete Bank geht nichts
	world.apply_command("spieler", {type = "einlagern", gegenstand = "heiltrank"})
	_check(p.progress.total_count("heiltrank") == 3 and p.progress.bank.is_empty(), "Ohne Bank kann man nichts einlagern")
	# Bankstelle in Kreuzweg
	_check(world.npcs.has("bank_kreuzweg") and world.npcs.has("bank_wipfelheim"), "Bankstellen in Kreuzweg und Wipfelheim")
	p.shop = "bank"
	world.apply_command("spieler", {type = "einlagern", gegenstand = "heiltrank"})
	_check(p.progress.total_count("heiltrank") == 0 and int(p.progress.bank.get("heiltrank", 0)) == 3, "3 Heiltränke eingelagert")
	world.apply_command("spieler", {type = "laden_zu"})
	# Andere Bankstelle: dieselbe Bank
	p.shop = "bank"
	_check(int(p.progress.bank.get("heiltrank", 0)) == 3, "Zweite Bankstelle zeigt dieselben Heiltränke")
	world.apply_command("spieler", {type = "abholen", gegenstand = "heiltrank"})
	_check(p.progress.total_count("heiltrank") == 3 and not p.progress.bank.has("heiltrank"), "Heiltränke wieder abgeholt")
	# Volle Bank
	p.progress.bank = {}
	for i in Progress.BANK_START:
		p.progress.bank["test_%d" % i] = 1
	world.apply_command("spieler", {type = "einlagern", gegenstand = "kraut"})
	_check(p.progress.item_count("kraut") == 5, "Volle Bank nimmt nichts Neues")
	# Volle Tasche
	p.progress.bank = {heiltrank = 2}
	p.progress.items = {}
	for i in Progress.BAG_SIZE:
		p.progress.items["voll_%d" % i] = 1
	world.apply_command("spieler", {type = "abholen", gegenstand = "heiltrank"})
	_check(int(p.progress.bank.get("heiltrank", 0)) == 2, "Volle Tasche: nichts wird abgeholt")
	# Speichern und Laden
	var copy := Progress.new()
	copy.load_dict(p.progress.to_dict())
	_check(copy.bank == {heiltrank = 2} and copy.bank_size == Progress.BANK_START, "Bank wird gespeichert")
	# Bankplätze kaufen (Projekt 4, Schritt 3)
	p.shop = "bank"
	p.progress.gold = 4999
	world.apply_command("spieler", {type = "bank_erweitern"})
	_check(p.progress.bank_size == Progress.BANK_START and p.progress.gold == 4999, "Zu wenig Geld: keine Erweiterung")
	p.progress.gold = 100000
	world.apply_command("spieler", {type = "bank_erweitern"})
	_check(p.progress.bank_size == Progress.BANK_START + 10 and p.progress.gold == 95000, "Erweiterung für 50 Silber: +10 Plätze")
	_check(world.bank_expansion(p).preis == 10000, "Nächste Erweiterung kostet 1 Gold")
	for i in 3:
		world.apply_command("spieler", {type = "bank_erweitern"})
	_check(p.progress.bank_size == Progress.BANK_START + 40 and world.bank_expansion(p).is_empty(), "Nach vier Erweiterungen voll ausgebaut (60 Plätze)")
	var gold := p.progress.gold
	world.apply_command("spieler", {type = "bank_erweitern"})
	_check(p.progress.gold == gold, "Voll ausgebaut: kein Geld weg")
	var saved := Progress.new()
	saved.load_dict(p.progress.to_dict())
	_check(saved.bank_size == Progress.BANK_START + 40, "Bankplätze werden gespeichert")
	print("Bank: %s" % ("alles richtig" if _failed == 0 else "%d Fehler" % _failed))
	quit(_failed)
