package utils.cool;

class ArrayUtil
{
    public static function setArrayPrefix(arr:Array<String>, prefix:String):Array<String>
        return [for (str in arr) prefix + str];
}