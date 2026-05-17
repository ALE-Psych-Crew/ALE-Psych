 package core.structures;

@:structInit
class MetaData
{
    public var developerMode:Bool = false;
    public var mobileMode:Bool = false;
    public var hotReloading:Bool = true;
    public var debugPrint:Bool = true;
    public var verbose:Bool = false;

    public var initialState:String = 'InitialState';

    public var titleState:String = 'TitleState';
    public var storyMenuState:String = 'StoryMenuState';
    public var freeplayState:String = 'FreeplayState';
    public var mainMenuState:String = 'MainMenuState';
    public var optionsState:String = 'OptionsState';
    public var masterState:String = 'MasterState';
    
    public var pauseSubState:String = 'PauseSubState';
    public var gameOverSubState:String = 'GameOverSubState';
    public var transition:String = 'FadeTransition';

    public var loadDefaultWeeks:Bool = false;
    public var bpm:Float = 100;

    public var discordID:String = '1309982575368077416';
    public var discordButtons:Array<{label:Null<String>, url:Null<String>}> = [
        {
            label: 'ALE Psych Website',
            url: 'https://ale-psych-crew.github.io/ALE-Psych-Site/'
        }
    ];

    public var title:String = 'Friday Night Funkin\': ALE Psych';
    public var windowColor:String = '0xFF212121';
    public var width:Int = 1280;
    public var height:Int = 720;

    public var save:Null<String> = null;
}