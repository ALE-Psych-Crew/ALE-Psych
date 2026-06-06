package core.interfaces;

interface IMusicState extends IState
{
    public function stepHit(curStep:Int):Void;
    public function safeStepHit(safeStep:Int):Void;

    public function beatHit(curBeat:Int):Void;
    public function safeBeatHit(safeBeat:Int):Void;

    public function sectionHit(curSection:Int):Void;
    public function safeSectionHit(safeSection:Int):Void;

    public function musicPlay():Void;
    public function musicPause():Void;
    public function musicResume():Void;
    public function musicStop():Void;
    public function musicComplete():Void;
    public function musicResync():Void;
}