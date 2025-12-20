package utils.cool;

import core.structures.PlayStateJSONData;

import utils.Song;
import utils.Section;

class PlayStateUtil
{
	public static function loadPlayStateJSON(songJson:Dynamic):SwagSong
	{
		var json = songJson;

		if (json.format == 'psych_v1_convert' || json.format == 'psych_v1')
		{
			for (section in cast(json.notes, Array<Dynamic>))
				if (section.sectionNotes != null && section.sectionNotes.length > 0)
					for (note in cast(section.sectionNotes, Array<Dynamic>))
						if (!section.mustHitSection)
							note[1] = note[1] > 3 ? note[1] % 4 : note[1] += 4;
		} else {
			json = songJson.song;
		}

		if (json.gfVersion == null)
		{
			json.gfVersion = json.player3;

			json.player3 = null;
		}

		if (json.events == null)
		{
			json.events = [];
			
			for (secNum in 0...json.notes.length)
			{
				var sec:SwagSection = json.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;

				while (i < len)
				{
					var note:Array<Dynamic> = notes[i];

					if (note[1] < 0)
					{
						json.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}

					else i++;
				}
			}
		}

		return cast json;
	}

	public static function loadPlayStateSong(name:String, difficulty:String):PlayStateJSONData
	{
		var jsonData:SwagSong = null;

		var json = FileUtil.searchComplexFile('songs/' + name + '/charts/' + difficulty + '.json');

		if (json == null)
			debugTrace(name + '/charts/' + difficulty + '.json', MISSING_FILE);
		else
			jsonData = loadPlayStateJSON(Paths.json(json.substring(0, json.length - 5)));

		return {
			route: FileUtil.searchComplexFile('songs/' + name),
			json: jsonData
		};
	}

	public static function loadSong(name:String, difficulty:String, goToPlayState:Bool = true)
	{
		var data:PlayStateJSONData = loadPlayStateSong(name, difficulty);

		PlayState.SONG = data.json;
		PlayState.difficulty = difficulty;
		PlayState.songRoute = data.route;

		if (goToPlayState && PlayState.SONG != null)
			StateUtil.switchState(new PlayState());

		debugTrace('Name: ' + name + ' - Difficulty: ' + difficulty, LOAD_SONG);
	}

	public static function loadWeek(weekName:String, names:Array<String>, difficulty:String, goToPlayState:Bool = true)
	{
		PlayState.playlist = names;
		PlayState.week = weekName;

		if (goToPlayState)
			loadSong(PlayState.playlist[0], difficulty);

		debugTrace('Name: ' + weekName + ' - Songs: ' + names + ' - Difficulty: ' + difficulty, LOAD_WEEK);
	}
	
    public static function exitSong()
    {
        PlayState.instance.vocals.volume = 0;

        PlayState.deathCounter = 0;
        PlayState.seenCutscene = false;

        PlayState.changedDifficulty = false;
        PlayState.chartingMode = false;

        FlxG.camera.followLerp = 0;
        
        PlayState.instance.paused = true;

        FlxG.sound.playMusic(Paths.music('freakyMenu'));

        StateUtil.switchState(new CustomState(PlayState.isStoryMode ? CoolVars.data.storyMenuState : CoolVars.data.freeplayState));
    }

    public static function resetSong()
    {
        PlayState.instance.paused = true;
        PlayState.instance.vocals.volume = 0;

        MusicBeatState.instance.shouldClearMemory = false;

        FlxG.sound.music.volume = 0;
        
        StateUtil.resetState();
    }
}