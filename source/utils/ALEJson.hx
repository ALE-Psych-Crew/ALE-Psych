package utils;

import jsonmod.Json;

import haxe.format.JsonPrinter;

class ALEJson
{
    public static function parse(raw:String)
        return Json.parse(raw);

    public static function stringify(object:Dynamic, ?space:String)
        return JsonPrinter.print(object, null, space ?? '\t');
}