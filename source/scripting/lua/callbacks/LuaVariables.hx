package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

class LuaVariables extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

		set('Function_Stop', CoolVars.Function_Stop);
		set('Function_Continue', CoolVars.Function_Continue);

		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);
        
		set('version', CoolVars.engineVersion);
		
		set('downscroll', ClientPrefs.data.downScroll);
		set('framerate', ClientPrefs.data.framerate);
		set('ghostTapping', ClientPrefs.data.ghostTapping);
		set('flashingLights', ClientPrefs.data.flashing);
		set('noResetButton', ClientPrefs.data.noReset);
		set('lowQuality', ClientPrefs.data.lowQuality);
		set('shadersEnabled', ClientPrefs.data.shaders);

		set('scriptName', lua.name);
		set('currentModDirectory', Paths.mod);

		set('buildTarget', CoolVars.BUILD_TARGET);
    }
}
