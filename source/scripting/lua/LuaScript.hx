package scripting.lua;

#if LUA_ALLOWED
import cpp.RawPointer;

import hxluajit.wrapper.LuaUtils;
import hxluajit.wrapper.LuaConverter;
import hxluajit.wrapper.LuaError;

import hxluajit.Lua;
import hxluajit.LuaL;
import hxluajit.Types;

import haxe.ds.StringMap;

import core.enums.ScriptType;

class LuaScript
{
    public var state:Null<RawPointer<Lua_State>>;

    public var type:ScriptType;

    public var name:String;

    public var closed:Bool = false;

    public var variables:StringMap<Dynamic> = new StringMap();

    public function new(name:String, type:ScriptType, ?args:Array<Dynamic>, ?customCallbacks:Array<Class<LuaPresetBase>>)
    {
        variables.set('this', this);

        this.name = name;

        this.type = type;

        state = LuaL.newstate();
        
        LuaCallbackHandler.applyID(state, name);

        new LuaPreset(this);

        for (callbacks in (customCallbacks ?? []))
            Type.createInstance(callbacks, [this]);

        LuaL.openlibs(state);

        LuaUtils.doFile(state, name);

        call('new', args ?? []);
    }

    public function call(name:String, args:Array<Dynamic>):Dynamic
    {
        if (closed)
            return CoolVars.Function_Continue;

        try
        {
            Lua.getglobal(state, name);

            if (Lua.isnil(state, -1) != 0)
            {
                Lua.pop(state, 1);
                
                return CoolVars.Function_Continue;
            }
            
            args ??= [];

            for (arg in args)
                LuaConverter.toLua(state, arg);

            var status:Int = Lua.pcall(state, args.length, 1, 0);

            if (status != Lua.OK)
            {
                if (LuaError.errorHandler != null)
                    LuaError.errorHandler(LuaError.getMessage(state, -1));

                return CoolVars.Function_Continue;
            }
            
            var result:Dynamic = null;

            if (Lua.gettop(state) > 0)
            {
                result = cast LuaConverter.fromLua(state, -1);
                
                Lua.pop(state, 1);
            }

            return result;
        } catch (error:Dynamic) {
            debugTrace(error, ERROR);
        }

        return CoolVars.Function_Continue;
    }

    public function set(name:String, value:Dynamic)
    {
        if (closed)
            return;

        if (Reflect.isFunction(value))
            LuaCallbackHandler.addFunction(state, name, value);
        else
            LuaUtils.setVariable(state, name, value);
    }
    
    public function close()
    {
        closed = true;

        LuaCallbackHandler.cleanupStateFunctions(state);

        Lua.close(state);
    }
}
#end