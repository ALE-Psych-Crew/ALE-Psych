package core.structures;

typedef JsonSpriteAnimation = {
    > JsonBase,
    name:String,
    ?frameRate:Int,
    ?loop:Bool,
    ?offset:Point,
    ?prefix:String,
    ?indices:Array<Int>,
    ?timeline:String,
    ?symbol:String,
    ?flipX:Bool,
    ?flipY:Bool
}