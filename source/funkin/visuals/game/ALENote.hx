package funkin.visuals.game;

import funkin.visuals.shaders.RGBPalette;
import funkin.visuals.shaders.RGBPalette.RGBShaderReference;

import flixel.math.FlxAngle;

import core.structures.ALEStrum;

import core.enums.NoteType;

class ALENote extends FlxSprite
{
    public var textureShader:RGBShaderReference;

    public var allowShader:Bool;

    public var type:NoteType;

    public var time:Float;
    public var data:Int;
    public var length:Float;
    public var noteType:String;

    public function new(config:ALEStrum, time:Float, data:Int, length:Float, noteType:String, type:NoteType, space:Float, scale:Float, skins:Array<String>)
    {
        super();

        final inputs = ClientPrefs.controls.notes;

        this.type = type;

        this.time = time;
        this.data = data;
        this.length = length;
        this.noteType = noteType;

        frames = Paths.getMultiAtlas([for (skin in skins) 'noteSkins/' + skin]);

        switch (type)
        {
            case NOTE:
                animation.addByPrefix('idle', config.note, 0, false);
            case SUSTAIN:
                animation.addByPrefix('idle', config.sustain, 0, false);
            case END:
                animation.addByPrefix('idle', config.end, 0, false);
        }

        animation.play('idle');

        this.scale.x = this.scale.y = scale;
        
        updateHitbox();

        x = data * space;
        
		textureShader = new RGBShaderReference(this, new RGBPalette());

        allowShader = config.shader != null;

        if (allowShader)
        {
            textureShader.r = CoolUtil.colorFromString(config.shader[0]);
            textureShader.g = CoolUtil.colorFromString(config.shader[1]);
            textureShader.b = CoolUtil.colorFromString(config.shader[2]);
        }

        multSpeed = 1;
    }

    public var multSpeed(default, set):Float;
    function set_multSpeed(value:Float):Float
    {
        multSpeed = value;

        resizeByRatio(value / multSpeed);

        return value;
    }

    public function resizeByRatio(value:Float)
    {
        if (type == SUSTAIN && animation.curAnim != null)
        {
            scale.y *= value;

            updateHitbox();
        }
    }

    public var direction:Float = 0;

    public var copyAngle:Bool = true;
    public var copyDirection:Bool = true;
    public var copyAlpha:Bool = true;
    public var copyX:Bool = true;
    public var copyY:Bool = true;

    public var offsetX:Float = 0;
    public var offsetY:Float = 0;
    public var offsetAngle:Float = 0;
    public var offsetDirection:Float = 0;

    public var multAlpha:Float = 1;

    public final speedMult:Float = ClientPrefs.data.downScroll ? -0.45 : 0.45;

    public var timeDistance(get, never):Float;
    function get_timeDistance():Float
    {
        return time - Conductor.songPosition;
    }

    public function followStrum(strum:Strum, crochet:Float, ?speed:Float)
    {
        speed ??= 1;

        var distance:Float = speedMult * timeDistance * speed * multSpeed;

        if (copyAngle)
            angle = strum.angle + offsetAngle;

        var finalDirection:Float = direction;

        if (copyDirection)
            finalDirection = strum.direction;

        finalDirection = (finalDirection + 90) * FlxAngle.TO_RAD;

        if (copyAlpha)
            alpha = strum.alpha * multAlpha;

        if (copyX)
            x = strum.x + offsetX + Math.cos(finalDirection) * distance;

        if (copyY)
            y = strum.y + offsetY + Math.sin(finalDirection) * distance;
    }
}