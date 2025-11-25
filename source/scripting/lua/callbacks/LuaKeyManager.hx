package scripting.lua.callbacks;

import flixel.input.keyboard.FlxKey;

import scripting.lua.LuaPresetBase;

import core.backend.MobileControls;

using StringTools;

class LuaKeyManager extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);
    
        set('keyboardJustPressed', function(name:String)
        {
            var keys:Array<FlxKey> = [FlxKey.fromString(name.toUpperCase().trim())];
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyJustPressed(keys);

            #if !mobile return FlxG.keys.anyJustPressed(keys); #end
        });
    
        set('keyboardPressed', function(name:String)
        {
            var keys:Array<FlxKey> = [FlxKey.fromString(name.toUpperCase().trim())];
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyPressed(keys);

            #if !mobile return FlxG.keys.anyPressed(keys); #end
        });
    
        set('keyboardReleased', function(name:String)
        {
            var keys:Array<FlxKey> = [FlxKey.fromString(name.toUpperCase().trim())];
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyJustReleased(keys);

            #if !mobile return FlxG.keys.anyJustReleased(keys); #end
        });

        set('keyJustPressed', function(group:String, name:String)
        {
            var keys:Array<FlxKey> = Reflect.getProperty(Reflect.getProperty(ClientPrefs.controls, group), name);
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyJustPressed(keys);

            #if !mobile return FlxG.keys.anyJustPressed(keys); #end
        });

        set('keyPressed', function(group:String, name:String)
        {
            var keys:Array<FlxKey> = Reflect.getProperty(Reflect.getProperty(ClientPrefs.controls, group), name);
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyPressed(keys);

            #if !mobile return FlxG.keys.anyPressed(keys); #end
        });

        set('keyReleased', function(group:String, name:String)
        {
            var keys:Array<FlxKey> = Reflect.getProperty(Reflect.getProperty(ClientPrefs.controls, group), name);
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyJustReleased(keys);

            #if !mobile return FlxG.keys.anyJustReleased(keys); #end
        });
    }
}
