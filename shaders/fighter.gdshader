shader_type canvas_item;
// Figuren-Shader: weißes Aufblitzen bei Treffern und ein leuchtender Umriss
// (z. B. wenn eine Fähigkeit gewirkt wird oder die Figur als Ziel wählbar ist).

uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	if (c.a < 0.5 && outline_color.a > 0.0) {
		vec2 px = TEXTURE_PIXEL_SIZE;
		float n = texture(TEXTURE, UV + vec2(px.x, 0.0)).a
			+ texture(TEXTURE, UV - vec2(px.x, 0.0)).a
			+ texture(TEXTURE, UV + vec2(0.0, px.y)).a
			+ texture(TEXTURE, UV - vec2(0.0, px.y)).a;
		if (n > 0.5) {
			c = outline_color;
		}
	} else {
		c.rgb = mix(c.rgb, vec3(1.0), flash);
	}
	COLOR = c * COLOR;
}
