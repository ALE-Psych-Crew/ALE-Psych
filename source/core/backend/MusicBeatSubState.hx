package core.backend;

import core.structures.BPMChange;

import core.interfaces.IMusicState;

import utils.Song.SwagSong;

import flixel.FlxSubState;

class MusicBeatSubState extends FlxSubState implements IMusicState
{
	public static var instance:MusicBeatSubState;

	override function create()
	{
		instance = this;

		super.create();
	}
	
	var bpmChangeMap:Null<Array<BPMChange>>;

	public function calculateBPMChanges(?song:Null<SwagSong>)
	{
		if (song == null)
		{
			bpmChangeMap = null;

			return;
		}

		var curTime:Float = 0;
		var curStep:Int = 0;

		Conductor.bpm = song.bpm;
		
		bpmChangeMap = [
			{
				bpm: Conductor.bpm,
				time: 0,
				step: 0
			}
		];

		for (section in song.notes)
		{
			if (section.changeBPM && section.bpm != Conductor.bpm)
			{
				Conductor.bpm = section.bpm;

				bpmChangeMap.push(
					{
						bpm: Conductor.bpm,
						time: curTime,
						step: curStep
					}
				);
			}
			
			curTime += Conductor.sectionCrochet;
			curStep += Conductor.beatsPerSection * Conductor.stepsPerBeat;
		}

		Conductor.bpm = song.bpm;
	}

	var curBPMIndex:Int = 0;

    public var curStep:Int = -1;

    public var curBeat:Int = -1;

    public var curSection:Int = -1;

	public var shouldUpdateMusic:Bool = true;

	public function updateMusic()
	{
		if (!shouldUpdateMusic || FlxG.sound.music == null || Conductor.songPosition < 0)
			return;

		var newStep:Int = -1;

		if (bpmChangeMap == null)
		{
			newStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
		} else {
			while (curBPMIndex + 1 < bpmChangeMap.length && Conductor.songPosition >= bpmChangeMap[curBPMIndex + 1].time)
				curBPMIndex++;

			while (curBPMIndex > 0 && Conductor.songPosition < bpmChangeMap[curBPMIndex - 1].time)
				curBPMIndex--;

			var change:BPMChange = bpmChangeMap[curBPMIndex];

			if (Conductor.bpm != change.bpm)
				Conductor.bpm = change.bpm;

			newStep = change.step + Math.floor((Conductor.songPosition - change.time) / Conductor.stepCrochet);
		}

		if (curStep != newStep)
		{
			curStep = newStep;
			
			stepHit();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		updateMusic();
	}

	var lastSafeStep:Int = 0;

	public function stepHit():Void
	{
		var prev:Int = lastSafeStep;

		for (i in 0...(curStep - prev))
			safeStepHit(Math.floor(lastSafeStep + 1));

		var newBeat:Int = Math.floor(curStep / Conductor.stepsPerBeat);

		if (curBeat != newBeat)
		{
			curBeat = newBeat;

			beatHit();
		}
	}

	var lastSafeBeat:Int = 0;

	public function beatHit():Void
	{
		var prev:Int = lastSafeBeat;

		for (i in 0...(curBeat - prev))
			safeBeatHit(Math.floor(lastSafeBeat + 1));

		var newSection = Math.floor(curBeat / Conductor.beatsPerSection);

		if (curSection != newSection)
		{
			curSection = newSection;

			sectionHit();
		}
	}

	var lastSafeSection:Int = 0;

	public function sectionHit():Void
	{
		var prev:Int = lastSafeSection;

		for (i in 0...(curSection - prev))
			safeSectionHit(Math.floor(lastSafeSection + 1));
	}

	public function safeStepHit(safeStep:Int)
	{
		lastSafeStep = safeStep;
	}

	public function safeBeatHit(safeBeat:Int)
	{
		lastSafeBeat = safeBeat;
	}

	public function safeSectionHit(safeSection:Int)
	{
		lastSafeSection = safeSection;
	}
}
