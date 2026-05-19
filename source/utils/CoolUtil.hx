package utils;

@:build(core.macros.FunctionsMergeMacro.build(
	[
		'utils.cool.ColorUtil',
		'utils.cool.StateUtil',
		'utils.cool.MathUtil',
		'utils.cool.CameraUtil',
		'utils.cool.AppUtil',
		'utils.cool.FileUtil',
		'utils.cool.MapUtil',
		'utils.cool.SpriteUtil',
		'utils.cool.ReflectUtil',
		'utils.cool.ArrayUtil',
		'utils.cool.SoundUtil',
		'utils.cool.StringUtil'
	]
))
class CoolUtil {}