package utils.cool;

class SoundUtil
{
	public static inline function playSound(name:String, ?volume:Float = 1, ?looped = false):Sound
	{
		final sound:Sound = new Sound();
		sound.volume = volume;
		sound.loadEmbedded(Paths.sound(name), looped);

		FlxG.sound.defaultSoundGroup.add(sound);

		sound.play();

		return sound;
	}
}