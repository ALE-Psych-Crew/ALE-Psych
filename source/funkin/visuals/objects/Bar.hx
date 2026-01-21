package funkin.visuals.objects;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class Bar extends FlxSpriteGroup
{
    public var percent(default, set):Null<Float>;
    function set_percent(value:Float):Null<Float>
    {
        value = FlxMath.bound(value, 0, 100);

        if (percent == value)
            return value;

        percent = value;

        var bgScale:Float = bg.width * percent / 100;

        var bgSpace:Float = bg.width - bgScale;

        leftBar.clipRect.x = rightToLeft ? bgSpace : 0;
        leftBar.clipRect.width = rightToLeft ? bgScale : bgSpace;

        rightBar.clipRect.x = rightToLeft ? 0 : bgSpace;
        rightBar.clipRect.width = rightToLeft ? bgSpace : bgScale;

        return percent;
    }

    public var bg:FlxSprite;
    public var leftBar:FlxSprite;
    public var rightBar:FlxSprite;

    public var rightToLeft(default, set):Bool;
    function set_rightToLeft(value:Bool)
    {
        if (rightToLeft == value)
            return value;

        rightToLeft = value;

        if (percent != null)
            percent = percent;
        
        return rightToLeft;
    }

    public function new(image:String, ?x:Float, ?y:Float, ?percent:Float, ?rightToLeft:Bool, ?leftColor:FlxColor, ?rightColor:FlxColor)
    {
        super(x, y);

        bg = new FlxSprite().loadGraphic(Paths.image(image));

        leftBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height));
        leftBar.color = leftColor ?? FlxColor.LIME;
        leftBar.clipRect = FlxRect.get(0, 0, leftBar.frameWidth, leftBar.frameHeight);
        add(leftBar);

        rightBar = new FlxSprite().makeGraphic(Std.int(bg.width), Std.int(bg.height));
        rightBar.color = rightColor ?? FlxColor.RED;
        rightBar.clipRect = FlxRect.get(0, 0, rightBar.frameWidth, rightBar.frameHeight);
        add(rightBar);

        add(bg);

        this.rightToLeft = rightToLeft ?? false;

        this.percent = percent ?? 50;
    }

    public function getMiddle():FlxPoint
    {
        return FlxPoint.get(x + (rightToLeft ? rightBar.clipRect.width : leftBar.clipRect.width), y + bg.height / 2);
    }
}