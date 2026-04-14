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

        strumLineConfig = Json.copy(strlData);
        
		textureShader = new RGBShaderReference(this, palette ?? new RGBPalette());

        if (strumLineConfig.shader != null)
            for (index => prop in ['r', 'g', 'b'])
                Reflect.setProperty(textureShader, prop, CoolUtil.colorFromString(strumLineConfig.shader[index]));
    }
}