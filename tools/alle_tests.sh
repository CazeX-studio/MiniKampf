#!/usr/bin/env bash
# Startet alle Prüfungen (tests/*_test.gd) gleichzeitig auf allen Kernen und meldet nur, was schiefging.
# Aufruf: bash tools/alle_tests.sh            (alle)
#         bash tools/alle_tests.sh gruenwacht (nur Prüfungen, deren Name das Wort enthält)
# Godot: $GODOT, sonst ~/godot/godot (Cloud) oder die Konsolenversion auf Marcos PC.
# Jede Prüfung bekommt einen eigenen Speicherordner (user://), damit sich gleichzeitig laufende Prüfungen
# keinen Spielstand teilen und der echte Spielstand unberührt bleibt. Die Netz-Prüfungen bekommen je einen
# eigenen Anschluss (MINIKAMPF_PORT), damit sie sich nicht in die Quere kommen.
set -u
cd "$(dirname "$0")/.."

if [ -z "${GODOT:-}" ]; then
	if [ -x "$HOME/godot/godot" ]; then
		GODOT="$HOME/godot/godot"
	else
		GODOT="C:/GameDev/Godot/Godot_v4.7.2-stable_win64_console.exe"
	fi
fi
export GODOT

filter="${1:-}"
# Uhrzeit für Tag und Nacht (D14): fest 12 Uhr, damit die Prüfungen nicht von der echten Uhr abhängen.
# Nachts prüfen: MINIKAMPF_STUNDE=23 bash tools/alle_tests.sh
export MINIKAMPF_STUNDE="${MINIKAMPF_STUNDE:-12}"
kerne="$( (nproc || echo "${NUMBER_OF_PROCESSORS:-4}") 2>/dev/null | head -1)"
ordner="$(mktemp -d)"
export ordner
trap 'rm -rf "$ordner"' EXIT

# Eine Prüfung laufen lassen: Ausgabe in eine Datei, Zeit und Ergebnis in eine Zeile
eine() {
	local t="$1"
	local name
	name="$(basename "$t" .gd)"
	local daten="$ordner/daten_$name"
	mkdir -p "$daten"
	local start
	start="$(date +%s)"
	# Eigener Anschluss je Prüfung, aus dem Namen abgeleitet (9000 bis 9899)
	local port=$(( 9000 + $(echo -n "$name" | cksum | cut -d' ' -f1) % 900 ))
	MINIKAMPF_PORT="$port" XDG_DATA_HOME="$daten" APPDATA="$daten" timeout 300 "$GODOT" --headless --path . -s "$t" > "$ordner/$name.log" 2>&1
	local code=$?
	local dauer=$(( $(date +%s) - start ))
	local fehler
	fehler="$(grep -E "FEHLER|SCRIPT ERROR|Parse Error" "$ordner/$name.log" | head -5)"
	if [ -n "$fehler" ] || [ "$code" -ne 0 ]; then
		[ "$code" -eq 124 ] && fehler="${fehler}"$'\n'"Abgebrochen nach 5 Minuten"
		[ "$code" -ne 0 ] && [ "$code" -ne 124 ] && fehler="${fehler}"$'\n'"Beendet mit Fehlercode $code"
		# Dazu die letzten Zeilen der Ausgabe, damit man sieht, wo es hing
		fehler="${fehler}"$'\n'"Letzte Zeilen:"$'\n'"$(grep -vE '^\s*at:|^$|ObjectDB|resources still' "$ordner/$name.log" | tail -6)"
		printf 'FEHLER  %3ds  %s\n%s\n' "$dauer" "$name" "$(echo "$fehler" | sed 's/^/        /')" > "$ordner/$name.ergebnis"
	else
		printf 'ok      %3ds  %s\n' "$dauer" "$name" > "$ordner/$name.ergebnis"
	fi
}
export -f eine

tests=$(ls tests/*_test.gd | grep -- "$filter")
gesamt_start="$(date +%s)"
# Die langen zuerst starten, damit am Ende nicht eine allein übrig bleibt
lang=$(echo "$tests" | grep -E "/(netz_|wildnis|faehigkeit_fx|aussehen_schichten)" || true)
kurz=$(echo "$tests" | grep -vE "/(netz_|wildnis|faehigkeit_fx|aussehen_schichten)" || true)
printf '%s\n%s\n' "$lang" "$kurz" | grep . | xargs -P "$kerne" -I{} bash -c 'eine "$@"' _ {}

anzahl=$(echo "$tests" | grep -c . || true)
# Nur die Fehler mit ihren Zeilen zeigen
cat "$ordner"/*.ergebnis 2>/dev/null | awk '/^ok/ {zeigen = 0} /^FEHLER/ {zeigen = 1} zeigen' || true
schlecht=$(cat "$ordner"/*.ergebnis 2>/dev/null | grep -c "^FEHLER" || true)
echo "Langsamste:"
cat "$ordner"/*.ergebnis | grep -E "^(ok|FEHLER)" | sort -k2 -rn | head -3 | sed 's/^/  /'
echo "$anzahl Prüfungen in $(( $(date +%s) - gesamt_start )) s, davon mit Fehler: $schlecht"
[ "$schlecht" -eq 0 ]
