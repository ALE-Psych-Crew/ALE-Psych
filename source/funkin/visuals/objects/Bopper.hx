package funkin.visuals.objects;

import core.interfaces.IMusicObject;

class Bopper extends FunkinSprite implements IMusicObject
{
    public function stepHit(curStep:Int) {}
    public function safeStepHit(safeStep:Int) {}

    public function beatHit(curBeat:Int) {}
    public function safeBeatHit(safeBeat:Int) {}

    public function sectionHit(curSection:Int) {}
    public function safeSectionHit(safeSection:Int) {}
}