package utils;

import cpp.WindowsAPI;

import core.structures.ALEData;
import core.Main;

import utils.cool.EngineUtil;

import sys.FileSystem;
import sys.io.File;

import openfl.Lib;

@:build(core.macros.CoolVarsMacro.build())
class CoolVars
{
	public static var skipTransIn:Bool = false;
	public static var skipTransOut:Bool = false;

	public static var engineVersion(get, never):String;

	public static function get_engineVersion():String
		return Lib.application?.meta?.get('version') ?? '';

	public static var onlineVersion(get, never):String;

	public static function get_onlineVersion():String
		return Main.onlineVersion;

	public static var globalVars:Map<String, Dynamic> = new Map<String, Dynamic>();

	public static final BUILD_TARGET:String = #if windows 'windows' #elseif linux 'linux' #elseif mac 'mac' #elseif ios 'ios' #elseif android 'android' #else 'unknown' #end;

	public static final Function_Stop:String = '##_ALE_PSYCH_LUA_FUNCTION_STOP_##';
	public static final Function_Continue:String = '##_ALE_PSYCH_LUA_FUNCTION_CONTINUE_##';

	public static var data:ALEData = null;
	
	public static function loadMetadata()
	{
		data = {
			developerMode: false,
			mobileDebug: false,
			scriptsHotReloading: false,

			verbose: false,
			allowDebugPrint: true,

			initialState: 'TitleState',
			freeplayState: 'FreeplayState',
			storyMenuState: 'StoryMenuState',
			masterEditorState: 'MasterEditorState',
			mainMenuState: 'MainMenuState',
			optionsState: 'OptionsState',

			loadDefaultWeeks: true,

			pauseSubState: 'PauseSubState',
			gameOverScreen: 'GameOverSubState',
			transition: 'FadeTransition',

			title: 'Friday Night Funkin\': ALE Psych',
			icon: 'images/appIcon',
			width: 1280,
			height: 720,

            paths: [],

            dependencies: [],

			windowColor: [33, 33, 33],

			bpm: 102.0,

			discordID: '1309982575368077416',

			discordButtons: [
				{
					label: 'ALE Psych Website',
					url: 'https://ale-psych-crew.github.io/ALE-Psych-Website/'
				}
			],

			modID: null
		};

		var json:Null<ALEData> = null;

		for (path in [Paths.mods + '/' + Paths.mod, Paths.assets])
			if (FileSystem.exists(path + '/data/data.json'))
				json = cast Json.parse(File.getContent(path + '/data/data.json'));

		for (field in Reflect.fields(json))
			if (Reflect.field(data, field) != null)
				Reflect.setField(data, field, Reflect.field(json, field));
		
		FlxG.stage.window.title = CoolVars.data.title;

		WindowsAPI.setWindowTitle();

		WindowsAPI.setWindowBorderColor(CoolVars.data.windowColor[0], CoolVars.data.windowColor[1], CoolVars.data.windowColor[2]);

		EngineUtil.resizeGame(CoolVars.data.width, CoolVars.data.height);
	}

    public static function reset()
    {
		globalVars.clear();
    }
}