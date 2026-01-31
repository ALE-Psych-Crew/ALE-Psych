package core.structures;

import core.structures.NotesControls;
import core.structures.UIControls;
import core.structures.EngineControls;

import flixel.input.keyboard.FlxKey;

@:structInit class ControlsData
{
	public var notes:NotesControls = {
		left: [FlxKey.A, FlxKey.LEFT],
		down: [FlxKey.S, FlxKey.DOWN],
		up: [FlxKey.W, FlxKey.UP],
		right: [FlxKey.D, FlxKey.RIGHT]
	};

	public var ui:UIControls = {
		left: [FlxKey.A, FlxKey.LEFT],
		down: [FlxKey.S, FlxKey.DOWN],
		up: [FlxKey.W, FlxKey.UP],
		right: [FlxKey.D, FlxKey.RIGHT],
		accept: [FlxKey.ENTER, FlxKey.SPACE],
		back: [FlxKey.ESCAPE, null],
		reset: [FlxKey.R, FlxKey.F5],
		pause: [FlxKey.ENTER, FlxKey.ESCAPE]
	};

	public var engine:EngineControls = {
		chart: [FlxKey.SEVEN, null],
		character: [FlxKey.EIGHT, null],
		switch_mod: [FlxKey.M, null],
		reset_game: [FlxKey.N, null],
		master_menu: [FlxKey.SEVEN, null],
		fps_counter: [FlxKey.F3, null]
	};
}