package funkin.visuals;

import flixel.addons.display.FlxRuntimeShader;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;

import openfl.filters.ShaderFilter;
import openfl.geom.ColorTransform;
import openfl.display.BitmapData;
import openfl.display.BlendMode;

class ALECamera extends FlxCamera
{
	public function new(x = 0.0, y = 0.0, width = 0, height = 0, zoom = 0.0)
	{
		super(x, y, width, height, zoom);

		bgColor = FlxColor.TRANSPARENT;
	}
	
    override function set_angle(val:Float):Float
    {
        angle = val;

        return angle;
    }

	override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
        if (!FlxG.renderBlit && angle != 0)
        {
            matrix.translate(-width / 2, -height / 2);

            var rad:Float = angle * Math.PI / 180;
            matrix.rotateWithTrig(Math.cos(rad), Math.sin(rad));

            matrix.translate(width / 2, height / 2);
        }
        
        super.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
    }

	public function setShaders(shaders:Array<FlxRuntimeShader>):Void
		filters = [for (shader in shaders) new ShaderFilter(shader)];
}