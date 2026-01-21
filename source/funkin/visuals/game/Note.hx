package funkin.visuals.game;

import funkin.visuals.shaders.RGBPalette;
import funkin.visuals.shaders.RGBShaderReference;

import flixel.math.FlxAngle;
import flixel.math.FlxRect;

import core.structures.ALEStrum;

import core.enums.NoteType;

class Note extends FlxSprite
{
    public var textureShader:RGBShaderReference;

    public var allowShader:Bool;

    public var type:NoteType;

    public var time:Float;
    public var data:Int;
    public var length:Float;
    public var noteType:String;

    public var hit:Bool = false;

    public var miss:Bool = false;

    public var parent:Note;

    public var characterPosition:Int;

    public var singAnimation:String;
    public var missAnimation:String;

    public var botplayMiss:Bool = false;

    public var ignore:Bool = false;

    public var sustainHeight(default, set):Float;
    function set_sustainHeight(value:Float):Float
    {
        sustainHeight = value;

        sustainSpeed = sustainSpeed;

        return sustainHeight;
    }

    public var sustainSpeed(default, set):Null<Float>;
    function set_sustainSpeed(value:Float):Null<Float>
    {
        sustainSpeed = value;

        setGraphicSize(width, sustainHeight * sustainSpeed);
                    
        updateHitbox();

        return sustainSpeed;
    }

    public function new(config:ALEStrum, time:Float, data:Int, length:Float, noteType:String, type:NoteType, space:Float, scale:Float, skins:Array<String>, palette:RGBPalette, character:Int, ?sustainHeight:Float, ?speed:Float)
    {
        super();

        final inputs = ClientPrefs.controls.notes;

        this.type = type;

        this.time = time;
        this.data = data;
        this.length = length;
        this.noteType = noteType;

        this.characterPosition = character;

        this.singAnimation = config.sing;
        this.missAnimation = config.miss;

        frames = Paths.getMultiAtlas([for (skin in skins) 'notes/' + skin]);

        switch (type)
        {
            case 'note':
                animation.addByPrefix('idle', config.note, 0, false);
            case 'sustain':
                animation.addByPrefix('idle', config.sustain, 0, false);
            case 'end':
                animation.addByPrefix('idle', config.end, 0, false);
        }

        animation.play('idle');

        this.scale.x = this.scale.y = scale;
        
        updateHitbox();
        centerOrigin();
        centerOffsets();

        x = data * space;

        y = 2000;
        
		textureShader = new RGBShaderReference(this, palette);

        allowShader = config.shader != null;

        multSpeed = 1;

        if (sustainHeight != null)
            this.sustainHeight = sustainHeight;

        if (sustainSpeed != null)
            this.sustainSpeed = sustainSpeed;
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
        if (type == 'sustain' && animation.curAnim != null)
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

	public var hitHealth:Float = 0.02;
	public var missHealth:Float = 0.1;

    public var multAlpha:Float = 1;

    public final speedMult:Float = ClientPrefs.data.downScroll ? -0.45 : 0.45;

    public var timeDistance:Float = 0;

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
            y = strum.y + offsetY + Math.sin(finalDirection) * distance - (ClientPrefs.data.downScroll && type != 'note' ? height : 0);
        
        if (type != 'note' && hit)
        {
            if (this.clipRect == null)
                clipRect = FlxRect.get();

            var clipY:Float = 0;

            if (ClientPrefs.data.downScroll)
                clipY = ((y + height) - (strum.y + offsetY)) / scale.y;
            else
                clipY = ((strum.y + offsetY) - y) / scale.y;

            clipRect.set(0, clipY, frameWidth, frameHeight - clipY);
        } else {
            clipRect = null;
        }
    }
}