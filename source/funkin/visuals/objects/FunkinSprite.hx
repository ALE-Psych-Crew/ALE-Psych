package funkin.visuals.objects;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxAngle;
import flixel.FlxObject;

import utils.cool.SpriteUtil;

import animate.FlxAnimateController;
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
        if (!shouldPlayAnim(name))
            return;

        anim.play(name, force ?? true);

        applyOffset(getAnimOffset());
    }

    public function shouldPlayAnim(name:Null<String>):Bool
        return anim != null && name != null && anim.getNameList().contains(name) && !(anim.curAnim != null && anim.name == name && anim.curAnim.looped);

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

    public function fromJson(json:JsonSprite, ?imageDirectory:String):FunkinSprite
    {
        SpriteUtil.spriteFromJson(this, json, imageDirectory ?? pathPrefix);

        return this;
    }

    public function loadFrames(type:SpriteType, images:Array<String>, ?framesNum:Int):FunkinSprite
    {
        SpriteUtil.loadSpriteFrames(this, type, images, framesNum);

        return this;
    }

    public function addAnim(type:SpriteType, animData:JsonSpriteAnimation):FunkinSprite
    {
        SpriteUtil.addSpriteAnim(this, type, animData);
        
        return this;
    }

    public function restart():FunkinSprite
    {
        // FlxBasic

        active = true;
        visible = true;
        alive = true;
        exists = true;

        _cameras = null;

        // FlxObject

        x = 0;
        y = 0;

        width = 0;
        height = 0;

        last.set();

        scrollFactor.set(1, 1);

        pixelPerfectPosition = FlxObject.defaultPixelPerfectPosition;

        velocity.set();
        acceleration.set();
        drag.set();

        maxVelocity.set(10000, 10000);

        moves = FlxObject.defaultMoves;

        immovable = false;

        angle = 0;

        angularVelocity = 0;
        angularAcceleration = 0;
        angularDrag = 0;
        maxAngular = 0;

        touching = NONE;
        wasTouching = NONE;

        path = null;

        // FlxSprite

        loadGraphic('flixel/NO_IMAGE.png');

        // animation?.destroy();
        // animation = new FlxAnimationController(this);

        offset.set();
        origin.set();
        scale.set(1, 1);

        alpha = 1;

        color = FlxColor.WHITE;

        flipX = false;
        flipY = false;

        blend = null;
        shader = null;
        clipRect = null;

        antialiasing = FlxSprite.defaultAntialiasing;

        bakedRotationAngle = 0;

        dirty = true;

        // FlxAnimate

        anim?.destroy();
        anim = new FlxAnimateController(this);
        
        animation = anim;

        skew.set();

        library = null;
        timeline = null;

        isAnimate = false;

        applyStageMatrix = false;
        postStageMatrixApply = false;

        renderStage = false;
        useRenderTexture = false;

        _renderTextureDirty = true;

        // FunkinSprite

        offsets = new Map();

        allowUpdateHitboxOffset = false;

        lastScaleX = 1;
        lastScaleY = 1;
        lastAngle = 0;

        allowOffset = true;
        allowOffsetX = true;
        allowOffsetY = true;

        allowUpdateOffset = true;

        allowScaleFix = true;
        allowScaleXFix = true;
        allowScaleYFix = true;

        allowAngleFix = true;

        config = null;
        pathPrefix = null;

        update(0);
        draw();
        updateHitbox();

        return this;
    }
}