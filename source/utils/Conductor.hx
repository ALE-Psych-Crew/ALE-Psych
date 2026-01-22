package utils;

import core.structures.ALESong;
import core.structures.BPMChange;

import flixel.util.FlxSignal.FlxTypedSignal;

@:access(core.backend.MusicBeatState)
class Conductor
{
	public static var offset:Float = 0;
	
	public static var songPosition:Float = -1;

	public static var stepsPerBeat:Int = 4;
	public static var beatsPerSection:Int = 4;

	public static var bpm:Float = 100;

	public static var crochet(get, never):Float;
	static function get_crochet():Float
		return 60000 / bpm;

	public static var stepCrochet(get, never):Float;
	static function get_stepCrochet():Float
		return crochet / stepsPerBeat;

	public static var sectionCrochet(get, never):Float;
	static function get_sectionCrochet():Float
		return crochet * beatsPerSection;

	public static var curStep:Int = -1;
	public static var stepHit:FlxTypedSignal<Int -> Void>;
	public static var safeStep:Int = -1;
	public static var safeStepHit:FlxTypedSignal<Int -> Void>;

	public static var curBeat:Int = -1;
	public static var beatHit:FlxTypedSignal<Int -> Void>;
	public static var safeBeat:Int = -1;
	public static var safeBeatHit:FlxTypedSignal<Int -> Void>;

	public static var curSection:Int = -1;
	public static var sectionHit:FlxTypedSignal<Int -> Void>;
	public static var safeSection:Int = -1;
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
		songPosition = -1;

		curStep = curBeat = curSection = safeStep = safeBeat = safeSection = -1;
		
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

		var newStep:Int = -1;

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

		for (i in 0...(curStep - prev))
		{
			safeStep++;

			safeStepHit.dispatch(safeStep);
		}

		final newBeat:Int = Math.floor(curStep / stepsPerBeat);

		if (curBeat != newBeat)
		{
			curBeat = newBeat;

			beatHandler();
		}

		stepHit.dispatch(curStep);
	}

	@:unreflective static function beatHandler()
	{
		final prev:Int = safeBeat;

		for (i in 0...(curBeat - prev))
		{
			safeBeat++;

			safeBeatHit.dispatch(safeBeat);
		}

		final newSection:Int = Math.floor(curBeat / beatsPerSection);

		if (curSection != newSection)
		{
			curSection = newSection;

			sectionHandler();
		}

		beatHit.dispatch(curBeat);
	}

	@:unreflective static function sectionHandler()
	{
		final prev:Int = safeSection;

		for (i in 0...(curSection - prev))
		{
			safeSection++;

			safeSectionHit.dispatch(safeSection);
		}

		sectionHit.dispatch(curSection);
	}
}