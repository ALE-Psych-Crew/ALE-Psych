package core.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Format;

class CoolVarsMacro
{
	public static function build():Array<Field>
	{
		var fields:Array<Field> = Context.getBuildFields();

        function proccessExpr(id:String, args:Array<String>):Expr
        {
            try
            {
                final proc = new sys.io.Process(id, args);

                final out = proc.stdout.readLine();

                proc.close();

                return macro $v{out};
            } catch (e:Dynamic) {}

            return macro null;
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

        pushField('GITHUB_COMMIT', proccessExpr('git', ['log', '--pretty=%h', '-n', '1']));
        pushField('GITHUB_NAME', proccessExpr('git', ['log', '--pretty=%s', '-n', '1']));
        pushField('BUILD_TIMESTAMP', macro Date.now().toString());

		return fields;
	}
}