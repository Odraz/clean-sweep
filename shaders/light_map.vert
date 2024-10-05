#version 330 core

out vec4 FragColor;

in vec2 TexCoords;

uniform sampler2D lightMap; // The current light map
uniform vec2 lightPos; // Position of the flashlight in screen coordinates
uniform float lightRadius; // Radius of the flashlight
uniform vec3 lightColor; // Color of the flashlight

void main()
{
    vec4 currentLight = texture(lightMap, TexCoords);

    // Calculate distance from the current pixel to the light source
    float distance = length(TexCoords - lightPos);

    // Calculate the light intensity based on the distance
    float lightIntensity = 1.0 - smoothstep(0.0, lightRadius, distance);

    // Combine the current light with the new light based on the light intensity
    vec3 newLight = mix(currentLight.rgb, lightColor, lightIntensity);

    FragColor = vec4(newLight, 1.0);
}
