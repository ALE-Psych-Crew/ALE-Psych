package core.states;

import api.DesktopAPI;

class MainState extends State
{
	override public function create()
	{
		super.create();

		Main.postResetConfig();

		DesktopAPI.setWindowTitle();
		
		DesktopAPI.setWindowBorderColor(33, 33, 33);

		add(new FlxSprite());
	}
}