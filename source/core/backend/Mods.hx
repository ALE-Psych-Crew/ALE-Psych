package core.backend;

import core.config.MainState;

import flixel.util.FlxSave;

import utils.cool.EngineUtil;
import utils.ALEAssetLibrary;

import openfl.Assets as OpenFLAssets;
import openfl.display.BitmapData;
import openfl.utils.AssetLibrary;
import openfl.Lib;

import sys.FileSystem;
import sys.io.File;

import lime.graphics.Image;

class Mods
{
    @:unreflective public static var UNIQUE_MOD:Null<String> = null;

	public static var folder:String = UNIQUE_MOD ?? '';

    public static function init()
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
			width: Main.game.width,
			height: Main.game.height,

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

        if (FileSystem.exists('mods/UNIQUE_MOD.txt'))
        {
            #if mobile
            core.config.MainState.showedModMenu = true;
            #end

            UNIQUE_MOD = folder = File.getContent('mods/UNIQUE_MOD.txt').split('\n')[0].trim();
        } else {
            UNIQUE_MOD = null;

            var save:FlxSave = new FlxSave();

            save.bind('ALEEngineData', utils.cool.FileUtil.getSavePath(false));

            if (save != null)
                folder = save.data.currentMod;

            if (!FileSystem.exists(Paths.modFolder()))
                folder = '';
        }

		final modFolder:Bool = Mods.folder != null && Mods.folder.trim() != '';

		final folderPath:String = modFolder ? ('mods/' + Mods.folder.trim()) : 'assets';

		try
		{
			if (FileSystem.exists(folderPath + '/data.json'))
			{
				var json:Dynamic = Json.parse(File.getContent(folderPath + '/data.json'));

				for (field in Reflect.fields(json))
					if (Reflect.hasField(CoolVars.data, field))
						Reflect.setField(CoolVars.data, field, Reflect.field(json, field));
			}
		} catch (error:Dynamic) {
			debugTrace('Error While Loading Game Data: ' + error, ERROR);
		}

		FlxG.stage.window.title = CoolVars.data.title;

		EngineUtil.resizeGame(CoolVars.data.width, CoolVars.data.height);

        var libraryRoots:Array<String> = [];

        #if MODS_ALLOWED
        if (modFolder)
        {
            for (path in CoolVars.data.paths)
                libraryRoots.push(folderPath + '/' + path.trim());
			
            libraryRoots.push(folderPath);
        }
        #end

		final libPath:String = FileSystem.exists(folderPath + '/.alelib') ? (folderPath + '/.alelib') : '.alelib';

        for (path in CoolVars.data.dependencies)
		{
			final finalPath:String = libPath + '/' + path.trim();

			if (FileSystem.exists(finalPath))
			{
            	libraryRoots.push(finalPath);
			} else {
				MainState.missingLibraries ??= [];

				MainState.missingLibraries.push(path.trim());
			}
		}

        libraryRoots.push('assets');

        OpenFLAssets.registerLibrary('default', new ALEAssetLibrary(libraryRoots));

		if (Paths.exists(CoolVars.data.icon + '.png'))
			Lib.current.stage.window.setIcon(Image.fromFile(Paths.getPath(CoolVars.data.icon + '.png')));
		else
			Lib.current.stage.window.setIcon(Image.fromFile(Paths.getPath('images/appIcon.png')));
    }
}