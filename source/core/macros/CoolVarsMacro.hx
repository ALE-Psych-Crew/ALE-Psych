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
		
        fields.push(
            {
                name: 'GITHUB_COMMIT',
                access: [APublic, AStatic, AFinal],
                kind: FVar(macro:String, macro new sys.io.Process('git', ['log', "--pretty=format:%h", '-n', '1']).stdout.readLine()),
                pos: Context.currentPos()
            }
        );

		return fields;
	}
}