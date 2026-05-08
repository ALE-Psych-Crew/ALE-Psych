package utils;

@:build(core.macros.FunctionsMergeMacro.build(
	[
		'utils.cool.MathUtil',
		'utils.cool.MapUtil'
	]
))
class CoolUtil {}