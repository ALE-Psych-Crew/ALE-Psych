# LuaSave

### > `flushSaveData(name:String)`

#### Saves the save files 

- `name`: Save file ID. Can be `preferences`, `score`, `custom`, `controls` 

---

### > `getDataFromSave(name:String, variable:String):Dynamic`

#### Gets a value from a save file 

- `name`: Save file ID. Can be `preferences`, `score`, `custom`, `controls` 

- `variable`: Variable to look up 

#### `RETURN`: Variable value 

---

### > `setDataFromSave(name:String, values:Any)`

#### Sets a value in a save file 

- `name`: Save file ID. Can be `preferences`, `score`, `custom`, `controls` 

- `values`: Table of variables to set or modify 

---

### > `eraseSaveData(name:String)`

#### Deletes the data of a save file 

- `name`: Save file ID. Can be `preferences`, `score`, `custom`, `controls` 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)