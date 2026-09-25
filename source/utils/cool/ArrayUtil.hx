package utils.cool;

class ArrayUtil
{
    public static function setArrayPrefix(arr:Array<String>, prefix:String):Array<String>
        return [for (str in arr) prefix + str];

    public static function getRandomObject(array:Array<Dynamic>, ?excludes:Array<Dynamic>):Dynamic
    {
        var res:Dynamic = null;

        var intExcludes:Array<Int> = [];

        while (intExcludes.length < array.length)
        {
            final int:Int = FlxG.random.int(0, array.length - 1, intExcludes);

            res = array[int];

            if (excludes != null && excludes.contains(res))
                intExcludes.push(int);
            else
                break;
        }

        return res;
    }
}