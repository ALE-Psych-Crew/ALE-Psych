# LuaSprite

### > `makeLuaSprite(tag:String, ?image:String, ?x:Float, ?y:Float)`

#### Creates a `FlxSprite` 

- `tag`: Sprite ID 

- `image`: Image path 

- `x`: Position on `x` 

- `y`: Position on `y` 

---

### > `loadGraphic(tag:String, sprite:String, ?gridX:Int, =, 0, ?gridY:Int, =, 0)`

#### Loads a graphic into a sprite 

- `tag`: Sprite ID 

- `sprite`: Image path 

- `gridX`: Maximum graphic width 

- `gridY`: Maximum graphic height 

---

### > `makeGraphic(tag:String, x:Float, y:Float, ?color:FlxColor)`

#### Creates a square graphic and loads it into a sprite 

- `tag`: Sprite ID 

- `x`: Graphic width 

- `y`: Graphic height 

- `color`: Graphic color 

---

### > `loadFrames(tag:String, sprite:String, ?spriteType:String)`

#### Loads an animated graphic into a sprite 

- `tag`: Sprite ID 

- `sprite`: Image path 

- `spriteType`: Graphic type. Can be `sparrow`, `packer`, `aseprite` 

---

### > `addAnimationByPrefix(tag:String, name:String, prefix:String, ?framerate:Int, ?loop:Bool)`

#### Adds an animation to the sprite 

- `tag`: Sprite ID 

- `name`: Animation name 

- `prefix`: Animation prefix in the atlas 

- `framerate`: Animation speed in frames 

- `loop`: Defines whether the animation should loop 

---

### > `addAnimation(tag:String, name:String, frames:Array<Int>, ?framerate:Int, ?loop:Bool)`

#### Adds an animation to the sprite 

- `tag`: Sprite ID 

- `name`: Animation name 

- `frames`: Indices that indicate which frames to play and in what order 

- `framerate`: Animation speed in frames 

- `loop`: Defines whether the animation should loop 

---

### > `addAnimationByIndices(tag:String, name:String, prefix:String, indices:Array<Int>, ?framerate:Int, ?loop:Bool)`

#### Adds an animation to the sprite 

- `tag`: Sprite ID 

- `name`: Animation name 

- `prefix`: Animation prefix in the atlas 

- `indices`: Indices that indicate which frames to play and in what order 

- `framerate`: Animation speed in frames 

- `loop`: Defines whether the animation should loop 

---

### > `playAnim(tag:String, name:String, ?forced:Bool, ?reversed:Bool, ?startFrame:Int)`

#### Plays a sprite animation 

- `tag`: Sprite ID 

- `name`: Animation name 

- `forced`: Forces the animation to play 

---

### > `setGraphicSize(tag:String, w:Int, h:Int)`

#### Sets the sprite size in pixels 

- `tag`: Sprite ID 

- `w`: Sprite width 

- `h`: Sprite height 

---

### > `updateHitbox(tag:String)`

#### Updates the sprite hitbox 

- `tag`: Sprite ID 

---

### > `setBlendMode(tag:String, mode:String)`

#### Changes how a sprite's colors blend with others 

- `tag`: Sprite ID 

- `mode`: Defines the color blend mode. Can be `add`,`alpha`,`darken`,`difference`,`erase`,`hardlight`,`invert`,`layer`,`lighten`,`multiply`,`normal`,`overlay`,`screen`,`shader` or `subtract` 

---

### > `getPixelColor(tag:String, x:Int, y:Int):Int`

#### Gets the color of a pixel in a sprite 

- `tag`: Sprite ID 

- `x`: Pixel `x` position 

- `y`: Pixel `y` position 

#### `RETURN`: Pixel color 

---

### > `addLuaSprite(tag:String)`

#### Adds a sprite to the game 

- `tag`: Sprite ID 

###### `DEPRECATED`: Use `add` instead 

---

### > `removeLuaSprite(tag:String, ?destroy:Bool)`

#### Removes a sprite from the game 

- `tag`: Sprite ID 

- `destroy`: Defines whether the sprite should be destroyed 

###### `DEPRECATED`: Use `remove` instead 

---

### > `getMidpointX(tag:String):Float`

#### Gets the `x` coordinate of the sprite midpoint 

- `tag`: Sprite ID 

#### `RETURN`: `x` of the sprite midpoint 

---

### > `getMidpointY(tag:String):Float`

#### Gets the `y` coordinate of the sprite midpoint 

- `tag`: Sprite ID 

#### `RETURN`: `y` of the sprite midpoint 

---

### > `getGraphicMidpointX(tag:String):Float`

#### Gets the `x` coordinate of the sprite graphic midpoint 

- `tag`: Sprite ID 

#### `RETURN`: `x` of the sprite graphic midpoint 

---

### > `getGraphicMidpointY(tag:String):Float`

#### Gets the `y` coordinate of the sprite graphic midpoint 

- `tag`: Sprite ID 

#### `RETURN`: `y` of the sprite graphic midpoint 

---

### > `getScreenPositionX(tag:String):Float`

#### Gets the sprite screen `x` position 

- `tag`: Sprite ID 

#### `RETURN`: Sprite screen `x` position 

---

### > `getScreenPositionY(tag:String):Float`

#### Gets the sprite screen `y` position 

- `tag`: Sprite ID 

#### `RETURN`: Sprite screen `y` position 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)