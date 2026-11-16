package scripting.haxe;

import scripting.ScriptConfig;

using utils.cool.MapUtil;

import haxe.Exception;

import core.debug.HotReloading;

#if ALLOW_HSCRIPT
import ale.hscript.module.Module;

import ale.hscript.Config;
#end

class HScriptConfig
{
	public static function init()
	{
        #if ALLOW_HSCRIPT
        Config.reset();

        Config.FILE_TIME = id -> Paths.stat(id).mtime.getTime();
        Config.FILE_CHECKER = id -> Paths.exists(id);
        Config.FILE_READER = id -> Paths.getContent(id);

        Config.MODULE_IMPORT_CALLBACK = path -> HotReloading.add(path);

        Config.MODULE_PATH = 'scripts/classes/';

        Config.IMPORTS = Config.IMPORTS.concat(ScriptConfig.CLASSES);
        Config.ABSTRACTS = Config.ABSTRACTS.concat(ScriptConfig.ABSTRACTS);
        Config.TYPEDEFS = cast Config.TYPEDEFS.mapConcat(ScriptConfig.TYPEDEFS);
        Config.VARIABLES = cast Config.VARIABLES.mapConcat(ScriptConfig.VARIABLES);

        Config.VARIABLES.set('window', openfl.Lib.application.window);

        Config.ERROR_HANDLER = (name, error) -> debugTrace(name + ': ' + error?.toString() ?? error, ERROR, null, null, null);

        Config.SCRIPT_PATH = '';

        Module.reset();
		#end
	}
}