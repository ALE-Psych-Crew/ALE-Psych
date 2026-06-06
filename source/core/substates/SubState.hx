package core.substates;

import core.interfaces.IState;

import flixel.FlxSubState;

class SubState extends FlxSubState implements IState
{
    public var subCamera:Camera;

    var allowCamerasConfig:Bool = true;

    public var updating(get, never):Bool;
    function get_updating():Bool
        return persistentUpdate || subState == null;

    override function create()
    {
        super.create();

        if (allowCamerasConfig)
            initCameras();
    }

    function initCameras()
    {
        subCamera = new Camera();

		FlxG.cameras.add(subCamera, false);
    }

	override function destroy()
	{
        FlxG.cameras.remove(subCamera, true);
        
		super.destroy();
	}
}