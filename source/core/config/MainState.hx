package core.config;

import funkin.substates.ModsMenuSubState;

import funkin.states.AdminState;

import flixel.FlxState;

import api.DesktopAPI;

import core.Main;

class MainState extends FlxState
{
    @:unreflective static var showedModMenu:Bool = #if mobile false #else true #end;

    override public function create()
    {
        super.create();

        Main.postResetConfig();
        
		FlxTimer.wait(0.0001, () -> {
            if (DesktopAPI.isRunningAsAdministrator() && !DesktopAPI.isRunningInWine())
            {
                CoolUtil.switchState(new AdminState());
            } else if (showedModMenu) {
                CoolUtil.switchState(new CustomState(CoolVars.data.initialState), true, true);
            } else {
                showedModMenu = true;

                CoolUtil.openSubState(new ModsMenuSubState());
            }
        });
    }
}