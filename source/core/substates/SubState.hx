package core.substates;

import flixel.FlxSubState;

class SubState extends FlxSubState
{
    public var subCamera:Camera;

    var allowCamerasConfig:Bool = true;

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