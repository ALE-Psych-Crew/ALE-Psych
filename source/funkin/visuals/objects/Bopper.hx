package funkin.visuals.objects;

import core.interfaces.IMusicObject;

import core.structures.JsonBopper;

class Bopper extends FunkinSprite implements IMusicObject
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

    public function configBeatHitAnimations():Bopper
    {
        final castConfig:JsonBopper = cast config;

        if (castConfig.animations != null && castConfig.bopAnimations != null)
            beatHit = (beat) -> playAnim(castConfig.bopAnimations[beat % castConfig.bopAnimations.length]);

        return this;
    }

    override function restart():FunkinSprite
    {
        stepHit = null;
        safeStepHit = null;

        beatHit = null;
        safeBeatHit = null;

        sectionHit = null;
        safeSectionHit = null;

        musicPlay = null;
        musicPause = null;
        musicResume = null;
        musicStop = null;
        musicComplete = null;
        musicResync = null;

        return this;
    }
}