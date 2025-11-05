# LuaPlayState

### > `endSong()`

#### Ends the song 

---

### > `restartSong()`

#### Restarts the song 

---

### > `exitSong()`

#### Exits the song to the corresponding menu 

---

### > `cameraSetTarget(target:String)`

#### Sets the game camera target 

- `target`: Camera target. Can be `gf`/`girlfriend`, `dad`/`opponent` or `bf`/`boyfriend` 

---

### > `triggerEvent(name:String, arg1:Dynamic, arg2:Dynamic)`

#### Triggers an event in the song 

- `name`: Event name 

- `arg1`: First event argument 

- `arg2`: Second event argument 

---

### > `characterDance(character:String)`

#### Executes dance logic on a character 

- `character`: Character to use. Can be `gf`/`girlfriend`, `dad`/`opponent` or `bf`/`boyfriend` 

---

### > `noteTween(tag:String, note:Int, props:Dynamic, ?time:Float, ?options:Dynamic)`

#### Performs a tween on a note 

- `tag`: Tween ID 

- `note`: Note position in the strumLine 

- `props`: Table of variables to modify 

- `time`: Tween duration 

- `options`: Tween options. See [TweenOptions](https://api.haxeflixel.com/flixel/tweens/TweenOptions.html) 

---

### > `noteTweenX(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `x` variable of a note 

- `tag`: Tween ID 

- `note`: Note position in the strumLine 

- `value`: Variable value 

- `duration`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `noteTween` instead 

---

### > `noteTweenY(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `y` variable of a note 

- `tag`: Tween ID 

- `note`: Note position in the strumLine 

- `value`: Variable value 

- `duration`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `noteTween` instead 

---

### > `noteTweenAngle(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `angle` variable of a note 

- `tag`: Tween ID 

- `note`: Note position in the strumLine 

- `value`: Variable value 

- `duration`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `noteTween` instead 

---

### > `noteTweenDirection(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `direction` variable of a note 

- `tag`: Tween ID 

- `note`: Note position in the strumLine 

- `value`: Variable value 

- `duration`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `noteTween` instead 

---

### > `noteTweenAlpha(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `alpha` variable of a note 

- `tag`: Tween ID 

- `note`: Note position in the strumLine 

- `value`: Variable value 

- `duration`: Tween duration 

- `ease`: Tween ease 

###### `DEPRECATED`: Use `noteTween` instead 

---

### > `addBehindGF(obj:String)`

#### Adds an object to the game behind the Girlfriend entity 

- `obj`: Object ID 

---

### > `addBehindBF(obj:String)`

#### Adds an object to the game behind the Boyfriend entity 

- `obj`: Object ID 

---

### > `addBehindDad(obj:String)`

#### Adds an object to the game behind the Dad entity 

- `obj`: Object ID 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)