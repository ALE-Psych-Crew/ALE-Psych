# LuaReflect

### > `getProperty(tag:String):Dynamic`

#### Gets a value from an object 

- `tag`: Variable being searched 

#### `RETURN`: Variable value 

---

### > `getPropertyFromGroup(tag:String, index:Int, prop:String):Dynamic`

#### Gets a value from an object in a group 

- `tag`: Group ID 

- `index`: Object position in the group 

- `prop`: Variable being searched 

#### `RETURN`: Variable value 

---

### > `getPropertyFromClass(path:String, prop:String):Dynamic`

#### Gets a value from a class object 

- `path`: Class path 

- `prop`: Variable being searched 

#### `RETURN`: Variable value 

---

### > `setProperty(tag:String, value:Dynamic)`

#### Sets a value to a variable on an object 

- `tag`: Object ID 

- `value`: Variable value 

---

### > `setPropertyFromGroup(tag:String, index:Int, prop:String, value:Dynamic)`

#### Sets a value to a variable of an object in a group 

- `tag`: Group ID 

- `index`: Object position in the group 

- `prop`: Object variable 

- `value`: Variable value 

---

### > `setPropertyFromClass(path:String, prop:String, value:Dynamic)`

#### Sets a value to a variable in a class 

- `path`: Class path 

- `prop`: Variable being searched 

- `value`: Variable value 

---

### > `setProperties(tag:String, props:Any)`

#### Sets multiple properties of an object 

- `tag`: Object ID 

- `props`: Table of object variables 

---

### > `setPropertiesFromGroup(tag:String, index:Int, props:Any)`

#### Sets multiple properties of an object in a group 

- `tag`: Group ID 

- `index`: Object position in the group 

- `props`: Table of object variables 

---

### > `setPropertiesFromClass(path:String, props:Any)`

#### Sets multiple properties of a class 

- `path`: Class path 

- `props`: Table of class variables 

---

### > `callMethod(tag:String, ?args:Array<Dynamic>):Dynamic`

#### Calls a function of an object 

- `tag`: Function name 

- `args`: Function arguments 

#### `RETURN`: Returns the function's return value 

---

### > `callMethodFromClass(path:String, func:String, ?args:Array<Dynamic>):Dynamic`

#### Calls a function of a class 

- `path`: Class path 

- `func`: Function name 

- `args`: Function arguments 

#### `RETURN`: Returns the function's return value 

---

### > `createInstance(tag:String, path:String, ?args:Array<Dynamic>)`

#### Creates an instance of a class 

- `tag`: Instance ID 

- `path`: Class path 

- `args`: Instance arguments 

---

### > `addInstance(tag:String)`

#### Adds an instance to the game 

- `tag`: Instance ID 

###### `DEPRECATED`: Use `add` instead 

---

### > `instanceArg(tag:String)`

#### Formats the string in a way that the game will interpret it as an object/instance 

- `tag`: Instance ID 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)