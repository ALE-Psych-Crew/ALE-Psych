package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import flixel.FlxBasic;

class LuaGlobal extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Adds an object to the game
         * 
         * @param tag ID of the object
         */
        set('add', function(tag:String)
        {
            if (tagIs(tag, flixel.FlxBasic))
                game.add(getTag(tag));
        });

        /**
         * Removes an object from the game
         * 
         * @param tag ID of the object
         * @param destroy Defines whether the object should be destroyed
         */
        set('remove', function(tag:String, ?destroy:Bool)
        {
            if (tagIs(tag, FlxBasic))
                game.remove(getTag(tag), destroy);
        });

        /**
         * Inserts an object into the game
         * 
         * @param position Position where the object will be inserted
         * @param tag ID of the object
         */
        set('insert', function(position:Int, tag:String)
        {
            if (tagIs(tag, FlxBasic))
                game.insert(position, getTag(tag));
        });

        /**
         * Gets the position of an object in the game
         * 
         * @param tag ID of the object
         * 
         * @return Object position
         */
        set('getObjectOrder', function(tag:String)
        {
            return game.members.indexOf(getTag(tag));
        });

        /**
         * Removes and reinserts an object in a different position
         * 
         * @param tag ID of the object
         * @param position New position
         */
        set('setObjectOrder', function(tag:String, position:Int)
        {
            if (!tagIs(tag, FlxBasic))
                return;

            var object:FlxBasic = getTag(tag);

            game.remove(object);
            game.insert(position, object);
        });

        /**
         * Gets a random integer
         * 
         * @param min Smallest integer
         * @param max Largest integer
         * @param excludes Integers that will not be used
         * 
         * @return Obtained integer
         */
        set('getRandomInt', function(?min:Int, ?max:Int, ?excludes:Array<Int>)
        {
            return FlxG.random.int(min, max, excludes);
        });

        /**
         * Gets a random float
         * 
         * @param min Smallest float
         * @param max Largest float
         * @param excludes Floats that will not be used
         * 
         * @return Obtained float
         */
        set('getRandomFloat', function(?min:Float, ?max:Float, ?excludes:Array<Float>)
        {
            return FlxG.random.float(min, max, excludes);
        });

        /**
         * Gets a random boolean
         * 
         * @param chance Probability that the value is `true` (from 0 to 100)
         * 
         * @return Obtained boolean
         */
        set('getRandomBool', function(?chance:Float)
        {
            return FlxG.random.bool(chance);
        });

        /**
         * Shares a Lua function with all running scripts
         *
         * @param name Function name to expose globally
         */
        set('registerGlobalFunction', function(name:String)
        {
            globalFunctionLua(name);

            #if HSCRIPT_ALLOWED
            globalFunctionHScript(name);
            #end
        });

        /**
         * Shares a Lua function with all running Lua scripts
         *
         * @param name Function name to expose globally
         */
        set('registerGlobalLuaFunction', function(name:String)
        {
            globalFunctionLua(name);
        });

        #if HSCRIPT_ALLOWED
        /**
         * Shares a Lua function with all running HScript scripts
         *
         * @param name Function name to expose globally
         */
        set('registerGlobalHScriptFunction', function(name:String)
        {
            globalFunctionHScript(name);
        });
        #end

        /**
         * 
         */
        set('registerGlobalVariable', function(tag:String)
        {
            globalVariableLua(tag);

            #if HSCRIPT_ALLOWED
            globalVariableHScript(tag);
            #end
        });

        /**
         * 
         */
        set('registerGlobalLuaVariable', function(tag:String)
        {
            globalVariableLua(tag);
        });

        #if HSCRIPT_ALLOWED
        /**
         * 
         */
        set('registerGlobalHScriptVariable', function(tag:String)
        {
            globalVariableHScript(tag);
        });
        #end
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
