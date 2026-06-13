package scripting;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;

import core.enums.ScriptCallType;
import core.enums.ScriptType;

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

@:publicFields
class ScriptsManager implements IFlxDestroyable
{
    var allowHotReloading:Bool = false;

    var type:ScriptType;

    var members:Array<IScript> = [];

    public function new(type:ScriptType, ?globalArguments:Array<Dynamic> #if ALLOW_HSCRIPT , ?haxeArguments:Array<Dynamic> #end #if ALLOW_LUA , ?luaArguments:Array<Dynamic> #end , ?allowHotReloading:Bool = false)
    {
        this.type = type;

        this.allowHotReloading = allowHotReloading;

        this.globalArguments = globalArguments;

        #if ALLOW_HSCRIPT
        this.haxeArguments = haxeArguments;
        #end

        #if ALLOW_LUA
        this.luaArguments = luaArguments;
        #end
    }

    final globalArguments:Array<Dynamic>;

    function load(path:String, ?args:Array<Dynamic> #if ALLOW_HSCRIPT , ?haxeArgs:Array<Dynamic> #end #if ALLOW_LUA , ?luaArgs:Array<Dynamic> #end)
    {
        #if ALLOW_HSCRIPT
        if (path.endsWith(RuleScriptGlobal.SCRIPT_EXTENSION))
        {
            haxeLoad(CoolUtil.removeExtension(path), haxeArgs ?? args);
            
            return;
        }
        #end

        #if ALLOW_LUA
        if (path.endsWith('.lua'))
        {
            luaLoad(CoolUtil.removeExtension(path), luaArgs ?? args);

            return;
        }
        #end

        #if ALLOW_HSCRIPT
        haxeLoad(path, haxeArgs ?? args ?? haxeArguments ?? globalArguments);
        #end

        #if ALLOW_LUA
        luaLoad(path, luaArgs ?? args);
        #end
    }

    function loadFolder(path:String, ?recursive:Bool = true, ?args:Array<Dynamic> #if ALLOW_HSCRIPT , ?haxeArgs:Array<Dynamic> #end #if ALLOW_LUA , ?luaArgs:Array<Dynamic> #end)
    {
        for (file in Paths.readDirectory(path, MULTIPLE))
        {
            final fullPath:String = path + '/' + file;

            if (Paths.isDirectory(fullPath) && recursive)
                loadFolder(fullPath, recursive, args #if ALLOW_HSCRIPT , haxeArgs #end #if ALLOW_LUA , luaArgs #end);
            else if (file.endsWith('.lua') || file.endsWith(RuleScriptGlobal.SCRIPT_EXTENSION))
                load(fullPath, args #if ALLOW_HSCRIPT , haxeArgs #end #if ALLOW_LUA , luaArgs #end);
        }
    }

    function set(name:String, value:Dynamic)
        for (script in members)
            script.set(name, value);

    function call(name:String, ?args:Array<Dynamic>):Array<Dynamic>
        return [for (script in members) script.call(name, args)];

    function callback(type:ScriptCallType, id:String, ?globalArgs:Array<Dynamic> #if ALLOW_HSCRIPT , ?haxeArgs:Array<Dynamic> #end #if ALLOW_LUA , ?luaArgs:Array<Dynamic> #end):Bool
    {
        final callID:String = Std.string(type) + id;

        var result:Bool = true;

        #if ALLOW_HSCRIPT
        if (haxeCall(callID, haxeArgs ?? globalArgs).contains(CoolVars.Function_Stop))
            result = false;
        #end

        #if ALLOW_LUA
        if (luaCall(callID, luaArgs ?? globalArgs).contains(CoolVars.Function_Stop))
            result = false;
        #end

        return result;
    }

    function destroy()
    {
        members = null;

        #if ALLOW_HSCRIPT
        haxe = null;
        haxeContext = null;
        #end

        #if ALLOW_LUA
        lua = null;
        #end
    }

    #if ALLOW_HSCRIPT
    var haxe:Array<HScript> = [];

    var haxeContext:Context = new Context();

    final haxeArguments:Array<Dynamic>;

    function haxeLoad(path:String, ?args:Array<Dynamic>)
    {
        final fullPath:String = path + RuleScriptGlobal.SCRIPT_EXTENSION;

        if (Paths.exists(fullPath))
        {
            final script:HScript = new HScript(path, haxeContext, args ?? haxeArguments ?? globalArguments, type);

            if (allowHotReloading)
                HotReloading.add(fullPath);

            if (!script.failedExecution)
            {
                haxe.push(script);

                members.push(script);

                debugTrace('"' + fullPath + '" has been loaded', HSCRIPT);
            }
        }
    }

    function haxeSet(name:String, value:Dynamic):Void
        for (script in haxe)
            script.set(name, value);

    function haxeCall(name:String, ?args:Array<Dynamic>):Array<Dynamic>
        return [for (script in haxe) script.call(name, args)];
    #end

    #if ALLOW_LUA
    var lua:Array<LuaScript> = [];

    final luaArguments:Array<Dynamic>;

    function luaLoad(path:String, ?args:Array<Dynamic>)
    {
        final fullPath:String = path + '.lua';

        if (Paths.exists(fullPath))
        {
            if (allowHotReloading)
                HotReloading.add(fullPath);

            try
            {
                final script:LuaScript = new LuaScript(path, args ?? luaArguments ?? globalArguments, type);

                lua.push(script);

                members.push(script);

                debugTrace('"' + fullPath + '" has been loaded', LUA);
            } catch (error) {
                debugTrace(error.message, ERROR);
            }
        }
    }

    function luaSet(name:String, value:Dynamic):Void
        for (script in lua)
            script.set(name, value);

    function luaCall(name:String, ?args:Array<Dynamic>):Array<Dynamic>
        return [for (script in lua) script.call(name, args)];
    #end
}