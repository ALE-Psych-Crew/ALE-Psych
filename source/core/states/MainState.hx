package core.states;

import api.DesktopAPI;

class MainState extends State
{
	override public function create()
	{
		super.create();

		Main.postResetConfig();

		CoolUtil.switchState(new CustomState(CoolVars.data.initialState));
	}
}