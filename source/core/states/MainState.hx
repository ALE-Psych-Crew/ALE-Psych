package core.states;

import funkin.substates.ModsMenuSubState;

import flixel.FlxState;

import api.DesktopAPI;

class MainState extends FlxState
{
    @:unreflective static var showedModMenu(default, null):Bool = #if FORCE_TOUCH false #else true #end;

	override public function create()
	{
		super.create();

		Main.postResetConfig();

		if (showedModMenu)
		{
			CoolUtil.switchState(CoolVars.meta.initialState, true, true);
		} else {
			showedModMenu = true;

			CoolUtil.openSubState(new ModsMenuSubState());
		}
	}
}