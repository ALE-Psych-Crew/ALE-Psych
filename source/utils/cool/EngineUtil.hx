package utils.cool;

import core.config.MainState;

import openfl.Lib;

import lime.graphics.Image;

class EngineUtil
{
	public static function resizeGame(width:Int, height:Int, ?centerWindow:Bool = true, ?scale:Float = 1)
	{
		for (camera in FlxG.cameras.list)
		{
			camera.width = FlxG.width;
			camera.height = FlxG.height;
		}

		Reflect.setProperty(FlxG, 'initialWidth', width);
		Reflect.setProperty(FlxG, 'initialHeight', height);

		FlxG.resizeGame(width, height);
		FlxG.resizeWindow(Math.floor(width / scale), Math.floor(height / scale));

		#if !mobile
		FlxG.fullscreen = false;

		if (centerWindow)
		{
			Lib.application.window.x = Std.int((Lib.application.window.display.bounds.width - Lib.application.window.width) / 2);
			Lib.application.window.y = Std.int((Lib.application.window.display.bounds.height - Lib.application.window.height) / 2);
		}
		#end

		for (camera in FlxG.cameras.list)
		{
			camera.width = width;
			camera.height = height;
		}
	}

	public static function loadMetadata()
	{
		CoolVars.data = {
			developerMode: false,
			mobileDebug: false,
			scriptsHotReloading: false,

			verbose: false,
			allowDebugPrint: true,

			initialState: 'TitleState',
			freeplayState: 'FreeplayState',
			storyMenuState: 'StoryMenuState',
			masterEditorState: 'MasterEditorState',
			mainMenuState: 'MainMenuState',
			optionsState: 'OptionsState',

			loadDefaultWeeks: true,

			pauseSubState: 'PauseSubState',
			gameOverScreen: 'GameOverSubState',
			transition: 'FadeTransition',

			title: 'Friday Night Funkin\': ALE Psych',
			icon: 'appIcon',
			width: 1280,
			height: 720,

            paths: [],

            dependencies: [],

			windowColor: [33, 33, 33],

			bpm: 102.0,

			discordID: '1309982575368077416',

			discordButtons: [
				{
					label: 'ALE Psych Website',
					url: 'https://ale-psych-crew.github.io/ALE-Psych-Website/'
				}
			],

			modID: null
		};
	}
}
