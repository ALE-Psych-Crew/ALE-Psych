package core.structures;

typedef JsonSpriteAnimation = {
    > JsonBase,
    name:String,
    ?frameRate:Int,
    ?loop:Bool,
    ?offset:Point,
    ?prefix:String,
    ?indices:Array<Int>
}