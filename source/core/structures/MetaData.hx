 package core.structures;

@:structInit
class MetaData
{
    public var developerMode:Bool = false;
    public var touchDebug:Bool = false;
    public var hotReloading:Bool = true;
    public var debugPrint:Bool = true;
    public var verbose:Bool = false;

    public var states:Any = {};
    public var substates:Any = {};

    public var loadDefaultWeeks:Bool = false;
    
    public var bpm:Float = 102;
    public var stepsPerBeat:Int = 4;
    public var beatsPerSection:Int = 4;

    public var discordID:String = '1309982575368077416';
    public var discordButtons:Array<{label:Null<String>, url:Null<String>}> = [
        {
            label: 'ALE Psych Website',
            url: 'https://ale-psych-crew.github.io/ALE-Psych-Site/'
        }
    ];

    public var title:String = 'Friday Night Funkin\': ALE Psych';
    public var icon:String = 'icon';

    public var color:String = '0xFF212121';
    public var width:Int = 1280;
    public var height:Int = 720;

    public var save:Null<String> = null;
}