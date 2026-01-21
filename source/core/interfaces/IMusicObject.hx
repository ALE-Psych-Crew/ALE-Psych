package core.interfaces;

interface IMusicObject
{
    public function stepHit(curStep:Int):Void;
    public function safeStepHit(safeStep:Int):Void;

    public function beatHit(curBeat:Int):Void;
    public function safeBeatHit(safeBeat:Int):Void;

    public function sectionHit(curSection:Int):Void;
    public function safeSectionHit(safeSection:Int):Void;
}