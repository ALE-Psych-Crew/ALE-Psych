package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import funkin.visuals.shaders.ALERuntimeShader;

class LuaShader extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        set('initLuaShader', function(tag:String, name:String)
        {
            setTag(tag, CoolUtil.createRuntimeShader(name));
        });

        set('setCameraShaders', function(camera:String, shaderTags:Array<String>)
            {
                var procShaders:Array<ALERuntimeShader> = [];

                for (tag in shaderTags)
                    if (tagIs(tag, ALERuntimeShader))
                        procShaders.push(getTag(tag));

                if (tagIs(camera, FlxCamera))
                    CoolUtil.setCameraShaders(getTag(camera), procShaders);
            }
        );

        set('setSpriteShader', function(tag:String, name:String)
        {
            if (tagIs(tag, FlxSprite) && tagIs(name, ALERuntimeShader))
                getTag(tag).shader = getTag(name);
        });

        set('setShaderInt', function(tag:String, id:String, int:Int)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setInt(id, int);
            }
        );

        set('getShaderInt', function(tag:String, id:String):Null<Int>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getInt(id);

                return null;
            }
        );

        set('setShaderIntArray', function(tag:String, id:String, ints:Array<Int>)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setIntArray(id, ints);
            }
        );

        set('getShaderIntArray', function(tag:String, id:String):Null<Array<Int>>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getIntArray(id);

                return null;
            }
        );

        set('setShaderFloat', function(tag:String, id:String, float:Float)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setFloat(id, float);
            }
        );

        set('getShaderFloat', function(tag:String, id:String):Null<Float>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getFloat(id);

                return null;
            }
        );

        set('setShaderFloatArray', function(tag:String, id:String, floats:Array<Float>)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setFloatArray(id, floats);
            }
        );

        set('getShaderFloatArray', function(tag:String, id:String):Null<Array<Float>>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getFloatArray(id);

                return null;
            }
        );

        set('setShaderBool', function(tag:String, id:String, bool:Bool)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setBool(id, bool);
            }
        );

        set('getShaderBool', function(tag:String, id:String):Null<Bool>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getBool(id);

                return null;
            }
        );

        set('setShaderBoolArray', function(tag:String, id:String, bools:Array<Bool>)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setBoolArray(id, bools);
            }
        );

        set('getShaderBoolArray', function(tag:String, id:String):Null<Array<Bool>>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getBoolArray(id);

                return null;
            }
        );

        set('setShaderSample2D', function(tag:String, id:String, path:String)
        {
            if (tagIs(tag, ALERuntimeShader))
                getTag(tag).setSampler2D(id, Paths.image(path).bitmap);
        });
    }
}
