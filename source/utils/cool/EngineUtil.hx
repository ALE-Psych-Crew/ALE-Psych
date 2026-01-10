package utils.cool;

import core.Main;
import core.config.MainState;
import core.plugins.ALEPluginsHandler;

import openfl.ui.Mouse;
import openfl.Lib;

import lime.graphics.Image;

class EngineUtil
{
	public static function resetEngine():Void
	{
		if (MainState.debugCounter != null)
		{
			MainState.debugCounter.destroy();

			FlxG.game.removeChild(MainState.debugCounter);
		}

		DiscordRPC.shutdown();

		CoolVars.skipTransIn = CoolVars.skipTransOut = true;

		if (ScriptState.instance != null)
			ScriptState.instance.destroyScripts();

		if (ScriptSubState.instance != null)
			ScriptSubState.instance.destroyScripts();

		if (FlxG.state.subState != null)
			FlxG.state.subState.close();

		for (key in CoolVars.globalVars.keys())
			CoolVars.globalVars.remove(key);

		#if WINDOWS_API
		winapi.WindowsAPI.resetWindowsFuncs();
		#end

		FlxG.mouse.visible = true;

		FlxTween.globalManager.clear();

		FlxG.camera.bgColor = FlxColor.BLACK;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();

			FlxG.sound.music = null;
		}

		core.backend.Mods.init();

		FlxG.resetGame();

		#if desktop
		Mouse.cursor = ARROW;
		#end
		
        ALEPluginsHandler.finish();
	}

	public static function resizeGame(width:Int, height:Int, ?centerWindow:Bool = true, ?scale:Float = 1)
	{
		for (camera in FlxG.cameras.list)
		{
			camera.width = FlxG.width;
			camera.height = FlxG.height;
		}

		Reflect.setProperty(FlxG, 'initialWidth', width);
		Reflect.setProperty(FlxG, 'initialHeight', height);

		FlxG.resizeGame(width, height);
		FlxG.resizeWindow(Math.floor(width / scale), Math.floor(height / scale));

		#if !mobile
		FlxG.fullscreen = false;

		if (centerWindow)
		{
			Lib.application.window.x = Std.int((Lib.application.window.display.bounds.width - Lib.application.window.width) / 2);
			Lib.application.window.y = Std.int((Lib.application.window.display.bounds.height - Lib.application.window.height) / 2);
		}
		#end

		for (camera in FlxG.cameras.list)
		{
			camera.width = width;
			camera.height = height;
		}
	}
}
