package core.substates;

import core.interfaces.IState;

import flixel.FlxSubState;
import flixel.FlxBasic;

import core.Main;

class SubState extends FlxSubState implements IState
{
    public var subCamera:Camera;

    var allowCamerasConfig:Bool = true;

    var allowCamerasOverriding:Bool = true;

    public var updating(get, never):Bool;
    function get_updating():Bool
        return persistentUpdate || subState == null;

    override function create()
    {
        super.create();

        Main.touchPlugin?.initSubState();

        if (allowCamerasConfig)
            initCameras();
    }

    function initCameras()
    {
        subCamera = new Camera();

		FlxG.cameras.add(subCamera, false);
    }

    override function add(obj:FlxBasic):FlxBasic
    {
        if (subCamera != null && allowCamerasOverriding)
            obj.camera = subCamera;

        return super.add(obj);
    }

	override function destroy()
	{
        FlxG.cameras.remove(subCamera, true);
        
		super.destroy();

        Main.touchPlugin?.destroySubState();
	}
}