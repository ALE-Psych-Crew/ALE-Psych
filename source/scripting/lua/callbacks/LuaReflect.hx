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

        set('setVariableFromClass', function(tag:String, path:String, prop:String)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return;

            setTag(tag, getRecursiveProperty(cl, prop.split('.')));
        });

        set('setVariableFromGroup', function(tag:String, groupTag:String, index:Int)
        {
            if (tagIs(groupTag, FlxTypedGroup))
                setTag(tag, getTag(groupTag).members[index]);
        });

        set('getProperty', function(tag:String):Dynamic
        {
            return getTag(tag);
        });

        set('getPropertyFromGroup', function(tag:String, index:Int, prop:String):Dynamic
        {
            if (tagIs(tag, FlxTypedGroup))
                return Reflect.getProperty(getTag(tag).members[index], prop);

            return null;
        });

        set('getPropertyFromClass', function(path:String, prop:String):Dynamic
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return null;

            return getRecursiveProperty(cl, prop.split('.'));
        });

        set('setProperty', function(tag:String, value:Dynamic)
        {
            var split:Array<String> = tag.split('.');

            var pop:String = split.pop();

            Reflect.setProperty(getTag(split.join('.')), pop, parseArg(value));
        });

        set('setPropertyFromGroup', function(tag:String, index:Int, prop:String, value:Dynamic)
        {
            if (tagIs(tag, FlxTypedGroup))
                Reflect.setProperty(getTag(tag).members[index], prop, parseArg(value));
        });

        set('setPropertyFromClass', function(path:String, prop:String, value:Dynamic)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return;

            var split:Array<String> = prop.split('.');

            var pop:String = split.pop();

            Reflect.setProperty(getRecursiveProperty(cl, split), pop, parseArg(value));
        });

        set('setProperties', function(tag:String, props:Any)
        {
            setMultiProperty(getTag(tag), props);
        });

        set('setPropertiesFromGroup', function(tag:String, index:Int, props:Any)
        {
            if (tagIs(tag, FlxTypedGroup))
                setMultiProperty(getTag(tag).members[index], props);
        });

        set('setPropertiesFromClass', function(path:String, props:Any)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return;

            setMultiProperty(cl, props);
        });

        set('callMethod', function(tag:String, ?args:Array<Dynamic>):Dynamic
        {
            return Reflect.callMethod(null, getTag(tag), parseArgs(args ?? []));
        });

        set('callMethodFromClass', function(path:String, func:String, ?args:Array<Dynamic>):Dynamic
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return null;

            return Reflect.callMethod(this, getRecursiveProperty(cl, func.split('.')), parseArgs(args ?? []));
        });

        set('createInstance', function(tag:String, path:String, ?args:Array<Dynamic>)
        {
            var cl:Dynamic = LuaPresetUtils.getClass(path);

            if (cl == null)
                return;

            setTag(tag, Type.createInstance(cl, parseArgs(args ?? [])));
        });

        set('addInstance', function(tag:String)
        {
            deprecatedPrint('Use "add" instead of "addInstance"');

            if (tagIs(tag, flixel.FlxBasic))
                game.add(getTag(tag));
        });

        set('instanceArg', function(tag:String)
        {
            return INSTANCE_ARG_ID + tag;
        });
    }
}
