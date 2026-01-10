import ale.ui.ALEUIUtils;

import core.config.DiscordRPC;

function onCreate()
{
    DiscordRPC.changePresence('In the Menus: ' + game.scriptName, null);

    Conductor.bpm = CoolVars.data.bpm;
}

function onUpdate(elapsed:Float)
{
    if (FlxG.keys.justPressed.R && CoolVars.data.developerMode && !ALEUIUtils.usingInputs)
        resetCustomState();
    
    if (FlxG.sound.music != null)
	    Conductor.songPosition = FlxG.sound.music.time;
}