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

        set('createScriptedInstance', function(tag:String, path:String, ?args:Array<Dynamic>)
        {
            setTag(tag, RuleScript.createScriptedInstance(path, args));
        });
    }
}
#end
