package core.structures;

typedef JsonWeek = {
    > JsonBase,

    songs:Array<JsonWeekSong>,

    background:String,

    image:String,

    phrase:String,

    locked:Bool,

    hideStoryMode:Bool,
    hideFreeplay:Bool,

    previousWeek:String,

    difficulties:Array<String>
}