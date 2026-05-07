package core;

import flixel.util.typeLimit.NextState.InitialState;
import flixel.FlxGame;

import api.DesktopAPI;

class FunkinGame extends FlxGame
{
	override public function new(initial:InitialState)
	{
		super(1280, 720, initial, 120, 120, true, false);
	}
	
	@:unreflective
	var visibleConsole:Bool = false;

	override public function update()
	{
		DesktopAPI.setWindowTitle();

		super.update();

		#if ALLOW_WINDOWS_API
		if (FlxG.keys.justPressed.F2)
		{
			if (!visibleConsole)
				DesktopAPI.showConsole();

			visibleConsole = true;
		}
		#end
	}
}