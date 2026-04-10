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

    public function new(id:String, strlData:JsonStrumLineConfig)
    {
        super();

        fromJson(Paths.json('data/' + pathPrefix + id));

        strumLineConfig = strlData;
        
		textureShader = new RGBShaderReference(this, new RGBPalette());

        if (strumLineConfig.shader != null)
            for (index => prop in ['r', 'g', 'b'])
                Reflect.setProperty(textureShader, prop, CoolUtil.colorFromString(strumLineConfig.shader[index]));
    }
}