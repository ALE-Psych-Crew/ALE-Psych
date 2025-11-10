package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

class LuaTween extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
        
        /**
         * Creates and starts a `FlxTween`
         * 
         * @param tag Tween ID
         * @param obj ID of the object the tween will act on
         * @param props Table of object variables that will be modified
         * @param time Tween duration
         * @param options Tween options. See [TweenOptions](https://api.haxeflixel.com/flixel/tweens/TweenOptions.html)
         */
        set('tween', function(tag:String, obj:String, props:Dynamic, ?time:Float, ?options:Dynamic)
        {
            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), props, time, options));
        });
        
        /**
         * Creates and starts a tween on an object and its `x` variable
         * 
         * @param tag Tween ID
         * @param obj Object ID
         * @param value Value for `x`
         * @param time Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `tween` instead
         */
        set('doTweenX', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenX"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {x: value}, time, {ease: ease}));
        });
        
        /**
         * Creates and starts a tween on an object and its `y` variable
         * 
         * @param tag Tween ID
         * @param obj Object ID
         * @param value Value for `y`
         * @param time Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `tween` instead
         */
        set('doTweenY', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenY"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {y: value}, time, {ease: ease}));
        });
        
        /**
         * Creates and starts a tween on an object and its `angle` variable
         * 
         * @param tag Tween ID
         * @param obj Object ID
         * @param value Value for `angle`
         * @param time Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `tween` instead
         */
        set('doTweenAngle', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenAngle"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {angle: value}, time, {ease: ease}));
        });
        
        /**
         * Creates and starts a tween on an object and its `alpha` variable
         * 
         * @param tag Tween ID
         * @param obj Object ID
         * @param value Value for `alpha`
         * @param time Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `tween` instead
         */
        set('doTweenAlpha', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenAlpha"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {alpha: value}, time, {ease: ease}));
        });
        
        /**
         * Creates and starts a tween on an object and its `zoom` variable
         * 
         * @param tag Tween ID
         * @param obj Object ID
         * @param value Value for `zoom`
         * @param time Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `tween` instead
         */
        set('doTweenZoom', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "tween" instead of "doTweenZoom"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {zoom: value}, time, {ease: ease}));
        });
        
        /**
         * Creates and starts a tween on an object and its `color` variable
         * 
         * @param tag Tween ID
         * @param obj Object ID
         * @param value Value for `color`
         * @param time Tween duration
         * @param ease Tween ease
         * 
         * @deprecated Use `tween` instead
         */
        set('doTweenColor', function(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)
        {
			deprecatedPrint('Use "colorTween" instead of "doTweenColor"');

            setTag(tag, LuaPresetUtils.complexTween(lua, tag, getTag(obj), {color: value}, time, {ease: ease}));
        });

        /**
         * Creates and starts a tween that will change an object's color
         * 
         * @param tag Tween ID
         * @param obj Object ID
         * @param time Tween duration
         * @param from Starting color
         * @param to Ending color
         * @param options Tween options. See [TweenOptions](https://api.haxeflixel.com/flixel/tweens/TweenOptions.html)
         */
        set('colorTween', function(tag:String, obj:String, ?time:Float, ?from:FlxColor, ?to:FlxColor, ?options:Dynamic)
        {
            setTag(tag, LuaPresetUtils.complexColorTween(lua, tag, getTag(obj), time, from, to, options));
        });

        /**
         * Cancels a tween
         * 
         * @param tag Tween ID
         */
        set('cancelTween', function(tag:String)
        {
            if (tagIs(tag, FlxTween))
                getTag(tag).cancel();
        });

        /**
         * Cancels all tweens running on an object
         *
         * @param tag Object ID whose tweens will be cancelled
         */
        set('cancelTweensOf', function(tag:String)
        {
            FlxTween.cancelTweensOf(getTag(tag));
        });
    }
}
