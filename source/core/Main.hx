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

#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;

import haxe.CallStack;
#end

import funkin.debug.DebugCounter;

import core.config.MainState;

import core.backend.ALESoundTray;
import core.plugins.*;
import core.ALEGame;

import scripting.haxe.HScriptConfig;

import lime.graphics.Image;

#if android
import extension.androidtools.os.Environment as AndroidEnvironment;
import extension.androidtools.Permissions as AndroidPermissions;
import extension.androidtools.os.Build.VERSION as AndroidVersion;
import extension.androidtools.Settings as AndroidSettings;
import extension.androidtools.os.Build.VERSION_CODES as AndroidVersionCode;
#end

#if mobile
import openfl.Assets as OpenFLAssets;
import openfl.utils.ByteArray;

import sys.FileSystem;
import sys.io.File;

import haxe.Exception;
#end

import api.DesktopAPI;
import api.MobileAPI;

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

		preOnceConfig();
		
		addChild(new ALEGame(MainState));

		postOnceConfig();
	}

	@:unreflective function preOnceConfig()
	{
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if android
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.M)
		{
			if (AndroidVersion.SDK_INT < AndroidVersionCode.TIRAMISU)
				AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

			if (!AndroidEnvironment.isExternalStorageManager())
				AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}

		Sys.sleep(1);
		
		final androidPath:String = AndroidEnvironment.getExternalStorageDirectory() + '/.' + Lib.application?.meta?.get('file');

		if (!FileSystem.exists(androidPath))
			FileSystem.createDirectory(androidPath);

		Sys.setCwd(Path.addTrailingSlash(androidPath));
		#end
	}

	@:unreflective function postOnceConfig()
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

		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
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

        Conductor.destroy();
		
		ALEPluginsHandler.destroy();

		CoolVars.reset();

		debugCounter?.destroy();

		FlxG.game.removeChild(debugCounter);
    }

	public static var debugCounter:DebugCounter;
	
	public static var debugPrintPlugin:DebugPrintPlugin;

	public static var mobileControlsPlugin:MobileControlsPlugin;

	@:unreflective static var allowMobileConfig:Bool = true;

    @:unreflective public static function postResetConfig()
    {
		if (allowMobileConfig)
		{
			#if mobile
			final textExtensions:Array<String> = ['ini', 'txt', 'xml', 'hx', 'lua', 'json', 'frag', 'vert'];

			final localFiles:Array<String> = OpenFLAssets.list().filter(file -> !FileSystem.exists(file));

			for (file in localFiles)
			{
				final directory:String = Path.directory(file);

				try
				{
					if (OpenFLAssets.exists(file))
					{
						if (!FileSystem.exists(directory))
							FileSystem.createDirectory(directory);

						if (textExtensions.contains(Path.extension(file)))
							File.saveContent(file, OpenFLAssets.getText(file));
						else
							File.saveBytes(file, ['otf', 'ttf'].contains(Path.extension(file)) ? ByteArray.fromFile(file) : OpenFLAssets.getBytes(file));
					} else {
						debugTrace(file, MISSING_FILE);
					}
				} catch (e:Exception) {}
			}
			#end

			allowMobileConfig = false;
		}

		CoolUtil.destroy();

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

		Paths.clear(true);

		Paths.initMod();

        CoolVars.loadMetadata();

        Paths.init();

        CoolUtil.init();

        Conductor.init();

		HScriptConfig.config();

		ALEPluginsHandler.init();

		Lib.current.stage.window.setIcon(Paths.library.getImage(CoolVars.data.icon + '.png'));

		final soundTray:ALESoundTray = cast FlxG.game.soundTray;

		if (soundTray != null)
		{
			soundTray.font = Paths.font('jetbrains.ttf');
			soundTray.sound = Paths.sound('tick');
		}

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

		if (CoolVars.mobile)
			ALEPluginsHandler.add(mobileControlsPlugin = new MobileControlsPlugin());

		MobileAPI.setOrientation(LANDSCAPE);
    }

	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
	
		#if WINDOWS_API
		DesktopAPI.showMessageBox('ALE Psych ' + CoolVars.engineVersion + ' | Crash Handler', errMsg, ERROR);
		#else
		Application.current.window.alert(errMsg, 'ALE Psych ' + CoolVars.engineVersion + ' | Crash Handler');
		#end

		debugTrace(errMsg, ERROR);

		Discord.destroy();

		#if WINDOWS_API
		winapi.WindowsAPI.resetWindowsFuncs();
		#end

		Sys.exit(1);
	}
}
