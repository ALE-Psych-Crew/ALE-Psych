// FILE: source/core/config/DiscordRPC.hx
package core.config;

#if DISCORD_ALLOWED
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#end

import sys.thread.Thread;

import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.ConstCharStar;

import lime.app.Application;

class DiscordRPC
{
    public static var initialized:Bool = false;

    private static var presence:#if DISCORD_ALLOWED DiscordRichPresence = new DiscordRichPresence() #else Dynamic = null #end;

    @:unreflective private static var thread:Thread;

    // HScript-friendly caches
    private static var _largeImageText:String = null;
    private static var _smallImageText:String = null;
    #if DISCORD_ALLOWED
    private static var _buttons:Array<{label:String, url:String}> = [];
    #end

    public static function initialize(id:String)
    {
        #if DISCORD_ALLOWED
        if (!ClientPrefs.data.discordRPC)
            return;

        var eventHandlers:DiscordEventHandlers = new DiscordEventHandlers();
        eventHandlers.ready = Function.fromStaticFunction(onReady);
        eventHandlers.disconnected = Function.fromStaticFunction(onDisconnected);
        eventHandlers.errored = Function.fromStaticFunction(onError);

        Discord.Initialize(id, RawPointer.addressOf(eventHandlers), false, null);

        if (thread == null)
        {
            thread = Thread.create(function():Void
                {
                    while (true)
                    {
                        #if DISCORD_DISABLE_IO_THREAD
                        Discord.UpdateConnection();
                        #end

                        Discord.RunCallbacks();

                        Sys.sleep(1);
                    }
                }
            );
        }

        Application.current.window.onClose.add(function()
            {
                if (initialized)
                    shutdown();
            }
        );

        initialized = true;
        #end
    }

    public static function shutdown()
    {
        #if DISCORD_ALLOWED
        initialized = false;

        // Reset presence + caches
        presence = new DiscordRichPresence();
        _largeImageText = null;
        _smallImageText = null;
        _buttons = [];

        Discord.Shutdown();
        #end
    }

    /**
     * Extended presence update (backward-compatible).
     * @param details/state/largeImage/smallImage/usesTime/endTime  // original fields
     * @param largeText  Hover text for large image
     * @param smallText  Hover text for small image
     * @param buttons    Array<Dynamic> of {label:String, url:String} (max 2)
     */
    public static function changePresence(
        details:String,
        ?state:String,
        ?largeImage:String,
        ?smallImage:String,
        ?usesTime:Bool = false,
        ?endTime:Float = 0,
        ?largeText:String = null,
        ?smallText:String = null,
        ?buttons:Array<Dynamic> = null)
    {
        #if DISCORD_ALLOWED
        // Update caches when provided
        if (largeText != null || smallText != null)
            setImageTexts(largeText, smallText);
        if (buttons != null)
            setButtons(buttons);

        var startTime:Float = 0;
        if (usesTime)
            startTime = Date.now().getTime();
        if (endTime > 0)
            endTime = startTime + endTime;

        presence.state = state;
        presence.details = details;
        presence.largeImageKey = largeImage;

        presence.largeImageText = (_largeImageText != null && _largeImageText.length > 0)
            ? _largeImageText
            : 'Engine Version: ' + CoolVars.engineVersion;

        presence.smallImageKey = smallImage;
        presence.smallImageText = (_smallImageText != null && _smallImageText.length > 0)
            ? _smallImageText
            : null;

        presence.startTimestamp = Std.int(startTime / 1000);
        presence.endTimestamp = Std.int(endTime / 1000);

        _applyButtons();

        updatePresence();
        #end
    }

    public static function updatePresence()
    {
        #if DISCORD_ALLOWED
        Discord.UpdatePresence(RawConstPointer.addressOf(presence));
        #end
    }

    private static function onReady(request:#if DISCORD_ALLOWED RawConstPointer<DiscordUser> #else Dynamic #end):Void
    {
        #if DISCORD_ALLOWED
        final user:String = request[0].username;
        final discriminator:Int = Std.parseInt(request[0].discriminator);
        dcTrace('Connected to User ' + (discriminator == 0 ? user : user + ' #' + discriminator));
        #end
    }

    private static function onDisconnected(errorCode:Int, message:ConstCharStar):Void
    {
        #if DISCORD_ALLOWED
        dcTrace('Disconnected (' + errorCode + ': ' + message + ')');
        #end
    }

    private static function onError(errorCode:Int, message:ConstCharStar):Void
    {
        #if DISCORD_ALLOWED
        dcTrace('Error ' + errorCode + ': ' + message);
        #end
    }

    #if DISCORD_ALLOWED
    private static function dcTrace(data:Dynamic)
    {
        debugTrace(data, CUSTOM, 'DISCORD', 0xFF5865F2);
    }
    #end

    // -------- Helpers --------

    public static inline function setImageTexts(?largeText:String, ?smallText:String):Void
    {
        if (largeText != null) _largeImageText = (largeText.length > 0) ? largeText : null;
        if (smallText != null) _smallImageText = (smallText.length > 0) ? smallText : null;
    }

    public static function setButtons(buttons:Array<Dynamic>):Void
    {
        #if DISCORD_ALLOWED
        _buttons = [];
        if (buttons == null) return;

        for (b in buttons)
        {
            if (b == null) continue;
            var label = _clipLabel(Std.string(Reflect.field(b, "label")));
            var url   = _sanitizeUrl(Std.string(Reflect.field(b, "url")));
            if (label != null && url != null)
                _buttons.push({ label: label, url: url });
            if (_buttons.length >= 2) break;
        }
        #end
    }

    public static function clearButtons():Void
    {
        #if DISCORD_ALLOWED
        _buttons = [];
        for (i in 0...2)
            presence.buttons[i] = null; // clear slot (don’t assign null to label/url)
        updatePresence();
        #end
    }

    #if DISCORD_ALLOWED
    static function _applyButtons():Void
    {
        for (i in 0...2)
        {
            if (i < _buttons.length)
            {
                var btn = new DiscordButton();
                btn.label = _buttons[i].label; // non-null
                btn.url   = _buttons[i].url;   // non-null
                presence.buttons[i] = btn;
            } else {
                presence.buttons[i] = null; // remove slot
            }
        }
    }

    static inline function _clipLabel(s:String):String
    {
        if (s == null) return null;
        var t = StringTools.trim(s);
        if (t.length == 0) return null;
        if (t.length > 32) t = t.substr(0, 32);
        return t;
    }

    static inline function _sanitizeUrl(u:String):String
    {
        if (u == null) return null;
        var t = StringTools.trim(u);
        if (!StringTools.startsWith(t, "https://")) {
            dcTrace('DiscordRPC: Button URL must start with https:// -> ' + t);
            return null;
        }
        return t;
    }
    #end
}
