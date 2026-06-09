package core.states;

import core.interfaces.IState;

import flixel.FlxState;

#if cpp
import cpp.vm.Gc;
#end

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
        #if cpp
        Gc.run(true);
        Gc.compact();
        #end

        FlxG.bitmap.clearUnused();
        FlxG.bitmap.clearCache();
    }
}