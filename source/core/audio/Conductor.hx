package core.audio;

import openfl.media.Sound as OpenFLSound;

import core.structures.ConductorEvent;
import core.structures.ALESong;

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
        reset(CoolVars.data.bpm, CoolVars.meta.stepsPerBeat, CoolVars.meta.beatsPerSection, true);
        
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
        musicResync = new FlxTypedSignal<Void -> Void>();

        FlxG.signals.postUpdate.add(update);
    }

    @:dox(hide)
    public static function destroy()
    {
        FlxG.signals.postUpdate.remove(update);

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

    /**
     * This allows the music data belonging to Conductor to be updated
     */
    public static var allowUpdating:Bool = true;

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

        synchronize();
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

        reset(CoolVars.data.bpm, CoolVars.meta.stepsPerBeat, CoolVars.meta.beatsPerSection, true);
    }

    /**
     * Resets the song position to 0 and allows you to customize certain settings
     * 
     * @param bpm BPM of the song
     * @param stepsPerBeat Steps per Beat in the song
     * @param beatsPerSection Beats per section in the song
     */
    public static function reset(?bpm:Float, ?stepsPerBeat:Int, ?beatsPerSection:Int, ?clearEvents:Bool = false)
    {
        if (bpm != null)
            Conductor.bpm = bpm;

        if (stepsPerBeat != null)
            Conductor.stepsPerBeat = stepsPerBeat;

        if (beatsPerSection != null)
            Conductor.beatsPerSection = beatsPerSection;

        time = curStep = safeStep = curBeat = safeBeat = curSection = safeSection = 0;
        
        allowUpdating = true;

        allowRewind = false;

        if (clearEvents)
        {
            eventIndex = 0;

            events = null;
        }
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

    public static var allowRewind:Bool = false;

    /**
     * This corresponds to the index of the current event
     */
    static var eventIndex:Int = 0;

    /**
     * This refers to the list of events involving BPM Changes and Time Signature changes
     */
    static var events:Null<Array<ConductorEvent>>;

    /**
     * This corresponds to the current event
     */
    static var curEvent(get, never):Null<ConductorEvent>;
    @:dox(hide)
    static function get_curEvent():Null<ConductorEvent>
        return events == null ? null : events[eventIndex];

    /**
     * Retrieves the events that will occur based on a Chart
     * @param chart Chart to Analyze
     */
    public static function loadEvents(?chart:ALESong)
    {
        eventIndex = 0;

        if (chart == null)
        {
            events = null;

            return;
        }

        bpm = chart.bpm;
        stepsPerBeat = chart.stepsPerBeat;
        beatsPerSection = chart.beatsPerSection;

        var curTime:Float = 0;

        var curStep:Int = 0;
        var curBeat:Int = 0;
        var curSection:Int = 0;

        events = [];

        for (section in chart.sections)
        {
            if (section.changeBPM || section.changeTimeSignature)
            {
                if (section.changeBPM)
                    bpm = section.bpm;

                if (section.changeTimeSignature)
                {
                    stepsPerBeat = section.stepsPerBeat;
                    beatsPerSection = section.beatsPerSection;
                }

                events.push({
                    bpm: bpm,
                    time: curTime,
                    step: curStep,
                    beat: curBeat,
                    section: curSection,

                    stepsPerBeat: stepsPerBeat,
                    beatsPerSection: beatsPerSection
                });
            }

            curTime += sectionCrochet;

            curBeat += beatsPerSection;
            curStep += stepsPerBeat * beatsPerSection;

            curSection++;
        }

        bpm = chart.bpm;

        stepsPerBeat = chart.stepsPerBeat;
        beatsPerSection = chart.beatsPerSection;
    }

    @:dox(hide)
    public static function update()
    {
        if (music == null || !allowUpdating)
            return;

        if (music.playing)
        {
            time += FlxG.elapsed * 1000;

            if (Math.abs(music.time - time) >= 25)
                synchronize();

            var newStep:Int = 0;

            if (events == null || events.length <= 0)
            {
                newStep = Math.floor(time / stepCrochet);
            } else {
                while (eventIndex + 1 < events.length && time >= events[eventIndex + 1].time)
                    eventIndex++;

                while (eventIndex > 0 && time < events[eventIndex].time)
                    eventIndex--;

                final event:ConductorEvent = curEvent;

                if (bpm != event.bpm)
                    bpm = event.bpm;

                if (stepsPerBeat != event.stepsPerBeat)
                    stepsPerBeat = event.stepsPerBeat;

                if (beatsPerSection != event.beatsPerSection)
                    beatsPerSection = event.beatsPerSection;

                newStep = event.step + Math.floor((time - event.time) / stepCrochet);
            }

            if (allowRewind ? newStep != curStep : newStep > curStep)
            {
                curStep = newStep;

                stepHandler();

                if (needsResync())
                    synchronize();
            }
        }
    }

    /**
     * This synchronizes this class and the audio files to be synchronized with the music
     */
    public static function synchronize()
    {
        if (music == null)
            return;

        time = music.time;

        for (sound in synchronizedSounds)
            sound.time = time;

        musicResync?.dispatch();
    }

    /**
     * This simply checks to see if any of the audio tracks linked to Conductor are out of sync so that they can be resynchronized
     * @return This determines whether or not the audio should be resynchronized
     */
    static function needsResync():Bool
    {
        if (Math.abs(music.time - time) >= 20)
            return true;

        for (sound in synchronizedSounds)
            if (sound != null && Math.abs(sound.time - time) >= 20)
                return true;

        return false;
    }

    @:dox(hide)
    public static function stepHandler()
    {
        stepHit?.dispatch(curStep);

        while (safeStep < curStep)
            safeStepHit?.dispatch(++safeStep);

        final newBeat:Int = curEvent == null ? Math.floor(curStep / stepsPerBeat) : curEvent.beat + Math.floor((curStep - curEvent.step) / curEvent.stepsPerBeat);

        if (newBeat != curBeat)
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

        final newSection:Int = curEvent == null ? Math.floor(curBeat / beatsPerSection) : curEvent.section + Math.floor((curBeat - curEvent.beat) / curEvent.beatsPerSection);

        if (newSection != curSection)
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

    @:deprecated('Use `time` instead')
    public static var songPosition(get, set):Float;
    @:dox(hide)
    static function get_songPosition():Float
        return time;
    @:dox(hide)
    static function set_songPosition(value:Float)
        return time = value;
}