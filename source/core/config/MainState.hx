package core.config;

import funkin.substates.ModsMenuSubState;

import flixel.FlxState;

import core.Main;

class MainState extends FlxState
{
    @:unreflective static var showedModMenu:Bool = #if mobile false #else true #end;

    override public function create()
    {
        super.create();

        Main.postResetConfig();
        
		FlxTimer.wait(0.0001, () -> {
            if (showedModMenu)
            {
                CoolUtil.switchState(new CustomState(CoolVars.data.initialState), true, true);
            } else {
                showedModMenu = true;

                CoolUtil.openSubState(new ModsMenuSubState());
            }
        });
    }
}