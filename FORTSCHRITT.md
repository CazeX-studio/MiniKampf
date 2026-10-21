# Fortschritt

Hier steht, was fertig ist, was als Nächstes kommt und welche Fragen offen sind.
Wird nach jedem Arbeitsschritt aktualisiert.

## Aktueller Stand (2026-10-21)

- **Kampf-Sandbox** (Lernprojekt 2): alle 11 Klassen, Element-Sechseck, Duette, Zähmen, Test-Dungeon Pilzhöhle
  mit Urbaum-Entscheidung, Kampfauswertung. Der Kampf ist in Regeln (`battle_state.gd`) und Anzeige (`combat.gd`) getrennt.
- **Kreuzweg-Demo** (Lernprojekt 3): Die **erste Stunde ist komplett spielbar**, von der Ankunft bis zum Abspann
  (alle 9 Schritte aus `KREUZWEG_PLAN.md`). Steuerung per Tasten, Steuerknopf oder Antippen, Speichern, Musik mit Lautstärke-Regler.
- **Zusammen spielen** (Lernprojekt 4, Plan in `ZUSAMMEN_PLAN.md`): **alle 8 Schritte eingebaut**, Marco testet.
  Bis zu 4 Spieler übers Internet (Online-Server bei Render, Frankfurt): zusammen laufen, Chat, Gruppen, Geschichte
  gemeinsam mit Abstimmung, gemeinsamer Kampf, Nacht des Sternenfalls zusammen, Wiederverbinden nach einem Abbruch.
- **Als Nächstes:** Marcos Rückmeldungen zur ersten Stunde am Stück: Teil 1 fertig (Schritt 18: Grundwerte, langer Lernkampf, schwerere Kämpfe); Schritt 19: Kampf-Geräusche, Schritt 20: größere Stadt mit Ständen und Gesandten-Bildschirm. Alle Punkte aus dem Test sind eingebaut. Außerdem Schritt 1 von
  „Zusammen spielen“ testen. Marcos Entscheidungen vom 20.10. stehen in `ZUSAMMEN_PLAN.md`. Schritt 2
  (Online-Server) ist vorbereitet: Marco legt nach `SERVER_ANLEITUNG.md` ein kostenloses Konto bei Render an.
- **Lernprojekt 5 „Grünwacht“:** Plan steht in `GRUENWACHT_PLAN.md` (11 Schritte: Reise nach Wipfelheim, eigene Klasse
  in der Welt, Fenns Prüfung, Professor Esche und Kobalt, Ysoldes Geschichte, Pilzhöhle als echter Dungeon,
  Kreuzweg-Karten mit Sternentafel, Nebenaufträge, Feinschliff). Marcos Entscheidungen vom 21.10. stehen im Plan
  (alle Klassen dürfen hin, gleicher Spielstand, Weg Stufe 10–15 und Grünwacht 15–20, Sternentafel bei Bingo in Kreuzweg,
  Koch-Stand als Platzhalter, Ruf sichtbar). **Als Nächstes Schritt 1.**
- **Neu (21.10.): Figuren und Nebenaufträge aus Sitzung 21** in Kreuzweg: Wirtin Hanne mit Gasthaus Wegrast, Vogt Edmar,
  Steinmetz Quill, die Kinder Pip und Lotte, die Wache heißt jetzt Brom. Fünf Nebenaufträge mit **blauem „!“ und „?“**
  (Hauptaufträge bleiben gelb). Siehe „Schritt 21“ unten, Test-Liste unter „Was du testen kannst“.
- **Platzhalter:** Alle Texte der Hauptfiguren (Ye, Mira, Ren, Marv, Lene, Bingo, Gesandte …) stehen in `data/dialoge.json`
  und werden von Marco noch geschrieben (Anleitung in `data/LIESMICH.md`).
- Selbst gewählte Zahlen und Passiven: Abschnitt „Vorläufige Werte (Feinschliff am Ende)“ unten.
- Web-Version: **https://cazex-studio.github.io/MiniKampf/** (wird nach jedem Push automatisch neu gebaut).

## Aufgaben Lernprojekt 5 „Grünwacht“ (Fahrplan in `GRUENWACHT_PLAN.md`)

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 0 | Plan schreiben | erledigt |
| – | Entscheidungen: alle Klassen, gleicher Spielstand, Stufen nach Reihenfolge, Sternentafel bei Bingo, Koch-Stand als Platzhalter, Ruf sichtbar | entschieden 21.10. |
| 1 | Die Reise und Wipfelheim (mehrere Karten, Weg von Kreuzweg, Koch-Stand) | offen |
| 2 | Die eigene Klasse in der Welt, Monster der Region | offen |
| 3 | Einstieg Bogenschütze: Fenns Prüfung der drei Ziele | offen |
| 4 | Einstieg Zähmer: Professor Esche und Kobalt | offen |
| 5 | Geschichte 1 und 2: veränderte Tiere (Jäger oder Zähmer, Ruf), Kael | offen |
| 6 | Geschichte 3: Rowans leeres Grab (Erinnerungs-Szene) | offen |
| 7 | Dungeon Pilzhöhle unter dem Urbaum | offen |
| 8 | Ende der Region: Ysolde und Kael, Abstimmung | offen |
| 9 | Kreuzweg-Karten mit Sternentafel, Marv, Oma Hagebutte | offen |
| 10 | Nebenaufträge (Kobalt, Bienenstock) | offen |
| 11 | Feinschliff (Musik, Durchlauf, Stufen) | offen |

## Aufgaben Lernprojekt 4 „Zusammen spielen“ (Fahrplan in `ZUSAMMEN_PLAN.md`)

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 0 | Plan schreiben | erledigt |
| 1 | Zusammen in Kreuzweg laufen (Gastgeber, Beitreten, alle sehen sich) | eingebaut, Marco testet |
| – | Entscheidungen: kostenloser Server, Story gemeinsam mit Abstimmung, Chat mit Schnellsätzen, ein Spielstand | entschieden 20.10., Spielstand eingebaut |
| 2 | Online-Server im Internet (kostenlos bei Render) | vorbereitet, Marco legt das Konto an |
| 3 | Chat mit freiem Text und Sprechblase | eingebaut, Marco testet |
| 4 | Gruppe bilden (einladen, Gruppenfenster, Gruppenführer) | eingebaut, Marco testet |
| 5 | Geschichte gemeinsam erleben (Abstimmung) | eingebaut, Marco testet |
| 6 | Gemeinsamer Kampf | eingebaut, Marco testet |
| 7 | Nacht des Sternenfalls zusammen | eingebaut, Marco testet |
| 8 | Feinschliff (Wiederverbinden, Test mit 4 Spielern, Durchlauf zu zweit) | eingebaut, Marco testet |

## Fertig in Lernprojekt 4

- **Schritt 1 – Zusammen in Kreuzweg laufen:**
  - Im Menü gibt es den neuen Knopf **„Zusammen spielen“**. Dort wählst du **Name** und **Figur** (8 Pixel-Figuren)
    und tippst auf **„Gastgeber werden“** (nur PC-Version) oder **„Beitreten“** (mit der Adresse des Gastgebers).
    Name, Figur und Adresse werden gemerkt.
  - In Kreuzweg sehen sich **bis zu 4 Spieler** gegenseitig laufen, mit Namen über dem Kopf (dein eigener grün).
    Oben links steht „Zusammen: 2 Spieler“, beim Gastgeber dazu die **Adresse für Mitspieler** im eigenen WLAN.
  - **Wie es funktioniert:** Nur der Gastgeber hat die echte Stadt. Mitspieler schicken ihre Befehle (laufen, reden,
    Antwort wählen, kaufen …) und bekommen zurück, wo alle stehen, und ihren eigenen Fortschritt. Das klappt, weil die
    Stadt seit Lernprojekt 3 nur über Befehle gesteuert wird – an den Regeln der Stadt musste nichts geändert werden.
  - Noch spielt **jeder seine eigene Geschichte** (Aufträge, Gespräche, Nacht beim Fest …). Gemeinsam mit Abstimmung
    kommt in Schritt 5.
  - **Spielstand (nach deiner Entscheidung):** Beim Zusammenspielen gilt **derselbe Spielstand wie allein**, ein Charakter
    für alles. Läuft auf demselben PC schon ein anderes Fenster mit diesem Spielstand, bekommt das zweite Fenster
    automatisch einen eigenen (`spielstand_fenster_<Name>`), damit sich die beiden beim Testen nicht überschreiben.
    Die automatischen Tests benutzen eigene Test-Spielstände und fassen deinen nie an.
  - **Kämpfe sind noch allein:** Wer kämpft, verschwindet kurz aus der Stadt und kommt danach zurück.
    Der gemeinsame Kampf ist Schritt 5.
  - **„Menü“** beendet das Zusammenspielen (beim Gastgeber für alle). Reißt die Verbindung ab, landest du wieder auf
    „Zusammen spielen“ mit einem Hinweis; dein Fortschritt ist gespeichert.
  - **Server ohne Grafik** für später: `Godot --headless --path . -- --server` (gleiches Spiel, keine eigene Figur).
  - **Grenzen bisher:** Am Handy und im Browser geht nur „Beitreten“, und zwar erst richtig mit einem Server im Internet
    (Schritt 2), weil Browser aus Sicherheitsgründen nur sichere Verbindungen erlauben. Ausnahme: Browser und Gastgeber
    auf demselben PC (`localhost`). Die eigene Figur reagiert minimal verzögert (im WLAN kaum spürbar), das glätte ich in Schritt 7.
  - **Tests:** `tests/netz_test.gd` startet ein zweites Programm als Mitspieler: Beitreten, Name und Figur, Laufen,
    Einleitung vom Gastgeber, Verlassen, dazu der Spielstand für ein zweites Fenster – alles richtig (14 Prüfungen). `tests/netz_stadt_test.gd` öffnet die echte
    Stadt gegen einen Server ohne Grafik, inklusive „Neu beginnen“ und „Menü“: alles richtig (13 Prüfungen).
    Alle bisherigen Tests (Welt, Klassenwahl, Übergang, Lektionen, Elemente, Durchlauf der ersten Stunde) laufen unverändert.

- **Schritt 2 – Online-Server (vorbereitet):**
  - Auf „Zusammen spielen“ gibt es den neuen Knopf **„Online-Server (übers Internet)“**. Er verbindet mit dem Server
    bei Render (`wss://asterfall-server.onrender.com`, sichere Verbindung, geht im Browser und am Handy).
  - Der Server ist dasselbe Spiel ohne Grafik. Bauplan für Render: `render.yaml` und `server/Dockerfile`. Den Port
    gibt der Anbieter vor.
  - **Der kostenlose Server schläft**, wenn 15 Minuten niemand spielt, und braucht dann bis zu einer Minute zum Aufwachen.
    Das Spiel wartet deshalb bis zu zwei Minuten und sagt das auch an. Verbundene Mitspieler melden sich alle 30 Sekunden
    kurz, damit er nicht mitten im Spiel einschläft.
  - **Geprüft:** Das Server-Paket hier nachgebaut (gleiches Spiel, Port 10000 wie bei Render) und einen Mitspieler
    verbunden: Beitreten, Laufen, Einleitung, alles richtig. Den Download-Teil des Bauplans (Godot holen) konnte ich hier
    nicht ausprobieren, weil diese Umgebung keine Pakete aus dem Internet laden darf; das zeigt sich beim ersten Bau bei
    Render. Alle bisherigen Tests laufen weiter.
  - **Läuft** (Marco, 20.10.): Verbinden klappt, aber man hing öfter. Darum nachgebessert:
    - **Standort Frankfurt** statt Oregon (USA) im Bauplan. Dafür muss der Dienst einmal neu angelegt werden
      (Anleitung unten in `SERVER_ANLEITUNG.md`).
    - **Eigene Figur läuft sofort** los, ohne auf den Server zu warten. Der Server rechnet dasselbe und zieht die Figur
      nur zurück, wenn sie stark abweicht.
    - **Mitspieler laufen gleichmäßig:** Sie werden 0,2 Sekunden verzögert gezeigt, dafür ohne Ruckeln. Bleiben Nachrichten
      kurz aus, laufen sie noch bis zu 0,6 Sekunden in ihrer Richtung weiter.
    - **Server rechnet sparsamer** (höchstens 30-mal pro Sekunde), weil der kostenlose Tarif wenig Rechenleistung hat.
    - **Gemessen** mit künstlich schlechter Verbindung (alle 2 Sekunden 0,35 Sekunden Aussetzer): Sprünge der Mitspieler
      von 69 auf 3, Stillstand-Bilder ungefähr halbiert. Alle Tests laufen.

- **Schritt 3 – Chat:**
  - Beim Zusammenspielen gibt es oben links den Knopf **„Chat (Enter)“**. Am PC öffnet **Enter** die Eingabe, Enter
    schickt ab, **Esc** bricht ab. Am Handy den Knopf antippen, dann erscheint die Tastatur.
  - Die Nachricht geht an **alle in Kreuzweg**: Sie steht links unter dem Knopf (die letzten 6, ältere blenden nach
    20 Sekunden aus) und als **Sprechblase** über dem Kopf des Schreibers (6 Sekunden).
  - Hinweise vom Spiel im Chat: „Mira ist in Kreuzweg.“ und „… hat das Spiel verlassen.“ (nicht nach jedem Kampf neu).
  - Während man tippt, läuft die Figur nicht (WASD sind dann Buchstaben).
  - Schutz: höchstens 120 Zeichen, keine Zeilenumbrüche, höchstens eine Nachricht alle 0,6 Sekunden pro Spieler.
    Wer gerade kämpft, kann nicht schreiben, sieht nach dem Kampf aber, was geschrieben wurde.
  - Schnellsätze und Emotes kommen später (Vorschläge in design.md im Ideen-Parkplatz).
  - **Tests:** Gastgeber und Mitspieler schreiben sich, zu schnelle Nachricht wird verworfen, Hinweise beim Kommen und
    Gehen, Chat in der echten Stadt mit Sprechblase – alles richtig. Alle bisherigen Tests laufen weiter.

- **Schritt 4 – Gruppe bilden:**
  - **Mitspieler antippen** (oder anklicken) öffnet ein kleines Menü: **„In Gruppe einladen“**. Als Gruppenführer
    stehen bei Mitgliedern **„Führung übergeben“** und **„Aus Gruppe nehmen“**.
  - Der Eingeladene bekommt ein Fenster „Marco lädt dich in die Gruppe ein.“ mit **Annehmen** und **Ablehnen**.
    Die Einladung gilt 60 Sekunden.
  - **Gruppenfenster** rechts oben: alle Mitglieder mit Stufe und Leben, ★ = Gruppenführer, „kämpft gerade“ bei
    jemandem, der gerade einen Kampf spielt. Knopf **„Gruppe verlassen“**. Gruppenmitglieder haben in der Stadt
    einen **hellblauen Namen**.
  - **Regeln:** höchstens 4 Spieler. Nur der Gruppenführer lädt ein. Wer die Gruppe gründet (die erste Einladung wird
    angenommen), führt sie. Geht der Gruppenführer, führt der Nächste. Wer allein übrig bleibt, ist nicht mehr in einer
    Gruppe. Wer kämpft, bleibt in der Gruppe; wer das Spiel verlässt, ist raus.
  - Die Leben-Leiste ist in der Stadt immer voll (Kämpfe heilen ganz). Im gemeinsamen Kampf (Schritt 6) zeigt sie
    das echte Leben.
  - Die Regeln stehen in einem eigenen Baustein ohne Grafik (`scripts/netz/gruppen.gd`), darauf bauen später die
    gemeinsame Geschichte (Abstimmung, Gruppenführer bei Gleichstand) und der gemeinsame Kampf auf.
  - **Tests:** `tests/gruppen_test.gd` prüft alle Regeln (20 Prüfungen), der Netz-Test eine echte Einladung zwischen
    zwei Programmen – alles richtig. Alle bisherigen Tests laufen weiter.

- **Schritt 5 – Geschichte gemeinsam erleben:**
  - Spricht jemand aus einer Gruppe eine Figur an, werden **Gruppenmitglieder in der Nähe** (8 Felder, nach deiner
    Entscheidung) in das Gespräch geholt: „Gemeinsame Szene: Marco spricht mit Schreiberin Lene.“ Alle sehen denselben Text.
  - **Wer spricht, blättert weiter.** Bei Antworten **stimmen alle ab**, die in der Geschichte an derselben Stelle sind.
    Man sieht, wie viele Stimmen jede Antwort hat (✔ = eigene Stimme), wie viele noch fehlen und die Restzeit.
    Haben alle gewählt, gilt die Mehrheit; **bei Gleichstand entscheidet der Gruppenführer** (hat er nicht mitgestimmt:
    wer spricht). Nach **30 Sekunden** zählen die abgegebenen Stimmen.
  - **Wer an einer anderen Stelle der Geschichte ist** (z. B. die Szene schon erlebt hat), **schaut zu**: Er sieht alles,
    kann aber nicht abstimmen und bekommt keine Belohnung. Seine eigene frühere Wahl bleibt.
  - Belohnungen, Aufträge und Gemerktes gelten für alle, die abgestimmt haben.
  - **„Szene verlassen“** holt einen aus der Szene. Geht der Sprecher (Knopf, Kampf, Spiel verlassen), spricht der Nächste
    weiter. Ist niemand mehr da, der abstimmen darf, ist die Szene vorbei.
  - Allein (ohne Gruppe oder ohne Mitglieder in der Nähe) läuft jedes Gespräch wie bisher.
  - Noch vorläufig: Ein Kampf aus einem Gespräch (z. B. Lektion bei Ye) startet bei jedem einzeln. Gemeinsam kämpfen
    kommt in Schritt 6.
  - **Tests:** `tests/szene_test.gd` (Mitholen, Abstimmen, Zuschauen, Gleichstand, Weiterblättern, Verlassen, Zeit,
    Belohnungen – 23 Prüfungen) und im Netz-Test eine echte gemeinsame Szene mit Lene zwischen zwei Programmen –
    alles richtig. Alle bisherigen Tests laufen weiter.

- **Schritt 6 – Gemeinsamer Kampf:**
  - Beginnt in einer **gemeinsamen Szene ein Kampf** (z. B. „Wir schaffen das!“ bei Ye für den Gruppenkampf), kämpfen
    **alle zusammen, die mit abgestimmt haben** (nach deiner Entscheidung). Wer nur zugeschaut hat, bleibt in der Stadt.
  - **Jeder steuert seine eigene Figur.** Die Spieler stehen vorne, **freie Plätze füllen die Novizen-Mitstreiter**
    (z. B. zwei Spieler + Ida und Bo beim Gruppenkampf). Im Kampf sieht jeder aus wie seine Figur in der Stadt.
  - **25 Sekunden pro Zug** (die Uhr steht oben beim eigenen Zug), danach kommt automatisch ein **Standardangriff**.
    Bei den anderen steht „Mira ist am Zug …“.
  - **Parieren** misst jedes Gerät selbst (die Verbindung verdirbt das Timing nicht), die anderen sehen das Ergebnis.
  - **Aufgeben** bringt einen zurück in die Stadt (als Niederlage); die anderen kämpfen weiter, für die Figur entscheidet
    ab dann der Server (Standardangriff). Genauso, wenn jemand die Verbindung verliert.
  - Gemeinsam gibt es kein „Nochmal versuchen“ (dafür müssten alle zustimmen). Jeder bekommt danach sein Ergebnis
    (Erfahrung, Aufträge, getrunkene Heiltränke) wie bisher.
  - **Wie es funktioniert:** Die Kampfregeln ergeben bei gleichem Startwert und gleichen Entscheidungen immer genau denselben
    Kampf (das hatten wir in Runde 2 so gebaut). Deshalb rechnet **jedes Gerät den Kampf selbst**, und übers Netz gehen nur
    die **Entscheidungen** (Fähigkeit und Ziel, wie gut pariert wurde). Der Server rechnet unsichtbar mit, prüft jede
    Entscheidung und springt ein, wenn jemand weg ist (`scripts/netz/gemeinsamer_kampf.gd`).
  - **Platzhalter:** Die Texte des Gruppenkampfs sprechen noch von „Ida, Bo und Tom kämpfen mit dir“, auch wenn Mitspieler dabei sind.
  - Noch nicht gemeinsam: der Sternenfresser mit Ren (das ist Schritt 7).
  - **Tests:** `tests/gruppenkampf_test.gd`: Server und zwei Mitspieler rechnen drei Kämpfe (normal, einer gibt auf,
    ungültige Entscheidungen) – jedes Mal **genau gleich** (Sieger, Züge, Leben aller Figuren, Kampf-Log).
    `tests/netz_gruppenkampf_test.gd`: zwei echte Programme mit echter Kampf-Anzeige kämpfen den Gruppenkampf zusammen –
    gleiches Ergebnis auf beiden, danach zurück in der Stadt. Szenen-Test: Kampf aus einer Szene wird zum Gruppenkampf.
    Alle bisherigen Tests laufen weiter.

- **Schritt 7 – Nacht des Sternenfalls zusammen:**
  - **Marv spricht die Gruppe gemeinsam an:** Kommt jemand auf dem Fest in Marvs Nähe, werden Gruppenmitglieder in der Nähe
    mit in die Szene geholt (wie bei Schritt 5). Danach spricht Marv niemanden aus der Gruppe noch einmal an.
  - **Den Sternenfall sehen alle in der Stadt** (greller Lichtblitz, Wackeln), auch wer gar nicht auf dem Fest ist –
    so steht es in design.md. Er kommt nur einmal, auch wenn mehrere ihn auslösen.
  - **Sternenfresser für die Gruppe:** Alle, die bei Ye „Los!“ mit abgestimmt haben, kämpfen zusammen (Schritt 6).
    Er **passt sich der Gruppengröße an**: je weiterem Spieler 25 % mehr Leben (allein 240, zu zweit 300, zu viert 420).
    In `data/kaempfe.json` als `"gruppe_staerke": 0.25` einstellbar (vorläufig, Feinschliff am Ende).
  - **Ren kommt erst, wenn alle zurück sind:** Wer zuerst aus dem Kampf kommt (oder aufgegeben hat), wartet. Sind alle
    wieder in der Stadt, spricht Ren die Gruppe **gemeinsam** an. Wer aufgegeben hat, hat „verloren“ und schaut bei Ren zu,
    wenn die anderen gewonnen haben. Wer das Spiel verlässt, auf den wird nicht gewartet.
  - Allein läuft die Nacht wie bisher.
  - **Platzhalter:** Ye ruft „Ida, Bo, Tom – und du!“, auch wenn Mitspieler dabei sind.
  - **Tests:** Szenen-Test mit der ganzen Nacht (Marv holt beide, Sternenfall für alle einmal, gemeinsamer Boss, Ren wartet
    und kommt dann für beide, beide haben den Erfolg) und dem stärkeren Sternenfresser. Der Sternenfresser lief auch als
    echter Gruppenkampf zwischen zwei Programmen (gleiches Ergebnis auf beiden). Alle bisherigen Tests laufen weiter.

- **Schritt 8 – Feinschliff:**
  - **Wiederverbinden:** Reißt die Verbindung in der Stadt ab (Funkloch, Server startet neu), steht in der Mitte
    „Verbindung weg – verbinde neu (Versuch 1 von 3) …“. Das Spiel versucht es bis zu dreimal von selbst und holt dich
    danach mit deinem gespeicherten Fortschritt zurück in die Stadt. Erst wenn alle drei Versuche scheitern, geht es
    zurück zu „Zusammen spielen“ mit einem Hinweis.
  - **Gruppe bleibt:** Kommst du innerhalb von 3 Minuten zurück, bist du wieder in deiner alten Gruppe
    („Mira ist wieder da.“). War die Gruppe zu zweit (sie löst sich dann auf), wird sie neu gebildet.
  - Im Gruppenkampf geht das Wiederverbinden nicht (der Kampf läuft weiter, der Server übernimmt deine Figur); dann zurück
    zu „Zusammen spielen“, der Fortschritt ist gespeichert.
  - **Test mit 4 Spielern:** Gastgeber + drei Mitspieler-Programme treten bei, bilden eine Gruppe, grüßen im Chat und
    kämpfen den Gruppenkampf zu viert (keine Mitstreiter mehr nötig) – alle vier haben genau dasselbe Ergebnis.
  - **Durchlauf zu zweit:** Zwei Computer-Spieler in einer Gruppe spielen die ganze erste Stunde bis zum Abspann – mit
    gemeinsamen Szenen (Ye, Marv, Bingo, Lene, Marv auf dem Fest, Ren …), uneinigen Abstimmungen, Gruppenkämpfen
    (Grundausbildung, Gruppenkampf, Sternenfresser) und Ren, die auf beide wartet. Mit sieben Startwerten ohne Hänger.
    Beobachtung: Ist einer in der Geschichte schon weiter, schaut er bei Marv nur zu, und jeder kämpft den Sternenfresser
    für sich – so ist es gewollt.
  - **Tests:** `tests/netz_wiederverbinden_test.gd`, `tests/netz_gruppenkampf_test.gd` (jetzt zu viert),
    `tests/durchlauf_zu_zweit_test.gd` – alles richtig. Alle bisherigen Tests laufen weiter.

## Lernprojekt 4 auf einen Blick

| Was | Wie |
|-----|-----|
| Beitreten | Menü → „Zusammen spielen“ → „Online-Server“ (Browser, Handy, PC) oder Gastgeber/Beitreten im eigenen WLAN |
| Spielstand | derselbe wie allein (zweites Fenster auf demselben PC: eigener) |
| Chat | Enter bzw. Knopf „Chat“, Sprechblase über dem Kopf |
| Gruppe | Mitspieler antippen → einladen, bis 4, ★ = Gruppenführer |
| Geschichte | Gruppenmitglieder in der Nähe erleben Gespräche mit und stimmen ab (Gleichstand: Gruppenführer) |
| Kampf | Kampf aus einer gemeinsamen Szene = Gruppenkampf, 25 s pro Zug, freie Plätze: Novizen |
| Sternenfall | für alle sichtbar, Boss passt sich der Gruppe an, Ren für alle gemeinsam |
| Abbruch | automatisch neu verbinden, Gruppe bleibt |

## Aufgaben dieser Runde (Runde 2)

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 1 | Sternensängerin heißt jetzt „Vega“ | erledigt |
| 2 | Schnellfeuer, Polarstern, Zähmen, Entscheidung nach der Pilzhöhle | erledigt |
| 3 | Kunoichi-Ult lädt nur durch Siegel-Kombinationen | erledigt |
| 4 | Elemente absichern (unbekanntes Element = normaler Schaden) | erledigt |
| 5 | Selbst gewählte Werte als „vorläufig“ markieren | erledigt |
| 6 | Kampf in Regeln und Anzeige trennen | erledigt |
| 7 | Steuerung in der Welt: Tasten (PC), Steuerknopf und Aktions-Knopf (Handy) | erledigt |
| 8 | Kreuzweg-Demo Schritt 1: Bausteine (siehe KREUZWEG_PLAN.md) | erledigt |
| 9 | Kreuzweg-Demo Schritt 2: Ankunft (Gilde, Ye, erster Auftrag) | erledigt |
| 10 | Kreuzweg-Demo Schritt 3: Grundausbildung (Lektionen, erster Gruppenkampf) | erledigt |
| 11 | Kreuzweg-Demo Schritt 4: Marv und Bingos Laden | erledigt |
| 12 | Kreuzweg-Demo Schritt 5: Gesandte der fünf Regionen mit Probestunden | erledigt |
| 13 | Kreuzweg-Demo Schritt 6: Der zugewachsene Weg (Wache Holm, Mira) | erledigt |
| 14 | Kreuzweg-Demo Schritt 7: Nacht des Sternenfalls (Fest, Sternenfresser, Ren) | erledigt |
| 15 | Parieren/Ausweichen mit normaler Zone und Perfekt-Zone | erledigt |
| 16 | Kreuzweg-Demo Schritt 8: Klassenwahl und Abreise | erledigt |
| 17 | Kreuzweg-Demo Schritt 9: Feinschliff (Musik, Hintergründe, Namen, Durchlauf-Test) | eingebaut, Marco testet am Stück |
| 21 | Kreuzweg nach Sitzung 21: neue Figuren und Nebenaufträge (blaues Zeichen) | eingebaut, Marco testet |

## Aufgaben der Runde 1

| Nr. | Aufgabe | Stand |
|-----|---------|-------|
| 1 | Kampf-Sandbox prüfen und fertigstellen | erledigt |
| 2 | Pilzhöhle als spielbarer Test-Dungeon | erledigt |
| 3 | Gerüst für die Kreuzweg-Demo (Lernprojekt 3) | erledigt |
| 4 | Web-Export aktualisieren | erledigt |

## Fertig in Runde 2

- **Schritt 1 – Name:** Die Sternensängerin heißt jetzt überall **Vega** (Lyra ist Kaels Schwester).

- **Schritt 2 – Fehlende Fähigkeiten und Entscheidung:**
  - **Schnellfeuer** (Bogenschütze): 3 schnelle Pfeile à 7 auf zufällige Gegner, 12 Mana. Kritische Treffer laden wie immer die Ult.
  - **Polarstern** (Sternensängerin): Ein Verbündeter bekommt Abwehr+ und ist früher dran, +1 Schutz-Sternbild, 10 Mana.
    Mit vollem Schutz-Sternbild (Sternenglanz) wirkt er auf die ganze Gruppe.
  - **Zähmen** (Monster-Zähmer): Ein Monster unter 50 % Leben kann gefangen werden. Je schwächer, desto sicherer
    (bei 50 % halbe Chance). Es kommt mit halbem Leben auf die Bank und kann per „Wechsel“ kämpfen, mit seinem
    eigenen Angriff und „Beschützen“. Zähmbar sind alle normalen Monster, auch die der Pilzhöhle (nicht Bosse,
    Sporenknospen und Knoten). Höchstens 5 Monster.
  - **Entscheidung nach der Pilzhöhle:** Nach dem Sieg über den Vorboten zwei Knöpfe: „Baum fällen, großen Splitter
    mitnehmen“ oder „Splitter herausschneiden, Baum retten“. Das Ergebnis steht im Log und in der Auswertung.
  - Neu: **automatische Testkämpfe** (Ordner `tests`): 75 Kämpfe, alle Klassen, alle Gegner, der Computer spielt.
    Alle laufen ohne Fehler durch, Zähmen, Polarstern und die Entscheidung kommen darin vor.

- **Schritt 3 – Kunoichi-Ult:** lädt jetzt nur noch durch ausgelöste Siegel-Kombinationen (+35 je Kombination,
  also nach drei Kombinationen voll). Ein einzelnes gelöstes Siegel lädt nichts mehr.

- **Schritt 4 – Elemente absichern:** Ein unbekanntes Element (z. B. Tippfehler oder ein neues Element ohne Eintrag)
  macht jetzt normalen Schaden, statt das Spiel abstürzen zu lassen. Dazu ein kleiner automatischer Test (10 von 10 richtig).
  Im Spiel ändert sich dadurch nichts Sichtbares.

- **Schritt 5 – Vorläufige Werte:** Die selbst gewählten Passiven und alle Pilzhöhlen-Zahlen stehen jetzt gesammelt
  im Abschnitt „Vorläufige Werte (Feinschliff am Ende)“.

- **Schritt 6 – Kampf in Regeln und Anzeige getrennt:**
  - **Regeln** (`battle_state.gd`): ein Kampf-Zustand ganz ohne Grafik. Er nimmt Befehle an („Vega benutzt
    Polarstern auf Wren“, „Reaktion getroffen: ja“) und meldet Ereignisse („Treffer 12 auf Sporenwolf“,
    „Geschoss von Wren zum Dornling“, Log-Zeilen). Er wartet nie auf Animationen und hat seinen eigenen Zufall.
  - **Anzeige** (`combat.gd`): spielt diese Ereignisse der Reihe nach ab (Figuren, Treffer, Leisten, Log, Ring)
    und gibt deine Eingaben als Befehle zurück. Die Lebensleiste sinkt erst, wenn der Treffer zu sehen ist.
  - **Warum:** Für gemeinsame Kämpfe kann der Kampf-Zustand später auf einem Server laufen; jeder Spieler hat nur
    die Anzeige. Ein Computer-Spieler kann denselben Kampf ohne Grafik in Sekunden durchspielen.
  - **Geprüft:** 75 automatische Kämpfe (5 Teams, alle 11 Klassen, alle 5 Gegner, je 3 feste Zufallswerte)
    vor und nach dem Umbau. Ergebnis: **Zug für Zug identisch** (Leben, Mana, Ult, Zugleiste, jede Log-Zeile und
    jede Schadenszahl, rund 90.000 Zeilen). Für den Vergleich habe ich im alten Stand nur die Zufallsquelle
    ausgetauscht, sonst nichts. Dazu ein Probelauf mit echter Anzeige, in dem der Computer spielt
    (`tests/anzeige_auto.tscn`), und alle Szenen starten ohne Fehlermeldung.

- **Schritt 7 – Steuerung in der Welt** (Kreuzweg-Demo, auch in design.md unter „Steuerung“ eingetragen):
  - **PC:** WASD oder Pfeiltasten = laufen, E oder Leertaste = reden bzw. Gespräch weiterblättern. Klicken zum Hinlaufen bleibt.
  - **Handy:** Steuerknopf unten links – er erscheint dort, wo der Daumen aufsetzt (kurz antippen ohne Ziehen = hinlaufen).
    Aktions-Knopf „Reden“ unten rechts. Antippen zum Hinlaufen bleibt. Beides erscheint nur auf Geräten mit Touchscreen.
  - Häuser, Bäume und NPCs halten dich auf, du rutschst an ihnen entlang.
  - Wie bisher alles über Befehle an die Welt („steuern“, „benutzen“), damit später Mitspieler dazukommen können.
  - Der Kampf bleibt rundenbasiert mit Antippen. Automatischer Test `tests/welt_test.gd`: alles richtig.

- **Schritt 8 – Kreuzweg-Demo, Bausteine** (Schritt 1 aus `KREUZWEG_PLAN.md`):
  - **Gespräche mit Antworten:** Ye stellt Fragen, du wählst eine Antwort (antippen oder Taste 1–4).
    Je nach Antwort und Fortschritt sagt er etwas anderes.
  - **Auftragsbuch** (Knopf „Aufträge“ oder J): zeigt laufende, erfüllte und abgeschlossene Aufträge mit Fortschritt.
  - **Gold und Tasche** (Knopf „Tasche“ oder I), **Erfahrung und Stufen 1–10** oben links.
  - **Speichern:** automatisch bei jedem Fortschritt und beim Verlassen. „Neu beginnen“ löscht den Spielstand.
  - **Probe-Auftrag „Kräuter für Ye“:** nur zum Ausprobieren der Bausteine (der echte erste Auftrag kommt in Schritt 2).
    Drei leuchtende Silberkräuter einsammeln (antippen oder E daneben), bei Ye abgeben:
    30 Gold, 120 Erfahrung (= Stufe 2) und ein Heiltrank.
  - **Alles in Datendateien** (`data/`): Dialoge, Aufträge, Gegenstände, Stufen, Meldungen und die NPCs der Stadt.
    Anleitung zum Ändern: `data/LIESMICH.md`.
  - **Mehrspieler-tauglich:** Jeder Spieler hat seinen eigenen Fortschritt, alles läuft über Befehle an die Welt
    („rede mit Ye“, „wähle Antwort 2“, „sammle Punkt 1“). Jeder sieht nur die Kräuter, die er selbst noch nicht hat.
  - **Platzhalter:** Ye's Texte sind Platzhalter – **Marco schreibt die Dialoge der Hauptfiguren noch.**
  - Automatischer Test `tests/welt_test.gd` (Gespräch, Auftrag, Belohnung, Stufen, Speichern): alles richtig.

- **Nachbesserung nach deinem Test:**
  - Das dritte Silberkraut lag hinter der Schmiede versteckt. Es liegt jetzt frei sichtbar auf dem Marktplatz.
  - **Splitter sind Dungeon-Belohnungen** (auch in design.md eingetragen): Nach der Pilzhöhle behält die Gruppe den
    Splitter in beiden Fällen. In der Auswertung steht „Belohnung: Sternensplitter“. Der Sternensplitter steht schon
    als Gegenstand in `data/gegenstaende.json`, damit er später in die Tasche kommen kann.
  - Die Knöpfe der Urbaum-Entscheidung verraten nicht mehr, was danach passiert (z. B. besserer Ruf bei den Zähmern).
    Die Folgen stehen erst nach der Wahl im Log. Das gilt ab jetzt für alle Entscheidungen.
  - Die Urbaum-Frage kommt **nur beim ersten Abschluss**. Die Wahl wird im Spielstand gespeichert; bei jedem weiteren
    Sieg in der Pilzhöhle gilt sie automatisch („Wie beim ersten Mal …“). „Neu beginnen“ in der Kreuzweg-Demo löscht
    sie mit. (Im fertigen Spiel ist der erste Abschluss der über den Auftrag.) Auch in design.md eingetragen.

- **Schritt 9 – Kreuzweg-Demo, Ankunft** (Schritt 2 aus `KREUZWEG_PLAN.md`, Stufe 1–2):
  - **Einleitung am Stadttor:** Beim ersten Betreten erzählt ein Erzähler kurz, wo du bist, und schickt dich zur Gilde.
  - **Abenteurergilde:** Die Gildenschreiberin **Lene** vor dem Eingang trägt dich als Novize ein und schickt dich zu Ye.
  - **Ausbilder Ye:** begrüßt dich, beantwortet Fragen (Kämpfen, Laterne) und gibt den **ersten Auftrag
    „Die Stadt kennenlernen“**: drei Silberkräuter sammeln und der **Schmiedin Marta** Bescheid sagen. Abgeben bei Ye
    = 25 Gold, ein Heiltrank und genau **Stufe 2**. Danach kündigt Ye die Grundausbildung am Stadttor an (Schritt 3).
  - **Hilfen zum Zurechtfinden:** „!“ über einem NPC = neuer Auftrag, „?“ = dort etwas erledigen oder abgeben.
    Oben links steht immer das nächste **Ziel** (z. B. „Silberkraut 1 / 3“ oder „Zurück zu Ausbilder Ye“).
  - Wer Ye vor der Anmeldung anspricht, wird freundlich zur Gilde geschickt. Marv kommt wie geplant erst nach dem Tutorial.
  - Der Probe-Auftrag aus Schritt 1 ist durch den echten ersten Auftrag ersetzt. **Alte Spielstände beginnen neu**
    (sie passten nicht mehr zum neuen Ablauf).
  - **Platzhalter:** Alle Texte von Erzähler, Gildenschreiberin, Ye und Schmiedin sind Platzhalter –
    **Marco schreibt die Dialoge der Hauptfiguren noch** (`data/dialoge.json`).
  - Automatischer Test `tests/welt_test.gd` spielt den ganzen Ablauf durch (41 Prüfungen): alles richtig.
  - Namen nach deiner Antwort: Die Gildenschreiberin heißt **Lene**, die Schmiedin **Marta**.

- **Schritt 10 – Kreuzweg-Demo, Grundausbildung** (Schritt 3 aus `KREUZWEG_PLAN.md`, Stufe 2–5):
  - Nach Ye's erstem Auftrag steht er **am Stadttor** (in der Gilde ist er dann nicht mehr).
  - **Vier Lektionen**, jede ein eigener Kampf auf dem Kampfbildschirm, danach geht es zurück in die Stadt:
    1. **Tempo-Leiste** gegen einen Feldschleim (nur „Schlag“),
    2. **Fähigkeiten** (neu: Kraftschlag und Erste Hilfe, Mana und Abklingzeit),
    3. **Parieren** gegen Ye selbst mit Übungsschwert – bestanden nach **zwei perfekten Paraden** („Schild hoch, Schild runter“),
    4. **Zwei Reihen** gegen einen Rüpelkobold (neu: „Nach hinten“).
  - **Erklär-Fenster** („Ye erklärt“) halten den Kampf an, bis du „Verstanden“ antippst. Die Erklärung zum Parieren
    kommt, bevor der erste Schlag losgeht, damit der Ring zum Schlag passt.
  - **Erster Gruppenkampf:** du mit den Novizen **Ida, Bo und Tom** (der Computer steuert sie) gegen vier Kobolde.
  - Du kämpfst als **Novize** (noch keine Klasse, keine Ult): mit jeder Stufe etwas mehr Leben und Mana.
  - Erfahrung gibt es beim **ersten** Sieg jeder Lektion. Verlieren ist nicht schlimm: „Nochmal versuchen“ oder später
    wieder mit Ye reden. „Aufgeben“ oben rechts bringt dich zurück in die Stadt.
  - Am Ende: **Stufe 5**, 75 Gold, 3 Heiltränke. Ye kündigt an, dass in der Stadt bald einiges los ist (Schritt 4: Marv und Bingo).
  - Neue Gegner: Feldschleim, Wiesenkobold, Rüpelkobold (zähmbar wie alle normalen Monster).
  - **Platzhalter:** alle Texte (Ye, Erklärungen, Ida, Bo, Tom); als Hintergrund dient noch das Gewölbe der Sandbox,
    nicht die Wiese vor dem Stadttor.
  - **Tests:** Der Computer hat jede Lektion und den Gruppenkampf je 30-mal gespielt: alles läuft, alles ist für
    Anfänger schaffbar (Zahlen vorläufig). Welt-Test mit der ganzen Grundausbildung und ein Test für den echten Wechsel
    Stadt → Kampf → Stadt: alles richtig. Die 75 Sandbox-Kämpfe laufen unverändert.
  - **Nachbesserung nach deinem Test:**
    - In **Lektion 1 und 2** kann der Novize noch **nicht parieren** (kein Ring). Parieren kommt erst in Lektion 3.
      Ye erklärt dort zusätzlich: Als Novize lernt jeder das Parieren, später hängt es von der Klasse ab
      (manche parieren, manche weichen aus, manche haben keine Reaktion). Auf dem Klassenwahl-Bildschirm (Schritt 8)
      steht das dann bei jeder Klasse.
    - **Zahlentasten am PC:** Vor jedem Knopf im Kampf steht seine Nummer, 1–9 wählen ihn aus (Fähigkeiten, Auswahl,
      „Zurück“). Gilt auch in der Kampf-Sandbox. Am Handy bleiben die Knöpfe ohne Nummer.
    - **Mitstreiter parieren seltener:** Ida, Bo und Tom schaffen eine perfekte Reaktion nur noch in 10 % der Fälle.
    - **Lektion 4:** Die erste Aktion ist „Nach hinten“. Alle anderen Knöpfe sind gesperrt („Erst ‚Nach hinten‘“),
      bis du die Reihe gewechselt hast. Danach ist alles frei. (In `data/kaempfe.json` als `"zuerst": "row"` festgelegt.)

- **Schritt 11 – Kreuzweg-Demo, Marv und Bingos Laden** (Schritt 4 aus `KREUZWEG_PLAN.md`):
  - **Marv** ist erst nach der Grundausbildung in der Stadt (an der Straße zwischen Tor und Marktplatz) und
    **spricht dich von sich aus an**, sobald du vorbeikommst – einmal. Er erzählt begeistert von Kreuzweg-Karten
    und schickt dich zu Bingo. Auftrag „Marvs großer Traum“: bei Bingo nach der Sternentafel fragen, zurück zu Marv.
    Seine Antwort auf 5000 Gold: „Dann spar halt! Ich warte. Ich hab Zeit.“ (der Running Gag beginnt; „Ich hab Zeit“ sagt er nur an dieser einen Stelle).
  - **Handelsherr Bingo** steht vor seinem Laden. **Laden-Fenster:** Heiltrank kaufen (15 Gold), Dinge aus der Tasche
    verkaufen (zur Hälfte des Preises), die **Sternentafel für 5000 Gold** (viel zu teuer: „Zu wenig Gold“).
    Bingo erklärt auf Nachfrage, was die Sternentafel ist.
  - **Heiltränke im Kampf:** Damit sich der Laden lohnt, kann der Novize ab Lektion 4 und im Gruppenkampf Heiltränke
    aus seiner Tasche trinken oder reichen (heilt 35). Getrunkene Tränke fehlen danach in der Tasche, auch bei
    „Nochmal versuchen“.
  - Neue Datendatei `data/laeden.json`. **Platzhalter:** alle Texte von Marv und Bingo, ihr Aussehen.
  - Das Mini-Spiel Kreuzweg-Karten selbst kommt später (laut Plan spielt Marv genau einmal mit).
  - Tests: Welt-Test mit Marv und Bingo (Ansprechen, Kaufen, Verkaufen, zu teuer), Übergangs-Test mit Heiltränken: alles richtig.

- **Schritt 12 – Kreuzweg-Demo, Gesandte der fünf Regionen** (Schritt 5 aus `KREUZWEG_PLAN.md`, Stufe 5–7):
  - **Ye am Tor** steht jetzt links neben der Straße (10,19) und nicht mehr hinter den Bäumen.
  - Nach der Grundausbildung stehen **fünf Gesandte** rund um die Statue der Fünf: Arkanum, Messinghafen, Glutoase,
    Grünwacht und Nebelinseln. Jeder erzählt kurz von seiner Region und bietet **Probestunden** für ihre Klassen an
    (zusammen alle 11 Klassen aus der Sandbox).
  - **Lene** (Schreiberin) vergibt den Auftrag „Die Gesandten der fünf Regionen“: **eine Probestunde ist Pflicht**,
    die anderen sind freiwillig (jede gibt beim ersten Sieg 40 Erfahrung). Abgeben bei Lene: 300 Erfahrung, 50 Gold
    – damit **Stufe 6**, mit allen Probestunden Stufe 7.
  - **Probestunde:** Du spielst die Klasse kurz auf der Übungswiese, **mit Ida und Bo** als Gruppe (sonst sind Tank und
    Support allein kaum spielbar). Die **Ult ist schon zu 60 % voll** – du lädst sie mit der typischen Aktion der Klasse
    auf. Ye erklärt vorher die Klasse (Rolle, Mechanik, Reaktion, Ult) aus den Klassendaten.
  - Gespräche mit vielen Antworten wachsen nach oben, damit sie ins Bild passen. In der Stadt wählen 1–9 Antworten.
  - **Namen der Gesandten** (nach deiner Antwort): Magistra Ilwen (Arkanum), Tüftler Pim (Messinghafen), Feuertänzerin
    Nalia (Glutoase), Fährtenleser Aske (Grünwacht), Schreindienerin Mei (Nebelinseln).
  - **Platzhalter:** alle Texte der Gesandten. Hintergrund im Kampf
    ist noch das Gewölbe.
  - **Tests:** Der Computer hat alle 11 Probestunden je 30-mal gespielt: alle schaffbar (24–43 Züge, alle Figuren
    zusammen). Welt-Test mit Lene, Gesandten und Probestunden: alles richtig.

- **Schritt 13 – Kreuzweg-Demo, Der zugewachsene Weg** (Schritt 6 aus `KREUZWEG_PLAN.md`, Stufe 7–8):
  - Nach den Gesandten bittet **Lene** dich, der Wache am alten Südost-Weg einen **Essenskorb** zu bringen.
  - **Wache Holm** steht am Anfang der zugewachsenen sechsten Straße (hinter der Schmiede). Er freut sich über das
    Essen, aber zum Weg sagt er nur „Befehl der Fünf: Niemand geht da lang“ – und schickt dich weg.
  - Danach hörst du ein leises Singen: **Mira** steht plötzlich da und spricht dich an: **„Hörst du sie auch?“**
    Sie war vor zehn Jahren auch Novize, hustet („Die Lieder werden lauter“) und verabschiedet sich mit einem Hinweis
    auf das **Fest der fünf Wege**. Danach ist sie wieder fort.
  - Belohnung: 200 + 250 Erfahrung = **Stufe 7** (mit allen freiwilligen Probestunden Stufe 8).
  - **Platzhalter:** alle Texte von Lene, Holm und Mira (Mira ist eine Hauptfigur: Marco schreibt ihre Dialoge noch).
  - Der Marktplatz ist inzwischen recht voll (viele Namensschilder dicht beieinander). Das nehme ich mir beim
    Feinschliff (Schritt 9) vor.
  - Test: Welt-Test mit Korb, Wache und Mira: alles richtig.

- **Schritt 14 – Kreuzweg-Demo, Nacht des Sternenfalls** (Schritt 7 aus `KREUZWEG_PLAN.md`, Stufe 8–10):
  - **Aufgeräumt:** Die Gesandten stehen jetzt am Anfang „ihrer“ Straße (Arkanum Norden, Nebelinseln Nordwesten,
    Grünwacht Westen, Messinghafen Osten, Glutoase Süden) statt alle um die Statue. NPCs wippen deutlich ruhiger
    und nicht mehr alle im Gleichtakt.
  - **Fest der fünf Wege:** Lene lädt dich ein („Warum fünf Wege? Es gibt doch sechs Straßen.“ – „Die sechste zählt
    nicht.“). Es wird **Nacht**, auf dem Marktplatz leuchten **fünf Festlaternen** in den Farben der Regionen.
    Die Gesandten sind abgereist.
  - **Marv** spricht dich auf dem Fest an und fragt, ob du die Sternentafel schon hast. Mitten im Satz beginnt der
    **Sternenfall**: greller Lichtblitz, das Bild wackelt, ein Splitter schlägt ein, ein Feldschleim frisst ihn.
  - **Boss „Der Sternenfresser“** (mit Ida, Bo und Tom): Ein **Sternenpanzer** lässt Treffer fast abprallen. Nur eine
    **perfekte Parade** erschüttert ihn für kurze Zeit, dann könnt ihr zuschlagen. Nach **10 Zügen** explodiert
    der Splitter in seinem Bauch. So ist er nur mit mehreren guten Paraden zu schaffen.
    (Computer-Test mit jeder zweiten Parade gelungen: 11 von 30 Siegen – wer gut pariert, schafft es öfter.)
  - **Sieg:** Erfolg **„Schild hoch, Schild runter“** (steht jetzt im Auftragsbuch unter „Erfolge“) – und eine
    Fremde taucht auf, lobt dich und **klaut den Splitter**. **Niederlage:** Alles wird schwarz … dieselbe Fremde
    **rettet die Gruppe**. Ihren Namen nennt sie nicht (Namensschild „???“, sie sagt nur „Niemand. Und du hast mich nie gesehen.“). Im Spiel heißt sie intern weiter Ren.
  - Kein „Nochmal versuchen“ beim Boss: Die Geschichte geht so oder so weiter. Danach: Stufe 8 (Niederlage) bzw. 9 (Sieg).
  - Auf dem Marktplatz bleibt ein **leuchtender Krater**.
  - **Platzhalter:** alle Texte (Lene, Marv, Erzähler, Ye, Ren – Ren ist eine Hauptfigur). Der Kampf spielt noch im Gewölbe.
  - Tests: Welt-Test mit Fest, Sternenfall, Niederlage und Sieg: alles richtig. Sandbox-Kämpfe unverändert.

- **Schritt 15 – Parieren und Ausweichen neu** (überall: Kreuzweg-Demo und Kampf-Sandbox, auch in design.md):
  - Der Balken oben hat jetzt **zwei Zonen**: Die **hellgrüne normale Zone** (etwa eine halbe Sekunde um den Treffer)
    = normal pariert bzw. ausgewichen, **25 % weniger Schaden** („Pariert!“ / „Ausgewichen!“).
    In ihrer Mitte die **schmale grüne Perfekt-Zone** (20 % der Breite, genau wenn der Ring den Kreis erreicht)
    = **PERFEKT**: kein Schaden und die festgelegten Klassen-Effekte (Mana, Klinge, Konter …).
  - Nur **perfekte** Paraden zählen für Lektion 3 und erschüttern den Sternenfresser.
  - Ida, Bo und Tom: 10 % perfekt, 30 % normal.
  - Computer-Test mit einem Spieler, der je 35 % perfekt und normal trifft: Lektionen und Probestunden schaffbar,
    der Sternenfresser in 5 von 30 Fällen (kaum schaffbar, wie geplant).

- **Schritt 16 – Kreuzweg-Demo, Klassenwahl und Abreise** (Schritt 8 aus `KREUZWEG_PLAN.md`):
  - **Morgen danach:** Lene verkündet, dass alle Novizen heute in die Regionen reisen (die Nacht endet,
    die Laternen sind weg, der Krater bleibt). Auftrag „Die Abreise“.
  - **Marv** spricht dich ein letztes Mal an: „Du gehst?! Und unsere Partie Kreuzweg-Karten?“ (ohne „Zeit“, nach deinem Test geändert).
  - **Ye am Tor** öffnet den **Klassenwahl-Bildschirm**: links alle 11 Klassen, rechts Rolle, Region, **Lehrmeister**
    (aus design.md), Mechanik, Reaktion, ein **Fünfeck-Diagramm** (Schaden, Schutz, Heilung, Unterstützung,
    Schwierigkeit), eine **Ult-Vorschau** und die Knöpfe **„Probestunde“** und **„Diese Klasse wählen“**
    (mit Nachfrage). Die Probestunde startet direkt und führt danach zurück zur Klassenwahl.
  - Danach nennt Ye deine Klasse, Region und deinen Lehrmeister („Also Bogenschütze. Dein Weg führt nach Grünwacht,
    zu Pfadmeister Fenn.“). Umentscheiden geht noch. Mit „Leb wohl, Ye.“ kommt der **Abspann** – Ende der Demo.
  - Die **Werte im Diagramm** habe ich selbst geschätzt: **vorläufig, Feinschliff am Ende** (in `data/klassen.json`).
  - Behoben nebenbei: Wurde man mitten im Laufen angesprochen, ging danach das Antippen eines direkt benachbarten NPCs
    manchmal nicht. Und Lene hätte am Morgen sonst noch einmal zum Fest eingeladen.
  - **Platzhalter:** alle Texte (Lene, Marv, Ye, Abspann).
  - Tests: Welt-Test bis zum Abspann, Test des Klassenwahl-Bildschirms (Auswahl, Probestunde, Wahl, Abspann): alles richtig.

- **Schritt 17 – Kreuzweg-Demo, Feinschliff** (Schritt 9 aus `KREUZWEG_PLAN.md`):
  - **Platzhalter-Musik:** vier kleine Retro-Stücke, selbst erzeugt (keine Lizenzfragen): **Stadt**, **Nacht** (Fest,
    Abspann), **Kampf** und **Boss** (sobald ein großer Gegner auftaucht). Sanftes Überblenden beim Wechsel.
    **Taste M** oder der Knopf im Menü schaltet die Musik an und aus (wird gemerkt).
  - **Lautstärke-Regler** (nach deinem Wunsch): im Startmenü unter dem Musik-Knopf und oben links in der Kreuzweg-Demo,
    0–100 % in 5er-Schritten, gilt für alles, was das Spiel abspielt, und wird auf dem Gerät gemerkt.
  - **Kampf vor der Stadt:** Lektionen, Gruppenkampf und Probestunden spielen jetzt auf einer **Wiese vor der
    Stadtmauer von Kreuzweg** (mit Tor, Hügeln, Pollen). Der Sternenfresser kämpft auf dem **Marktplatz bei Nacht**
    (erleuchtete Häuser, die fünf Festlaternen). Sandbox und Pilzhöhle bleiben im Gewölbe.
  - **Marktplatz entzerrt:** NPC-Namen blenden mit der Entfernung aus (nah = voll sichtbar, ab ca. 6 Feldern weg).
    Die Zeichen „!“ und „?“ bleiben immer sichtbar.
  - **Automatischer Durchlauf** (`tests/durchlauf_test.gd`): Ein Computer-Spieler spielt die ganze erste Stunde am
    Stück – mit echten Kämpfen – von der Ankunft bis zum Abspann. Mit fünf verschiedenen Zufallswerten ohne Hänger.
    **Stufenverlauf:** Ankunft 1 → 2, Grundausbildung bis 5, Gesandte 6 (mit allen Probestunden 7), zugewachsener Weg 7,
    Sternenfall 8–9, Abreise 9–10. Passt zum Plan in design.md.
    Der Computer braucht etwa 14 Minuten; wer alles liest, sich umsieht und mehrere Probestunden macht, eher 30–45.
  - **Werte:** Nach dem Durchlauf nichts Großes geändert. Beobachtung: Mit Heiltränken und Stufe 8 schafft der Computer
    den Sternenfresser in der Geschichte öfter (etwa jedes zweite Mal) als ohne Tränke. Dein Eindruck beim Testen
    entscheidet, ob er schwerer werden soll.

- **Schritt 18 – Rückmeldungen aus deinem Test, Teil 1** (Grundwerte, ein langer Lernkampf, Kleinigkeiten):
  - **Die Unbekannte** nennt ihren Namen nicht mehr: „???“ über dem Kopf und im Gespräch („Niemand. Und du hast mich nie gesehen.“).
  - **Marv** sagt „Ich hab Zeit. Ganz viel Zeit.“ nur noch beim ersten Mal. Danach fragt er weiter nach der Sternentafel
    („Ich frag morgen wieder. Und übermorgen.“), auf dem Fest wird er vom Stern unterbrochen, beim Abschied:
    „Aber wehe, du übst da draußen heimlich!“ (Platzhalter.)
  - **Klassenwahl:** keine Zahlen mehr hinter den Werten im Diagramm.
  - **Grundwerte** (neu, Zahlen in `data/stufen.json`, **vorläufig, Feinschliff am Ende**): Leben, Mana, Angriff, Tempo.
    Stufe 1: 45 Leben (vorher 90), 30 Mana, Angriff 20, Tempo 11. Jede Stufe: **Leben +7, Mana +3, Angriff +1**.
    Angriff 20 = normaler Schaden, jeder Punkt mehr = 5 % mehr Schaden **und Heilung** (Stufe 9: 40 % mehr).
    Beim Stufenaufstieg steht, was gewachsen ist. Neues Fenster **„Werte (C)“** in der Stadt erklärt die Grundwerte.
    Ye erklärt sie auch im ersten Kampf. Die sechs Eigenschaften mit freien Punkten (design.md) kommen später mit der Klasse.
  - **Ein langer Lernkampf statt vier einzelner:** „Grundausbildung bei Ye“ hat vier Phasen (Tempo-Leiste → Fähigkeiten →
    Parieren gegen Ye → zwei Reihen). Jede Phase bringt neue Gegner, schaltet neue Fähigkeiten frei und Ye erklärt.
    Dein Leben geht mit in die nächste Phase (ein Viertel wird geheilt). Verlierst du, beginnt „Nochmal versuchen“
    bei der Lektion, in der du verloren hast. 300 Erfahrung beim ersten Sieg.
  - **Schwerer:** Feldschleim, Wiesenkobold und Rüpelkobold schlagen härter, Kobolde haben mehr Leben.
    Der Gruppenkampf hat eine **zweite Welle** (zwei Rüpelkobolde). Messung mit dem Computer-Spieler (pariert die Hälfte):
    Lernkampf 18 von 30 gewonnen, Gruppenkampf 25 von 30, Sternenfresser 8 von 30. Im kompletten Durchlauf hat der
    Computer den Gruppenkampf erst im dritten Versuch geschafft. Probestunden bleiben leicht (zum Ausprobieren).
  - Sandbox unverändert (Vergleich mit 75 Kämpfen: gleich).

- **Schritt 19 – Kampf-Geräusche** (nach deinem Wunsch): Schlag (Luftzug), Wurf/Pfeil/Zauber-Geschoss, Treffer
  (bei kritischen Treffern kräftiger), **Parade** (Klirren), **perfekte Parade** (Klirren mit hellem Dreiklang),
  Ausweichen (Luftzug), Zauber/Fähigkeit (aufsteigender Ton, bei der Ult tiefer) und Heilung (zwei Glockentöne).
  Auch die Paraden von Ida, Bo und Tom sind zu hören. Selbst erzeugt (`tools/sounds_erzeugen.gd`), Platzhalter.
  Der Lautstärke-Regler gilt auch für die Geräusche; Taste M schaltet nur die Musik ab.

- **Schritt 20 – Größere Stadt, Stände, Gesandten-Bildschirm** (Rückmeldungen Teil 3):
  - **Kreuzweg ist viermal so groß** (44 × 44 Felder statt 22 × 22). Runder Marktplatz mit der Statue der Fünf
    (fünf Figuren mit den Farben der Regionen) und einem Brunnen. **Straßen drei Felder breit** mit dunklem Rand,
    damit man sie klar sieht. Zehn zusätzliche Wohnhäuser, Blumen, viel mehr Bäume. Alle Figuren stehen an denselben
    Stellen wie vorher, nur weiter auseinander. Man läuft schneller (5,5 statt 4 Felder pro Sekunde).
  - Nachbesserung nach deinem Test: Das Wohnhaus stand auf dem fünften Weg (Nordwesten) – verschoben. Die Schmiede
    steht jetzt weiter weg von der Wache am sechsten Weg (Marta davor). Zweite Nachbesserung: Schmiede, Wohnhaus und
    ein Haus am Marktplatz verschoben. Jedes Haus hält jetzt mindestens ein Feld Abstand zu Straßen und Marktplatz
    (ein Test prüft das automatisch).
    Nalia (Glutoase) und Aske (Grünwacht) stehen jetzt rechts neben ihrem Stand statt dahinter bzw. davor.
  - **Häuser mit Satteldach** statt Kästen: Fachwerk-Balken, Tür mit Bogen, beleuchtete Fenster, Ziegelreihen, Schornstein.
  - **Stände der Gesandten:** Jeder Gesandte steht am Anfang seiner Straße vor einem kleinen Stand – Tresen,
    gestreiftes Sonnendach mit Bogenkante in der Farbe der Region, Schild mit dem Namen der Region.
    Positionen stehen in `data/kreuzweg.json` unter „staende“.
  - **Gesandten-Bildschirm:** „Zeig mir eure Klassen.“ öffnet denselben Bildschirm wie die Klassenwahl, aber nur
    mit den Klassen der Region (zwei, in der Glutoase drei). Mit Diagramm, Ult-Vorschau und Knopf „Probestunde“;
    „Wählen“ gibt es erst am Tag der Abreise bei Ye. Nach der Probestunde geht es zurück zu diesem Bildschirm.
  - Tests: Welt, Übergang, Klassenwahl (mit Gesandten-Bildschirm), Netz, kompletter Durchlauf: alles richtig.
    Neue Vorführ-Szene `tests/karte_auto.tscn` (Übersicht der Stadt für Bildschirmfotos).

- **Schritt 21 – Neue Figuren und Nebenaufträge** (aus Sitzung 21, „Kreuzweg im Detail“ in design.md):
  - **Nebenaufträge haben ein blaues „!“ und „?“** (Hauptaufträge bleiben gelb). Hat eine Figur beides, gilt das
    gelbe Zeichen der Geschichte. Im Auftragsbuch steht davor **„◆ Nebenauftrag:“** in Blau, die Meldung heißt
    „Neuer Nebenauftrag: …“. Oben bei „Ziel:“ steht immer zuerst die Geschichte; ein Nebenauftrag erscheint dort nur,
    wenn in der Geschichte gerade nichts offen ist, mit „Nebenbei:“ davor.
  - **Neue Figuren:** **Wirtin Hanne** vor dem neuen **Gasthaus „Wegrast“** (an der Weststraße), **Vogt Edmar** am Brunnen,
    **Steinmetz Quill** vor der Statue der Fünf, die Kinder **Pip und Lotte** auf dem Marktplatz (Südwesten).
    **Wache Holm heißt jetzt Torwache Brom** (Name aus Sitzung 21) und sagt „Da geht's nirgendwohin. Befehl ist Befehl.“
  - **Die fünf Nebenaufträge** (jeder bringt nebenbei etwas bei):
    - **Hannes Kater** (Hanne, gleich nach der Anmeldung in der Gilde): Lotte fragen, Kater Brösel in der Gasse neben
      Bingos Laden finden und mit **E / Leertaste / „Reden“** ansprechen. Lernziel: laufen, reden, Aktions-Taste.
    - **Glanz für die Fünf** (Quill, nach Ye's erstem Auftrag): Quill gibt eine **Bürste**. Direkt an der Statue in der
      **Tasche auf „Benutzen“** tippen. Unter dem Moos: die weggemeißelte sechste Zeile („… und der sechs…“).
      Lernziel: Gegenstände benutzen.
    - **Ein Festmahl** (Hanne, nach dem Kater): 3 Wiesenkraut und 2 Wildfleisch auf den Kreuzwegfeldern am Stadtrand
      sammeln. Die Sammelpunkte erscheinen erst mit dem Auftrag. Lernziel: Sammeln.
    - **Fünf Farben** (Edmar, nach dem ersten Gruppenkampf): fünf Festlaternen an die leeren Pfähle rund um den Marktplatz
      hängen (jede in der Farbe ihrer Region, sie leuchten danach auch am Tag). Dann Ye am Tor fragen:
      „Fünf Farben. Schön. … Fehlt nur eine.“ Zurück zu Edmar.
    - **Die Dunkelheit spielen** (Pip, gleich nach der Anmeldung): Du bist die Dunkelheit und verlierst. Danach fragt Lotte:
      „Warum hat die Dunkelheit auf der Statue eigentlich kein Gesicht?“
  - **„Essen für Brom“** aus Sitzung 21 gibt es schon: Das ist der Hauptauftrag „Ein Korb für die Wache“ (Lene schickt dich
    mit dem Essen zu Brom, er erzählt vom Weg, danach kommt Mira). Er bleibt deshalb ein Hauptauftrag mit gelbem Zeichen.
    Siehe offene Fragen.
  - **Noch nicht eingebaut:** die Mitschüler **Tessa und Gorm** (in der Demo heißen die Novizen-Mitstreiter Ida, Bo und Tom;
    siehe offene Fragen) und „Kreuzweg verändert sich mit der Story“ (Akt 2 und 3 gibt es in der Demo noch nicht).
  - **Platzhalter:** alle Texte der neuen Figuren (Stil nach dem Leitfaden „Sprache der Figuren“). Belohnungen (10–20 Gold,
    30–80 Erfahrung, ein Heiltrank beim Festmahl) sind **vorläufig, Feinschliff am Ende**.
  - **Neue Bausteine** (in `data/LIESMICH.md` erklärt): Aufträge mit `"neben": true`, **Orte** zum Benutzen (Kater,
    Laternenpfähle), Gegenstände mit **„Benutzen“** in der Tasche, Sammelpunkte und Ziel-Zeichen mit Bedingung,
    Bedingung „oder“.
  - **Tests:** neuer Teil im Welt-Test (blaues Zeichen, Hauptauftrag geht vor, Kater mit der Aktions-Taste, Bürste weit weg
    und an der Statue, Laternen, Ye erst danach mit „?“). Der Computer-Spieler im **kompletten Durchlauf erledigt jetzt
    auch alle fünf Nebenaufträge** (geschätzte Spielzeit 20–22 statt 18 Minuten). Alle bisherigen Tests laufen weiter,
    auch Netz und Durchlauf zu zweit.
    sie mit. (Im fertigen Spiel ist der erste Abschluss der über den Auftrag.) Auch in design.md eingetragen.

## Fertig in Runde 1

- **Schritt 1 – Kampf-Sandbox:** Alle 11 Klassen, Element-Sechseck, Zähmer mit Monster-Wechsel,
  Mechaniker mit Roboter, sechs Duette und die Kampfauswertung waren schon fertig.
  Angeglichen an design.md: Das Duett **Sternentanz** lässt Zaras Klingen jetzt eine Runde lang
  mit **Sternenkraft** treffen (ignoriert Resistenzen) und gibt +2 Klingen und Resonanz.

- **Schritt 2 – Pilzhöhle:** spielbar in der Sandbox (Auswahl → Gegner „Pilzhöhle“ oder „Pilzhöhle: nur Bosse“).
  Eigene Monster (Leuchtmotte, Wurzelkriecher, Sporenwolf, Glimmerkäfer), Zwischenboss Sporenkönigin
  (pro Kampf zufällig Sporenblüte ODER Sporen-Zwillinge), Wurzelmutter (Rinde heilt, Zwillingsknoten,
  Verschlingen, Wurzelzug) und Vorbote (Dunkelheit, keine Zugleiste, Lichtfraß, Das letzte Licht).
  Alle Mechaniken gehen mit jeder Klasse („Giftwolke vertreiben“, „Laterne entzünden“, „Licht weiterreichen“).
  Automatisch getestet: Wipes, abgewehrtes Verschlingen, Phase 2 und Siege kommen alle vor.

- **Schritt 3 – Kreuzweg-Demo (Gerüst):** Neues Startmenü. Stadt schräg von oben mit Platzhalter-Grafik
  (Marktplatz, Statue der Fünf, Gilde, Bingos Laden, Schmiede, sechs Straßen, die sechste zugewachsen),
  Laufen per Antippen mit Wegsuche um Häuser und Bäume, Ausbilder Ye mit kurzem Gespräch
  (beim zweiten Mal ein anderer Satz), Laterne an der Gildenwand als kleiner Hinweis.
  Spiellogik und Anzeige sind getrennt; ein „Testgefährte“ läuft als zweiter Spieler über dieselben Befehle.

- **Schritt 4 – Web-Export:** Nach jedem Push automatisch neu gebaut und veröffentlicht (alle Läufe erfolgreich).

## Was du testen kannst

Link: **https://cazex-studio.github.io/MiniKampf/** (Handy quer halten). Das Spiel startet jetzt mit einem Menü.

**Neu: Figuren und Nebenaufträge aus Sitzung 21** (Kreuzweg-Demo → „Neu beginnen“)
1. Nach der Anmeldung bei Lene: Haben Wirtin Hanne (vor dem Gasthaus Wegrast an der Weststraße) und Pip (Marktplatz)
   ein **blaues „!“**? Ist es gut vom gelben „!“ der Geschichte zu unterscheiden?
2. **Hannes Kater:** Lotte fragen, dann den schwarzen Kater neben Bingos Laden suchen und mit E / „Reden“ ansprechen.
3. **Glanz für die Fünf** bei Quill (vor der Statue): Tasche (I) öffnen, bei der Bürste auf „Benutzen“ tippen –
   erst weit weg (Hinweis), dann direkt an der Statue.
4. **Fünf Farben** bei Edmar (am Brunnen, nach dem ersten Gruppenkampf): Laternen aufhängen, dann zu Ye ans Tor.
5. Auftragsbuch (J): Stehen die Nebenaufträge mit blauem „◆ Nebenauftrag“ da? Ist oben bei „Ziel:“ immer klar,
   was die Geschichte als Nächstes will?

**Neu: Größere Stadt und Gesandten-Stände** (Kreuzweg-Demo → „Neu beginnen“)
1. Lauf einmal durch die Stadt: Ist sie groß genug? Erkennst du die fünf Straßen gut?
2. Gefallen dir die Häuser mit Dach besser als die Kästen von vorher?
3. Wenn die Gesandten da sind: Jeder steht vor einem kleinen Stand an seiner Straße. Sind die Stände klein und hübsch genug?
4. Bei einem Gesandten „Zeig mir eure Klassen.“: Du siehst nur seine Klassen (Glutoase drei, sonst zwei), kannst eine
   Probestunde machen und landest danach wieder dort.
5. Ist das Laufen jetzt zu lang, oder passt es mit dem schnelleren Gehen?

**Neu: Kampf-Geräusche** (irgendein Kampf, Ton an)
1. Greif an: Hörst du einen Luftzug beim Schlag und einen dumpfen Treffer?
2. Parier normal (hellgrünes Feld): Klirren. Perfekt (grüne Mitte): Klirren mit hellem Klang.
3. „Erste Hilfe“: zwei Glockentöne. Eine Fähigkeit der Probestunde: aufsteigender Zauberton.
4. Taste M: Die Musik geht aus, die Geräusche bleiben. Der Lautstärke-Regler macht beides leiser.

**Neu: Grundwerte und langer Lernkampf** (Kreuzweg-Demo → „Neu beginnen“)
1. Oben rechts „Werte (C)“ antippen: Leben 45, Mana 30, Angriff 20, Tempo 11 – mit kurzer Erklärung.
2. Bei Ye am Tor: Die Grundausbildung ist jetzt ein einziger langer Kampf mit vier Lektionen hintereinander.
   Achte darauf, ob Ye zwischendurch gut erklärt, was neu ist.
3. Verlier ruhig mal absichtlich in Lektion 3 oder 4: „Nochmal versuchen“ sollte bei dieser Lektion weitermachen.
4. Fühlen sich die Kämpfe jetzt fordernder an? Besonders der Gruppenkampf mit der zweiten Welle.
5. Die Unbekannte nach dem Sternenfall heißt nur „???“, und Marv sagt „Ganz viel Zeit“ nur beim ersten Mal.

**Neu in Runde 2 – bitte testen** (Kampf-Sandbox)
1. Bogenschütze ins Team nehmen und „Schnellfeuer“ antippen: Drei Pfeile fliegen auf zufällige Gegner.
2. Sternensängerin (heißt jetzt Vega) nehmen, „Polarstern“ auf einen Helden: Er steht danach weiter vorne in der Zugleiste und hat „Abw+“.
3. Monster-Zähmer nehmen, einen Gegner unter die Hälfte seines Lebens bringen, dann „Zähmen“. Klappt es, steht das
   Monster bei „Wechsel“ in der Liste und kämpft für dich.
4. „Pilzhöhle: nur Bosse“ schaffen: Am Ende kommt die Frage, was mit dem Urbaum geschieht (nur beim ersten Mal; zum
   erneuten Testen in der Kreuzweg-Demo „Neu beginnen“ antippen).
5. Kunoichi: Ein einzelnes Siegel lösen lädt die Ult nicht mehr, zwei Siegel auf demselben Gegner lösen (Kombination) schon.
6. Umbau des Kampfes: Spiel einen ganzen Kampf wie gewohnt. Es sollte sich nichts anders anfühlen: Treffer, Zahlen,
   Ring zum Parieren, Wellen und Auswertung wie vorher. Achte darauf, dass die Lebensleiste erst beim Treffer sinkt.

**Neu: Steuerung in der Kreuzweg-Demo** (Menü → „Kreuzweg-Demo“)
1. PC: Mit WASD oder den Pfeiltasten herumlaufen. Läuft die Figur in die richtige Richtung und bleibt an Häusern hängen?
2. PC: Neben Ausbilder Ye stellen und E (oder Leertaste) drücken: Das Gespräch startet, E blättert weiter.
3. Handy (quer): Daumen unten links aufsetzen und ziehen. Der Steuerknopf erscheint unter dem Daumen, die Figur läuft.
4. Handy: Neben Ye „Reden“ unten rechts antippen. Das Gespräch startet.
5. Antippen bzw. Klicken auf den Boden läuft weiterhin dorthin.

**Bausteine der Kreuzweg-Demo:** Gespräche mit Antworten, Auftragsbuch (J), Tasche (I), Stufe oben links, Speichern
(Seite neu laden = Stand bleibt) und „Neu beginnen“ testest du jetzt direkt im Ablauf „Ankunft in Kreuzweg“.

**Neu: Ankunft in Kreuzweg** (Menü → „Kreuzweg-Demo“, vorher einmal „Neu beginnen“)
1. Prüfe, ob der Erzähler die Stadt kurz vorstellt und oben „Ziel: Bei der Gildenschreiberin anmelden“ steht.
2. Zur Gildenschreiberin gehen (das „?“ über ihrem Kopf). Probier beide Antworten aus und lass dich eintragen.
3. Zu Ausbilder Ye gehen (jetzt hat er das „?“). Stell ihm Fragen und nimm danach seinen Auftrag an.
4. Der Schmiedin (südlich der Statue, vor der Schmiede) Bescheid sagen und die drei Kräuter sammeln.
   Prüfe, ob das Ziel oben mitzählt.
5. Bei Ye abgeben: Danach solltest du Stufe 2, 25 Gold und einen Heiltrank haben, und Ye erwähnt die Grundausbildung.

**Neu: Grundausbildung** (Kreuzweg-Demo, nach Ye's erstem Auftrag)
1. Prüfe, ob Ye nach seinem ersten Auftrag am Stadttor (unten, wo du angekommen bist) mit „!“ steht. Sprich ihn an.
2. Lektion 1 und 2 spielen: Erscheinen die Erklär-Fenster, kommt noch KEIN Ring, und geht es danach zurück in die Stadt?
   Am PC: Fähigkeiten mit den Zahlentasten 1, 2, 3 … wählen.
3. Lektion 3: Ye greift an, tippe, wenn der Ring grün wird. Prüfe, ob die Lektion nach zwei Paraden bestanden ist.
4. Lektion 4: Zuerst geht nur „Nach hinten“, die anderen Knöpfe sind gesperrt. Bekommst du hinten weniger Schaden?
5. Gruppenkampf mit Ida, Bo und Tom gewinnen und bei Ye abgeben: Danach solltest du Stufe 5 haben.

**Neu: Marv und Bingo** (Kreuzweg-Demo, nach der Grundausbildung)
1. Vom Stadttor Richtung Marktplatz laufen: Marv sollte dich von selbst ansprechen. Nimm seinen Auftrag an.
2. Zu Handelsherr Bingo (links vor seinem Laden): „Zeig mir deine Waren“. Kauf einen Heiltrank und verkauf etwas.
3. Versuch, die Sternentafel zu kaufen: Es sollte „Zu wenig Gold“ kommen.
4. Bingo nach dem leuchtenden Brett fragen, dann zurück zu Marv und den Auftrag abgeben.
5. Im Gruppenkampf (oder Lektion 4) einen Heiltrank trinken: Danach sollte er in der Tasche fehlen.

**Neu: Gesandte und Probestunden** (Kreuzweg-Demo, nach der Grundausbildung)
1. Am Stadttor nachsehen: Ye steht jetzt links neben der Straße und nicht mehr hinter den Bäumen.
2. Lene hat ein „!“: Sprich mit ihr und nimm den Auftrag an.
3. Geh zu einem der fünf Gesandten rund um die Statue und frag nach der Region. Starte dann eine Probestunde.
4. Prüfe in der Probestunde, ob die Erklärung zur Klasse passt und ob du die Ult (60 % voll) aufladen und benutzen kannst.
5. Danach bei Lene abgeben: Prüfe, ob du jetzt Stufe 6 hast. Probier gern noch weitere Klassen aus.

**Neu: Der zugewachsene Weg** (Kreuzweg-Demo, nach den Gesandten)
1. Prüfe bei einem Gesandten, ob er jetzt einen eigenen Namen hat (z. B. Feuertänzerin Nalia).
2. Lene bittet dich nach den Gesandten um den Essenskorb. Nimm an: Der Korb liegt jetzt in deiner Tasche.
3. Geh zu Wache Holm am Anfang der zugewachsenen Straße hinter der Schmiede, gib ihm den Korb und frag nach dem Weg.
4. Nachdem er dich wegschickt, sollte Mira dich ansprechen: „Hörst du sie auch?“
5. Danach sollte Mira wieder fort sein und du Stufe 7 haben.

**Neu: Nacht des Sternenfalls** (Kreuzweg-Demo, nach Mira)
1. Prüfe, ob die Gesandten jetzt an den fünf Straßen stehen und die NPCs ruhiger stehen.
2. Lene lädt zum Fest ein: Wird es Nacht, und leuchten auf dem Marktplatz fünf Laternen?
3. Geh zum Marktplatz: Marv spricht dich an, dann beginnt der Sternenfall (Lichtblitz) und der Boss-Kampf.
4. Im Kampf: Pariere die Angriffe des Sternenfressers. Erst nach einer perfekten Parade ist er „ERSCHÜTTERT“ und nimmt
   richtig Schaden. Achte auf den Countdown „EXPLOSION in X Zügen“.
5. Danach taucht eine namenlose Fremde auf (Ren; bei Sieg klaut sie den Splitter, bei Niederlage rettet sie euch). Bei Sieg: Auftragsbuch → Erfolge.

**Neu: Parieren mit zwei Zonen** (überall)
1. Lass dich angreifen und tippe früh im hellgrünen Feld: „Pariert!“ (oder „Ausgewichen!“), der Schaden ist kleiner.
2. Tippe genau in die schmale grüne Mitte, wenn der Ring den Kreis erreicht: „PERFEKT!“, kein Schaden, Klassen-Effekt.
3. Lektion 3 bei Ye: Zählen nur die perfekten Paraden?

**Neu: Klassenwahl und Abreise** (Kreuzweg-Demo, nach Ren)
1. Lene ansprechen: Es wird Morgen, die Abreise beginnt. Auf dem Weg zum Tor verabschiedet sich Marv.
2. Bei Ye am Tor die Klassen anzeigen lassen: Passen die Diagramme und die Ult-Vorschau zu den Klassen?
3. Bei einer Klasse auf „Probestunde“ tippen: Danach solltest du wieder auf der Klassenwahl landen.
4. Eine Klasse wählen und bestätigen: Ye sollte Klasse, Region und Lehrmeister nennen.
5. „Leb wohl, Ye.“: Prüfe, ob der Abspann erscheint und „Neu beginnen“ von vorne anfängt.

**Neu: Zusammen spielen, Schritt 1** (am PC in Godot, Anleitung auch in der README)
1. In Godot „Debuggen → Ausführungsinstanzen anpassen…“ öffnen, „Mehrere Instanzen aktivieren“, 2 eintragen, F5.
2. Fenster 1: Menü → „Zusammen spielen“, Name eingeben, Figur mit < > wählen, „Gastgeber werden“.
3. Fenster 2: anderen Namen und andere Figur, Adresse `localhost`, „Beitreten“. Siehst du dich in beiden Fenstern gegenseitig?
4. In einem Fenster laufen (WASD) und mit Lene reden: Läuft die Figur im anderen Fenster mit, und hat jeder seinen eigenen Auftrag?
   Fenster 1 sollte deinen normalen Spielstand haben (wie in der Kreuzweg-Demo), Fenster 2 einen eigenen.
5. Fenster 1 (Gastgeber) → „Menü“: Fenster 2 sollte mit einem Hinweis auf „Zusammen spielen“ zurückkehren.

**Neu: Chat** (Web-Version oder zwei Fenster, „Zusammen spielen“ → Online-Server)
1. Auf zwei Geräten beitreten: Steht im Chat „… ist in Kreuzweg.“?
2. Am PC Enter drücken, etwas schreiben, Enter: Steht es bei beiden im Chat und als Sprechblase über deiner Figur?
3. Am Handy auf „Chat (Enter)“ tippen: Kommt die Tastatur, und ist das Eingabefeld noch zu sehen?
4. Während der Eingabe W, A, S, D tippen: Die Figur sollte stehen bleiben.
5. Ein Gerät schließen: Steht beim anderen „… hat das Spiel verlassen.“?

**Neu: Gruppe bilden** (zwei Geräte, „Zusammen spielen“ → Online-Server)
1. Auf dem einen Gerät den anderen Spieler antippen: Kommt das Menü mit „In Gruppe einladen“?
2. Auf dem anderen Gerät „Annehmen“: Erscheint bei beiden rechts oben das Gruppenfenster, mit ★ beim Einladenden?
3. Sind die Namen der Gruppenmitglieder in der Stadt hellblau?
4. Einer startet einen Kampf (z. B. bei Ye): Steht beim anderen „kämpft gerade“?
5. „Gruppe verlassen“: Verschwindet das Fenster bei beiden (bei zwei Spielern ist die Gruppe dann aufgelöst)?

**Neu: Geschichte gemeinsam** (zwei Geräte, beide „Neu beginnen“, in einer Gruppe)
1. Beide die Einleitung durchklicken und nebeneinander zu Lene gehen. Einer spricht sie an: Ist der andere mit im Gespräch?
2. Bei „Soll ich dich eintragen?“ verschieden wählen: Entscheidet der Gruppenführer (★)?
3. Gleich wählen: Haben danach beide den Auftrag „zu Ye“?
4. Einer ist schon weiter (z. B. schon bei Ye gewesen): Steht bei ihm „Du schaust zu“, und kann er nicht wählen?
5. „Szene verlassen“: Ist man raus, und läuft das Gespräch für den anderen weiter?

**Neu: Gemeinsamer Kampf** (zwei Geräte, in einer Gruppe, beide bis zur Grundausbildung gespielt)
1. Nebeneinander zu Ye ans Tor, einer spricht ihn an, beide wählen beim Gruppenkampf „Wir schaffen das!“.
2. Landen beide im selben Kampf, mit euren Figuren vorne und Ida/Bo als Mitstreiter?
3. Ist beim eigenen Zug oben die Uhr (25 s) zu sehen, und beim anderen „… ist am Zug“?
4. Einmal 25 Sekunden nichts tun: Kommt ein Standardangriff?
5. Einer tippt auf „Aufgeben“: Kämpft der andere weiter?

**Neu: Nacht des Sternenfalls zusammen** (zwei Geräte in einer Gruppe, beide bis zum Fest gespielt)
1. Zusammen zum Marktplatz: Spricht Marv euch beide gemeinsam an?
2. Sehen beide den Sternenfall (Lichtblitz)? Ein drittes Gerät, das nicht auf dem Fest ist, sollte ihn auch sehen.
3. Beide „Los!“: Kämpft ihr zusammen gegen den Sternenfresser? Hat er mehr Leben als allein (300 statt 240)?
4. Einer gibt auf: Wartet er in der Stadt, bis der andere fertig ist, und spricht Ren dann beide zusammen an?

**Neu: Wiederverbinden** (zwei Geräte, Online-Server, in einer Gruppe)
1. Am Handy kurz das WLAN/die mobilen Daten aus- und wieder einschalten: Erscheint „Verbindung weg – verbinde neu …“?
2. Bist du danach wieder in der Stadt, mit deinem Fortschritt?
3. Bist du wieder in der Gruppe (beim anderen: „… ist wieder da.“)?

**Die ganze erste Stunde am Stück** (Kreuzweg-Demo → „Neu beginnen“, Ton an)
1. Spiel einmal von der Ankunft bis zum Abspann durch, ohne Abkürzungen. Notier dir, wo du nicht wusstest, was zu tun ist.
2. Achte auf die Musik: Stadt, Nacht beim Fest, Kampf, Boss beim Sternenfresser. Taste M bzw. Menü-Knopf schaltet sie ab,
   der Regler „Lautstärke“ (Menü und oben links in der Stadt) macht sie leiser oder lauter.
3. Kämpfe vor der Stadt: Wiese mit Stadtmauer im Hintergrund, der Sternenfresser auf dem nächtlichen Marktplatz.
4. Auf dem Marktplatz: Sind die Namen jetzt übersichtlicher (weit entfernte blenden aus)?
5. Gute Fragen dabei: Wie lange hast du gebraucht? War ein Kampf zu leicht oder zu schwer? Welche Stelle war langweilig?



## Vorläufige Werte (Feinschliff am Ende)

Diese Dinge stehen nicht in design.md, ich habe sie selbst gewählt. Sie sind **vorläufig, Feinschliff am Ende**:
Erst wenn alles spielbar ist, werden sie zusammen abgestimmt.

- **Selbst gewählte Passiven:**
  - Mechaniker / Roboter „Wartung“: Solange Fritz lebt, repariert sich der Roboter jeden Zug um 5.
  - Rüstungsschmied: Passende Rüstung fängt 40 % ab, jede Härte (bis 5) noch einmal 6 %.
  - Zwielicht-Wandler: Am Rand der Leiste „überladen“ = 1,6-facher Schaden, aber jeden Zug 8 % Rückstoß.
  - Bank-Boni der Zähmer-Monster: Moosling −15 % Schaden, Glutwelpe +15 % Schaden, Bachotter +5 LP je Zug.
- **Pilzhöhle (alle Zahlen):** Leben und Angriffe der Monster und Bosse, 5 Giftwolken mit je 2 Schaden,
  Sporenknospen heilen 8 %, Verschlingen nach 3 Zügen, Knotenpaar kostet 25 % Leben,
  Dunkelheit in 6 Stufen, Splitterlicht brennt 8, 12, 16 …
- **Neu in Runde 2:** Schnellfeuer (3 × 7), Polarstern (Abwehr+ und 30 % früher dran),
  Zähmen (unter 50 % Leben, Chance = fehlendes Leben, halbes Leben auf der Bank, höchstens 5 Monster).
## Als Nächstes (Vorschläge)

- Deine Rückmeldungen aus dem Test der ersten Stunde am Stück einarbeiten (Schwierigkeit, Länge, unklare Stellen).
- Rückmeldungen zu den neuen Figuren und Nebenaufträgen aus Sitzung 21 (Farbe, Brom, Tessa und Gorm).
- Dialoge der Hauptfiguren: Marco schreibt sie; Platzhalter stehen in `data/dialoge.json`.
- Rückmeldungen zur Pilzhöhle einarbeiten (Schwierigkeit, Zahlen).
- Lernprojekt 4 „Zusammen spielen“ ist gebaut: deine Rückmeldungen aus dem Test mit Freunden einarbeiten.
- Lernprojekt 5 „Grünwacht“: Plan steht (`GRUENWACHT_PLAN.md`). Entscheidungen vom 21.10. sind drin, als Nächstes Schritt 1.
- Hinten angestellt: Schnellsätze und Emotes (Vorschläge im Ideen-Parkplatz von design.md).

## Offene Fragen an Marco

- **Stufen der späteren Regionen** (Vorschlag, eilt nicht): 2. Region 20–25, 3. 25–30, 4. 30–35, 5. 35–40,
  Akt 3 40–50. Grünwacht selbst ist entschieden (Weg 10–15, Region 15–20).

- **Zusammen spielen:** Die vier Entscheidungen sind getroffen (20.10.). Auch geklärt: Bei Gleichstand entscheidet der
  Gruppenführer, wer eine Szene schon erlebt hat, stimmt nicht mehr mit ab. Schnellsätze sind hinten angestellt
  (Vorschläge in design.md im Ideen-Parkplatz).

- **Pilzhöhle – was ich selbst ergänzt habe** (bitte prüfen; alle Zahlen **vorläufig, Feinschliff am Ende**):
  - Gegen Giftwolken gibt es für jede Klasse „Giftwolke vertreiben“ (kostet den Zug), Wind-Treffer vertreiben auch eine.
    Jede Wolke macht bei jedem Zug der Königin 2 Schaden an allen.
  - „Dieselbe Runde“ heißt im Prototyp: bevor der überlebende Sporenknospe bzw. die Wurzelmutter wieder dran ist.
  - Ein zerstörtes Knotenpaar kostet die Wurzelmutter 25 % Leben, danach wachsen neue Knoten.
  - Splitterlicht: Der Halter wird vom Vorboten nicht angegriffen, verliert aber jeden Vorboten-Zug mehr Leben (8, 12, 16 …).
    Weiterreichen kostet den Zug.
  - Monsterkarten der Dungeon-Monster gibt es in der Sandbox noch nicht (Zähmen schon).


- **Sitzung 21 in der Demo:**
  - **Farbe der Nebenaufträge:** Ich habe **Blau** genommen, weil Grün schon für „erfüllt“ im Auftragsbuch und für deinen
    eigenen Namen steht. Passt das?
  - **„Essen für Brom“** ist in der Demo schon der Hauptauftrag „Ein Korb für die Wache“ (führt zu Mira). Soll er so
    bleiben, oder möchtest du zusätzlich einen kleinen Nebenauftrag, z. B. Brom in der Festnacht einen Teller von Hanne bringen?
  - **Tessa und Gorm:** In der Demo kämpfen drei Novizen mit (Ida, Bo, Tom). Sollen sie Tessa und Gorm heißen
    (dann zu zweit statt zu dritt), oder bleiben Ida, Bo und Tom?
  - Passen die Plätze (Wegrast an der Weststraße, Edmar am Brunnen, Quill vor der Statue, Kinder im Südwesten des Marktplatzes)?

- **Kreuzweg-Demo:** Passen die Positionen (Gilde im Nordosten, Bingos Laden im Westen, die sechste,
  zugewachsene Straße nach Südosten, Gesandte an „ihren“ Straßen)?
- **Sternenfresser:** Mit Heiltränken schafft der Computer ihn etwa jedes zweite Mal. Soll er schwerer werden?
