# LuaBasic

### > `setObjectCamera(tag:String, camera:String)`

#### Sets the camera in which an object will be drawn 

- `tag`: ID of the object 

- `camera`: ID of the camera 

###### `DEPRECATED`: Use `setObjectCameras` instead 

---

### > `setObjectCameras(tag:String, cameras:Array<String>)`

#### Sets the cameras in which an object will be drawn 

- `tag`: ID of the object 

- `cameras`: List of camera IDs 

---

### > `objectsOverlap(tag0:String, tag1:String):Bool`

#### Shows if one object is touching another 

- `tag0`: ID of the first object 

- `tag1`: ID of the second object 

#### `RETURN`: Whether the objects are overlapping 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)