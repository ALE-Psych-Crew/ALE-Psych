package core.backend;

import flixel.FlxState;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

class ALEState extends FlxState
{
    public var camGame:ALECamera;
    public var camHUD:ALECamera;

    override function create()
    {
        super.create();
		
		camGame = new ALECamera();
		
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
        
		camHUD = new ALECamera();
		
		FlxG.cameras.add(camHUD, false);
    }

	override function destroy()
	{
        if (shouldClearMemory)
            cleanMemory();
        
		super.destroy();
	}

    public var shouldClearMemory:Bool = true;

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
}