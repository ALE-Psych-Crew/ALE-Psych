package funkin.visuals.game;

import funkin.visuals.shaders.RGBPalette;
import funkin.visuals.shaders.RGBPalette.RGBShaderReference;

import flixel.input.keyboard.FlxKey;

import core.structures.ALEStrum;

class Strum extends FlxSprite
{
    public var textureShader:RGBShaderReference;

    public var allowShader:Bool;

    public var data:Int;

    public var returnToIdle:Bool = false;
    public var returnToIdleTime:Float = 0.15;

    public var direction:Float = 0;

    public function new(config:ALEStrum, data:Int, framerate:Float, skins:Array<String>, scale:Float, space:Float)
    {
        super();

        this.data = data;

        frames = Paths.getMultiAtlas([for (skin in skins) 'noteSkins/' + skin]);

        animation.addByPrefix('idle', config.idle, framerate, false);
        animation.addByPrefix('hit', config.hit, framerate, false);
        animation.addByPrefix('pressed', config.pressed, framerate, false);

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

        textureShader.enabled = false;
    }

    public var idleTimer:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (idleTimer > 0 && returnToIdle)
        {
            idleTimer -= elapsed;

            if (idleTimer <= 0)
                playAnim('idle');
        }
    }

    public function playAnim(anim:String)
    {
        textureShader.enabled = anim != 'idle' && allowShader;

        idleTimer = anim == 'idle' ? -1 : returnToIdleTime;

        animation.play(anim, true);
        
        centerOffsets();
        
        centerOrigin();
    }
}