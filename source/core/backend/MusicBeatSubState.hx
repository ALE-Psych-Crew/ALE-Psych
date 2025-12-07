package core.backend;

import flixel.FlxSubState;

class MusicBeatSubState extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;

	override function update(elapsed:Float)
	{
		//everyStep();
		if(!persistentUpdate) MusicBeatState.timePassedOnState += elapsed;
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	var lastSafeStep:Int = 0;

	public function stepHit():Void
	{
		var prev:Int = lastSafeStep;

		for (i in 0...(curStep - prev))
			safeStepHit(Math.floor(lastSafeStep + 1));

		if (curStep % 4 == 0)
			beatHit();
	}

	var lastSafeBeat:Int = 0;

	public function beatHit():Void
	{
		var prev:Int = lastSafeBeat;

		for (i in 0...(curBeat - prev))
			safeBeatHit(Math.floor(lastSafeBeat + 1));
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
	
	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
