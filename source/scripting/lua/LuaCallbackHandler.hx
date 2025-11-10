package scripting.lua;

#if LUA_ALLOWED
import cpp.RawPointer;

import hxluajit.wrapper.LuaUtils;
import hxluajit.wrapper.LuaConverter;

import hxluajit.Lua;
import hxluajit.LuaL;
import hxluajit.Types;

import haxe.Exception;

@:unreflective class LuaCallbackHandler
{
    private static final STATE_ID_VAR = '__ALE_PSYCH_LUA_CALLBACKS_ID';

	private static final callbacks:Map<String, Map<String, Dynamic>> = [];

    public static function applyID(L:RawPointer<Lua_State>, id:String)
        LuaUtils.setVariable(L, STATE_ID_VAR, id);

	public static function addFunction(L:RawPointer<Lua_State>, name:String, fn:Dynamic):Void
	{
		final stateID = LuaUtils.getVariable(L, STATE_ID_VAR);

		if (!callbacks.exists(stateID))
			callbacks.set(stateID, []);

		callbacks.get(stateID)?.set(name, fn);

		final parts:Array<String> = name.split('.');

		if (parts.length > 1)
		{
			@:privateAccess LuaUtils.ensureTablePath(L, parts);

			final last:String = parts[parts.length - 1];

			Lua.pushstring(L, last);
			Lua.pushcclosure(L, cpp.Function.fromStaticFunction(functionHandler), 1);

			Lua.setfield(L, -2, last);

			Lua.pop(L, parts.length);
		} else {
			Lua.pushstring(L, name);
			Lua.pushcclosure(L, cpp.Function.fromStaticFunction(functionHandler), 1);
			Lua.setglobal(L, name);
		}
	}

	public static function cleanupStateFunctions(L:RawPointer<Lua_State>):Void
	{
		final stateID = LuaUtils.getVariable(L, STATE_ID_VAR);

		if (callbacks.exists(stateID))
			callbacks.remove(stateID);
	}

	private static function functionHandler(L:RawPointer<Lua_State>):Int
	{
		final stateID = LuaUtils.getVariable(L, STATE_ID_VAR);

		final name:String = Lua.tostring(L, Lua.upvalueindex(1));

		final args:Array<Dynamic> = [for (i in 0...Lua.gettop(L)) LuaConverter.fromLua(L, i + 1)];

		try
		{
			final ret:Dynamic = Reflect.callMethod(null, callbacks.get(stateID)?.get(name), args);

			if (ret != null)
			{
				LuaConverter.toLua(L, ret);

				return 1;
			}
		} catch (e:Exception) {
			LuaL.error(L, 'Error executing function ' + name + ': ${e.toString()}');
        }

		return 0;
	}
}
#end