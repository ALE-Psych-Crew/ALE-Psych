package core.macros;

import haxe.macro.Context;
import haxe.macro.Expr.Access;
import haxe.macro.Expr.Field;
import haxe.macro.Type;

class FunctionsMergeMacro
{
	public static function build(utils:Array<String>, ?renameArray:Array<String>):Array<Field>
	{
		final rename:Map<String, String> = new Map();

		if (renameArray != null)
		{
			for (str in renameArray)
			{
				final parsedStr:Array<String> = str.split('::');

				rename.set(parsedStr[0], parsedStr[1]);
			}
		}

        final list:Array<Type> = utils.map(t -> Context.getType(t));

		var fields:Array<Field> = Context.getBuildFields();
		
		for (t in list)
		{
			switch (t)
			{
				case TInst(type, params):
					final type = type.get();

					for (field in type.statics.get())
					{
						if (!field.isPublic)
							continue;

						var fieldData:Array<String> = type.module.split('.').concat([type.name, field.name]);

						final newName:String = rename.exists(field.name) ? rename.get(field.name) : field.name;

						switch (field.kind)
						{
							case FVar(read, write):
								fields.push({
									name: newName,
									doc: field.doc,
									access: [APublic, AStatic],
									kind: FVar(null, macro $p{fieldData}),
									pos: Context.currentPos()
								});

							case FMethod(k):
								fields.push({
									name: newName,
									doc: field.doc,
									access: [APublic, AStatic],
									kind: FProp('get', 'never', Context.toComplexType(field.type)),
									pos: Context.currentPos()
								});

								fields.push({
									name: 'get_' + newName,
									doc: field.doc,
									access: [AInline, AStatic],
									kind: FFun({
										args: [],
										ret: null,
										expr: macro return $p{fieldData},
										params: null
									}),
									pos: Context.currentPos()
								});
							
							default:
						}
					}

				default:
			}
		}

		return fields;
	}
}