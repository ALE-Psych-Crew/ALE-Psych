package core.macros;

import haxe.macro.TypeTools;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;

using StringTools;

typedef PackageData = {
    name:String,
    path:String
}

class ExtensibleMacro
{
    macro public static function init()
    {
        final packs:Array<String> = [
            'flixel.group',
            
            'flixel.sound.filters.FlxSoundBaseEffect',
            'flixel.sound.filters.FlxSoundFilter',
            'flixel.sound.filters.effects',
            'flixel.addons.display',
            'flixel.graphics',
            'flixel.effects',
            'flixel.tweens',
            'flixel.system',
            'flixel.sound',
            'flixel.text',
            'flixel',
            
            'animate',

            'openfl.display.Sprite',
            'openfl.text.TextField',

            // 'core.objects.GameObject',

            'funkin.visuals.shaders.RuntimeShader',
            'funkin.visuals.shaders.FXShader',
            'funkin.visuals.game.Character',
            'funkin.visuals.game.Strum',
            'funkin.visuals.game.Note',
            'funkin.visuals.game.Icon',
            'funkin.visuals.objects',
            'funkin.visuals',

            'scripting.lua.LuaPresetBase',

            'ale.ui.MouseSprite',
            'ale.ui.UISprite'
        ];

        final ignore:Array<String> = [
            'flixel.group.FlxSpriteContainer',
            'flixel.FlxGame',

            'animate.FlxAnimateAssets',

            'funkin.visuals.objects.Alphabet',
            'funkin.visuals.objects.Letter',
            'funkin.visuals.objects.Bar'
        ];

        final forceOverride:Array<String> = [
            'openfl.display.Sprite',
            'openfl.text.TextField'
        ];

        final packages:Map<String, Array<PackageData>> = [];

        var savedPackages:Bool = false;

        final created:Array<String> = [];
     
        Context.onAfterTyping(types -> {    
            if (!savedPackages)
            {
                savedPackages = true;

                for (type in types)
                {
                    final cls:BaseType = switch (type)
                    {
                        case TClassDecl(ref):
                            final cls = ref.get();

                            if (cls.isPrivate || cls.isFinal || cls.constructor == null)
                                null;
                            else
                                cls;
                        case TTypeDecl(ref):
                            ref.get();
                        default:
                            null;
                    };

                    if (cls == null)
                        continue;

                    final pack:Array<String> = cls.module.split('.');

                    final packName:String = pack.pop();

                    final joinPack:String = pack.join('.');

                    if (packName != cls.name)
                        continue;
                    
                    final path:String = joinPack + '.' + cls.name;

                    if ((packs.contains(joinPack) || packs.contains(path)) && !ignore.contains(joinPack) && !ignore.contains(path))
                    {
                        packages[joinPack] ??= [];

                        packages[joinPack].push({name: cls.name, path: path});
                    }
                }
            }

            for (pack in packages.keys())
            {
                for (data in packages[pack])
                {
                    final scriptedName:String = 'Scripted' + data.name;

                    if (created.contains(scriptedName))
                        continue;

                    created.push(scriptedName);

                    final typeDef:TypeDefinition = {
                        pack: ['scripting', 'haxe'],
                        name: scriptedName,
                        pos: Context.currentPos(),
                        fields: [],
                        kind: TDClass(
                            {
                                pack: pack.split('.'),
                                name: data.name
                            },
                            [{
                                pack: ['rulescript', 'scriptedClass'],
                                name: 'RuleScriptedClass'
                            }]
                        )
                    };

                    if (forceOverride.contains(data.path) || forceOverride.contains(pack))
                        typeDef.meta = [{
                            pos: Context.currentPos(),
                            name: ':forceOverride'
                        }];

                    Context.defineType(typeDef);
                }
            }
        });

        return macro null;
    }
}