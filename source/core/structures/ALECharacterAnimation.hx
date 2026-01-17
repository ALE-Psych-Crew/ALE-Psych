package core.structures;

typedef ALECharacterAnimation = {
    var prefix:String;
    var animation:String;
    var framerate:Int;
    var loop:Bool;
    var indices:Array<Int>;
    var offset:Point;
}