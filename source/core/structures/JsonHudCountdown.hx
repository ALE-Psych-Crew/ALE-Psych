package core.structures;

typedef JsonHudCountdown = {
    > JsonBase,
    ease:String,
    beats:Float,
    list:Array<String>,
    properties:Dynamic,
    start:AlphaScalePoint,
    end:AlphaScalePoint
}