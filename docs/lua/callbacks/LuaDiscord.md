# LuaDiscord

### > `changeDiscordPresence()`

#### Extends Discord Rich Presence to optionally include image tooltips and up to two buttons. Backward-compatible: the legacy 6-argument form still works. 

- `details`:   Main presence line. 

- `state`:     Secondary line. (optional) 

- `largeImage`: Large image key. (optional) 

- `smallImage`: Small image key. (optional) 

- `usesTime`:  Whether to show time information. (optional) 

- `endTime`:   Timestamp used when usesTime is true. (optional) 

- `largeText`: Tooltip text for the large image. (optional) 

- `smallText`: Tooltip text for the small image. (optional) 

- `label1`:    Label of the first button. (requires url1) 

- `url1`:      URL opened by the first button. 

- `label2`:    Label of the second button. (optional; requires url2) 

- `url2`:      URL opened by the second button. (optional; requires label2) @note Discord supports at most two buttons. @note Null or omitted optional values are ignored by the RPC. 

---

### > `setDiscordImageTexts(?largeText:String, ?smallText:String)`

#### Sets the hover tooltip texts for the large and small presence images. 

- `largeText`: Tooltip for the large image. (null to clear/omit) 

- `smallText`: Tooltip for the small image. (null to clear/omit) @note Use together with image keys passed to changeDiscordPresence. 

---

### > `setDiscordButtons(label1:String, url1:String, ?label2:String, ?url2:String)`

#### Replaces the current Discord Rich Presence buttons with up to two new ones. 

- `label1`: Label of the first button. (requires url1) 

- `url1`:   URL opened by the first button. 

- `label2`: Label of the second button. (optional; requires url2) 

- `url2`:   URL opened by the second button. (optional; requires label2) @note Passing only one of label/url for a slot will not add that button. @note To remove all buttons, call clearDiscordButtons(). 

---

### > `clearDiscordButtons()`

#### Removes all buttons from the Discord Rich Presence card. 

---

### > `changeDiscordClientID(id:String, ->, {)`

#### Switches the Discord application (client ID) used by the RPC integration. Shuts down the current session and re-initializes with the provided ID. 

- `id`: The new Discord client/application ID. 



##### [Return to Home Page](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)