package core.interfaces;

import flixel.FlxState;
import flixel.FlxBasic;

import utils.Song.SwagSong;

interface IMusicState
{
    private var bpmChangeMap:Null<Array<Float>>;

    public function calculateBPMChanges(?song:Null<SwagSong>):Void;

    private var _lastStep:Int;
    public var curStep:Int;

    public var curBeat:Int;

    public var curSection:Int;

    public var shouldUpdateMusic:Bool;

    public function updateMusic():Void;

    public function stepHit():Void;
    public function beatHit():Void;
    public function sectionHit():Void;

    private var lastSafeStep:Int;
    public function safeStepHit(safeStep:Int):Void;

    private var lastSafeBeat:Int;
    public function safeBeatHit(safeBeat:Int):Void;

    private var lastSafeSection:Int;
    public function safeSectionHit(safeSection:Int):Void;
}