package core;

import openfl.events.UncaughtErrorEvent;
import openfl.display.Sprite;
import openfl.ui.Mouse;
import openfl.Lib;

import scripting.haxe.HScriptConfig;

import core.plugins.DebugPrintPlugin;
import core.plugins.PluginsHandler;

import core.debug.HotReloading;

import core.objects.SoundTray;
import core.objects.DebugTray;

import api.DesktopAPI;

import flixel.input.keyboard.FlxKey;
import flixel.FlxGame;

import haxe.CallStack;

import utils.Formatter;

@:unreflective
class Main extends Sprite
{
	public static var game(get, never):Game;
	static function get_game():Game
		return cast FlxG.game;

	public function new()
	{
		super();

		preConfig();
		
		addChild(new Game());

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

		FlxG.stage.addEventListener('keyDown', (event) -> {
			if (event.altKey && event.keyCode == FlxKey.ENTER)
				event.stopImmediatePropagation();
		}, false, 1);
		
		DesktopAPI.setDPIAware();
	}

	static function postConfig()
	{
	}

	@:allow(utils.cool.AppUtil)
	static function preResetConfig()
	{
		DesktopAPI.reset();

		#if desktop
		Mouse.cursor = ARROW;
		#end

		if (FlxG.state.subState != null)
			FlxG.state.subState.close();

		FlxTween.globalManager.clear();

		HotReloading.destroy();

		PluginsHandler.destroy();

		Conductor.destroy();

		game.soundTraySprite?.destroy();
		game.soundTraySprite = null;

		game.debugTray?.destroy();
		game.debugTray = null;
	}

	public static var debugPrintPlugin:DebugPrintPlugin;

	public static var onlineVersion(default, null):String = '';

	@:allow(core.states.MainState)
	static function postResetConfig()
	{
		Lib.application.window.resizable = true;

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
		
		FlxG.keys.preventDefaultKeys = [TAB];

		FlxG.sound.muteKeys = FlxG.sound.volumeDownKeys = FlxG.sound.volumeUpKeys = [];

		FlxG.autoPause = false;

		FlxG.mouse.unload();
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;
		
		Paths.clear(true, true);
		Paths.loadMod();
		Paths.init();
		
		CoolVars.init();

		HotReloading.init();

		Logs.init();

		Defines.init();
		
		PluginsHandler.init();

		HScriptConfig.init();

		Conductor.init();

		Formatter.init();

		if (CoolVars.meta.debugPrint && CoolVars.meta.developerMode)
			PluginsHandler.add(debugPrintPlugin = new DebugPrintPlugin());

		game.addChild(game.soundTraySprite = new SoundTray());

		FlxG.stage.addChild(game.debugTray = new DebugTray());	
	}
}