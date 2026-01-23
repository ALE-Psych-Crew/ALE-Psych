package utils;

import flixel.input.keyboard.FlxKey;

import core.config.ALESave;

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
		'utils.cool.ReflectUtil'
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
		save.save();
		
		save.destroy();
	}

	public static function resetGame()
	{
		Main.preResetConfig();

		FlxG.resetGame();
	}
}