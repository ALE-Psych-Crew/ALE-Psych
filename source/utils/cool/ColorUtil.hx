package utils.cool;

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
}