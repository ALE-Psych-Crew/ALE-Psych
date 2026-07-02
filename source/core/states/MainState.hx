package core.states;

import flixel.FlxState;

import api.DesktopAPI;

class MainState extends FlxState
{
	override public function create()
	{
		super.create();

		Main.postResetConfig();

		CoolUtil.switchState(CoolVars.meta.initialState, true, true);
	}
}