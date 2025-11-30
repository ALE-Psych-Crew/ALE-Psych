# LuaCoolUtil

### > `colorFromString(str:String):FlxColor`

#### Gets a color from a String that contains its HEX code 

- `str`: String with the HEX code 

#### `RETURN`: Obtained color 

---

### > `getDominantColor(tag:String):FlxColor`

#### Gets the most frequent color in a sprite 

- `tag`: ID of the sprite 

#### `RETURN`: Most frequent color 

---

### > `colorFromArray(arr:Array<Int>):FlxColor`

#### Gets a color from a list 

- `arr`: List with the color in RGB 

#### `RETURN`: Obtained color 

---

### > `resetEngine()`

#### Resets the engine and some of its variables 

---

### > `reloadGameMetadata()`

#### Reloads the engine metadata found in `data.json` 

---

### > `resizeGame(width:Int, height:Int, ?centerWindow:Bool)`

#### Changes the window and game size 

- `width`: Game width 

- `height`: Game height 

- `centerWindow`: Defines whether to center the game on screen or not 

---

### > `searchComplexFile(path:String, ?missingPrint:Bool):String`

#### Searches for a file path ignoring spaces and case, being more flexible 

- `path`: File path 

- `missingPrint`: Defines whether to warn if the file does not exist 

#### `RETURN`: Real file path 

---

### > `searchFile(parent:String, file:String):String`

#### Searches for a file path within a folder ignoring spaces and case 

- `parent`: Folder where it is searched 

- `file`: File being searched 

#### `RETURN`: Real file path 

---

### > `openFolder(folder:String, ?absolute:Bool)`

#### Opens the file explorer at a specific folder 

- `folder`: Folder to open 

- `absolute`: Defines whether to resolve from the computer root or from the game folder 

---

### > `formatToSongPath(str:String):String`

#### Lowercases a string and replaces spaces with hyphens 

- `str`: String to process 

#### `RETURN`: Processed string 

---

### > `debugTrace(text:Dynamic, ?type:PrintType, ?customType:String, =, ?customColor:FlxColor)`

#### Prints text that includes the time it was printed and colors to help distinguish the displayed information 

- `text`: Text to display 

- `type`: Type of text to display. Can be `error`, `warning`, `deprecated`, `trace`, `hscript`, `lua`, `missing_file`, `missing_folder`, `custom` or `pop-up`, 

- `customType`: Assigns a custom text type 

- `customColor`: Assigns a custom text color 

---

### > `ansiColorString(str:String, color:FlxColor):String`

#### Helps obtain a string which, when printed to the console, will have the indicated color 

- `str`: Text to color 

- `color`: Color to apply 

#### `RETURN`: Colored text 

---

### > `floorDecimal(num:Float, decimals:Int):Float`

#### Rounds a decimal number but allows showing a certain number of decimals 

- `num`: Number to round 

- `decimals`: Maximum number of decimals to show 

#### `RETURN`: Rounded number with its decimals 

---

### > `quantize(f:Float, snap:Float):Float`

#### Snaps a number to a grid 

- `f`: Original value 

- `snap`: Number of divisions or steps 

#### `RETURN`: Value quantized to the nearest multiple of 1/snap 

---

### > `numberArray(max:Int, ?min:Int):Array<Int>`

#### Generates a list of numbers 

- `max`: Maximum number of the list 

- `min`: Minimum number of the list 

#### `RETURN`: List of numbers 

---

### > `fpsLerp(v1:Float, v2:Float, ratio:Float):Float`

#### Interpolates between two values taking FPS into account 

- `v1`: Start value 

- `v2`: End value 

- `ratio`: Interpolation ratio (0 to 1) 

#### `RETURN`: Interpolated value adjusted to the FPS rate 

---

### > `fpsRatio(ratio:Float):Float`

#### Adjusts a ratio based on elapsed time and clamps it between 0 and 1 

- `ratio`: Base ratio 

#### `RETURN`: Ratio corrected according to FPS 

---

### > `loadPlayStateSong(name:String, difficulty:String):PlayStateJSONData`

#### Preloads a song JSON in PlayState 

- `name`: Song name 

- `difficulty`: Song difficulty 

#### `RETURN`: Table with the song path (`.route`) and the loaded JSON (`.json`) 

---

### > `loadSong(name:String, difficulty:String, ?goToPlayState)`

#### Loads a song 

- `name`: Song name 

- `difficulty`: Song difficulty 

- `goToPlayState`: Defines whether the game should go to PlayState 

---

### > `loadWeek(weekName:String, names:Array<String>, difficulty:String, ?goToPlayState:Bool)`

#### Loads a week 

- `weekName`: Week name 

- `names`: List with the song names 

- `difficulty`: Week difficulty 

- `goToPlayState`: Defines whether the game should go to PlayState 

---

### > `resetState()`

#### Reinitializes the current state 

---

### > `switchState(state:String, ?args:Array<Dynamic>, ?skipTransIn:Bool, ?skipTransOut:Bool)`

#### Switches the game to a state 

- `state`: Class path of the state 

- `args`: Arguments for the class instance 

- `skipTransIn`: Defines whether the entry transition will be shown 

- `skipTransOut`: Defines whether the exit transition will be shown 

---

### > `openSubState(substate:String, ?args:Array<Dynamic>)`

#### Opens a sub-state 

- `substate`: Class path of the substate 

- `args`: Arguments for the class instance 

---

### > `capitalizeString(str:String):String`

#### Capitalizes a string 

- `str`: String to capitalize 

#### `RETURN`: Capitalized string 

---

### > `listFromString(str:String):Array<String>`

#### Extracts a list based on the line breaks of a string 

- `str`: String to process 

#### `RETURN`: List of lines 

---

### > `browserLoad(site:String)`

#### Opens a URL in the browser 

- `site`: Site URL 

---

### > `getBuildTarget():String`

#### Gets the target the engine was compiled for 

#### `RETURN`: Obtained target 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)