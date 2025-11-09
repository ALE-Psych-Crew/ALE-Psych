package utils;

import haxe.ds.StringMap;

import flixel.util.FlxSave;

import utils.cool.FileUtil;

import utils.Score;

class ALESave
{
    public var preferences:FlxSave;

    public var score:FlxSave;

    public var custom:FlxSave;

    public var controls:FlxSave;

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
    }

    public function loadPreferences()
    {
		if (preferences.data.settings != null)
		{
			for (field in Reflect.fields(preferences.data.settings))
				if (Reflect.field(ClientPrefs.data, field) != null)
					Reflect.setField(ClientPrefs.data, field, Reflect.field(preferences.data.settings, field));
		}

        if (custom.data.settings != null)
        {
            ClientPrefs.custom = custom.data.settings;
                    
            if (Paths.exists('options.json'))
            {
                var jsonData:Dynamic = Paths.json('options');

                if (jsonData.categories is Array)
                    for (cat in cast(jsonData.categories, Array<Dynamic>))
                        if (cat.options != null)
                            for (option in cast(cat.options, Array<Dynamic>))
                                if (Reflect.fields(CoolUtil.save.custom.data.settings).contains(option.variable))
                                    Reflect.setField(ClientPrefs.custom, option.variable, Reflect.field(CoolUtil.save.custom.data.settings, option.variable));
                                else
                                    Reflect.setField(ClientPrefs.custom, option.variable, option.initialValue);
            }
        } else {
            ClientPrefs.custom = {};
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

    public function loadControls()
    {
        if (controls.data.settings != null)
			for (field in Reflect.fields(controls.data.settings))
				if (Reflect.field(ClientPrefs.controls, field) != null)
					Reflect.setField(ClientPrefs.controls, field, Reflect.field(controls.data.settings, field));
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
    }

    public function load()
    {
        loadPreferences();

        loadScore();
        
        loadControls();
    }

    public function save()
    {
        savePreferences();

        saveScore();

        saveControls();
    }

    public function destroy()
    {
        ClientPrefs.data = null;
        ClientPrefs.data = {};
        
        ClientPrefs.custom = null;
        ClientPrefs.custom = {};

        preferences.destroy();
        preferences = null;

        score.destroy();
        score = null;

        controls.destroy();
        controls = null;

        custom.destroy();
        custom = null;
    }
}