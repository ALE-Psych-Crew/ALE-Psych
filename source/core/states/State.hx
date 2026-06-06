package core.states;

import core.interfaces.IState;

import flixel.FlxState;

import cpp.vm.Gc;

class State extends FlxState implements IState
{
    public var camGame:Camera;
    public var camHUD:Camera;

    public var updating(get, never):Bool;
    function get_updating():Bool
        return subState == null || persistentUpdate || FlxState.transitioning;

    var allowCamerasConfig:Bool = true;

    override function create()
    {
        super.create();

        if (allowCamerasConfig)
            initCameras();
        
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

    function initCameras()
    {
		camGame = new Camera();
		
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
        
		camHUD = new Camera();
		
		FlxG.cameras.add(camHUD, false);
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