# LuaCamera

### > `cameraShake(camera:String, tag:String, ?intensity:Float, ?duration:Float, ?force:Bool, ?axes:FlxAxes)`

#### Shakes a camera 

- `camera`: ID of the camera 

- `tag`: ID of the shake 

- `intensity`: Intensity of the shake 

- `duration`: Duration of the shake 

- `force`: Defines if the shake will be forced 

- `axes`: Defines the axes in which the camera will shake. Can be `0x00`, `0x01`, `0x11` or `0x10` 

---

### > `cameraFlash(camera:String, tag:String, ?color:FlxColor, ?duration:Float, ?force:Bool)`

#### Flashes a camera with a color overlay 

- `camera`: ID of the camera 

- `tag`: ID of the flash effect 

- `color`: Overlay color 

- `duration`: Duration of the flash 

- `force`: Defines whether the flash will be forced 

---

### > `cameraFade(camera:String, tag:String, ?color:FlxColor, ?duration:Float, ?fadeIn:Bool, ?force:Bool)`

#### Fades a camera in or out to a color 

- `camera`: ID of the camera 

- `tag`: ID of the fade effect 

- `color`: Fade color 

- `duration`: Duration of the fade 

- `fadeIn`: Defines whether the fade will fade in (`true`) or out (`false`) 

- `force`: Defines whether the fade will be forced 

---

### > `stopCameraFX(camera:String)`

#### Stops all camera effects (shake, fade and flash) 

- `camera`: ID of the camera 

---

### > `stopCameraFade(camera:String)`

#### Stops the current camera fade 

- `camera`: ID of the camera 

---

### > `stopCameraFlash(camera:String)`

#### Stops the current camera flash 

- `camera`: ID of the camera 

---

### > `stopCameraShake(camera:String)`

#### Stops the current camera shake 

- `camera`: ID of the camera 

---

### > `cameraFollow(camera:String, target:String, ?lerp:Float)`

#### Makes a camera follow an object 

- `camera`: ID of the camera 

- `target`: ID of the object to follow 

- `lerp`: Lerp value used by the camera follow 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)