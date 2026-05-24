package core.structures;

typedef JsonIcon = {
    > JsonSprite,
    bopScale:Point,
    bopModulo:Int,
    speed:Float,
    healthAnimations:Array<JsonIconHealthAnimation>
}