package utils.cool;

import flixel.system.scaleModes.RatioScaleMode;

import sys.thread.Thread;

import openfl.Lib;

import core.Main;

class AppUtil
{
	public static function resetGame()
	{
		Main.preResetConfig();

		FlxG.resetGame();
	}

	public static function createSafeThread(func:Void -> Void):Thread
	{
		return Thread.create(function()
		{
			try {
				func();
			} catch(e) {
				debugTrace(e.details(), ERROR);
			}
		});
	}
	
	@:access(flixel.FlxG)
	public static function resizeGame(width:Int, height:Int, ?centerWindow:Bool = true, ?scale:Float = 1)
	{
		final previousFullscreen:Bool = FlxG.fullscreen;

		FlxG.initialWidth = width;
		FlxG.initialHeight = height;

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

		FlxG.scaleMode = new RatioScaleMode();

		#if !mobile
		FlxG.fullscreen = previousFullscreen;
		#end
	}
}
