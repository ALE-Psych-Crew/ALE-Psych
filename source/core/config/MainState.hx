package core.config;

import haxe.io.Path;

import flixel.FlxState;

import openfl.Lib;
import openfl.display.StageScaleMode;

import ale.ui.ALEUIUtils;

#if LUA_ALLOWED
import hxluajit.wrapper.LuaError;
#end

import core.plugins.ALEPluginsHandler;
import core.plugins.DebugPrintPlugin;

import funkin.debug.DebugCounter;

import cpp.WindowsAPI;

class MainState extends MusicBeatState
{
	public static var debugCounter:DebugCounter;
	
    #if mobile
	@:allow(core.backend.Mods)
    @:unreflective private static var showedModMenu:Bool = false;
    #end

	@:unreflective public static var debugPrintPlugin:DebugPrintPlugin;

	override function create()
	{
		Conductor.songPosition = 0;
		Conductor.offset = 0;
		Conductor.stepsPerBeat = 4;
		Conductor.beatsPerSection = 4;
		Conductor.bpm = 100;

		Paths.clearEngineCache(true);

		CoolVars.skipTransOut = true;

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];
	
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		super.create();

		utils.Rating.ratingWindows = {
			sickWindow: 50,
			goodWindow: 100,
			badWindow: 135
		};

		core.backend.Mods.init();

    	ALEUIUtils.OBJECT_SIZE = 25;
    	ALEUIUtils.FONT = Paths.font('jetbrains.ttf');
    	ALEUIUtils.COLOR = FlxColor.fromRGB(50, 70, 100);
      	ALEUIUtils.OUTLINE_COLOR = FlxColor.WHITE;

		#if LUA_ALLOWED
		LuaError.errorHandler = (e:String) -> {
			debugTrace(e, ERROR);
		};
		
        Sys.putEnv('LUA_PATH', Sys.getCwd() + '/' + Paths.modFolder() + '/scripts/modules/?.lua;');
		#end

		CoolUtil.reloadGameMetadata();
		
        WindowsAPI.setWindowTitle();
		
		#if WINDOWS_API
		WindowsAPI.setWindowBorderColor(CoolVars.data.windowColor[0], CoolVars.data.windowColor[1], CoolVars.data.windowColor[2]);
		#end

		ALEPluginsHandler.initialize();

		debugPrintPlugin = null;

		if (CoolVars.data.allowDebugPrint && CoolVars.data.developerMode)
			ALEPluginsHandler.add(debugPrintPlugin = new DebugPrintPlugin());

        DiscordRPC.initialize(CoolVars.data.discordID);
    
        if (CoolUtil.save != null)
			CoolUtil.save.destroy();

        CoolUtil.save = new utils.ALESave();

		CoolUtil.save.load();

		FlxG.mouse.useSystemCursor = true;
		
		#if HSCRIPT_ALLOWED
		scripting.haxe.HScriptConfig.config();
		#end
		
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;

        #if mobile
        if (showedModMenu || Mods.UNIQUE_MOD != null)
        {
        	CoolUtil.switchState(new CustomState(CoolVars.data.initialState), true, true);
        } else {
            MainState.showedModMenu = true;

            CoolUtil.openSubState(new funkin.substates.ModsMenuSubState());
		}
        #else
        CoolUtil.switchState(new CustomState(CoolVars.data.initialState), true, true);
        #end
		
		openalFix();
		
		debugCounter = new DebugCounter(Paths.json('debug').fields == null ? [] : cast Paths.json('debug').fields);
		
		FlxG.game.addChild(debugCounter);
	}

    function openalFix()
    {
		#if desktop
		var origin:String = #if hl Sys.getCwd() #else Sys.programPath() #end;

		var configPath:String = Path.directory(Path.withoutExtension(origin));

		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = Path.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#else
		configPath += "/plugins/alsoft.conf";
		#end

		Sys.putEnv("ALSOFT_CONF", configPath);
		#end	
    }
}