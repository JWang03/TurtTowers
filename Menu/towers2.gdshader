shader_type canvas_item;

void fragment() {
    vec2 uv = UV - 0.5;
    float v = smoothstep(0.3, 0.85, length(uv));
    COLOR = vec4(0.0, 0.0, 0.05, v * 0.75);
}