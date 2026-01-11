package funkin.states;

import core.structures.ALESong;

import funkin.visuals.game.StrumLine;

import utils.ALEFormatter;

class NeoPlayState extends MusicBeatState
{
    var SONG:ALESong;

    var instSound:openfl.media.Sound;

    public function new(?song:String, ?difficulty:String)
    {
        super();
            
        SONG ??= ALEFormatter.getSong(song ?? 'fresh', difficulty ?? 'hard');

        instSound = Paths.voices('songs/' + (song ?? 'fresh'));
    }

    override function create()
    {
        super.create();

        FlxG.sound.playMusic(instSound);

        loadSong();
    }

    public function loadSong()
    {
        initStrumLines();
    }

    public var strumLines:FlxTypedGroup<StrumLine>;

    public function initStrumLines()
    {
        final notes:Array<Array<Dynamic>> = [];

        for (section in SONG.sections)
        {
            for (note in section.notes)
            {
                notes[note[4][0]] ??= [];

                notes[note[4][0]].push(
                    [
                        note[0],
                        note[1],
                        note[2],
                        note[3],
                        note[4][1]
                    ]
                );
            }
        }

        strumLines = new FlxTypedGroup<StrumLine>();
        add(strumLines);

        for (strlIndex => strl in SONG.strumLines)
            strumLines.add(new StrumLine(strl, notes[strlIndex] ?? [], SONG.speed));
    }

    override function update(elapsed:Float)
    {
        Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);
    }
}