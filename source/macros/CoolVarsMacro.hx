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

		var shaExpr:Expr = macro null;

        try
        {
            var proc = new sys.io.Process('git', ['log', "--pretty=format:%h", '-n', '1']);
            var sha = proc.stdout.readLine();
            proc.close();
            shaExpr = macro $v{sha};
        } catch (e:Dynamic) {}

        fields.push({
            name: 'GITHUB_COMMIT',
            access: [APublic, AStatic, AFinal],
            kind: FVar(macro:String, shaExpr),
            pos: Context.currentPos()
        });

        fields.push({
            name: 'BUILD_TIMESTAMP',
            access: [APublic, AStatic, AFinal],
            kind: FVar(macro:String, macro Date.now().toString()),
            pos: Context.currentPos()
        });

		return fields;
	}
}