shader_type canvas_item;

uniform float speed : hint_range(0.0, 2.0) = 0.25;
uniform float scale : hint_range(1.0, 20.0) = 7.0;
uniform float brightness : hint_range(0.0, 1.0) = 0.12;
uniform vec4 water_color : source_color = vec4(0.0, 0.102, 0.18, 1.0);
uniform vec4 caustic_color : source_color = vec4(0.102, 0.722, 0.831, 1.0);

float caustic(vec2 uv, float t) {
    vec2 p = uv * scale;
    float v = 0.0;

    v += sin(p.x * 1.2 + sin(p.y * 0.8 + t) * 1.5 + t * 1.1);
    v += sin(p.y * 1.1 + sin(p.x * 0.9 + t * 0.8) * 1.4 + t * 0.9);
    v += sin((p.x + p.y) * 0.9 + t * 1.3);
    v += sin((p.x - p.y) * 1.0 + sin(p.x * 0.5 + t) + t * 0.7);

    return pow(abs(sin(v * 0.5)), 3.0);
}

void fragment() {
    vec2 uv = UV;
    float t = TIME * speed;

    float c = caustic(uv, t) * 0.6 + caustic(uv + vec2(0.3, 0.2), t + 1.5) * 0.4;

    vec4 col = mix(water_color, caustic_color, c * brightness);
    COLOR = col;
}