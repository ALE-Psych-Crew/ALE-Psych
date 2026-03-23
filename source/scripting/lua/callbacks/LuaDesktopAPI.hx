package scripting.lua.callbacks;

import api.DesktopAPI;

import winapi.WindowsAPI.MessageBoxIcon;

class LuaDesktopAPI extends LuaPresetBase
{
	public function new(lua:LuaScript)
	{
		super(lua);

		set('showMessageBox', function(caption:String, message:String, ?icon:MessageBoxIcon)
		{
			DesktopAPI.showMessageBox(caption, message, icon);
		});

		set('setWindowBorderColor', function(r:Int, g:Int, b:Int)
		{
			DesktopAPI.setWindowBorderColor(r, g, b);
		});

		set('clearTerminal', function()
		{
			DesktopAPI.clearTerminal();
		});

		set('showConsole', function()
		{
			DesktopAPI.showConsole();
		});

		set('sendNotification', function(title:String, desc:String)
		{
			DesktopAPI.sendNotification(title, desc);
		});
	}
}