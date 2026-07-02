package core.structures;

import core.structures.EngineControls;
import core.structures.NotesControls;
import core.structures.UIControls;

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
		back: [FlxKey.ESCAPE],
		reset: [FlxKey.R, FlxKey.F5],
		pause: [FlxKey.ENTER, FlxKey.ESCAPE],
		mute: [FlxKey.ZERO],
		volume_up: [FlxKey.PLUS, FlxKey.NUMPADPLUS],
		volume_down: [FlxKey.MINUS, FlxKey.NUMPADMINUS]
	};

	public var engine:EngineControls = {
		chart: [FlxKey.SEVEN],
		character: [FlxKey.EIGHT],
		switch_mod: [FlxKey.M],
		reset_game: [FlxKey.N],
		master_menu: [FlxKey.SEVEN],
		fps_counter: [FlxKey.F3]
	};
}