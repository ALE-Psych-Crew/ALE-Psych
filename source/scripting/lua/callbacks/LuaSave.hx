package scripting.lua.callbacks;

import funkin.config.SaveFile;

class LuaSave extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('saveSaveData', function(name:String)
        {
            cast(Reflect.getProperty(Save, name), SaveFile).save();
        });

        set('getDataFromSave', function(name:String, variable:String):Dynamic
        {
            var result = cast(Reflect.getProperty(Save, name), SaveFile).data;

            var split:Array<String> = variable.split('.');

            for (sp in split)
                result = Reflect.getProperty(result, sp);

            return result;
        });

        set('setDataFromSave', function(name:String, values:Any)
        {
            setMultiProperty(cast(Reflect.getProperty(Save, name), SaveFile).data, values);
        });

        set('deleteSaveData', function(name:String)
        {
            cast(Reflect.getProperty(Save, name), SaveFile).delete();
        });
    }
}