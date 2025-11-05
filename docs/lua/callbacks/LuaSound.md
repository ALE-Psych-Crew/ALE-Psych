# LuaSound

### > `playMusic(sound:String, ?volume:Float, ?loop:Bool)`

#### Plays music in the game 

- `sound`: Audio path 

- `volume`: Music volume (from 0 to 1) 

- `loop`: Defines whether the music loops 

---

### > `playSound(sound:String, ?volume:Float, ?tag:String, ?loop:Bool)`

#### Plays a sound 

- `sound`: Audio path 

- `volume`: Sound volume (from 0 to 1) 

- `tag`: Sound ID 

- `loop`: Defines whether the sound loops 

---

### > `stopSound(tag:String)`

#### Stops a sound 

- `tag`: Sound ID 

---

### > `pauseSound(tag:String)`

#### Pauses a sound 

- `tag`: Sound ID 

---

### > `resumeSound(tag:String)`

#### Resumes a sound 

- `tag`: Sound ID 

---

### > `soundFadeIn(tag:String, ?duration:Float, ?fromValue:Float, ?toValue:Float)`

#### Changes a sound's volume over a set time 

- `tag`: Sound ID 

- `duration`: Duration of the change 

- `fromValue`: Starting volume 

- `toValue`: Ending volume 

---

### > `soundFadeOut(tag:String, ?duration:Float, ?toValue:Float)`

#### Changes a sound's volume over a set time 

- `tag`: Sound ID 

- `duration`: Duration of the change 

- `toValue`: Ending volume 

---

### > `soundFadeCancel(tag:String)`

#### Stops a sound's volume change 

- `tag`: Sound ID 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)