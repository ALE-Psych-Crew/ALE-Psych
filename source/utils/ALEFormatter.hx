package utils;

import core.structures.ALESong;
import core.structures.ALESongSection;
import core.structures.ALEStrumLine;
import core.structures.PsychSong;
import core.structures.PsychSongSection;

import core.enums.CharacterType;

import utils.cool.FileUtil;

typedef ALECharacter = Dynamic;

class ALEFormatter
{
    public static final FORMAT:String = 'ale-format-v0.1';

    public static function getSong(name:String, difficulty:String):ALESong
    {
        final path:String = 'songs/' + name + '/charts/' + difficulty + '.json';

        final complexPath:String = FileUtil.searchComplexFile(path);

        var json:Dynamic = Paths.json(complexPath.substring(0, path.length - 5));

        var result:ALESong = null;

        if (json.format == FORMAT)
            result = cast json;

        if (result == null)
        {
            var psychSong:PsychSong = getPsychSong(json);
   
            result = {
                strumLines: [
                    for (i in 0...3)
                    {
                        {
                            file: 'default',
                            position: {
                                x: 92,
                                y: 50
                            },
                            rightToLeft: i == 0,
                            visible: i != 2,
                            characters: [[psychSong.player2, psychSong.player1, psychSong.gfVersion][i]],
                            type: [CharacterType.OPPONENT, CharacterType.PLAYER, CharacterType.EXTRA][i]
                        }
                    }
                ],
                sections: [],
                speed: psychSong.speed,
                bpm: psychSong.bpm,
                format: FORMAT,
                stepsPerBeat: 4,
                beatsPerSection: 4
            };

            for (section in psychSong.notes)
            {
                var curSection:ALESongSection = {
                    notes: [],
                    camera: [section.gfSection ? 2 : section.mustHitSection ? 1 : 0, 0],
                    bpm: section.changeBPM == true ? section.bpm : psychSong.bpm,
                    changeBPM: section.changeBPM ?? false
                };

                if (section.sectionNotes != null)
                {
                    for (note in section.sectionNotes)
                    {
                        var arrayNote:Array<Dynamic> = [
                            note[0],
                            note[1] % 4,
                            note[2],
                            note[3] == 'GF Sing' && section.gfSection && note[1] < 4 ? '' : (note[3] ?? ''),
                            [note[3] == 'GF Sing' || section.gfSection && note[1] < 4 ? 2 : (section.mustHitSection && note[1] < 4) || (!section.mustHitSection && note[1] > 3) ? 1 : 0, 0]
                        ];

                        curSection.notes.push(arrayNote);
                    }
                }

                result.sections.push(curSection);
            }
        }

        for (section in result.sections)
        {
            section.notes.sort((a, b) -> {
                return (a[0] < b[0]) ? 1 : (a[0] > b[0]) ? -1 : 0;
            });
        }

        return result;
    }

    public static function getPsychSong(json:Dynamic):PsychSong
    {
		if (json.format == 'psych_v1_convert' || json.format == 'psych_v1')
		{
			for (section in cast(json.notes, Array<Dynamic>))
				if (section.sectionNotes != null && section.sectionNotes.length > 0)
					for (note in cast(section.sectionNotes, Array<Dynamic>))
						if (!section.mustHitSection)
							note[1] = note[1] > 3 ? note[1] % 4 : note[1] += 4;
		} else {
			json = json.song;
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
				var sec:PsychSongSection = json.notes[secNum];

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
    
    public static function getCharacter(char:String):ALECharacter
    {
        return Paths.json('characters/' + char);
    }

    public static function getStrumLine(strl:String):ALEStrumLine
    {
        return cast Paths.json('strumLines/' + strl);
    }
}