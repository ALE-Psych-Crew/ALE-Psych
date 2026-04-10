package funkin.visuals.game;

import utils.Formatter;

import core.structures.JsonCharacter;

import core.enums.CharacterType;

class Character extends Bopper
{
    public var type:CharacterType;

    public var id:String;

    @:unreflective public var _castConfig(get, never):JsonCharacter;
    function get__castConfig():JsonCharacter
        return cast config;

    public function new(name:String, type:CharacterType)
    {
        pathPrefix = 'characters/';

        super();
        
        beatHit = (curBeat) -> {
            if (bopTimer <= 0)
                playAnim(_castConfig.bopAnimations[curBeat % _castConfig.bopAnimations.length]);
        }

        change(name, type);

        flipX = _castConfig.properties.flipX != (this.type == 'player');

        beatHit(0);

        anim.onFinish.add((name) -> {
            playAnim(name + '-loop');
        });
    }

    public function change(id:String, ?type:CharacterType)
    {
        if (type != null)
            this.type = type;

        fromJson(Formatter.getCharacter(id, type));

        this.id = id;
    }

    public var bopTimer:Float = 0;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (bopTimer > 0)
            bopTimer -= elapsed;
    }

    public function playTimedAnim(?anim:String, ?applyTimer:Bool = true, ?force:Bool = true)
    {
        playAnim(anim, force);

        if (applyTimer)
            bopTimer = _castConfig.animationLength;
    }

    public var vocals:Array<FlxSound> = [];

    public function sing(?anim:String, ?applyTimer:Bool = true, ?force:Bool)
    {
        playTimedAnim(anim, applyTimer, force);

        for (vocal in vocals)
            if (vocal != null)
                vocal.volume = 1;
    }

    public function miss(?anim:String, ?applyTimer:Bool = true, ?force:Bool)
    {
        playTimedAnim(anim, applyTimer, force);

        for (vocal in vocals)
            if (vocal != null)
                vocal.volume = 0;
    }
}