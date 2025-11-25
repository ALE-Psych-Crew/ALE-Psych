package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import funkin.visuals.mobile.MobileButton;

class LuaMobile extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('makeLuaMobileButton', function(tag:String, ?x:Float, ?y:Float, ?group:String, ?key:String, letter:String, ?width:Float, ?height:Float)
        {
            setTag(tag, new MobileButton(x, y, Reflect.getProperty(Reflect.getProperty(ClientPrefs.controls, group), key), letter, width, height));
        });
    }
}
