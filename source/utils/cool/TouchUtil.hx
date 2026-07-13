package utils.cool;

import flixel.input.keyboard.FlxKey;

import core.Main;

class TouchUtil
{
    public static function createTouchButtons(buttonsData:Array<{label:String, keys:Array<FlxKey>}>, ?x:Float = 0, ?y:Float = 0, ?angle:Float = 0, ?radius:Float = 100)
    {
        if (!CoolVars.touch)
            return;

        Main.touchPlugin.createButtons(buttonsData, x, y, angle, radius);
    }
}