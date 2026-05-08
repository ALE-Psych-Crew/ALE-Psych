package utils;

import api.DesktopAPI;

import core.structures.JsonData;
import core.Main;

import utils.cool.ColorUtil;
import utils.cool.AppUtil;

import openfl.Lib;

@:build(core.macros.CoolVarsMacro.build())
class CoolVars
{
	public static var data:JsonData = {};
	
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

	public static var globalVars:Map<String, Dynamic> = null;

	public static function init()
	{
		globalVars = [];
		
		Lib.application.window.title = data.title;

		DesktopAPI.setWindowTitle();
		
		final windowColor:FlxColor = ColorUtil.colorFromString(data.windowColor);

		DesktopAPI.setWindowBorderColor(windowColor.red, windowColor.green, windowColor.blue);

		AppUtil.resizeGame(data.width, data.height);
	}
}