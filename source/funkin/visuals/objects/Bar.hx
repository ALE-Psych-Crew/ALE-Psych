package funkin.visuals.objects;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

import core.enums.Orientation;

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

    public var orientation(default, set):Orientation;
    function set_orientation(val:Orientation):Orientation
    {
        percent = percent;

        return orientation = val;
    }

    public var percent(default, set):Float;
    function set_percent(value:Float):Float
    {
        value = FlxMath.bound(value, 0, 100);

        fillingFront.clipRect ??= FlxRect.get();

        if (orientation == HORIZONTAL)
        {
            final factor:Float = fillingFront.width * (value / 100);

            fillingFront.clipRect.set(leftToRight ? 0 : fillingFront.width - factor, 0, leftToRight ? factor : fillingFront.width, fillingFront.height);
        } else {
            final factor:Float = fillingFront.height * (value / 100);

            fillingFront.clipRect.set(0, leftToRight ? factor : 0, fillingFront.width, leftToRight ? fillingFront.height : factor);
        }

        return percent = value;
    }

    public function new(main:String, filling:String, ?leftToRight:Bool, ?percent:Float, ?orientation:Orientation)
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
        this.orientation = orientation ?? Orientation.HORIZONTAL;
    }

    public function getMiddle():FlxPoint
        if (orientation == HORIZONTAL)
            return FlxPoint.get(fillingFront.x + (leftToRight ? fillingFront.clipRect.width : fillingFront.clipRect.x), fillingFront.y + fillingFront.height / 2);
        else
            return FlxPoint.get(fillingFront.x + fillingFront.width / 2, fillingFront.y + (leftToRight ? fillingFront.clipRect.y : fillingFront.clipRect.height));
}