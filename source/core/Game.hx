package core;

import flixel.util.typeLimit.NextState.InitialState;
import flixel.FlxGame;

import core.states.MainState;

import api.DesktopAPI;

class Game extends FlxGame
{
	override public function new()
	{
		super(1280, 720, MainState, 120, 120, true, false);
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