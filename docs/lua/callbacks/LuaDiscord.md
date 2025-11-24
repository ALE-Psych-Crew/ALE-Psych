# LuaDiscord

### > changeDiscordPresence(details:String, ?state:String, ?largeImage:String, ?smallImage:String, ?usesTime:Bool, ?endTime:Float, ?largeText:String, ?smallText:String, ?label1:String, ?url1:String, ?label2:String, ?url2:String)

Changes the Discord RPC details (extended).

- details: Title of the RPC
- state: Subtitle of the RPC
- largeImage: Key for the large icon
- smallImage: Key for the small icon
- usesTime: If true, shows a timer
- endTime: If usesTime is true and endTime > 0, counts down from now + endTime (ms). If endTime == 0, shows elapsed timer.
- largeText: Optional hover text for the large image
- smallText: Optional hover text for the small image
- label1, url1: Optional first button (URL must start with https://)
- label2, url2: Optional second button (URL must start with https://)

Notes:
- Discord shows at most 2 buttons. Desktop client only.
- Button labels are clipped to 32 characters.
- If you control RPC during gameplay, disable auto updates:
  PlayState.instance.autoUpdateRPC = false

---

### > setDiscordImageTexts(?largeText:String, ?smallText:String)

Sets hover texts for large and small images.

- Pass null or empty to clear either value.
- Values persist until changed again.
- Also used by changeDiscordPresence if largeText or smallText are omitted.

---

### > setDiscordButtons(label1:String, url1:String, ?label2:String, ?url2:String)

Sets up to two link buttons.

- URLs must start with https://
- Labels over 32 characters are clipped
- Buttons persist across presence updates until you clear or replace them

---

### > clearDiscordButtons()

Removes any buttons from the current presence.

---

### > changeDiscordClientID(id:String)

Changes the Discord RPC client ID.

- id: New Discord Application (Client) ID
- Re-initializes the RPC layer using the provided ID
Here’s a clean, ASCII-only rewrite you can drop in as `docs/lua/LuaDiscord.md` (no fancy punctuation).

````md
# LuaDiscord

### > changeDiscordPresence(details:String, ?state:String, ?largeImage:String, ?smallImage:String, ?usesTime:Bool, ?endTime:Float, ?largeText:String, ?smallText:String, ?label1:String, ?url1:String, ?label2:String, ?url2:String)

Changes the Discord RPC details (extended).

- details: Title of the RPC
- state: Subtitle of the RPC
- largeImage: Key for the large icon
- smallImage: Key for the small icon
- usesTime: If true, shows a timer
- endTime: If usesTime is true and endTime > 0, counts down from now + endTime (ms). If endTime == 0, shows elapsed timer.
- largeText: Optional hover text for the large image
- smallText: Optional hover text for the small image
- label1, url1: Optional first button (URL must start with https://)
- label2, url2: Optional second button (URL must start with https://)

Notes:
- Discord shows at most 2 buttons. Desktop client only.
- Button labels are clipped to 32 characters.
- If you control RPC during gameplay, disable auto updates:
  PlayState.instance.autoUpdateRPC = false

---

### > setDiscordImageTexts(?largeText:String, ?smallText:String)

Sets hover texts for large and small images.

- Pass null or empty to clear either value.
- Values persist until changed again.
- Also used by changeDiscordPresence if largeText or smallText are omitted.

---

### > setDiscordButtons(label1:String, url1:String, ?label2:String, ?url2:String)

Sets up to two link buttons.

- URLs must start with https://
- Labels over 32 characters are clipped
- Buttons persist across presence updates until you clear or replace them

---

### > clearDiscordButtons()

Removes any buttons from the current presence.

---

### > changeDiscordClientID(id:String)

Changes the Discord RPC client ID.

- id: New Discord Application (Client) ID
- Re-initializes the RPC layer using the provided ID

---

##### Return to Home Page: [https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md](https://github.com/ALE-Psych-Crew/ALE-Psych/blob/main/docs/lua/Home.md)

```
```
