package core.structures;

import haxe.ds.StringMap;

import core.enums.Quality;

typedef StageArray = {
    var objects:StringMap<{object:FlxSprite, quality:Quality}>;
    var config:JsonStage;
    var id:String;
}