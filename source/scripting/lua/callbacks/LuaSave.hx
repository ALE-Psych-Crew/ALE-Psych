package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

import flixel.util.FlxSave;

class LuaSave extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Saves the save files
         * 
         * @param name Save file ID. Can be `preferences`, `score`, `custom`, `controls`
         */
        set('flushSaveData', function(name:String)
        {
            cast(Reflect.getProperty(CoolUtil.save, name), FlxSave).flush();
        });

        /**
         * Gets a value from a save file
         * 
         * @param name Save file ID. Can be `preferences`, `score`, `custom`, `controls`
         * @param variable Variable to look up
         * 
         * @return Variable value
         */
        set('getDataFromSave', function(name:String, variable:String):Dynamic
        {
            var result = cast(Reflect.getProperty(CoolUtil.save, name), FlxSave).data;

            var split:Array<String> = variable.split('.');

            for (sp in split)
                result = Reflect.getProperty(result, sp);

            return result;
        });

        /**
         * Sets a value in a save file
         * 
         * @param name Save file ID. Can be `preferences`, `score`, `custom`, `controls`
         * @param values Table of variables to set or modify
         */
        set('setDataFromSave', function(name:String, values:Any)
        {
            setMultiProperty(cast(Reflect.getProperty(CoolUtil.save, name), FlxSave).data, values);
        });

        /**
         * Deletes the data of a save file
         * 
         * @param name Save file ID. Can be `preferences`, `score`, `custom`, `controls`
         */
        set('eraseSaveData', function(name:String)
        {
            cast(Reflect.getProperty(CoolUtil.save, name), FlxSave).erase();
        });
    }
}
