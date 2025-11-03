package cpp;

#if WINDOWS_API
import winapi.WindowsCPP;
import winapi.WindowsAPI as WinAPI;
import winapi.WindowsAPI.MessageBoxIcon;
import winapi.WindowsTerminalCPP;
#end

class WindowsAPI
{
	/*
	public static function screenCapture(path:String)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsCPP.windowsScreenShot(path);
		#end
	}
	*/

	public static function showMessageBox(caption:String, message:String, icon:#if WINDOWS_API MessageBoxIcon = WARNING #else Int = 0 #end)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsCPP.showMessageBox(caption, message, icon);
		#end
	}

	/*
	public static function setWindowVisible(mode:Bool)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsCPP.setWindowVisible(mode);
		#end
	}
	*/

	public static function setWindowBorderColor(r:Int, g:Int, b:Int)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsCPP.setWindowBorderColor(r, g, b);
		#end
	}

	/*
	public static function hideTaskbar(hide:Bool)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsCPP.hideTaskbar(hide);
		#end
	}
	
	public static function hideDesktopIcons(hide:Bool)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsCPP.hideDesktopIcons(hide);
		#end
	}

	public static function setTaskBarAlpha(alpha:Float)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsCPP._setTaskBarAlpha(alpha);
		#end
	}
	*/

	public static function clearTerminal()
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.clearTerminal();
		#end
	}

	public static function showConsole()
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.allocConsole();
		#end
	}

	/*
	public static function hideMainWindow()
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.hideMainWindow();
		#end
	}

	public static function setConsoleTitle(title:String)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.setConsoleTitle(title);
		#end
	}

	public static function setConsoleWindowIcon(path:String)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.setConsoleWindowIcon(path);
		#end
	}

	public static function centerConsoleWindow()
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.centerConsoleWindow();
		#end
	}

	public static function disableResizeConsoleWindow()
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.disableResizeConsoleWindow();
		#end
	}

	public static function disableCloseConsoleWindow()
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.disableCloseConsoleWindow();
		#end
	}

	public static function maximizeConsoleWindow()
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.maximizeConsoleWindow();
		#end
	}

	public static function getConsoleWindowWidth():Int
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		return WindowsTerminalCPP.returnConsoleWindowWidth();
		#else
		return 0;
		#end
	}

	public static function getConsoleWindowHeight():Int
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		return WindowsTerminalCPP.returnConsoleWindowHeight();
		#else
		return 0;
		#end
	}

	public static function setConsoleCursorPosition(x:Int, y:Int)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.setConsoleCursorPosition(x, y);
		#end
	}

	public static function getConsoleCursorPositionInX():Int
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		return WindowsTerminalCPP.getConsoleCursorPositionInX();
		#else
		return 0;
		#end
	}

	public static function getConsoleCursorPositionInY():Int
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		return WindowsTerminalCPP.getConsoleCursorPositionInY();
		#else
		return 0;
		#end
	}

	public static function setConsoleWindowPositionX(posX:Int)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.setConsoleWindowPositionX(posX);
		#end
	}

	public static function setConsoleWindowPositionY(posY:Int)
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.setConsoleWindowPositionY(posY);
		#end
	}

	public static function hideConsoleWindow()
	{
		#if WINDOWS_API
		reDefineMainWindowTitle(lime.app.Application.current.window.title);
		WindowsTerminalCPP.hideConsoleWindow();
		#end
	}
	*/

	public static function sendNotification(title:String, desc:String)
	{
		#if WINDOWS_API
		WinAPI.sendWindowsNotification(title, desc);
		#end
	}

	public static function reDefineMainWindowTitle(windowTitle:String)
	{
		#if WINDOWS_API
		WindowsCPP.reDefineMainWindowTitle(windowTitle);
		#end
	}
}