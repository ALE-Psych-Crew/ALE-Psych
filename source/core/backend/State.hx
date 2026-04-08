package core.backend;

import flixel.FlxState;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

import api.MobileAPI;

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

        MobileAPI.controls?.update(FlxG.elapsed);

        if (subState != null)
            subState.tryUpdate(elapsed);
	}

	override function destroy()
	{
        Paths.clear(shouldClearMemory);

        if (shouldClearMemory)
            cleanMemory();
        
		super.destroy();
	}

    public var shouldClearMemory:Bool = true;

    function cleanMemory()
    {
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
}