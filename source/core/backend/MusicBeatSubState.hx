package core.backend;

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

	var bpmChangeMap:Null<Array<Float>>;

	public function calculateBPMChanges(?song:Null<SwagSong>)
	{
		bpmChangeMap = song == null ? null : [];

		_lastStep = 0;

		curStep = curBeat = curSection = -1;

		if (song == null)
			return;

		Conductor.bpm = song.bpm;

		for (sectionIndex => section in song.notes)
		{
			if (section.changeBPM)
				Conductor.bpm = section.bpm;

			for (i in 0...(Conductor.stepsPerBeat * Conductor.beatsPerSection))
				bpmChangeMap.push((bpmChangeMap[bpmChangeMap.length - 1] ?? 0) + Conductor.stepCrochet);
		}

		Conductor.bpm = song.bpm;
	}

    private var _lastStep:Int = 0;
    public var curStep:Int = -1;

    public var curBeat:Int = -1;

    public var curSection:Int = -1;

	public var shouldUpdateMusic:Bool = true;

	public function updateMusic()
	{
		if (!shouldUpdateMusic || FlxG.sound.music == null)
			return;

		if (bpmChangeMap == null)
		{
			_lastStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);
		} else {
			while (Conductor.songPosition > bpmChangeMap[_lastStep] ?? FlxG.sound.music.length)
				_lastStep++;

			while (Conductor.songPosition < bpmChangeMap[_lastStep - 1] ?? 0)
				_lastStep--;
		}
		
		if (_lastStep != curStep)
		{
			curStep = _lastStep;

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

		if (curStep % Conductor.stepsPerBeat == 0)
		{
			curBeat = Math.floor(curStep / Conductor.stepsPerBeat);

			beatHit();
		}
	}

	var lastSafeBeat:Int = 0;

	public function beatHit():Void
	{
		var prev:Int = lastSafeBeat;

		for (i in 0...(curBeat - prev))
			safeBeatHit(Math.floor(lastSafeBeat + 1));

		if (curBeat % Conductor.beatsPerSection == 0)
		{
			curSection = Math.floor(curBeat / Conductor.beatsPerSection);

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
