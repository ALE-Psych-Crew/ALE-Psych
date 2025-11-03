package scripting.lua.callbacks;

import cpp.WindowsAPI;

#if WINDOWS_API
import winapi.WindowsAPI.MessageBoxIcon;
#end

class LuaWindowsAPI extends LuaPresetBase
{
	public function new(lua:LuaScript)
	{
		super(lua);

		/**
		 * 
		 */
		set('showMessageBox', function(caption:String, message:String, ?icon:#if WINDOWS_API MessageBoxIcon #else Int #end)
		{
			WindowsAPI.showMessageBox(caption, message, icon);
		});

		/**
		 * 
		 */
		set('setWindowBorderColor', function(r:Int, g:Int, b:Int)
		{
			WindowsAPI.setWindowBorderColor(r, g, b);
		});

		/**
		 * 
		 */
		set('clearTerminal', function()
		{
			WindowsAPI.clearTerminal();
		});

		/**
		 * 
		 */
		set('showConsole', function()
		{
			WindowsAPI.showConsole();
		});

		/**
		 * 
		 */
		set('sendNotification', function(title:String, desc:String)
		{
			WindowsAPI.sendNotification(title, desc);
		});

		/**
		 * 
		 */
		set('reDefineMainWindowTitle', function(windowTitle:String)
		{
			WindowsAPI.reDefineMainWindowTitle(windowTitle);
		});
	}
}