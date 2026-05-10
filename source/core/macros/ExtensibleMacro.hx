package core.macros;

import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;

using StringTools;

class ExtensibleMacro
{
    macro public static function init()
    {
        final packages:Array<String> = [
            'flixel',
            'flixel.text',
            'flixel.graphics',
            'flixel.addons.display',
            
            'animate',

            'openfl.display.Sprite',
            'openfl.text.TextField',            

            'funkin.visuals',
            'funkin.visuals.objects',
            'funkin.visuals.shaders',
            'funkin.modchart',

            'ale.ui.MouseSprite',
            'ale.ui.UISprite'
        ];

        final restricted:Array<String> = [
            'flixel.util.LabelValuePair',
            'flixel.group.FlxTypedContainer',
            'flixel.FlxGame'
        ];

        final forceOverride:Array<String> = [
            'openfl.display.Sprite',
            'openfl.text.TextField'
        ];

        function defineScriptedClass(cls:ClassType, ?scriptedName:String)
        {
            final splitModule = cls.module.split('.');

            scriptedName ??= cls.name;

            if (cls.params.length > 0)
                trace(cls, scriptedName, cls.params);

            if (splitModule[splitModule.length - 1] != scriptedName || (!packages.contains(cls.pack.join('.')) && !packages.contains(cls.module)) || cls.constructor == null || cls.isFinal || cls.isInterface || cls.isAbstract || restricted.contains(cls.module) || restricted.contains(cls.pack.join('.')))
                return;

            final typeToDefine:TypeDefinition = {
                pos: Context.currentPos(),
                pack: ['scripting', 'haxe'],
                name: 'Scripted' + scriptedName,
                kind: TDClass(
                    {
                        name: cls.name,
                        pack: cls.pack
                    },
                    [{
                        pack: ['rulescript', 'scriptedClass'],
                        name: 'RuleScriptedClass'
                    }],
                    false,
                    false,
                    false
                ),
                fields: []
            };

            if (forceOverride.contains(cls.module))
                typeToDefine.meta = [{pos: Context.currentPos(), name: ':forceOverride'}];

            Context.defineType(typeToDefine);
        }

        Context.onAfterTyping((types) -> {
            for (type in types)
            {
                switch (type)
                {
                    case TClassDecl(ref):
                        final cls = ref.get();

                        if (!packages.contains(cls.pack.join('.')) && !packages.contains(cls.module))
                            continue;

                        defineScriptedClass(cls);
                    case TTypeDecl(typeRef):
                        final tpd = typeRef.get();

                        if ((!packages.contains(tpd.pack.join('.')) && !packages.contains(tpd.module)) || restricted.contains(tpd.module) || restricted.contains(tpd.pack.join('.')))
                            continue;
                        
                        switch (tpd.type)
                        {
                            case TInst(type, _):
                                final cls = type.get();

                                if (!packages.contains(cls.pack.join('.')) && !packages.contains(cls.module))
                                    continue;

                                defineScriptedClass(cls, tpd.name);
                            default:
                        }
                    default:
                }
            }
        });

        return macro null;
    }
}