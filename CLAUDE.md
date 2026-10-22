# Hinweise für Claude

- Marco (CazeX Studio) programmiert nicht selbst: Claude macht die technische Arbeit,
  Marco trifft Design-Entscheidungen und testet in Godot. Erklärungen auf Deutsch, ohne Fachjargon.
- Godot 4.7.2: `C:\GameDev\Godot\Godot_v4.7.2-stable_win64.exe`
  (Konsolenversion `..._console.exe` für Headless-Prüfungen, z. B.
  `--headless --path C:\GameDev\MiniKampf --quit-after 120`).
- GitHub: Account `CazeX-studio`, Repo `CazeX-studio/MiniKampf`. Login läuft über die GitHub CLI (`gh`).
- GDScript mit Typangaben, Tabs zum Einrücken, Kommentare und Texte im Spiel auf Deutsch.
- Langfristiges Ziel: 2D-Story-MMO mit Holy-Trinity (Tank/Heiler/Schaden). Dieses Projekt ist der kleine Einstieg.

## „Mach den nächsten Bauauftrag“

Sagt Marco „Mach den nächsten Bauauftrag“ (oder ähnlich), dann:
1. FORTSCHRITT.md kurz lesen, damit klar ist, was schon gebaut ist.
2. In BAUAUFTRAEGE.md den nächsten Schritt mit „Status: offen“ nehmen (von oben nach unten, Abschnitt „Später“ auslassen). Ist er durch FORTSCHRITT.md schon erledigt, auf „fertig“ setzen und den nächsten nehmen.
3. Status auf „in Arbeit“ setzen, den Schritt bauen. Die Beschlüsse in design.md (Repo Spieldesign) gelten.
4. Committen (kurze deutsche Nachricht, z. B. „Bauauftrag: Geld-Anzeige“), Status in BAUAUFTRAEGE.md auf „fertig“ setzen, den Schritt in FORTSCHRITT.md eintragen (mit „So testest du es“), committen und pushen.
5. Marco in 2–3 einfachen Sätzen sagen, was jetzt im Spiel geht und wie er es in Godot testet.

Das gilt genauso in Claude Code in der Cloud (vom Handy): dort direkt im GitHub-Repo arbeiten, committen und pushen – Marco testet später am PC in Godot. Ist ein Schritt zu groß für eine Sitzung, ihn in BAUAUFTRAEGE.md in kleinere Schritte teilen und nur den ersten bauen.
