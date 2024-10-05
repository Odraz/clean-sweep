#version 330 core

out vec4 FragColor;

in vec2 TexCoords;

uniform sampler2D texture1; // The original texture
uniform sampler2D lightMap; // The updated light map

void main()
{
    vec4 texColor = texture(texture1, TexCoords);
    vec4 lightColor = texture(lightMap, TexCoords);

    float blueTone = 0.2; // Adjust this value to change the intensity of the blue tone
    vec3 nightColor = vec3(0.0, 0.0, blueTone);

    // Combine the night color with the light color
    vec3 finalColor = mix(nightColor, lightColor.rgb, lightColor.a);

    FragColor = vec4(texColor.rgb * finalColor, texColor.a);
}
