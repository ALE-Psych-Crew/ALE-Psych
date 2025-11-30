# LuaText

### > `makeLuaText(tag:String, text:String, width:Int, x:Float, y:Float)`

#### Creates a `FlxText` 

- `tag`: ID of the text 

- `text`: Text to display 

- `width`: Maximum text width 

- `x`: Position `x` 

- `y`: Position `y` 

---

### > `setTextBorder(tag:String, size:Float, color:FlxColor, ?style:String)`

#### Applies a border to text 

- `tag`: ID of the text 

- `size`: Border thickness 

- `color`: Border color 

- `style`: Border style. Can be `shadow`, `outline`, `outline_fast` or `none` 

---

### > `setTextFont(tag:String, newFont:String)`

#### Applies a font to text 

- `tag`: ID of the text 

- `newFont`: Font to apply 

---

### > `addLuaText(tag:String)`

#### Adds a text to the game 

- `tag`: ID of the text 

###### `DEPRECATED`: Use `add` instead 

---

### > `removeLuaText(tag:String, ?destroy:Bool)`

#### Removes a text from the game 

- `tag`: ID of the text 

- `destroy`: Defines whether the text should be destroyed 

###### `DEPRECATED`: Use `remove` instead 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)