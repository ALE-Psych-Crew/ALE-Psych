// FILE: source/scripting/lua/callbacks/LuaDiscord.hx
package scripting.lua.callbacks;

import core.config.DiscordRPC;
import scripting.lua.LuaPresetBase;

class LuaDiscord extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Extended changeDiscordPresence with optional image texts and two buttons.
         * Backward-compatible: old 6-arg calls still work.
         *
         * @param details, state, largeImage, smallImage, usesTime, endTime
         * @param largeText, smallText
         * @param label1, url1, label2, url2  (two buttons max)
         */
        set('changeDiscordPresence', function(
            details:String, ?state:String, ?largeImage:String, ?smallImage:String,
            ?usesTime:Bool, ?endTime:Float,
            ?largeText:String, ?smallText:String,
            ?label1:String, ?url1:String, ?label2:String, ?url2:String)
        {
            var buttons:Array<Dynamic> = [];
            if (label1 != null && url1 != null) buttons.push({ label: label1, url: url1 });
            if (label2 != null && url2 != null) buttons.push({ label: label2, url: url2 });

            DiscordRPC.changePresence(
                details, state, largeImage, smallImage,
                usesTime, endTime,
                largeText, smallText, buttons
            );
        });

        // Optional: keep helpers for convenience
        set('setDiscordImageTexts', function(?largeText:String, ?smallText:String)
        {
            DiscordRPC.setImageTexts(largeText, smallText);
        });

        set('setDiscordButtons', function(label1:String, url1:String, ?label2:String, ?url2:String)
        {
            var buttons:Array<Dynamic> = [];
            if (label1 != null && url1 != null) buttons.push({ label: label1, url: url1 });
            if (label2 != null && url2 != null) buttons.push({ label: label2, url: url2 });
            DiscordRPC.setButtons(buttons);
        });

        set('clearDiscordButtons', function()
        {
            DiscordRPC.clearButtons();
        });

        set('changeDiscordClientID', (id:String) -> {
            DiscordRPC.shutdown();
            DiscordRPC.initialize(id);
        });
    }
}
