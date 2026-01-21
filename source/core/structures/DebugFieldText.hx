package core.structures;

import flixel.util.typeLimit.OneOfThree;
import flixel.util.FlxColor;

typedef DebugFieldText = {
    var lines:Array<DebugFieldTextLine>;
    @:optional var size:Int;
    @:optional var color:OneOfThree<FlxColor, Int, String>;
    @:optional var offset:Float;
}