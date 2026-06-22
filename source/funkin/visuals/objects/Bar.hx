package funkin.visuals.objects;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class Bar extends FlxSpriteGroup
{
    public final border:FlxSprite;
    public final fillingBack:FlxSprite;
    public final fillingFront:FlxSprite;

    public var leftToRight(default, set):Bool;
    function set_leftToRight(value:Bool):Bool
    {
        leftToRight = value;

        percent = percent;

        return leftToRight;
    }

    public var percent(default, set):Float;
    function set_percent(value:Float):Float
    {
        value = FlxMath.bound(value, 0, 100);

        fillingFront.clipRect ??= FlxRect.get();

        final factor:Float = fillingFront.width * (value / 100);

        fillingFront.clipRect.set(leftToRight ? 0 : fillingFront.width - factor, 0, leftToRight ? factor : fillingFront.width, fillingFront.height);

        return percent = value;
    }

    public function new(main:String, filling:String, ?leftToRight:Bool, ?percent:Float)
    {
        super();

        fillingBack = new FlxSprite(0, 0, Paths.image(filling));
        fillingBack.color = FlxColor.RED;
        add(fillingBack);

        fillingFront = new FlxSprite(0, 0, Paths.image(filling));
        fillingFront.color = FlxColor.LIME;
        add(fillingFront);

        border = new FlxSprite(0, 0, Paths.image(main));
        add(border);

        for (spr in [fillingFront, fillingBack])
        {
            spr.x = border.x + border.width / 2 - spr.width / 2;
            spr.y = border.y + border.height / 2 - spr.height / 2;
        }

        this.leftToRight = leftToRight ?? true;

        this.percent = percent ?? 50;
    }

    public function getMiddle():FlxPoint
        return FlxPoint.get(fillingFront.x + (leftToRight ? fillingFront.clipRect.width : fillingFront.clipRect.x), fillingFront.y + fillingFront.height / 2);
}