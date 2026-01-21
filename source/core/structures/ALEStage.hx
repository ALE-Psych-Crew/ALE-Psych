package core.structures;

typedef ALEStage = {
    var hud:String;
    @:optional var speed:Float;
    @:optional var zoom:Float;
    @:optional var ui:String;
    @:optional var characterOffset:ALEStageOffset;
    @:optional var cameraOffset:ALEStageOffset;
    @:optional var objectsConfig:ALEStageObjectsConfig;
}