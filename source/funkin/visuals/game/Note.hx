package funkin.visuals.game;

import core.structures.JsonStrumLineConfig;

import core.enums.NoteType;

import flixel.math.FlxAngle;
import flixel.math.FlxRect;

import funkin.visuals.shaders.RGBPalette;

class Note extends StrumLineObject
{
    public var time:Float = 0;
    public var length:Float = 0;
    public var noteType:String = '';

    public var parent:Note;

    public var strum:Strum;

    public var type:NoteType;

    public var sustainHeight(default, set):Float;
    function set_sustainHeight(value:Float):Float
    {
        sustainHeight = value;

        speed = speed;

        return sustainHeight;
    }

    public var speed(default, set):Null<Float>;
    function set_speed(value:Null<Float>):Null<Float>
    {
        speed = value ?? 1;

        if (type == SUSTAIN && animation.curAnim != null)
        {
            setGraphicSize(width, sustainHeight * speed);

            updateHitbox();
        }

        return speed;
    }

	public var hitHealth:Float;
	public var missHealth:Float;

    public var character:Array<Int> = [0, 0];

    public function new(id:String, strlData:JsonStrumLineConfig, type:NoteType, palette:RGBPalette)
    {
        allowOffset = false;
        
        pathPrefix = 'notes/';

        super(id, strlData, palette);

        this.type = type;

        hitHealth = type == ARROW ? 0.025 : 0;
        missHealth = type == ARROW ? 0.05 : 0;

        playAnim(type == ARROW ? strlData.note : type == SUSTAIN ? strlData.sustain : strlData.end);

        y = FlxG.height * 2;

        updateHitbox();
        centerOrigin();
        centerOffsets();

        sustainHeight = 0.465;
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

    public var strumClipping:Bool = true;
    
    public function followStrum()
    {
        speed ??= 1;

        final distance:Float = timeDistance * speed * speedMultiplier * (strumLine.downScroll ? -1 : 1);

        if (copyAngle)
            angle = strum.angle + angleOffset;

        if (copyAlpha)
            alpha = strum.alpha * alphaMultiplier;

        if (copyX || copyY)
        {
            final totalDirection:Float = ((copyDirection ? strum.direction : direction) + directionOffset) * FlxAngle.TO_RAD;

            if (copyX)
                x = strum.x + xOffset + Math.cos(totalDirection) * distance;

            if (copyY)
                y = strum.y + yOffset + Math.sin(totalDirection) * distance - (strumLine.downScroll && type != 'arrow' ? height : 0);
        }

        if (strumClipping && type != 'arrow')
        {
            if (hit)
            {
                this.clipRect ??= FlxRect.get();

                final clip:Float = (strumLine.downScroll ? ((y + height) - (strum.y + yOffset)) : ((strum.y + yOffset) - y)) / scale.y;

                clipRect.set(0, clip, frameWidth, frameHeight - clip);
            } else {
                clipRect = null;
            }
        }
    }
    
    public var hit:Bool = false;
    public var miss:Bool = false;

    public var characterIndex:Int = 0;

    public var ignore:Bool = false;
    public var botplayMiss:Bool = false;
    
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}
}