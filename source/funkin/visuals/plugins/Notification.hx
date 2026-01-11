package funkin.visuals.plugins;

import flixel.tweens.FlxEase.EaseFunction;

import ale.ui.ALEUIUtils;
import ale.ui.ALETab;

class Notification extends ALETab
{
    public var finishCallback:Void -> Void;

    public var text:FlxText;

    public final moveTime:Float;
    public final waitTime:Float;

    public final inEase:EaseFunction;
    public final outEase:EaseFunction;

    public var target:Float;

    public function new(title:String, content:String, ?moveTime:Float = 1, ?waitTime:Float = 2, ?inEase:EaseFunction, ?outEase:EaseFunction)
    {
        this.moveTime = moveTime;
        this.waitTime = waitTime;

        this.inEase = inEase ?? FlxEase.expoOut;
        this.outEase = outEase ?? FlxEase.expoIn;

        text = new FlxText(15, 15, 0, content, 15);
        text.font = ALEUIUtils.FONT;

        if (text.width > FlxG.width * 0.35)
            text.fieldWidth = FlxG.width * 0.35;
        
        super(FlxG.width, 0, text.width + 30, text.height + 30, title, false);
        
        y = target = FlxG.height - height - 30 + ALEUIUtils.OBJECT_SIZE;

        alpha = 0;

        add(text);
    }

    var time:Float = 0;

    var state:Int = 0x01;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        time += elapsed;

        switch (state)
        {
            case 0x01:
                var t:Float = Math.min(time / moveTime, 1);

                var eased:Float = inEase(t);

                x = FlxMath.lerp(FlxG.width, FlxG.width - width - 30, eased);

                alpha = eased;

                if (t >= 1)
                {
                    state = 0x10;

                    time = 0;
                }

            case 0x10:
                if (time >= waitTime)
                {
                    state = 0x11;

                    time = 0;
                }

            case 0x11:
                var t:Float = Math.min(time / moveTime, 1);

                var eased:Float = outEase(t);

                x = FlxMath.lerp(FlxG.width - width - 30, FlxG.width, eased);

                alpha = 1 - eased;

                if (t >= 1)
                {
                    state = 0x0;

                    if (finishCallback != null)
                        finishCallback();
                }

            default:
        }

        y = FlxMath.lerp(y, target, 0.3);
    }
}