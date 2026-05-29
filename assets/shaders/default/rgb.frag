#pragma header

uniform vec3 r;
uniform vec3 g;
uniform vec3 b;
uniform float multiplier;

vec4 rgbTexture(sampler2D bitmap, vec2 coord)
{
	vec4 color = flixel_texture2D(bitmap, coord);

	if (!hasTransform || color.a == 0.0 || multiplier == 0.0)
	{
		return color;
	}

	vec4 newColor = color;
	newColor.rgb = min(color.r * r + color.g * g + color.b * b, vec3(1.0));
	newColor.a = color.a;
	
	color = mix(color, newColor, multiplier);
	
	if(color.a > 0.0)
	{
		return vec4(color.rgb, color.a);
	}

	return vec4(0.0, 0.0, 0.0, 0.0);
}

void main()
{
	gl_FragColor = rgbTexture(bitmap, openfl_TextureCoordv);
}