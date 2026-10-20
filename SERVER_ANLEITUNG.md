# Anleitung: Online-Server einrichten (Zusammen spielen, Schritt 2)

Damit Freunde im Browser und am Handy mitspielen können, läuft das Spiel ohne Grafik als **Server im Internet**.
Wir nehmen dafür erst einmal den **kostenlosen** Anbieter **Render** (render.com). Alles Technische ist vorbereitet:
Der Bauplan steht in `render.yaml`, das Server-Paket in `server/Dockerfile`. Du musst nur ein Konto anlegen und
einmal auf „Anlegen“ klicken.

## Vorher: die Änderungen nach `main` übernehmen

Render und die Web-Version bauen immer aus `main`. Die Arbeit von Lernprojekt 4 liegt noch auf dem Arbeitszweig
`claude/spieldesign-dokumente-lesen-142xd3`. Sag mir Bescheid, dann lege ich einen Pull Request an. Du klickst auf
GitHub nur noch auf **„Merge pull request“**.

## 1. Konto bei Render anlegen (ca. 2 Minuten)

1. Öffne **https://render.com** und klicke auf **„Get Started“** bzw. **„Sign Up“**.
2. Wähle **„GitHub“** und melde dich mit dem Account **CazeX-studio** an.
3. Render fragt, auf welche Repos es zugreifen darf: **CazeX-studio/MiniKampf** auswählen (oder „All repositories“).
4. Wähle den kostenlosen Tarif („Hobby“ / „Free“). Für den kostenlosen Server braucht man normalerweise keine Kreditkarte.
   Fragt Render doch danach, schreib mir, bevor du etwas eingibst.

## 2. Server anlegen (ca. 5 Minuten, das meiste ist Warten)

1. Im Render-Dashboard oben auf **„New +“** → **„Blueprint“** klicken.
2. Das Repo **CazeX-studio/MiniKampf** auswählen. Render findet den Bauplan `render.yaml` von selbst und zeigt
   einen Dienst namens **asterfall-server** (Typ „Web Service“, Tarif „Free“).
3. Auf **„Apply“** (bzw. „Deploy Blueprint“) klicken.
4. Render baut jetzt den Server. Unter **„Logs“** siehst du, was passiert. Fertig ist er, wenn dort steht:
   **`Netz: Gastgeber bereit auf Port 10000`**
5. Oben auf der Seite des Dienstes steht seine **Adresse**, z. B. `https://asterfall-server.onrender.com`.
   **Schick mir diese Adresse.** Im Spiel ist schon `asterfall-server.onrender.com` eingetragen. Hat Render einen
   anderen Namen vergeben (weil der Name schon belegt war), trage ich die richtige Adresse ein.

## 3. Ausprobieren

1. Web-Version öffnen: **https://cazex-studio.github.io/MiniKampf/** (nach dem Merge neu gebaut).
2. Menü → **„Zusammen spielen“** → Name und Figur wählen → **„Online-Server“**.
3. Beim ersten Mal kann es **bis zu einer Minute** dauern (der Server wacht auf). Danach bist du in Kreuzweg.
4. Auf einem zweiten Gerät (z. B. Handy, quer halten) dasselbe machen: Ihr solltet euch gegenseitig sehen.

## Gut zu wissen

- **Der kostenlose Server schläft ein**, wenn 15 Minuten lang niemand spielt. Der Nächste, der beitritt, weckt ihn
  (bis zu einer Minute Warten). Solange jemand verbunden ist, meldet sich das Spiel alle 30 Sekunden kurz beim Server,
  damit er wach bleibt.
- **750 Stunden pro Monat** sind kostenlos. Das reicht für einen Server, der den ganzen Monat läuft.
- **Auf dem Server wird nichts gespeichert.** Jeder Spielstand bleibt auf dem eigenen Gerät (wie bisher).
- **Neue Versionen:** Sobald neuer Code auf `main` liegt, baut Render den Server automatisch neu. Wer gerade spielt,
  fliegt dabei kurz raus und kann gleich wieder beitreten.
- **Später** (mehr Spieler, kein Einschlafen) können wir auf einen kleinen gemieteten Server wechseln. Am Spiel
  ändert sich dafür nur die Adresse.

## Umzug nach Frankfurt (einmalig, nach dem Merge vom 20.10.)

Der erste Server stand in Oregon (USA), weil im Bauplan noch kein Standort stand. Von Deutschland aus ist das weit,
deshalb hängt das Spiel öfter. Der Bauplan sagt jetzt **Frankfurt**. Den Standort eines bestehenden Dienstes kann
Render nicht ändern, deshalb einmal neu anlegen:

1. Pull Request mergen (Link schickt Claude).
2. **https://dashboard.render.com** → **asterfall-server** → **„Settings“** → ganz unten **„Delete Web Service“**
   → Namen zur Bestätigung eintippen → löschen.
3. **https://dashboard.render.com/blueprints** → deinen Blueprint öffnen → **„Manual Sync“** (bzw. „Sync“).
   Render legt den Server neu an, diesmal in Frankfurt.
4. Warten, bis in den Logs wieder `Netz: Gastgeber bereit auf Port 10000` steht, und die Adresse prüfen
   (sollte wieder `asterfall-server.onrender.com` sein; sonst Claude die neue Adresse schicken).
