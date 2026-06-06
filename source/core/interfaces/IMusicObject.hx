package core.interfaces;

interface IMusicObject
{
    public var stepHit:Int -> Void;
    public var safeStepHit:Int -> Void;

    public var beatHit:Int -> Void;
    public var safeBeatHit:Int -> Void;

    public var sectionHit:Int -> Void;
    public var safeSectionHit:Int -> Void;
    
    public var musicPlay:Void -> Void;
    public var musicPause:Void -> Void;
    public var musicResume:Void -> Void;
    public var musicStop:Void -> Void;
    public var musicComplete:Void -> Void;
    public var musicResync:Void -> Void;
}