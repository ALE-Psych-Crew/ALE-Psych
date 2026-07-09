package utils.cool;

class ArrayUtil
{
    public static function setArrayPrefix(arr:Array<String>, prefix:String):Array<String>
        return [for (str in arr) prefix + str];

    public static function getRandomObject(array:Array<Dynamic>):Dynamic
        return array[FlxG.random.int(0, array.length - 1)];
}