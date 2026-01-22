package core.config;

#if DISCORD_ALLOWED
import hxdiscord_rpc.Discord as DiscordLib;
import hxdiscord_rpc.Types;
#end

import sys.thread.Thread;

import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;
import cpp.ConstCharStar;

import lime.app.Application;

class Discord
{
	public static var initialized:Bool = false;

	private static var presence:#if DISCORD_ALLOWED DiscordRichPresence = new DiscordRichPresence() #else Dynamic = null #end;

	@:unreflective private static var thread:Thread;

	public static function check():Bool
	{
		if (ClientPrefs.data.discordRPC)
		{
			if (!initialized)
				Discord.init(CoolVars.data.discordID);
		} else {
			if (initialized)
				destroy();
		}

		return ClientPrefs.data.discordRPC;
	}

	public static function init(id:String)
	{
		#if DISCORD_ALLOWED
		if (!ClientPrefs.data.discordRPC)
		{
			if (initialized)
				destroy();

			return;
		}

		var eventHandlers:DiscordEventHandlers = new DiscordEventHandlers();
		eventHandlers.ready = Function.fromStaticFunction(onReady);
		eventHandlers.disconnected = Function.fromStaticFunction(onDisconnected);
		eventHandlers.errored = Function.fromStaticFunction(onError);

		DiscordLib.Initialize(id, RawPointer.addressOf(eventHandlers), false, null);

		if (thread == null)
		{
			thread = Thread.create(function():Void
				{
					while (true)
					{
						#if DISCORD_DISABLE_IO_THREAD
						DiscordLib.UpdateConnection();
						#end

						DiscordLib.RunCallbacks();

						Sys.sleep(1);
					}
				}
			);
		}

		Application.current.window.onClose.add(function()
			{
				if (initialized)
					destroy();
			}
		);

		initialized = true;
		#end
	}

	public static function destroy()
	{
		#if DISCORD_ALLOWED
		initialized = false;

		DiscordLib.Shutdown();
		#end
	}

	public static function changePresence(details:String, ?state:String, ?largeImage:String, ?smallImage:String, ?usesTime:Bool = false, ?endTime:Float = 0)
	{
		#if DISCORD_ALLOWED
		if (!check())
			return;

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
		if (!check())
			return;
		
		DiscordLib.UpdatePresence(RawConstPointer.addressOf(presence));
		#end
	}

	private static function onReady(request:#if DISCORD_ALLOWED RawConstPointer<DiscordUser> #else Dynamic #end):Void
	{
		#if DISCORD_ALLOWED
		final user:String = request[0].username;
		final discriminator:Int = Std.parseInt(request[0].discriminator);

		for (index => button in CoolVars.data.discordButtons)
		{
			if (index > 1)
				break;

			var btn:DiscordButton = new DiscordButton();

			btn.label = button.label ?? 'Button';
			btn.url = button.url ?? 'https://ale-psych-crew.github.io/ALE-Psych-Website';

			presence.buttons[index] = btn;
		}

		updatePresence();

		debugTrace('Connected to User ' + (discriminator == 0 ? user : user + ' #' + discriminator), DISCORD);
		#end
	}

	private static function onDisconnected(errorCode:Int, message:ConstCharStar):Void
	{
		#if DISCORD_ALLOWED
		debugTrace('Disconnected (' + errorCode + ': ' + message + ')', DISCORD);
		#end
	}

	private static function onError(errorCode:Int, message:ConstCharStar):Void
	{
		#if DISCORD_ALLOWED
		debugTrace('Error ' + errorCode + ': ' + message, DISCORD);
		#end
	}
}