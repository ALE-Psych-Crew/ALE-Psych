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

    public var musicComplete:Void -> Void;

    public function configBeatHitAnimations():Bopper
    {
        final castConfig:JsonBopper = cast config;

        if (castConfig.animations != null && castConfig.bopAnimations != null)
            beatHit = (beat) -> playAnim(castConfig.bopAnimations[beat % castConfig.bopAnimations.length]);

        return this;
    }
}