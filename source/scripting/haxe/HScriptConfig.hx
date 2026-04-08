package scripting.haxe;

import scripting.ScriptConfig;

import haxe.ds.StringMap;

#if HSCRIPT_ALLOWED
import rulescript.RuleScript as OGRuleScript;
import rulescript.scriptedClass.RuleScriptedClassUtil;
import rulescript.scriptedClass.RuleScriptedClass;
import rulescript.types.ScriptedTypeUtil;
import rulescript.types.ScriptedAbstract;
import rulescript.interps.RuleScriptInterp;
import rulescript.types.ScriptedModule;
import rulescript.types.Abstracts;

import hscript.Expr;

using rulescript.Tools;

@:access(rulescript.types.ScriptedTypeUtil)
#end
class HScriptConfig
{
	public static function config()
	{
        #if HSCRIPT_ALLOWED
		ScriptedTypeUtil.resolveModule = function (name:String):Array<ModuleDecl>
        {
            var path:Array<String> = name.split('.');

            var pack:Array<String> = [];

            while (path[0].charAt(0) == path[0].charAt(0).toLowerCase())
                pack.push(path.shift());

            var moduleName:String = null;

            if (path.length > 1)
                moduleName = path.shift();

            var filePath = 'scripts/classes/' + (pack.length >= 1 ? pack.join('.') + '.' + (moduleName ?? path[0]) : path[0]).replace('.', '/') + '.hx';

            if (!Paths.exists(filePath))
                return null;

            var parser = new Parser(name);
            parser.allowAll();
            parser.mode = MODULE;

            return parser.parseModule(Paths.getContent(filePath));
        }

        RuleScriptedClassUtil.buildBridge = function (typePath:String, superInstance:Dynamic):OGRuleScript
        {
			var type:ScriptedClassType = ScriptedTypeUtil.resolveScript(typePath);

			var script = new RuleScript(typePath);

			script.superInstance = superInstance;

			script.getInterp(RuleScriptInterp).skipNextRestore = true;

			if (type.isExpr)
			{
				script.execute(cast type);

				script;
			} else {
				var cl:ScriptedClass = cast type;

				RuleScriptedClassUtil.buildScriptedClass(cl, script);
			}

			return script;
        };

        ScriptedTypeUtil.resolveScript = function (name:String):Dynamic
        {
            var path = Tools.parseTypePath(name);

            final module:Array<ModuleDecl> = ScriptedTypeUtil.resolveModule(path.modulePath());

            if (module == null)
                return null;

            return new ScriptedModule(path.modulePath(), module, ScriptedTypeUtil._currentContext).types[path.typeName];
        };

        // Imports

		OGRuleScript.defaultImports[''] = new Map();
		
        final curPackage:Map<String, Dynamic> = OGRuleScript.defaultImports[''];

        for (theClass in ScriptConfig.CLASSES)
			curPackage.set(Type.getClassName(theClass).split('.').pop(), theClass);

        for (abst in ScriptConfig.ABSTRACTS)
            curPackage.set(abst.trim().split('.').pop(), Abstracts.resolveAbstract(abst));

		for (def in ScriptConfig.TYPEDEFS.keys())
			curPackage.set(def, ScriptConfig.TYPEDEFS.get(def));

		var presetVariables:StringMap<Dynamic> = [
            'debugTrace' => debugTrace,
            'Function_Stop' => CoolVars.Function_Stop,
            'Function_Continue' => CoolVars.Function_Continue,
			'Int' => Int,
			'Float' => Float,
			'Bool' => Bool
		];

		for (preVar in presetVariables.keys())
			curPackage.set(preVar, presetVariables.get(preVar));
        #end
	}
}