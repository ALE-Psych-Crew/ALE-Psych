package core;

import flixel.FlxGame;

import flixel.util.typeLimit.NextState.InitialState;

import cpp.WindowsAPI;

class ALEGame extends FlxGame
{
    override public function new(width:Int, height:Int, initial:InitialState, framerate:Int)
    {
        super(width, height, initial, framerate, framerate, true, false);
    }

    override public function update()
    {
        WindowsAPI.setWindowTitle();

        super.update();
    }
}