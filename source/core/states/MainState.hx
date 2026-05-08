package core.states;

import api.DesktopAPI;

class MainState extends State
{
	override public function create()
	{
		super.create();

		Main.postResetConfig();

		FlxSprite.defaultAntialiasing = true;

		CoolUtil.switchState(new CustomState(CoolVars.data.initialState));
	}
}