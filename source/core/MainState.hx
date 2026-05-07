package core;

import flixel.FlxState;

import api.DesktopAPI;

class MainState extends FlxState
{
	override public function create()
	{
		super.create();

		Main.postResetConfig();

		DesktopAPI.setWindowTitle();
		
		DesktopAPI.setWindowBorderColor(33, 33, 33);
	}
}