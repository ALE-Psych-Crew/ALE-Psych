package core.structures;

@:structInit
class PrintConfig
{
    public var verbose:Bool = false;
    public var allowTrace:Bool = true;
    public var allowPrint:Bool = true;
    public var title:String = 'UNKNOWN';
    public var color:FlxColor = FlxColor.GRAY;
}