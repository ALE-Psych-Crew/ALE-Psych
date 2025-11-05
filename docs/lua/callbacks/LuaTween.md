# LuaTween

### > `tween(tag:String, obj:String, props:Dynamic, ?time:Float, ?options:Dynamic)`

#### Creates and starts a `FlxTween` 

- `tag`: Tween ID 

- `obj`: ID of the object the tween will act on 

- `props`: Table of object variables that will be modified 

- `time`: Tween duration 

- `options`: Tween options. See [TweenOptions](https://api.haxeflixel.com/flixel/tweens/TweenOptions.html) 

---

### > `doTweenX(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)`

#### Creates and starts a tween on an object and its `x` variable 

- `tag`: Tween ID 

- `obj`: Object ID 

- `value`: Value for `x` 

- `time`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `tween` instead 

---

### > `doTweenY(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)`

#### Creates and starts a tween on an object and its `y` variable 

- `tag`: Tween ID 

- `obj`: Object ID 

- `value`: Value for `y` 

- `time`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `tween` instead 

---

### > `doTweenAngle(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)`

#### Creates and starts a tween on an object and its `angle` variable 

- `tag`: Tween ID 

- `obj`: Object ID 

- `value`: Value for `angle` 

- `time`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `tween` instead 

---

### > `doTweenAlpha(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)`

#### Creates and starts a tween on an object and its `alpha` variable 

- `tag`: Tween ID 

- `obj`: Object ID 

- `value`: Value for `alpha` 

- `time`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `tween` instead 

---

### > `doTweenZoom(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)`

#### Creates and starts a tween on an object and its `zoom` variable 

- `tag`: Tween ID 

- `obj`: Object ID 

- `value`: Value for `zoom` 

- `time`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `tween` instead 

---

### > `doTweenColor(tag:String, obj:String, value:Dynamic, ?time:Float, ?ease:String)`

#### Creates and starts a tween on an object and its `color` variable 

- `tag`: Tween ID 

- `obj`: Object ID 

- `value`: Value for `color` 

- `time`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `tween` instead 

---

### > `colorTween(tag:String, obj:String, ?time:Float, ?from:FlxColor, ?to:FlxColor, ?options:Dynamic)`

#### Creates and starts a tween that will change an object's color 

- `tag`: Tween ID 

- `obj`: Object ID 

- `time`: Tween duration 

- `from`: Starting color 

- `to`: Ending color 

- `options`: Tween options. See [TweenOptions](https://api.haxeflixel.com/flixel/tweens/TweenOptions.html) 

---

### > `cancelTween(tag:String)`

#### Cancels a tween 

- `tag`: Tween ID 

---

### > `cancelTweensOf(tag:String)`

#### Cancels all tweens running on an object 

- `tag`: Object ID whose tweens will be cancelled 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)