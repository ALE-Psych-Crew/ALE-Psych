package core.config;

import funkin.states.PlayState;

import core.backend.ALEState;

import core.plugins.*;

class MainState extends ALEState
{
	public static var debugPrintPlugin:DebugPrintPlugin;

    public static function preResetConfig()
    {
        CoolUtil.destroy();
    }

    public static function postResetConfig()
    {
        CoolUtil.init();

        FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;

        Conductor.init();

        Paths.init();

        CoolUtil.loadMetadata();

        if (debugPrintPlugin != null)
            debugPrintPlugin.destroy();

		if (CoolVars.data.allowDebugPrint && CoolVars.data.developerMode)
			ALEPluginsHandler.add(debugPrintPlugin = new DebugPrintPlugin());
    }
    
    override public function create()
    {
        super.create();

        postResetConfig();

        FlxG.switchState(new PlayState());
    }
}