package core.structures;

import haxe.ds.StringMap;

typedef StageArray = {
    var objects:StringMap<FlxSprite>;
    var data:ALEStage;
    var id:String;
}