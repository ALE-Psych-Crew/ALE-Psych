package utils.cool;

import core.structures.FlxColorData;

import flixel.util.FlxColor;

using StringTools;

class ColorUtil
{
	public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;

		var color:String = hideChars.split(color).join('').trim();
		
		if (color.startsWith('0x'))
			color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);

		if(colorNum == null)
			colorNum = FlxColor.fromString('#$color');

		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	public static function colorFromArray(arr:Array<Int>):Int
    	return #if neko arr[0] * 0x10000 + arr[1] * 0x100 + arr[2] #else FlxColor.fromRGB(arr[0], arr[1], arr[2]) #end;

	public static function colorLerp(from:FlxColor, to:FlxColor, ratio:Float):FlxColor
		return FlxColor.interpolate(from, to, MathUtil.fpsRatio(ratio));

	public static function getColorData(color:FlxColor):FlxColorData
		return {
			red: color.red,
			blue: color.blue,
			green: color.green,
			alpha: color.alpha,

			redFloat: color.redFloat,
			blueFloat: color.blueFloat,
			greenFloat: color.greenFloat,
			alphaFloat: color.alphaFloat,

			cyan: color.cyan,
			magenta: color.magenta,
			yellow: color.yellow,
			black: color.black,

			rgb: color.rgb,
			hue: color.hue,
			saturation: color.saturation,
			brightness: color.brightness,
			lightness: color.lightness,
			luminance: color.luminance
		};

	public static function setColorData(color:FlxColor, data:FlxColorData):FlxColor
	{
		if (data.red != null)
			color.red = data.red;
		
		if (data.blue != null)
			color.blue = data.blue;
		
		if (data.green != null)
			color.green = data.green;
		
		if (data.alpha != null)
			color.alpha = data.alpha;
		

		if (data.redFloat != null)
			color.redFloat = data.redFloat;
		
		if (data.blueFloat != null)
			color.blueFloat = data.blueFloat;
		
		if (data.greenFloat != null)
			color.greenFloat = data.greenFloat;
		
		if (data.alphaFloat != null)
			color.alphaFloat = data.alphaFloat;
		

		if (data.cyan != null)
			color.cyan = data.cyan;
		
		if (data.magenta != null)
			color.magenta = data.magenta;
		
		if (data.yellow != null)
			color.yellow = data.yellow;
		
		if (data.black != null)
			color.black = data.black;
		

		if (data.rgb != null)
			color.rgb = data.rgb;
		
		if (data.hue != null)
			color.hue = data.hue;
		
		if (data.saturation != null)
			color.saturation = data.saturation;
		
		if (data.brightness != null)
			color.brightness = data.brightness;
		
		if (data.lightness != null)
			color.lightness = data.lightness;
		

		return color;
	}
}