package funkin.visuals.objects;

import haxe.ds.StringMap;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxAngle;

import animate.FlxAnimate;

import core.enums.SpriteType;

import core.structures.Point;

class FunkinSprite extends FlxAnimate
{
    public var offsets:StringMap<Point> = new StringMap();

    public function playAnim(animation:String, ?force:Bool)
    {
        anim.play(animation, force ?? true);

        applyOffset(getAnimOffset());
    }

    public function getAnimOffset():Point
    {
        return offsets.get(anim.name) ?? {x: 0, y: 0};
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

    public function addAnimation(type:SpriteType, name:String, ?prefix:String, ?fps:Int, ?loop:Bool, ?indices:Null<Array<Int>>)
    {
        switch (type)
        {
            case 'sheet':
                if (indices == null || indices.length <= 0)
                    animation.addByPrefix(name, prefix, fps, loop);
                else
                    animation.addByIndices(name, prefix, indices, '', fps, loop);

            case 'frames':
                animation.add(name, indices, fps, loop);

            case 'map':
                if (indices == null || indices.length <= 0)
                    anim.addByFrameLabel(name, prefix, fps, loop);
                else
                    anim.addByFrameLabelIndices(name, prefix, indices, fps, loop);

            default:
        }
    }

    public function loadFrames(type:SpriteType, ids:Array<String>, ?anims:Int)
    {
        switch (type)
        {
            case 'sheet':
                frames = Paths.getMultiAtlas(ids);
            case 'map':
                frames = Paths.getAnimateAtlas(ids[0]);
            case 'frames':
                final graphic:FlxGraphic = Paths.image(ids[0]);

                loadGraphic(graphic, true, Math.floor(graphic.width / anims));
        }
    }
}