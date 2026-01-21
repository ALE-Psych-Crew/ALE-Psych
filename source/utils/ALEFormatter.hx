package utils;

import core.structures.*;

import core.enums.CharacterType;

import utils.cool.FileUtil;

using StringTools;

class ALEFormatter
{
    public static final CHART_FORMAT:String = 'ale-chart-v0.1';

    public static function getSong(name:String, difficulty:String):ALESong
    {
        final path:String = 'songs/' + name + '/charts/' + difficulty + '.json';

        final complexPath:String = FileUtil.searchComplexFile(path);

        var json:Dynamic = Paths.json(complexPath.substring(0, path.length - 5));

        var result:ALESong = null;

        if (json.format == CHART_FORMAT)
            result = cast json;

        if (result == null)
        {
            var psychSong:PsychSong = getPsychSong(json);

            result = {
                events: psychSong.events,
                strumLines: [
                    for (i in 0...3)
                    {
                        {
                            file: 'default',
                            position: {
                                x: 92,
                                y: 50
                            },
                            rightToLeft: i == 1,
                            visible: i != 0,
                            characters: [[psychSong.gfVersion, psychSong.player2, psychSong.player1][i]],
                            type: cast ['extra', 'opponent', 'player'][i]
                        }
                    }
                ],
                sections: [],
                speed: psychSong.speed,
                bpm: psychSong.bpm,
                format: CHART_FORMAT,
                stepsPerBeat: 4,
                beatsPerSection: 4,
                stage: psychSong.stage
            };

            for (section in psychSong.notes)
            {
                var curSection:ALESongSection = {
                    notes: [],
                    camera: [section.gfSection ? 0 : section.mustHitSection ? 2 : 1, 0],
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
                            [note[3] == 'GF Sing' || section.gfSection && note[1] < 4 ? 0 : (section.mustHitSection && note[1] < 4) || (!section.mustHitSection && note[1] > 3) ? 2 : 1, 0]
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
    
    public static final CHARACTER_FORMAT:String = 'ale-character-v0.1';

    public static function getCharacter(char:String, type:CharacterType):ALECharacter
    {
        var json:Dynamic = Paths.json('data/characters/' + char);

        if (json == null)
            return null;

        if (json.format == CHARACTER_FORMAT)
            return cast json;

        if (json.version == "1.0.0")
        {
            final funkinJson:FunkinCharacter = cast json;

            final result:ALECharacter = {
                type: switch (funkinJson.renderType)
                {
                    case 'animateatlas', 'multianimateatlas':
                        'map';

                    default:
                        'sheet';
                },
                animations: [],
                scale: 1,
                animationLength: 0.4,
                icon: funkinJson.healthIcon.id,
                position: funkinJson.offsets == null ? {x: 0, y: 0} : {
                    x: funkinJson.offsets[0],
                    y: funkinJson.offsets[1]
                },
                cameraPosition: funkinJson.cameraOffsets == null ? {x: 0, y: 0} : {
                    x: funkinJson.cameraOffsets[0],
                    y: funkinJson.cameraOffsets[1]
                },
                textures: [funkinJson.assetPath.contains(':') ? funkinJson.assetPath.split(':')[1] : funkinJson.assetPath],
                flipX: funkinJson.flipX,
                flipY: false,
                antialiasing: true,
                barColor: type == 'opponent' ? '0xFFFF0000' : '0xFF00FF00',
                death: 'bf-dead',
                sustainAnimation: false,
                danceModulo: char.contains('gf') && !char.contains('bf') ? 1 : 2,
                format: CHARACTER_FORMAT
            }

            for (anim in funkinJson.animations)
                result.animations.push({
                    name: anim.name,
                    prefix: anim.prefix,
                    framerate: 24,
                    loop: false,
                    indices: anim.indices,
                    offset: {
                        x: anim.offsets[0],
                        y: anim.offsets[1]
                    }
                });

            return result;
        }

        final psychJson:PsychCharacter = cast json;

        final result:ALECharacter = {
            type: 'sheet',
            animations: [],
            scale: psychJson.scale,
            animationLength: psychJson.sing_duration / 10,
            icon: psychJson.healthicon,
            position: {
                x: psychJson.position[0],
                y: psychJson.position[1]
            },
            cameraPosition: {
                x: psychJson.camera_position[0],
                y: psychJson.camera_position[1]
            },
            textures: [for (image in psychJson.image.split(',')) image.trim()],
            flipX: psychJson.flip_x,
            flipY: false,
            antialiasing: !psychJson.no_antialiasing,
            barColor: CoolUtil.intToHex(CoolUtil.colorFromArray(psychJson.healthbar_colors)),
            death: psychJson.deadVariant ?? 'bf-dead',
            sustainAnimation: true,
            danceModulo: char.contains('gf') && !char.contains('bf') ? 1 : 2,
            format: CHARACTER_FORMAT
        };

        if (type == 'player')
        {
            result.cameraPosition.x += 100;
            result.cameraPosition.y -= 100;
        } else {
            result.cameraPosition.x += 150;
            result.cameraPosition.y -= 100;
        }

        for (anim in psychJson.animations)
            result.animations.push({
                name: anim.anim,
                prefix: anim.name,
                framerate: anim.fps,
                loop: anim.loop,
                indices: anim.indices,
                offset: {
                    x: anim.offsets[0] / psychJson.scale,
                    y: anim.offsets[1] / psychJson.scale
                }
            });

        return result;
    }

    public static final STAGE_FORMAT:String = 'ale-stage-v0.1';

    public static function getStage(id:String):ALEStage
    {
        var json:Dynamic = Paths.json('data/stages/' + id);

        if (json.format == STAGE_FORMAT)
            return cast json;

        json.camera_speed ??= 1;
        json.defaultZoom ??= 1;
        json.isPixelStage ??= false;

        json.boyfriend ??= [0, 0];
        json.opponent ??= [0, 0];
        json.girlfriend ??= [0, 0];
        
        json.camera_boyfriend ??= [0, 0];
        json.camera_opponent ??= [0, 0];
        json.camera_girlfriend ??= [0, 0];

        return {
            speed: json.camera_speed,
            zoom: json.defaultZoom,
            hud: json.isPixelStage ? 'pixel' : 'default',
            characterOffset: {
                type: {
                    player: {
                        x: json.boyfriend[0],
                        y: json.boyfriend[1]
                    },
                    opponent: {
                        x: json.opponent[0],
                        y: json.opponent[1]
                    },
                    extra: {
                        x: json.girlfriend[0],
                        y: json.girlfriend[1]
                    }
                }
            },
            cameraOffset: {
                type: {
                    player: {
                        x: json.camera_boyfriend[0],
                        y: json.camera_boyfriend[1]
                    },
                    opponent: {
                        x: json.camera_opponent[0],
                        y: json.camera_opponent[1]
                    },
                    extra: {
                        x: json.camera_girlfriend[0],
                        y: json.camera_girlfriend[1]
                    }
                }
            }
        };
    }

    public static final STRUMLINE_FORMAT:String = 'ale-strumline-v0.1';

    public static function getStrumLine(strl:String):ALEStrumLine
    {
        final json:Dynamic = Paths.json('data/strumLines/' + strl);

        if (json != null && json.format == STRUMLINE_FORMAT)
            return cast json;

        return null;
    }

    public static final ICON_FORMAT:String = 'ale-icon-v0.1';

    public static function getIcon(id:String):ALEIcon
    {
        final json:Dynamic = Paths.json('data/icons/' + id, false, false);

        if (json != null && json.format == ICON_FORMAT)
            return cast json;

        return {
            texture: id,
            type: "frames",
            frames: 2,
            animations: [
                {
                    percent: 0,
                    name: 'lose',
                    indices: [1],
                    framerate: 0,
                    loop: false
                },
                {
                    percent: 20,
                    name: 'neutral',
                    indices: [0],
                    framerate: 0,
                    loop: false
                }
            ],
            scale: {
                x: 1,
                y: 1
            },
            bopScale: {
                x: 1.2,
                y: 1.2
            },
            offset: {
                x: 20,
                y: 0
            },
            bopModulo: 1,
            lerp: 0.33,
            flipX: false,
            flipY: false,
            antialiasing: !id.contains('pixel'),
            format: ICON_FORMAT
        };
    }

    public static final HUD_FORMAT:String = 'ale-hud-v0.1';

    public static function getHud(id:String):ALEHud
    {
        final json:Dynamic = Paths.json('data/huds/' + id);

        if (json.format == HUD_FORMAT)
            return cast json;

        return null;
    }
}