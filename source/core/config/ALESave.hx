package core.config;

import haxe.ds.StringMap;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

import utils.cool.FileUtil;
import utils.Score;

class ALESave
{
    public var score:FlxSave;

    public var preferences:FlxSave;

    public var custom:FlxSave;

    public var controls:FlxSave;

    public var customControls:FlxSave;

    public function new()
    {
        preferences = new FlxSave();
		preferences.bind('preferences', FileUtil.getSavePath());

        score = new FlxSave();
        score.bind('score', FileUtil.getSavePath());

        custom = new FlxSave();
        custom.bind('custom', FileUtil.getSavePath());

        controls = new FlxSave();
        controls.bind('controls', FileUtil.getSavePath());

        customControls = new FlxSave();
        customControls.bind('customControls', FileUtil.getSavePath());
    }

    public function loadScore()
    {
        CoolUtil.save.score.data.song ??= new StringMap<Float>();

        Score.song = CoolUtil.save.score.data.song;

        CoolUtil.save.score.data.week ??= new StringMap<Float>();

        Score.week = CoolUtil.save.score.data.week;

        CoolUtil.save.score.data.rating ??= new StringMap<Float>();

        Score.rating = CoolUtil.save.score.data.rating;

        CoolUtil.save.score.data.completed ??= new StringMap<Bool>();

        Score.completed = CoolUtil.save.score.data.completed;
    }

    public function loadPreferences()
    {
		if (preferences.data.settings != null)
		{
			for (field in Reflect.fields(preferences.data.settings))
				if (Reflect.field(ClientPrefs.data, field) != null)
					Reflect.setField(ClientPrefs.data, field, Reflect.field(preferences.data.settings, field));
		}

        if (custom.data.settings == null)
            ClientPrefs.custom = {};
        else
            ClientPrefs.custom = custom.data.settings;

        if (Paths.exists('options.json'))
        {
            var jsonData:Dynamic = Paths.json('options');

            if (jsonData.categories is Array)
                for (cat in cast(jsonData.categories, Array<Dynamic>))
                    if (cat.options != null)
                        for (option in cast(cat.options, Array<Dynamic>))
                            if (option.variable != null && Reflect.field(ClientPrefs.data, option.variable) == null)
                                Reflect.setField(ClientPrefs.custom, option.variable, Reflect.field(CoolUtil.save.custom.data.settings, option.variable) ?? option.initialValue);
        }

		if (ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		} else {
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
    }

    public function loadControls()
    {
        if (controls.data.settings != null)
			for (field in Reflect.fields(controls.data.settings))
				if (Reflect.field(ClientPrefs.controls, field) != null)
					Reflect.setField(ClientPrefs.controls, field, Reflect.field(controls.data.settings, field));


        if (custom.data.settings == null)
            ClientPrefs.custom = {};
        else            
            ClientPrefs.customControls = custom.data.settings;

        if (Paths.exists('controls.json'))
        {
            var jsonControls:Array<Dynamic> = cast Paths.json('controls').categories;

            for (jsonGroup in jsonControls)
            {
                var group = Reflect.field(ClientPrefs.controls, jsonGroup.name) ?? Reflect.field(ClientPrefs.customControls, jsonGroup.name);

                if (group == null)
                {
                    Reflect.setProperty(ClientPrefs.customControls, jsonGroup.name, {});

                    group = Reflect.field(ClientPrefs.customControls, jsonGroup.name);
                }

                for (jsonOption in cast(jsonGroup.options, Array<Dynamic>))
                    if (Reflect.field(group, jsonOption.variable) == null)
                        Reflect.setField(group, jsonOption.variable, [for (def in cast(jsonOption.initialValue, Array<Dynamic>)) FlxKey.fromString(def)]);
            }
        }
    }

    public function savePreferences()
    {
		preferences.data.settings = ClientPrefs.data;
		preferences.flush();

		custom.data.settings = ClientPrefs.custom;
		custom.flush();
    }

    public function saveScore()
    {
		CoolUtil.save.score.data.song = Score.song;
		
		CoolUtil.save.score.data.week = Score.week;

		CoolUtil.save.score.data.rating = Score.rating;

        CoolUtil.save.score.data.completed = Score.completed;
        
		CoolUtil.save.score.flush();
    }

    public function saveControls()
    {
        controls.data.settings = ClientPrefs.controls;
        controls.flush();
        
        customControls.data.settings = ClientPrefs.customControls;
        customControls.flush();
    }

    public function load()
    {
        try
        {
            loadPreferences();

            loadScore();
            
            loadControls();
        } catch(e) {
            debugTrace('While loading preferences: ' + e, ERROR);
        }
    }

    public function save()
    {
        try
        {
            savePreferences();

            saveScore();

            saveControls();
        } catch(e) {
            debugTrace('While saving preferences: ' + e, ERROR);
        }
    }

    public function reset()
    {
        save();
        
        ClientPrefs.data = {};
        
        ClientPrefs.custom = {};

        load();
    }

    public function destroy()
    {
        ClientPrefs.data = {};
        
        ClientPrefs.custom = {};
        
        ClientPrefs.customControls = {};

        score.destroy();
        score = null;

        preferences.destroy();
        preferences = null;

        custom.destroy();
        custom = null;

        controls.destroy();
        controls = null;

        customControls.destroy();
        customControls = null;
    }
}