package core;

import openfl.events.UncaughtErrorEvent;
import openfl.display.Sprite;
import openfl.Lib;

import api.DesktopAPI;

import flixel.FlxGame;

import haxe.CallStack;

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
			final title:String = 'ALE Psych ' + CoolVars.engineVersion + ' | Crash Handler';

			var printMessage:String = '';

			var consoleMessage:String = '\n' + title + '\n';

			for (stackItem in CallStack.exceptionStack(true))
			{
				switch (stackItem)
				{
					case FilePos(item, file, line, _):
						switch (item)
						{
							case Method(className, func):
								printMessage += className + '.' + func + ' - Line ' + line;
							default:
								printMessage += file + ':' + line;
						}

						printMessage += '\n';

						consoleMessage += file + '#' + line + '\n';
					default:
						Sys.println(stackItem);
				}
			}

			final errorMessage:String = '\n' + error.error;

			debugTrace(consoleMessage + errorMessage, PrintType.ERROR);
			
			Logs.popUp(title, printMessage + errorMessage, ERROR);

			Sys.exit(1);
		});
		#end
		
		DesktopAPI.setDPIAware();
	}

	static function postConfig()
	{
	}

	@:allow(core.MainState)
	static function postResetConfig()
	{
		Lib.application.window.resizable = true;

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		FlxG.mouse.unload();
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;

		Paths.init();

		Logs.init();
	}
}