package core.backend;

import flixel.addons.ui.FlxUIState;
import flixel.FlxState;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

class MusicBeatState extends FlxUIState
{
	var curSection:Int = 0;
	var curStep:Int = 0;
	var curBeat:Int = 0;

	public static var instance:MusicBeatState;

	var stepsToDo:Int = 0;

	var curDecStep:Float = 0;
	var curDecBeat:Float = 0;

	var _psychCameraInitialized:Bool = false;

	override function create()
	{
		if (!_psychCameraInitialized)
			initPsychCamera();

		MusicBeatState.instance = this;

        if (CoolVars.skipTransOut)
        {
            CoolVars.skipTransOut = false;
        } else {
            #if cpp
            CoolUtil.openSubState(new CustomSubState(
                CoolVars.data.transition,
                null,
                [
                    'transIn' => false,
                    'transOut' => true,
                    'finishCallback' => null
                ],
                [
                    'transIn' => false,
                    'transOut' => true,
                    'finishCallback' => null
                ]
            ));
            #end
        }

		super.create();

		timePassedOnState = 0;
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

	public function initPsychCamera():ALECamera
	{
		var camera = new ALECamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		//trace('initialized psych camera ' + Sys.cpuTime());
		return camera;
	}

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

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

	function updateSection():Void
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

	function rollbackSection():Void
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

	function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - ClientPrefs.data.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public static function getState():MusicBeatState {
		return cast (FlxG.state, MusicBeatState);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void {}

	public function sectionHit():Void {}

	function getBeatsOnSection()
	{
		var val:Null<Float> = 4;
		if(PlayState.SONG != null && PlayState.SONG.notes[curSection] != null) val = PlayState.SONG.notes[curSection].sectionBeats;
		return val == null ? 4 : val;
	}
}
