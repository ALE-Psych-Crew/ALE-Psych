package core.structures;

typedef JsonHud = {
    > JsonBase,
    directory:String,
    ratings:Array<JsonHudRating>,
    combo:JsonHudCombo,
    countdown:JsonHudCountdown,
    textFont:String,
    bar:String,
    barFilling:String
}