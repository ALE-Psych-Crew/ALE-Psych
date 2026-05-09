package core.audio;

import openfl.media.Sound;

class Conductor
{
    public static var music(get, never):Null<FlxSound>;
    static function get_music():Null<FlxSound>
        return FlxG.sound.music;

    public static var bpm:Float = 100;

    public static var stepsPerBeat:Int = 4;
    public static var beatsPerSection:Int = 4;

    public static var time:Float;

    public static var synchronizedSounds:Array<FlxSound>;

    public static var secTime(get, never):Float;
    static function get_secTime():Float
        return time / 1000;

    public static var crochet(get, never):Float;
    static function get_crochet():Float
        return 60000 / bpm;

    public static var secCrochet(get, never):Float;
    static function get_secCrochet():Float
        return crochet / 1000;

    public static var stepCrochet(get, never):Float;
    static function get_stepCrochet():Float
        return crochet / stepsPerBeat;

    public static var secStepCrochet(get, never):Float;
    static function get_secStepCrochet():Float
        return stepCrochet / 1000;

    public static var sectionCrochet(get, never):Float;
    static function get_sectionCrochet():Float
        return crochet * beatsPerSection;

    public static var secSectionCrochet(get, never):Float;
    static function get_secSectionCrochet():Float
        return sectionCrochet / 1000;

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

        FlxG.signals.preUpdate.add(update);
    }

    public static function destroy()
    {
        FlxG.signals.preUpdate.remove(update);

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

        safeSectionHit.removeAll();
        safeSectionHit = null;

        onMusicComplete.removeAll();
        onMusicComplete = null;
    }

    @:unreflective
    public static var allowMusicUpdating:Bool = true;

    public static function playMusic(sound:String, ?bpm:Float, ?stepsPerBeat:Int, ?beatsPerSection:Int)
    {
        if (sound == null)
            return;

        FlxG.sound.playMusic('music/' + sound + '.ogg');

        music.onComplete = () -> {
            reset(bpm, stepsPerBeat, beatsPerSection);

            onMusicComplete?.dispatch();
        };

        reset(bpm, stepsPerBeat, beatsPerSection);
    }

    public static function stopMusic()
    {
        if (FlxG.sound.music == null)
            return;

        music.stop();

        music.destroy();

        FlxG.sound.music = null;
    }

    public static function reset(?bpm:Float, ?stepsPerBeat:Int, ?beatsPerSection:Int)
    {
        Conductor.bpm = bpm ?? 100;
        Conductor.stepsPerBeat = stepsPerBeat ?? 4;
        Conductor.beatsPerSection = beatsPerSection ?? 4;

        time = curStep = safeStep = curBeat = safeBeat = curSection = safeSection = 0;
    }

    public static var onMusicComplete:FlxTypedSignal<Void -> Void>;

	public static var curStep:Int = 0;
	public static var stepHit:FlxTypedSignal<Int -> Void>;
	public static var safeStep:Int = 0;
	public static var safeStepHit:FlxTypedSignal<Int -> Void>;

	public static var curBeat:Int = 0;
	public static var beatHit:FlxTypedSignal<Int -> Void>;
	public static var safeBeat:Int = 0;
	public static var safeBeatHit:FlxTypedSignal<Int -> Void>;

	public static var curSection:Int = 0;
	public static var sectionHit:FlxTypedSignal<Int -> Void>;
	public static var safeSection:Int = 0;
	public static var safeSectionHit:FlxTypedSignal<Int -> Void>;

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

    public static function synchronize()
    {
        time = music.time;

        for (sound in synchronizedSounds)
            sound.time = time;
    }

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

    public static function sectionHandler()
    {
        sectionHit?.dispatch(curSection);

        while (safeSection < curSection)
        {
            safeSection++;

            safeSectionHit?.dispatch(safeSection);
        }
    }

    public static var songPosition(get, set):Float;

    static function get_songPosition():Float
        return time;

    static function set_songPosition(value:Float)
        return time = value;
}