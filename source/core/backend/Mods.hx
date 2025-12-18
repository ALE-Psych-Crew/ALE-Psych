package core.backend;

import flixel.util.FlxSave;

import sys.FileSystem;

class Mods
{
    @:unreflective public static var UNIQUE_MOD:Null<String> = null;

	static public var folder:String = UNIQUE_MOD ?? '';

    public static function init()
    {
        if (FileSystem.exists('mods/UNIQUE_MOD.txt'))
        {
            #if mobile
            core.config.MainState.showedModMenu = true;
            #end

            UNIQUE_MOD = folder = sys.io.File.getContent('mods/UNIQUE_MOD.txt').split('\n')[0].trim();
            
            return;
        } else {
            UNIQUE_MOD = null;
        }

		var save:FlxSave = new FlxSave();

		save.bind('ALEEngineData', CoolUtil.getSavePath(false));

        if (save != null)
            folder = save.data.currentMod;

        if (!FileSystem.exists(Paths.modFolder()))
            folder = '';
    }
}