package core.backend;

import flixel.util.FlxSave;

import sys.FileSystem;

class Mods
{
    @:unreflective public static final UNIQUE_MOD:Null<String> = null;

	static public var folder:String = UNIQUE_MOD ?? '';

    public static function init()
    {
        if (UNIQUE_MOD != null)
            return;

		var save:FlxSave = new FlxSave();

		save.bind('ALEEngineData', CoolUtil.getSavePath(false));

        if (save != null)
            folder = save.data.currentMod;

        if (!FileSystem.exists(Paths.modFolder()))
            folder = '';
    }
}