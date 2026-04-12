package utils;

import sys.FileSystem;
import sys.io.File;

class Defines
{
	static final path:String = Paths.mods + '/';

	static final postfix:String = '.def';

	static function exists(id:String):Bool
		return FileSystem.exists(path + id + postfix);

	static function get(id:String):Null<String>
		return exists(id) ? File.getContent(path + id + postfix) : null;

	public static var CONTENT_MOD(default, null):Null<String> = null;

	public static var DISABLE_ADMINISTRATOR_EASTER_EGG(default, null):Bool = false;

	public static function init()
	{
		CONTENT_MOD = get('CONTENT_MOD');

		DISABLE_ADMINISTRATOR_EASTER_EGG = exists('DISABLE_ADMINISTRATOR_EASTER_EGG');

		trace(CONTENT_MOD + ' | ' + DISABLE_ADMINISTRATOR_EASTER_EGG);
	}
}