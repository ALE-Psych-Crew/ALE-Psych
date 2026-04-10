package core.structures;

import core.enums.SpriteType;

typedef JsonSprite = {
    > JsonBase,
    images:Array<String>,
    type:SpriteType,
    animations:Array<JsonSpriteAnimation>,
    properties:Dynamic,
    ?frames:Int
}