package core.backend;

#if HSCRIPT_ALLOWED
import scripting.haxe.HScript;

import rulescript.Context;
#end

#if LUA_ALLOWED
import scripting.lua.LuaScript;
#end

import haxe.Exception;

import core.interfaces.IScriptState;

class ScriptSubState extends MusicBeatSubState implements IScriptState
{
    public static var instance:ScriptSubState;

    #if HSCRIPT_ALLOWED
    public var hScripts:Array<HScript> = [];

    public var hScriptsContext:Context;
    #end

    #if LUA_ALLOWED
    public var luaScripts:Array<LuaScript> = [];
    #end

    public var camGame:FlxCamera;

    public function new()
    {
        #if HSCRIPT_ALLOWED
        hScriptsContext = new Context();
        #end

        super();
    }

    override public function create()
    {
        super.create();

        instance = this;
        
        camGame = FlxG.camera;
    }

    override public function destroy()
    {
        instance = null;

        super.destroy();
    }

    public function loadScript(path:String, ?haxeArgs:Array<Dynamic>, ?luaArgs:Array<Dynamic>)
    {
        #if HSCRIPT_ALLOWED
        if (path.endsWith('.hx'))
        {
            loadHScript(path.substring(0, path.length - 3), haxeArgs);

            return;
        }
        #end

        #if LUA_ALLOWED
        if (path.endsWith('.lua'))
        {
            loadLuaScript(path.substring(0, path.length - 4), luaArgs);

            return;
        }
        #end

        #if HSCRIPT_ALLOWED
        loadHScript(path, haxeArgs);
        #end

        #if LUA_ALLOWED
        loadLuaScript(path, luaArgs);
        #end
    }

    public function loadHScript(path:String, ?args:Array<Dynamic>)
    {
        #if HSCRIPT_ALLOWED
        if (Paths.exists(path + '.hx'))
        {
            var script:HScript = new HScript(Paths.getPath(path + '.hx'), hScriptsContext, args, SUBSTATE, path, [scripting.haxe.callbacks.HScriptPlayState]);

            if (!script.failedParsing)
            {
                hScripts.push(script);

                debugTrace('"' + path + '.hx" has been Successfully Loaded', HSCRIPT);
            }
        }
        #end
    }

    public function loadLuaScript(path:String, ?args:Array<Dynamic>)
    {
        #if LUA_ALLOWED
        if (Paths.exists(path + '.lua'))
        {
            try
            {
                var script:LuaScript = new LuaScript(Paths.getPath(path + '.lua'), SUBSTATE, args, [scripting.lua.callbacks.LuaPlayState]);

                luaScripts.push(script);

                debugTrace('"' + path + '.lua" has been Successfully Loaded', LUA);
            } catch (error:Exception) {
                debugTrace(error.message, ERROR);
            }
        }
        #end
    }

    public inline function setOnScripts(name:String, value:Dynamic)
    {
        #if HSCRIPT_ALLOWED
        setOnHScripts(name, value);
        #end

        #if LUA_ALLOWED
        setOnLuaScripts(name, value);
        #end
    }

    public inline function setOnHScripts(name:String, value:Dynamic)
    {
        #if HSCRIPT_ALLOWED
        if (hScripts.length > 0)
            for (script in hScripts)
                script.set(name, value);
        #end
    }

    public inline function setOnLuaScripts(name:String, value:Dynamic)
    {
        #if LUA_ALLOWED
        if (luaScripts.length > 0)
            for (script in luaScripts)
                script.set(name, value);
        #end
    }

    public function callOnScripts(callback:String, ?arguments:Array<Dynamic> = null):Array<Dynamic>
    {
        var result:Array<Dynamic> = [];

        #if HSCRIPT_ALLOWED
        for (res in callOnHScripts(callback, arguments))
            result.push(res);
        #end

        #if LUA_ALLOWED
        for (res in callOnLuaScripts(callback, arguments))
            result.push(res);
        #end
        
        return result;
    }

    public function callOnHScripts(callback:String, arguments:Array<Dynamic> = null):Array<Dynamic>
    {
        var results:Array<Dynamic> = [];

        #if HSCRIPT_ALLOWED
        if (hScripts.length > 0)
        {
            try
            {
                for (script in hScripts)
                {
                    if (script == null)
                        continue;

                    results.push(script.call(callback, arguments));
                }
            } catch(_) {}
        }
        #end

        return results;
    }

    public function callOnLuaScripts(callback:String, arguments:Array<Dynamic> = null):Array<Dynamic>
    {
        var results:Array<Dynamic> = [];

        #if LUA_ALLOWED
        if (luaScripts.length > 0)
        {
            try
            {
                for (script in luaScripts)
                {
                    if (script == null)
                        continue;

                    results.push(script.call(callback, arguments));
                }
            } catch(_) {}
        }
        #end

        return results;
    }

    public inline function destroyScripts()
    {
        #if HSCRIPT_ALLOWED
        destroyHScripts();
        #end

        #if LUA_ALLOWED
        destroyLuaScripts();
        #end
    }

    public inline function destroyHScripts()
    {
        #if HSCRIPT_ALLOWED
        if (hScripts.length > 0)
        {
            for (script in hScripts)
                hScripts.remove(script);
        }
        #end
    }

    public inline function destroyLuaScripts()
    {
        #if LUA_ALLOWED
        if (luaScripts.length > 0)
        {
            for (script in luaScripts)
            {
                script.close();

                luaScripts.remove(script);
            }
        }
        #end
    }
}