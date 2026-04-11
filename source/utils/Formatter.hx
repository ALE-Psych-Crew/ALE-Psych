package utils;

import core.enums.FormatterType;
import core.enums.CharacterType;

import utils.cool.StringUtil;
import utils.cool.ColorUtil;
import utils.cool.FileUtil;

import core.structures.*;

class Formatter
{
    public static var config:Map<String, FormatterConfig> = new Map();

    static function removePrefix(prefix:String, base:String):String
    {
        if (base.startsWith(prefix + '/'))
            return base.substring(prefix.length + 1);
        
        return base;
    }

    static function removeArrayPrefix(prefix:String, base:Array<String>):Array<String>
        return [for (obj in base) removePrefix(prefix, obj)];

    public static function init()
    {
        config = [
            CHARACTER => {
                path: 'characters',
                format: FormatterType.CHARACTER.format(),
                resolvers: [
                    function (rawJson:Dynamic, id:String, ?args:Array<Dynamic>)
                    {
                        final psychJson:PsychCharacter = cast rawJson;

                        final result:JsonCharacter = {
                            type: Paths.isDirectory('images/characters/' + psychJson.image.split(',')[0].trim()) ? 'map' : 'sheet',
                            images: [for (image in psychJson.image.split(',')) removePrefix('characters', image.trim())],
                            animations: [],
                            animationLength: psychJson.sing_duration / 10,
                            icon: psychJson.healthicon,
                            cameraOffset: {
                                x: psychJson.camera_position[0],
                                y: psychJson.camera_position[1]
                            },
                            sustainAnimation: true,
                            death: 'bf-dead',
                            properties: {
                                x: psychJson.position[0],
                                y: psychJson.position[1],
                                scale: {
                                    x: psychJson.scale,
                                    y: psychJson.scale
                                },
                                flipX: psychJson.flip_x,
                                antialiasing: !psychJson.no_antialiasing
                            },
                            format: FormatterType.CHARACTER.format(),
                            bopAnimations: ['idle', null],
                            barColor: StringUtil.intToHex(ColorUtil.colorFromArray(psychJson.healthbar_colors))
                        };

                        if (args[0] == CharacterType.PLAYER)
                        {
                            result.cameraOffset.x += 100;
                            result.cameraOffset.y -= 100;
                        } else {
                            result.cameraOffset.x += 150;
                            result.cameraOffset.y -= 100;
                        }

                        final animList:Array<String> = [];

                        for (anim in psychJson.animations)
                        {
                            result.animations.push({
                                name: anim.anim,
                                prefix: anim.name,
                                frameRate: anim.fps,
                                loop: anim.loop,
                                indices: anim.indices,
                                offset: {
                                    x: anim.offsets[0] / psychJson.scale,
                                    y: anim.offsets[1] / psychJson.scale
                                }
                            });

                            animList.push(anim.anim);   
                        }

                        if (animList.contains('danceLeft') && animList.contains('danceRight'))
                            result.bopAnimations = ['danceLeft', 'danceRight'];

                        return result;
                    }
                ],
                fileCheck: (json) -> {
                    for (image in cast(json.images, Array<Dynamic>))
                        if (Paths.exists('images/' + config[CHARACTER].path + '/' + image + '.png'))
                            return true;

                    return false;
                },
                example: {
                    images: ['bf'],
                    type: 'sheet',
                    animations: [],
                    properties: {
                        x: 0,
                        y: 0,
                        flipX: false
                    },
                    sustainAnimation: false,
                    animationLength: 0.4,
                    icon: 'bf',
                    cameraOffset: {
                        x: 0,
                        y: 0
                    },
                    death: 'bf-dead',
                    barColor: '0xFF00FF00',
                    format: FormatterType.CHARACTER.format()
                }
            },
            STAGE => {
                path: 'stages',
                format: FormatterType.STAGE.format(),
                resolvers: [
                    function (rawJson:Dynamic, id:String, ?args:Array<Dynamic>)
                    {
                        final psychJson:PsychStage = cast rawJson;

                        psychJson.boyfriend ??= [0, 0];
                        psychJson.opponent ??= [0, 0];
                        psychJson.girlfriend ??= [0, 0];
                        
                        psychJson.camera_boyfriend ??= [0, 0];
                        psychJson.camera_opponent ??= [0, 0];
                        psychJson.camera_girlfriend ??= [0, 0];

                        return {
                            speed: psychJson.camera_speed,
                            zoom: psychJson.defaultZoom,
                            hud: psychJson.isPixelStage ? 'pixel' : 'default',
                            charactersOffset: {
                                type: {
                                    player: {
                                        x: psychJson.boyfriend[0],
                                        y: psychJson.boyfriend[1]
                                    },
                                    opponent: {
                                        x: psychJson.opponent[0],
                                        y: psychJson.opponent[1]
                                    },
                                    extra: {
                                        x: psychJson.girlfriend[0],
                                        y: psychJson.girlfriend[1]
                                    }
                                }
                            },
                            charactersCamera: {
                                type: {
                                    player: {
                                        x: psychJson.camera_boyfriend[0],
                                        y: psychJson.camera_boyfriend[1]
                                    },
                                    opponent: {
                                        x: psychJson.camera_opponent[0],
                                        y: psychJson.camera_opponent[1]
                                    },
                                    extra: {
                                        x: psychJson.camera_girlfriend[0],
                                        y: psychJson.camera_girlfriend[1]
                                    }
                                }
                            },
                            format: FormatterType.STAGE.format()
                        }
                    }
                ],
                fileCheck: (json) -> {
                    return Paths.exists('data/' + 'huds' /** PROVISIONAL FIX **/ + '/' + json.hud + '.json');
                },
                example: {
                    zoom: 0.9,
                    speed: 1,
                    hud: 'default',
                    format: FormatterType.STAGE.format()
                }
            },
            STRUMLINE => {
                path: 'strumLines',
                format: FormatterType.STRUMLINE.format(),
                fileCheck: (json) -> {
                    for (obj in [[json.strums, 'strums'], [json.notes, 'notes'], [json.splashes, 'splashes']])
                        if (!Paths.exists('data/' + obj[1] + '/' + obj[0] + '.json'))
                            return false;

                    return true;
                },
                example: {
                    spacing: 112,
                    strums: 'default',
                    notes: 'default',
                    splashes: 'default',
                    config: [
                        {
                            idle: 'leftIdle',
                            hit: 'leftHit',
                            press: 'leftPress',
                            keyBind: {
                                group: 'notes',
                                id: 'left'
                            },
                            note: 'leftNote',
                            sustain: 'sustain',
                            end: 'end',
                            splash: [
                                'splash1',
                                'splash2'
                            ],
                            sing: 'singLEFT',
                            miss: 'singLEFTmiss',
                            shader: [
                                '0xFFC24B99',
                                '0xFFFFFFFF',
                                '0xFF3C1F56'
                            ]
                        },
                        {
                            idle: 'downIdle',
                            hit: 'downHit',
                            press: 'downPress',
                            keyBind: {
                                group: 'notes',
                                id: 'down'
                            },
                            note: 'downNote',
                            sustain: 'sustain',
                            end: 'end',
                            splash: [
                                'splash1',
                                'splash2'
                            ],
                            sing: 'singDOWN',
                            miss: 'singDOWNmiss',
                            shader: [
                                '0xFF00FFFF',
                                '0xFFFFFFFF',
                                '0xFF1542B7'
                            ]
                        },
                        {
                            idle: 'upIdle',
                            hit: 'upHit',
                            press: 'upPress',
                            keyBind: {
                                group: 'notes',
                                id: 'up'
                            },
                            note: 'upNote',
                            sustain: 'sustain',
                            end: 'end',
                            splash: [
                                'splash1',
                                'splash2'
                            ],
                            sing: 'singUP',
                            miss: 'singUPmiss',
                            shader: [
                                '0xFF00FF00',
                                '0xFFFFFFFF',
                                '0xFF003300'
                            ]
                        },
                        {
                            idle: 'rightIdle',
                            hit: 'rightHit',
                            press: 'rightPress',
                            keyBind: {
                                group: 'notes',
                                id: 'right'
                            },
                            note: 'rightNote',
                            sustain: 'sustain',
                            end: 'end',
                            splash: [
                                'splash1',
                                'splash2'
                            ],
                            sing: 'singRIGHT',
                            miss: 'singRIGHTmiss',
                            shader: [
                                '0xFFF9393F',
                                '0xFFFFFFFF',
                                '0xFF651038'
                            ]
                        }
                    ],
                    format: FormatterType.STRUMLINE.format()
                }
            },
            ICON => {
                path: 'icons',
                format: FormatterType.ICON.format(),
                exampleModifier: (example, id, ?args) -> {
                    example.images = [id];

                    return example;
                },
                example: {
                    images: ['bf'],
                    type: 'frames',
                    frames: 2,
                    animations: [
                        {
                            name: 'lose',
                            indices: [1],
                            frameRate: 0,
                            loop: false,
                            offset: {
                                x: 20,
                                y: 0
                            }
                        },
                        {
                            name: 'neutral',
                            indices: [0],
                            frameRate: 0,
                            loop: false,
                            offset: {
                                x: 20,
                                y: 0
                            }
                        }
                    ],
                    healthAnimations: [
                        {
                            percent: 0,
                            name: 'lose'
                        },
                        {
                            percent: 20,
                            name: 'neutral'
                        }
                    ],
                    properties: {
                        flipX: false,
                        antialiasing: false,
                        scale: {
                            x: 1,
                            y: 1,
                        }
                    },
                    bopScale: {
                        x: 1.2,
                        y: 1.2
                    },
                    bopModulo: 1,
                    speed: 0.33,
                    format: FormatterType.ICON.format()
                }
            },
            WEEK => {
                path: 'weeks',
                format: FormatterType.WEEK.format(),
                resolvers: [
                    function (rawJson:Dynamic, id:String, ?args:Array<Dynamic>)
                    {
                        final difficulties:Null<String> = cast rawJson.difficulties;

                        return {
                            songs: [
                                for (song in cast(rawJson.songs, Array<Dynamic>))
                                    {
                                        name: song[0],
                                        icon: song[1],
                                        color: song[2]
                                    }
                            ],
                            characters: rawJson.weekCharacters,
                            background: rawJson.weekBackground,
                            image: id,
                            phrase: rawJson.storyName,
                            locked: !rawJson.startUnlocked,
                            hideStoryMode: rawJson.hideStoryMode,
                            hideFreeplay: rawJson.hideFreeplay,
                            weekBefore: rawJson.weekBefore,
                            difficulties: difficulties == null || difficulties.length <= 0 ? ['Easy', 'Normal', 'Hard'] : difficulties.trim().split(','),
                            format: FormatterType.WEEK.format()
                        }
                    }
                ],
                example: {
                    songs: [
                        {
                            name: 'Bopeebo',
                            icon: 'dad',
                            color: [255, 255, 255]
                        }
                    ],
                    opponent: 'dad',
                    extra: 'gf',
                    player: 'bf',
                    background: 'stage',
                    image: 'week1',
                    phrase: '',
                    locked: false,
                    hideStoryMode: false,
                    hideFreeplay: false,
                    weekBefore: '',
                    difficulties: ['Easy', 'Normal', 'Hard'],
                    format: FormatterType.WEEK.format()
                }
            }
        ];
    }

    public static function clear()
    {
        if (config != null)
            for (val in config)
                val.cache?.clear();
    }

    public static function fix(example:Dynamic, data:Dynamic)
    {
        for (prop in Reflect.fields(example))
        {
            final dataProp = Reflect.field(data, prop);

            final exampleProp = Reflect.field(example, prop);
            
            if (dataProp == null)
                Reflect.setField(data, prop, exampleProp);
            else if (Reflect.isObject(dataProp))
                fix(exampleProp, dataProp);
        }

        return data;
    }

    public static function get(type:String, file:String, ?resolverArgs:Array<Dynamic>, ?exampleArgs:Array<Dynamic>):Dynamic
    {
        final data:FormatterConfig = config.get(type);

        if (data?.cache[file] != null)
            return data.cache[file];

        final rawJson:Dynamic = Paths.json('data/' + data.path + '/' + file, false, false);

        var result:Dynamic = null;

        if (rawJson != null)
        {
            if (rawJson.format == data.format)
            {
                result = fix(data.example, rawJson);
            } else if (data.resolvers != null) {
                for (method in data.resolvers)
                {
                    try
                    {
                        final curResult:Null<JsonCharacter> = method(rawJson, file, resolverArgs);

                        if (curResult != null)
                        {
                            result = fix(data.example, curResult);

                            break;
                        }
                    } catch(e:Dynamic) {}
                }
            }
        }

        if (result == null || !data.fileCheck(result))
            result = data.exampleModifier(data.example, file, exampleArgs);

        final returnValue:Dynamic = result ?? data.example;

        if (returnValue != null)
            data.cache[file] = returnValue;

        return returnValue;
    }

    public static function getSong(name:String, difficulty:String):ALESong
    {
        final path:String = 'songs/' + name + '/charts/' + difficulty + '.json';

        final complexPath:String = FileUtil.searchComplexFile(path);

        var json:Dynamic = Paths.json(complexPath.substring(0, path.length - 5));

        var result:ALESong = null;

        if (json.format == 'ale-chart-v0.1')
            result = cast json;

        if (result == null)
        {
            var psychSong:PsychSong = getPsychSong(json);

            final onlyGF:Bool = psychSong.gfVersion == psychSong.player2;

            result = {
                events: psychSong.events,
                strumLines: [
                    for (i in 0...3)
                    {
                        if (i != 1 || !onlyGF)
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
                    }
                ],
                sections: [],
                speed: psychSong.speed,
                bpm: psychSong.bpm,
                format: 'ale-chart-v0.1',
                stepsPerBeat: 4,
                beatsPerSection: 4,
                stage: psychSong.stage
            };

            for (section in psychSong.notes)
            {
                var curSection:ALESongSection = {
                    notes: [],
                    camera: onlyGF ? [section.mustHitSection ? 1 : 0] : [section.gfSection ? 0 : section.mustHitSection ? 2 : 1, 0],
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
                            note[3] == 'GF Sing' && (section.gfSection || (!section.mustHitSection && onlyGF)) && note[1] < 4 ? '' : (note[3] ?? ''),
                            onlyGF ? section.mustHitSection && note[1] > 3 || !section.mustHitSection && note[1] < 4 || note[3] == 'GF Sing' ? 0 : 1 : note[3] == 'GF Sing' || section.gfSection && note[1] < 4 ? 0 : (section.mustHitSection && note[1] < 4) || (!section.mustHitSection && note[1] > 3) ? 2 : 1,
                            0
                        ];

                        curSection.notes.push(arrayNote);
                    }
                }

                result.sections.push(curSection);
            }
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
			json.gfVersion = json.player3 ?? 'gf';

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

    public static function getCharacter(id:String, type:CharacterType):JsonCharacter
        return cast get(CHARACTER, id, [type]);

    public static function getStage(id:String):JsonStage
        return cast get(STAGE, id);

    public static function getStrumLine(id:String):JsonStrumLine
        return cast get(STRUMLINE, id);

    public static function getIcon(id:String):JsonIcon
        return cast get(ICON, id);

    public static function getHud(id:String):ALEHud
        return cast Paths.json('data/huds/' + id);

    public static function getWeek(id:String):ALEWeek
        return cast get(WEEK, id);
}