package utils.cool;

class ColorUtil
{
	public static function colorFromString(color:String):FlxColor
	{
		var hideChars = ~/[\t\n\r]/;

		var color:String = hideChars.split(color).join('').trim();
		
		if (color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];

		for(col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);

				if (colorOfThisPixel != 0)
				{
					if(countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}

		var maxCount = 0;

		var maxKey:Int = 0;

		countByColor[FlxColor.BLACK] = 0;

		for(key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];

				maxKey = key;
			}
		}

		countByColor = [];

		return maxKey;
	}
	
	public static function colorFromArray(arr:Array<Int>):Int
    	return FlxColor.fromRGB(arr[0], arr[1], arr[2]);	

	public static function colorLerp(from:FlxColor, to:FlxColor, ratio:Float):FlxColor
		return FlxColor.interpolate(from, to, MathUtil.fpsRatio(ratio));
}