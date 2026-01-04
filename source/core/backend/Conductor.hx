package core.backend;

@:access(core.backend.MusicBeatState)
class Conductor
{
	public static var offset:Float = 0;

	public static var safeZoneOffset:Float = 0;

	public static var songPosition:Float;

	public static var stepsPerBeat:Int = 4;
	public static var beatsPerSection:Int = 4;

	public static var bpm:Float = 100;

	public static var crochet(get, never):Float;
	static function get_crochet():Float
		return 60000 / bpm;

	public static var stepCrochet(get, never):Float;
	static function get_stepCrochet():Float
		return crochet / stepsPerBeat;

	public static var sectionCrochet(get, never):Float;
	static function get_sectionCrochet():Float
		return crochet * beatsPerSection;

	public static var curStep(get, never):Int;
	static function get_curStep():Int
		return MusicBeatState.instance == null ? 0 : MusicBeatState.instance.curStep;

	public static var curBeat(get, never):Int;
	static function get_curBeat():Int
		return MusicBeatState.instance == null ? 0 : MusicBeatState.instance.curBeat;

	public static var curSection(get, never):Int;
	static function get_curSection():Int
		return MusicBeatState.instance == null ? 0 : MusicBeatState.instance.curSection;
}