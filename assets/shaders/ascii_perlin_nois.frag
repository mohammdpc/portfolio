#version 460 core
#include <flutter/runtime_effect.glsl>
precision highp float;

// ---------------------------------------------------------------
// generative/pnoise.glsl and its dependencies, from LYGIA
// Copyright 2021-2023 Stefan Gustavson and Ian McEwan
// Published under the MIT license: https://opensource.org/license/mit/
// Source: https://github.com/patriciogonzalezvivo/lygia
// ---------------------------------------------------------------

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }
vec3 fade(vec3 t) { return t * t * t * (t * (t * 6.0 - 15.0) + 10.0); }

float quintic(const in float v) { return v*v*v*(v*(v*6.0-15.0)+10.0); }
vec2  quintic(const in vec2 v)  { return v*v*v*(v*(v*6.0-15.0)+10.0); }
vec3  quintic(const in vec3 v)  { return v*v*v*(v*(v*6.0-15.0)+10.0); }
vec4  quintic(const in vec4 v)  { return v*v*v*(v*(v*6.0-15.0)+10.0); }

float pnoise(in vec3 P, in vec3 rep) {
    vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
    vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    vec3 Pf0 = fract(P); // Fractional part for interpolation
    vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;

    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);

    vec4 gx0 = ixy0 * (1.0 / 7.0);
    vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);

    vec4 gx1 = ixy1 * (1.0 / 7.0);
    vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);

    vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
    vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
    vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
    vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
    vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
    vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
    vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
    vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);

    vec3 fade_xyz = quintic(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}

// ---------------------------------------------------------------
// fBm: several layers (octaves) of pnoise added together.
// Each octave has higher frequency (lacunarity) and lower strength (gain).
// The result is divided by the total strength so it stays in about [-1, 1].
// With octaves = 1 this is exactly plain pnoise.
// ---------------------------------------------------------------
float fbm(vec3 p, vec3 rep, int octaves, float lacunarity, float gain) {
    float sum = 0.0;
    float amp = 1.0;
    float total = 0.0;
    for (int i = 0; i < 8; i++) {
        if (i >= octaves) break;
        sum += amp * pnoise(p, rep);
        total += amp;
        p *= lacunarity;
        amp *= gain;
    }
    return sum / max(total, 0.0001);
}

// ---------------------------------------------------------------
// Your uniforms and animation
// ---------------------------------------------------------------
uniform float uZoom;         // noise zoom: bigger = more zoomed in, smaller = more zoomed out
uniform float uTime;         // animation clock, in seconds
uniform vec2 uResolution;    // canvas size, in device pixels
uniform vec2 uGridCount;     // number of character columns/rows on screen
uniform vec2 uAtlasLayout;   // number of glyph columns/rows inside the atlas texture
uniform sampler2D uAtlas;    // the character bitmap atlas

out vec4 fragColor;

void main() {
    // =============================================================
    // CONTROLS - edit these values, no changes needed on the Dart side
    // To get the ORIGINAL look: warpStrength = 0.0, swirl = 0.0,
    // rippleAmount = 0.0, octaves = 1, shapeMode = 0, contrast = 1.0,
    // gamma = 1.0, and all glyph values = 1.0.
    // =============================================================

    // --- Domain warp (distorts the noise using more noise) ---
    float warpStrength = 1.0;   // 0.0 = off. Around 0.5 to 2.0 is a good range
    float warpScale    = 1.0;   // frequency of the warp noise, bigger = finer wobbles
    float warpSpeed    = 1.0;   // how fast the warp animates, 0.0 = frozen warp
    int   warpPasses   = 1;     // 1 to 4. 2 or more = "warp of the warp", more liquid
    int   warpOctaves  = 1;     // 1 to 8. Detail layers inside the warp itself

    // --- Swirl (twists the pattern more the farther from the center) ---
    float swirl        = 0.0;   // 0.0 = off. Try 2.0 to 6.0. Negative spins the other way

    // --- Ripple (regular sine-wave wobble) ---
    float rippleAmount    = 0.0;  // 0.0 = off. Try 0.02 to 0.1
    float rippleFrequency = 10.0; // number of ripples
    float rippleSpeed     = 1.0;  // animation speed of the ripples

    // --- fBm detail for the final noise ---
    int   octaves      = 2;     // 1 = plain noise, 4 = much more detail (1 to 8)
    float lacunarity   = 2.0;   // frequency multiplier per octave
    float gain         = 0.5;   // strength multiplier per octave

    // --- Noise shape ---
    // 0 = normal (smooth blobs)
    // 1 = turbulence (sharp creases, few characters dominate)
    // 2 = ridged (sharp peaks, the inverse of turbulence)
    int   shapeMode    = 0;

    // --- Contrast of the noise value (which characters get picked) ---
    float contrast         = 1.8;  // 1.0 = unchanged, above 1 = more extreme characters
    float contrastMidpoint = 0.5;  // the value that stays fixed while stretching
    float gamma            = 1.0;  // above 1 = favors the first-index characters side, below 1 = the other side

    // --- Contrast of the drawn characters (how they look) ---
    float glyphSharpness = 1.0;  // 1.0 = unchanged, above 1 = crisper/bolder edges
    float glyphContrast  = 1.0;  // 1.0 = unchanged, above 1 = more contrast in the glyph color
    float glyphGamma     = 1.0;  // 1.0 = unchanged, above 1 = darker midtones

    // =============================================================
    // END OF CONTROLS
    // =============================================================

    vec3 backgroundColor = vec3(0.0, 0.0, 0.0); // solid background the shader paints itself

    float shortestSide = min(uResolution.x, uResolution.y);

    // 1. Which character cell is this pixel in, and where within it (grid space, unaffected by zoom)
    vec2 cellPixelSize = uResolution / uGridCount;
    vec2 cellIndex = floor(FlutterFragCoord().xy / cellPixelSize);
    vec2 cellLocalUV = fract(FlutterFragCoord().xy / cellPixelSize);

    // 2. Sample noise once per cell, in a centered/symmetric coordinate space
    vec2 cellCenterPx = (cellIndex + 0.5) * cellPixelSize;
    vec2 centeredUV = (cellCenterPx - 0.5 * uResolution) / shortestSide;

    float radius = length(centeredUV);

    // Swirl: rotate the position by an angle that grows with the radius.
    // Done BEFORE the fold so the 3-fold symmetry is kept (it becomes a spiral).
    float swirlAngle = swirl * radius;
    float sc = cos(swirlAngle);
    float sn = sin(swirlAngle);
    vec2 swirledUV = vec2(sc * centeredUV.x - sn * centeredUV.y,
    sn * centeredUV.x + sc * centeredUV.y);

    float rotationOffset = 30.0 * 3.14159265 / 180.0;
    float angle = atan(swirledUV.y, swirledUV.x) + rotationOffset;
    float wedgeAngle = 6.28318530718 / 3.0; // 3-fold symmetry
    angle = mod(angle, wedgeAngle);
    angle = abs(angle - wedgeAngle * 0.5);
    vec2 noiseSampleUV = vec2(cos(angle), sin(angle)) * radius;

    // Ripple: sine wobble, done AFTER the fold so symmetry is kept
    noiseSampleUV += rippleAmount * vec2(
    sin(noiseSampleUV.y * rippleFrequency + uTime * rippleSpeed),
    cos(noiseSampleUV.x * rippleFrequency + uTime * rippleSpeed)
    );

    // uZoom only affects how "zoomed in" the noise pattern looks;
    // the character grid stays perfectly fixed regardless of zoom level.
    vec3 rep = vec3(100.0);
    vec3 p = vec3(noiseSampleUV * uZoom, uTime * 0.3);

    // Domain warp: use noise to push the sample position around.
    // The offsets (5.2, 1.3, ...) are arbitrary numbers, their only job is
    // to make the x and y displacement uncorrelated with each other.
    if (warpStrength != 0.0) {
        for (int i = 0; i < 4; i++) {
            if (i >= warpPasses) break;
            vec3 wp = vec3(p.xy * warpScale, uTime * 0.3 * warpSpeed);
            vec2 q = vec2(
            fbm(wp + vec3(5.2, 1.3, 2.8), rep, warpOctaves, lacunarity, gain),
            fbm(wp + vec3(1.7, 9.2, 6.4), rep, warpOctaves, lacunarity, gain)
            );
            p.xy += q * warpStrength;
        }
    }

    float n = fbm(p, rep, octaves, lacunarity, gain); // roughly [-1, 1]

    // Noise shape -> value in [0, 1]
    float noiseValue;
    if (shapeMode == 1) {
        noiseValue = abs(n);            // turbulence
    } else if (shapeMode == 2) {
        noiseValue = 1.0 - abs(n);      // ridged
    } else {
        noiseValue = n * 0.5 + 0.5;     // normal, remap [-1,1] -> [0,1]
    }
    noiseValue = clamp(noiseValue, 0.0, 1.0);

    // Contrast on the noise value. The clamp is required: values outside
    // [0, 1] would pick a character index outside the atlas.
    noiseValue = clamp((noiseValue - contrastMidpoint) * contrast + contrastMidpoint, 0.0, 1.0);
    noiseValue = pow(noiseValue, gamma);

    // 3. Map noise -> character index (1.0 -> first glyph, 0.0 -> last glyph)
    float totalChars = uAtlasLayout.x * uAtlasLayout.y;
    float charIndex = floor((1.0 - noiseValue) * (totalChars - 0.001));
    float charColumn = mod(charIndex, uAtlasLayout.x);
    float charRow = floor(charIndex / uAtlasLayout.x);

    // 4. Sample the glyph - fills the whole cell, no spacing/inset
    vec2 glyphCellSize = 1.0 / uAtlasLayout;
    vec2 atlasUV = (vec2(charColumn, charRow) + cellLocalUV) * glyphCellSize;
    vec4 glyph = texture(uAtlas, atlasUV);

    // Glyph sharpness: steepen the alpha edge around 0.5
    float a = clamp((glyph.a - 0.5) * glyphSharpness + 0.5, 0.0, 1.0);

    // Use the bitmap's own baked-in color, blended toward the background by alpha.
    vec3 color = mix(backgroundColor, glyph.rgb, a);

    // Glyph contrast and gamma
    color = clamp((color - 0.5) * glyphContrast + 0.5, 0.0, 1.0);
    color = pow(color, vec3(glyphGamma));

    fragColor = vec4(color, 1.0);
}