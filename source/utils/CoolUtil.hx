package utils;

@:build(core.macros.FunctionsMergeMacro.build(
	[
		'utils.cool.CameraUtil',
		'utils.cool.ColorUtil',
		'utils.cool.StateUtil',
		'utils.cool.MathUtil',
		'utils.cool.AppUtil',
		'utils.cool.MapUtil'
	]
))
class CoolUtil {}