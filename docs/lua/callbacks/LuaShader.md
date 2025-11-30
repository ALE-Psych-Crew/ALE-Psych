# LuaShader

### > `initLuaShader(tag:String, name:String)`

#### Creates an `ALERuntimeShader` 

- `tag`: Shader ID 

- `name`: File name 

---

### > `setCameraShaders(camera:String, shaderTags:Array<String>)`

#### Applies shaders to a camera 

- `camera`: Camera ID 

- `shaderTags`: List of shader IDs 

---

### > `setSpriteShader(tag:String, name:String)`

#### Applies a shader to a sprite 

- `tag`: Sprite ID 

- `name`: Shader ID 

---

### > `setShaderInt(tag:String, id:String, int:Int)`

#### Sets an integer on a shader 

- `tag`: Shader ID 

- `id`: Integer ID 

- `int`: Integer value 

---

### > `getShaderInt(tag:String, id:String):Null<Int>`

#### Gets an integer from a shader 

- `tag`: Shader ID 

- `id`: Integer ID 

#### `RETURN`: Integer value 

---

### > `setShaderIntArray(tag:String, id:String, ints:Array<Int>)`

#### Sets a list of integers on a shader 

- `tag`: Shader ID 

- `id`: Integer list ID 

- `ints`: List of integers 

---

### > `getShaderIntArray(tag:String, id:String):Null<Array<Int>>`

#### Gets a list of integers from a shader 

- `tag`: Shader ID 

- `id`: Integer list ID 

#### `RETURN`: List of integers 

---

### > `setShaderFloat(tag:String, id:String, float:Float)`

#### Sets a float on a shader 

- `tag`: Shader ID 

- `id`: Float ID 

- `float`: Float value 

---

### > `getShaderFloat(tag:String, id:String):Null<Float>`

#### Gets a float from a shader 

- `tag`: Shader ID 

- `id`: Float ID 

#### `RETURN`: Float value 

---

### > `setShaderFloatArray(tag:String, id:String, floats:Array<Float>)`

#### Sets a list of floats on a shader 

- `tag`: Shader ID 

- `id`: Float list ID 

- `float`: List of floats 

---

### > `getShaderFloatArray(tag:String, id:String):Null<Array<Float>>`

#### Gets a list of floats from a shader 

- `tag`: Shader ID 

- `id`: Float list ID 

#### `RETURN`: List of floats 

---

### > `setShaderBool(tag:String, id:String, bool:Bool)`

#### Sets a boolean on a shader 

- `tag`: Shader ID 

- `id`: Boolean ID 

- `bool`: Boolean value 

---

### > `getShaderBool(tag:String, id:String):Null<Bool>`

#### Gets a boolean from a shader 

- `tag`: Shader ID 

- `id`: Boolean ID 

#### `RETURN`: Boolean value 

---

### > `setShaderBoolArray(tag:String, id:String, bools:Array<Bool>)`

#### Sets a list of booleans on a shader 

- `tag`: Shader ID 

- `id`: Boolean list ID 

- `bools`: List of booleans 

---

### > `getShaderBoolArray(tag:String, id:String):Null<Array<Bool>>`

#### Gets a list of booleans from a shader 

- `tag`: Shader ID 

- `id`: Boolean list ID 

#### `RETURN`: List of booleans 

---

### > `setShaderSample2D(tag:String, id:String, path:String)`

#### Sets a sampler2D on a shader 

- `tag`: Shader ID 

- `id`: sampler2D ID 

- `path`: Image path 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)