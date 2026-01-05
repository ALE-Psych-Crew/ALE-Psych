package core.interfaces;

import core.structures.BPMChange;

import flixel.FlxState;
import flixel.FlxBasic;

import utils.Song.SwagSong;

interface IMusicState
{
    private var bpmChangeMap:Null<Array<BPMChange>>;

    public function calculateBPMChanges(?song:Null<SwagSong>):Void;

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