package core.structures;

typedef JsonStrumLine = {
    > JsonBase,
    spacing:Float,
    strums:String,
    notes:String,
    splashes:String,
    config:Array<JsonStrumLineConfig>,
    properties:Any
}