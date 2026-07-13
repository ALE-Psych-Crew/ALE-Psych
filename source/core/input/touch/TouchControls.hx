package core.input.touch;

@:allow(core.input.touch.TouchButton)
class TouchControls
{
	static var justReleasedMap:Vector<Int>;
	static var justPressedMap:Vector<Int>;
	static var pressedMap:Vector<Int>;


	static function checkKeys(keys:Array<Null<FlxKey>>, map:Vector<Int>)
	{
		for (key in keys)
		{
			if (key == null || (key : Int) <= 0)
				continue;
			
			if (map[key] > 0)
				return true;
		}

		return false;
	}

	public static function anyJustReleased(keys:Array<Null<FlxKey>>):Bool
		return checkKeys(keys, justReleasedMap);

	public static function anyJustPressed(keys:Array<Null<FlxKey>>):Bool
		return checkKeys(keys, justPressedMap);

	public static function anyPressed(keys:Array<Null<FlxKey>>):Bool
		return checkKeys(keys, pressedMap);
	

	public static function init()
	{
		var maxVal:Int = 0;

		for (value in FlxKey.toStringMap.keys())
			if ((value : Int) > maxVal)
				maxVal = value;

		justReleasedMap = new Vector<Int>(maxVal);
		justPressedMap = new Vector<Int>(maxVal);
		pressedMap = new Vector<Int>(maxVal);
	}
}