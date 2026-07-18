package funkin.visuals.game;

import core.structures.JsonStrumLineConfig;

import core.enums.NoteType;

import funkin.visuals.shaders.RGBShader;

import flixel.math.FlxAngle;
import flixel.math.FlxRect;

class Note extends StrumLineObject
{
    public final type:NoteType;

    public var strum:Strum;
    public var splash:Splash;

    public var parent:Note;

    public var time:Float;
    public var length:Float;
    public var noteType:String;
    public var character:Array<Int>;

    public var crochet:Float;

    public var sustainHeightFactor:Float = 1.0285;

    public var speed(default, set):Null<Float>;
    function set_speed(value:Null<Float>):Null<Float>
    {
        speed = value;

        if (type == 'sustain' && animation.curAnim != null)
        {
            setGraphicSize(width, sustainHeightFactor * speedMultiplier * crochet * speed);

            updateHitbox();
        }

        return speed;
    }

    public var singHealth:Float;
    public var missHealth:Float;

    public function new(id:String, strlData:JsonStrumLineConfig, allowShader:Bool, type:NoteType, data:Int, rgb:RGBShader)
    {
        allowOffset = false;

        pathPrefix = 'notes/';

        super(id, strlData, allowShader, data, rgb);

        this.type = type;

        playAnim(type == 'arrow' ? strumLineConfig.note : type == 'sustain' ? strumLineConfig.sustain : strumLineConfig.end);

        y = FlxG.height * 2;

        updateHitbox();

        singHealth = type == 'arrow' ? 1.25 : 0.625;
        missHealth = type == 'arrow' ? 2.5 : 1.25;
    }

    public var timeDistance:Float = 0;

    public var speedMultiplier:Float = 0.45;

    public var direction:Float = 0;

    public var copyAngle:Bool = true;
    public var angleOffset:Float = 0;

    public var copyDirection:Bool = true;
    public var directionOffset:Float = 90;

    public var copyAlpha:Bool = true;
    public var alphaMultiplier:Float = 1;

    public var copyX:Bool = true;
    public var xOffset:Float = 0;

    public var copyY:Bool = true;
    public var yOffset:Float = 0;

    public var copyScale:Bool = true;
    public var scaleMultiplier:Float = 1;

    public var copySkewX:Bool = true;
    public var skewXOffset:Float = 0;

    public var copySkewY:Bool = true;
    public var skewYOffset:Float = 0;

    public var sustainClipping:Bool = true;

    public function followStrum()
    {
        speed ??= 1;

        final distance:Float = timeDistance * speed * speedMultiplier * (strumLine.downScroll ? -1 : 1) - (strumLine.downScroll && type != 'arrow' ? height : 0);

        if (copyAngle)
            angle = strum.angle + angleOffset;

        if (copyAlpha)
            alpha = strum.alpha * alphaMultiplier;

        if (copySkewX)
            skew.x = strum.skew.x + skewXOffset;

        if (copySkewY)
            skew.y = strum.skew.y + skewYOffset;

        if (copyScale)
        {
            scale.x = strum.scale.x * scaleMultiplier;
            
            if (type == 'arrow')
                scale.y = strum.scale.y * scaleMultiplier;
        }

        if (copyX || copyY)
        {
            final rawDirection:Float = ((copyDirection ? strum.direction : direction) + directionOffset) * FlxAngle.TO_RAD;

            if (copyX)
                x = strum.x + distance * FlxMath.fastCos(rawDirection) + xOffset;

            if (copyY)
                y = strum.y + distance * FlxMath.fastSin(rawDirection) + yOffset;
        }

        if (sustainClipping && type != 'arrow')
        {
            if (hit)
            {
                this.clipRect ??= FlxRect.get();

                final time:Float = FlxMath.bound((Conductor.songPosition - time) / height * speedMultiplier * speed, 0, 1);

                this.clipRect.set(0, frameHeight * time, frameWidth, frameHeight * (1 - time));
            } else {
                this.clipRect?.put();
            }
        }
    }

    public var hit:Bool = false;
    public var miss:Bool = false;

    public var ignore:Bool = false;

    public var botplayMiss:Bool = false;
}