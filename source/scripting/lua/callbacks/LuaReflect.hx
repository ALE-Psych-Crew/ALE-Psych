package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import scripting.lua.LuaPresetUtils;

import Type;

using StringTools;

class LuaReflect extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Gets a value from an object
         * 
         * @param tag Variable being searched
         * 
         * @return Variable value
         */
        set('getProperty', function(tag:String):Dynamic
        {
            return getTag(tag);
        });

        /**
         * Gets a value from an object in a group
         * 
         * @param tag Group ID
         * @param index Object position in the group
         * @param prop Variable being searched
         * 
         * @return Variable value
         */
        set('getPropertyFromGroup', function(tag:String, index:Int, prop:String):Dynamic
        {
            if (tagIs(tag, FlxTypedGroup))
                return Reflect.getProperty(getTag(tag).members[index], prop);

            return null;
        });

        /**
         * Gets a value from a class object
         * 
         * @param path Class path
         * @param prop Variable being searched
         * 
         * @return Variable value
         */
        set('getPropertyFromClass', function(path:String, prop:String):Dynamic
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return null;

            return getRecursiveProperty(cl, prop.split('.'));
        });

        /**
         * Sets a value to a variable on an object
         * 
         * @param tag Object ID
         * @param value Variable value
         */
        set('setProperty', function(tag:String, value:Dynamic)
        {
            var split:Array<String> = tag.split('.');

            var pop:String = split.pop();

            Reflect.setProperty(getTag(split.join('.')), pop, parseArg(value));
        });

        /**
         * Sets a value to a variable of an object in a group
         * 
         * @param tag Group ID
         * @param index Object position in the group
         * @param prop Object variable
         * @param value Variable value
         */
        set('setPropertyFromGroup', function(tag:String, index:Int, prop:String, value:Dynamic)
        {
            if (tagIs(tag, FlxTypedGroup))
                Reflect.setProperty(getTag(tag).members[index], prop, parseArg(value));
        });

        /**
         * Sets a value to a variable in a class
         * 
         * @param path Class path
         * @param prop Variable being searched
         * @param value Variable value
         */
        set('setPropertyFromClass', function(path:String, prop:String, value:Dynamic)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return;

            var split:Array<String> = prop.split('.');

            var pop:String = split.pop();

            Reflect.setProperty(getRecursiveProperty(cl, split), pop, parseArg(value));
        });

        /**
         * Sets multiple properties of an object
         * 
         * @param tag Object ID
         * @param props Table of object variables
         */
        set('setProperties', function(tag:String, props:Any)
        {
            setMultiProperty(getTag(tag), props);
        });

        /**
         * Sets multiple properties of an object in a group
         * 
         * @param tag Group ID
         * @param index Object position in the group
         * @param props Table of object variables
         */
        set('setPropertiesFromGroup', function(tag:String, index:Int, props:Any)
        {
            if (tagIs(tag, FlxTypedGroup))
                setMultiProperty(getTag(tag).members[index], props);
        });

        /**
         * Sets multiple properties of a class
         * 
         * @param path Class path
         * @param props Table of class variables
         */
        set('setPropertiesFromClass', function(path:String, props:Any)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return;

            setMultiProperty(cl, props);
        });

        /**
         * Calls a function of an object
         * 
         * @param tag Function name
         * @param args Function arguments
         * 
         * @return Returns the function's return value
         */
        set('callMethod', function(tag:String, ?args:Array<Dynamic>):Dynamic
        {
            return Reflect.callMethod(null, getTag(tag), parseArgs(args ?? []));
        });

        /**
         * Calls a function of a class
         * 
         * @param path Class path
         * @param func Function name
         * @param args Function arguments
         * 
         * @return Returns the function's return value
         */
        set('callMethodFromClass', function(path:String, func:String, ?args:Array<Dynamic>):Dynamic
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return null;

            return Reflect.callMethod(this, getRecursiveProperty(cl, func.split('.')), parseArgs(args ?? []));
        });

        /**
         * Creates an instance of a class
         * 
         * @param tag Instance ID
         * @param path Class path
         * @param args Instance arguments
         */
        set('createInstance', function(tag:String, path:String, ?args:Array<Dynamic>)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return;

            setTag(tag, Type.createInstance(cl, parseArgs(args ?? [])));
        });

        /**
         * Adds an instance to the game
         * 
         * @param tag Instance ID
         * 
         * @deprecated Use `add` instead
         */
        set('addInstance', function(tag:String)
        {
            deprecatedPrint('Use "add" instead of "addInstance"');

            if (tagIs(tag, flixel.FlxBasic))
                game.add(getTag(tag));
        });

        /**
         * Formats the string in a way that the game will interpret it as an object/instance
         * 
         * @param tag Instance ID
         */
        set('instanceArg', function(tag:String)
        {
            return INSTANCE_ARG_ID + tag;
        });
    }
}
