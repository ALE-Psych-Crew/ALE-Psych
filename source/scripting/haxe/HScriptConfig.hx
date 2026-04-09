package scripting.haxe;

import scripting.ScriptConfig;

#if HSCRIPT_ALLOWED
import ale.rulescript.RuleScriptGlobal;

import scripting.haxe.Extensible;
#end

import haxe.Exception;

using utils.cool.MapUtil;

class HScriptConfig
{
	public static function config()
	{
        #if HSCRIPT_ALLOWED
        RuleScriptGlobal.reset();

        RuleScriptGlobal.FILE_CHECKER = (id:String) -> Paths.exists(id);
        RuleScriptGlobal.FILE_READER = (id:String) -> Paths.getContent(id);

        RuleScriptGlobal.IMPORTS = RuleScriptGlobal.IMPORTS.concat(ScriptConfig.CLASSES);
        RuleScriptGlobal.ABSTRACTS = RuleScriptGlobal.ABSTRACTS.concat(ScriptConfig.ABSTRACTS);
        RuleScriptGlobal.TYPEDEFS = cast RuleScriptGlobal.TYPEDEFS.mapConcat(ScriptConfig.TYPEDEFS);
        RuleScriptGlobal.VARIABLES = cast RuleScriptGlobal.VARIABLES.mapConcat(ScriptConfig.VARIABLES);

        RuleScriptGlobal.VARIABLES.set('window', openfl.Lib.application.window);

        RuleScriptGlobal.SCRIPT_PATH = '';

        RuleScriptGlobal.ERROR_HANDLER = (error:String) -> debugTrace(error, ERROR);

        RuleScriptGlobal.apply();
		#end
	}
}