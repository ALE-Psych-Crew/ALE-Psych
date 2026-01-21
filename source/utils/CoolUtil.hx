package utils;

import flixel.input.keyboard.FlxKey;

import core.config.ALESave;

@:build(core.macros.FunctionsMergeMacro.build(
	[
		'utils.cool.FileUtil',
		'utils.cool.LogUtil',
		'utils.cool.MathUtil',
		'utils.cool.ReflectUtil',
		'utils.cool.StringUtil',
		'utils.cool.OptionsUtil',
		'utils.cool.ColorUtil',
		'utils.cool.EngineUtil'
	]
))
class CoolUtil
{
	public static var save:ALESave;

	public static function init()
	{
		save = new ALESave();

		save.load();
	}

	public static function destroy()
	{
		save?.destroy();
	}
}