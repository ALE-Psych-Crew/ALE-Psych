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
         * Preloads a sound effect.
         *
         * Sound effects are small audio clips used for UI, hits, misses, etc.
         * Preloading ensures the first playback does not lag.
         *
         * @param file Path of the sound (without extension).
         * @param missingPrint Whether to warn when the file is missing.
         */
        set('precacheSound', function(file:String, ?missingPrint:Bool)
        {
            Paths.sound(file, missingPrint);
        });

        /**
         * Preloads a music file before use.
         *
         * Music files are larger than sounds, so preloading avoids
         * stuttering when switching songs or starting states or scripts.
         *
         * @param file Path of the music file (without extension).
         * @param missingPrint Whether to print a warning if the file is missing.
         */
        set('precacheMusic', function(file:String, ?missingPrint:Bool)
        {
            Paths.music(file, missingPrint);
        });
    }
}
