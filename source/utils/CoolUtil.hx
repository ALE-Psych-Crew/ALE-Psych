package utils;

import flixel.input.keyboard.FlxKey;

@:build(core.macros.FunctionsMergeMacro.build(
	[
		'utils.cool.ColorUtil',
		'utils.cool.EngineUtil',
		'utils.cool.FileUtil',
		'utils.cool.LogUtil',
		'utils.cool.MathUtil',
		'utils.cool.PlayStateUtil',
		'utils.cool.ShaderUtil',
		'utils.cool.StateUtil',
		'utils.cool.StringUtil',
		'utils.cool.SystemUtil',
		'utils.cool.KeyUtil',
		'flixel.away3d.Flx3DUtil'
	]
))
class CoolUtil
{
	public static var save:ALESave;
}