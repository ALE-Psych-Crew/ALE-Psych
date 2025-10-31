#if LUA_ALLOWED
package scripting.lua;

import haxe.ds.StringMap;

import core.enums.ScriptType;

import core.interfaces.IScriptState;

class LuaPresetBase
{
    public var lua:LuaScript;

    public var game:IScriptState;

    public var variables(get, never):StringMap<Dynamic>;
    function get_variables():StringMap<Dynamic>
        return lua.variables;

    public var type(get, never):ScriptType;
    function get_type():ScriptType
        return lua.type;

    public function new(lua:LuaScript)
    {
        this.lua = lua;

        game = lua.type == STATE ? ScriptState.instance : ScriptSubState.instance;
    }

    public inline function set(name:String, value:Dynamic)
        lua.set(name, value);

    public inline function errorPrint(text:String)
        debugTrace(text, ERROR);

    public inline function deprecatedPrint(text:String)
        debugTrace(text, DEPRECATED);

    public function getTag(tag:String):Dynamic
    {
        var split:Array<String> = tag.split('.');

        var instance:Dynamic = variables.get(split[0]);

        if (instance == null)
            instance = game;
        else
            split.shift();

        var result:Dynamic = tag.length > 0 ? getRecursiveProperty(instance, split) : instance;

        if (result == null)
            errorPrint('There is no Object with this Tag "' + tag + '"');

        return result;
    }

    public inline function tagIs(name:String, type:Dynamic):Bool
    {
        var result:Bool = Std.isOfType(getTag(name), type);

        if (!result)
            errorPrint(name + ':' + Type.getClassName(Type.getClass(getTag(name))) + ' should be ' + name + ':' + Type.getClassName(type));
        
        return result;
    }

    public inline function setTag(name:String, value:Dynamic)
    {
        if (variables.exists(name))
            errorPrint('There is already an object with the tag "' + name + '"');
        else
            variables.set(name, value);
    }

    public inline function removeTag(name:String)
    {
        if (variables.exists(name))
            variables.remove(name);
    }

    function getRecursiveProperty(instance:Dynamic, split:Array<String>):Dynamic
    {
        var result:Dynamic = instance;

        for (part in split)
        {
            result = Reflect.getProperty(result, part);

            if (result == null)
                return null;
        }

        return result;
    }
}
#end