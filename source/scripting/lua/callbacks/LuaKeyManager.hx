package scripting.lua.callbacks;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

import scripting.lua.LuaPresetBase;

using StringTools;

class LuaKeyManager extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('keyboardJustPressed', function(name:String)
        {
            return FlxG.keys.anyJustPressed([
                FlxKey.fromString(name.toUpperCase().trim())
            ]);
        });

        set('keyboardPressed', function(name:String)
        {
            return FlxG.keys.anyPressed([
                FlxKey.fromString(name.toUpperCase().trim())
            ]);
        });

        set('keyboardReleased', function(name:String)
        {
            return FlxG.keys.anyJustReleased([
                FlxKey.fromString(name.toUpperCase().trim())
            ]);
        });

        set('keyJustPressed', function(group:String, name:String)
        {
            return FlxG.keys.anyJustPressed(
                ClientPrefs.getControl(group, name)
            );
        });

        set('keyPressed', function(group:String, name:String)
        {
            return FlxG.keys.anyPressed(
                ClientPrefs.getControl(group, name)
            );
        });

        set('keyReleased', function(group:String, name:String)
        {
            return FlxG.keys.anyJustReleased(
                ClientPrefs.getControl(group, name)
            );
        });
    }
}