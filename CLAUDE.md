# Hinweise für Claude

- Marco (CazeX Studio) programmiert nicht selbst: Claude macht die technische Arbeit,
  Marco trifft Design-Entscheidungen und testet in Godot. Erklärungen auf Deutsch, ohne Fachjargon.
- Godot 4.7.2: `C:\GameDev\Godot\Godot_v4.7.2-stable_win64.exe`
  (Konsolenversion `..._console.exe` für Headless-Prüfungen, z. B.
  `--headless --path C:\GameDev\MiniKampf --quit-after 120`).
- Einstieg in einen neuen Chat: In `BAUAUFTRAEGE.md` steht ganz oben die „Demo-Reihenfolge“ (D1 bis D36, Testtage T1 bis T4), `FORTSCHRITT.md` nennt den nächsten Schritt.
- GitHub: Account `CazeX-studio`, Repo `CazeX-studio/MiniKampf`. Login läuft über die GitHub CLI (`gh`).
- GDScript mit Typangaben, Tabs zum Einrücken, Kommentare und Texte im Spiel auf Deutsch.
- Langfristiges Ziel: 2D-Story-MMO mit Holy-Trinity (Tank/Heiler/Schaden). Dieses Projekt ist der kleine Einstieg.

## „Mach den nächsten Bauauftrag“

Sagt Marco „Mach den nächsten Bauauftrag“ (oder ähnlich), dann:
1. FORTSCHRITT.md kurz lesen, damit klar ist, was schon gebaut ist.
2. In BAUAUFTRAEGE.md den obersten offenen Punkt der „Demo-Reihenfolge“ nehmen (die Testtage stehen seit 02.11.2026 am Ende, wegen ihnen nicht anhalten); ist sie abgearbeitet, den nächsten Schritt mit „Status: offen“ von oben nach unten (Abschnitt „Später“ auslassen). Ist er durch FORTSCHRITT.md schon erledigt, auf „fertig“ setzen und den nächsten nehmen.
3. Status auf „in Arbeit“ setzen, den Schritt bauen. Die Beschlüsse in design.md (Repo Spieldesign) gelten.
4. Committen (kurze deutsche Nachricht, z. B. „Bauauftrag: Geld-Anzeige“), Status in BAUAUFTRAEGE.md auf „fertig“ setzen, den Schritt in FORTSCHRITT.md eintragen (mit „So testest du es“), committen und pushen.
   Außerdem im Google Doc „CazeX MMO – Brainstorming“ (Abschnitt „Bauaufträge-Entwurf“) den Status des Schritts auf „fertig“ setzen, damit Doc, BAUAUFTRAEGE.md und FORTSCHRITT.md immer dasselbe sagen. Genaue Schritte: Skill `.claude/skills/bauauftrag/SKILL.md`.
5. Marco in 2–3 einfachen Sätzen sagen, was jetzt im Spiel geht und wie er es in Godot testet.

Das gilt genauso in Claude Code in der Cloud (vom Handy): dort direkt im GitHub-Repo arbeiten, committen und pushen – Marco testet später am PC in Godot. Ist ein Schritt zu groß für eine Sitzung, ihn in BAUAUFTRAEGE.md in kleinere Schritte teilen und nur den ersten bauen.

## Werkzeuge

- Python auf dem PC mit Pillow, numpy und scipy: `C:/GameDev/.venv/Scripts/python.exe` (das normale `python` geht nicht). Für Umlaute in der Ausgabe `PYTHONIOENCODING=utf-8` setzen.
- Bilder importieren: `..._console.exe --path . --import --headless`.
- Eine Prüfung: `..._console.exe --headless --path . -s tests/<name>_test.gd`. Alle Prüfungen: `bash tools/alle_tests.sh` (gleichzeitig auf allen Kernen, rund 45 s in der Cloud; mit einem Wort dahinter nur passende, z. B. `gruenwacht`; die Uhr steht dabei auf 12 Uhr, nachts prüfen mit `MINIKAMPF_STUNDE=23`). Alle müssen sauber sein.
- Leistung messen: `..._console.exe --headless --path . -s tests/leistung_messen.gd` (Rechenzeit pro Bild in Kreuzweg). Mit Bild in der Cloud: `xvfb-run -a ~/godot/godot --path . --rendering-driver opengl3 -s tests/leistung_messen.gd -- 300` (Software-Grafik, nur zum Vergleichen vorher/nachher).
- Fotos aus dem Spiel: `..._console.exe --path . res://tests/<name>_foto.tscn -- <Ordner>` (z. B. `gruenwacht_foto`).
- Commits: Dateien gezielt hinzufügen (`tools/referenz/*.png.import` nicht mitnehmen), auf `main` pushen.
- Google Doc „CazeX MMO – Brainstorming“: ID `1yVavfCZW8AntSBdW14AA6RUH6KY50G1L9OGxyzEUawg`. Es ist zu groß zum direkten Lesen: Das gespeicherte Ergebnis mit Python öffnen.
- Neue gemalte Bilder (Figuren, Porträts, Figurteile, Baukasten-Objekte) nach dem Import mit `tools/web_bilder.py` aufs kleinere Web-Format stellen (der Web-Export macht es sonst selbst).
- Neue oder geänderte Köpfe: danach das Foto aller Köpfe (`tests/alle_koepfe_foto.tscn`) ansehen. Schräg von vorne müssen Gesicht und Körper in dieselbe Richtung schauen (nach rechts). Köpfe, die nach links gezeichnet sind, kommen in `KOPF_VORN_GESPIEGELT` (scripts/kampf/figur_teile.gd).
- Datei aus Marcos Stadt-Editor (stadt_<ort>.json) übernehmen: `python3 tools/stadt_editor_uebernehmen.py <datei>`.
- Karten von Grünwacht neu erzeugen: `tools/gruenwacht_karten.py`. Bilder zuschneiden: `tools/baukasten_zuschneiden.py <blatt>`.

## In der Cloud (Marco arbeitet auch vom Handy)

- **Zu Beginn jedes Cloud-Chats einmal `bash tools/cloud_einrichten.sh` starten.** Das holt Godot 4.7.2 für Linux nach `~/godot/godot`, installiert die Python-Pakete und importiert die Bilder. Python ist dort `python3`, die Befehle unter „Werkzeuge“ gelten sonst gleich.
- `design.md` und `GRAFIK_AUFTRAG.md` liegen im privaten Repo `CazeX-studio/Spieldesign`. Ist es nicht da, mit `git clone` holen; geht das nicht, Marco bitten, es dem Chat hinzuzufügen. Nicht ohne die Beschlüsse bauen.
- Direkt auf `main` committen und pushen, nicht auf Nebenzweige. Jeder Push veröffentlicht die Web-Version unter https://cazex-studio.github.io/MiniKampf/ (Startseite `web/index.html`, das Spiel unter `/spiel/`).
- Fehlt der Zugriff auf das Google Doc, Marco den fertigen Status-Text zum Einfügen geben (siehe Skill `bauauftrag`).
- Bilder von Marco kommen als Anhang im Chat: unter `tools/vorlagen/` mit sprechendem Namen ablegen und mit committen.

## Marcos Arbeitsregeln

- „Mach weiter“ heißt: Skill `bauauftrag`, obersten offenen Punkt der Demo-Reihenfolge bauen. Alle Testtage kommen am Ende (Marcos Beschluss 02.11.2026), nicht anhalten.
- Antworten knapp halten: was jetzt geht, was fehlt, was seine Sache ist.
- Entscheidungen ohne Spoiler: Knöpfe und Fragen nennen nur die Handlung, Folgen erst nach der Wahl.
- Prompts (Grafik-Nachbesserungen, fehlende oder neue Bilder) immer fertig in `GRAFIK_AUFTRAG.md` (Repo Spieldesign) speichern, nicht in den Chat schreiben. Erst wenn Marco nach Prompts fragt, sie im Chat zum Kopieren abliefern (Marco, 10.11.2026).
- Marco testet zwischendurch nicht, die Testpunkte (3 bis 5, in einfachen Worten) nur in `FORTSCHRITT.md` eintragen. Nur bei Testtagen im Chat nennen, mit Link zum Spiel.
- Nicht ans Hochladen von design.md als Wissensdatei erinnern.
- Bilder: itch.io ist gesperrt, freie Bilder nur von OpenGameArt oder GitHub (CC0), Quellen in `CREDITS.md`.
