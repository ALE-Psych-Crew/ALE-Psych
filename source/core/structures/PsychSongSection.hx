package core.structures;

typedef PsychSongSection = {
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Int;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}