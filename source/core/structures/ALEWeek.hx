package core.structures;

typedef ALEWeek = {
    var songs:Array<ALEWeekSong>;

    var characters:Array<String>;

    var background:String;

    var image:String;

    var phrase:String;

    var locked:Bool;

    var hideStoryMode:Bool;
    var hideFreeplay:Bool;
    
    var format:String;

    var difficulties:Array<String>;
}