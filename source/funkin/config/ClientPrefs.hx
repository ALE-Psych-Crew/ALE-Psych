package funkin.config;

import core.structures.ControlsData;
import core.structures.SaveData;

import flixel.input.keyboard.FlxKey;

class ClientPrefs
{
    public static var data:SaveData;

	public static var custom:Dynamic;
	
	public static var controls:ControlsData;

	public static var customControls:Dynamic;
	
	public static function init()
	{
		data = {
			antialiasing: true,
			flashing: true,
			lowQuality: false,
			shaders: true,
			
			downScroll: false,
			ghostTapping: true,
			noReset: false,

			cacheOnGPU: true,
			framerate: 120,

			checkForUpdates: true,
			
			discordRPC: true,

			botplay: false,

			practice: false
		};

		custom = {};

		controls = {
			notes: {
				left: [FlxKey.A, FlxKey.LEFT],
				down: [FlxKey.S, FlxKey.DOWN],
				up: [FlxKey.W, FlxKey.UP],
				right: [FlxKey.D, FlxKey.RIGHT]
			},

			ui: {
				left: [FlxKey.A, FlxKey.LEFT],
				down: [FlxKey.S, FlxKey.DOWN],
				up: [FlxKey.W, FlxKey.UP],
				right: [FlxKey.D, FlxKey.RIGHT],
				accept: [FlxKey.ENTER, FlxKey.SPACE],
				back: [FlxKey.ESCAPE],
				reset: [FlxKey.R, FlxKey.F5],
				pause: [FlxKey.ENTER, FlxKey.ESCAPE],
				mute: [FlxKey.ZERO],
				volume_up: [FlxKey.PLUS, FlxKey.NUMPADPLUS],
				volume_down: [FlxKey.MINUS, FlxKey.NUMPADMINUS]
			},

			engine: {
				chart: [FlxKey.SEVEN],
				character: [FlxKey.EIGHT],
				switch_mod: [FlxKey.M],
				reset_game: [FlxKey.N],
				master_menu: [FlxKey.SEVEN],
				fps_counter: [FlxKey.F3]
			}
		};

		customControls = {};
	}

	public static function getPreference(id:String):Dynamic
		return Reflect.field(data, id) ?? Reflect.field(custom, id);

	public static function setPreference(id:String, value:Dynamic):Dynamic
	{
		if (Reflect.field(data, id) == null)
			Reflect.setField(custom, id, value);
		else
			Reflect.setField(data, id, value);

		return value;
	}

	public static function getControl(groupID:String, id:String):Null<Array<Int>>
	{
		final group = Reflect.field(controls, groupID) ?? Reflect.field(customControls, groupID);

		return group == null ? null : cast Reflect.field(group, id);
	}

	public static function setControl(groupID:String, id:String, value:Array<Int>):Array<Int>
	{
		final group = Reflect.field(controls, groupID) ?? Reflect.field(customControls, groupID);

		if (group != null)
			Reflect.setField(group, id, value);

		return value;
	}
}