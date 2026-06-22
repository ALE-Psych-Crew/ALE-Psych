package core.audio;

import openfl.media.Sound as OpenFLSound;

/**
 * Handles the game's music and some related callbacks
 */
class Conductor
{
    /**
     * Shortcut to the game's music
     */
    public static var music(get, set):Null<FlxSound>;
    @:dox(hide)
    static function get_music():Null<FlxSound>
        return FlxG.sound.music;
    @:dox(hide)
    static function set_music(value:Null<FlxSound>):Null<FlxSound>
        return FlxG.sound.music = value;

    public static var bpm:Float = 100;

    public static var stepsPerBeat:Int = 4;
    public static var beatsPerSection:Int = 4;

    /**
     * List of sounds to be synchronized with the music
     */
    public static var synchronizedSounds:Array<FlxSound>;

    /**
     * Current position of the song (in milliseconds)
     */
    public static var time:Float;

    /**
     * Current position of the song (in seconds)
     */
    public static var secTime(get, never):Float;
    @:dox(hide)
    static function get_secTime():Float
        return time / 1000;

    /**
     * Duration of a beat (in milliseconds)
     */
    public static var crochet(get, never):Float;
    @:dox(hide)
    static function get_crochet():Float
        return 60000 / bpm;

    /**
     * Duration of a beat (in seconds)
     */
    public static var secCrochet(get, never):Float;
    @:dox(hide)
    static function get_secCrochet():Float
        return crochet / 1000;

    /**
     * Duration of a step (in milliseconds)
     */
    public static var stepCrochet(get, never):Float;
    @:dox(hide)
    static function get_stepCrochet():Float
        return crochet / stepsPerBeat;

    /**
     * Duration of a step (in seconds)
     */
    public static var secStepCrochet(get, never):Float;
    @:dox(hide)
    static function get_secStepCrochet():Float
        return stepCrochet / 1000;

    /**
     * Duration of a section (in milliseconds)
     */
    public static var sectionCrochet(get, never):Float;
    @:dox(hide)
    static function get_sectionCrochet():Float
        return crochet * beatsPerSection;

    /**
     * Duration of a section (in seconds)
     */
    public static var secSectionCrochet(get, never):Float;
    @:dox(hide)
    static function get_secSectionCrochet():Float
        return sectionCrochet / 1000;

    @:dox(hide)
    public static function init()
    {
        reset();

        synchronizedSounds = [];

		stepHit = new FlxTypedSignal<Int -> Void>();
		beatHit = new FlxTypedSignal<Int -> Void>();
		sectionHit = new FlxTypedSignal<Int -> Void>();

		safeStepHit = new FlxTypedSignal<Int -> Void>();
		safeBeatHit = new FlxTypedSignal<Int -> Void>();
		safeSectionHit = new FlxTypedSignal<Int -> Void>();

        musicPlay = new FlxTypedSignal<Void -> Void>();
        musicPause = new FlxTypedSignal<Void -> Void>();
        musicResume = new FlxTypedSignal<Void -> Void>();
        musicStop = new FlxTypedSignal<Void -> Void>();
        musicComplete = new FlxTypedSignal<Void -> Void>();

        FlxG.signals.preUpdate.add(update);
    }

    @:dox(hide)
    public static function destroy()
    {
        FlxG.signals.preUpdate.remove(update);

        reset(100, 4, 4);

        stop();

        synchronizedSounds = null;

        stepHit?.removeAll();
        stepHit = null;

        beatHit?.removeAll();
        beatHit = null;

        sectionHit?.removeAll();
        sectionHit = null;

        safeStepHit?.removeAll();
        safeStepHit = null;

        safeBeatHit?.removeAll();
        safeBeatHit = null;

        safeSectionHit?.removeAll();
        safeSectionHit = null;

        musicPlay?.removeAll();
        musicPlay = null;

        musicPause?.removeAll();
        musicPause = null;

        musicResume?.removeAll();
        musicResume = null;

        musicStop?.removeAll();
        musicStop = null;

        musicComplete?.removeAll();
        musicComplete = null;

        musicResync?.removeAll();
        musicResync = null;
    }

    @:dox(hide)
    @:unreflective
    public static var allowMusicUpdating:Bool = true;

    /**
     * Plays a song, with the option to configure some additional fields
     * 
     * @param sound Sound to use
     * @param bpm BPM of the song
     * @param stepsPerBeat Steps per Beat in the song
     * @param beatsPerSection Beats per section in the song
     * @param loop This determines whether the song should loop or not
     * @param volume Song volume
     */
    public static function play(sound:OpenFLSound, ?bpm:Float, ?stepsPerBeat:Int, ?beatsPerSection:Int, ?loop:Bool = true, ?volume:Float = 1)
    {
        if (sound == null)
            return;

        if (music == null || !(music is Sound))
        {
            music?.stop();
            music?.destroy();

            music = new Sound();
        }

        FlxG.sound.playMusic(sound, volume, loop);

        music.onComplete = () -> {
            reset(bpm, stepsPerBeat, beatsPerSection);

            musicComplete?.dispatch();
        };

        reset(bpm, stepsPerBeat, beatsPerSection);

        musicPlay?.dispatch();
    }

    /**
     * This pauses the music and the synchronized sounds
     */
    public static function pause()
    {
        music?.pause();

        for (sound in synchronizedSounds)
            sound?.pause();

        musicPause?.dispatch();
    }

    /**
     * This plays the music and the synchronized sounds again after a pause
     */
    public static function resume()
    {
        music?.resume();

        for (sound in synchronizedSounds)
            sound?.resume();

        synchronize();

        musicResume?.dispatch();
    }

    /**
     * This destroys and stops the music and synchronized audio
     */
    public static function stop()
    {
        music?.stop();

        music?.destroy();

        music = null;

        if (synchronizedSounds != null)
            for (sound in synchronizedSounds.copy())
            {
                sound?.stop();
                sound?.destroy();

                synchronizedSounds.remove(sound);
            }

        musicStop?.dispatch();
    }

    /**
     * Resets the song position to 0 and allows you to customize certain settings
     * 
     * @param bpm BPM of the song
     * @param stepsPerBeat Steps per Beat in the song
     * @param beatsPerSection Beats per section in the song
     */
    public static function reset(?bpm:Float, ?stepsPerBeat:Int, ?beatsPerSection:Int)
    {
        if (bpm != null)
            Conductor.bpm = bpm;

        if (stepsPerBeat != null)
            Conductor.stepsPerBeat = stepsPerBeat;

        if (beatsPerSection != null)
            Conductor.beatsPerSection = beatsPerSection;

        time = curStep = safeStep = curBeat = safeBeat = curSection = safeSection = 0;
    }

    public static var curStep:Int = 0;
	public static var safeStep:Int = 0;

	public static var curBeat:Int = 0;
	public static var safeBeat:Int = 0;

	public static var curSection:Int = 0;
	public static var safeSection:Int = 0;

	/**
	 * It is dispatched when a step is advanced in the song
	 */
	public static var stepHit:FlxTypedSignal<Int -> Void>;

	/**
	 * It is dispatched when a step is advanced in the song without skipping steps in case there is a lag spike
	 */
	public static var safeStepHit:FlxTypedSignal<Int -> Void>;

	/**
	 * It is dispatched when a beat is advanced in the song
	 */
	public static var beatHit:FlxTypedSignal<Int -> Void>;
	
	/**
	 * It is dispatched when a beat is advanced in the song without skipping beats in case there is a lag spike
	 */
    public static var safeBeatHit:FlxTypedSignal<Int -> Void>;

	/**
	 * It is dispatched when a section is advanced in the song
	 */
	public static var sectionHit:FlxTypedSignal<Int -> Void>;
	
	/**
	 * It is dispatched when a section is advanced in the song without skipping sections in case there is a lag spike
	 */
    public static var safeSectionHit:FlxTypedSignal<Int -> Void>;

	/**
	 * It is dispatched when the music plays
	 */
    public static var musicPlay:FlxTypedSignal<Void -> Void>;
    
	/**
	 * It is dispatched when the music pauses
	 */
    public static var musicPause:FlxTypedSignal<Void -> Void>;
    
	/**
	 * It is dispatched when the music resumes
	 */
    public static var musicResume:FlxTypedSignal<Void -> Void>;
    
	/**
	 * It is dispatched when the music stops
	 */
    public static var musicStop:FlxTypedSignal<Void -> Void>;
    
	/**
	 * It is dispatched when the music ends
	 */
    public static var musicComplete:FlxTypedSignal<Void -> Void>;
    
	/**
	 * It is dispatched when the specified sounds are synchronized with the music
	 */
    public static var musicResync:FlxTypedSignal<Void -> Void>;

    @:dox(hide)
    public static function update()
    {
        if (music == null || !allowMusicUpdating)
            return;

        if (music.playing)
        {
            time += FlxG.elapsed * 1000;

            final musicOffset:Float = Math.abs(music.time - time);

            if (musicOffset >= 25)
                synchronize();

            final newStep:Int = Math.floor(time / stepCrochet);

            if (newStep > curStep)
            {
                curStep = newStep;

                stepHandler();
            }
        }
    }

    /**
     * This synchronizes this class and the audio files to be synchronized with the music
     */
    public static function synchronize()
    {
        time = music.time;

        for (sound in synchronizedSounds)
            sound.time = time;

        musicResync?.dispatch();
    }

    @:dox(hide)
    public static function stepHandler()
    {
        stepHit?.dispatch(curStep);

        while (safeStep < curStep)
        {
            safeStep++;

            safeStepHit?.dispatch(safeStep);
        }

        final newBeat:Int = Math.floor(curStep / stepsPerBeat);

        if (newBeat > curBeat)
        {
            curBeat = newBeat;

            beatHandler();
        }
    }

    @:dox(hide)
    public static function beatHandler()
    {
        beatHit?.dispatch(curBeat);

        while (safeBeat < curBeat)
        {
            safeBeat++;

            safeBeatHit?.dispatch(safeBeat);
        }

        final newSection:Int = Math.floor(curBeat / beatsPerSection);

        if (newSection > curSection)
        {
            curSection = newSection;

            sectionHandler();
        }
    }

    @:dox(hide)
    public static function sectionHandler()
    {
        sectionHit?.dispatch(curSection);

        while (safeSection < curSection)
        {
            safeSection++;

            safeSectionHit?.dispatch(safeSection);
        }
    }

    @:deprecated
    public static var songPosition(get, set):Float;

    @:dox(hide)
    static function get_songPosition():Float
        return time;

    @:dox(hide)
    static function set_songPosition(value:Float)
        return time = value;
}