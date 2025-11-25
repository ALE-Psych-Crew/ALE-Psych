package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

class LuaTween extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
        
        set('tween', function(tag:String, obj:String, props:Dynamic, ?time:Float, ?options:Dynamic)
        {
            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), props, time, options));
        });
        
        set('doTweenX', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenX"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {x: value}, time, {ease: ease}));
        });
        
        set('doTweenY', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenY"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {y: value}, time, {ease: ease}));
        });
        
        set('doTweenAngle', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenAngle"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {angle: value}, time, {ease: ease}));
        });
        
        set('doTweenAlpha', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenAlpha"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {alpha: value}, time, {ease: ease}));
        });
        
        set('doTweenZoom', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenZoom"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {zoom: value}, time, {ease: ease}));
        });
        
        set('doTweenColor', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "colorTween" instead of "doTweenColor"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {color: value}, time, {ease: ease}));
        });

        set('colorTween', function(tag:String, obj:String, ?time:Float, ?from:FlxColor, ?to:FlxColor, ?options:Dynamic)
        {
            setTag(tag, LuaPresetUtils.complexColorTween(lua, tag, getTag(obj), time, from, to, options));
        });

        set('numTween', function(tag:String, fromValue:Float, toValue:Float, ?duration:Float, ?options:Dynamic)
        {
            setTag(tag, LuaPresetUtils.complexNumTween(lua, tag, fromValue, toValue, duration, options));
        });

        set('cancelTween', function(tag:String)
        {
            if (tagIs(tag, FlxTween))
            {
                getTag(tag).cancel();

                removeTag(tag);
            }
        });

        set('cancelTweensOf', function(tag:String)
        {
            FlxTween.cancelTweensOf(getTag(tag));
        });
    }
}
