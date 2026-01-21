package core.config;

import funkin.states.PlayState;

import core.backend.ALEState;

import core.Main;

class MainState extends ALEState
{
    override public function create()
    {
        super.create();

        Main.postResetConfig();

        FlxG.switchState(new PlayState());
    }
}