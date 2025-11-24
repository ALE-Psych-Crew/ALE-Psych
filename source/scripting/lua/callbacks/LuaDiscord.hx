package scripting.lua.callbacks;

import core.config.DiscordRPC;
import scripting.lua.LuaPresetBase;

class LuaDiscord extends LuaPresetBase
{
    override public function new(lua:LuaScript)
    {
        super(lua);

        /**
         * Extends Discord Rich Presence to optionally include image tooltips and up to two buttons.
         * Backward-compatible: the legacy 6-argument form still works.
         *
         * @param details   Main presence line.
         * @param state     Secondary line. (optional)
         * @param largeImage Large image key. (optional)
         * @param smallImage Small image key. (optional)
         * @param usesTime  Whether to show time information. (optional)
         * @param endTime   Timestamp used when usesTime is true. (optional)
         * @param largeText Tooltip text for the large image. (optional)
         * @param smallText Tooltip text for the small image. (optional)
         * @param label1    Label of the first button. (requires url1)
         * @param url1      URL opened by the first button.
         * @param label2    Label of the second button. (optional; requires url2)
         * @param url2      URL opened by the second button. (optional; requires label2)
         *
         * @note Discord supports at most two buttons.
         * @note Null or omitted optional values are ignored by the RPC.
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

        /**
         * Sets the hover tooltip texts for the large and small presence images.
         *
         * @param largeText Tooltip for the large image. (null to clear/omit)
         * @param smallText Tooltip for the small image. (null to clear/omit)
         *
         * @note Use together with image keys passed to changeDiscordPresence.
         */
        set('setDiscordImageTexts', function(?largeText:String, ?smallText:String)
        {
            DiscordRPC.setImageTexts(largeText, smallText);
        });

        /**
         * Replaces the current Discord Rich Presence buttons with up to two new ones.
         *
         * @param label1 Label of the first button. (requires url1)
         * @param url1   URL opened by the first button.
         * @param label2 Label of the second button. (optional; requires url2)
         * @param url2   URL opened by the second button. (optional; requires label2)
         *
         * @note Passing only one of label/url for a slot will not add that button.
         * @note To remove all buttons, call clearDiscordButtons().
         */
        set('setDiscordButtons', function(label1:String, url1:String, ?label2:String, ?url2:String)
        {
            var buttons:Array<Dynamic> = [];
            if (label1 != null && url1 != null) buttons.push({ label: label1, url: url1 });
            if (label2 != null && url2 != null) buttons.push({ label: label2, url: url2 });
            DiscordRPC.setButtons(buttons);
        });

        /**
         * Removes all buttons from the Discord Rich Presence card.
         */
        set('clearDiscordButtons', function()
        {
            DiscordRPC.clearButtons();
        });

        /**
         * Switches the Discord application (client ID) used by the RPC integration.
         * Shuts down the current session and re-initializes with the provided ID.
         *
         * @param id The new Discord client/application ID.
         */
        set('changeDiscordClientID', (id:String) -> {
            DiscordRPC.shutdown();
            DiscordRPC.initialize(id);
        });
    }
}
