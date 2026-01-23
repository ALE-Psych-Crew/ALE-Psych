package funkin.visuals.shaders;

import haxe.ds.StringMap;

import flixel.tweens.FlxEase.EaseFunction;

class FXShader extends ALERuntimeShader
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

    public function set(props:Any, value:Float)
    {
        for (prop in Reflect.fields(props))
        {
            cancelTween(prop);

            setFloat(prop, Reflect.field(props, prop));
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