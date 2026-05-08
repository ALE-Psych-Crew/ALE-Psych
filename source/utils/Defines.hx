package utils;

import sys.FileSystem;
import sys.io.File;

class Defines
{
	static final path:String = 'defines/';

	static final extension:String = '.define';

	static function exists(id:String):Bool
		return FileSystem.exists(path + id + extension);

	static function get(id:String):Null<String>
		return exists(id) ? File.getContent(path + id + extension) : null;

	public static var CONTENT_MOD(default, null):Null<String> = null;

	public static function init()
	{
		CONTENT_MOD = get('CONTENT_MOD');
	}
}