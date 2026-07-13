package core.states;

import core.interfaces.IState;

import flixel.FlxState;
import flixel.FlxBasic;

#if cpp
import cpp.vm.Gc;
#end

import core.Main;

import utils.Formatter;

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


    public var allowMemoryCleaning:Bool = true;

	override function destroy()
	{
		super.destroy();
        
        Paths.clear(allowMemoryCleaning);

        Formatter.clear();

        if (allowMemoryCleaning)
        {
            #if cpp
            Gc.run(true);
            Gc.compact();
            #end

            FlxG.bitmap.clearUnused();
            FlxG.bitmap.clearCache();
        }

        Main.touchPlugin?.destroyState();
	}

    
    public function addBehind(target:FlxBasic, obj:FlxBasic):FlxBasic
    {
        insert(members.indexOf(target), obj);

        return obj;
    }

    public function addAhead(target:FlxBasic, obj:FlxBasic):FlxBasic
    {
        insert(members.indexOf(target) + 1, obj);

        return obj;
    }

    public function addBehindGroup<T:FlxBasic>(group:FlxTypedGroup<T>, obj:FlxBasic):FlxBasic
        return addBehind(group.members[0], obj);

    public function addAheadGroup<T:FlxBasic>(group:FlxTypedGroup<T>, obj:FlxBasic):FlxBasic
        return addAhead(group.members[group.members.length - 1], obj);


    public function reset()
    {
        allowMemoryCleaning = false;

        FlxG.resetState();
    }
}