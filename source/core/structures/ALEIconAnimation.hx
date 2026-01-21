package core.structures;

typedef ALEIconAnimation = {
    var percent:Float;
    var name:String;
    @:optional var prefix:String;
    @:optional var indices:Array<Int>;
    var framerate:Int;
    var loop:Bool;
}