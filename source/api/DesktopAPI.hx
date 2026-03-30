package api;

#if WINDOWS_API
@:buildXml('
<target id="haxe">
    <lib name="psapi.lib"/>
</target>
')
@:cppFileCode('
#include <windows.h>
#include <psapi.h>
')
#end
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
	#if WINDOWS_API
	@:functionCode('
    PROCESS_MEMORY_COUNTERS_EX pmc;

    if (GetProcessMemoryInfo(GetCurrentProcess(), (PROCESS_MEMORY_COUNTERS*) &pmc, sizeof(pmc)))
        return (double) pmc.PrivateUsage;

    return 0;
	')
	#end
	public static function getTaskMemory():Null<Float>
		return null;
	
	public static function setWindowTitle()
	{
		#if WINDOWS_API
		winapi.WindowsCPP.reDefineMainWindowTitle(lime.app.Application.current.window.title);
		#end
	}
}