package utils.cool;

import haxe.Constraints.IMap;

class MapUtil
{
	public static function mapConcat(a:IMap<Dynamic, Dynamic>, b:IMap<Dynamic, Dynamic>):Map<Dynamic, Dynamic>
	{
		final result:Map<Dynamic, Dynamic> = new Map<Dynamic, Dynamic>();

		for (map in [a, b])
			for (key in map.keys())
				result[key] = map.get(key);

		return result;
	}
}