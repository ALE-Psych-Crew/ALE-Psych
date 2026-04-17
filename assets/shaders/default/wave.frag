#pragma header

uniform float time;

uniform bool vertical;

uniform float amplitude;
uniform float frequency;
uniform float speed;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    
    if (vertical)
    {
        uv.y += amplitude * sin(frequency * uv.x - speed * time);
    } else {
        uv.x += amplitude * sin(frequency * uv.y - speed * time);
    }
    
    vec4 color = flixel_texture2D(bitmap, uv);
    
    gl_FragColor = color; 
}