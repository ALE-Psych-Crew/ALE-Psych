package utils;

import openfl.Lib;

class CoolVars
{
    public static var engineVersion(get, never):String;
	public static function get_engineVersion():String
		return Lib.application?.meta?.get('version') ?? '';
}