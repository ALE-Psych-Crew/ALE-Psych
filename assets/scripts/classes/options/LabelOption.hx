package options;

import options.BaseOption;

class LabelOption extends BaseOption
{
    public var labelBG:FlxSprite;

    public var secondText:Alphabet;

    public var labelString(default, set):String;
    function set_labelString(val:String):String
    {
        labelString = val;

        secondText.text = labelString;
        secondText.x = labelBG.x + labelBG.width / 2 - secondText.width / 2;
        secondText.y = labelBG.y + labelBG.height / 2 - secondText.height / 2 - 30;
        
        for (let in secondText)
            let.colorTransform.redOffset = let.colorTransform.greenOffset = let.colorTransform.blueOffset = 255;

        return labelString;
    }

    override public function new(data:OptionsOption)
    {
        super(data);    

        labelBG = roundSprite(FlxG.width * 0.35, 60, FlxColor.fromRGB(50, 50, 60));
        add(labelBG);
        labelBG.x = bg.x + bg.width - labelBG.width - 50;
        labelBG.y = bg.y + bg.height / 2 - labelBG.height / 2;

        secondText = new Alphabet(0, 0, '', false);
        add(secondText);
        secondText.scaleX = secondText.scaleY = 0.6;

        remove(cover, true);
        add(cover);    
    }

    function step(back:Bool) {}

    public var allowInputs:Bool = true;

    var isBack:Null<Bool> = null;

    var timer:Float = 0;

    override function update(elapsed:Float)
    {
        if (selected && allowInputs)
        {
            if (isBack != null)
            {
                if (((Controls.UI_LEFT_R || Controls.UI_RIGHT_P) && isBack) || ((Controls.UI_RIGHT_R || Controls.UI_LEFT_P) && !isBack))
                {
                    isBack = null;
                } else {
                    timer -= elapsed;

                    if (timer <= 0)
                    {
                        timer = 0.025;

                        step(isBack);
                    }
                }
            }

            if (isBack == null)
            {
                if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P)
                {
                    isBack = Controls.UI_LEFT_P;

                    step(isBack);

                    timer = 0.5;
                }
            }
        }

        super.update(elapsed);
    }
}