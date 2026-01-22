package core.backend;

import flixel.FlxSubState;

#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#end

class ALESubState extends FlxSubState
{
    public var subCamera:ALECamera;

    override function create()
    {
        super.create();
		
		FlxG.cameras.add(subCamera = new ALECamera(), false);
    }

	override function destroy()
	{
        FlxG.cameras.remove(subCamera, true);
        
		super.destroy();
	}
}