---
name: bauauftrag
description: Nächsten Bauauftrag für MiniKampf bauen und danach alle drei Stellen gleich halten (BAUAUFTRAEGE.md, FORTSCHRITT.md und den Abschnitt „Bauaufträge-Entwurf“ im Google Doc „CazeX MMO – Brainstorming“). Benutzen, wenn Marco „Mach den nächsten Bauauftrag“, „Starte den nächsten Bauauftrag“ oder Ähnliches sagt, oder wenn ein Bauauftrag fertig, geteilt oder umsortiert wird.
---

# Bauauftrag bauen und alles gleich halten

Marco plant im Google Doc „CazeX MMO – Brainstorming“ (Abschnitt „Bauaufträge-Entwurf“), Claude Code baut im Repo.
Damit Marco beim Brainstormen immer den echten Stand sieht, müssen **drei Stellen** dasselbe sagen:

| Stelle | Was dort steht |
|---|---|
| `BAUAUFTRAEGE.md` (Repo MiniKampf) | Liste der Schritte mit Status (offen / in Arbeit / fertig) |
| `FORTSCHRITT.md` (Repo MiniKampf), Abschnitt „Bauaufträge“ | Was gebaut ist, mit „So testest du es“ |
| Google Doc „CazeX MMO – Brainstorming“, Abschnitt „Bauaufträge-Entwurf“ | Dieselben Schritte mit „Status: …“ am Ende |

## Ablauf

1. **Stand holen:** FORTSCHRITT.md kurz lesen. Das Doc lesen (Drive `search_files` mit `title contains 'CazeX MMO'`,
   dann `read_file_content`, Abschnitt „Bauaufträge-Entwurf“ suchen). Weicht die Reihenfolge oder ein Schritt im Doc
   von BAUAUFTRAEGE.md ab, gilt das Doc (Marco plant dort) – BAUAUFTRAEGE.md zuerst daran angleichen, fertige
   Schritte behalten ihren Status.
2. **Schritt wählen:** den obersten Schritt mit „Status: offen“ (Abschnitt „Später“ auslassen). Ist er laut
   FORTSCHRITT.md schon erledigt, auf „fertig“ setzen und den nächsten nehmen.
3. **Bauen:** Status „in Arbeit“. Die Beschlüsse in design.md (Repo Spieldesign) gelten. Prüfen mit Godot
   (headless-Tests unter `tests/`, bei Grafik Bildschirmfotos). In der Cloud: Godot 4.7.2 für Linux von GitHub laden.
4. **Committen:** kurze deutsche Nachricht, z. B. „Bauauftrag: Licht wie bei Octopath Traveler“.
5. **Alle drei Stellen nachziehen:**
   - BAUAUFTRAEGE.md: „Status: fertig (Datum)“.
   - FORTSCHRITT.md: Eintrag im Abschnitt „Bauaufträge“ mit „So testest du es“, im „Aktueller Stand“ den nächsten Schritt nennen.
   - Google Doc: im Abschnitt „Bauaufträge-Entwurf“ beim Schritt „Status: offen.“ ersetzen durch
     „Status: fertig (Datum, gebaut von Claude Code: kurz was drin ist; was noch fehlt).“
     Am einfachsten mit Docs `update_doc` und `replaceAllText` auf einen **eindeutigen** Satzteil des Schritts
     (z. B. das Ende von „So testest du es … Status: offen.“), danach mit Drive-Suche
     (`fullText contains 'Status: fertig (Datum'`) prüfen, dass es genau einmal geändert wurde.
   - Wurde ein Schritt geteilt oder ein Hinweis „Schon da“ ergänzt, das auch im Doc eintragen.
6. Committen und pushen (BAUAUFTRAEGE.md und FORTSCHRITT.md).
7. Marco in 2–3 einfachen Sätzen sagen, was jetzt im Spiel geht, wie er es in Godot testet, und dass das Doc
   aktualisiert ist.

## Regeln

- Im Doc nichts löschen oder umformulieren außer dem Status (Ideen werden nie gestrichen).
- Ist der Google-Docs-Connector nicht verfügbar: Marco sagen, dass das Doc noch nachgezogen werden muss, und den
  fertigen Status-Text zum Einfügen mitgeben.
- Alles auf Deutsch, ohne Fachjargon.
