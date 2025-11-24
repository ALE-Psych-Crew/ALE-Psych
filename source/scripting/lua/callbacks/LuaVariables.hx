package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

class LuaVariables extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Whether mobile controls are active.
         *
         * @note Platform/runtime dependent.
         */
        set('mobileControls', CoolVars.mobileControls);

        /**
         * Special value to stop a Lua callback early.
         *
         * @note Return this from an event to cancel further handling.
         */
        set('Function_Stop', CoolVars.Function_Stop);

        /**
         * Special value to continue a Lua callback.
         *
         * @note Default flow; provided for parity with Function_Stop.
         */
        set('Function_Continue', CoolVars.Function_Continue);

        /**
         * Game viewport width in pixels.
         */
        set('screenWidth', FlxG.width);

        /**
         * Game viewport height in pixels.
         */
        set('screenHeight', FlxG.height);

        /**
         * Engine version string.
         */
        set('version', CoolVars.engineVersion);

        /**
         * Whether notes scroll downward instead of upward.
         */
        set('downscroll', ClientPrefs.data.downScroll);

        /**
         * Target frame rate from client preferences.
         */
        set('framerate', ClientPrefs.data.framerate);

        /**
         * Whether ghost tapping is enabled.
         */
        set('ghostTapping', ClientPrefs.data.ghostTapping);

        /**
         * Whether flashing light effects are enabled.
         */
        set('flashingLights', ClientPrefs.data.flashing);

        /**
         * Global note timing offset, in milliseconds.
         */
        set('noteOffset', ClientPrefs.data.noteOffset);

        /**
         * Whether the Reset keybind is disabled.
         */
        set('noResetButton', ClientPrefs.data.noReset);

        /**
         * Whether low-quality mode is enabled.
         */
        set('lowQuality', ClientPrefs.data.lowQuality);

        /**
         * Whether shaders are enabled.
         */
        set('shadersEnabled', ClientPrefs.data.shaders);

        /**
         * Name of the currently running Lua script.
         */
        set('scriptName', lua.name);

        /**
         * Name of the active mod directory.
         */
        set('currentModDirectory', Mods.folder);
    }
}
