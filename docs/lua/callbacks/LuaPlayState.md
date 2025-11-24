# LuaPlayState

### > `inChartEditor(false, ;)`

#### Whether the current PlayState was launched from the Chart Editor. 

---

### > `curBpm(Conductor.bpm, ;)`

#### Current Conductor BPM value. 

---

### > `bpm(PlayState.SONG.bpm, ;)`

#### Song BPM defined in the loaded chart. 

---

### > `scrollSpeed(PlayState.SONG.speed, ;)`

#### Scroll speed defined by the chart. 

---

### > `crochet(Conductor.crochet, ;)`

#### Duration of a crochet (quarter note), in milliseconds. 

---

### > `stepCrochet(Conductor.stepCrochet, ;)`

#### Duration of a step, in milliseconds. 

---

### > `songLength(FlxG.sound.music.length, ;)`

#### Length of the current song, in milliseconds. 

---

### > `songName(PlayState.SONG.song, ;)`

#### Name of the current song. 

---

### > `songPath(PlayState.songRoute, ;)`

#### File system path to the current song. 

---

### > `startedCountdown(false, ;)`

#### Whether the song countdown has already started. 

---

### > `curStage(PlayState.SONG.stage, ;)`

#### Name of the stage currently in use. 

---

### > `isStoryMode(PlayState.isStoryMode, ;)`

#### Whether the game is currently in Story Mode. 

---

### > `difficulty(PlayState.difficulty, ;)`

#### Numeric difficulty of the current chart. 

---

### > `week(PlayState.week, ;)`

#### Current week identifier. 

---

### > `seenCutscene(PlayState.seenCutscene, ;)`

#### Whether the cutscene for the song has already been seen. 

---

### > `hasVocals(PlayState.SONG.needsVoices, ;)`

#### Whether the song uses vocal tracks. 

---

### > `cameraX(0, ;)`

#### Camera X coordinate override. 

---

### > `cameraY(0, ;)`

#### Camera Y coordinate override. 

---

### > `score(0, ;)`

#### Player score value. 

---

### > `misses(0, ;)`

#### Amount of missed notes in the current song. 

---

### > `hits(0, ;)`

#### Amount of successful note hits. 

---

### > `combo(0, ;)`

#### Current note combo value. 

---

### > `rating(0, ;)`

#### Current accuracy rating value. 

---

### > `ratingName(;)`

#### Rating name string for the current accuracy. 

---

### > `ratingFC(;)`

#### Rating FC label for the run. 

---

### > `inplayStateOver(false, ;)`

#### Whether the PlayState has already reached game over. 

---

### > `mustHitSection(false, ;)`

#### Whether the current section belongs to the player (must-hit section). 

---

### > `altAnim(false, ;)`

#### Whether alt animations are active for the opponent section. 

---

### > `gfSection(false, ;)`

#### Whether the current section is dedicated to the girlfriend character. 

---

### > `healthGainMult(playState.healthGain, ;)`

#### Multiplier applied to health gained on successful hits. 

---

### > `healthLossMult(playState.healthLoss, ;)`

#### Multiplier applied to health lost on misses. 

---

### > `playbackRate(playState.playbackRate, ;)`

#### Current playback rate affecting song speed. 

---

### > `playbackRate(1, ;)`

#### Current playback rate affecting song speed. 

---

### > `guitarHeroSustains(playState.guitarHeroSustains, ;)`

#### Whether sustains use Guitar Hero-style behavior. 

---

### > `botPlay(playState.cpuControlled, ;)`

#### Whether BotPlay is enabled. 

---

### > `practice(playState.practiceMode, ;)`

#### Whether Practice mode is enabled. 

---

### > `defaultPlayerStrumX(+, i, 0, ;)`

#### Default X position for player strum note ${i}. 

---

### > `defaultPlayerStrumY(+, i, 0, ;)`

#### Default Y position for player strum note ${i}. 

---

### > `defaultOpponentStrumX(+, i, 0, ;)`

#### Default X position for opponent strum note ${i}. 

---

### > `defaultOpponentStrumY(+, i, 0, ;)`

#### Default Y position for opponent strum note ${i}. 

---

### > `defaultBoyfriendX(playState.BF_X, ;)`

#### Default X position for the boyfriend character. 

---

### > `defaultBoyfriendY(playState.BF_Y, ;)`

#### Default Y position for the boyfriend character. 

---

### > `defaultOpponentX(playState.DAD_X, ;)`

#### Default X position for the dad/opponent character. 

---

### > `defaultOpponentY(playState.DAD_Y, ;)`

#### Default Y position for the dad/opponent character. 

---

### > `defaultGirlfriendX(playState.GF_X, ;)`

#### Default X position for the girlfriend character. 

---

### > `defaultGirlfriendY(playState.GF_Y, ;)`

#### Default Y position for the girlfriend character. 

---

### > `boyfriendName(PlayState.SONG.player1, ;)`

#### Name of the boyfriend character being used. 

---

### > `dadName(PlayState.SONG.player2, ;)`

#### Name of the dad/opponent character being used. 

---

### > `gfName(PlayState.SONG.gfVersion, ;)`

#### Name of the girlfriend character being used. 

---

### > `splashAlpha(ClientPrefs.data.splashAlpha, ;)`

#### Alpha multiplier applied to note splashes. 

---

### > `buildTarget(CoolUtil.getBuildTarget, ;)`

#### Build target the engine was compiled for. 

---

### > `startCountdown(playState.startCountdown, ;)`

#### Starts the song countdown sequence. 

---

### > `endSong()`

#### Ends the song. 

---

### > `restartSong()`

#### Restarts the song. @note Resets volumes and state, then reloads the PlayState. 

---

### > `exitSong()`

#### Exits the song to the corresponding menu. @note Chooses Story Menu or Freeplay based on isStoryMode. 

---

### > `cameraSetTarget(target:String)`

#### Sets the game camera target. 

- `target`: Camera target. Can be `gf`/`girlfriend`, `dad`/`opponent`, or `bf`/`boyfriend`. 

---

### > `triggerEvent(name:String, arg1:Dynamic, arg2:Dynamic)`

#### Triggers an event in the song. 

- `name`: Event name. 

- `arg1`: First event argument. 

- `arg2`: Second event argument. @note The event is fired at the current song position. 

---

### > `characterDance(character:String)`

#### Executes dance logic on a character. 

- `character`: Character to use. Can be `gf`/`girlfriend`, `dad`/`opponent`, or `bf`/`boyfriend`. 

---

### > `noteTween(tag:String, note:Int, props:Dynamic, ?time:Float, ?options:Dynamic)`

#### Performs a tween on a note. 

- `tag`:   Tween ID. 

- `note`:  Note position in the strumLine. 

- `props`: Table of variables to modify. 

- `time`:  Tween duration. (optional) 

- `options`: Tween options. See https://api.haxeflixel.com/flixel/tweens/TweenOptions.html (optional) @note Stores the tween handle under the provided tag. 

---

### > `noteTweenX(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `x` variable of a note. 

- `tag`:      Tween ID. 

- `note`:     Note position in the strumLine. 

- `value`:    Variable value. 

- `duration`: Tween duration. 

- `ease`:     Tween ease. 

###### `DEPRECATED`: Use `noteTween` instead. 

---

### > `noteTweenY(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `y` variable of a note. 

- `tag`:      Tween ID. 

- `note`:     Note position in the strumLine. 

- `value`:    Variable value. 

- `duration`: Tween duration. 

- `ease`:     Tween ease. 

###### `DEPRECATED`: Use `noteTween` instead. 

---

### > `noteTweenAngle(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `angle` variable of a note. 

- `tag`:      Tween ID. 

- `note`:     Note position in the strumLine. 

- `value`:    Variable value. 

- `duration`: Tween duration. 

- `ease`:     Tween ease. 

###### `DEPRECATED`: Use `noteTween` instead. 

---

### > `noteTweenDirection(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `direction` variable of a note. 

- `tag`:      Tween ID. 

- `note`:     Note position in the strumLine. 

- `value`:    Variable value. 

- `duration`: Tween duration. 

- `ease`:     Tween ease. 

###### `DEPRECATED`: Use `noteTween` instead. 

---

### > `noteTweenAlpha(tag:String, note:Int, value:Dynamic, duration:Float, ease:String)`

#### Performs a tween on the `alpha` variable of a note. 

- `tag`:      Tween ID. 

- `note`:     Note position in the strumLine. 

- `value`:    Variable value. 

- `duration`: Tween duration. 

- `ease`:     Tween ease. 

###### `DEPRECATED`: Use `noteTween` instead. 

---

### > `addBehindGF(obj:String)`

#### Adds an object to the game behind the Girlfriend entity. 

- `obj`: Object ID. 

---

### > `addBehindBF(obj:String)`

#### Adds an object to the game behind the Boyfriend entity. 

- `obj`: Object ID. 

---

### > `addBehindDad(obj:String)`

#### Adds an object to the game behind the Dad entity. 

- `obj`: Object ID. 

---

### > `adjustMobileControls()`

#### Adjusts on-screen mobile controls to the current PlayState. 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)