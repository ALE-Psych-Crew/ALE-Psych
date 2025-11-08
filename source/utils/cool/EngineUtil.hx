package utils.cool;

import core.Main;
import core.config.MainState;
import openfl.ui.Mouse;
import openfl.Lib;
import lime.graphics.Image;

class EngineUtil
{
	public static function resetEngine():Void
	{
		if (MainState.debugCounter != null)
		{
			MainState.debugCounter.destroy();

			FlxG.game.removeChild(MainState.debugCounter);
		}

		DiscordRPC.shutdown();

		CoolVars.skipTransIn = CoolVars.skipTransOut = true;

		if (ScriptState.instance != null)
			ScriptState.instance.destroyScripts();

		if (ScriptSubState.instance != null)
			ScriptSubState.instance.destroyScripts();

		if (FlxG.state.subState != null)
			FlxG.state.subState.close();

		for (key in CoolVars.globalVars.keys())
			CoolVars.globalVars.remove(key);

		#if (windows && cpp)
		cpp.WindowsAPI.setWindowBorderColor(255, 255, 255);
		#end

		FlxG.mouse.visible = true;

		FlxTween.globalManager.clear();

		FlxG.camera.bgColor = FlxColor.BLACK;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();

			FlxG.sound.music = null;
		}

		FlxG.resetGame();

		Paths.clearEngineCache(true);

		#if desktop
		Mouse.cursor = ARROW;
		#end
	}

	public static function reloadGameMetadata()
	{
		CoolVars.data = {
			developerMode: false,
			mobileDebug: false,
			scriptsHotReloading: false,

			verbose: false,

			initialState: 'TitleState',
			freeplayState: 'FreeplayState',
			storyMenuState: 'StoryMenuState',
			masterEditorState: 'MasterEditorState',
			mainMenuState: 'MainMenuState',

			loadDefaultWeeks: true,

			pauseSubState: 'PauseSubState',
			gameOverScreen: 'GameOverSubState',
			transition: 'FadeTransition',

			title: 'Friday Night Funkin\': ALE Psych',
			icon: 'appIcon',
			width: Main.game.width,
			height: Main.game.height,

			bpm: 102.0,

			discordID: '1309982575368077416',
		};

		try
		{
			if (Paths.exists('data.json'))
			{
				var json:Dynamic = Paths.json('data');

				for (field in Reflect.fields(json))
					if (Reflect.hasField(CoolVars.data, field))
						Reflect.setField(CoolVars.data, field, Reflect.field(json, field));
			}
		}
		catch (error:Dynamic)
		{
			debugTrace('Error While Loading Game Data (data.json): ' + error, ERROR);
		}

		if (Paths.exists(CoolVars.data.icon + '.png'))
			Lib.current.stage.window.setIcon(Image.fromFile(Paths.getPath(CoolVars.data.icon + '.png')));
		else
			Lib.current.stage.window.setIcon(Image.fromFile(Paths.getPath('images/appIcon.png')));

		FlxG.stage.window.title = CoolVars.data.title;

		resizeGame(CoolVars.data.width, CoolVars.data.height);
	}

	public static function resizeGame(width:Int, height:Int, ?centerWindow:Bool = true)
	{
		for (camera in FlxG.cameras.list)
		{
			camera.width = FlxG.width;
			camera.height = FlxG.height;
		}

		#if !mobile
		FlxG.fullscreen = false;
		FlxG.initialWidth = width;
		FlxG.initialHeight = height;
		FlxG.resizeGame(width, height);
		FlxG.resizeWindow(width, height);

		if (centerWindow)
		{
			Lib.application.window.x = Std.int((Lib.application.window.display.bounds.width - Lib.application.window.width) / 2);
			Lib.application.window.y = Std.int((Lib.application.window.display.bounds.height - Lib.application.window.height) / 2);
		}

		for (camera in FlxG.cameras.list)
		{
			camera.width = width;
			camera.height = height;
		}
		#end
	}
}
