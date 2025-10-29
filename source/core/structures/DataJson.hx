package core.structures;

typedef DataJson =
{
    var developerMode:Bool;
    var mobileDebug:Bool;
    var scriptsHotReloading:Bool;

    var verbose:Bool;

    var initialState:String;
    var freeplayState:String;
    var storyMenuState:String;
    var masterEditorState:String;
    var mainMenuState:String;

    var pauseSubState:String;
    var gameOverScreen:String;
    var transition:String;

    var loadDefaultWeeks:Bool;

    var title:String;
    var icon:String;
    var width:Int;
    var height:Int;

    var bpm:Float;

    var discordID:String;
}