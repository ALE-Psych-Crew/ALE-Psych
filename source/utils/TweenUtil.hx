package utils;

class TweenUtil
{
    static var tweensMap:Map<Dynamic, Map<String, FlxTween>> = new Map<Dynamic, Map<String, FlxTween>>();

    public static function tween(obj:Dynamic, values:Dynamic, ?duration:Float = 1, ?options:TweenOptions)
    {
        tweensMap[obj] ??= new Map<String, FlxTween>();

        recursiveTween(obj, values, duration, options, tweensMap[obj]);
    }

    static function recursiveTween(obj:Dynamic, values:Dynamic, ?duration:Float = 1, ?options:TweenOptions, map:Map<String, FlxTween>, ?prefix:String = '')
    {
        if (obj == null || values == null || duration <= 0)
            return;

        for (field in Reflect.fields(values))
        {
            if (field == null)
                continue;

            final fieldRes:Dynamic = Reflect.field(values, field);
            
            final objRes:Dynamic = Reflect.getProperty(obj, field);

            if (fieldRes == null || objRes == null)
                continue;

            final mapID:String = prefix + field;

            if (Reflect.isObject(fieldRes))
            {
                recursiveTween(Reflect.getProperty(obj, field), fieldRes, duration, options, map, field + '.');
            } else {
                map[mapID]?.cancel();

                map[mapID] = FlxTween.num(objRes, fieldRes, duration, options, (val) -> { Reflect.setProperty(obj, field, val); });
            }
        }
    }

    public static function setProperties(obj:Dynamic, values:Dynamic)
    {
        if (obj == null || values == null)
            return;
        
        recursiveSet(obj, values, tweensMap[obj]);
    }
    
    static function recursiveSet(obj:Dynamic, values:Dynamic, map:Map<String, FlxTween>, ?prefix:String = '')
    {
        for (field in Reflect.fields(values))
        {
            if (field == null)
                continue;

            final fieldRes:Dynamic = Reflect.field(values, field);

            final mapID:String = prefix + field;

            if (map != null)
                map[mapID]?.cancel();

            if (Reflect.isObject(fieldRes))
                recursiveSet(Reflect.getProperty(obj, field), fieldRes, map, field + '.');
            else
                Reflect.setProperty(obj, field, fieldRes);
        }
    }

    public static function cancelTweensOf(obj:Dynamic)
    {
        if (obj == null)
            return;

        final mapRes:Map<String, Dynamic> = tweensMap[obj];

        if (mapRes != null)
            for (val in mapRes)
                val?.cancel();
    }

    public static function cancel()
    {
        for (map in tweensMap)
            if (map != null)
                for (val in map)
                    val?.cancel();
    }

    public static function destroy()
    {
        cancel();

        tweensMap.clear();
    }
}