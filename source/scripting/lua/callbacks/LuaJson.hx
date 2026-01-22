package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

class LuaJson extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
        
        set('parseJson', function(str:String)
        {
            return Json.parse(str);
        });

        set('parseJsonFile', function(path:String)
        {
            return Paths.json(path);
        });

        set('stringifyJson', function(object:Dynamic, ?space:String)
        {
            return Json.stringify(object, space);
        });
    }
}
