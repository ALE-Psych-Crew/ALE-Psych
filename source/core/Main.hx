package core;

import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;

import haxe.io.Path;

import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

import lime.app.Application;

import core.config.MainState;
import core.config.CopyState;

#if linux
import lime.graphics.Image;
#end

#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;

import haxe.CallStack;
import haxe.io.Path;
#end

import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

#if android
import android.content.Context as AndroidContext;
import android.os.Environment as AndroidEnvironment;
import android.Permissions as AndroidPermissions;
import android.os.Build.VERSION as AndroidVersion;
import android.Settings as AndroidSettings;
import android.os.Build.VERSION_CODES as AndroidVersionCode;

import lime.system.System as LimeSystem;

import sys.FileSystem;
#end

#if (windows && cpp)
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
@:cppInclude('./cpp/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

class Main extends Sprite
{
	@:allow(utils.cool.EngineUtil)
	private static var game = {
		width: 1280,
		height: 720,
		initialState: #if mobile CopyState #else MainState #end,
		zoom: -1.0,
		framerate: 60,
		skipSplash: true,
		startFullscreen: false
	};

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		#if android
		requestPermissions();

		Sys.setCwd(Path.addTrailingSlash(AndroidContext.getObbDir()));
		#end

		#if ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		#if (windows && cpp)
		untyped __cpp__("SetProcessDPIAware();");

		FlxG.stage.window.borderless = true;
		FlxG.stage.window.borderless = false;

		Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
		Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
		#end

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	#if android
	@:unreflective static function requestPermissions():Void
	{
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.M)
			checkPermissions();

		try
		{
			if (!FileSystem.exists(AndroidContext.getObbDir()))
				FileSystem.createDirectory(AndroidContext.getObbDir());
		} catch (e:Dynamic) {
			CoolUtil.showPopUp('Error', 'Please create directory to\n' + AndroidContext.getObbDir() + '\nPress OK to close the game');

			LimeSystem.exit(1);
		}
	}

	@:unreflective static function checkPermissions()
	{
		var isAPI33 = AndroidVersion.SDK_INT >= AndroidVersionCode.TIRAMISU;
		
		var hasReadExternal:Bool = false;
		
		for (perm in ['MANAGE_APP_ALL_FILES_ACCESS_PERMISSION'].concat(isAPI33 ? ['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE'] : []))
		{
			if (AndroidPermissions.getGrantedPermissions().contains(perm))
			{
				hasReadExternal = true;

				break;
			}
		}

		if (!hasReadExternal)
		{
			if (!isAPI33)
				AndroidPermissions.requestPermissions(['READ_EXTERNAL_STORAGE', 'WRITE_EXTERNAL_STORAGE']);

			AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
		}
	}
	#end

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
		
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);

		Lib.application.window.onClose.add(function()
			{
				CoolUtil.save?.save();		
			}
		);
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		#if (openfl <= "9.2.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;
		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
		#else
		if (game.zoom == -1.0)
			game.zoom = 1.0;
		#end
	
		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if html5
		FlxG.autoPause = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
		
		Lib.application.window.onClose.add(function()
			{
				CoolUtil.save?.save();
			}
		);

		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				if (cam != null && cam.filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
			}

			if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
		});

		#if VIDEOS_ALLOWED
		hxvlc.util.Handle.init(#if (hxvlc >= "1.8.0") ['--no-lua'] #end);
		#end
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	#if CRASH_HANDLER
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
		cpp.WindowsAPI.showMessageBox('ALE Psych ' + CoolVars.engineVersion + ' | Crash Handler', errMsg, ERROR);
		#else
		Application.current.window.alert(errMsg, 'ALE Psych ' + CoolVars.engineVersion + ' | Crash Handler');
		#end

		debugTrace(errMsg, ERROR);

		DiscordRPC.shutdown();

		Sys.exit(1);
	}
	#end

	@:unreflective static var visibleConsole:Bool = false;
    
    function onKeyPressed(event:KeyboardEvent)
    {
		var key = CoolUtil.openFLToFlixelKey(event);

		if (event.ctrlKey && event.shiftKey)
		{
			if (!Std.isOfType(FlxG.state, funkin.states.PlayState))
			{
				if (Mods.UNIQUE_MOD == null)
				{
					if (ClientPrefs.controls.engine.switch_mod.contains(key))
					{
							if (FlxG.state.subState != null)
								FlxG.state.subState.close();

							CoolUtil.openSubState(new funkin.substates.ModsMenuSubState());
					}
				}

				if (ClientPrefs.controls.engine.reset_game.contains(key))
					CoolUtil.resetEngine();
			}
		}

		#if WINDOWS_API
		if (key == FlxKey.F2)
		{
			if (!visibleConsole)
				cpp.WindowsAPI.showConsole();
			
			visibleConsole = true;
		}
		#end
    }
}
