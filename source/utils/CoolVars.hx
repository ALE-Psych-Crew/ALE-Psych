package utils;

import openfl.Lib;

import core.structures.DataJson;

@:build(core.macros.CoolVarsMacro.build())
class CoolVars
{
	public static var data:DataJson = null;

    public static var skipTransIn:Bool = false;
    public static var skipTransOut:Bool = false;

	public static var mobileControls(get, never):Bool;
	public static function get_mobileControls():Bool
		return #if mobile true #else CoolVars.data.developerMode && CoolVars.data.mobileDebug #end;
	
	public static var engineVersion(get, never):String;
	public static function get_engineVersion():String
		return Lib.application?.meta?.get('version') ?? '';

	public static var globalVars:Map<String, Dynamic> = new Map<String, Dynamic>();

	@:unreflective public static final Function_Stop:String = '##_ALE_PSYCH_LUA_FUNCTION_STOP_##';
	@:unreflective public static final Function_Continue:String = '##_ALE_PSYCH_LUA_FUNCTION_CONTINUE_##';
}