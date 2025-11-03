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
         * Creates an instance of a RuleScript-enabled class
         *
         * @param tag Instance ID
         * @param path RuleScript path
         * @param args Arguments for the instance constructor
         */
        set('createScriptedInstance', function(tag:String, path:String, ?args:Array<Dynamic>)
        {
            setTag(tag, RuleScript.createScriptedInstance(path, args));
        });
    }
}
#end
