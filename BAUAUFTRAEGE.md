# Bauaufträge

Kleine Bauaufträge für Claude Code, abgeleitet aus den Beschlüssen in design.md (Repo Spieldesign).
Sagt Marco „Mach den nächsten Bauauftrag“: kurz FORTSCHRITT.md prüfen, den nächsten offenen Schritt von oben nehmen, bauen, committen, Status auf „fertig“ setzen und in FORTSCHRITT.md eintragen.

Status: offen / in Arbeit / fertig

## Projekt 1: Geld (Bronze, Silber, Gold)
_Aus den Beschlüssen vom 21.10.2026: Geld ist knapp, Währung Bronze, Silber, Gold._

### Schritt 1: Geld speichern und anzeigen
- **Ziel:** Geld wird als eine Zahl gespeichert und als Bronze, Silber und Gold angezeigt (100 Bronze = 1 Silber, 100 Silber = 1 Gold). Die Münznamen stehen an einer einzigen Stelle, damit man sie später leicht umbenennen kann.
- **So testest du es:** Geld-Anzeige ansehen, per Testknopf Geld dazugeben und prüfen, ob die Münzen richtig umspringen.
- **Status:** offen

### Schritt 2: Monster lassen wenig Geld fallen
- **Ziel:** Besiegte Monster geben einen kleinen Geldbetrag, damit Geld knapp bleibt.
- **So testest du es:** Monster besiegen, das Geld steigt um einen kleinen Betrag.
- **Schon da:** Monster in der Wildnis geben bereits „etwas Gold“. Offen ist, die Beträge auf Bronze/Silber/Gold umzustellen und knapp zu halten.
- **Status:** offen

## Projekt 2: Tasche und Bank
_Aus den Beschlüssen vom 21.10.2026: Tasche mit festen Plätzen, dieselbe Bank in jeder Stadt, Bankplätze gegen Gold._

### Schritt 1: Tasche mit 30 Plätzen
- **Ziel:** Die Tasche hat 30 Plätze.
- **So testest du es:** Gegenstände aufheben, bis die Tasche voll ist, danach erscheint ein Hinweis.
- **Status:** offen

### Schritt 2: Bank, die überall dasselbe enthält
- **Ziel:** Jede Bankstelle zeigt dieselben eingelagerten Sachen.
- **So testest du es:** Etwas einlagern und wieder herausholen, an zwei Bankstellen prüfen, dass beide dasselbe zeigen.
- **Status:** offen

### Schritt 3: Bankplätze gegen Gold erweitern
- **Ziel:** Man kann mehr Bankplätze kaufen.
- **So testest du es:** Erweiterung kaufen, das Geld sinkt, die Bank hat mehr Plätze.
- **Status:** offen

## Projekt 3: Gürtel und Tränke
_Aus den Beschlüssen vom 21.10.2026: Gürtel ist die Grenze, ein Gürtel-Gegenstand pro Runde gratis, gemeinsame Wartezeit von 3 Runden für Tränke._

### Schritt 1: Vier Gürtelplätze
- **Ziel:** Vier Gürtelplätze, jeder fasst einen kleinen Stapel (z. B. 5). Befüllen nur außerhalb des Kampfes.
- **So testest du es:** Heiltränke auf den Gürtel legen, im Kampf lässt sich der Gürtel nicht umräumen.
- **Status:** offen

### Schritt 2: Ein Gürtel-Gegenstand pro Runde gratis
- **Ziel:** Im Kampf ist ein Gürtel-Gegenstand pro Runde gratis, jeder weitere kostet den Zug.
- **So testest du es:** Trank nehmen und in derselben Runde noch angreifen, ein zweiter Gegenstand beendet den Zug.
- **Status:** offen

### Schritt 3: Gemeinsame Trank-Wartezeit
- **Ziel:** Nach einem Trank sind alle Tränke 3 Runden gesperrt, sichtbar am Gürtel.
- **So testest du es:** Nach einem Trank sind alle Tränke 3 Runden gesperrt und zählen sichtbar herunter.
- **Status:** offen

## Projekt 4: Händler
_Aus den Beschlüssen vom 21.10.2026: Grundmaterialien kauft man beim Händler für Gold._

### Schritt 1: Händler verkauft Tränke und Grundmaterialien
- **Ziel:** Ein Händler verkauft Heiltränke und Grundmaterialien (Garn, Öl, Leder) gegen Geld.
- **So testest du es:** Etwas kaufen, das Geld sinkt, der Gegenstand liegt in der Tasche. Ohne genug Geld klappt der Kauf nicht.
- **Schon da:** Bingos Laden in Kreuzweg verkauft Heiltränke (mit „Zu wenig Gold“). Offen sind die Grundmaterialien und die neuen Münzen.
- **Status:** offen

## Später (wartet auf andere Teile des Spiels)
- Taschen vom Schneider und Lagerfeuer-Essen (brauchen Berufe)
- Marktstand-Gebühr (braucht den Markt)
- Schriftrollen, Wiederbelebungs-Rolle und besondere Munition
- Testversion bis Stufe 20 mit Kauf (braucht Online-Konten)
- Sternen-Glanz und Siegel-Zähler (braucht den Server)
