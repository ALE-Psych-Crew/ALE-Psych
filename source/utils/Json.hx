package utils;

import haxe.format.JsonPrinter;

import jsonmod.Json as OGJson;

class Json
{
    public static function parse(raw:String)
        return OGJson.parse(raw);

    public static function stringify(object:Dynamic, ?space:String)
        return JsonPrinter.print(object, null, space ?? '\t');
    
    public static function copy<T>(value:T):T
    {
        if (value == null)
            return value;

        if (value is Array)
        {
            var arrValue:Array<Dynamic> = cast value;

            var result:Array<Dynamic> = [];

            for (i in 0...arrValue.length)
                result[i] = copy(arrValue[i]);

            return cast result;
        }

        switch (Type.typeof(value))
        {
            case TObject:
                var result:Dynamic = {};

                for (field in Reflect.fields(value))
                    Reflect.setField(result, field, copy(Reflect.field(value, field)));

                return cast result;

            default:
                return value;
        }
    }
}