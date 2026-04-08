package core.backend;

import flixel.FlxSubState;

class SubState extends FlxSubState
{
    public var subCamera:Camera;

    override function create()
    {
        super.create();

        FlxG.stage.window.onTextInput.add(onTextInput);
		
		FlxG.cameras.add(subCamera = new Camera(), false);
    }

	override function destroy()
	{
        FlxG.stage.window.onTextInput.remove(onTextInput);
        
        FlxG.cameras.remove(subCamera, true);
        
		super.destroy();
	}

    public function onTextInput(text:String) {}
}