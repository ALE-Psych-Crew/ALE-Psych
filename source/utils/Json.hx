package utils;

import haxe.format.JsonPrinter;

import jsonmod.Json as OGJson;

class Json
{
    public static function parse(raw:String)
        return OGJson.parse(raw);

    public static function stringify(object:Dynamic, ?space:String)
        return JsonPrinter.print(object, null, space ?? '\t');
}