package core;

import flixel.FlxState;

class MainState extends FlxState
{
	override public function create()
	{
		super.create();

		Main.postResetConfig();
	}
}