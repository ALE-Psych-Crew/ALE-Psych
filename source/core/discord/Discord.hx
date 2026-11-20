package core.discord;

#if ALLOW_DISCORD
import hxdiscord_rpc.Discord as DiscordRPC;
import hxdiscord_rpc.Types;

import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.Function;
#end

import core.structures.DiscordPresenceData;

import sys.thread.Thread;

class Discord
{
    @:unreflective
    static final DEFAULT_ID:String = '1309982575368077416';

    static var presence(default, null):Presence;

    @:unreflective
    static var initialized(default, null):Bool = false;

    @:unreflective
    static var _thread:Thread;

    public static var id(default, set):String;
    static function set_id(val:String)
    {
        val ??= DEFAULT_ID;

        if (id == val)
            return id;

        id = val;

        if (initialized)
        {
            destroy();
            init();
            update();
        }

        return id;
    }

    @:unreflective
    static var _continue(default, null):Bool = false;

    public static var user(default, null):Null<String>;
    public static var discriminator(default, null):Null<String>;

    public static function init()
    {
        if (initialized)
            return;

        _continue = false;

        user = null;
        discriminator = null;

        presence = new Presence();

        final newId:String = (CoolVars.meta != null && CoolVars.meta.discord != null ? CoolVars.meta.discord.id : null) ?? DEFAULT_ID;

        #if ALLOW_DISCORD
        final handlers:DiscordEventHandlers = new DiscordEventHandlers();
        handlers.ready = Function.fromStaticFunction(onReady);
        handlers.disconnected = Function.fromStaticFunction(onDisconnected);
        handlers.errored = Function.fromStaticFunction(onError);

        DiscordRPC.Initialize(newId, RawPointer.addressOf(handlers), false, null);
        #else
        onReady(null);
        #end

        while (!_continue) {}

        if (CoolVars.meta != null && CoolVars.meta.discord != null)
        {
            if (CoolVars.meta.discord.firstButton != null)
                presence.firstButton = new Button(CoolVars.meta.discord.firstButton.label, CoolVars.meta.discord.firstButton.url);

            if (CoolVars.meta.discord.secondButton != null)
                presence.secondButton = new Button(CoolVars.meta.discord.secondButton.label, CoolVars.meta.discord.secondButton.url);
        }

        _thread = Thread.create(() -> {
            while (true)
            {
                #if ALLOW_DISCORD
                if (initialized)
                {
                    #if DISCORD_DISABLE_IO_THREAD
                    DiscordRPC.UpdateConnection();
                    #end

                    DiscordRPC.RunCallbacks();
                }
                #end

                Sys.sleep(0.5);
            }
        });

        initialized = true;

        @:bypassAccessor id = newId;
    }

    public static function destroy()
        shutdown();


    static function onReady(request: #if ALLOW_DISCORD RawConstPointer<DiscordUser> #else Dynamic #end)
    {
        #if ALLOW_DISCORD
        user = cast request[0].username;
        discriminator = cast request[0].discriminator;
        #end

        update();

        _continue = true;
    }

    static function onDisconnected(_, _)
        _continue = true;

    static function onError(_, _)
        _continue = true;

	static function update()
    {
        #if ALLOW_DISCORD
        DiscordRPC.UpdatePresence(RawConstPointer.addressOf(presence._presence));
        #end
    }

    static function shutdown()
    {
        if (!initialized)
            return;

        _thread = null;

        #if ALLOW_DISCORD
        DiscordRPC.ClearPresence();
        DiscordRPC.Shutdown();
        #end

        initialized = false;
    }

    public static function setPresence(data:DiscordPresenceData):DiscordPresenceData
    {
        if (data.firstButton != null)
            presence.firstButton = new Button(data.firstButton.label, data.firstButton.url);

        if (data.secondButton != null)
            presence.secondButton = new Button(data.secondButton.label, data.secondButton.url);

        presence.state = data.state;
        presence.details = data.details;

        presence.largeImageKey = data.largeImageKey;
        presence.largeImageText = data.largeImageText;

        presence.smallImageKey = data.smallImageKey;
        presence.smallImageText = data.smallImageText;

        presence.startTimestamp = data.startTimestamp;
        presence.endTimestamp = data.endTimestamp;

        presence.instance = data.instance;

        presence.joinSecret = data.joinSecret;
        presence.matchSecret = data.matchSecret;
        presence.spectateSecret = data.spectateSecret;

        presence.partyId = data.partyId;
        presence.partySize = data.partySize;
        presence.partyMax = data.partyMax;
        presence.partyPrivacy = data.partyPrivacy;

        presence.type = data.type;

        update();

        return data;
    }
}