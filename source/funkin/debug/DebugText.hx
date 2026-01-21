package funkin.debug;

import openfl.text.TextField;

class DebugText extends TextField
{
    public var valueFunction:Void -> Dynamic;

    override public function new(func:Void -> Dynamic)
    {
        super();

        valueFunction = func;

		selectable = false;
		mouseEnabled = false;
        autoSize = LEFT;
        multiline = true;
        
        text = valueFunction();
    }

    override function __enterFrame(time:Int)
    {
        super.__enterFrame(time);

        text = valueFunction();
    }
}