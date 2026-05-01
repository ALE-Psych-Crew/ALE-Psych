package funkin.visuals.game;

import funkin.visuals.shaders.RGBShaderReference;
import funkin.visuals.shaders.RGBPalette;

import core.structures.JsonStrumLineConfig;

class StrumLineObject extends FunkinSprite
{
    public var strumLine:StrumLine;

    public var strumLineConfig:JsonStrumLineConfig;

    public var textureShader:RGBShaderReference;

    public var data:Int = 0;

    public function new(id:String, strlData:JsonStrumLineConfig, ?palette:RGBPalette)
    {
        super();

        fromJson(Paths.json('data/' + pathPrefix + id));

        strumLineConfig = Reflect.copy(strlData);
        
        if (palette == null)
        {
            if (strumLineConfig.shader == null)
                palette = new RGBPalette();
            else
                palette = new RGBPalette(CoolUtil.colorFromString(strumLineConfig.shader[0]), CoolUtil.colorFromString(strumLineConfig.shader[1]), CoolUtil.colorFromString(strumLineConfig.shader[2]));
        }

		textureShader = new RGBShaderReference(this, palette);
    }
}