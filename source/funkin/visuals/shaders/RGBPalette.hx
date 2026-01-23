package funkin.visuals.shaders;

import funkin.visuals.game.Note;

class RGBPalette
{
	public var shader(default, null):ALERuntimeShader = new ALERuntimeShader('noteRGB');

	public var r(default, set):FlxColor;
	public var g(default, set):FlxColor;
	public var b(default, set):FlxColor;
	public var mult(default, set):Float;

	private function set_r(color:FlxColor) {
		r = color;
		shader.setFloatArray('r', [color.redFloat, color.greenFloat, color.blueFloat]);
		return color;
	}

	private function set_g(color:FlxColor) {
		g = color;
		shader.setFloatArray('g', [color.redFloat, color.greenFloat, color.blueFloat]);
		return color;
	}

	private function set_b(color:FlxColor) {
		b = color;
		shader.setFloatArray('b', [color.redFloat, color.greenFloat, color.blueFloat]);
		return color;
	}
	
	private function set_mult(value:Float) {
		mult = FlxMath.bound(value, 0, 1);
		shader.setFloatArray('mult', [mult]);
		return mult;
	}

	public function new()
	{
		r = 0xFFFF0000;
		g = 0xFF00FF00;
		b = 0xFF0000FF;

		mult = 1.0;
	}
}