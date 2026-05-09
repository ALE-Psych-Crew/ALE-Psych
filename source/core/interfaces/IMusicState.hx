package core.interfaces;

interface IMusicState
{
    private var addedConductorListeners:Bool;

    public function addConductorListeners():Void;

    private var removedConductorListeners:Bool;

    public function removeConductorListeners():Void;

    private function recursiveMusicHit(obj:Dynamic, handler:IMusicObject -> Void):Void;

    private function onStepHit(step:Int):Void;
    private function onSafeStepHit(safeStep:Int):Void;

    private function onBeatHit(beat:Int):Void;
    private function onSafeBeatHit(safeBeat:Int):Void;

    private function onSectionHit(section:Int):Void;
    private function onSafeSectionHit(safeSection:Int):Void;

    public function stepHit(curStep:Int):Void;
    public function safeStepHit(safeStep:Int):Void;

    public function beatHit(curBeat:Int):Void;
    public function safeBeatHit(safeBeat:Int):Void;

    public function sectionHit(curSection:Int):Void;
    public function safeSectionHit(safeSection:Int):Void;
}