package scripting.lua.callbacks;

#if HSCRIPT_ALLOWED
import scripting.lua.LuaPresetBase;

import rulescript.RuleScript;

using StringTools;

class LuaRuleScript extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Create an instance of a custom class
         *
         * @param tag Instance ID
         * @param path Class Path
         * @param args Arguments for the instance constructor
         */
        set('createScriptedInstance', function(tag:String, path:String, ?args:Array<Dynamic>)
        {
            setTag(tag, RuleScript.createScriptedInstance(path, args));
        });
    }
}
#end
