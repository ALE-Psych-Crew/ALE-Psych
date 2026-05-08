package utils;

import core.Main;

import openfl.Lib;

@:build(core.macros.CoolVarsMacro.build())
class CoolVars
{
	public static var data:Dynamic = {
		developerMode: true
	};
	
	public static var onlineVersion(get, never):String;
	static function get_onlineVersion():String
		return Main.onlineVersion;

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