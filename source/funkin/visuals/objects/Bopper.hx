package funkin.visuals.objects;

import core.interfaces.IMusicObject;

class Bopper extends FunkinSprite implements IMusicObject
{
    public var stepHit:Int -> Void;
    public var safeStepHit:Int -> Void;

    public var beatHit:Int -> Void;
    public var safeBeatHit:Int -> Void;

    public var sectionHit:Int -> Void;
    public var safeSectionHit:Int -> Void;
}