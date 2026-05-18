package core.states;

import flixel.FlxState;

import api.DesktopAPI;

class MainState extends FlxState
{
	override public function create()
	{
		super.create();

		Main.postResetConfig();

		FlxSprite.defaultAntialiasing = true;

		CoolUtil.switchState(new CustomState(CoolVars.meta.initialState), true, true);
	}
}