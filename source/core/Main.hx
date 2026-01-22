package core;

import haxe.io.Path;
import haxe.Http;

import lime.app.Application;

import openfl.display.Sprite;
import openfl.ui.Mouse;
import openfl.Lib;

import ale.ui.ALEUIUtils;

#if LUA_ALLOWED
import hxluajit.wrapper.LuaError;
#end

import funkin.debug.DebugCounter;

import core.config.MainState;

import core.backend.ALESoundTray;
import core.plugins.*;
import core.ALEGame;

import scripting.haxe.HScriptConfig;

import lime.graphics.Image;

#if WINDOWS_API
@:buildXml('
<target id="haxe">
	<lib name="wininet.lib" if="windows" />
	<lib name="dwmapi.lib" if="windows" />
</target>
')

@:cppFileCode('
#include <windows.h>
#include <winuser.h>
#pragma comment(lib, "Shell32.lib")
extern "C" HRESULT WINAPI SetCurrentProcessExplicitAppUserModelID(PCWSTR AppID);
')
#end

#if linux
@:cppInclude('./config/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	@:allow(utils.CoolVars)
	@:unreflective private static var onlineVersion:String = '';

	@:unreflective public function new()
	{
		super();
		
		addChild(new ALEGame(MainState));

		onceConfig();
	}

	@:unreflective function onceConfig()
	{
		#if WINDOWS_API
		untyped __cpp__("SetProcessDPIAware();");

		FlxG.stage.window.borderless = true;
		FlxG.stage.window.borderless = false;

		Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
		Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
		#end

		#if desktop
		var origin:String = #if hl Sys.getCwd() #else Sys.programPath() #end;

		var configPath:String = Path.directory(Path.withoutExtension(origin));

		#if mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#else
		configPath += "/plugins/alsoft.conf";
		#end

		Sys.putEnv("ALSOFT_CONF", configPath);
		#end

		return;
		
		try
		{
			var http = new Http('https://raw.githubusercontent.com/ALE-Psych-Crew/ALE-Psych/main/githubVersion.txt');

			http.onData = function (data:String)
			{
				onlineVersion = data.split('\n')[0].trim();
			}
			
			http.onError = (error) -> {
				debugTrace('During the game version check: $error', ERROR);
			}

			http.request();
		} catch (e:Dynamic) {
			debugTrace('During the game version check: ' + e.message, ERROR);
		}
	}

	public static var debugCounter:DebugCounter;
	
	public static var debugPrintPlugin:DebugPrintPlugin;

    @:unreflective public static function preResetConfig()
    {
		#if WINDOWS_API
		winapi.WindowsAPI.resetWindowsFuncs();
		#end

		#if desktop
		Mouse.cursor = ARROW;
		#end

		if (FlxG.state.subState != null)
			FlxG.state.subState.close();

		FlxTween.globalManager.clear();

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();

			FlxG.sound.music = null;
		}

        CoolUtil.destroy();
		
        Conductor.destroy();
		
		ALEPluginsHandler.destroy();

		CoolVars.reset();

		debugCounter?.destroy();

		FlxG.game.removeChild(debugCounter);
    }

    @:unreflective public static function postResetConfig()
    {
        FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		FlxG.mouse.visible = true;
      
		FlxG.mouse.unload();

		FlxG.mouse.useSystemCursor = true;

		Paths.clearEngineCache(true);

        CoolUtil.init();

		Paths.initMod();

        CoolVars.loadMetadata();

        Paths.init();

        Conductor.init();

		HScriptConfig.config();

		ALEPluginsHandler.init();

		Lib.current.stage.window.setIcon(Paths.library.getImage(CoolVars.data.icon + '.png'));

		final soundTray:ALESoundTray = cast FlxG.game.soundTray;

		soundTray.font = Paths.font('jetbrains.ttf');
		soundTray.sound = Paths.sound('tick');

		ALEUIUtils.OBJECT_SIZE = 25;
		ALEUIUtils.FONT = Paths.font('jetbrains.ttf');
		ALEUIUtils.COLOR = FlxColor.fromRGB(50, 70, 100);
		ALEUIUtils.OUTLINE_COLOR = FlxColor.WHITE;

		#if LUA_ALLOWED
		LuaError.errorHandler = (e:String) -> {
			debugTrace(e, ERROR);
		};

		Sys.putEnv('LUA_PATH', Sys.getCwd() + '/' + Paths.mods + '/' + Paths.mod + '/scripts/modules/?.lua;');
		#end

		FlxG.game.addChild(debugCounter = new DebugCounter(Paths.exists('data/debug') ? cast Paths.json('data/debug').fields : []));
		
		if (CoolVars.data.allowDebugPrint && CoolVars.data.developerMode)
			ALEPluginsHandler.add(debugPrintPlugin = new DebugPrintPlugin());
    }
}
