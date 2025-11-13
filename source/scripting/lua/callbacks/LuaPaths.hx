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
         * Clears cached assets used by the engine.
         *
         * This removes images, spritesheets, audio files and other stored resources so
         * the engine can reload them when needed. Useful when switching mods,
         * unloading large files, or preventing long‑session memory buildup.
         *
         * @param clearPermanent If true, also clears permanent cache entries,
         *        which are normally preserved across state changes.
         */
        set('clearEngineCache', function(?clearPermanent:Bool)
        {
            Paths.clearEngineCache(clearPermanent);
        });

        /**
         * Preloads an image into memory.
         *
         * Forces the engine to load an image ahead of time so it does not
         * cause a stall when first drawn. Helpful for characters, stages,
         * HUD graphics and scripted UI elements.
         *
         * @param file Path of the image (without file extension).
         * @param permanent Whether the image should stay permanently cached.
         * @param missingPrint Whether to print a warning if the file is missing.
         */
        set('precacheImage', function(file:String, ?permanent:Bool, ?missingPrint:Bool)
        {
            Paths.image(file, permanent, missingPrint);
        });

        /**
         * 
         */
        set('precacheSound', function(file:String, ?permanent:Bool, ?missingPrint:Bool)
        {
            Paths.sound(file, permanent, missingPrint);
        });

        /**
         * 
         */
        set('precacheMusic', function(file:String, ?permanent:Bool, ?missingPrint:Bool)
        {
            Paths.music(file, permanent, missingPrint);
        });
    }
}
