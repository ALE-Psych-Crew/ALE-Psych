package core;

import openfl.events.UncaughtErrorEvent;
import openfl.display.Sprite;
import openfl.Lib;

import flixel.FlxGame;

import haxe.CallStack;

#if ALLOW_WINDOWS_API
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

@:unreflective
class Main extends Sprite
{
	public function new()
	{
		super();

		preConfig();
		
		addChild(new FunkinGame(MainState));

		postConfig();
	}

	static function preConfig()
	{
		#if ALLOW_CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (error) -> {
			var errorMessage:String = '';

			for (stackItem in CallStack.exceptionStack(true))
			{
				switch (stackItem)
				{
					case FilePos(_, file, line, _):
						errorMessage += file + ':' + line;
					default:
						Sys.println(stackItem);
				}
			}

			errorMessage += '\n' + error.error;
			
			Lib.application.window.alert(errorMessage, 'ALE Psych ' + CoolVars.engineVersion + ' | Crash Handler');

			Sys.println(errorMessage);

			Sys.exit(1);
		});
		#end
	}

	static function postConfig()
	{
		#if ALLOW_WINDOWS_API
		untyped __cpp__('SetProcessDPIAware();');

		FlxG.stage.window.borderless = true;
		FlxG.stage.window.borderless = false;

		Lib.application.window.x = Std.int((Lib.application.window.display.bounds.width - Lib.application.window.width) / 2);
		Lib.application.window.y = Std.int((Lib.application.window.display.bounds.height - Lib.application.window.height) / 2);
		#end
	}

	@:allow(core.MainState)
	static function postResetConfig()
	{
		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		FlxG.mouse.unload();
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;
	}
}