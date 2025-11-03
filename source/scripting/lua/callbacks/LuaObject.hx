package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import flixel.FlxObject;

import flixel.util.FlxAxes;

class LuaObject extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Creates a `FlxObject`
         *
         * @param tag Object ID
         * @param x Position on `x`
         * @param y Position on `y`
         * @param width Object width
         * @param height Object height
         */
        set('makeLuaObject', function(tag:String, ?x:Float, ?y:Float, ?width:Float, ?height:Float)
        {
            setTag(tag, new FlxObject(x, y, width, height));
        });

        /**
         * Centers an object on the screen
         * 
         * @param tag ID of the object
         * @param axes Axes on which it will be centered. Can be `0x00`, `0x01`, `0x11`, `0x10`
         */
        set('screenCenter', function(tag:String, ?axes:FlxAxes)
        {
            if (tagIs(tag, FlxObject))
                getTag(tag).screenCenter(axes ?? FlxAxes.XY);
        });
    }
}
