// =============================================================================
// GLSL Shader Color Formats Example
// nvim-colorpicker detects and can replace all these formats
// =============================================================================

#version 330 core

// Uniform color inputs
uniform vec3 u_ambientColor;
uniform vec3 u_diffuseColor;
uniform vec3 u_specularColor;
uniform vec4 u_overlayColor;

// Color constants (vec3 - RGB, values 0.0-1.0)
const vec3 COLOR_WHITE = vec3(1.000, 1.000, 1.000);
const vec3 COLOR_BLACK = vec3(0.000, 0.000, 0.000);
const vec3 COLOR_RED = vec3(1.000, 0.000, 0.000);
const vec3 COLOR_GREEN = vec3(0.000, 1.000, 0.000);
const vec3 COLOR_BLUE = vec3(0.000, 0.000, 1.000);

// Material colors
const vec3 GOLD = vec3(1.000, 0.843, 0.000);
const vec3 SILVER = vec3(0.753, 0.753, 0.753);
const vec3 COPPER = vec3(0.722, 0.451, 0.200);
const vec3 BRONZE = vec3(0.804, 0.498, 0.196);

// Skin tones
const vec3 SKIN_LIGHT = vec3(1.000, 0.859, 0.773);
const vec3 SKIN_MEDIUM = vec3(0.824, 0.635, 0.498);
const vec3 SKIN_DARK = vec3(0.545, 0.349, 0.247);

// With alpha (vec4 - RGBA)
const vec4 TRANSPARENT = vec4(0.000, 0.000, 0.000, 0.000);
const vec4 SEMI_WHITE = vec4(1.000, 1.000, 1.000, 0.500);
const vec4 GLASS = vec4(0.800, 0.900, 1.000, 0.200);
const vec4 SHADOW = vec4(0.000, 0.000, 0.000, 0.600);

// Game theme colors
const vec3 PLAYER_COLOR = vec3(0.310, 0.765, 0.969);
const vec3 ENEMY_COLOR = vec3(0.937, 0.325, 0.314);
const vec3 PICKUP_COLOR = vec3(1.000, 0.835, 0.310);
const vec3 HEALTH_COLOR = vec3(0.400, 0.733, 0.416);
const vec3 MANA_COLOR = vec3(0.671, 0.278, 0.737);

// Environment colors
const vec3 SKY_DAY = vec3(0.529, 0.808, 0.922);
const vec3 SKY_SUNSET = vec3(1.000, 0.600, 0.400);
const vec3 SKY_NIGHT = vec3(0.051, 0.051, 0.102);
const vec3 GRASS = vec3(0.365, 0.678, 0.329);
const vec3 WATER = vec3(0.255, 0.412, 0.882);
const vec4 WATER_ALPHA = vec4(0.255, 0.412, 0.882, 0.800);

// Fog colors
const vec3 FOG_COLOR = vec3(0.700, 0.750, 0.800);
const vec4 FOG_DENSE = vec4(0.500, 0.550, 0.600, 0.900);

void main() {
    // Example usage in fragment shader
    vec3 baseColor = vec3(0.800, 0.200, 0.100);
    vec3 ambient = baseColor * vec3(0.100, 0.100, 0.150);
    vec3 highlight = vec3(1.000, 0.950, 0.900);

    vec4 finalColor = vec4(baseColor, 1.000);

    // Apply overlay
    vec4 overlay = vec4(0.200, 0.400, 0.800, 0.300);
    finalColor = mix(finalColor, overlay, overlay.a);

    gl_FragColor = finalColor;
}
