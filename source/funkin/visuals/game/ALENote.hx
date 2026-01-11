package funkin.visuals.game;

import funkin.visuals.shaders.RGBPalette;
import funkin.visuals.shaders.RGBPalette.RGBShaderReference;

import core.structures.ALEStrum;

import core.enums.NoteType;

class ALENote extends FlxSprite
{
    public var textureShader:RGBShaderReference;

    public var allowShader:Bool;

    public var strum:Strum;
    
    public var type:NoteType;

    public var time:Float;
    public var data:Int;
    public var length:Float;
    public var noteType:String;

    public function new(config:ALEStrum, strum:Strum, time:Float, data:Int, length:Float, noteType:String, type:NoteType, space:Float, scale:Float, skins:Array<String>)
    {
        super();

        final inputs = ClientPrefs.controls.notes;

        this.strum = strum;

        this.type = type;

        this.time = time;
        this.data = data;
        this.length = length;
        this.noteType = noteType;

        frames = Paths.getMultiAtlas([for (skin in skins) 'noteSkins/' + skin]);

        switch (type)
        {
            case NOTE:
                animation.addByPrefix('idle', config.note, config.frameRate, false);
            case SUSTAIN:
                animation.addByPrefix('idle', config.sustain, config.frameRate, false);
            case END:
                animation.addByPrefix('idle', config.end, config.frameRate, false);
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
    }
}