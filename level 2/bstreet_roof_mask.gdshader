shader_type canvas_item;
render_mode unshaded;

uniform sampler2D mask : source_color, filter_nearest;

void fragment() {
	vec4 tc = texture(TEXTURE, UV);
	float m = texture(mask, UV).r;
	COLOR = vec4(tc.rgb, tc.a * m);
}
