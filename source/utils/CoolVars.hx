package utils;

import openfl.Lib;

class CoolVars
{
	public static var Function_Stop(get, never):String;
	static function get_Function_Stop():String
		return '##_ALE_PSYCH_LUA_FUNCTION_STOP_##';

	public static var Function_Continue:String;
	static function get_Function_Continue():String
		return '##_ALE_PSYCH_LUA_FUNCTION_CONTINUE_##';

    public static var engineVersion(get, never):String;
	public static function get_engineVersion():String
		return Lib.application?.meta?.get('version') ?? '';
}