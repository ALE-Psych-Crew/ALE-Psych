package core.structures;

import core.enums.SpriteType;

typedef JsonSprite = {
    > JsonBase,
    images:Array<String>,
    ?color:String,
    ?type:SpriteType,
    ?animations:Array<JsonSpriteAnimation>,
    ?properties:Dynamic,
    ?initialAnimation:String,
    ?frames:Int
}