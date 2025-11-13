# LuaPaths

### > `clearEngineCache(?clearPermanent:Bool)`

#### Clears cached assets used by the engine. This removes images, spritesheets, audio files and other stored resources so the engine can reload them when needed. Useful when switching mods, unloading large files, or preventing long‑session memory buildup. 

- `clearPermanent`: If true, also clears permanent cache entries,        which are normally preserved across state changes. 

---

### > `precacheImage(file:String, ?permanent:Bool, ?missingPrint:Bool)`

#### Preloads an image into memory. Forces the engine to load an image ahead of time so it does not cause a stall when first drawn. Helpful for characters, stages, HUD graphics and scripted UI elements. 

- `file`: Path of the image (without file extension). 

- `permanent`: Whether the image should stay permanently cached. 

- `missingPrint`: Whether to print a warning if the file is missing. 

---

### > `precacheSound(file:String, ?permanent:Bool, ?missingPrint:Bool)`

#### 

---

### > `precacheMusic(file:String, ?permanent:Bool, ?missingPrint:Bool)`

#### 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)