package core.states;

import flixel.FlxState;

import cpp.vm.Gc;

class State extends FlxState
{
    public var camGame:Camera;
    public var camHUD:Camera;

    public var updating(get, never):Bool;
    function get_updating():Bool
        return subState == null || persistentUpdate || FlxState.transitioning;

    override function create()
    {
        super.create();

		camGame = new Camera();
		
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
        
		camHUD = new Camera();
		
		FlxG.cameras.add(camHUD, false);
        
        if (CoolVars.skipTransOut)
        {
            CoolVars.skipTransOut = false;
        } else {
            CoolUtil.openSubState(new CustomSubState(
                CoolVars.meta.transition,
                [false, null]
            ));
        }
    }

	override function tryUpdate(elapsed:Float):Void
	{
		if (persistentUpdate || (subState == null || FlxState.transitioning))
			update(elapsed);

		if (_requestSubStateReset)
		{
			_requestSubStateReset = false;

			resetSubState();
		}

        if (subState != null)
            subState.tryUpdate(elapsed);
	}

	override function destroy()
	{
        Paths.clear(allowMemoryCleaning);

        if (allowMemoryCleaning)
            cleanMemory();
        
		super.destroy();
	}

    public function reset()
    {
        allowMemoryCleaning = false;

        FlxG.resetState();
    }

    public var allowMemoryCleaning:Bool = true;

    function cleanMemory()
    {
        Gc.run(true);
        Gc.compact();

        FlxG.bitmap.clearUnused();
        FlxG.bitmap.clearCache();
    }
}