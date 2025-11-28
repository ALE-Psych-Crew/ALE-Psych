package cpp;

#if WINDOWS_API
import winapi.WindowsCPP;
import winapi.WindowsAPI as WinAPI;
import winapi.WindowsAPI.MessageBoxIcon;
import winapi.WindowsTerminalCPP;
#end

class WindowsAPI
{
	public static function screenCapture(path:String)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsCPP.windowsScreenShot(path);
		#end
	}

	public static function showMessageBox(caption:String, message:String, icon:#if WINDOWS_API MessageBoxIcon = WARNING #else Int = 0 #end)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsCPP.showMessageBox(caption, message, icon);
		#end
	}

	public static function setWindowVisible(mode:Bool)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsCPP.setWindowVisible(mode);
		#end
	}

	public static function setWindowBorderColor(r:Int, g:Int, b:Int)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsCPP.setWindowBorderColor(r, g, b);
		#end
	}

	public static function hideTaskbar(hide:Bool)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsCPP.hideTaskbar(hide);
		#end
	}
	
	public static function hideDesktopIcons(hide:Bool)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsCPP.hideDesktopIcons(hide);
		#end
	}

	public static function setTaskBarAlpha(alpha:Float)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsCPP._setTaskBarAlpha(alpha);
		#end
	}

	public static function clearTerminal()
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.clearTerminal();
		#end
	}

	public static function showConsole()
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.allocConsole();
		#end
	}

	public static function hideMainWindow()
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.hideMainWindow();
		#end
	}

	public static function setConsoleTitle(title:String)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.setConsoleTitle(title);
		#end
	}

	public static function setConsoleWindowIcon(path:String)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.setConsoleWindowIcon(path);
		#end
	}

	public static function centerConsoleWindow()
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.centerConsoleWindow();
		#end
	}

	public static function disableResizeConsoleWindow()
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.disableResizeConsoleWindow();
		#end
	}

	public static function disableCloseConsoleWindow()
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.disableCloseConsoleWindow();
		#end
	}

	public static function maximizeConsoleWindow()
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.maximizeConsoleWindow();
		#end
	}

	public static function getConsoleWindowWidth():Int
	{
		#if WINDOWS_API
		setWindowTitle();

		return WindowsTerminalCPP.returnConsoleWindowWidth();
		#else
		return 0;
		#end
	}

	public static function getConsoleWindowHeight():Int
	{
		#if WINDOWS_API
		setWindowTitle();

		return WindowsTerminalCPP.returnConsoleWindowHeight();
		#else
		return 0;
		#end
	}

	public static function setConsoleCursorPosition(x:Int, y:Int)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.setConsoleCursorPosition(x, y);
		#end
	}

	public static function getConsoleCursorPositionInX():Int
	{
		#if WINDOWS_API
		setWindowTitle();

		return WindowsTerminalCPP.getConsoleCursorPositionInX();
		#else
		return 0;
		#end
	}

	public static function getConsoleCursorPositionInY():Int
	{
		#if WINDOWS_API
		setWindowTitle();

		return WindowsTerminalCPP.getConsoleCursorPositionInY();
		#else
		return 0;
		#end
	}

	public static function setConsoleWindowPositionX(posX:Int)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.setConsoleWindowPositionX(posX);
		#end
	}

	public static function setConsoleWindowPositionY(posY:Int)
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.setConsoleWindowPositionY(posY);
		#end
	}

	public static function hideConsoleWindow()
	{
		#if WINDOWS_API
		setWindowTitle();

		WindowsTerminalCPP.hideConsoleWindow();
		#end
	}

	public static function sendNotification(title:String, desc:String)
	{
		#if WINDOWS_API
		WinAPI.sendWindowsNotification(title, desc);
		#end
	}

	public static function setWindowTitle()
	{
		#if WINDOWS_API
		WindowsCPP.reDefineMainWindowTitle(lime.app.Application.current.window.title);
		#end
	}
}