shader_type canvas_item;
// Dunkelheit beim Vorboten (Pilzhöhle): Das Feld ist dunkel, nur um Lichtquellen (Laternen, Splitterlicht)
// bleiben runde, weich auslaufende Lichtkreise hell. Je dunkler, desto kleiner die Kreise.

// Wie dunkel das Feld ist (0 = hell, 1 = schwarz)
uniform float amount : hint_range(0.0, 1.0) = 0.0;
uniform vec4 tint : source_color = vec4(0.01, 0.0, 0.04, 1.0);
// Bis zu 8 Lichter: x, y (Bildpunkte auf dem Feld), Halbmesser, Stärke (0 bis 1)
uniform vec4 lights[8];
uniform int light_count = 0;
// Größe des Feldes in Bildpunkten (um UV in Bildpunkte umzurechnen)
uniform vec2 field_size = vec2(1280.0, 530.0);

void fragment() {
	vec2 p = UV * field_size;
	float lit = 0.0;
	for (int i = 0; i < 8; i++) {
		if (i >= light_count) {
			break;
		}
		vec4 l = lights[i];
		// Lichtkreise liegen flach auf dem Boden: etwas breiter als hoch
		vec2 d = (p - l.xy) * vec2(1.0, 1.35);
		float k = 1.0 - smoothstep(l.z * 0.45, l.z, length(d));
		lit = max(lit, k * l.w);
	}
	COLOR = vec4(tint.rgb, amount * (1.0 - lit));
}
