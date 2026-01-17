package funkin.visuals.objects;

import haxe.ds.StringMap;

import flixel.math.FlxAngle;

import core.structures.Point;

class FunkinSprite extends FlxSprite
{
    public var offsets:StringMap<Point> = new StringMap();

    public function playAnim(anim:String, ?force:Bool)
    {
        animation.play(anim, force ?? true);

        applyOffset(getAnimOffset());
    }

    public function getAnimOffset():Point
    {
        return offsets.get(animation.name) ?? {x: 0, y: 0};
    }

    var lastScaleX:Float = 1;
    var lastScaleY:Float = 1;
    var lastAngle:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (scale.x != lastScaleX || scale.y != lastScaleY || angle != lastAngle)
        {
            lastScaleX = scale.x;
            lastScaleY = scale.y;

            lastAngle = angle;

            applyOffset();
        }
    }

    public function applyOffset(?base:Point)
    {
        base ??= getAnimOffset();

        var sx:Float = base.x * scale.x;
        var sy:Float = base.y * scale.y;

        var cos:Float = 1;
        var sin:Float = 0;

        if (angle != 0)
        {
            var rad:Float = angle * FlxAngle.TO_RAD;

            cos = Math.cos(rad);
            sin = Math.sin(rad);

            var tx:Float = sx * cos - sy * sin;

            sy = sx * sin + sy * cos;
            sx = tx;
        }

        offset.set(sx, sy);
    }
}