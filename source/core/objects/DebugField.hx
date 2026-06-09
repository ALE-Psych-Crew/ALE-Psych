package core.objects;

import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * This corresponds to each of the text boxes found in the `DebugTray`
 */
class DebugField extends GameObject
{
    /**
     * Displayed text
     */
    final label:TextField;

    /**
     * Function that determines the text to be displayed
     */
    public var textFunction:Void -> String;

    /**
     * This creates one of the fields in `DebugTray`
     * 
     * @param textFunction Function that determines the text to be displayed
     */
    public function new(?textFunction:Void -> String)
    {
        super();

        this.textFunction = textFunction ?? () -> '';

        label = new TextField();
        label.antiAliasType = ADVANCED;
        label.sharpness = 200;
        label.selectable = label.mouseEnabled = false;
        label.autoSize = LEFT;
        label.multiline = true;
        label.defaultTextFormat = new TextFormat(Paths.font('monsterrat.ttf'), 13, FlxColor.WHITE);
        label.x = 5;
        label.y = 5;

        add(label);

        showBG = true;

        updateField();
    }

    @:dox(hide)
    var currentWidth:Float = 0;

    @:dox(hide)
    var currentHeight:Float = 0;

    /**
     * Determines whether or not the box background should be displayed
     */
    public var showBG(default, set):Bool;
    @:dox(hide)
    function set_showBG(value:Bool):Bool
    {
        showBG = value;

        if (!showBG)
            graphics.clear();
        else
            updateField(true);

        return showBG;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        updateField();
    }

    /**
     * This updates how the background should be drawn and how the text should be displayed
     * 
     * @param drawBG Determines whether or not the box background should be displayed
     */
    function updateField(?drawBG:Bool = false)
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
}