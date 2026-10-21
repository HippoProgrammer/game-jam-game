shader_type canvas_item;

// Controls the zoom
uniform float radius : hint_range(0.0, 5.0, 0.01) = 0.6;
// Controls the intensity of the distortion (higher values = more distortion)
uniform float power : hint_range(0.01, 3.0, 0.01) = 0.2;
// If true, color will be set directly, if false, color will be multiplied (for colored lenses)
uniform bool transparent_texture = true;
// The center of the lens in the minimap's own UV space (0..1), set this from script
uniform vec2 lens_center = vec2(0.5, 0.5);

void fragment() {
    vec2 uv = UV; // Get the current pixel's UV coordinates (local to the minimap TextureRect)
    vec2 centerUV = lens_center; // The center is already in UV space

    // Adjust for aspect ratio to prevent oval distortion
    vec2 aspect_ratio = vec2(TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x, 1.0);
    vec2 adjusted_uv = (uv - centerUV) * aspect_ratio + centerUV;

    // Calculate distance from the effect center
    float dist = distance(centerUV, adjusted_uv);

    // Compute warp intensity based on distance and power setting
    float warp = clamp(1.0 - pow(dist / radius, power), 0.0, 1.0);

    // Apply the distortion effect by pulling UVs towards the center
    vec2 warped_uv = uv + (centerUV - uv) * warp;

    // Sample the SubViewport texture at the new warped UVs
    vec4 tex_color = texture(TEXTURE, warped_uv);

    // If transparent_texture is true, directly set the color, otherwise multiply the color
    if (transparent_texture) {
        COLOR = tex_color;
    } else {
        COLOR *= tex_color;
    }
}