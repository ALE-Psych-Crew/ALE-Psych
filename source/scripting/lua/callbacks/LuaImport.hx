package scripting.lua.callbacks;

import scripting.lua.*;

import hxluajit.*;

import cpp.Callable;

/**
 * This has been made possible thanks to SrtHero278's LScript
 * 
 * @see https://github.com/SrtHero278/lscript
 */

class LuaImport
{
	public var lua:LuaScript;

    public function new(lua:LuaScript)
    {
		this.lua = lua;

		final state = lua.state;

		Lua.newtable(state);
		final tableIndex = Lua.gettop(state);
		Lua.pushvalue(state, tableIndex);

		LuaL.newmetatable(state, "__scriptMetatable");
		final metatableIndex = Lua.gettop(state);
		Lua.pushvalue(state, metatableIndex);
		Lua.setglobal(state, "__scriptMetatable");

		Lua.pushstring(state, '__index');
		Lua.pushcfunction(state, callIndex);
		Lua.settable(state, metatableIndex);
		
		Lua.pushstring(state, '__newindex');
		Lua.pushcfunction(state, callNewIndex);
		Lua.settable(state, metatableIndex);
		
		Lua.pushstring(state, '__call');
		Lua.pushcfunction(state, callMetatableCall);
		Lua.settable(state, metatableIndex);

		Lua.pushstring(state, '__gc');
		Lua.pushcfunction(state, callGarbageCollect);
		Lua.settable(state, metatableIndex);

		Lua.setmetatable(state, tableIndex);

		LuaL.newmetatable(state, "__enumMetatable");
		final enumMetatableIndex = Lua.gettop(state);
		Lua.pushvalue(state, metatableIndex);

		Lua.pushstring(state, '__index');
		Lua.pushcfunction(state, callEnumIndex);
		Lua.settable(state, enumMetatableIndex);

		LuaL.newmetatable(state, "__globalMetatable");
		final globalMetatableIndex = Lua.gettop(state);
		Lua.pushvalue(state, metatableIndex);

		Lua.pushstring(state, '__index');
		Lua.pushcfunction(state, callGlobalIndex);
		Lua.settable(state, globalMetatableIndex);

		Lua.pushstring(state, '__newindex');
		Lua.pushcfunction(state, callGlobalNewIndex);
		Lua.settable(state, globalMetatableIndex);

		Lua.newtable(state);
		final scriptTableIndex = Lua.gettop(state);

		Lua.pushstring(state, '__special_id');
		Lua.pushinteger(state, 0);
		Lua.settable(state, scriptTableIndex);

		LuaL.getmetatable(state, "__scriptMetatable");
		Lua.setmetatable(state, scriptTableIndex);

        lua.set('import', importClass);
    }
    
	public static var curSpecial:Int = -1;

	public static var curParent:Int = -1;

	public static function fromLua(stackPos:Int, ?includeIndexes:Bool = false):Dynamic
	{
		var ret:Any = null;

		final curLua = LuaScript.current;
		
		final state = curLua.state;

		switch (Lua.type(state, stackPos))
		{
			case type if (type == Lua.TNIL):
				ret = null;
			case type if (type == Lua.TBOOLEAN):
				ret = Lua.toboolean(state, stackPos) == 1;
			case type if (type == Lua.TNUMBER):
				ret = Lua.tonumber(state, stackPos);
			case type if (type == Lua.TSTRING):
				ret = Lua.tostring(state, stackPos).toString();
			case type if (type == Lua.TTABLE):
				ret = toHaxeObj(stackPos);
			case type if (type == Lua.TFUNCTION):
				if (Lua.tocfunction(state, stackPos) != workaroundCallable)
				{
					Lua.pushvalue(state, stackPos);

					final ref = LuaL.ref(state, Lua.REGISTRYINDEX);

					function callLocalLuaFunc(params:Array<Dynamic>)
					{
						final lastLua:LuaScript = LuaScript.current;

						LuaScript.current = curLua;

						Lua.settop(state, 0);
						Lua.rawgeti(state, Lua.REGISTRYINDEX, ref);
				
						if (Lua.isfunction(state, -1) != 1)
							return null;

						var nparams:Int = 0;

						if (params != null && params.length > 0)
						{
							nparams = params.length;

							for (val in params)
								toLua(val);
						}
						
						if (Lua.pcall(state, nparams, 1, 0) != 0)
						{
							Sys.println('Function(LOCAL) Error: ${Lua.tostring(state, -1)}');

							return null;
						}

						final v = fromLua(Lua.gettop(state));

						Lua.settop(state, 0);

						LuaScript.current = lastLua;
						
						return v;
					}

					ret = Reflect.makeVarArgs(callLocalLuaFunc);
				}
			case idk:
				ret = null;

				Sys.println('Return value not supported: ${Std.string(idk)} - $stackPos');
		}

		if (ret is Dynamic && Reflect.hasField(ret, "__special_id"))
		{
			final specID = Reflect.field(ret, "__special_id");

			if (includeIndexes)
			{
				curSpecial = specID;

				curParent = Reflect.field(ret, "__parent_id");
			}

			return curLua.specialVariables[specID];
		}

		return ret;
	}

	public static function addToMetatable(val:Dynamic, parentIndex:Int):Int
	{
		final lua = LuaScript.current;
		final state = lua.state;
		final location = lua.availableIndices.length > 0 ? lua.availableIndices.shift() : lua.nextIndex;

		lua.nextIndex += untyped __cpp__("{0}", lua.nextIndex == location);
		lua.specialVariables.set(location, val); 

		Lua.newtable(state);
			final tableIndex = Lua.gettop(state);

		Lua.pushstring(state, '__parent_id');
		Lua.pushinteger(state, parentIndex);
		Lua.settable(state, tableIndex);

		Lua.pushstring(state, '__special_id');
		Lua.pushinteger(state, location);
		Lua.settable(state, tableIndex);

		LuaL.getmetatable(state, "__scriptMetatable");
		Lua.setmetatable(state, tableIndex);

		return tableIndex;
	}

	public static function toLua(val:Any, ?parentIndex:Int = -1)
	{
		var varType = Type.typeof(val);
		var curLua = LuaScript.current;
		var state = curLua.state;

		switch (varType)
		{
			case Type.ValueType.TNull:
				Lua.pushnil(state);
			case Type.ValueType.TBool:
				Lua.pushboolean(state, val);
			case Type.ValueType.TInt:
				Lua.pushinteger(state, cast(val, Int));
			case Type.ValueType.TFloat:
				Lua.pushnumber(state, val);
			case Type.ValueType.TClass(String):
				Lua.pushstring(state, cast(val, String));
			case Type.ValueType.TClass(Array):
				addToMetatable(val, parentIndex);
			case Type.ValueType.TObject:
				final tableIndex = addToMetatable(val, parentIndex);

				if (val is Class)
				{
					Lua.pushstring(state, "new");
					Lua.pushcfunction(state, workaroundCallable);
					Lua.rawset(state, tableIndex);
				}
			default:
				addToMetatable(val, parentIndex);
		}
	}

	public static function toHaxeObj(i:Int):Any
	{
		var state = LuaScript.current.state;
		var count = 0;
		var array = true;

		LuaMacro.loopTable(state, i, {
			if (array)
			{
				if (Lua.type(state, -2) != Lua.TNUMBER)
				{
					array = false;
				} else {
					var index = Lua.tonumber(state, -2);

					if (index < 0 || Std.int(index) != index)
						array = false;
				}
			}

			count++;
		});

		return if (count == 0) {
				{};
			} else if (array) {
				var v = [];

				LuaMacro.loopTable(state, i, {
					var index = Std.int(Lua.tonumber(state, -2)) - 1;
					v[index] = fromLua(-1);
				});

				cast v;
			} else {
				var v:haxe.DynamicAccess<Any> = {};

				LuaMacro.loopTable(state, i, {
					switch Lua.type(state, -2) {
						case type if (type == Lua.TSTRING):
							v.set(Lua.tostring(state, -2), fromLua(-1));
						case type if (type == Lua.TNUMBER):
							v.set(Std.string(Lua.tonumber(state, -2)), fromLua(-1));
					}
				});

				cast v;
			}
	}

	public static final workaroundCallable:Callable<LuaStatePointer -> Int> = Callable.fromStaticFunction(instanceWorkAround);

	static function instanceWorkAround(state:LuaStatePointer):Int
	{
		final nparams:Int = Lua.gettop(LuaScript.current.state);

		final params:Array<Dynamic> = [
			for (i in 0...nparams)
				fromLua(-nparams + i)
		];
		
		final funcParams = [
			for (i in 1...params.length)
				params[i]
		];
		
		params.splice(1, params.length);

		params.push(funcParams);

		var returned:Dynamic = null;

		try {
			returned = Type.createInstance(params[0], params[1]);
		} catch(e) {
			debugTrace('Lua Instance Creation Error: ' + e.details(), ERROR);

			Lua.settop(LuaScript.current.state, 0);

			return 0;
		}

		Lua.settop(LuaScript.current.state, 0);

		if (returned != null)
		{
			toLua(returned);

			return 1;
		}

		return 0;
	}

	public static function importClass(path:String, ?varName:String)
	{
		final state = LuaScript.current.state;

		final importedClass = Type.resolveClass(path);

		final importedEnum = Type.resolveEnum(path);

		final trimmedName = varName != null ? varName : path.substr(path.lastIndexOf(".") + 1, path.length);

		if (importedClass != null)
		{
			final tableIndex = addToMetatable(importedClass, -1);
			
			Lua.pushstring(state, "new");
			Lua.pushcfunction(state, workaroundCallable);
			Lua.rawset(state, tableIndex);

			Lua.setglobal(state, trimmedName);
		} else if (importedEnum != null) {
			final tableIndex = addToMetatable(importedEnum, -1);
			
			LuaL.getmetatable(state, "__enumMetatable");
			Lua.setmetatable(state, tableIndex);
			
			Lua.setglobal(state, trimmedName);
		} else {
			Sys.println('Lua Import Error: Unable to find class from path "$path".');
		}
	}
    
	public static final callIndex = Callable.fromStaticFunction(_callIndex);

	public static final callNewIndex = Callable.fromStaticFunction(_callNewIndex);

	public static final callMetatableCall = Callable.fromStaticFunction(_callMetatableCall);

	public static final callGarbageCollect = Callable.fromStaticFunction(_callGarbageCollect);

	public static final callEnumIndex = Callable.fromStaticFunction(_callEnumIndex);

	public static final callGlobalIndex = Callable.fromStaticFunction(_callGlobalIndex);

	public static final callGlobalNewIndex = Callable.fromStaticFunction(_callGlobalNewIndex);

	static function _callIndex(state:LuaStatePointer):Int
		return metatableFunc(LuaScript.current.state, 0);

	static function _callNewIndex(state:LuaStatePointer):Int
		return metatableFunc(LuaScript.current.state, 1);

	static function _callMetatableCall(state:LuaStatePointer):Int
		return metatableFunc(LuaScript.current.state, 2);

	static function _callGarbageCollect(state:LuaStatePointer):Int
		return metatableFunc(LuaScript.current.state, 3);

	static function _callEnumIndex(state:LuaStatePointer):Int
		return metatableFunc(LuaScript.current.state, 4);

	static function _callGlobalIndex(state:LuaStatePointer):Int
	{
		final state = LuaScript.current.state;

		final nparams = Lua.gettop(state);

		Lua.remove(state, -nparams);
		Lua.getglobal(state, "script");
		Lua.getfield(state, -1, "parent");
		Lua.remove(state, -2);
		Lua.insert(state, -nparams);

		return metatableFunc(state, 0);
	}

	static function _callGlobalNewIndex(state:LuaStatePointer):Int
	{
		final state = LuaScript.current.state;
		final nparams = Lua.gettop(state);

		Lua.remove(state, -nparams);
		Lua.getglobal(state, "script");
		Lua.getfield(state, -1, "parent");
		Lua.remove(state, -2);
		Lua.insert(state, -nparams);

		return metatableFunc(state, 1);
	}

	static function metatableFunc(state:LuaState, funcNum:Int)
	{
		final functions:Array<Dynamic> = [index, newIndex, metatableCall, garbageCollect, enumIndex];

		final nparams:Int = Lua.gettop(state);

		final params:Array<Dynamic> = [
			for (i in 0...nparams)
				fromLua(-nparams + i, i == 0)
		];
		
		final specialIndex:Int = curSpecial;
		final parentIndex:Int = curParent;

		if (funcNum == 2)
		{
			final objParent = parentIndex >= 0 ? LuaScript.current.specialVariables[parentIndex] : null;

			if (params[1] != objParent)
				params.insert(1, objParent);

			final funcParams = [
				for (i in 2...params.length)
					params[i]
			];

			params.splice(2, params.length);
			params.push(funcParams);
		}

		var returned:Dynamic = null;

		try {
			returned = functions[funcNum](params[0], params[1], params[2]);
		} catch(e) {
			debugTrace('Lua Metatable Error: ' + e.details(), ERROR);

			Lua.settop(state, 0);

			return 0;
		}

		Lua.settop(state, 0);

		if (returned != null)
		{
			toLua(returned, funcNum < 2 ? specialIndex : -1);

			return 1;
		}

		return 0;
	}

	public static function index(object:Dynamic, property:Any, ?uselessValue:Any):Dynamic
	{
		if (object is Array && property is Int)
			return object[cast(property, Int)];

		var grabbedProperty:Dynamic = null;

		if (object != null && (grabbedProperty = Reflect.getProperty(object, cast(property, String))) != null)
			return grabbedProperty;

		return null;
	}

	public static function newIndex(object:Dynamic, property:Any, value:Dynamic)
	{
		if (object is Array && property is Int)
		{
			object[cast(property, Int)] = value;

			return null;
		}

		if (object != null)
			Reflect.setProperty(object, cast(property, String), value);
		
		return null;
	}

	public static function metatableCall(func:Dynamic, object:Dynamic, ?params:Array<Any>)
	{
		final funcParams = (params != null && params.length > 0) ? params : [];

		if (func != null && Reflect.isFunction(func))
			return Reflect.callMethod(object, func, funcParams);

		return null;
	}

	public static function garbageCollect(index:Int)
	{
		LuaScript.current.availableIndices.push(index);
		LuaScript.current.specialVariables.remove(index);
	}
	
	public static function enumIndex(object:Enum<Dynamic>, value:String, ?params:Array<Any>):EnumValue
	{
		final funcParams = params != null && params.length > 0 ? params : [];

		var enumValue:EnumValue = object.createByName(value, funcParams);

		if (object != null && enumValue != null)
			return enumValue;

		return null;
	}
}