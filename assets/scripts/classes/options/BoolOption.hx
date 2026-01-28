package options;

import options.BaseOption;

class BoolOption extends BaseOption
{
    public var ballBG:FlxSprite;

    public var ball:FlxSprite;

    public var BALL_BG_COLOR:Array<FlxColor> = [FlxColor.fromRGB(40, 40, 50), FlxColor.fromRGB(50, 50, 75)];
    public var BALL_COLOR:Array<FlxColor> = [FlxColor.fromRGB(120, 120, 140), FlxColor.fromRGB(215, 215, 235)];

    override public function new(data:OptionsOption)
    {
        super(data);

        var objHeight:Float = bg.height * 0.65;

        ballBG = roundSprite(objHeight * 2, objHeight, BALL_BG_COLOR[0], 50);
        add(ballBG);
        ballBG.x = bg.width - ballBG.width * 1.2;
        ballBG.y = bg.height / 2 - ballBG.height / 2;

        ball = roundSprite(objHeight * 0.8, objHeight * 0.8, BALL_COLOR[0], objHeight * 0.8);
        add(ball);
        ball.x = ballBG.x + 10;
        ball.y = ballBG.y + ballBG.height / 2 - ball.height / 2;

        remove(cover, true);
        add(cover);

        setValue(getVarVal(), true);
    }

    var curValue:Bool = false;

    function setValue(value:Bool, ?skipTween:Bool)
    {
        for (obj in [ballBG, ball])
            FlxTween.cancelTweensOf(obj);

        curValue = setVarVal(value);

        if (skipTween ?? false)
        {
            ballBG.color = BALL_BG_COLOR[curValue ? 1 : 0];
            
            ball.x = ballBG.x + (curValue ? ballBG.width - ball.width - 10 : 10);
            ball.color = BALL_COLOR[curValue ? 1 : 0];
        } else {
            FlxTween.color(ballBG, 0.3, ballBG.color, BALL_BG_COLOR[curValue ? 1 : 0], {ease: FlxEase.cubeOut});
            FlxTween.color(ball, 0.3, ball.color, BALL_COLOR[curValue ? 1 : 0], {ease: FlxEase.cubeOut});
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (isOnScreen(FlxG.camera))
            ball.x = CoolUtil.fpsLerp(ball.x, ballBG.x + (curValue ? ballBG.width - ball.width - 10 : 10), 0.25);

        if (selected)
        {
            if (Controls.ACCEPT)
                setValue(!curValue);

            if (Controls.UI_LEFT_P && curValue)
                setValue(false);

            if (Controls.UI_RIGHT_P && !curValue)
                setValue(true);
        }
    }
}