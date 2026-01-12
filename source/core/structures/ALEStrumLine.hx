package core.structures;

typedef ALEStrumLine = {
    var position:Point;
    var splashScale:Float;
    var strumScale:Float;
    var noteScale:Float;
    var space:Float;
    var splashTextures:Array<String>;
    var strumTextures:Array<String>;
    var noteTextures:Array<String>;
    var splashFramerate:Int;
    var strumFramerate:Int;
    var noteFramerate:Int;
    var strums:Array<ALEStrum>;
}