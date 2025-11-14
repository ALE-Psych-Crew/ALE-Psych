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
    
        /**
         * Defines if a key has been pressed
         * 
         * @param name Key name
         * 
         * @return Whether the key has been pressed
         */
        set('keyboardJustPressed', function(name:String)
        {
            var keys:Array<FlxKey> = [FlxKey.fromString(name.toUpperCase().trim())];
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyJustPressed(keys);

            #if !mobile return FlxG.keys.anyJustPressed(keys); #end
        });
    
        /**
         * Defines if a key is being held down
         * 
         * @param name Key name
         * 
         * @return Whether the key is being held down
         */
        set('keyboardPressed', function(name:String)
        {
            var keys:Array<FlxKey> = [FlxKey.fromString(name.toUpperCase().trim())];
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyPressed(keys);

            #if !mobile return FlxG.keys.anyPressed(keys); #end
        });
    
        /**
         * Defines if a key has been released
         * 
         * @param name Key name
         * 
         * @return Whether the key has been released
         */
        set('keyboardReleased', function(name:String)
        {
            var keys:Array<FlxKey> = [FlxKey.fromString(name.toUpperCase().trim())];
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyJustReleased(keys);

            #if !mobile return FlxG.keys.anyJustReleased(keys); #end
        });

        /**
         * Defines if a key from the options has been pressed. See [ClientPrefs](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/source/core/config/ClientPrefs.hx)
         * 
         * @param group Key group
         * @param name Key ID
         * 
         * @return Whether the key has been pressed
         */
        set('keyJustPressed', function(group:String, name:String)
        {
            var keys:Array<FlxKey> = Reflect.getProperty(Reflect.getProperty(ClientPrefs.controls, group), name);
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyJustPressed(keys);

            #if !mobile return FlxG.keys.anyJustPressed(keys); #end
        });

        /**
         * Defines if a key from the options is being held down. See [ClientPrefs](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/source/core/config/ClientPrefs.hx)
         * 
         * @param group Key group
         * @param name Key ID
         * 
         * @return Whether the key is being held down
         */
        set('keyPressed', function(group:String, name:String)
        {
            var keys:Array<FlxKey> = Reflect.getProperty(Reflect.getProperty(ClientPrefs.controls, group), name);
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyPressed(keys);

            #if !mobile return FlxG.keys.anyPressed(keys); #end
        });

        /**
         * Defines if a key from the options has been released. See [ClientPrefs](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/source/core/config/ClientPrefs.hx)
         * 
         * @param group Key group
         * @param name Key ID
         * 
         * @return Whether the key has been released
         */
        set('keyReleased', function(group:String, name:String)
        {
            var keys:Array<FlxKey> = Reflect.getProperty(Reflect.getProperty(ClientPrefs.controls, group), name);
            
            #if !mobile if (CoolVars.data.mobileDebug && CoolVars.data.developerMode) #end
                return MobileControls.anyJustReleased(keys);

            #if !mobile return FlxG.keys.anyJustReleased(keys); #end
        });
    }
}
