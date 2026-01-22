package core.structures;

typedef ALEStageObject = {
    var id:String;
    @:optional var classPath:String;
    @:optional var classArguments:Array<Dynamic>;
    @:optional var path:String;
    @:optional var properties:Any;
    @:optional var addMethod:String;
    @:optional var highQuality:Bool;
}