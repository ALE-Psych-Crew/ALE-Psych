package core.backend;

import flixel.util.FlxSave;

import sys.FileSystem;

class Mods
{
	static public var folder:String = Sys.getEnv('UNIQUE_MOD') ?? '';

    public static function init()
    {
        if (Sys.getEnv('UNIQUE_MOD') != null && Sys.getEnv('UNIQUE_MOD') != '')
            return;

		var save:FlxSave = new FlxSave();

		save.bind('ALEEngineData', CoolUtil.getSavePath(false));

        if (save != null)
            folder = save.data.currentMod;

        if (!FileSystem.exists(Paths.modFolder()))
            folder = '';
    }
}