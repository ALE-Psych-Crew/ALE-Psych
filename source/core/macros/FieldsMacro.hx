package core.macros;

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

class FieldsMacro
{
    macro public static function init():Void
    {
        for (cls in [
            'flixel.FlxBasic',
            'flixel.FlxState',
            'flixel.FlxSprite',
            'utils.CoolVars'
        ])
            Compiler.addGlobalMetadata(cls, '@:build(core.macros.FieldsMacro.build())', true);
    }

    macro public static function build():Array<Field>
    {
        var fields = Context.getBuildFields();

        final cls = Context.getLocalClass().get();
        
        final fullName = cls.pack.join('.') + '.' + cls.name;

        switch (fullName)
        {
            case 'utils.CoolVars':
                function processExpr(id:String, args:Array<String>):Expr
                {
                    try
                    {
                        final proc = new sys.io.Process(id, args);

                        final out = proc.stdout.readLine();
                        
                        proc.close();

                        return macro $v{out};
                    } catch (e:Dynamic) {
                        return macro null;
                    }
                }

                function pushField(name:String, expr:Expr)
                {
                    fields.push({
                        name: name,
                        access: [APublic, AStatic, AFinal],
                        kind: FVar(macro:String, expr),
                        pos: Context.currentPos()
                    });
                }

                pushField('GITHUB_COMMIT', processExpr('git', ['log', '--pretty=%h', '-n', '1']));
                pushField('GITHUB_NAME', processExpr('git', ['log', '--pretty=%s', '-n', '1']));
                pushField('BUILD_TIMESTAMP', macro Date.now().toString());

            case 'flixel.FlxBasic':
                fields.push({
                    name: 'metadata',
                    access: [APublic],
                    kind: FVar(macro:Map<String, Dynamic>, macro new Map<String, Dynamic>()),
                    pos: Context.currentPos()
                });

            case 'flixel.FlxState':
                for (f in fields)
                {
                    if (f.name != 'tryUpdate')
                        continue;

                    f.kind = FFun({
                        args: [{ name: 'elapsed', type: macro:Float }],
                        ret: macro:Void,
                        expr: macro {
                            if (subState == null || persistentUpdate || transitioning)
                                update(elapsed);

                            if (_requestSubStateReset)
                            {
                                _requestSubStateReset = false;

                                resetSubState();
                            }

                            if (subState != null)
                                subState.tryUpdate(elapsed);
                        }
                    });

                    break;
                }

                fields.push({
                    name: 'transitioning',
                    access: [APublic, AStatic],
                    kind: FVar(macro:Bool, macro false),
                    pos: Context.currentPos()
                });

            case 'flixel.FlxSprite':
                for (f in fields)
                {
                    if (f.name != 'checkEmptyFrame')
                        continue;

                    f.kind = FFun({
                        args: [],
                        ret: macro:Void,
                        expr: macro {
                            if (_frame == null)
                            {
                                loadGraphic('flixel/NO_IMAGE.png');
                            } else if (graphic != null && graphic.isDestroyed) {
                                final width = this.width;
                                final height = this.height;

                                flixel.FlxG.log.error('Cannot render a destroyed graphic, the placeholder image will be used instead');

                                loadGraphic('flixel/NO_IMAGE.png');

                                this.width = width;
                                this.height = height;
                            }
                        }
                    });

                    break;
                }
        }

        return fields;
    }
}