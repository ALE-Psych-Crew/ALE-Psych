package utils.cool;

import flixel.system.scaleModes.RatioScaleMode;

import openfl.Lib;

class EngineUtil
{
	public static function resizeGame(width:Int, height:Int, ?centerWindow:Bool = true, ?scale:Float = 1)
	{
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

		FlxG.scaleMode = new RatioScaleMode();
	}
}
