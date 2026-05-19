package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import flixel.FlxObject;

import flixel.util.FlxAxes;

class LuaObject extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('makeLuaObject', function(tag:String, ?x:Float, ?y:Float, ?width:Float, ?height:Float)
        {
            setTag(tag, new FlxObject(x, y, width, height));
        });

        set('screenCenter', function(tag:String, ?axes:FlxAxes)
        {
            if (tagIs(tag, FlxObject))
                getTag(tag).screenCenter(axes ?? FlxAxes.XY);
        });
    }
}
