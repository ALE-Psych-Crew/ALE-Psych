package utils.cool;

class SoundUtil
{
	public static inline function playSound(name:String, ?volume:Float = 1)
		FlxG.sound.play(Paths.sound(name), volume);
}