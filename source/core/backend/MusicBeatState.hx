package core.backend;

import core.structures.BPMChange;

import core.interfaces.IMusicState;

import utils.Song.SwagSong;

import flixel.addons.ui.FlxUIState;
import flixel.FlxState;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

class MusicBeatState extends FlxUIState implements IMusicState
{
	public static var instance:MusicBeatState;

	public var camGame:ALECamera;

	override function create()
	{
		MusicBeatState.instance = this;
		
		camGame = new ALECamera();
		
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camera, true);

        if (CoolVars.skipTransOut)
        {
            CoolVars.skipTransOut = false;
        } else {
            #if cpp
            CoolUtil.openSubState(new CustomSubState(
                CoolVars.data.transition,
                [false, null],
                [false],
				null,
                ['finishCallback' => null]
            ));
            #end
        }

		super.create();
	}

    public var shouldClearMemory:Bool = true;

	override function destroy()
	{
		MusicBeatState.instance = null;

        if (shouldClearMemory)
            cleanMemory();
        
		super.destroy();
	}

    function cleanMemory()
    {
        Paths.clearEngineCache();

        #if cpp
        var killZombies:Bool = true;
        
        while (killZombies)
		{
            var zombie = Gc.getNextZombie();
        
            if (zombie == null)
			{
                killZombies = false;
            } else {
                var closeMethod = Reflect.field(zombie, "close");
        
                if (closeMethod != null && Reflect.isFunction(closeMethod))
                    closeMethod.call(zombie, []);
            }
        }
        
        Gc.run(true);
        Gc.compact();
        #end

        #if hl
        Gc.major();
        #end
        
        FlxG.bitmap.clearUnused();
        FlxG.bitmap.clearCache();
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
