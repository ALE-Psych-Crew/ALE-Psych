package api;

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
}