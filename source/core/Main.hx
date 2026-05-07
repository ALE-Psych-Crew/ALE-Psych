package core;

import openfl.events.UncaughtErrorEvent;
import openfl.display.Sprite;
import openfl.Lib;

import flixel.FlxGame;

import haxe.CallStack;

@:unreflective
class Main extends Sprite
{
	public function new()
	{
		super();

		preConfig();
		
		addChild(new FlxGame(0, 0, MainState, true));

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