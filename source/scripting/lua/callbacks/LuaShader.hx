package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import funkin.visuals.shaders.RuntimeShader;
import funkin.visuals.shaders.FXShader;

import openfl.filters.ShaderFilter;

class LuaShader extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('initLuaShader', function(tag:String, name:String)
        {
            deprecatedPrint('Use "makeLuaShader" instead of "initLuaShader"');

            setTag(tag, new RuntimeShader(name));
        });

        set('makeLuaShader', function(tag:String, name:String, ?force:Bool)
        {
            setTag(tag, new FXShader(name, force));
        });

        set('setCameraShaders', function(camera:String, shaderTags:Array<String>)
            {
                var procShaders:Array<ShaderFilter> = [];

                for (tag in shaderTags)
                    if (tagIs(tag, RuntimeShader))
                        procShaders.push(new ShaderFilter(getTag(tag)));

                if (tagIs(camera, FlxCamera))
                    getTag(camera).filters = procShaders;
            }
        );

        set('setSpriteShader', function(tag:String, name:String)
        {
            if (tagIs(tag, FlxSprite) && tagIs(name, RuntimeShader))
                getTag(tag).shader = getTag(name);
        });

        set('setShaderInt', function(tag:String, id:String, int:Int)
            {
                if (tagIs(tag, RuntimeShader))
                    getTag(tag).setInt(id, int);
            }
        );

        set('getShaderInt', function(tag:String, id:String):Null<Int>
            {
                if (tagIs(tag, RuntimeShader))
                    return getTag(tag).getInt(id);

                return null;
            }
        );

        set('setShaderIntArray', function(tag:String, id:String, ints:Array<Int>)
            {
                if (tagIs(tag, RuntimeShader))
                    getTag(tag).setIntArray(id, ints);
            }
        );

        set('getShaderIntArray', function(tag:String, id:String):Null<Array<Int>>
            {
                if (tagIs(tag, RuntimeShader))
                    return getTag(tag).getIntArray(id);

                return null;
            }
        );

        set('setShaderFloat', function(tag:String, id:String, float:Float)
            {
                if (tagIs(tag, RuntimeShader))
                    getTag(tag).setFloat(id, float);
            }
        );

        set('getShaderFloat', function(tag:String, id:String):Null<Float>
            {
                if (tagIs(tag, RuntimeShader))
                    return getTag(tag).getFloat(id);

                return null;
            }
        );

        set('setShaderFloatArray', function(tag:String, id:String, floats:Array<Float>)
            {
                if (tagIs(tag, RuntimeShader))
                    getTag(tag).setFloatArray(id, floats);
            }
        );

        set('getShaderFloatArray', function(tag:String, id:String):Null<Array<Float>>
            {
                if (tagIs(tag, RuntimeShader))
                    return getTag(tag).getFloatArray(id);

                return null;
            }
        );

        set('setShaderBool', function(tag:String, id:String, bool:Bool)
            {
                if (tagIs(tag, RuntimeShader))
                    getTag(tag).setBool(id, bool);
            }
        );

        set('getShaderBool', function(tag:String, id:String):Null<Bool>
            {
                if (tagIs(tag, RuntimeShader))
                    return getTag(tag).getBool(id);

                return null;
            }
        );

        set('setShaderBoolArray', function(tag:String, id:String, bools:Array<Bool>)
            {
                if (tagIs(tag, RuntimeShader))
                    getTag(tag).setBoolArray(id, bools);
            }
        );

        set('getShaderBoolArray', function(tag:String, id:String):Null<Array<Bool>>
            {
                if (tagIs(tag, RuntimeShader))
                    return getTag(tag).getBoolArray(id);

                return null;
            }
        );

        set('setShaderSample2D', function(tag:String, id:String, path:String)
        {
            if (tagIs(tag, RuntimeShader))
                getTag(tag).setSampler2D(id, Paths.image(path).bitmap);
        });
    }
}
