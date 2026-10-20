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
# Einmal importieren, damit der Server schnell startet
RUN godot --headless --path /spiel --import || true

# Der Anbieter gibt den Port über PORT vor (bei Render 10000)
ENV PORT=10000
EXPOSE 10000
CMD ["godot", "--headless", "--path", "/spiel", "--", "--server"]
