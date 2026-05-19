package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

using StringTools;

class LuaStringTools extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('stringStartsWith', function(str:String, start:String):Bool
        {
            return str.startsWith(start);
        });

        set('stringEndsWith', function(str:String, end:String):Bool
        {
            return str.endsWith(end);
        });

        set('stringSplit', function(str:String, split:String):Array<String>
        {
            return str.split(split);
        });

        set('stringTrim', function(str:String):String
        {
            return str.trim();
        });
    }
}
