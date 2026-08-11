package core.structures;

typedef JsonStageGroup = {
    > JsonStageObject,
    ?sprites:Array<JsonStageSprite>,
    ?properties:Dynamic,
}