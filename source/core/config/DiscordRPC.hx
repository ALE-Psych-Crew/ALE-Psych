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

        Discord.Shutdown();
		#end
    }

    public static function changePresence(details:String, ?state:String, ?largeImage:String, ?smallImage:String, ?usesTime:Bool = false, ?endTime:Float = 0)
    {
		#if DISCORD_ALLOWED
        var startTime:Float = 0;

        if (usesTime)
            startTime = Date.now().getTime();

        if (endTime > 0)
            endTime = startTime + endTime;

        presence.state = state;
        presence.details = details;
        presence.largeImageKey = largeImage;
        presence.largeImageText = 'Engine Version: ' + CoolVars.engineVersion;
        presence.smallImageKey = smallImage;
        presence.startTimestamp = Std.int(startTime / 1000);
        presence.endTimestamp = Std.int(endTime / 1000);

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
}