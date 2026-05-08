package core.visuals;

import flixel.addons.display.FlxRuntimeShader;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;

import openfl.filters.ShaderFilter;
import openfl.geom.ColorTransform;
import openfl.display.BitmapData;
import openfl.display.BlendMode;

class Camera extends FlxCamera
{
	public function new(x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, zoom:Float = 0)
	{
		super(x, y, width, height, zoom);

		bgColor = FlxColor.TRANSPARENT;
	}
	
    override function set_angle(value:Float):Float
    {
        angle = value;

        return angle;
    }

	override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
        if (!FlxG.renderBlit && angle != 0)
        {
            matrix.translate(-width / 2, -height / 2);

            final rad:Float = angle * Math.PI / 180;

            matrix.rotateWithTrig(Math.cos(rad), Math.sin(rad));

            matrix.translate(width / 2, height / 2);
        }
        
        super.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
    }

    public var shaders(default, set):Array<FlxRuntimeShader> = [];
    function set_shaders(value:Array<FlxRuntimeShader>):Array<FlxRuntimeShader>
    {
        shaders = value;

		filters = [for (shader in shaders) new ShaderFilter(shader)];

        return shaders;
    }

	public function setShaders(shaders:Array<FlxRuntimeShader>):Void
        this.shaders = shaders;
}