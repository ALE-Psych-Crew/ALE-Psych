package utils.cool;

class ReflectUtil
{
    public static function getRecursiveProperty(instance:Dynamic, split:Array<String>):Dynamic
    {
        var result:Dynamic = instance;

        for (part in split)
        {
            result = Reflect.getProperty(result, part);

            if (result == null)
                return null;
        }

        return result;
    }

    public static function setProperties(obj:Dynamic, props:Dynamic)
    {
        if (props == null)
            return;

        var fields = Reflect.fields(props);

        for (key in fields)
        {
            var value:Dynamic = Reflect.field(props, key);

            if (Reflect.fields(value).length > 0)
            {
                var subObj = Reflect.field(obj, key) ?? Reflect.getProperty(obj, key);

                setProperties(subObj, value);
            } else {
                Reflect.setProperty(obj, key, value);
            }
        }
    }
}