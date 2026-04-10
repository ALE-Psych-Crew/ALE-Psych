package core.interfaces;

interface IMusicObject
{
    public var stepHit:Int -> Void;
    public var safeStepHit:Int -> Void;

    public var beatHit:Int -> Void;
    public var safeBeatHit:Int -> Void;

    public var sectionHit:Int -> Void;
    public var safeSectionHit:Int -> Void;
}