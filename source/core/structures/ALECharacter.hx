package core.structures;

typedef ALECharacter = {
    var animations:Array<ALECharacterAnimation>;
    var scale:Float;
    var animationLength:Float;
    var icon:String;
    var position:Point;
    var cameraPosition:Point;
    var textures:Array<String>;
    var flipX:Bool;
    var flipY:Bool;
    var antialiasing:Bool;
    var barColor:String;
    var death:String;
    var sustainAnimation:Bool;
    var format:String;
    var danceModulo:Int;
}