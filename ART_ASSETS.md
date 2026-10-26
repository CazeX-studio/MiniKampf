# Art-Assets – Asterfall

Dieses Dokument legt fest, wo neue Grafik-Assets abgelegt werden. Der konkrete visuelle Stil wird separat festgelegt und ist hier absichtlich nicht vorweggenommen.

## Grundregel

- **Neue, eigene Grafik-Assets** kommen nach `assets/art/`.
- **Bereits verwendete Dateien bleiben vorerst an ihrem bisherigen Pfad.** Szenen und Skripte können diese Pfade bereits referenzieren; nichts wird allein zur Ordnung verschoben.
- Die vorhandenen Ordner `assets/figuren/` und `assets/0x72_dungeontileset_ii/` bleiben unangetastet, bis vorhandene Verwendungen und Lizenzen geprüft sind.
- Musik und Soundeffekte bleiben in `assets/musik/` und `assets/sfx/`.

## Ordnerstruktur für neue Art-Assets

```text
assets/
├── art/
│   ├── characters/
│   │   ├── concepts/       # Entwürfe, Varianten, Referenzblätter
│   │   ├── sprites/        # Im Spiel verwendete Figuren und Animationen
│   │   └── portraits/      # Dialog-, Profil- und Klassenporträts
│   ├── environments/
│   │   ├── tilesets/       # Wiederverwendbare Boden-, Wand- und Naturkacheln
│   │   └── locations/      # Ortsgrafiken und individuelle Szenen-Hintergründe
│   ├── props/              # Einzelobjekte: Möbel, Schilder, Truhen, Pflanzen usw.
│   ├── ui/                 # Symbole, Rahmen, Fenster und weitere UI-Grafiken
│   └── vfx/                # Zauber, Treffer, Heilung und andere visuelle Effekte
├── figuren/                # Bestehende Dateien – vorerst nicht verschieben
├── 0x72_dungeontileset_ii/ # Bestehende Drittanbieter-Assets und Lizenz
├── musik/                  # Bestehende Musik
└── sfx/                    # Bestehende Soundeffekte
```

## Status und Freigabe

Jedes Asset wird in der Übersicht bzw. in seinem Ordner mit einem Status geführt:

1. **Konzept** – Idee oder Entwurf, noch nicht für die Integration freigegeben.
2. **In Arbeit** – wird überarbeitet oder animiert.
3. **Freigegeben** – Design ist abgestimmt und darf integriert werden.
4. **Im Spiel** – in Godot eingebaut und getestet.
5. **Ersetzt** – nicht mehr neu verwenden; alte Referenzen nur nach Prüfung entfernen.

Nur weil ein Bild hübsch aussieht, ist es noch nicht automatisch ein fertiges Game-Asset. Vor der Freigabe prüfen wir unter anderem Transparenz, Abmessungen, Pixelraster, Animationsframes, Ausrichtung und Lesbarkeit im Spiel.

## Dateinamen

- Kleinbuchstaben und Unterstriche verwenden.
- Namen möglichst beschreibend und stabil halten: `vega_portrait.png`, `crossroads_market_tiles.png`, `starfall_hit_effect.png`.
- Varianten eindeutig kennzeichnen: `vega_portrait_v02.png` oder `market_sign_concept_a.png`.
- Keine Statuswörter wie `final_final_neu` verwenden. Der Status gehört in die Asset-Übersicht oder in die Begleitdokumentation.
- Bei Animationen Animationsname und Richtung/Frame nachvollziehbar benennen, sofern das gewählte Godot-Setup einzelne Frames benötigt.

## Dateiformate und Godot

- Transparente Figuren, Objekte und UI-Grafiken normalerweise als PNG speichern.
- Quell- bzw. Arbeitsdateien des verwendeten Zeichenprogramms nach Möglichkeit zusammen mit dem Export aufbewahren, wenn sie für spätere Änderungen gebraucht werden.
- Godot kann zu importierten Dateien `.import`-Metadaten anlegen. Diese nicht von Hand umschreiben; bestehende Ressourcenpfade nicht ohne Prüfung ändern.
- Für große Dateien oder Spritesheets vor der Freigabe sicherstellen, dass Größe und Frame-Aufteilung zum konkreten Godot-Import passen.

## Verantwortung

ChatGPT unterstützt Konzept, Varianten, Dokumentation und visuelle Qualitätsprüfung. Die Projektverantwortlichen geben das Design frei; Claude bzw. die technische Umsetzung integriert freigegebene Assets in Godot. Änderungen an bestehenden Spielpfaden werden getrennt von reinen Art-Ordneränderungen vorgenommen.
