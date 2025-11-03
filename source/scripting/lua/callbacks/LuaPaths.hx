package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

using StringTools;

class LuaPaths extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
		
        /**
         * Preloads a sound
         *
         * @param file Path of the audio
         * @param missingPrint Defines whether to show a warning if the file does not exist
         */
        set('precacheSound', function(file:String, ?missingPrint:Bool)
        {
            Paths.sound(file, missingPrint);
        });

        /**
         * Preloads music
         *
         * @param file Path of the audio
         * @param missingPrint Defines whether to show a warning if the file does not exist
         */
        set('precacheMusic', function(file:String, ?missingPrint:Bool)
        {
            Paths.music(file, missingPrint);
        });
    }
}
