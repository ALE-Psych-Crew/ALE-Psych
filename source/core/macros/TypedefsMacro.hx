package core.macros;

import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.rtti.Meta;

class TypedefsMacro
{
	@:noPrivateAccess
	@:allow(rulescript.types.Typedefs)
	static var list(get, null):Map<String, Class<Dynamic>>;
	static function get_list():Map<String, Class<Dynamic>>
	{
		if (list == null)
		{
			list = [];

			final raw:String = Meta.getType(TypedefsMacro).ALE_TYPEDEF_LIST[0];

			for (entry in raw.split(';'))
			{
				if (entry == null || entry == '')
					continue;

				final parts = entry.split('=');

				if (parts.length < 2)
					continue;

				final resolved = Type.resolveClass(parts[1]);

				if (resolved != null)
					list[parts[0]] = resolved;
			}
		}

		return list;
	}

    #if macro
	public static function init():Void
	{
		Context.onGenerate(types -> {
			switch (Context.getType('core.macros.TypedefsMacro'))
			{
				case TInst(t, _):
					final cls = t.get();

					if (cls.meta.has('ALE_TYPEDEF_LIST'))
						return;

					final list = [];

					for (type in types)
					{
						switch (type)
						{
							case TType(ref, _):
								final t = ref.get();

								switch (t.type)
								{
									case TInst(classRef, _):
										final concrete = classRef.get();

										list.push((t.pack.length > 0 ? t.pack.join('.') + '.' : '') + t.name + '=' + (concrete.pack.length > 0 ? concrete.pack.join('.') + '.' : '') + concrete.name);

									default:
								}

							default:
						}
					}

					cls.meta.add('ALE_TYPEDEF_LIST', [macro $v{list.join(';')}], Context.currentPos());

				default:
			}
		});
	}
    #end
}