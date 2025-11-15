package core.config;

import core.structures.ControlsSaveData;
import core.structures.SaveData;

import flixel.input.keyboard.FlxKey;

class ClientPrefs
{
	public static var controls:ControlsSaveData = {
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
			back: [FlxKey.ESCAPE, null],
			reset: [FlxKey.R, FlxKey.F5],
			pause: [FlxKey.ENTER, FlxKey.ESCAPE]
		},
		engine: {
			chart: [FlxKey.SEVEN, null],
			character: [FlxKey.EIGHT, null],
			switch_mod: [FlxKey.M, null],
			reset_game: [FlxKey.N, null],
			master_menu: [FlxKey.SEVEN, null],
			fps_counter: [FlxKey.F3, null]
		}
	};

    public static var data:SaveData = {};

	public static var custom:Dynamic = {};
}