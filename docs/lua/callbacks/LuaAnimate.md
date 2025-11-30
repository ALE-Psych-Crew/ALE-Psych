# LuaAnimate

### > `makeFlxAnimateSprite(tag:String, ?x:Float, ?y:Float, ?loadFolder:String)`

#### Creates a FlxAnimate 

- `tag`: ID of the animate 

- `x`: Position on `x` 

- `y`: Position on `y` 

- `loadFolder`: Path of the atlas 

---

### > `loadAnimateAtlas(tag:String, folderOrImg:Dynamic, ?spriteJson:Dynamic, ?animationJson:Dynamic)`

#### Loads an atlas into an animate 

- `tag`: ID of the animate 

- `folderOrImg`: Path of the spritemap 

- `spriteJson`: Path of the spritemap JSON 

- `animationJson`: Path of the animation JSON 

---

### > `addAnimationBySymbolIndices(tag:String, name:String, symbol:String, indices:Any, ?framerate:Float, ?loop:Bool, ?matX:Float, ?matY:Float)`

#### Adds an animation by its symbol to an animate 

- `tag`: ID of the animate 

- `name`: Name of the animation 

- `symbol`: Symbol name in Adobe Animate 

- `indices`: Indices that indicate which frames and in what order they play 

- `framerate`: Animation speed in frames 

- `loop`: Defines whether the animation should loop or not 

- `matX`: Matrix offset on `x` 

- `matY`: Matrix offset on `y` 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)