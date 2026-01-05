package utils.cool;

class MathUtil
{
	public static function floorDecimal(value:Float, decimals:Int):Float
		return FlxMath.roundDecimal(value, decimals);

	inline public static function quantize(f:Float, snap:Float)
		return Math.fround(f * snap) / snap;

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		
		for (i in min...max)
			dumbArray.push(i);

		return dumbArray;
	}

	public static function fpsLerp(v1:Float, v2:Float, ratio:Float):Float
		return FlxMath.lerp(v1, v2, fpsRatio(ratio));

	public static function fpsRatio(ratio:Float)
		return FlxMath.bound(ratio * FlxG.elapsed * 60, 0, 1);

	public static function snapNumber(og:Float, mod:Float):Float
		return Math.floor(og / mod) * mod;
}