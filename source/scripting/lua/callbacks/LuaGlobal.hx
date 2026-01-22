package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import flixel.FlxBasic;

import haxe.ds.StringMap;

class LuaGlobal extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('add', function(tag:String)
        {
            if (tagIs(tag, flixel.FlxBasic))
                game.add(getTag(tag));
        });

        set('remove', function(tag:String, ?destroy:Bool)
        {
            if (tagIs(tag, FlxBasic))
                game.remove(getTag(tag), destroy);
        });

        set('insert', function(position:Int, tag:String)
        {
            if (tagIs(tag, FlxBasic))
                game.insert(position, getTag(tag));
        });

        set('getObjectOrder', function(tag:String)
        {
            return game.members.indexOf(getTag(tag));
        });

        set('setObjectOrder', function(tag:String, position:Int)
        {
            if (!tagIs(tag, FlxBasic))
                return;

            var object:FlxBasic = getTag(tag);

            game.remove(object);
            game.insert(position, object);
        });

        set('getRandomInt', function(?min:Int, ?max:Int, ?excludes:Array<Int>)
        {
            return FlxG.random.int(min, max, excludes);
        });

        set('getRandomFloat', function(?min:Float, ?max:Float, ?excludes:Array<Float>)
        {
            return FlxG.random.float(min, max, excludes);
        });

        set('getRandomBool', function(?chance:Float)
        {
            return FlxG.random.bool(chance);
        });

        set('registerGlobalFunction', function(name:String)
        {
            globalFunctionLua(name);

            #if HSCRIPT_ALLOWED
            globalFunctionHScript(name);
            #end
        });

        set('registerGlobalLuaFunction', function(name:String)
        {
            globalFunctionLua(name);
        });

        #if HSCRIPT_ALLOWED
        set('registerGlobalHScriptFunction', function(name:String)
        {
            globalFunctionHScript(name);
        });
        #end

        set('registerGlobalVariable', function(tag:String)
        {
            globalVariableLua(tag);

            #if HSCRIPT_ALLOWED
            globalVariableHScript(tag);
            #end
        });

        set('registerGlobalLuaVariable', function(tag:String)
        {
            globalVariableLua(tag);
        });

        #if HSCRIPT_ALLOWED
        set('registerGlobalHScriptVariable', function(tag:String)
        {
            globalVariableHScript(tag);
        });
        #end

        set('variableExists', function(tag:String):Bool
        {
            return lua.variables.exists(tag);
        });

        if (type == SUBSTATE)
        {
            set('close', function()
            {
                (cast (game, ScriptSubState)).close();
            });
        }

        set('switchToCustomState', function(name:String, ?hsArguments:Array<Dynamic>, ?luaArguments:Array<Dynamic>, ?hsVariables:Any, ?luaVariables:Any)
        {
            CoolUtil.switchState(new CustomState(name, hsArguments, luaArguments, tableToStringMap(hsVariables), tableToStringMap(luaVariables)));
        });

        set('openCustomSubState', function(name:String, ?hsArguments:Array<Dynamic>, ?luaArguments:Array<Dynamic>, ?hsVariables:Any, ?luaVariables:Any)
        {
            CoolUtil.openSubState(new CustomSubState(name, hsArguments, luaArguments, tableToStringMap(hsVariables), tableToStringMap(luaVariables)));
        });
    }

    function tableToStringMap(table:Any):StringMap<Dynamic>
    {
        var result:StringMap<Dynamic> = new StringMap<Dynamic>();

        for (field in Reflect.fields(table))
            result.set(field, Reflect.field(table, field));

        return result;
    }

    function globalFunctionLua(name:String)
    {
        for (script in game.luaScripts)
        {
            if (script == lua)
                continue;
            
            script.set(name, Reflect.makeVarArgs(function(?args:Array<Dynamic>):Dynamic
            {
                return lua.call(name, args);
            }));
        }
    }

    function globalFunctionHScript(name:String)
    {
        for (script in game.hScripts)
        {
            script.set(name, Reflect.makeVarArgs(function(?args:Array<Dynamic>):Dynamic
            {
                return lua.call(name, args);
            }));
        }  
    }
    
    function globalVariableLua(tag:String)
    {
        final object:Dynamic = getTag(tag);

        if (object == null)
            return;

        for (script in game.luaScripts)
        {
            if (script == lua)
                continue;
            
            if (!script.variables.exists(tag))
                script.variables.set(tag, object);
        }
    }

    function globalVariableHScript(tag:String)
    {
        final object:Dynamic = getTag(tag);

        if (object == null)
            return;

        for (script in game.hScripts)
            if (!script.variables.exists(tag))
                script.set(tag, object);
    }
}
