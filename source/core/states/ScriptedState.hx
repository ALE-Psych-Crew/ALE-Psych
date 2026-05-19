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

#if ALLOW_LUA
import scripting.lua.LuaScript;
#end

class ScriptedState extends MusicBeatState implements IScriptedState
{
    public static var instance:ScriptedState;

    public var scripts:Array<IScript> = [];

    public function new(?haxeArguments:Array<Dynamic>, ?luaArguments:Array<Dynamic>)
    {
        super();

        #if ALLOW_HSCRIPT
        this.haxeArguments = haxeArguments;
        #end

        #if ALLOW_LUA
        this.luaArguments = luaArguments;
        #end
    }

    #if ALLOW_HSCRIPT
    public var haxeScripts:Array<HScript> = [];

    public var haxeScriptsContext:Context;

    public var haxeArguments:Array<Dynamic>;

    public function loadHScript(path:String, ?args:Array<Dynamic>)
    {
        final fullPath:String = path + RuleScriptGlobal.SCRIPT_EXTENSION;

        if (Paths.exists(fullPath))
        {
            final script:HScript = new HScript(path, haxeScriptsContext, args ?? haxeArguments, STATE);

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

    #if ALLOW_LUA
    public var luaScripts:Array<LuaScript> = [];

    public var luaArguments:Array<Dynamic>;

    public function loadLuaScript(path:String, ?args:Array<Dynamic>)
    {
        final fullPath:String = path + '.lua';

        if (Paths.exists(fullPath))
        {
            HotReloading.add(fullPath);

            try
            {
                final script:LuaScript = new LuaScript(path, args ?? luaArguments, STATE);

                luaScripts.push(script);

                scripts.push(script);

                debugTrace('"' + path + '.lua" has been Successfully Loaded', LUA);
            } catch (error) {
                debugTrace(error.message, ERROR);
            }
        }
    }

    public function setOnLuaScripts(name:String, value:Dynamic):Void
        for (script in luaScripts)
            script.set(name, value);

    public function callOnLuaScripts(name:String, ?args:Array<Dynamic>):Array<Dynamic>
        return [for (script in luaScripts) script.call(name, args)];
    #end

    public function loadScript(path:String, ?haxeArgs:Array<Dynamic>, ?luaArgs:Array<Dynamic>)
    {
        #if ALLOW_HSCRIPT
        if (path.endsWith(RuleScriptGlobal.SCRIPT_EXTENSION))
        {
            loadHScript(path.substring(0, path.length - RuleScriptGlobal.SCRIPT_EXTENSION.length), haxeArgs);

            return;
        }
        #end

        #if ALLOW_LUA
        if (path.endsWith('.lua'))
        {
            loadLuaScript(path.substring(0, path.length - '.lua'.length), luaArgs);

            return;
        }
        #end

        #if ALLOW_HSCRIPT
        loadHScript(path, haxeArgs);
        #end

        #if ALLOW_LUA
        loadLuaScript(path, luaArgs);
        #end
    }

    public function setOnScripts(name:String, value:Dynamic)
        for (script in scripts)
            script.set(name, value);

    public function callOnScripts(name:String, ?args:Array<Dynamic>):Array<Dynamic>
        return [for (script in scripts) script.call(name, args)];

    public function scriptCallbackCall(type:ScriptCallType, id:String, ?globalArgs:Array<Dynamic>, ?hxArgs:Array<Dynamic>, ?luaArgs:Array<Dynamic>):Bool
    {
        var result:Array<Dynamic> = [];

        globalArgs ??= [];

        #if ALLOW_HSCRIPT
        hxArgs ??= [];

        result = result.concat(callOnHScripts(Std.string(type) + id, globalArgs.concat(hxArgs)));
        #end

        #if ALLOW_LUA
        luaArgs ??= [];

        result = result.concat(callOnLuaScripts(Std.string(type) + id, globalArgs.concat(luaArgs)));
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

        #if ALLOW_LUA
        luaScripts = null;
        #end
    }

    override function create()
    {
        instance = this;

        super.create();

        if (CoolVars.meta.hotReloading && CoolVars.meta.developerMode)
            FlxG.autoPause = false;
    }

    override function destroy()
    {
        super.destroy();

        if (CoolVars.meta.hotReloading && CoolVars.meta.developerMode)
            FlxG.autoPause = true;

        instance = null;
    }
}