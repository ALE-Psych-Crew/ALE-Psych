package core.structures;

@:structInit
class PrintConfig
{
    public var verbose:Bool = false;
    public var allowTrace:Bool = true;
    public var allowPrint:Bool = true;
    public var title:String = '';
    public var color:FlxColor = FlxColor.GRAY;

    public function new(title:String = 'UNKNOWN', color:FlxColor = FlxColor.GRAY, verbose:Bool = false, allowTrace:Bool = true, allowPrint:Bool = true)
    {
        this.verbose = verbose;
        this.allowTrace = allowTrace;
        this.allowPrint = allowPrint;
        this.title = title;
        this.color = color;
    }
}