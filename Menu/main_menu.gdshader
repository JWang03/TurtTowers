shader_type canvas_item;

// Grabs the screen underneath the ColorRect
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// 0: Off, 1: Protanopia, 2: Deuteranopia, 3: Tritanopia
uniform int mode = 0; 

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	
	if (mode == 1) {
		// Protanopia (Red-blind)
		float r = color.r * 0.56667 + color.g * 0.43333;
		float g = color.r * 0.55833 + color.g * 0.44167;
		float b = color.b;
		color.rgb = vec3(r, g, b);
	} else if (mode == 2) {
		// Deuteranopia (Green-blind)
		float r = color.r * 0.625 + color.g * 0.375;
		float g = color.r * 0.7 + color.g * 0.3;
		float b = color.b;
		color.rgb = vec3(r, g, b);
	} else if (mode == 3) {
		// Tritanopia (Blue-blind)
		float r = color.r * 0.95 + color.g * 0.05;
		float g = color.r * 0.0 + color.g * 0.43333 + color.b * 0.56667;
		float b = color.r * 0.0 + color.g * 0.475 + color.b * 0.525;
		color.rgb = vec3(r, g, b);
	}
	
	COLOR = color;
}