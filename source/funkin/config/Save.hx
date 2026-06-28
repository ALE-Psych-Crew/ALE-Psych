package funkin.config;

import core.structures.JsonOption;

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
        ClientPrefs.init();

        function isCustom(res:Dynamic, ogRes:Dynamic):Bool
            return res == null || ogRes == null || Type.typeof(res) != Type.typeof(ogRes);

        if (options != null)
        {
            for (field in Reflect.fields(options.data))
            {
                final res = Reflect.field(options.data, field);
                final ogRes = Reflect.field(ClientPrefs.data, field);

                Reflect.setField(isCustom(res, ogRes) ? ClientPrefs.custom : ClientPrefs.data, field, res);
            }

            final jsonOptions:Array<{name:String, options:Array<JsonOption>}> = Paths.exists('data/options.json') ? cast Paths.json('data/options').categories : [];

            for (category in jsonOptions)
                for (option in category.options)
                    if (Reflect.field(ClientPrefs.custom, option.variable) == null || isCustom(Reflect.field(ClientPrefs.custom, option.variable), option.initial))
                        Reflect.setField(ClientPrefs.custom, option.variable, option.initial);

            FlxG.updateFramerate = FlxG.drawFramerate = ClientPrefs.data.framerate;

            FlxSprite.defaultAntialiasing = ClientPrefs.data.antialiasing;
        }

        if (controls != null)
        {
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
                        if (Reflect.field(ClientPrefs.customControls, field) != null)
                            Reflect.setField(ClientPrefs.customControls, field, {});

                        Reflect.setField(Reflect.field(ClientPrefs.customControls, field), subField, subRes);
                    } else {
                        Reflect.setField(ogRes, subField, subRes);
                    }
                }
            }
        }

        if (score != null)
        {
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
        if (options == null)
            return;

        options.data = Reflect.copy(ClientPrefs.data);
        options.merge(ClientPrefs.custom);
        options.save();
    }

    public static function saveControls()
    {
        if (controls == null)
            return;

        controls.data = Reflect.copy(ClientPrefs.controls);
        controls.merge(ClientPrefs.customControls);
        controls.save();
    }

    public static function saveScore()
    {
        if (score == null)
            return;

        score.data.songs ??= {};

        for (song in Score.songs.keys())
        {
            if (Reflect.field(score.data.songs, song) != null)
                Reflect.setField(score.data.songs, song, {});

            final curSong = Score.songs[song];

            for (diff in curSong.keys())
                Reflect.setField(Reflect.field(score.data.songs, song), diff, curSong[diff]);
        }

        score.data.weeks ??= {};

        for (week in Score.weeks.keys())
        {
            if (Reflect.field(score.data.weeks, week) != null)
                Reflect.setField(score.data.weeks, week, {});

            final curWeek = Score.weeks[week];

            for (diff in curWeek.keys())
                Reflect.setField(Reflect.field(score.data.weeks, week), diff, curWeek[diff]);
        }

        score.save();
    }

    public static function saveCustom()
        custom?.save();


    public static function reset()
    {
        clear();

        delete();

        load();
    }


    public static function clear()
    {
        options?.clear();
        controls?.clear();
        score?.clear();
        custom?.clear();
    }


    public static function delete()
    {
        options?.delete();
        controls?.delete();
        score?.delete();
        custom?.delete();
    }


    public static function destroy()
    {
        save();

        options = null;
        controls = null;
        score = null;
        custom = null;
    }
}