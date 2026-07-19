package core;

import openfl.events.UncaughtErrorEvent;
import openfl.display.Sprite;
import openfl.ui.Mouse;
import openfl.Lib;

import scripting.haxe.HScriptConfig;

import core.debug.HotReloading;

import core.objects.GameObject;
import core.objects.SoundTray;

import core.objects.DebugTray;

import core.input.touch.TouchControls;

import core.plugins.*;

import funkin.config.Score;
import funkin.config.Save;

import api.DesktopAPI;

import flixel.input.keyboard.FlxKey;
import flixel.FlxGame;

import haxe.CallStack;

import utils.cool.ColorUtil;
import utils.cool.AppUtil;
import utils.Formatter;

import lime.system.System;

#if android
import extension.androidtools.os.Build.VERSION_CODES as AndroidVersionCode;
import extension.androidtools.os.Environment as AndroidEnvironment;
import extension.androidtools.os.Build.VERSION as AndroidVersion;
import extension.androidtools.Permissions as AndroidPermissions;
import extension.androidtools.Settings as AndroidSettings;

import openfl.utils.Assets;
import openfl.utils.ByteArray;

import sys.FileSystem;
import sys.io.File;

import haxe.Exception;
import haxe.io.Path;
#end

#if ALLOW_LINUX_API
import hxgamemode.GamemodeClient;
#end

@:unreflective
class Main extends Sprite
{
	public static var game(get, never):Game;
	static function get_game():Game
		return cast FlxG.game;

	#if dox
	static function main()
		new Main();
	#end

	public function new()
	{
		super();

		preConfig();
		
		addChild(new Game());

		postConfig();
	}

	static function preConfig()
	{
		#if android
		if (AndroidVersion.SDK_INT >= AndroidVersionCode.M)
		{
			if (!AndroidEnvironment.isExternalStorageManager())
			{
				AndroidSettings.requestSetting('MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
				
				while (!AndroidEnvironment.isExternalStorageManager()) {}
			}
		}

		final androidPath:String = AndroidEnvironment.getExternalStorageDirectory() + '/.' + Lib.application?.meta?.get('file');

		if (!FileSystem.exists(androidPath))
			FileSystem.createDirectory(androidPath);

		Sys.setCwd(Path.addTrailingSlash(androidPath));
		#end

		#if ALLOW_LINUX_API
		GamemodeClient.request_start();
		#end

		#if ALLOW_CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (error) -> {
			final title:String = 'ALE Psych ' + CoolVars.engineVersion + ' | Crash Handler';

			var printMessage:String = '';

			var consoleMessage:String = '\n' + title + '\n';

			for (stackItem in CallStack.exceptionStack(true))
			{
				switch (stackItem)
				{
					case FilePos(item, file, line, _):
						switch (item)
						{
							case Method(className, func):
								printMessage += className + '.' + func + ' - Line ' + line;
							default:
								printMessage += file + ':' + line;
						}

						printMessage += '\n';

						consoleMessage += file + '#' + line + '\n';
					default:
						Sys.println(stackItem);
				}
			}

			final errorMessage:String = '\n' + error.error;

			debugTrace(consoleMessage + errorMessage, PrintType.ERROR);
			
			Logs.popUp(title, printMessage + errorMessage, ERROR);

			destroy();

			System.exit(1);
		});
		#end
		
		Lib.application.window.onClose.add(() -> destroy());

		FlxG.stage.addEventListener('keyDown', (event) -> {
			if (event.altKey && event.keyCode == FlxKey.ENTER)
				event.stopImmediatePropagation();
		}, false, 1);
		
		DesktopAPI.setDPIAware();
	}

	static function postConfig()
	{
		function resetSpriteCache(sprite:Sprite)
		{
			@:privateAccess {
		        sprite.__cacheBitmap = null;
				sprite.__cacheBitmapData = null;
			}
		}
		
		FlxG.signals.gameResized.add((w, h) -> {
		     if (FlxG.cameras != null)
				for (cam in FlxG.cameras.list)
					if (cam != null && cam.filters != null)
						resetSpriteCache(cam.flashSprite);

			if (FlxG.game != null)
				resetSpriteCache(FlxG.game);
		});
	}

	@:allow(utils.cool.AppUtil)
	static function preResetConfig()
	{
		DesktopAPI.reset();

		#if desktop
		Mouse.cursor = ARROW;
		#end

		if (FlxG.state.subState != null)
			FlxG.state.subState.close();

		FlxTween.globalManager.clear();

		HotReloading.destroy();

		PluginsHandler.destroy();

		Conductor.destroy();

		Save.destroy();

		Score.destroy();

		if (game.soundTraySprite is GameObject)
			cast(game.soundTraySprite, GameObject)?.destroy();

		game.soundTraySprite = null;

		if (game.debugTray is GameObject)
			cast(game.debugTray, GameObject)?.destroy();

		game.debugTray = null;
	}

	public static var debugPrintPlugin:DebugPrintPlugin;

	public static var touchPlugin:TouchPlugin;

	public static var onlineVersion(default, null):String = '';

	@:unreflective static var allowMobileConfig:Bool = true;

	@:allow(core.states.MainState)
	static function postResetConfig()
	{
		if (allowMobileConfig)
		{
			#if mobile
			final textExtensions:Array<String> = ['ini', 'txt', 'xml', 'hx', 'lua', 'json', 'frag', 'vert'];

			final localFiles:Array<String> = Assets.list().filter(file -> !FileSystem.exists(file));

			for (file in localFiles)
			{
				final directory:String = Path.directory(file);

				try
				{
					if (Assets.exists(file))
					{
						if (!FileSystem.exists(directory))
							FileSystem.createDirectory(directory);

						if (textExtensions.contains(Path.extension(file)))
							File.saveContent(file, Assets.getText(file));
						else
							File.saveBytes(file, ['otf', 'ttf'].contains(Path.extension(file)) ? ByteArray.fromFile(file) : Assets.getBytes(file));
					} else {
						debugTrace(file, MISSING_FILE);
					}
				} catch (e:Exception) {}
			}
			#end

			allowMobileConfig = false;
		}

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		FlxG.sound.muteKeys = FlxG.sound.volumeDownKeys = FlxG.sound.volumeUpKeys = [];

		FlxG.autoPause = false;

		FlxG.mouse.unload();
		FlxG.mouse.visible = true;
		FlxG.mouse.useSystemCursor = true;

		Defines.init();
		
		Paths.clear(true, true);
		Paths.loadMod();
		Paths.init();
		
		CoolVars.init();

		HotReloading.init();

		Logs.init();
		
		PluginsHandler.init();

		HScriptConfig.init();

		Conductor.init();

		Formatter.init();

		ClientPrefs.init();

		Score.init();

		Save.init();

		TouchControls.init();

		if (CoolVars.meta.debugPrint && CoolVars.meta.developerMode)
			PluginsHandler.add(debugPrintPlugin = new DebugPrintPlugin());

		if (CoolVars.touch)
			PluginsHandler.add(touchPlugin = new TouchPlugin());

		game.addChild(game.soundTraySprite = new SoundTray());

		FlxG.stage.addChild(game.debugTray = new DebugTray());
		
		Lib.application.window.setIcon(Paths.library.getImage(CoolVars.meta.icon + '.png'));
		Lib.application.window.title = CoolVars.meta.title;
		Lib.application.window.resizable = true;

		DesktopAPI.setWindowTitle();
		
		final windowColor:FlxColor = ColorUtil.colorFromString(CoolVars.meta.color);

		DesktopAPI.setWindowBorderColor(windowColor.red, windowColor.green, windowColor.blue);

		AppUtil.resizeGame(CoolVars.meta.width, CoolVars.meta.height);
	}

	static function destroy()
	{
		DesktopAPI.reset();

		#if ALLOW_LINUX_API
		GamemodeClient.request_end();
		#end

		Save.destroy();
	}
}