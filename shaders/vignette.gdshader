shader_type canvas_item;
// Abdunklung zum Rand hin, wie bei Octopath Traveler.

uniform float strength : hint_range(0.0, 1.0) = 0.8;
uniform float inner = 0.32;
uniform float outer = 0.85;
uniform vec4 tint : source_color = vec4(0.02, 0.01, 0.05, 1.0);

void fragment() {
	vec2 d = (UV - vec2(0.5)) * vec2(1.0, 1.25);
	float v = smoothstep(inner, outer, length(d));
	COLOR = vec4(tint.rgb, v * strength);
}
