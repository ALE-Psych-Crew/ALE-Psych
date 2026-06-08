package api;

import openfl.Lib;

/**
 * A simple list of functions that connect to the operating system API
 * Designed for Desktop Devices
 * 
 * Most of the functions are located in the Slushi Windows API library
 * @see https://github.com/Slushi-Github/SL-Windows-API/
 */
@:build(core.macros.FunctionsMergeMacro.build(
	[
		'winapi.WindowsAPI',
		'winapi.gdi.WindowsGDI'
	],
	[
		'allocConsole::showConsole',
		'sendWindowsNotification::sendNotification',
		'resetWindowsFuncs::reset'
	]
))
class DesktopAPI 
{
	/**
	 * Set the window name for the API
	 * 
	 * Useful when you rename the window and use any of this class's functions before the game updates the window name in the API
	 */
	public static function setWindowTitle()
	{
		#if ALLOW_WINDOWS_API
		winapi.WindowsCPP.reDefineMainWindowTitle(lime.app.Application.current.window.title);
		#end
	}

	/**
	 * Prevents the game window from appearing out of place when the screen scale is changed
	 */
	public static function setDPIAware()
	{
		#if ALLOW_WINDOWS_API
		setProgramDPIAware();

		FlxG.stage.window.borderless = true;
		FlxG.stage.window.borderless = false;

		Lib.application.window.x = Std.int((Lib.application.window.display.bounds.width - Lib.application.window.width) / 2);
		Lib.application.window.y = Std.int((Lib.application.window.display.bounds.height - Lib.application.window.height) / 2);
		#end
	}
}