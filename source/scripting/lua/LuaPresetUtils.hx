package scripting.lua;

import flixel.util.FlxSave;

import haxe.Constraints;

using StringTools;

class LuaPresetUtils
{
    public static function setMultiProperty(obj:Dynamic, props:Dynamic)
    {
        var fields = Reflect.fields(props);

        for (key in fields)
        {
            var value:Dynamic = Reflect.field(props, key);

            if (Reflect.fields(value).length > 0)
            {
                var subObj = Reflect.field(obj, key) ?? Reflect.getProperty(obj, key);

                setMultiProperty(subObj, value);
            } else {
                Reflect.setProperty(obj, key, value);
            }
        }
    }

    inline public static function getClass(path:String):Dynamic
    {
        var cl:Dynamic = Type.resolveClass(path);

        if (cl == null)
            debugTrace('Type not Found: ' + path, ERROR);

        return cl;
    }

	public static function getTweenOptions(lua:LuaScript, tag:String, options:Any):TweenOptions
	{
		return {
            type: tweenTypeByString(Reflect.field(options, 'type') ?? ''),
            startDelay: Reflect.field(options, 'startDelay'),
            onUpdate: (_) -> {
                lua.call('onTweenUpdate', [tag]);
            },
            onStart: (_) -> {
                lua.call('onTweenStart', [tag]);
            },
            onComplete: (_) -> {
                lua.call('onTweenComplete', [tag]);

				lua.variables.remove(tag);
            },
            loopDelay: Reflect.field(options, 'loopDelay'),
            ease: easeByString(Reflect.field(options, 'ease') ?? '')
        };
	}

    public static function complexTween(lua:LuaScript, tag:String, obj:Dynamic, props:Any, time:Float, options:Any):FlxTween
        return FlxTween.tween(obj, props, time, getTweenOptions(lua, tag, options));

	public static function complexColorTween(lua:LuaScript, tag:String, obj:Dynamic, time:Float, from:FlxColor, to:FlxColor, options:Any):FlxTween
		return FlxTween.color(obj, time, from, to, getTweenOptions(lua, tag, options));

	public static function complexNumTween(lua:LuaScript, tag:String, fromValue:Float, toValue:Float, ?duration:Float, options:Any):FlxTween
		return FlxTween.num(fromValue, toValue, duration, getTweenOptions(lua, tag, options), (val) -> { lua.call('onNumTweenUpdate', [tag, val]); });

	public static function easeByString(?ease:String = '')
    {
		return switch(ease.toLowerCase().trim())
        {
			case 'backin':
				FlxEase.backIn;
			case 'backinout':
				FlxEase.backInOut;
			case 'backout':
				FlxEase.backOut;
			case 'bouncein':
				FlxEase.bounceIn;
			case 'bounceinout':
				FlxEase.bounceInOut;
			case 'bounceout':
				FlxEase.bounceOut;
			case 'circin':
				FlxEase.circIn;
			case 'circinout':
				FlxEase.circInOut;
			case 'circout':
				FlxEase.circOut;
			case 'cubein':
				FlxEase.cubeIn;
			case 'cubeinout':
				FlxEase.cubeInOut;
			case 'cubeout':
				FlxEase.cubeOut;
			case 'elasticin':
				FlxEase.elasticIn;
			case 'elasticinout':
				FlxEase.elasticInOut;
			case 'elasticout':
				FlxEase.elasticOut;
			case 'expoin':
				FlxEase.expoIn;
			case 'expoinout':
				FlxEase.expoInOut;
			case 'expoout':
				FlxEase.expoOut;
			case 'quadin':
				FlxEase.quadIn;
			case 'quadinout':
				FlxEase.quadInOut;
			case 'quadout':
				FlxEase.quadOut;
			case 'quartin':
				FlxEase.quartIn;
			case 'quartinout':
				FlxEase.quartInOut;
			case 'quartout':
				FlxEase.quartOut;
			case 'quintin':
				FlxEase.quintIn;
			case 'quintinout':
				FlxEase.quintInOut;
			case 'quintout':
				FlxEase.quintOut;
			case 'sinein':
				FlxEase.sineIn;
			case 'sineinout':
				FlxEase.sineInOut;
			case 'sineout':
				FlxEase.sineOut;
			case 'smoothstepin':
				FlxEase.smoothStepIn;
			case 'smoothstepinout':
				FlxEase.smoothStepInOut;
			case 'smoothstepout':
				FlxEase.smoothStepOut;
			case 'smootherstepin':
				FlxEase.smootherStepIn;
			case 'smootherstepinout':
				FlxEase.smootherStepInOut;
			case 'smootherstepout':
				FlxEase.smootherStepOut;
			default:
				FlxEase.linear;
		}
	}

	public static function tweenTypeByString(?type:String = '')
	{
		return switch (type.toUpperCase().trim())
		{
			case 'BACKWARD':
				FlxTweenType.BACKWARD;
			case 'LOOPING':
				FlxTweenType.LOOPING;
			case 'ONESHOT':
				FlxTweenType.ONESHOT;
			case 'PERSIST':
				FlxTweenType.PERSIST;
			case 'PINGPONG':
				FlxTweenType.PINGPONG;
			default:
				null;
		}
	}
}