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

        FlxG.stage.window.onTextInput.add(onTextInput);
		
		camGame = new ALECamera();
		
		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
        
		camHUD = new ALECamera();
		
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
        final allowSubStateUpdate:Bool = subState != null;

		if (persistentUpdate || (subState == null || FlxState.transitioning))
			update(elapsed);

		if (_requestSubStateReset)
		{
			_requestSubStateReset = false;

			resetSubState();
		}

        if (subState != null && allowSubStateUpdate)
            subState.tryUpdate(elapsed);
	}

	override function destroy()
	{
        FlxG.stage.window.onTextInput.remove(onTextInput);
        
        if (shouldClearMemory)
            cleanMemory();
        
		super.destroy();
	}

    public function onTextInput(text:String) {}

    public var shouldClearMemory:Bool = true;

    function cleanMemory()
    {
        Paths.clear();

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