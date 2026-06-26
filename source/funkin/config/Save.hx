package funkin.config;

class Save
{
    public static var options:SaveFile;
    public static var controls:SaveFile;
    public static var score:SaveFile;
    public static var custom:SaveFile;

    public static function init()
    {
        options = new SaveFile('options');
        controls = new SaveFile('controls');
        score = new SaveFile('score');
        custom = new SaveFile('custom');

        load();
    }

    public static function load()
    {
        function isCustom(res:Dynamic, ogRes:Dynamic):Bool
            return res == null || ogRes == null || Type.typeof(res) != Type.typeof(ogRes);

        for (field in Reflect.fields(options.data))
        {
            final res = Reflect.field(options.data, field);
            final ogRes = Reflect.field(ClientPrefs.data, field);

            Reflect.setField(isCustom(res, ogRes) ? ClientPrefs.custom : ClientPrefs.data, field, res);
        }

        FlxG.updateFramerate = FlxG.drawFramerate = ClientPrefs.data.framerate;

		FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;

        for (field in Reflect.fields(controls.data))
        {
            final res = Reflect.field(controls.data, field);
            final ogRes = Reflect.field(ClientPrefs.controls, field);

            if (isCustom(res, ogRes))
                Reflect.setField(ClientPrefs.customControls, field, {});

            for (subField in Reflect.fields(res))
            {
                final subRes = Reflect.field(res, subField);
                final ogSubRes = Reflect.field(ogRes, subField);

                if (isCustom(subRes, ogSubRes))
                {
                    if (!Reflect.hasField(ClientPrefs.customControls, field))
                        Reflect.setField(ClientPrefs.customControls, field, {});

                    Reflect.setField(Reflect.field(ClientPrefs.customControls, field), subField, subRes);
                } else {
                    Reflect.setField(ogRes, subField, subRes);
                }
            }
        }

        if (score.data.songs != null)
        {
            for (song in Reflect.fields(score.data.songs))
            {
                Score.songs[song] = new Map();

                for (diff in Reflect.fields(Reflect.field(score.data.songs, song)))
                    Score.songs[song][diff] = Reflect.field(Reflect.field(score.data.songs, song), diff);
            }
        }

        if (score.data.weeks != null)
        {
            for (week in Reflect.fields(score.data.weeks))
            {
                Score.weeks[week] = new Map();

                for (diff in Reflect.fields(Reflect.field(score.data.weeks, week)))
                    Score.weeks[week][diff] = Reflect.field(Reflect.field(score.data.weeks, week), diff);
            }
        }
    }

    public static function save()
    {
        savePreferences();
        
        saveControls();

        saveScore();

        saveCustom();
    }

    public static function savePreferences()
    {
        options.data = Reflect.copy(ClientPrefs.data);
        options.merge(ClientPrefs.custom);
        options.save();
    }

    public static function saveControls()
    {
        controls.data = Reflect.copy(ClientPrefs.controls);
        controls.merge(ClientPrefs.customControls);
        controls.save();
    }

    public static function saveScore()
    {
        score.data.songs ??= {};

        for (song in Score.songs.keys())
        {
            if (!Reflect.hasField(score.data.songs, song))
                Reflect.setField(score.data.songs, song, {});

            final curSong = Score.songs[song];

            for (diff in curSong.keys())
                Reflect.setField(Reflect.field(score.data.songs, song), diff, curSong[diff]);
        }

        score.data.weeks ??= {};

        for (week in Score.weeks.keys())
        {
            if (!Reflect.hasField(score.data.weeks, week))
                Reflect.setField(score.data.weeks, week, {});

            final curWeek = Score.weeks[week];

            for (diff in curWeek.keys())
                Reflect.setField(Reflect.field(score.data.weeks, week), diff, curWeek[diff]);
        }

        score.save();
    }

    public static function saveCustom()
        custom.save();

    public static function destroy()
    {
        save();

        options = null;
        controls = null;
        score = null;
        custom = null;
    }
}