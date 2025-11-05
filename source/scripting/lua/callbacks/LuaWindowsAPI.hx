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
		 * Display a text box from another window
		 * 
		 * @param caption Window name
		 * @param message Text box content
		 * @param icon Text box type
		 */
		set('showMessageBox', function(caption:String, message:String, ?icon:#if WINDOWS_API MessageBoxIcon #else Int #end)
		{
			WindowsAPI.showMessageBox(caption, message, icon);
		});

		/**
		 * Applies a color to the window border
		 * 
		 * @param r Red
		 * @param g Green
		 * @param b Blue
		 */
		set('setWindowBorderColor', function(r:Int, g:Int, b:Int)
		{
			WindowsAPI.setWindowBorderColor(r, g, b);
		});

		/**
		 * Cleans the game terminal/console
		 */
		set('clearTerminal', function()
		{
			WindowsAPI.clearTerminal();
		});

		/**
		 * Shows the game terminal/console
		 */
		set('showConsole', function()
		{
			WindowsAPI.showConsole();
		});

		/**
		 * Displays a notification on the Device
		 */
		set('sendNotification', function(title:String, desc:String)
		{
			WindowsAPI.sendNotification(title, desc);
		});
	}
}