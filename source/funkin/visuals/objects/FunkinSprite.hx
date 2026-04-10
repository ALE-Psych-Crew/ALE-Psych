package funkin.visuals.objects;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxAngle;

import utils.cool.SpriteUtil;

import animate.FlxAnimate;

import core.structures.JsonSpriteAnimation;
import core.structures.JsonSprite;
import core.structures.Point;

import core.enums.SpriteType;

class FunkinSprite extends FlxAnimate
{
    public var offsets:Map<String, Point> = new Map();

    public var allowUpdateHitboxOffset:Bool = false;

    override public function updateHitbox()
    {
        super.updateHitbox();

        if (allowUpdateHitboxOffset && allowOffset)
            applyOffset();
    }

    public function playAnim(name:Null<String>, ?force:Bool = true)
    {
        if (name == null || !anim.getNameList().contains(name) || (anim.curAnim == null ? false : anim.name == name && anim.curAnim.looped))
            return;

        anim.play(name, force ?? true);

        applyOffset(getAnimOffset());
    }

    public function getAnimOffset():Point
        return offsets.get(anim.name) ?? {x: null, y: null};

    var lastScaleX:Float = 1;
    var lastScaleY:Float = 1;
    var lastAngle:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (!allowUpdateOffset || !allowOffset)
            return;

        if (scale.x != lastScaleX || scale.y != lastScaleY || angle != lastAngle)
        {
            lastScaleX = scale.x;
            lastScaleY = scale.y;

            lastAngle = angle;

            applyOffset();
        }
    }

    public var allowOffset:Bool = true;
    public var allowOffsetX:Bool = true;
    public var allowOffsetY:Bool = true;

    public var allowUpdateOffset:Bool = true;

    public var allowScaleFix:Bool = true;
    public var allowScaleXFix:Bool = true;
    public var allowScaleYFix:Bool = true;

    public var allowAngleFix:Bool = true;

    public function applyOffset(?base:Point)
    {
        if (!allowOffset)
            return;

        base ??= getAnimOffset();

        var sx:Float = base.x ?? 0;
        var sy:Float = base.y ?? 0;

        if (allowScaleFix)
        {
            if (allowScaleXFix)
                sx *= scale.x;

            if (allowScaleYFix)
                sy *= scale.y;
        }

        if (allowAngleFix && angle != 0)
        {
            final rad:Float = angle * FlxAngle.TO_RAD;

            final cos = Math.cos(rad);
            final sin = Math.sin(rad);

            sy = sx * sin + sy * cos;
            sx = sx * cos - sy * sin;
        }
        
        if (allowOffsetX && base.x != null)
            offset.x = sx;

        if (allowOffsetY && base.y != null)
            offset.y = sy;
    }

    public var config:JsonSprite;

    public var pathPrefix:String;

    public function fromJson(json:JsonSprite)
        SpriteUtil.spriteFromJson(this, json, pathPrefix);

    public function loadFrames(type:SpriteType, images:Array<String>, ?framesNum:Int)
        SpriteUtil.loadSpriteFrames(this, type, images, framesNum);

    public function addAnim(type:SpriteType, animData:JsonSpriteAnimation)
        SpriteUtil.addSpriteAnim(this, type, animData);
}