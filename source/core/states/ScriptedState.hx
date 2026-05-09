package core.states;

import core.enums.ScriptCallType;

import core.interfaces.IScriptedState;
import core.interfaces.IScript;

import core.debug.HotReloading;

#if ALLOW_HSCRIPT
import scripting.haxe.HScript;

import ale.rulescript.RuleScriptGlobal;

import rulescript.Context;
#end

class ScriptedState extends MusicBeatState implements IScriptedState
{
    public var scripts:Array<IScript> = [];

    #if ALLOW_HSCRIPT
    public var haxeScripts:Array<HScript> = [];

    public var haxeScriptsContext:Context;

    public function loadHScript(path:String, ?args:Array<Dynamic>)
    {
        final fullPath:String = path + RuleScriptGlobal.SCRIPT_EXTENSION;

        if (Paths.exists(fullPath))
        {
            final script:HScript = new HScript(path, haxeScriptsContext, args, STATE);

            HotReloading.add(fullPath);
            
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
        #if ALLOW_HSCRIPT
        if (path.endsWith('.hx'))
        {
            loadHScript(path.substring(0, path.length - 3), haxeArgs);

            return;
        }
        #end

        #if ALLOW_HSCRIPT
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

        globalArgs ??= [];

        #if ALLOW_HSCRIPT
        hxArgs ??= [];

        result = result.concat(callOnHScripts(Std.string(type) + id, globalArgs.concat(hxArgs)));
        #end

        return !result.contains(CoolVars.Function_Stop);
    }

    public function destroyScripts()
    {
        scripts = null;
        
        #if ALLOW_HSCRIPT
        haxeScripts = null;

        haxeScriptsContext = null;
        #end
    }

    override function create()
    {
        super.create();

        if (CoolVars.data.hotReloading && CoolVars.data.developerMode)
            FlxG.autoPause = false;
    }

    override function destroy()
    {
        super.destroy();

        if (CoolVars.data.hotReloading && CoolVars.data.developerMode)
            FlxG.autoPause = true;
    }
}