package core;

import flixel.util.typeLimit.NextState.InitialState;
import flixel.FlxGame;

import funkin.substates.ModsMenuSubState;

import core.states.MainState;

import core.audio.SoundTray;

import api.DesktopAPI;

class Game extends FlxGame
{
	public var soundTraySprite:SoundTray;

	override public function new()
		super(1280, 720, MainState, 120, 120, true, false);
	
	@:unreflective
	var visibleConsole:Bool = false;

	override public function update()
	{
		DesktopAPI.setWindowTitle();

		super.update();

		if (Controls.CONTROL && Controls.SHIFT)
		{
			if (CoolVars.data.developerMode)
			{
				if (Controls.RESET_GAME)
					CoolUtil.resetGame();
			}

			if (Defines.CONTENT_MOD == null && Controls.SWITCH_MOD)
			{
				if (FlxG.state.subState != null)
					FlxG.state.subState.close();

				CoolUtil.openSubState(new ModsMenuSubState());
			}
		}

		#if ALLOW_WINDOWS_API
		if (FlxG.keys.justPressed.F2)
		{
			if (!visibleConsole)
				DesktopAPI.showConsole();

			visibleConsole = true;
		}
		#end

		if (soundTraySprite != null)
			soundTraySprite.update(FlxG.elapsed);
	}
}