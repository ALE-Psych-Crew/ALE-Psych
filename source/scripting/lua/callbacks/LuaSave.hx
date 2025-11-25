package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

import flixel.util.FlxSave;

class LuaSave extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('flushSaveData', function(name:String)
        {
            cast(Reflect.getProperty(CoolUtil.save, name), FlxSave).flush();
        });

        set('getDataFromSave', function(name:String, variable:String):Dynamic
        {
            var result = cast(Reflect.getProperty(CoolUtil.save, name), FlxSave).data;

            var split:Array<String> = variable.split('.');

            for (sp in split)
                result = Reflect.getProperty(result, sp);

            return result;
        });

        set('setDataFromSave', function(name:String, values:Any)
        {
            setMultiProperty(cast(Reflect.getProperty(CoolUtil.save, name), FlxSave).data, values);
        });

        set('eraseSaveData', function(name:String)
        {
            cast(Reflect.getProperty(CoolUtil.save, name), FlxSave).erase();
        });
    }
}
