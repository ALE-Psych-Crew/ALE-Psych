package funkin.debug;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

class DebugField extends Sprite
{
    final label:TextField;

    public var textFunction:Void -> String;

    public function new(?textFunction:Void -> String)
    {
        super();

        this.textFunction = textFunction ?? () -> '';

        label = new TextField();
        label.selectable = label.mouseEnabled = false;
        label.autoSize = LEFT;
        label.multiline = true;
        label.defaultTextFormat = new TextFormat(Paths.font('monsterrat.ttf'), 13, FlxColor.WHITE);
        label.x = 5;
        label.y = 5;

        addChild(label);

        showBG = true;

        update();
    }

    var currentWidth:Float = 0;
    var currentHeight:Float = 0;

    public var showBG(default, set):Bool;
    function set_showBG(value:Bool):Bool
    {
        showBG = value;

        if (!showBG)
            graphics.clear();
        else
            update(true);

        return showBG;
    }

    public function update(?drawBG:Bool = false)
    {
        label.text = textFunction();

        if (label.width != currentWidth || label.height != currentHeight || drawBG)
        {
            currentWidth = label.width;
            currentHeight = label.height;

            if (showBG)
            {
                graphics.clear();
                graphics.lineStyle(2, FlxColor.WHITE, 0.5);
                graphics.beginFill(FlxColor.BLACK, 0.5);
                graphics.drawRect(0, 0, currentWidth + 10, currentHeight + 10);
                graphics.endFill();
            }
        }
    }

    public function destroy()
    {
        for (i in 0...numChildren)
        {
            final child = getChildAt(i);

            removeChild(child);
        }
        
        graphics.clear();
    }
}