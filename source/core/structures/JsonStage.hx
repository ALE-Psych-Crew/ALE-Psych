package core.structures;

typedef JsonStage = {
    > JsonBase,
    zoom:Float,
    speed:Float,
    hud:String,
    charactersOffset:JsonStageCharactersModifier,
    charactersCamera:JsonStageCharactersModifier,
    ?spritesConfig:JsonStageSpritesConfig
}