package funkin.visuals.shaders;

import haxe.ds.StringMap;

import openfl.display.BitmapData;

import flixel.tweens.FlxEase.EaseFunction;

class FXShader extends RuntimeShader
{
    var _tweens:StringMap<FlxTween> = new StringMap();

    public function cancelTween(prop:String)
    {
        if (_tweens.exists(prop))
        {
            _tweens.get(prop).cancel();

            _tweens.remove(prop);
        }
    }

    public function set(props:Any)
    {
        for (prop in Reflect.fields(props))
        {
            if (prop == null)
                continue;

            cancelTween(prop);

            final val:Dynamic = Reflect.field(props, prop);

            if (val == null)
                continue;

            if (val is Float)
                setFloat(prop, val);

            if (val is Int)
                setInt(prop, val);

            if (val is Bool)
                setBool(prop, val);

            if (val is BitmapData)
                setSampler2D(prop, val);

            if (val is Array)
            {
                final arr:Array<Dynamic> = cast val;

                if (arr.length <= 0)
                    continue;

                final first:Dynamic = arr[0];
                
                if (first is Float)
                    setFloatArray(prop, cast arr);

                if (first is Bool)
                    setBoolArray(prop, cast arr);
                
                if (first is Int)
                    setIntArray(prop, cast arr);
            }
        }
    }

    public function tween(props:Any, ?duration:Float, ?ease:EaseFunction)
    {
        if (!ClientPrefs.data.shaders)
            return;

        for (prop in Reflect.fields(props))
        {
            cancelTween(prop);

            _tweens.set(prop, FlxTween.num(
                getFloat(prop),
                Reflect.field(props, prop),
                duration ?? 1,
                {
                    ease: ease,
                    onComplete: (_) -> {
                        _tweens.remove(prop);
                    }
                },
                (val) -> setFloat(prop, val)
            ));
        }
    }
}