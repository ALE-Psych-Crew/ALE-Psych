package core.structures;

typedef JsonStageSpritesConfig = {
    > JsonBase,
    directory:String,
    properties:Dynamic,
    sprites:Array<JsonStageObject>
}