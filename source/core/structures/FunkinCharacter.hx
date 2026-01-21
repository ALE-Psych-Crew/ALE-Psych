package core.structures;

typedef FunkinCharacter = {
    var renderType:String;
    var healthIcon:{id:String};
    @:optional var offsets:Array<Float>;
    @:optional var cameraOffsets:Array<Float>;
    var assetPath:String;
    var flipX:Bool;
    var animations:Array<FunkinCharacterAnimation>;
}