package funkin.visuals.game;

import funkin.visuals.shaders.RGBPalette;
import funkin.visuals.shaders.RGBShaderReference;

import flixel.input.keyboard.FlxKey;

import core.structures.ALEStrum;

class Splash extends FlxSprite
{
    public var textureShader:RGBShaderReference;

    public var allowShader:Bool;

    public var data:Int;

    public var animations:Array<String> = [];

    public var strum:Strum;

    public function new(config:ALEStrum, strum:Strum, scale:Float, framerate:Float, skins:Array<String>)
    {
        super();

        this.animations = config.splash;

        frames = Paths.getMultiAtlas([for (skin in skins) 'noteSplashes/' + skin]);

        for (anim in animations)
            animation.addByPrefix(anim, anim, framerate, false);

        this.scale.x = this.scale.y = scale;
        
		textureShader = new RGBShaderReference(this, new RGBPalette());

        allowShader = config.shader != null;

        if (allowShader)
        {
            textureShader.r = CoolUtil.colorFromString(config.shader[0]);
            textureShader.g = CoolUtil.colorFromString(config.shader[1]);
            textureShader.b = CoolUtil.colorFromString(config.shader[2]);
        }

        this.strum = strum;

        exists = false;

        animation.onFinish.add((_) -> {
            exists = false;
        });
    }

    public function splash()
    {
        exists = true;

        animation.play(animations[FlxG.random.int(0, animations.length - 1)], true);

        updateHitbox();

        x = strum.x + strum.width / 2 - width / 2;
        y = strum.y + strum.height / 2 - height / 2;
    }
}