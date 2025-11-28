package;

typedef ALEWeek = {
    var songs:Array<ALEWeekSong>;

    var characters:Array<String>;

    var background:String;

    var image:String;

    var phrase:String;

    var locked:Bool;

    var hideStoryMode:Bool;
    var hideFreeplay:Bool;
    
    var format:String;

    var difficulties:Array<String>;
}

typedef ALEWeekSong = {
    var name:String;
    var icon:String;
    var color:Array<Int>;
};

using StringTools;

class ALEParserHelper 
{
    public static function getALEWeek(name:String):ALEWeek
    {
        if (Paths.exists('weeks/' + name + '.json'))
        {
            var data:Dynamic = Paths.json('weeks/' + name);

            if (data.format == 'ale-format-v0.1')
            {
                return cast data;
            } else {
                var difficulties:Null<String> = cast data.difficulties;
                
                var formattedWeek:ALEWeek = cast {
                    songs: [],

                    characters: data.weekCharacters,

                    background: data.weekBackground,

                    image: name,

                    phrase: data.storyName,

                    locked: !data.startUnlocked,

                    hideStoryMode: data.hideStoryMode,
                    hideFreeplay: data.hideFreeplay,

                    weekBefore: data.weekBefore,

                    difficulties: difficulties == null || difficulties.length <= 0 ? ['Easy', 'Normal', 'Hard'] : difficulties.trim().split(','),

                    format: 'ale-format-v0.1'
                };

                if (data.songs is Array)
                    for (song in cast(data.songs, Array<Dynamic>))
                        formattedWeek.songs.push(cast {
                                name: song[0],
                                icon: song[1],
                                color: song[2]
                            }
                        );

                return cast formattedWeek;
            }
        } else {
            return cast {
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

                format: 'ale-format-v0.1'
            };
        }
    }
}