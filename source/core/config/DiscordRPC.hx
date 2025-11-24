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
import StringTools; // needed by _clipLabel/_sanitizeUrl

class DiscordRPC
{
    public static var initialized:Bool = false;

    private static var presence:#if DISCORD_ALLOWED DiscordRichPresence = new DiscordRichPresence() #else Dynamic = null #end;

    @:unreflective private static var thread:Thread;

    // HScript-friendly caches
    private static var _largeImageText:String = null;
    private static var _smallImageText:String = null;

    // Typed button cache (avoid Dynamic -> const char* casts)
    #if DISCORD_ALLOWED
    private static var _btn1Label:String = null;
    private static var _btn1Url:String   = null;
    private static var _btn2Label:String = null;
    private static var _btn2Url:String   = null;
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
        _btn1Label = _btn1Url = _btn2Label = _btn2Url = null;

        Discord.Shutdown();
        #end
    }

    /**
     * Extended presence update (backward-compatible).
     * @param details/state/largeImage/smallImage/usesTime/endTime
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
        if (largeText != null || smallText != null)
            setImageTexts(largeText, smallText);
        if (buttons != null)
            setButtons(buttons);

        var startTime:Float = 0;
        if (usesTime) startTime = Date.now().getTime();
        if (endTime > 0) endTime = startTime + endTime;

        presence.state = state;
        presence.details = details;

        presence.largeImageKey  = largeImage;
        presence.largeImageText = (_largeImageText != null && _largeImageText.length > 0)
            ? _largeImageText
            : 'Engine Version: ' + CoolVars.engineVersion;

        presence.smallImageKey  = smallImage;
        presence.smallImageText = (_smallImageText != null && _smallImageText.length > 0)
            ? _smallImageText
            : null;

        presence.startTimestamp = Std.int(startTime / 1000);
        presence.endTimestamp   = Std.int(endTime   / 1000);

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

    // ---------- Helpers ----------

    /** Set hover texts shown on large/small image tooltips. */
    public static inline function setImageTexts(?largeText:String, ?smallText:String):Void
    {
        if (largeText != null) _largeImageText = (largeText.length > 0) ? largeText : null;
        if (smallText != null) _smallImageText = (smallText.length > 0) ? smallText : null;
    }

    /**
     * Set up to 2 link buttons. Accepts Array<Dynamic> with {label:String, url:String}.
     * Validates https:// and label length; stores typed strings.
     */
    public static function setButtons(buttons:Array<Dynamic>):Void
    {
        #if DISCORD_ALLOWED
        _btn1Label = _btn1Url = _btn2Label = _btn2Url = null;
        if (buttons == null) return;

        var stash:Array<{label:String, url:String}> = [];
        for (b in buttons)
        {
            if (b == null) continue;
            var label = _clipLabel(Std.string(Reflect.field(b, "label")));
            var url   = _sanitizeUrl(Std.string(Reflect.field(b, "url")));
            if (label != null && url != null) {
                stash.push({label: label, url: url});
                if (stash.length >= 2) break;
            }
        }

        if (stash.length >= 1) { _btn1Label = stash[0].label; _btn1Url = stash[0].url; }
        if (stash.length >= 2) { _btn2Label = stash[1].label; _btn2Url = stash[1].url; }
        #end
    }

    /** Clear any previously set buttons and push the clear to the client. */
    public static function clearButtons():Void
    {
        #if DISCORD_ALLOWED
        _btn1Label = _btn1Url = _btn2Label = _btn2Url = null;

        // Clear by assigning empty structs (not null)
        var empty0 = new DiscordButton(); // fields default to null pointers
        var empty1 = new DiscordButton();
        presence.buttons[0] = empty0;
        presence.buttons[1] = empty1;

        updatePresence();
        #end
    }

    // --------- Internal: apply/validate buttons ---------

    #if DISCORD_ALLOWED
    static function _applyButtons():Void
    {
        // Slot 0
        var btn0 = new DiscordButton();
        if (_btn1Label != null && _btn1Url != null) {
            btn0.label = _btn1Label; // typed String -> const char*
            btn0.url   = _btn1Url;
        }
        presence.buttons[0] = btn0;

        // Slot 1
        var btn1 = new DiscordButton();
        if (_btn2Label != null && _btn2Url != null) {
            btn1.label = _btn2Label;
            btn1.url   = _btn2Url;
        }
        presence.buttons[1] = btn1;
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
