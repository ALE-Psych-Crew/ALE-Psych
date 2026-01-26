package utils;

import core.structures.ALESong;
import core.structures.BPMChange;

import flixel.util.FlxSignal.FlxTypedSignal;

@:access(core.backend.MusicBeatState)
class Conductor
{
	public static var offset:Float = 0;
	
	public static var songPosition:Float = 0;

	public static var stepsPerBeat:Int = 4;
	public static var beatsPerSection:Int = 4;

	public static var bpm:Float = 100;

	public static var crochet(get, never):Float;
	static function get_crochet():Float
		return 60000 / bpm;

	public static var secCrochet(get, never):Float;
	static function get_secCrochet():Float
		return 60 / bpm;

	public static var stepCrochet(get, never):Float;
	static function get_stepCrochet():Float
		return crochet / stepsPerBeat;

	public static var secStepCrochet(get, never):Float;
	static function get_secStepCrochet():Float
		return secCrochet / stepsPerBeat;

	public static var sectionCrochet(get, never):Float;
	static function get_sectionCrochet():Float
		return crochet * beatsPerSection;

	public static var secCectionCrochet(get, never):Float;
	static function get_secCectionCrochet():Float
		return secCrochet * beatsPerSection;

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
	
	public static var bpmChangeMap:Null<Array<BPMChange>>;
	static var bpmChangeIndex:Int = 0;

	public static function calculateBPMChanges(?song:Null<ALESong>)
	{
		bpmChangeIndex = 0;

		if (song == null)
		{
			bpmChangeMap = null;

			return;
		}

		var curTime:Float = 0;

		var curStep:Int = 0;

		bpm = song.bpm;
		
		bpmChangeMap = [
			{
				bpm: bpm,
				time: 0,
				step: 0
			}
		];

		for (section in song.sections)
		{
			if (section.changeBPM && section.bpm != bpm)
			{
				bpm = section.bpm;

				bpmChangeMap.push(
					{
						bpm: bpm,
						time: curTime,
						step: curStep
					}
				);
			}
			
			curTime += sectionCrochet;
			curStep += beatsPerSection * stepsPerBeat;
		}

		bpm = song.bpm;
	}

	public static function beatsToTime(beat:Int)
	{
		if (bpmChangeMap == null || bpmChangeMap.length <= 0)
			return beat * crochet;

		final prevBPM:Float = bpm;

		var time:Float = 0;
		var lastChange:BPMChange = bpmChangeMap[0];

		for (i in 1...bpmChangeMap.length)
		{
			final change:BPMChange = bpmChangeMap[i];

			final changeBeat:Int = Math.floor(change.step / stepsPerBeat);
			final lastBeat:Int = Math.floor(lastChange.step / stepsPerBeat);

			if (changeBeat > beat)
				break;

			bpm = lastChange.bpm;

			time += (changeBeat - lastBeat) * crochet;

			lastChange = change;
		}

		bpm = lastChange.bpm;

		time += (beat - Math.floor(lastChange.step / stepsPerBeat)) * crochet;

		bpm = prevBPM;

		return time;
	}

	public static function init()
	{
		stepHit = new FlxTypedSignal<Int -> Void>();
		beatHit = new FlxTypedSignal<Int -> Void>();
		sectionHit = new FlxTypedSignal<Int -> Void>();

		safeStepHit = new FlxTypedSignal<Int -> Void>();
		safeBeatHit = new FlxTypedSignal<Int -> Void>();
		safeSectionHit = new FlxTypedSignal<Int -> Void>();
	}

	public static function reset(?bpm:Float, ?stepsPerBeat:Int, ?beatsPerSection:Int)
	{
		songPosition = 0;

		curStep = curBeat = curSection = safeStep = safeBeat = safeSection = 0;
		
		if (bpm != null)
			Conductor.bpm = bpm;

		if (stepsPerBeat != null)
			Conductor.stepsPerBeat = stepsPerBeat;

		if (beatsPerSection != null)
			Conductor.beatsPerSection = beatsPerSection;

		bpmChangeIndex = 0;

		bpmChangeMap = null;
	}

	public static function destroy()
	{
		reset(100, 4, 4);

		for (signal in [stepHit, beatHit, sectionHit, safeStepHit, safeBeatHit, safeSectionHit])
			signal?.removeAll();
	}
	
	public static var allowUpdate:Bool = true;

	@:allow(core.ALEGame)
	private static function update()
	{
		if (songPosition < 0 || !allowUpdate)
			return;

		var newStep:Int = 0;

		if (bpmChangeMap == null)
		{
			newStep = Math.floor(songPosition / stepCrochet);
		} else {
			while (bpmChangeIndex + 1 < bpmChangeMap.length && songPosition >= bpmChangeMap[bpmChangeIndex + 1].time)
				bpmChangeIndex++;

			while (bpmChangeIndex >= 0 && songPosition < bpmChangeMap[bpmChangeIndex].time)
				bpmChangeIndex--;

			final change:BPMChange = bpmChangeMap[bpmChangeIndex];

			if (bpm != change.bpm)
				bpm = change.bpm;

			newStep = change.step + Math.floor((songPosition - change.time) / stepCrochet);
		}

		if (curStep != newStep)
		{
			curStep = newStep;
			
			stepHandler();
		}
	}

    @:unreflective static function stepHandler()
    {
        final prev:Int = safeStep;

        if (prev < curStep)
            for (i in 0...(curStep - safeStep))
                safeStepHit.dispatch(++safeStep);

        final newBeat:Int = Math.floor(curStep / stepsPerBeat);

        if (newBeat != curBeat)
        {
            curBeat = newBeat;

            beatHandler();
        }

        stepHit.dispatch(curStep);
    }

    @:unreflective static function beatHandler()
    {
        final prev:Int = safeBeat;

        if (prev < curBeat)
            for (i in 0...(curBeat - safeBeat))
                safeBeatHit.dispatch(++safeBeat);

        final newSection:Int = Math.floor(curBeat / beatsPerSection);

        if (newSection != curSection)
        {
            curSection = newSection;

            sectionHandler();
        }

        beatHit.dispatch(curBeat);
    }

    @:unreflective static function sectionHandler()
    {
        final prev:Int = safeSection;

        if (prev < curSection)
            for (i in 0...(curSection - prev))
                safeSectionHit.dispatch(++safeSection);

        sectionHit.dispatch(curSection);
    }
}