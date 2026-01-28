package core;

import flixel.util.typeLimit.NextState.InitialState;

import flixel.FlxGame;

import cpp.WindowsAPI;

import core.backend.ALESoundTray;

import funkin.substates.ModsMenuSubState;

class ALEGame extends FlxGame
{
    override public function new(initial:InitialState)
    {
        super(1280, 720, initial, 120, 120, true, false);

        _customSoundTray = ALESoundTray;
    }

    @:unreflective var visibleConsole:Bool = false;

    override public function update()
    {
        WindowsAPI.setWindowTitle();

        super.update();

        Conductor.update();

        if (Controls.CONTROL && Controls.SHIFT)
        {
            if (FlxG.keys.anyJustPressed(ClientPrefs.controls.engine.reset_game))
                CoolUtil.resetGame();

            if (FlxG.keys.anyJustPressed(ClientPrefs.controls.engine.switch_mod))
            {
                if (FlxG.state.subState != null)
                    FlxG.state.subState.close();

                CoolUtil.openSubState(new funkin.substates.ModsMenuSubState());
            }
        }

        #if WINDOWS_API
        if (FlxG.keys.justPressed.F2)
        {
            if (!visibleConsole)
                cpp.WindowsAPI.showConsole();

            visibleConsole = true;
        }
        #end
    }
}