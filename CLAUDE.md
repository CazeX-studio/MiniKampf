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
2. In BAUAUFTRAEGE.md den obersten offenen Punkt der „Demo-Reihenfolge“ nehmen (Testtage dort einhalten); ist sie abgearbeitet, den nächsten Schritt mit „Status: offen“ von oben nach unten (Abschnitt „Später“ auslassen). Ist er durch FORTSCHRITT.md schon erledigt, auf „fertig“ setzen und den nächsten nehmen.
3. Status auf „in Arbeit“ setzen, den Schritt bauen. Die Beschlüsse in design.md (Repo Spieldesign) gelten.
4. Committen (kurze deutsche Nachricht, z. B. „Bauauftrag: Geld-Anzeige“), Status in BAUAUFTRAEGE.md auf „fertig“ setzen, den Schritt in FORTSCHRITT.md eintragen (mit „So testest du es“), committen und pushen.
   Außerdem im Google Doc „CazeX MMO – Brainstorming“ (Abschnitt „Bauaufträge-Entwurf“) den Status des Schritts auf „fertig“ setzen, damit Doc, BAUAUFTRAEGE.md und FORTSCHRITT.md immer dasselbe sagen. Genaue Schritte: Skill `.claude/skills/bauauftrag/SKILL.md`.
5. Marco in 2–3 einfachen Sätzen sagen, was jetzt im Spiel geht und wie er es in Godot testet.

Das gilt genauso in Claude Code in der Cloud (vom Handy): dort direkt im GitHub-Repo arbeiten, committen und pushen – Marco testet später am PC in Godot. Ist ein Schritt zu groß für eine Sitzung, ihn in BAUAUFTRAEGE.md in kleinere Schritte teilen und nur den ersten bauen.

## Werkzeuge

- Python mit Pillow, numpy und scipy: `C:/GameDev/.venv/Scripts/python.exe` (das normale `python` geht nicht). Für Umlaute in der Ausgabe `PYTHONIOENCODING=utf-8` setzen.
- Bilder importieren: `..._console.exe --path . --import --headless`.
- Eine Prüfung: `..._console.exe --headless --path . -s tests/<name>_test.gd`. Alle Prüfungen: Schleife über `tests/*_test.gd`, nach `FEHLER|SCRIPT ERROR|Parse` suchen. Alle müssen sauber sein.
- Fotos aus dem Spiel: `..._console.exe --path . res://tests/<name>_foto.tscn -- <Ordner>` (z. B. `gruenwacht_foto`).
- Commits: Dateien gezielt hinzufügen (`tools/referenz/*.png.import` nicht mitnehmen), auf `main` pushen.
- Google Doc „CazeX MMO – Brainstorming“: ID `1yVavfCZW8AntSBdW14AA6RUH6KY50G1L9OGxyzEUawg`. Es ist zu groß zum direkten Lesen: Das gespeicherte Ergebnis mit Python öffnen.
- Karten von Grünwacht neu erzeugen: `tools/gruenwacht_karten.py`. Bilder zuschneiden: `tools/baukasten_zuschneiden.py <blatt>`.
