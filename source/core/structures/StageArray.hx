package core.structures;

import haxe.ds.StringMap;

typedef StageArray = {
    var objects:StringMap<{object:FlxSprite, highQuality:Bool}>;
    var data:ALEStage;
    var id:String;
}