package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

class LuaDebug extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('debugTrace', function (text:Dynamic, ?type:String, ?allowTrace:Bool, ?allowPrint:Bool) {
            Logs.debugTrace(text, type, allowTrace, allowPrint);
        });

        set('debugPrint', function (text:Dynamic, ?type:String) {
            Logs.debugPrint(text, type);
        });

        set('showPopUp', function (title:String, message:String, ?icon:Int) {
            Logs.popUp(title, message, icon);
        });
    }
}
