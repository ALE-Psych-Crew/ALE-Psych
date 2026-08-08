package scripting.haxe;

import scripting.ScriptConfig;

using utils.cool.MapUtil;

import haxe.Exception;

#if ALLOW_HSCRIPT
#if ALE_HSCRIPT
import ale.hscript.errors.Error;
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
        Config.ERROR_HANDLER = (error:String) -> debugTrace(error, ERROR);

        Config.apply();
        #end
		#end
	}
}