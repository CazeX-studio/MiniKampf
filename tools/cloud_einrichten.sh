#!/usr/bin/env bash
# Richtet Claude Code in der Cloud ein (Chat vom Handy): Godot 4.7.2 für Linux, Python-Pakete, Bilder importieren.
# Einmal zu Beginn eines Cloud-Chats starten: bash tools/cloud_einrichten.sh
cd "$(dirname "$0")/.." || exit 1
GODOT="$HOME/godot/godot"
if [ ! -x "$GODOT" ]; then
	mkdir -p "$HOME/godot"
	curl -sSL -o "$HOME/godot/godot.zip" https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
	python3 -m zipfile -e "$HOME/godot/godot.zip" "$HOME/godot/"
	mv "$HOME/godot/Godot_v4.7.2-stable_linux.x86_64" "$GODOT"
	chmod +x "$GODOT"
	rm "$HOME/godot/godot.zip"
fi
python3 -m pip install -q numpy pillow scipy
"$GODOT" --path . --import --headless > /dev/null 2>&1
echo "Cloud bereit: Godot liegt unter $GODOT"
