package utils;

import flixel.input.keyboard.FlxKey;

import core.config.Save;

import core.Main;

@:build(core.macros.FunctionsMergeMacro.build(
	[
		'utils.cool.ColorUtil',
		'utils.cool.EngineUtil',
		'utils.cool.FileUtil',
		'utils.cool.LogUtil',
		'utils.cool.MathUtil',
		'utils.cool.OptionsUtil',
		'utils.cool.StateUtil',
		'utils.cool.StringUtil',
		'utils.cool.SystemUtil',
		'utils.cool.KeyUtil',
		'utils.cool.ReflectUtil',
		'utils.cool.MapUtil',
		'utils.cool.SpriteUtil',
		'utils.cool.ArrayUtil',
	]
))
class CoolUtil
{
	public static var save:Save;

	public static function init()
	{
		save = new Save();

		save.load();
	}

	public static function destroy()
	{
		save?.save();
		
		save?.destroy();

		save = null;
	}

	public static function resetGame()
	{
		Main.preResetConfig();

		FlxG.resetGame();
	}
}