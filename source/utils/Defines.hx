package utils;

import sys.FileSystem;
import sys.io.File;

class Defines
{
	static var path(get, never):String;
	static function get_path():String
		return 'defines/';

	static var extension(get, never):String;
	static function get_extension():String
		return '.define';

	@:unreflective
	static var arguments(default, null):Map<String, String>;

	static function exists(id:String):Bool
		return FileSystem.exists(path + id + extension) || arguments.exists(id);

	static function get(id:String):Null<String>
		return exists(id) ? (arguments.get(id) ?? (FileSystem.exists(path + id + extension) ? File.getContent(path + id + extension) : null)) : null;

	public static var CONTENT_MOD(default, null):Null<String> = null;

	public static function init()
	{
		if (arguments == null)
		{
			arguments = [];
			
			final argList:Array<String> = Sys.args().copy();

			var i:Int = 0;

			while (i < argList.length)
			{
				if (!argList[i].startsWith('-'))
				{
					i++;

					continue;
				}

				final key:String = argList[i++].substr(1);

				arguments[key] = i < argList.length && !argList[i].startsWith('-') ? argList[i++] : null;
			}
		}

		CONTENT_MOD = get('CONTENT_MOD');
	}
}