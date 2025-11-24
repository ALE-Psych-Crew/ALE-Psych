// FILE: source/scripting/lua/callbacks/LuaDiscord.hx
package scripting.lua.callbacks;

import core.config.DiscordRPC; // use the updated wrapper
import scripting.lua.LuaPresetBase;

class LuaDiscord extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Changes the Discord RPC details.
         * @param details  Title line
         * @param state    Subtitle
         * @param largeImage  Large image key
         * @param smallImage  Small image key
         * @param usesTime    Show timer (elapsed or countdown)
         * @param endTime     If > 0 and usesTime=true: countdown duration (ms)
         */
        set('changeDiscordPresence', function(details:String, ?state:String, ?largeImage:String, ?smallImage:String, ?usesTime:Bool, ?endTime:Float)
        {
            DiscordRPC.changePresence(details, state, largeImage, smallImage, usesTime, endTime);
        });

        /**
         * Same as changeDiscordPresence but also sets hover texts for the images.
         * Useful to keep presence styling in one call.
         */
        set('changeDiscordPresenceWithTexts', function(details:String, ?state:String, ?largeImage:String, ?smallImage:String, ?largeText:String, ?smallText:String, ?usesTime:Bool, ?endTime:Float)
        {
            DiscordRPC.setImageTexts(largeText, smallText); // why: ensure tooltips match this update
            DiscordRPC.changePresence(details, state, largeImage, smallImage, usesTime, endTime);
        });

        /**
         * Set image hover texts (tooltips). Pass null/empty to clear.
         */
        set('setDiscordImageTexts', function(?largeText:String, ?smallText:String)
        {
            DiscordRPC.setImageTexts(largeText, smallText);
        });

        /**
         * Set up to two link buttons. Labels max 32 chars; URLs must start with https://
         * Example:
         *   setDiscordButtons("Download", "https://example.com", "Discord", "https://discord.gg/xyz")
         */
        set('setDiscordButtons', function(label1:String, url1:String, ?label2:String, ?url2:String)
        {
            var buttons:Array<Dynamic> = [];
            if (label1 != null && url1 != null) buttons.push({ label: label1, url: url1 });
            if (label2 != null && url2 != null) buttons.push({ label: label2, url: url2 });
            DiscordRPC.setButtons(buttons); // why: wrapper validates https and length, clips & logs
        });

        /**
         * Clear any previously set buttons from the presence.
         */
        set('clearDiscordButtons', function()
        {
            DiscordRPC.clearButtons();
        });

        /**
         * Changes the Discord RPC client ID (re-initializes).
         */
        set('changeDiscordClientID', (id:String) -> {
            DiscordRPC.shutdown();
            DiscordRPC.initialize(id);
        });
    }
}
