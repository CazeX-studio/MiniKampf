# Online-Server für „Zusammen spielen“ (Lernprojekt 4, Schritt 2).
# Startet das Spiel ohne Grafik als Server. Der Anbieter (Render) baut daraus automatisch den Server,
# sobald neuer Code auf main liegt. Anleitung: SERVER_ANLEITUNG.md
FROM mirror.gcr.io/library/debian:bookworm-slim

ARG GODOT_VERSION=4.7.2
RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates curl unzip libfontconfig1 \
	&& curl -sSL -o /tmp/godot.zip "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
	&& unzip -q /tmp/godot.zip -d /tmp \
	&& mv /tmp/Godot_v${GODOT_VERSION}-stable_linux.x86_64 /usr/local/bin/godot \
	&& rm /tmp/godot.zip \
	&& apt-get purge -y curl unzip && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /spiel
COPY . .
# Einmal importieren, damit der Server schnell startet. Bricht der Import ab (zu wenig Speicher beim Bauen),
# macht der nächste Durchgang dort weiter, wo der letzte aufgehört hat.
RUN for i in 1 2 3; do godot --headless --path /spiel --import && break; echo "Import abgebrochen, neuer Versuch $i"; done; \
	test -d /spiel/.godot/imported

# Der Anbieter gibt den Port über PORT vor (bei Render 10000)
ENV PORT=10000
EXPOSE 10000
CMD ["godot", "--headless", "--path", "/spiel", "--", "--server"]
