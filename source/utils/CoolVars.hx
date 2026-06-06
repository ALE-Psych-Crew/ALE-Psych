package utils;

import api.DesktopAPI;

import core.structures.MetaData;
import core.Main;

import utils.cool.ColorUtil;
import utils.cool.AppUtil;

import openfl.Lib;

class CoolVars
{
	public static var skipTransIn:Bool = false;
	public static var skipTransOut:Bool = false;
	
	public static var meta:MetaData = null;
	
	public static var data(get, never):MetaData;
	static function get_data():MetaData
		return meta;

	public static var BUILD_TARGET(get, never):String;
	static function get_BUILD_TARGET():String
		return #if windows 'windows' #elseif linux 'linux' #elseif mac 'mac' #elseif ios 'ios' #elseif android 'android' #else 'unknown' #end;

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

		meta = {};

		if (Paths.exists('data/meta.json'))
		{
			final json = Paths.json('data/meta');

			for (field in Reflect.fields(json))
				if (Reflect.field(meta, field) != null)
					Reflect.setProperty(meta, field, Reflect.field(json, field));
		}

		Lib.application.window.title = meta.title;

		DesktopAPI.setWindowTitle();
		
		final windowColor:FlxColor = ColorUtil.colorFromString(meta.windowColor);

		DesktopAPI.setWindowBorderColor(windowColor.red, windowColor.green, windowColor.blue);

		AppUtil.resizeGame(meta.width, meta.height);
	}
}