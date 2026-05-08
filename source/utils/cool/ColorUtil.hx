package utils.cool;

class ColorUtil
{
	public static function colorFromString(colorString:String):FlxColor
	{
		var color:String = ~/[\t\n\r]/.split(colorString).join('').trim();
		
		if (color.startsWith('0x'))
			color = color.substring(color.length - 6);

		return FlxColor.fromString(color) ?? FlxColor.fromString('#$color');
	}
}