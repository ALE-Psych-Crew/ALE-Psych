package core.substates;

import flixel.FlxSubState;

class SubState extends FlxSubState
{
    public var subCamera:Camera;

    override function create()
    {
        super.create();
		
		FlxG.cameras.add(subCamera = new Camera(), false);
    }

	override function destroy()
	{
        FlxG.cameras.remove(subCamera, true);
        
		super.destroy();
	}
}