package core.structures;

import haxe.Constraints.Function;

@:structInit
class JsonData
{
    public var developerMode:Bool = true;
    public var hotReloading:Bool = true;
    public var title:String = 'Friday Night Funkin\': ALE Psych';
    public var windowColor:String = '0xFF212121';
    public var width:Int = 1280;
    public var height:Int = 720;
    public var verbose:Bool = true;
    public var initialState:String = 'TitleState';
}