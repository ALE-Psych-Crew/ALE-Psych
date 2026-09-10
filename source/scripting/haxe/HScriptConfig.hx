package scripting.haxe;

import scripting.ScriptConfig;

using utils.cool.MapUtil;

import haxe.Exception;

import core.debug.HotReloading;

#if ALLOW_HSCRIPT
#if ALE_HSCRIPT
import ale.hscript.errors.Error;
#else
import ale.rulescript.HxParser;
#end

typedef Config = #if ALE_HSCRIPT ale.hscript.Config #else ale.rulescript.RuleScriptGlobal #end;
#end

class HScriptConfig
{
	public static function init()
	{
        #if ALLOW_HSCRIPT
        Config.reset();

        Config.FILE_CHECKER = (id:String) -> Paths.exists(id);
        Config.FILE_READER = (id:String) -> Paths.getContent(id);

        Config.IMPORTS = Config.IMPORTS.concat(ScriptConfig.CLASSES);
        Config.ABSTRACTS = Config.ABSTRACTS.concat(ScriptConfig.ABSTRACTS);
        Config.TYPEDEFS = cast Config.TYPEDEFS.mapConcat(ScriptConfig.TYPEDEFS);
        Config.VARIABLES = cast Config.VARIABLES.mapConcat(ScriptConfig.VARIABLES);

        Config.VARIABLES.set('window', openfl.Lib.application.window);

        Config.SCRIPT_PATH = '';

        #if ALE_HSCRIPT
        Config.ERROR_HANDLER = (error, name) -> debugTrace(name + ': ' + error.toString(), ERROR, null, null, null);
        #else
        Config.MODULE_RESOLVER = (name) -> {
            final path:Array<String> = name.split('.');

            final pack:Array<String> = [];

            while (path[0].charAt(0) == path[0].charAt(0).toLowerCase())
                pack.push(path.shift());

            final moduleName:String = path.length > 1 ? path.shift() : null;

            final filePath:String = Config.MODULE_PATH + (pack.length >= 1 ? pack.join('.') + '.' + (moduleName ?? path[0]) : path[0]).replace('.', '/') + Config.MODULE_EXTENSION;

            if (!Config.FILE_CHECKER(filePath))
                return null;

            HotReloading.add(filePath);

            return new HxParser(name, MODULE).parseModule(Config.FILE_READER(filePath));
        };

        Config.ERROR_HANDLER = (error:String) -> debugTrace(error, ERROR);

        Config.apply();
        #end
		#end
	}
}