shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.48, 0.88, 0.52, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.08, 0.58, 0.38, 1.0);

uniform float radius : hint_range(0.0, 0.5) = 0.15;
uniform float border_width : hint_range(0.0, 0.1) = 0.025;
uniform vec4 border_color : source_color = vec4(0.03, 0.32, 0.20, 1.0);

float rounded_box(vec2 center_uv, vec2 size, float r) {
    vec2 q = abs(center_uv) - size + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
    vec2 center_uv = UV - 0.5;
    vec2 size = vec2(0.5, 0.5);
    
    float dist = rounded_box(center_uv, size, radius);
    
    vec4 gradient_mix = mix(top_color, bottom_color, UV.y);
    
    float alpha = 1.0 - smoothstep(0.0, 0.005, dist);
    
    // Border
    float border_mask = smoothstep(-border_width - 0.005, -border_width, dist);
    
    vec4 final_color = mix(gradient_mix, border_color, border_mask);
    
    COLOR = vec4(final_color.rgb, alpha);
}