package core.structures;

typedef ALESongSection = {
    var notes:Array<Array<Dynamic>>;

    var camera:Array<Int>;

    var bpm:Float;
    var changeBPM:Bool;

    var stepsPerBeat:Int;
    var beatsPerSection:Int;
    var changeTimeSignature:Bool;
}