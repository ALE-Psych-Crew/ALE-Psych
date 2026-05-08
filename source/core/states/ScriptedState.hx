package core.states;

import core.enums.ScriptCallType;

import core.interfaces.IScriptedState;
import core.interfaces.IScript;

#if ALLOW_HSCRIPT
import scripting.haxe.HScript;

import ale.rulescript.RuleScriptGlobal;

import rulescript.Context;
#end

class ScriptedState extends State implements IScriptedState
{
    public var scripts:Array<IScript> = [];

    #if ALLOW_HSCRIPT
    public var haxeScripts:Array<HScript> = [];

    public var haxeScriptsContext:Context;

    public function loadHScript(path:String, ?args:Array<Dynamic>)
    {
        if (Paths.exists(path + RuleScriptGlobal.SCRIPT_EXTENSION))
        {
            final script:HScript = new HScript(path, haxeScriptsContext, args, STATE);

            if (!script.failedExecution)
            {
                haxeScripts.push(script);
                
                scripts.push(script);

                debugTrace('"' + path + '.hx" has been Successfully Loaded', HSCRIPT);
            }
        }
    }

    public function setOnHScripts(name:String, value:Dynamic)
        for (script in haxeScripts)
            script.set(name, value);

    public function callOnHScripts(name:String, ?args:Array<Dynamic>):Array<Dynamic>
        return [for (script in haxeScripts) script.call(name, args)];
    #end

    public function loadScript(path:String, ?haxeArgs:Array<Dynamic>)
    {
        #if HSCRIPT_ALLOWED
        if (path.endsWith('.hx'))
        {
            loadHScript(path.substring(0, path.length - 3), haxeArgs);

            return;
        }
        #end

        #if HSCRIPT_ALLOWED
        loadHScript(path, haxeArgs);
        #end
    }

    public function setOnScripts(name:String, value:Dynamic)
        for (script in scripts)
            script.set(name, value);

    public function callOnScripts(name:String, ?args:Array<Dynamic>):Array<Dynamic>
        return [for (script in scripts) script.call(name, args)];

    public function scriptCallbackCall(type:ScriptCallType, id:String, ?globalArgs:Array<Dynamic>, ?hxArgs:Array<Dynamic>):Bool
    {
        var result:Array<Dynamic> = [];

        #if ALLOW_HSCRIPT
        result = result.concat(callOnHScripts(Std.string(type) + id, globalArgs.concat(hxArgs)));
        #end

        return result.contains(CoolVars.Function_Stop);
    }

    public function destroyScripts()
    {
        scripts = null;
        
        #if ALLOW_HSCRIPT
        haxeScripts = null;

        haxeScriptsContext = null;
        #end
    }

    override function destroy()
    {
        destroyScripts();

        super.destroy();
    }
}