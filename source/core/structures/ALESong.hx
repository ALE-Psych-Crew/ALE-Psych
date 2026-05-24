package core.structures;

typedef ALESong = {
    var events:Array<Array<Dynamic>>;
    var strumLines:Array<ALESongStrumLine>;
    var sections:Array<ALESongSection>;
    var format:String;
    var bpm:Float;
    var stepsPerBeat:Int;
    var beatsPerSection:Int;
    var speed:Float;
    var stage:String;
}