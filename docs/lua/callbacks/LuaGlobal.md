# LuaGlobal

### > `add(tag:String)`

#### Adds an object to the game 

- `tag`: ID of the object 

---

### > `remove(tag:String, ?destroy:Bool)`

#### Removes an object from the game 

- `tag`: ID of the object 

- `destroy`: Defines whether the object should be destroyed 

---

### > `insert(position:Int, tag:String)`

#### Inserts an object into the game 

- `position`: Position where the object will be inserted 

- `tag`: ID of the object 

---

### > `getObjectOrder(tag:String)`

#### Gets the position of an object in the game 

- `tag`: ID of the object 

#### `RETURN`: Object position 

---

### > `setObjectOrder(tag:String, position:Int)`

#### Removes and reinserts an object in a different position 

- `tag`: ID of the object 

- `position`: New position 

---

### > `getRandomInt(?min:Int, ?max:Int, ?excludes:Array<Int>)`

#### Gets a random integer 

- `min`: Smallest integer 

- `max`: Largest integer 

- `excludes`: Integers that will not be used 

#### `RETURN`: Obtained integer 

---

### > `getRandomFloat(?min:Float, ?max:Float, ?excludes:Array<Float>)`

#### Gets a random float 

- `min`: Smallest float 

- `max`: Largest float 

- `excludes`: Floats that will not be used 

#### `RETURN`: Obtained float 

---

### > `getRandomBool(?chance:Float)`

#### Gets a random boolean 

- `chance`: Probability that the value is `true` (from 0 to 100) 

#### `RETURN`: Obtained boolean 

---

### > `registerGlobalFunction(name:String)`

#### 

---

### > `registerGlobalLuaFunction(name:String)`

#### 

---

### > `registerGlobalHScriptFunction(name:String)`

#### 

