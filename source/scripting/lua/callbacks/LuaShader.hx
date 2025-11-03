package scripting.lua.callbacks;

import scripting.lua.LuaPresetBase;

import funkin.visuals.shaders.ALERuntimeShader;

class LuaShader extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Creates an `ALERuntimeShader`
         * 
         * @param tag Shader ID
         * @param name File name
         */
        set('initLuaShader', function(tag:String, name:String)
        {
            setTag(tag, CoolUtil.createRuntimeShader(name));
        });

        /**
         * Applies shaders to a camera
         * 
         * @param camera Camera ID
         * @param shaderTags List of shader IDs
         */
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

        /**
         * Applies a shader to a sprite
         * 
         * @param tag Sprite ID
         * @param name Shader ID
         */
        set('setSpriteShader', function(tag:String, name:String)
        {
            if (tagIs(tag, FlxSprite) && tagIs(name, ALERuntimeShader))
                getTag(tag).shader = getTag(name);
        });

        /**
         * Sets an integer on a shader
         * 
         * @param tag Shader ID
         * @param id Integer ID
         * @param int Integer value
         */
        set('setShaderInt', function(tag:String, id:String, int:Int)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setInt(id, int);
            }
        );

        /**
         * Gets an integer from a shader
         * 
         * @param tag Shader ID
         * @param id Integer ID
         * 
         * @return Integer value
         */
        set('getShaderInt', function(tag:String, id:String):Null<Int>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getInt(id);

                return null;
            }
        );

        /**
         * Sets a list of integers on a shader
         * 
         * @param tag Shader ID
         * @param id Integer list ID
         * @param ints List of integers
         */
        set('setShaderIntArray', function(tag:String, id:String, ints:Array<Int>)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setIntArray(id, ints);
            }
        );

        /**
         * Gets a list of integers from a shader
         * 
         * @param tag Shader ID
         * @param id Integer list ID
         * 
         * @return List of integers
         */
        set('getShaderIntArray', function(tag:String, id:String):Null<Array<Int>>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getIntArray(id);

                return null;
            }
        );

        /**
         * Sets a float on a shader
         * 
         * @param tag Shader ID
         * @param id Float ID
         * @param float Float value
         */
        set('setShaderFloat', function(tag:String, id:String, float:Float)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setFloat(id, float);
            }
        );

        /**
         * Gets a float from a shader
         * 
         * @param tag Shader ID
         * @param id Float ID
         * 
         * @return Float value
         */
        set('getShaderFloat', function(tag:String, id:String):Null<Float>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getFloat(id);

                return null;
            }
        );

        /**
         * Sets a list of floats on a shader
         * 
         * @param tag Shader ID
         * @param id Float list ID
         * @param float List of floats
         */
        set('setShaderFloatArray', function(tag:String, id:String, floats:Array<Float>)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setFloatArray(id, floats);
            }
        );

        /**
         * Gets a list of floats from a shader
         * 
         * @param tag Shader ID
         * @param id Float list ID
         * 
         * @return List of floats
         */
        set('getShaderFloatArray', function(tag:String, id:String):Null<Array<Float>>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getFloatArray(id);

                return null;
            }
        );

        /**
         * Sets a boolean on a shader
         *
         * @param tag Shader ID
         * @param id Boolean ID
         * @param bool Boolean value
         */
        set('setShaderBool', function(tag:String, id:String, bool:Bool)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setBool(id, bool);
            }
        );

        /**
         * Gets a boolean from a shader
         * 
         * @param tag Shader ID
         * @param id Boolean ID
         * 
         * @return Boolean value
         */
        set('getShaderBool', function(tag:String, id:String):Null<Bool>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getBool(id);

                return null;
            }
        );

        /**
         * Sets a list of booleans on a shader
         *
         * @param tag Shader ID
         * @param id Boolean list ID
         * @param bools List of booleans
         */
        set('setShaderBoolArray', function(tag:String, id:String, bools:Array<Bool>)
            {
                if (tagIs(tag, ALERuntimeShader))
                    getTag(tag).setBoolArray(id, bools);
            }
        );

        /**
         * Gets a list of booleans from a shader
         * 
         * @param tag Shader ID
         * @param id Boolean list ID
         * 
         * @return List of booleans
         */
        set('getShaderBoolArray', function(tag:String, id:String):Null<Array<Bool>>
            {
                if (tagIs(tag, ALERuntimeShader))
                    return getTag(tag).getBoolArray(id);

                return null;
            }
        );

        /**
         * Sets a sampler2D on a shader
         * 
         * @param tag Shader ID
         * @param id sampler2D ID
         * @param path Image path
         */
        set('setShaderSample2D', function(tag:String, id:String, path:String)
        {
            if (tagIs(tag, ALERuntimeShader))
                getTag(tag).setSampler2D(id, Paths.image(path).bitmap);
        });
    }
}
