package scripting.haxe;

import haxe.ds.StringMap;

import rulescript.RuleScript;
import rulescript.scriptedClass.RuleScriptedClassUtil;
import rulescript.scriptedClass.RuleScriptedClass;
import rulescript.types.ScriptedTypeUtil;
import rulescript.types.ScriptedAbstract;
import rulescript.interps.RuleScriptInterp;
import rulescript.types.Abstracts;

import hscript.Expr;

using rulescript.Tools;

class HScriptConfig
{
	public static function config()
	{
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

            var parser = new ALEParser(name);
            parser.allowAll();
            parser.mode = MODULE;

            return parser.parseModule(Paths.getContent(filePath));
        }

        RuleScriptedClassUtil.buildBridge = function (typePath:String, superInstance:Dynamic):RuleScript
        {
			var type:ScriptedClassType = ScriptedTypeUtil.resolveScript(typePath);

			var script = new ALERuleScript(typePath);

			script.superInstance = superInstance;

			cast(script.interp, RuleScriptInterp).skipNextRestore = true;

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
            final path:Array<String> = name.split('.');

            final pack:Array<String> = [];

            while (Tools.startsWithLowerCase(path[0]))
                pack.push(path.shift());

            var moduleName:String = null;

            if (path.length > 1)
                moduleName = path.shift();

            final module = ScriptedTypeUtil.resolveModule((pack.length >= 1 ? pack.join('.') + '.' + (moduleName ?? path[0]) : path[0]));

            if (module == null)
                return null;

            final typeName = path[0];

            final newModule:Array<ModuleDecl> = [];

            var typeDecl:Null<ModuleDecl> = null;

            for (decl in module)
            {
                switch (decl)
                {
                    case DPackage(_), DUsing(_), DImport(_):
                        newModule.push(decl);
                    case DClass(c) if (c.name == typeName):
                        typeDecl = decl;
                    case DAbstract(c) if (c.name == typeName):
                        typeDecl = decl;
                    default:
                }
            }

            newModule.push(typeDecl);

            return switch (typeDecl)
            {
                case DClass(classImpl):
                    final scriptedClass = new ScriptedClass({
                        name: moduleName ?? path[0],
                        path: pack.join('.'),
                        decl: newModule
                    }, classImpl?.name);

                    RuleScriptedClassUtil.registerRuleScriptedClass(scriptedClass.toString(), scriptedClass);

                    scriptedClass;
                case DAbstract(abstractImpl):
                    new ScriptedAbstract({
                        name: moduleName ?? path[0],
                        path: pack.join('.'),
                        decl: newModule
                    }, abstractImpl?.name);
                default: null;
            }
        };
		
        final curPackage:Map<String, Dynamic> = RuleScript.defaultImports[''];

		var presetClasses:Array<Class<Dynamic>> = [
            #if DISCORD_ALLOWED
            core.config.DiscordRPC,
            #end

			flixel.FlxG,
			flixel.sound.FlxSound,
			flixel.FlxState,
			flixel.FlxSprite,
			flixel.FlxCamera,
			flixel.math.FlxMath,
			flixel.util.FlxTimer,
			flixel.text.FlxText,
			flixel.tweens.FlxEase,
			flixel.tweens.FlxTween,
			flixel.group.FlxSpriteGroup,
			flixel.group.FlxGroup.FlxTypedGroup,

			Array,
			String,
            StringTools,
			Std,
			Math,
			Type,
			Reflect,
			Date,
			DateTools,
			Xml,
			EReg,
			Lambda,
			IntIterator,

			sys.io.Process,
			haxe.ds.StringMap,
			haxe.ds.IntMap,
			haxe.ds.EnumValueMap,
	
			sys.io.File,
			sys.FileSystem,
			Sys,

            core.backend.Conductor,
            core.backend.MusicBeatState,
            core.backend.MusicBeatSubState,
            core.backend.MobileControls,

            core.config.ClientPrefs,

            utils.CoolUtil,
            utils.CoolVars,

            funkin.states.PlayState,
			funkin.states.CustomState,
			funkin.substates.CustomSubState,

            funkin.visuals.mobile.MobileButton,
            
            Controls,

			Paths,

			cpp.WindowsAPI
		];

        for (theClass in presetClasses)
			curPackage.set(Type.getClassName(theClass).split('.').pop(), theClass);

        var abstracts:Array<String> = [
            'flixel.util.FlxColor'
        ];

        for (abst in abstracts)
            curPackage.set(abst.trim().split('.').pop(), Abstracts.resolveAbstract(abst));

		var presetVariables:StringMap<Dynamic> = [
			'Json' => utils.ALEJson,
            'debugTrace' => debugTrace,
            'Function_Stop' => CoolVars.Function_Stop,
            'Function_Continue' => CoolVars.Function_Continue
		];

		for (preVar in presetVariables.keys())
			curPackage.set(preVar, presetVariables.get(preVar));
	}
}