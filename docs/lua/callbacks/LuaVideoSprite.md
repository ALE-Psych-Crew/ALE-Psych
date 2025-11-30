# LuaVideoSprite

### > `makeLuaVideoSprite(tag:String, ?x:Float, ?y:Float, ?path:String, ?playOnLoad:Bool, ?loop:Bool)`

#### Creates a `VideoSprite` and registers it for Lua access. This loads a video at the given position and optionally starts playback immediately. When the video finishes loading or reaches its end, Lua callbacks are triggered automatically:   - `onVideoSpriteLoad(tag)`   - `onVideoSpriteEndReached(tag)` 

- `tag`: Unique ID of the video sprite object. 

- `x`: Position on the X axis. 

- `y`: Position on the Y axis. 

- `path`: Path of the video file (without extension). 

- `playOnLoad`: Whether to start playback once loaded. 

- `loop`: Whether the video should loop endlessly. 

---

### > `playVideoSprite(tag:String)`

#### Begins or restarts playback of a `VideoSprite`. 

- `tag`: ID of the video sprite. 

---

### > `stopVideoSprite(tag:String)`

#### Stops playback of a `VideoSprite` immediately. 

- `tag`: ID of the video sprite. 

---

### > `pauseVideoSprite(tag:String)`

#### Pauses playback of a `VideoSprite`. 

- `tag`: ID of the video sprite. 

---

### > `resumeVideoSprite(tag:String)`

#### Resumes playback of a paused `VideoSprite`. 

- `tag`: ID of the video sprite. 

---

### > `toggleVideoSpritePaused(tag:String)`

#### Toggles the paused state of a `VideoSprite`. Useful if you want a single function to switch between pause and resume behavior. 

- `tag`: ID of the video sprite. 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)