package core.config;

import funkin.states.PlayState;

import flixel.FlxState;

import core.Main;

class MainState extends FlxState
{
    override public function create()
    {
        super.create();

        Main.postResetConfig();
        
		CoolUtil.switchState(new CustomState(CoolVars.data.initialState), true, true);
    }
}