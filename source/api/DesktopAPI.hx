package api;

import openfl.Lib;

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
	public static function setWindowTitle()
	{
		#if ALLOW_WINDOWS_API
		winapi.WindowsCPP.reDefineMainWindowTitle(lime.app.Application.current.window.title);
		#end
	}

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