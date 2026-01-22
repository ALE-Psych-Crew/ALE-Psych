package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;
import scripting.lua.LuaPresetUtils;

using StringTools;

class LuaPaths extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('clearEngineCache', function(?clearPermanent:Bool)
        {
            Paths.clearEngineCache(clearPermanent);
        });

        set('precacheImage', function(file:String, ?permanent:Bool, ?missingPrint:Bool)
        {
            Paths.image(file, permanent, missingPrint);
        });

        set('precacheSound', function(file:String, ?permanent:Bool, ?missingPrint:Bool)
        {
            Paths.sound(file, permanent, missingPrint);
        });

        set('precacheMusic', function(file:String, ?permanent:Bool, ?missingPrint:Bool)
        {
            Paths.music(file, permanent, missingPrint);
        });
    }
}
